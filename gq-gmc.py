#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gq-gmc.py — GQ GMC Geiger counter serial poller + Textual dashboard (one file).

Speaks the GQ serial protocols directly (no vendor software, no pygmc — it is
never imported or installed):

    GQ-RFC1201 v1.40  GMC-280 / 300 / 300S / 300E+ / 320 / 320+ / 320S
                      GETCPM/GETCPS = 2 bytes big-endian (uint16)
    GQ-RFC1801        GMC-500 / 500+ / 600 / 600+ / 800
                      GETCPM/GETCPS = 4 bytes big-endian (uint32); probed safely:
                      2 bytes are read first, then a 2-byte peek — a 4-byte reply
                      is used only when it decodes sanely, 2-byte firmware works.

Serial parameters: 8N1, no flow control. Baud: 57600 (fw V3.xx and earlier),
115200 (V4.xx/Plus and later); GMC-320 is variable (factory 115200).
Autodetect probes GETVER at 57600 then 115200; --baud skips the probe list.

AUTODETECT (--port auto, the default)
    1. Scan /dev/serial/by-id/*, /dev/ttyUSB*, /dev/ttyACM* (deduped by realpath).
    2. Rank by sysfs USB VID:PID, GQ bridges first:
       CH340 1a86:7523 (most common on GQ units) > CH341 1a86:7522 >
       CP210x 10c4:ea60 > FTDI 0403:* > PL2303 067b:2303 > anything else.
    3. Probe <GETVER>> on each candidate in rank order; a valid reply is
       printable ASCII containing "GMC" or "GCM". Ports are closed between
       probes — nothing is held unless a device answers.
    --list-ports prints the candidates with USB IDs and exits without opening.

MODEL STRING
    Parsed from GETVER, e.g. "GMC-300SRe 1.05" -> model GMC-300S, firmware Re 1.05.
    Recognized families: 300 (300/300S/300E+), 320 (320/320+/320S), 500, 500+,
    600, 600+, 800, SE variants.

DOSE CONVERSION
    Default 154 CPM == 1 uSv/h (M4011 tube). If <GETCFG>> is readable, the
    unit's own calibration is used instead: the 256-byte config dump holds
    three calibration points at offsets 8/14/20 (u16BE CPM) and 10/16/22
    (float32-LE uSv/h) — verified on a live GMC-300S Re 1.05 (factory points
    105 CPM = 0.65 uSv/h -> 161.54 CPM/uSv). --cpm-per-usv overrides both.
    1 uSv/h == 0.1 mR/h (exact).

USAGE
    gq-gmc.py                          auto-detect, poll CPM every 1 s
    gq-gmc.py --once                   one reading, then exit
    gq-gmc.py --json                   NDJSON on stdout (banner -> stderr)
    gq-gmc.py --heartbeat              CPS stream via <HEARTBEAT1>>
    gq-gmc.py --list-ports             show candidate ports + USB IDs, exit
    gq-gmc.py --port /dev/ttyUSB1 --baud 115200 --interval 5
    gq-gmc.py --cpm-per-usv 154        tube calibration override
    gq-gmc.py --tui                    in-file Textual dashboard (GmcTui)
    gq-gmc.py --tui --simulate         dashboard on a virtual counter
    gq-gmc.py --pilot                  headless Textual pilot smoke test
    gq-gmc.py --guide                  print the GQ safety band table (stderr)

LAZY DEPENDENCIES (nothing installs before argparse has parsed: --help/-h is safe)
    pyserial is ensured before any `import serial`: pip -> apt python3-serial,
    then os.execv() re-exec. --tui/--pilot additionally ensure textual + rich:
    plain import -> ~/.venv-gmc site-packages fallback (pure-Python, same
    interpreter minor version) -> pip/apt install + execv re-exec. textual is
    imported only inside _tui_app_class(), which --tui/--pilot call AFTER
    argparse has parsed — so --help never imports or installs it.
    Programmatic use (hyphenated filename, so load it as a module):
        import importlib.util
        spec = importlib.util.spec_from_file_location(
            "gqgmc", os.path.expanduser("~/bin/gq-gmc.py"))
        gqgmc = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(gqgmc)      # -> GQGMC, run_tui, ensure_serial
        gqgmc.ensure_serial(); then use gqgmc.GQGMC
        gqgmc.run_tui(port=..., baud=..., interval=...,
                      cpm_per_usv=..., timeout=..., simulate=False)
    All device I/O is guarded by one reentrant lock (thread-safe polling).

TUI (GmcTui — Textual 8.x, Glamour-style dark theme, baby-blue accent)
    topbar    model · port @ baud · battery (if the device reports one)
    big row   CPM | uSv/h | mR/h
    action    big status line: the insert-card action for the current CPM band,
              colored green / yellow / orange / red / bright red
    clock     host local · UTC · device datetime
    chart     sparkline of the last ~120 CPM samples
    stats     min · max · avg CPM · elapsed · CPS · status
    safety    the full GQ 'Nuclear Radiation Safety Guide' band table, current
              band highlighted (g toggles it; vendor card, not medical/legal advice)
    footer    q quit · p pause · h heartbeat · r reset chart · g guide
    All serial I/O runs on the PollWorker thread; widgets are mounted once in
    compose() and updated IN PLACE (no DuplicateIds risk). <HEARTBEAT0>> is
    sent and the port closed on every exit path. --tui autodetects the port
    and baud first when --port is auto; --simulate uses a virtual counter.
"""

from __future__ import annotations

import argparse
import asyncio
import glob
import importlib.util
import json
import os
import queue
import random
import re
import struct
import subprocess
import sys
import threading
import time
from collections import deque
from datetime import datetime, timezone

PROG = "gq-gmc"

BAUD_CANDIDATES = (57600, 115200)   # RFC1201: 57600 fw V3.xx-, 115200 V4.xx+; 320 variable
DEFAULT_INTERVAL = 1.0
DEFAULT_TIMEOUT = 1.0
DEFAULT_CPM_PER_USV = 154.0         # M4011 tube: 154 CPM == 1 uSv/h
MR_PER_USV = 0.1                    # 1 uSv/h == 0.1 mR/h (exact)
HB_DATA_MASK = 0x3FFF               # heartbeat + GETCPS: only lowest 14 bits are data
CPM_SANITY = 1_000_000              # reject absurd counter values (protects dose math)
RFC1801_FAMILIES = (500, 600, 800)  # 4-byte GETCPM/GETCPS per GQ-RFC1801
RFC1801_PEEK_TIMEOUT = 0.05         # extra 2-byte peek for 4-byte counters

# GQ-unit USB-serial bridges, best first: (vid, pid, score); pid None = any.
USB_BRIDGES = (
    ("1a86", "7523", 100),   # CH340 — most common on GQ GMC units
    ("1a86", "7522", 95),    # CH341
    ("10c4", "ea60", 90),    # CP210x (CP2102)
    ("0403", None,   80),    # FTDI FT232 class
    ("067b", "2303", 70),    # PL2303
)
BRIDGE_NAMES = {
    ("1a86", "7523"): "CH340",
    ("1a86", "7522"): "CH341",
    ("10c4", "ea60"): "CP2102/CP210x",
    ("067b", "2303"): "PL2303",
}

serial = None  # pyserial module, set by ensure_serial() — never imported at module load


class GQGMCError(RuntimeError):
    """Protocol-level failure (short/empty read, invalid response)."""


# ---------------- lazy dependency bootstrap ----------------

def _find_spec(module):
    try:
        return importlib.util.find_spec(module)
    except (ImportError, ValueError):
        return None


def _die(msg, hint):
    sys.stderr.write("%s: %s\n  fix: %s\n" % (PROG, msg, hint))
    sys.exit(2)


def _pip_install(pkg):
    """Try plain pip, then --break-system-packages (PEP 668). Returns (ok, log)."""
    log = []
    for extra in ([], ["--break-system-packages"]):
        try:
            r = subprocess.run(
                [sys.executable, "-m", "pip", "install"] + extra + [pkg],
                capture_output=True, text=True, timeout=300,
                stdin=subprocess.DEVNULL)
        except (OSError, subprocess.SubprocessError) as exc:
            log.append("pip %s: %s" % (" ".join(extra) or "plain", exc))
            continue
        if r.returncode == 0:
            return True, "pip install %s: ok" % pkg
        tail = (r.stderr or r.stdout or "").strip().splitlines()
        log.append("pip %s: %s" % (" ".join(extra) or "plain",
                                   tail[-1] if tail else "exit %d" % r.returncode))
    return False, "; ".join(log)


def _apt_install(pkgs):
    cmd0 = ["apt-get"] if (hasattr(os, "geteuid") and os.geteuid() == 0) else ["sudo", "-n", "apt-get"]
    try:
        r = subprocess.run(cmd0 + ["install", "-y"] + pkgs,
                           capture_output=True, text=True, timeout=600,
                           stdin=subprocess.DEVNULL)
    except (OSError, subprocess.SubprocessError):
        return False
    return r.returncode == 0


def ensure_pkg(module, pip_name=None, apt_name=None, hint=None):
    """Ensure `module` is importable; install (pip -> apt) and re-exec if needed.

    MUST run before importing the module. argparse already handled --help/-h,
    so help output never triggers an install. After a successful install the
    whole process re-execs (os.execv) so the freshly installed package imports.
    """
    if _find_spec(module):
        return
    pip_name = pip_name or module
    apt_name = apt_name or ("python3-" + module)
    hint = hint or ("sudo apt install %s   (or: python3 -m pip install %s)" % (apt_name, pip_name))
    if os.environ.get("GQGMC_BOOTSTRAP") == "1":
        _die("dependency '%s' still not importable after install attempt "
             "(interpreter: %s)" % (module, sys.executable), hint)
    log = []
    ok, msg = _pip_install(pip_name)
    log.append(msg)
    if not ok and apt_name and os.path.exists("/usr/bin/apt-get"):
        ok = _apt_install([apt_name])
        log.append("apt install %s: %s" % (apt_name, "ok" if ok else "failed"))
    if not _find_spec(module):
        _die("dependency '%s' is missing and could not be installed (%s)" % (module, "; ".join(log)), hint)
    os.environ["GQGMC_BOOTSTRAP"] = "1"
    os.execve(sys.executable, [sys.executable] + sys.argv, os.environ)  # re-exec, import now works


def ensure_serial():
    """Ensure pyserial is importable, then bind it as the module global `serial`.

    Call before any serial I/O (also the entry point for the TUI worker).
    """
    ensure_pkg("serial", pip_name="pyserial", apt_name="python3-serial",
               hint="sudo apt install python3-serial   (or: python3 -m pip install pyserial)")
    global serial
    import serial  # noqa: local import on purpose (lazy dep)
    globals()["serial"] = serial


# ---------------- parsing helpers ----------------

def _clean_ascii(raw):
    """Decode bytes to printable ASCII, collapsing NULs/control chars."""
    text = "".join(ch if 32 <= ord(ch) < 127 else " " for ch in raw.decode("ascii", "replace"))
    return re.sub(r"\s+", " ", text).strip()


def is_gq_version(text):
    """RFC1201 GETVER sanity: printable ASCII containing GMC or GCM."""
    return bool(text) and ("GMC" in text or "GCM" in text)


MODEL_RE = re.compile(r"(GMC|GCM)\s*-?\s*(\d{3,4})\s*([A-Za-z+]*)(.*)", re.I)


def parse_model(text):
    """'GMC-300SRe 1.05' -> (300, 'GMC-300S', 'Re 1.05'); tolerant of firmware quirks.

    Returns (family_int_or_None, model_label, firmware_string).
    """
    m = MODEL_RE.search(text or "")
    if not m:
        label = (text or "").split()[0] if (text or "").split() else "?"
        return None, label[:16], ""
    fam = int(m.group(2))
    raw_suffix = m.group(3) or ""
    tail = (m.group(4) or "").strip()
    suffix = raw_suffix.upper()
    fw_re = bool(re.search(r"RE[0-9.]*$", suffix))  # 'Re' glued to the model = fw tag
    suffix = re.sub(r"RE[0-9.]*$", "", suffix)
    label = "GMC-%d%s" % (fam, suffix)
    fw = ("Re " + tail) if (fw_re and tail) else (tail or ("Re" if fw_re else ""))
    return fam, label, fw


def parse_cfg_calibration(cfg):
    """Extract the CPM<->uSv calibration from a GETCFG dump.

    Layout (verified on GMC-300S Re 1.05, 256-byte config; cfg[0:2]=0x00 0x01 = size BE):
        offset 8+6i  : u16 BE  CPM of calibration point i (i = 0..2)
        offset 10+6i : f32 LE  uSv/h of calibration point i
    Returns (cpm_per_usv or None, [(cpm, usv, ratio), ...valid points]).
    Every point must yield a plausible ratio (20..10000 CPM per uSv) or it is
    discarded; the highest-CPM valid point wins.
    """
    points = []
    if not cfg or len(cfg) < 26 or cfg[0] != 0x00 or cfg[1] not in (0x01, 0x02, 0x04, 0x08, 0x10):
        return None, points
    for i in range(3):
        off = 8 + 6 * i
        cpm = int.from_bytes(cfg[off:off + 2], "big")
        try:
            usv = struct.unpack("<f", cfg[off + 2:off + 6])[0]
        except struct.error:
            break
        if cpm > 0 and 0.0 < usv < 1000.0:
            ratio = cpm / usv
            if 20.0 <= ratio <= 10000.0:
                points.append((cpm, usv, ratio))
    if not points:
        return None, points
    best = max(points, key=lambda p: p[0])
    return best[2], points


# ---------------- device ----------------

class GQGMC:
    """Minimal GQ-RFC1201/RFC1801 client over pyserial. One lock guards all I/O."""

    def __init__(self, port, timeout=1.0):
        if serial is None:
            raise RuntimeError("pyserial not loaded — call gqgmc.ensure_serial() first")
        self.port = port
        self.timeout = timeout
        self.ser = None
        self.baud = None
        self.version = None
        self.model = None
        self.family = None
        self.firmware = None
        self.rfc1801 = False          # 4-byte GETCPM/GETCPS (GMC-500/600/800)
        self.calibration = None       # CPM per uSv/h from GETCFG, if readable
        self.cal_points = []
        self._voltage_cmd = None
        self._lock = threading.RLock()

    # ---- low level (all public I/O takes the lock) ----

    def open(self, baud):
        with self._lock:
            self.ser = serial.Serial(
                port=self.port,
                baudrate=baud,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=self.timeout,
                write_timeout=self.timeout,
                xonxoff=False,
                rtscts=False,
                dsrdtr=False,
            )
            self.baud = baud
            time.sleep(0.25)  # let USB bridges (CH340) settle after open/DTR

    def close(self):
        with self._lock:
            try:
                if self.ser is not None:
                    self.ser.close()
            except Exception:
                pass
            self.ser = None

    def is_open(self):
        return self.ser is not None

    def _send_u(self, cmd, payload=b""):
        """Write RFC1201 frame '<' + CMD + optional binary params + '>>'. Call under lock."""
        self.ser.reset_input_buffer()
        self.ser.write(b"<" + cmd.encode("ascii") + payload + b">>")
        self.ser.flush()

    def _read_exact_u(self, n, timeout=None):
        """Read exactly n bytes or return fewer on timeout (never raises on short)."""
        buf = bytearray()
        deadline = time.monotonic() + (self.timeout if timeout is None else timeout)
        while len(buf) < n:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                break
            self.ser.timeout = max(0.01, min(remaining, 0.5))
            chunk = self.ser.read(n - len(buf))
            if chunk:
                buf.extend(chunk)
        return bytes(buf)

    def _read_burst_u(self, max_bytes, gap=0.1):
        """Read a burst of bytes separated by < gap seconds (heartbeat framing)."""
        self.ser.timeout = gap
        return bytes(self.ser.read(max_bytes))

    def send(self, cmd):
        with self._lock:
            self._send_u(cmd)

    def read_exact(self, n, timeout=None):
        with self._lock:
            return self._read_exact_u(n, timeout)

    def read_burst(self, max_bytes, gap=0.1):
        with self._lock:
            return self._read_burst_u(max_bytes, gap)

    def identify(self, ver_text):
        """Parse a validated GETVER string: model label, family, RFC1801 flag."""
        self.version = ver_text
        self.family, self.model, self.firmware = parse_model(ver_text)
        self.rfc1801 = self.family in RFC1801_FAMILIES
        return self

    # ---- protocol commands ----

    def get_ver(self):
        """<GETVER>> -> cleaned ASCII (model + firmware); None if nothing sane."""
        with self._lock:
            self._send_u("GETVER")
            raw = self._read_exact_u(14)
            time.sleep(0.05)
            raw += self._read_exact_u(32, timeout=0.15)  # some firmware sends >14 chars
            return _clean_ascii(raw) or None

    def get_cpm(self):
        """<GETCPM>> -> uint16 BE (RFC1201) or uint32 BE (RFC1801, probed safely)."""
        with self._lock:
            self._send_u("GETCPM")
            raw = self._read_exact_u(2)
            if len(raw) < 2:
                raise GQGMCError("GETCPM returned %d byte(s)" % len(raw))
            val2 = (raw[0] << 8) | raw[1]
            if self.rfc1801:
                # RFC1801: 4-byte BE counter; RFC1201 firmware answers only 2.
                extra = self._read_exact_u(2, timeout=RFC1801_PEEK_TIMEOUT)
                if len(extra) == 2:
                    val4 = int.from_bytes(raw + extra, "big")
                    if val2 == 0 and val4:
                        return val4          # 2-byte read caught the zero high word
                    if val4 <= CPM_SANITY:
                        return val4
            if val2 > CPM_SANITY:
                raise GQGMCError("GETCPM implausible: %d" % val2)
            return val2

    def get_cps(self):
        """<GETCPS>> -> uint16 BE & 0x3FFF (uint32 BE on RFC1801); None if absent."""
        with self._lock:
            self._send_u("GETCPS")
            raw = self._read_exact_u(2)
            if self.rfc1801:
                extra = self._read_exact_u(2, timeout=RFC1801_PEEK_TIMEOUT)
                if len(extra) == 2:
                    return int.from_bytes(raw + extra, "big") & 0x3FFFFFFF
            if len(raw) < 2:
                return None
            return ((raw[0] << 8) | raw[1]) & HB_DATA_MASK

    def get_gyro(self):
        """<GETGYRO>> -> (x, y, z) signed 16-bit raw + terminator flag; None if absent."""
        with self._lock:
            self._send_u("GETGYRO")
            raw = self._read_exact_u(7)
            if len(raw) < 6:
                return None
            x, y, z = struct.unpack(">hhh", raw[0:6])
            term_ok = len(raw) >= 7 and raw[6] == 0xAA
            return (x, y, z, term_ok)

    def get_volt(self):
        """<GETVOLT>> (1 byte, V*10); <GETVOLTAGE>> fallback; None if unsupported."""
        with self._lock:
            cmds = (self._voltage_cmd,) if self._voltage_cmd else ("GETVOLT", "GETVOLTAGE")
            for cmd in cmds:
                self._send_u(cmd)
                raw = self._read_exact_u(1)
                if raw:
                    self._voltage_cmd = cmd
                    return raw[0] / 10.0
            return None

    def get_temp(self):
        """<GETTEMP>> -> 4 bytes: int, frac, sign(0=positive), 0xAA -> Celsius."""
        with self._lock:
            self._send_u("GETTEMP")
            raw = self._read_exact_u(4)
            if len(raw) < 4 or raw[3] != 0xAA:
                return None
            temp = raw[0] + raw[1] / 10.0
            if raw[2] != 0:
                temp = -temp
            return temp if -100.0 < temp < 200.0 else None

    def get_serial(self):
        """<GETSERIAL>> -> 7 bytes ASCII serial number (None if garbage/unsupported)."""
        with self._lock:
            self._send_u("GETSERIAL")
            raw = self._read_exact_u(7)
            if len(raw) < 7:
                return None
            text = _clean_ascii(raw)
            # Re.2.11+ only; older firmware returns junk — require mostly alnum
            return text if len(re.sub(r"[^A-Za-z0-9]", "", text)) >= 4 else None

    def get_datetime(self):
        """<GETDATETIME>> -> 7 bytes YY MM DD HH MM SS 0xAA -> 'YYYY-MM-DD HH:MM:SS'."""
        with self._lock:
            self._send_u("GETDATETIME")
            raw = self._read_exact_u(7)
            if len(raw) < 7:
                return None
            yy, mm, dd, hh, mi, ss = raw[0:6]
            if not (1 <= mm <= 12 and 1 <= dd <= 31 and hh <= 23 and mi <= 59 and ss <= 59):
                return None
            return "20%02d-%02d-%02d %02d:%02d:%02d" % (yy, mm, dd, hh, mi, ss)

    def set_datetime(self, when=None):
        """Set the unit RTC from the host local clock (RFC1201 <SETDATETIME[YYMMDDHHMMSS]>>).

        `when` defaults to datetime.now() (naive local). Year must be >= 2000.
        Returns True if the device ACKed 0xAA. Falls back to SETDATEYY/MM/DD and
        SETTIMEHH/MM/SS if the combined command is unsupported (pre-Re.3.00).
        """
        if when is None:
            when = datetime.now()
        if when.year < 2000:
            raise ValueError("device RTC year must be >= 2000")
        payload = bytes([
            when.year - 2000, when.month, when.day,
            when.hour, when.minute, when.second,
        ])
        fields = (
            ("SETDATEYY", payload[0]),
            ("SETDATEMM", payload[1]),
            ("SETDATEDD", payload[2]),
            ("SETTIMEHH", payload[3]),
            ("SETTIMEMM", payload[4]),
            ("SETTIMESS", payload[5]),
        )
        with self._lock:
            self._send_u("SETDATETIME", payload)
            ack = self._read_exact_u(1)
            if ack == b"\xaa":
                return True
            for cmd, val in fields:
                self._send_u(cmd, bytes([val]))
                a = self._read_exact_u(1)
                if a != b"\xaa":
                    return False
            return True

    def get_config(self):
        """<GETCFG>> -> 256-byte config dump (None if unsupported/short)."""
        with self._lock:
            self._send_u("GETCFG")
            raw = self._read_exact_u(256)
            return raw if len(raw) >= 26 else None

    def heartbeat(self, on):
        """<HEARTBEAT1>> start / <HEARTBEAT0>> stop the 1-per-second CPS stream."""
        self.send("HEARTBEAT1" if on else "HEARTBEAT0")


# ---------------- USB autodetect ----------------

def _usb_ids(node):
    """(vid, pid) for a tty node read from sysfs; (None, None) if not USB."""
    name = os.path.basename(os.path.realpath(node))
    d = os.path.realpath(os.path.join("/sys/class/tty", name, "device"))
    for _ in range(6):
        if not d or not os.path.isdir(d):
            break
        try:
            with open(os.path.join(d, "idVendor")) as f:
                vid = f.read().strip().lower()
            with open(os.path.join(d, "idProduct")) as f:
                pid = f.read().strip().lower()
            return vid, pid
        except OSError:
            d = os.path.dirname(d)  # idVendor lives on the USB device, walk up
    return None, None


def _bridge_name(vid, pid):
    if (vid, pid) in BRIDGE_NAMES:
        return BRIDGE_NAMES[(vid, pid)]
    if vid == "0403":
        return "FTDI"
    if vid == "1a86":
        return "WCH/CH34x"
    if vid == "10c4":
        return "CP210x"
    if vid == "067b":
        return "Prolific"
    return "generic USB-serial" if vid else "non-USB/unknown"


def _port_score(vid, pid):
    for bvid, bpid, score in USB_BRIDGES:
        if vid == bvid:
            return score if (bpid is None or pid == bpid) else score - 15
    return 10


def list_candidate_ports():
    """[(node, vid, pid, score, by_id_alias)] best-first, deduped by realpath."""
    seen = {}
    for link in sorted(glob.glob("/dev/serial/by-id/*")) + sorted(glob.glob("/dev/serial/by-path/*")):
        if os.path.islink(link):
            real = os.path.realpath(link)
            if os.path.exists(real):
                seen.setdefault(real, os.path.basename(link))
    for pat in ("/dev/ttyUSB*", "/dev/ttyACM*"):
        for node in sorted(glob.glob(pat)):
            real = os.path.realpath(node)
            if os.path.exists(real):
                seen.setdefault(real, None)
    out = []
    for real, alias in seen.items():
        vid, pid = _usb_ids(real)
        out.append((real, vid, pid, _port_score(vid, pid), alias))
    out.sort(key=lambda t: (-t[3], t[0]))
    return out


def connect(port, baud, timeout, probe_timeout=0.4):
    """Open `port` and probe GETVER across baud candidates; return GQGMC or None.

    The port is closed again after every failed attempt (never held).
    """
    bauds = (baud,) if baud else BAUD_CANDIDATES
    for b in bauds:
        dev = GQGMC(port, timeout=probe_timeout)
        try:
            dev.open(b)
        except (serial.SerialException, OSError, ValueError) as exc:
            _dbg("%s: open @%d failed: %s" % (port, b, exc))
            continue
        try:
            ver = dev.get_ver()
        except (serial.SerialException, GQGMCError, OSError) as exc:
            _dbg("%s: GETVER @%d failed: %s" % (port, b, exc))
            ver = None
        if ver and is_gq_version(ver):
            dev.timeout = timeout
            dev.identify(ver)
            return dev
        dev.close()
        time.sleep(0.05)
    return None


def _dbg(msg):
    if os.environ.get("GQGMC_DEBUG"):
        sys.stderr.write("[gq-gmc:debug] %s\n" % msg)


# ---------------- output ----------------

def timestamps():
    local = datetime.now().astimezone()
    utc = datetime.now(timezone.utc)
    return local.isoformat(timespec="seconds"), utc.strftime("%Y-%m-%dT%H:%M:%SZ")


def dose(cpm, cpm_per_usv):
    usv_h = cpm / cpm_per_usv
    return usv_h, usv_h * MR_PER_USV


def emit(rec, json_out):
    """One line per record. --json: exactly one NDJSON object per line on
    stdout, flushed immediately (wrapping scripts can pipe line by line).
    Banner/guide/errors go to stderr, so stdout stays pure JSON."""
    if json_out:
        print(json.dumps(rec), flush=True)  # NDJSON: one object per line
    else:
        parts = [rec["ts_local"], rec["ts_utc"]]
        if rec.get("cps") is not None:
            parts.append("CPS %d" % rec["cps"])
        if rec.get("cpm") is not None:
            parts.append("CPM %d" % rec["cpm"])
        if rec.get("cpm_est") is not None:
            parts.append("CPM~%d (1s est)" % rec["cpm_est"])
        if rec.get("usv_h") is not None:
            parts.append("%.3f uSv/h" % rec["usv_h"])
            parts.append("%.3f mR/h" % rec["mr_h"])
        print(" | ".join(parts), flush=True)


# Stable NDJSON record schema (EVERY key is always present; null when N/A):
#   ts_local, ts_utc                    host local ISO + UTC timestamps
#   cpm, cps, cpm_est                   raw CPM poll / CPS packet / 1s CPM estimate
#   usv_h, mr_h                         dose converted from cpm (or cpm_est)
#   cpm_per_usv                         tube calibration actually used
#   safety_band (0-4), safety_name, safety_action   GQ insert-card classification
#   model, firmware, port, baud         device identity of this stream
RECORD_KEYS = ("ts_local", "ts_utc", "cpm", "cps", "cpm_est", "usv_h", "mr_h",
               "cpm_per_usv", "safety_band", "safety_name", "safety_action",
               "model", "firmware", "port", "baud")


def make_record(cpm=None, cps=None, cpm_est=None, cpm_per_usv=DEFAULT_CPM_PER_USV,
                dev=None):
    """Build one record with the fixed schema above (missing values -> null).

    Safety band comes from the existing safety_band()/SAFETY_BANDS table and is
    classified by RAW CPM — cpm when polling, cpm_est (cps*60) on the heartbeat
    stream — never by the converted uSv/h.
    """
    ts_local, ts_utc = timestamps()
    basis = cpm if cpm is not None else cpm_est
    if basis is None:
        usv_h = mr_h = None
        band_idx, band = None, None
    else:
        usv_h, mr_h = dose(basis, cpm_per_usv)
        band_idx, band = safety_band(basis)
    rec = {
        "ts_local": ts_local,
        "ts_utc": ts_utc,
        "cpm": cpm,
        "cps": cps,
        "cpm_est": cpm_est,
        "usv_h": None if usv_h is None else round(usv_h, 4),
        "mr_h": None if mr_h is None else round(mr_h, 4),
        "cpm_per_usv": None if cpm_per_usv is None else round(float(cpm_per_usv), 4),
        "safety_band": band_idx,
        "safety_name": band[6] if band is not None else None,
        "safety_action": band[4] if band is not None else None,
        "model": getattr(dev, "model", None),
        "firmware": getattr(dev, "firmware", None),
        "port": getattr(dev, "port", None),
        "baud": getattr(dev, "baud", None),
    }
    assert tuple(rec) == RECORD_KEYS  # schema drift guard for wrapping scripts
    return rec


def resolve_cpm_per_usv(args, dev):
    """Override > GETCFG calibration > 154 CPM/uSv default (M4011)."""
    if args.cpm_per_usv is not None:
        return args.cpm_per_usv, "--cpm-per-usv override"
    if dev.calibration:
        return dev.calibration, "GETCFG calibration"
    return DEFAULT_CPM_PER_USV, "default (M4011 tube)"


def _safe(fn):
    try:
        return fn()
    except Exception:
        return None


def tag(dev):
    # Log tag for messages about the live unit: the detected model from
    # GETVER (e.g. GMC-300S), or PROG when the model is unknown.
    return getattr(dev, "model", None) or PROG


def banner(dev, args, cpm_per_usv, cal_src):
    saved_timeout = dev.timeout
    dev.timeout = min(saved_timeout, 0.5)  # optional probes: fail fast if absent
    try:
        serial_no = _safe(dev.get_serial)
        dt = _safe(dev.get_datetime)
        volt = _safe(dev.get_volt)
        temp = _safe(dev.get_temp)
        gyro = _safe(dev.get_gyro)
    finally:
        dev.timeout = saved_timeout
    gyro_txt = ("x=%d y=%d z=%d%s" % (gyro[0], gyro[1], gyro[2],
                "" if gyro[3] else " (bad 0xAA)")) if gyro else "n/a"
    proto = "RFC1801 (4-byte CPM)" if dev.rfc1801 else "RFC1201 (2-byte CPM)"
    t = tag(dev)
    lines = [
        "[%s] port=%s baud=%d protocol=%s" % (t, dev.port, dev.baud, proto),
        "[%s] model=%s firmware=%s getver=%r serial=%s datetime=%s" % (
            t, dev.model or "?", dev.firmware or "?", dev.version,
            serial_no or "n/a", dt or "n/a"),
        "[%s] battery=%s temp=%sC gyro=%s" % (
            t,
            ("%.1fV" % volt) if volt is not None else "n/a",
            ("%.1f" % temp) if temp is not None else "n/a",
            gyro_txt),
        "[%s] conversion: %g CPM = 1 uSv/h (%s); 1 uSv/h = %g mR/h"
        % (t, cpm_per_usv, cal_src, MR_PER_USV),
    ]
    if dev.cal_points:
        lines.insert(3, "[%s] GETCFG cal points: %s" % (t, ", ".join(
            "%d CPM=%.4g uSv/h" % (c, u) for c, u, _r in dev.cal_points)))
    if args.json:
        lines.insert(0, "[%s] (banner/status on stderr; NDJSON records on stdout)" % t)
    for line in lines:
        sys.stderr.write(line + "\n")


# ---------------- run loops ----------------

def run_poll(dev, args, cpm_per_usv, getter=None, est=False):
    """Poll <GETCPM>> (or a callable) every --interval seconds.

    est=True marks the getter as a 1-second count (GETCPS fallback on the
    heartbeat path): the record carries cpm_est instead of cpm so wrappers
    see an honest 1s estimate, classified by cpm_est like the heartbeat.
    """
    getter = getter or dev.get_cpm
    next_t = time.monotonic()
    emitted = False
    while True:
        try:
            value = getter()
        except (GQGMCError, serial.SerialException, OSError) as exc:
            sys.stderr.write("[%s] read failed: %s\n" % (tag(dev), exc))
            value = None
        if value is not None:
            if est:
                rec = make_record(cpm_est=value, cpm_per_usv=cpm_per_usv, dev=dev)
            else:
                rec = make_record(cpm=value, cpm_per_usv=cpm_per_usv, dev=dev)
            emit(rec, args.json)
            emitted = True
        if args.once:
            return 0 if emitted else 1
        next_t += args.interval
        sleep = next_t - time.monotonic()
        if sleep > 0:
            time.sleep(sleep)
        else:
            next_t = time.monotonic()  # fell behind: don't pile up


def run_heartbeat(dev, args, cpm_per_usv):
    """CPS stream via <HEARTBEAT1>>; falls back to GETCPS/GETCPM polling."""
    dev.heartbeat(True)
    sys.stderr.write("[%s] heartbeat on; expecting one CPS packet per second\n" % tag(dev))
    buf = bytearray()
    got_packet = False
    try:
        while True:
            if not buf:
                first_wait = max(2.0, args.interval + 0.5)
                first = dev.read_exact(1, timeout=first_wait)
                if not first:
                    if got_packet:
                        sys.stderr.write("[%s] no heartbeat packet in %.1fs\n" % (tag(dev), first_wait))
                        if args.once:
                            return 1
                        continue
                    # nothing at all: HEARTBEAT1 not supported by this firmware
                    sys.stderr.write("[%s] no heartbeat stream; falling back to GETCPS/GETCPM polling\n" % tag(dev))
                    dev.heartbeat(False)
                    if dev.get_cps() is not None:
                        return run_poll(dev, args, cpm_per_usv, getter=dev.get_cps, est=True)
                    return run_poll(dev, args, cpm_per_usv)
            # frame one packet: bytes of a packet arrive in a tight burst
            buf.extend(dev.read_burst(16, gap=0.1))
            if len(buf) >= 2:
                cps = ((buf[0] & 0x3F) << 8) | buf[1]  # 16-bit packet, 14 data bits
                del buf[:2]
            else:
                cps = buf[0] & 0xFF  # legacy Re.2.x firmware: single 8-bit CPS byte
                del buf[:1]
            got_packet = True
            rec = make_record(cps=cps, cpm_est=cps * 60, cpm_per_usv=cpm_per_usv, dev=dev)
            emit(rec, args.json)
            if args.once:
                return 0
    finally:
        try:
            dev.heartbeat(False)  # clean <HEARTBEAT0>> on Ctrl+C, SIGTERM, exit
            sys.stderr.write("[%s] heartbeat off\n" % tag(dev))
        except Exception:
            pass


# ---------------- simulated device (TUI) ----------------

class _SimDevice:
    """Virtual counter for --simulate / --pilot: same interface, no serial."""

    def __init__(self, port, timeout=1.0):
        self.port = "%s (sim)" % port
        self.timeout = timeout
        self.ser = None
        self.baud = 57600
        self.version = None
        self._cpm = 18

    def open(self, baud=None):
        self.version = "GMC-300SRe 1.05 (sim)"
        return self.version

    def get_ver(self):
        return self.version or "GMC-300SRe 1.05 (sim)"

    def get_cpm(self):
        self._cpm = max(0, self._cpm + random.randint(-3, 3))
        return self._cpm

    def get_cps(self):
        return max(0, round(self._cpm / 60) + random.randint(-1, 1))

    def get_volt(self):
        return 4.8

    def get_datetime(self):
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def set_datetime(self, when=None):
        return True

    def get_serial(self):
        return "SIM0000"

    def heartbeat(self, on):
        pass

    def read_heartbeat_packet(self):
        time.sleep(0.02)  # pace like the ~1 s stream, but pilot-friendly
        return random.randint(0, 2)

    def close(self):
        pass


# ---------------- TUI worker thread ----------------

class PollWorker(threading.Thread):
    """Owns the serial port; never touches the UI directly.

    Works with the real GQGMC (baud probe via GETVER, lock-guarded I/O) and
    with _SimDevice (open() returns the version itself).
    """

    def __init__(self, app, factory, baud, interval):
        super().__init__(daemon=True, name="gq-gmc-tui-poll")
        self.app = app
        self.factory = factory
        self.baud = baud
        self.interval = max(0.1, float(interval))
        self.dev = None
        self.mode = "cpm"  # or "hb"
        self._stop = threading.Event()
        self._pause = threading.Event()
        self._cmds: "queue.Queue[str]" = queue.Queue()
        self._err_streak = 0

    # ---- control (called from the UI thread) ----
    def stop(self):
        self._stop.set()

    def set_paused(self, paused: bool):
        (self._pause.set if paused else self._pause.clear)()

    def request_heartbeat(self, on: bool):
        self._cmds.put("hb_on" if on else "hb_off")

    # ---- helpers ----
    def _post(self, name, *args):
        try:
            self.app.call_from_thread(getattr(self.app, name), *args)
        except Exception:
            pass  # app already shutting down

    def _safe(self, fn):
        try:
            return fn()
        except Exception:
            return None

    def _drain_cmds(self):
        while True:
            try:
                cmd = self._cmds.get_nowait()
            except queue.Empty:
                return
            if cmd == "hb_on":
                try:
                    self.dev.heartbeat(True)
                except Exception as exc:
                    self._post("_on_error", "heartbeat on: %s" % exc)
                    continue
                self.mode = "hb"
                self._post("_on_hb_state", True)
            elif cmd == "hb_off":
                try:
                    self.dev.heartbeat(False)
                except Exception as exc:
                    self._post("_on_error", "heartbeat off: %s" % exc)
                    continue
                self.mode = "cpm"
                self._post("_on_hb_state", False)

    def _open_and_identify(self, dev):
        """Open the device, probing BAUD_CANDIDATES when no explicit baud was set.

        Mirrors connect(): the port is closed again after every failed attempt.
        """
        bauds = (self.baud,) if self.baud else BAUD_CANDIDATES
        last = None
        for b in bauds:
            try:
                dev.open(b)
            except (serial.SerialException, OSError, ValueError) as exc:
                last = exc
                continue
            try:
                ver = dev.get_ver()
            except (serial.SerialException, GQGMCError, OSError) as exc:
                last = exc
                ver = None
            if ver and is_gq_version(ver):
                if hasattr(dev, "identify"):     # real GQGMC
                    dev.identify(ver)
                else:                            # _SimDevice and friends
                    dev.version = ver
                return ver
            try:
                dev.close()
            except Exception:
                pass
            time.sleep(0.1)
        raise GQGMCError(
            "no GQ GMC answered GETVER on %s (baud %s); last error: %s"
            % (getattr(dev, "port", "?"),
               "/".join(str(b) for b in bauds), last))

    def _read_hb_packet(self, discard=False):
        """One HEARTBEAT1 packet: 14-bit framing, legacy 8-bit, or sim hook."""
        dev = self.dev
        fn = getattr(dev, "read_heartbeat_packet", None)
        if fn is not None:  # simulated device
            val = fn()
            return None if discard else val
        buf = bytearray()
        while not buf and not self._stop.is_set():
            chunk = dev.read_exact(1, timeout=0.25)
            if chunk:
                buf.extend(chunk)
        if not buf:
            return None
        try:
            buf.extend(dev.read_burst(16, gap=0.1))
        except Exception:
            pass
        if len(buf) >= 2:
            val = ((buf[0] & 0x3F) << 8) | buf[1]  # 16-bit packet, 14 data bits
        else:
            val = buf[0] & 0xFF  # legacy Re.2.x: single 8-bit CPS byte
        return None if discard else val

    # ---- thread body ----
    def run(self):
        try:
            dev = self.factory()
            ver = self._open_and_identify(dev)
        except Exception as exc:
            self._post("_on_device_error", str(exc))
            return
        self.dev = dev
        try:
            info = {
                "version": ver,
                "port": dev.port,
                "baud": dev.baud,
                "serial": self._safe(dev.get_serial),
                "volt": self._safe(dev.get_volt),
                "dt": self._safe(dev.get_datetime),
                "cps_capable": self._safe(dev.get_cps) is not None,
            }
        except Exception as exc:
            self._post("_on_device_error", str(exc))
            dev.close()
            return
        self._post("_on_device_ready", info)
        next_t = time.monotonic()
        last_aux = 0.0
        try:
            while not self._stop.is_set():
                self._drain_cmds()
                if self._pause.is_set():
                    if self.mode == "hb":
                        self._read_hb_packet(discard=True)  # keep stream drained
                    else:
                        self._stop.wait(0.2)
                    continue
                now = time.monotonic()
                if self.mode == "hb":
                    pkt = self._read_hb_packet()
                    if pkt is not None:
                        self._post("_on_sample", None, pkt)
                    next_t = now + 1.0
                    continue
                if now < next_t:
                    self._stop.wait(min(0.2, next_t - now))
                    continue
                try:
                    cpm = dev.get_cpm()
                    err = None
                except (GQGMCError, serial.SerialException) as exc:
                    cpm, err = None, str(exc)
                if cpm is not None:
                    self._post("_on_sample", cpm, None)
                    self._err_streak = 0
                else:
                    self._err_streak += 1
                    if self._err_streak == 3 or self._err_streak % 30 == 0:
                        self._post("_on_error", err or "GETCPM failed")
                if now - last_aux >= 60.0:  # battery + device clock refresh
                    last_aux = now
                    self._post("_on_aux", self._safe(dev.get_volt),
                               self._safe(dev.get_datetime))
                next_t += self.interval
                if next_t < time.monotonic():
                    next_t = time.monotonic()  # fell behind: don't pile up
        except Exception as exc:  # belt & braces: never kill the thread silently
            self._post("_on_error", "worker: %s" % exc)
        finally:
            try:
                if self.dev is not None:
                    try:
                        self.dev.heartbeat(False)  # HEARTBEAT0 on any exit path
                    except Exception:
                        pass
                    self.dev.close()
            except Exception:
                pass


# ---------------- Textual dashboard ----------------

ACCENT = "#7dd3fc"      # baby blue
MUTED = "#64748b"
TEXT = "#e2e8f0"
SOFT = "#94a3b8"
OK = "#4ade80"
WARN = "#fbbf24"
ERR = "#f87171"
PANEL = "#0e1420"
BORDER = "#1e2a3a"
ORANGE = "#fb923c"      # safety band: high (100-999 CPM)
BRIGHT_RED = "#ff4d4d"  # safety band: extremely high (>=2000 CPM)

# ---------------- GQ 'Nuclear Radiation Safety Guide' (vendor insert card) ----------------
# The printed insert shipped with GQ GMC units, encoded verbatim as data.
# Classified by the RAW CPM reading — never by the converted uSv/h — so the
# mapping follows the printed card even when the unit's own GETCFG calibration
# (161.5 CPM/uSv on the live GMC-300S Re 1.05) differs from the 154 CPM/uSv
# M4011 default. CPM < 5 (the unit often rests at 0) is band 0: still Normal
# background — the card's first row, not a new row.
# Tuple: (upper CPM inclusive | None, CPM label, uSv/h label, mR/h label,
#         action text, Rich color, short band name)
SAFETY_BANDS = (
    (50,   "5-50",   "0.03~0.33", "0.003~0.033",
     "Normal background. No action needed.",                              OK,         "NORMAL"),
    (99,   "51-99",  "0.34~0.64", "0.034~0.064",
     "Medium level. Check the reading regularly.",                        WARN,       "MEDIUM"),
    (999,  ">=100",  ">0.65",     ">0.065",
     "High level. Closely watch the reading, and find out why.",          ORANGE,     "HIGH"),
    (1999, ">=1000", ">6.5",      ">0.650",
     "Very high level. Leave the area ASAP, and find out why.",           ERR,        "VERY HIGH"),
    (None, ">=2000", ">13",       ">1.30",
     "Extremely high level. Evacuate immediately, report to government.", BRIGHT_RED, "EXTREME"),
)

GUIDE_DISCLAIMER = "GQ vendor insert card — guidance only, not medical or legal advice."


def safety_band(cpm):
    """Raw CPM -> (band index, band tuple) per the insert card; CPM < 5 is band 0."""
    try:
        v = float(cpm)
    except (TypeError, ValueError):
        v = 0.0
    if v != v:  # NaN: treat as no reading -> background
        v = 0.0
    for i, band in enumerate(SAFETY_BANDS):
        hi = band[0]
        if hi is None or v <= hi:
            return i, band
    return len(SAFETY_BANDS) - 1, SAFETY_BANDS[-1]


def print_guide(stream=None):
    """Print the safety band table as plain text (used by --guide; stderr only)."""
    stream = stream if stream is not None else sys.stderr
    stream.write("GQ 'Nuclear Radiation Safety Guide' — classify by CPM\n")
    stream.write("%-8s %-11s %-11s %s\n" % ("CPM", "uSv/h", "mR/h", "Action"))
    for _hi, cpm_l, usv_l, mr_l, action, _color, _name in SAFETY_BANDS:
        stream.write("%-8s %-11s %-11s %s\n" % (cpm_l, usv_l, mr_l, action))
    stream.write("(CPM < 5 is also Normal background.) %s\n" % GUIDE_DISCLAIMER)


def _tui_app_class():
    """Build and return GmcTui, importing textual/rich lazily.

    Called only from run_tui()/_pilot_smoke() — i.e. only after argparse has
    parsed --tui/--pilot/--simulate — so `--help` never imports textual.
    """
    from rich.text import Text
    from textual.app import App
    from textual.binding import Binding
    from textual.containers import Horizontal, Vertical
    from textual.widgets import Footer, Sparkline, Static

    class GmcTui(App):
        TITLE = "GQ GMC Geiger Dashboard"

        CSS = """
        Screen { background: #0b0e14; }
        #topbar { dock: top; height: 1; background: #10141c; padding: 0 1; }
        #bigrow { height: 5; }
        .big {
            width: 1fr; height: 5; margin: 0 1;
            border: round %s; background: %s;
            content-align: center middle;
        }
        #clock { height: 1; content-align: center middle; }
        #chartbox {
            height: 1fr; margin: 1 1 0 1; padding: 0 1;
            border: round %s; background: %s;
        }
        #spark { height: 1fr; }
        #chartcap { height: 1; }
        #statsrow { height: 1; background: #10141c; padding: 0 1; margin-top: 1; }
        .stat { width: auto; margin-right: 3; }
        #action {
            height: 3; margin: 1 1 0 1; padding: 0 1;
            background: #10141c; content-align: center middle;
        }
        #safety {
            height: auto; background: #10141c; padding: 0 1; margin-top: 1;
        }
        """ % (BORDER, PANEL, BORDER, PANEL)

        BINDINGS = [
            Binding("q", "quit", "Quit"),
            Binding("p", "toggle_pause", "Pause"),
            Binding("h", "toggle_heartbeat", "Heartbeat"),
            Binding("r", "reset_chart", "Reset chart"),
            Binding("g", "toggle_guide", "Guide"),
        ]

        def __init__(self, *, port, baud, interval, cpm_per_usv, timeout,
                     simulate=False, device_factory=None):
            super().__init__()
            self.dark = True
            self.port = port
            self.baud = baud
            self.interval = float(interval)
            self.cpm_per_usv = float(cpm_per_usv if cpm_per_usv is not None else DEFAULT_CPM_PER_USV)
            self.timeout = float(timeout)
            if device_factory is None:
                if simulate:
                    device_factory = lambda: _SimDevice(port, timeout=timeout)  # noqa: E731
                else:
                    device_factory = lambda: GQGMC(port, timeout=timeout)  # noqa: E731
            self._factory = device_factory
            self._worker: PollWorker | None = None
            self._samples: deque[float] = deque(maxlen=120)
            self._last_cps = None
            self._last_cpm = None   # raw CPM of the latest sample (band classifier input)
            self._band_idx = None   # index into SAFETY_BANDS for the current band
            self._hb_on = False
            self._paused = False
            self._model = None
            self._volt = None
            self._dev_dt = None
            self._dev_ready = False
            self._exit_code = 0
            self._t0 = time.monotonic()
            self._w = {}  # cached widget refs, mounted once

        # ---- layout: mounted exactly once; updated in place afterwards ----
        def compose(self):
            yield Static(Text("GMC · connecting…", style=WARN), id="topbar")
            with Horizontal(id="bigrow"):
                yield Static("", id="big-cpm", classes="big")
                yield Static("", id="big-usv", classes="big")
                yield Static("", id="big-mrh", classes="big")
            yield Static("", id="action")
            yield Static("", id="clock")
            with Vertical(id="chartbox"):
                yield Sparkline(id="spark", min_color="#16324a", max_color=ACCENT)
                yield Static("", id="chartcap")
            with Horizontal(id="statsrow"):
                yield Static("", id="st-min", classes="stat")
                yield Static("", id="st-max", classes="stat")
                yield Static("", id="st-avg", classes="stat")
                yield Static("", id="st-elapsed", classes="stat")
                yield Static("", id="st-cps", classes="stat")
                yield Static("", id="st-status", classes="stat")
            yield Static("", id="safety")
            yield Footer()

        def on_mount(self):
            self._w = {wid: self.query_one("#" + wid) for wid in (
                "topbar", "big-cpm", "big-usv", "big-mrh", "action", "clock",
                "spark", "chartcap", "st-min", "st-max", "st-avg", "st-elapsed",
                "st-cps", "st-status", "safety")}
            self._update_action()
            self._update_safety()
            self._tick_clock()
            self.set_interval(1.0, self._tick_clock)
            self._worker = PollWorker(self, self._factory, self.baud, self.interval)
            self._worker.start()

        # ---- worker callbacks (run on the UI thread via call_from_thread) ----
        def _on_device_ready(self, info):
            self._model = info.get("version")
            self._volt = info.get("volt")
            self._dev_dt = info.get("dt")
            self._dev_ready = True
            self._update_topbar()
            self._update_chartcap()
            self._update_status()

        def _on_device_error(self, msg):
            self._w["st-status"].update(Text("device error", style=ERR))
            self._w["topbar"].update(Text("GMC · %s" % msg, style=ERR))
            self._w["action"].update(Text("no guidance — device error", style=MUTED))
            self._exit_code = 1
            self.set_timer(2.0, lambda: self.exit(return_code=self._exit_code))

        def _on_sample(self, cpm, cps):
            if cps is not None:
                self._last_cps = cps
                cpm = cps * 60  # 1-second estimate, same basis as the poller
            if cpm is None:
                return
            self._samples.append(float(cpm))
            spark = self._w["spark"]
            spark.data = list(self._samples)
            tilde = "~" if self._hb_on else ""
            usv = cpm / self.cpm_per_usv
            self._update_big(self._w["big-cpm"],
                             "CPM (1s est)" if self._hb_on else "counts / minute",
                             "%s%s" % (tilde, format(int(round(cpm)), ",")), ACCENT)
            self._update_big(self._w["big-usv"], "uSv / h", "%.3f" % usv, TEXT)
            self._update_big(self._w["big-mrh"], "mR / h", "%.3f" % (usv * MR_PER_USV), TEXT)
            # safety band: classified by the raw CPM shown, never by converted uSv/h
            self._last_cpm = float(cpm)
            idx, band = safety_band(cpm)
            self._band_idx = idx
            self._update_action(idx, band)
            self._update_safety(idx)
            if self._samples:
                lo = min(self._samples)
                hi = max(self._samples)
                avg = sum(self._samples) / len(self._samples)
                self._w["st-min"].update(Text("min ", MUTED) + Text(format(int(round(lo)), ","), TEXT))
                self._w["st-max"].update(Text("max ", MUTED) + Text(format(int(round(hi)), ","), TEXT))
                self._w["st-avg"].update(Text("avg ", MUTED) + Text("%.1f" % avg, TEXT))
            self._update_chartcap()
            self._update_cps()

        def _on_aux(self, volt, dt):
            if volt is not None:
                self._volt = volt
            if dt is not None:
                self._dev_dt = dt
            self._update_topbar()

        def _on_hb_state(self, on):
            self._hb_on = bool(on)
            self._update_status()
            self._update_cps()

        def _on_error(self, msg):
            self._w["st-status"].update(Text("error: %s" % msg, style=ERR))

        # ---- render helpers ----
        def _update_big(self, widget, label, value, color):
            t = Text()
            t.append(label + "\n", MUTED)
            t.append(value, "bold " + color)
            widget.update(t)

        def _update_action(self, idx=None, band=None):
            """Big status line: the insert-card action for the current band."""
            if idx is None or band is None:
                if self._last_cpm is None:
                    self._w["action"].update(
                        Text("safety · waiting for first reading…", MUTED))
                    return
                idx, band = safety_band(self._last_cpm)
            self._w["action"].update(Text(
                "%s — %s" % (band[6], band[4]), "bold " + band[5]))

        def _update_safety(self, idx=None):
            """Full GQ guide table with the current band row highlighted."""
            if idx is None:
                idx = self._band_idx if self._band_idx is not None else -1
            t = Text()
            t.append("SAFETY GUIDE · GQ insert card · classify by CPM\n", "bold " + ACCENT)
            t.append("  %-6s %-9s %-11s %s\n" % ("CPM", "uSv/h", "mR/h", "action"), MUTED)
            for i, (_hi, cpm_l, usv_l, mr_l, action, color, _name) in enumerate(SAFETY_BANDS):
                style = ("bold " + color) if i == idx else color
                t.append("%s %-6s %-9s %-11s %s\n"
                         % (">" if i == idx else " ", cpm_l, usv_l, mr_l, action), style)
            t.append(GUIDE_DISCLAIMER, MUTED)
            self._w["safety"].update(t)

        def _update_topbar(self):
            t = Text()
            t.append("GMC ", "bold " + ACCENT)
            t.append(self._model or "?", "bold " + TEXT)
            t.append("  ·  %s @ %s bd" % (self.port, self.baud if self.baud else "auto"), SOFT)
            if self._volt is not None:
                t.append("  ·  bat %.1f V" % self._volt, OK)
            self._w["topbar"].update(t)

        def _update_chartcap(self):
            t = Text()
            t.append("CPM  last %d/120 samples" % len(self._samples), MUTED)
            t.append("  ·  %g CPM = 1 uSv/h  ·  1 uSv/h = %g mR/h"
                     % (self.cpm_per_usv, MR_PER_USV), SOFT)
            self._w["chartcap"].update(t)

        def _update_cps(self):
            if self._hb_on:
                val = "—" if self._last_cps is None else str(self._last_cps)
                self._w["st-cps"].update(Text("CPS ", MUTED) + Text(val, "bold " + ACCENT))
            else:
                val = str(self._last_cps) if self._last_cps is not None else "—"
                self._w["st-cps"].update(Text("CPS ", MUTED) + Text(val, SOFT))

        def _update_status(self):
            if self._paused:
                self._w["st-status"].update(Text("PAUSED", "bold " + WARN))
            elif self._hb_on:
                self._w["st-status"].update(Text("heartbeat", "bold " + ACCENT))
            else:
                self._w["st-status"].update(Text("polling", OK))

        def _tick_clock(self):
            local = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %Z")
            utc = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%SZ")
            t = Text()
            t.append("local ", MUTED)
            t.append(local, TEXT)
            t.append("  ·  UTC ", MUTED)
            t.append(utc, TEXT)
            t.append("  ·  device ", MUTED)
            t.append(self._dev_dt or "n/a", SOFT)
            self._w["clock"].update(t)
            elapsed = int(time.monotonic() - self._t0)
            h, rem = divmod(elapsed, 3600)
            m, s = divmod(rem, 60)
            self._w["st-elapsed"].update(
                Text("elapsed ", MUTED) + Text("%02d:%02d:%02d" % (h, m, s), TEXT))

        # ---- actions ----
        def action_toggle_pause(self):
            self._paused = not self._paused
            if self._worker is not None and self._worker.is_alive():
                self._worker.set_paused(self._paused)
            self._update_status()

        def action_toggle_heartbeat(self):
            if self._worker is None or not self._worker.is_alive():
                return
            self._worker.request_heartbeat(not self._hb_on)

        def action_reset_chart(self):
            self._samples.clear()
            self._w["spark"].data = None
            self._w["st-min"].update(Text("min ", MUTED) + Text("—", SOFT))
            self._w["st-max"].update(Text("max ", MUTED) + Text("—", SOFT))
            self._w["st-avg"].update(Text("avg ", MUTED) + Text("—", SOFT))
            self._update_chartcap()

        def action_toggle_guide(self):
            """Hide/show the safety guide table (default: shown). Updates in place."""
            self._w["safety"].display = not self._w["safety"].display

        def _shutdown_worker(self):
            w = self._worker
            if w is None:
                return
            self._worker = None
            w.stop()
            if w.is_alive() and threading.current_thread() is not w:
                w.join(timeout=3.0)  # worker sends HEARTBEAT0 + closes serial

        def action_quit(self):
            self._shutdown_worker()
            self.exit(return_code=self._exit_code)

        def on_unmount(self):
            self._shutdown_worker()

    return GmcTui


def run_tui(*, port, baud, interval, cpm_per_usv, timeout, simulate=False) -> int:
    """Open the dashboard.  Returns the process exit code (0 normal, 1 if the
    device could not be opened).  Call _ensure_tui_stack() first when invoked
    programmatically (the CLI entry points do it)."""
    GmcTui = _tui_app_class()
    app = GmcTui(port=port, baud=baud, interval=interval,
                 cpm_per_usv=cpm_per_usv, timeout=timeout, simulate=simulate)
    app.run()
    return int(app.return_code or 0)


async def _pilot_smoke(args) -> int:
    """Headless smoke: 100x40 pilot, pause/heartbeat/reset, then quit."""
    GmcTui = _tui_app_class()
    app = GmcTui(port=args.port, baud=args.baud or 57600,
                 interval=0.15, cpm_per_usv=args.cpm_per_usv,
                 timeout=args.timeout, simulate=True)
    async with app.run_test(size=(100, 40)) as pilot:
        await pilot.pause()
        await pilot.press("p")   # pause
        await pilot.pause()
        await pilot.press("p")   # resume
        await pilot.pause()
        await pilot.press("h")   # heartbeat on (simulated)
        await pilot.pause()
        await pilot.pause()
        await pilot.press("r")   # reset chart
        await pilot.pause()
        await pilot.press("g")   # hide the safety guide table
        await pilot.pause()
        await pilot.press("g")   # show it again (default is SHOW)
        await pilot.pause()
        widget_ids = ("topbar", "big-cpm", "big-usv", "big-mrh", "action", "clock",
                      "spark", "chartcap", "st-min", "st-max", "st-avg",
                      "st-elapsed", "st-cps", "st-status", "safety")
        missing = []
        for wid in widget_ids:
            try:
                app.query_one("#" + wid)
            except Exception:
                missing.append(wid)
        n_samples = len(app._samples)
        band_idx = app._band_idx
        rc_before_quit = app._exit_code
        await pilot.press("q")
    band_txt = "none" if band_idx is None else "%d %s" % (band_idx, SAFETY_BANDS[band_idx][6])
    print("PILOT widgets %d/%d present; samples=%d; hb=%s; band=%s; "
          "exit_code=%s; return_code=%s"
          % (len(widget_ids) - len(missing), len(widget_ids), n_samples,
             app._hb_on, band_txt, rc_before_quit, app.return_code))
    if missing:
        print("PILOT missing widgets: %s" % missing)
    return 0 if (not missing and n_samples > 0 and app.return_code == 0) else 1


# ---------------- CLI ----------------

def build_parser():
    ap = argparse.ArgumentParser(
        prog=PROG,
        description="Poll GQ GMC Geiger counters (GMC-300/300S/300E+/320/320+/320S/"
                    "500/500+/600/600+/800/SE) over USB serial — GQ-RFC1201/RFC1801, "
                    "with an optional in-file Textual dashboard.",
        epilog="examples:\n"
               "  gq-gmc.py --once                       one reading, auto-detected unit\n"
               "  gq-gmc.py --set-time                   copy host local clock onto the unit\n"
               "  gq-gmc.py --interval 5 --json          NDJSON stream (one object/line) for wrappers\n"
               "  gq-gmc.py --once --json | jq .         one stable JSON record, pretty-printed\n"
               "  gq-gmc.py --heartbeat                  1-per-second CPS stream\n"
               "  gq-gmc.py --list-ports                 candidate ports + USB IDs\n"
               "  gq-gmc.py --port /dev/ttyUSB1 --baud 115200\n"
               "  gq-gmc.py --cpm-per-usv 154 --once     explicit tube calibration\n"
               "  gq-gmc.py --guide                      print the GQ safety band table\n"
               "  gq-gmc.py --tui                        live Textual dashboard (in-file)\n"
               "  gq-gmc.py --tui --simulate             dashboard on a virtual counter\n"
               "  gq-gmc.py --pilot                      headless TUI smoke test (no serial)\n",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("--port", default="auto", metavar="DEV",
                    help="serial device (default: auto-detect; scans /dev/serial/by-id, "
                         "/dev/ttyUSB*, /dev/ttyACM*)")
    ap.add_argument("--baud", type=int, default=None, metavar="N",
                    help="force baud rate (default: auto-probe 57600, then 115200)")
    ap.add_argument("--interval", type=float, default=DEFAULT_INTERVAL, metavar="SEC",
                    help="poll interval seconds (default: %(default)s)")
    ap.add_argument("--once", action="store_true", help="take one reading and exit")
    ap.add_argument("--json", action="store_true", dest="json",
                    help="emit NDJSON on stdout: one JSON object per line, fixed schema "
                         "(ts_local, ts_utc, cpm, cps, cpm_est, usv_h, mr_h, cpm_per_usv, "
                         "safety_band 0-4, safety_name, safety_action, model, firmware, "
                         "port, baud; null when N/A) — banner/status stay on stderr; "
                         "wrap it: gq-gmc.py --once --json | jq .")
    ap.add_argument("--heartbeat", action="store_true",
                    help="use the <HEARTBEAT1>> CPS stream instead of GETCPM polling")
    ap.add_argument("--cpm-per-usv", type=float, default=None, dest="cpm_per_usv", metavar="N",
                    help="calibration override: CPM equal to 1 uSv/h (default: GETCFG "
                         "calibration if readable, else 154 for the M4011 tube)")
    ap.add_argument("--guide", action="store_true",
                    help="print the GQ 'Nuclear Radiation Safety Guide' band table to "
                         "stderr, then run (alone: print and exit, no device touched)")
    ap.add_argument("--tui", action="store_true",
                    help="launch the in-file Textual TUI dashboard "
                         "(installs textual+rich on first use)")
    ap.add_argument("--simulate", action="store_true",
                    help="TUI on a virtual counter, no serial hardware (implies --tui)")
    ap.add_argument("--pilot", action="store_true",
                    help="headless Textual pilot smoke test, no serial hardware (implies --tui)")
    ap.add_argument("--timeout", type=float, default=DEFAULT_TIMEOUT, metavar="SEC",
                    help="serial timeout seconds (default: %(default)s)")
    ap.add_argument("--list-ports", action="store_true", dest="list_ports",
                    help="list candidate serial ports with USB IDs, then exit")
    ap.add_argument("--set-time", action="store_true", dest="set_time",
                    help="set the unit RTC to this host's local date/time, then exit")
    return ap


def cmd_list_ports():
    cands = list_candidate_ports()
    if not cands:
        sys.stderr.write("%s: no serial ports found (/dev/serial/by-id, /dev/ttyUSB*, /dev/ttyACM*)\n" % PROG)
        return 1
    print("candidate serial ports (autodetect probes <GETVER>> at 57600, then 115200, in this order):")
    for node, vid, pid, score, alias in cands:
        usbid = ("%s:%s" % (vid, pid)) if vid else "-"
        extra = "  [by-id: %s]" % alias if alias else ""
        print("  %-24s %-9s %-18s score=%d%s" % (node, usbid, _bridge_name(vid, pid), score, extra))
    return 0


def _ensure_tui_stack():
    """Ensure serial + textual + rich for --tui/--pilot (never reached on --help).

    Order: plain import -> ~/.venv-gmc site-packages fallback (pure-Python deps,
    same interpreter minor version) -> ensure_pkg (pip -> apt -> execv re-exec).
    """
    ensure_serial()
    try:
        import rich  # noqa: F401
        import textual  # noqa: F401
        return
    except ImportError:
        pass
    site = os.path.join(os.path.expanduser("~"), ".venv-gmc", "lib",
                        "python%d.%d" % sys.version_info[:2], "site-packages")
    if os.path.isdir(site) and site not in sys.path:
        sys.path.append(site)
    try:
        import rich  # noqa: F401
        import textual  # noqa: F401
        return
    except ImportError:
        pass
    ensure_pkg("textual", pip_name="textual", apt_name=None,
               hint="python3 -m pip install textual rich   (no apt package for textual)")
    ensure_pkg("rich", pip_name="rich", apt_name="python3-rich",
               hint="python3 -m pip install rich   (or: sudo apt install python3-rich)")


def run_tui_entry(args):
    """Ensure TUI deps lazily, then launch the in-file Textual dashboard.

    Autodetects the port (and baud) before the TUI when --port is auto, so the
    dashboard opens straight onto the answered device. --simulate/--pilot
    never touch serial hardware.
    """
    _ensure_tui_stack()
    if args.pilot:
        return asyncio.run(_pilot_smoke(args)) or 0

    if args.simulate:
        port = args.port            # label only — no hardware is touched
        baud = args.baud
    else:
        port = args.port if args.port and args.port not in ("auto", "") else None
        baud = args.baud
        if port is None:
            ports = [c[0] for c in list_candidate_ports()]
            if not ports:
                sys.stderr.write("%s: no serial ports found for --tui\n" % PROG)
                return 1
            for p in ports:
                try:
                    dev = connect(p, args.baud, args.timeout)
                except Exception as exc:
                    sys.stderr.write("[%s] %s: %s\n" % (PROG, p, exc))
                    continue
                if dev is not None:
                    port, baud = dev.port, dev.baud
                    dev.close()     # the TUI worker reopens it
                    break
            if port is None:
                sys.stderr.write("%s: no GQ GMC answered GETVER (try --list-ports)\n" % PROG)
                return 1
    cpm = args.cpm_per_usv if args.cpm_per_usv is not None else DEFAULT_CPM_PER_USV
    try:
        return run_tui(port=port, baud=baud, interval=args.interval,
                       cpm_per_usv=cpm, timeout=args.timeout,
                       simulate=args.simulate) or 0
    except KeyboardInterrupt:
        return 0


def _on_sigterm(signum, _frame):
    raise KeyboardInterrupt  # reuse the clean Ctrl+C path


def main(argv=None):
    args = build_parser().parse_args(argv)   # --help/-h exits HERE: no installs, no serial import
    if args.list_ports:
        return cmd_list_ports()
    if args.interval <= 0:
        sys.stderr.write("%s: --interval must be > 0\n" % PROG)
        return 2
    if args.timeout <= 0:
        sys.stderr.write("%s: --timeout must be > 0\n" % PROG)
        return 2
    if args.cpm_per_usv is not None and args.cpm_per_usv <= 0:
        sys.stderr.write("%s: --cpm-per-usv must be > 0\n" % PROG)
        return 2
    if args.guide:
        print_guide(sys.stderr)
        if not (args.tui or args.simulate or args.pilot or args.once
                or args.heartbeat or args.set_time):
            return 0  # --guide alone: just the card, no serial device is touched
    if args.tui or args.simulate or args.pilot:
        return run_tui_entry(args)

    ensure_serial()  # lazy pyserial (pip -> apt python3-serial -> execv)

    import signal
    try:
        signal.signal(signal.SIGTERM, _on_sigterm)
    except (ValueError, OSError):
        pass

    if args.port and args.port not in ("auto", ""):
        ports = [args.port]
    else:
        ports = [c[0] for c in list_candidate_ports()]
        if not ports:
            sys.stderr.write("%s: no serial ports found (/dev/serial/by-id, /dev/ttyUSB*, "
                             "/dev/ttyACM*); check the USB link\n" % PROG)
            return 1

    dev = None
    for p in ports:
        _dbg("probing %s (baud %s)" % (p, args.baud or "auto"))
        try:
            dev = connect(p, args.baud, args.timeout)
        except Exception as exc:  # defensive: never die mid-autodetect
            sys.stderr.write("[%s] %s: %s\n" % (PROG, p, exc))
            continue
        if dev is not None:
            break
    if dev is None:
        sys.stderr.write(
            "%s: no GQ GMC answered <GETVER>> on %s (baud %s).\n"
            "  hints: check USB cable and unit power; ensure the user is in the 'dialout' "
            "group; run --list-ports; set GQGMC_DEBUG=1 for probe details.\n"
            % (PROG, ", ".join(ports), args.baud or "57600/115200"))
        return 1

    cfg = _safe(dev.get_config)
    dev.calibration, dev.cal_points = parse_cfg_calibration(cfg)
    cpm_per_usv, cal_src = resolve_cpm_per_usv(args, dev)
    banner(dev, args, cpm_per_usv, cal_src)
    rc = 0
    try:
        if args.set_time:
            host = datetime.now()
            before = _safe(dev.get_datetime)
            ok = dev.set_datetime(host)
            after = _safe(dev.get_datetime)
            out = sys.stderr if args.json else sys.stdout  # keep stdout pure NDJSON
            print("host local : %s" % host.strftime("%Y-%m-%d %H:%M:%S"), file=out, flush=True)
            print("device was : %s" % (before or "n/a"), file=out, flush=True)
            print("device now : %s" % (after or "n/a"), file=out, flush=True)
            if not ok:
                sys.stderr.write("%s: SETDATETIME not ACKed (firmware may be older than Re.3.00 / Re.2.23)\n" % PROG)
                rc = 1
            elif after is None:
                sys.stderr.write("%s: wrote clock but GETDATETIME did not parse\n" % PROG)
                rc = 1
            else:
                rc = 0
        else:
            rc = run_heartbeat(dev, args, cpm_per_usv) if args.heartbeat else run_poll(dev, args, cpm_per_usv)
    except KeyboardInterrupt:
        rc = 0
    finally:
        dev.close()  # never hold the port after exit
    return rc


if __name__ == "__main__":
    sys.exit(main())