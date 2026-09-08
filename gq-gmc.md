# gq-gmc — GQ GMC Geiger counters over USB

`gq-gmc` reads GQ GMC-series Geiger counters over USB serial and talks the GQ
protocols directly — **GQ-RFC1201** (GMC-300/300S/300E+/320/320+/320S, 2-byte
CPM) and **GQ-RFC1801** (GMC-500/500+/600/600+/800, 4-byte CPM, probed safely
so 2-byte firmware still works). No vendor software, no pygmc — it is never
imported or installed.

One file does everything: serial core, CLI, and the Textual dashboard. It
lives in `~/bin` as `gq-gmc.py` — the `gq-gmc.py` in this repository is the
canonical source. Examples below use `gq-gmc`.

```
gq-gmc --list-ports        # candidate ports + USB IDs, no device opened
gq-gmc --once              # one reading from an auto-detected unit
gq-gmc                     # poll CPM every second (Ctrl+C to stop)
gq-gmc --tui               # full-screen dashboard
```

## Permissions and ports

Serial ports need read/write access. Add yourself to the `dialout` group and
log back in:

```
sudo usermod -aG dialout $USER
```

A typical GQ unit shows up as a CH340 USB-serial bridge on `/dev/ttyUSB0`
(USB ID `1a86:7523`). Run `gq-gmc --list-ports` to see candidates with their
USB IDs before probing.

## How it connects

With the default `--port auto`, the tool scans `/dev/serial/by-id`,
`/dev/ttyUSB*` and `/dev/ttyACM*`, ranks USB bridges the GQ units use
(CH340 > CH341 > CP210x > FTDI > PL2303), then probes `<GETVER>>` on each
candidate at **57600** and then **115200**. The port is closed again after
every failed probe — nothing is held unless a device answers.

Baud by firmware: 57600 for V3.xx and earlier, 115200 for V4.xx/Plus and
later; the GMC-320 is variable (factory 115200). Skip the probe with
`--port /dev/ttyUSB0 --baud 57600`.

## Polling

| Flag | Behavior |
|------|----------|
| *(default)* | `GETCPM` poll every `--interval` seconds (default 1.0), one human-readable line per reading |
| `--once` | one reading, then exit |
| `--interval SEC` | poll period (default 1.0, must be > 0) |
| `--heartbeat` | the device's 1-per-second `<HEARTBEAT1>>` CPS stream instead of polling; if the firmware doesn't support it, falls back to `GETCPS`/`GETCPM` polling |
| `--timeout SEC` | serial timeout (default 1.0) |

## JSON for wrappers

`--json` emits **NDJSON on stdout** — exactly one JSON object per line,
flushed immediately, so wrapping scripts can pipe line by line. The banner,
status messages, and the `--guide` table all go to **stderr**, keeping stdout
pure JSON:

```
gq-gmc --once --json | jq .
gq-gmc --interval 5 --json | while read -r line; do ...; done
```

Every record carries all 15 keys; a key is `null` when not applicable (e.g.
`cps` is null on the poll stream, `cpm` is null on the heartbeat stream):

| Key | Meaning |
|-----|---------|
| `ts_local` / `ts_utc` | host local ISO timestamp / UTC timestamp |
| `cpm` | raw CPM from the `GETCPM` poll |
| `cps` | counts-per-second packet (heartbeat stream) |
| `cpm_est` | 1-second CPM estimate = `cps * 60` (heartbeat stream) |
| `usv_h` / `mr_h` | dose converted from `cpm` (or `cpm_est`) |
| `cpm_per_usv` | tube calibration actually used for the conversion |
| `safety_band` | 0–4 index into the GQ safety guide |
| `safety_name` / `safety_action` | band name and action text from the guide card |
| `model` / `firmware` | device identity, e.g. `GMC-300S` / `Re 1.05` |
| `port` / `baud` | port and baud rate of this stream |

Real record from a GMC-300S Re 1.05:

```json
{"ts_local": "2026-09-08T10:24:32-04:00", "ts_utc": "2026-09-08T14:24:32Z", "cpm": 0, "cps": null, "cpm_est": null, "usv_h": 0.0, "mr_h": 0.0, "cpm_per_usv": 161.5385, "safety_band": 0, "safety_name": "NORMAL", "safety_action": "Normal background. No action needed.", "model": "GMC-300S", "firmware": "Re 1.05", "port": "/dev/ttyUSB0", "baud": 57600}
```

Exit codes: `0` ok, `1` no device found / clock not ACKed / `--once` got no
reading, `2` invalid option values (e.g. `--interval 0`).

## Set the device clock

```
gq-gmc --set-time
```

Copies the **host local** date/time onto the unit RTC (year must be >= 2000),
prints before/after readings, and exits. Firmware older than the combined
`SETDATETIME` support gets per-field date+time writes instead. The unit RTC
drifts while unpowered — rerun `--set-time` if stored readings look
time-shifted.

## Dashboard (`--tui`)

A Textual dashboard living in the same file: big CPM / uSv/h / mR/h
readouts, a sparkline of the last ~120 samples, min/max/avg, host/UTC/device
clocks, battery voltage, and a status line showing the current band's action
from the safety card.

| Key | Action |
|-----|--------|
| `q` | quit |
| `p` | pause / resume polling |
| `h` | heartbeat on/off (1 s CPS stream) |
| `r` | reset chart and stats |
| `g` | show/hide the safety-guide table (shown by default) |

- `--tui --simulate` — dashboard on a virtual counter, no serial hardware.
- `--pilot` — headless smoke test (no serial hardware); prints one `PILOT ...`
  line and exits.

## Dose conversion

`1 uSv/h == 0.1 mR/h` (exact). CPM to uSv/h uses, in order of priority:

1. `--cpm-per-usv N` — explicit override (N CPM == 1 uSv/h)
2. the unit's own `GETCFG` calibration, when readable
3. the 154 CPM = 1 uSv/h default (M4011 tube)

Safety bands are always classified by **raw CPM**, never by the converted
uSv/h, so the mapping follows the printed card even when the unit's own
calibration differs from the default.

## Safety guide (`--guide`)

Prints the GQ "Nuclear Radiation Safety Guide" insert card to stderr, then
runs (combined with other flags). Alone, it prints the table and exits
without touching a device.

| CPM | uSv/h | mR/h | Action |
|-----|-------|------|--------|
| 5–50 (and < 5) | 0.03~0.33 | 0.003~0.033 | Normal background. No action needed. |
| 51–99 | 0.34~0.64 | 0.034~0.064 | Medium level. Check the reading regularly. |
| >=100 | >0.65 | >0.065 | High level. Closely watch the reading, and find out why. |
| >=1000 | >6.5 | >0.650 | Very high level. Leave the area ASAP, and find out why. |
| >=2000 | >13 | >1.30 | Extremely high level. Evacuate immediately, report to government. |

## Dependencies

Nothing is installed until it is actually needed, and `--help` never triggers
an install:

- **pyserial** — ensured before any serial I/O (pip, then apt
  `python3-serial`, then the process re-execs).
- **textual + rich** — only pulled in for `--tui`/`--pilot`/`--simulate`
  (pip, with a `~/.venv-gmc` site-packages fallback if present).

Programmatic use: the filename is hyphenated, so load it as a module with
`importlib.util.spec_from_file_location("gqgmc", "~/bin/gq-gmc.py")`, then
use `gqgmc.GQGMC` (all device I/O is lock-guarded).

## Troubleshooting

- **No device found** — check the USB cable and unit power, run
  `--list-ports`, and confirm you are in the `dialout` group.
- **Probes misbehaving** — `GQGMC_DEBUG=1 gq-gmc --once` prints each
  open/probe attempt.
- **A reading of 0 CPM is normal background**, not a fault — the unit often
  rests at 0.
- stderr status lines are prefixed `[gq-gmc]`; stdout stays clean for
  piping (fully clean with `--json`).

## Disclaimer

The safety-band table is the vendor's GQ insert card, reproduced as data.
It is guidance only — **not medical or legal advice**. Use proper survey
instruments and qualified judgment for any real radiological assessment.