#!/usr/bin/env python3
"""yt-transcript.py - download a video transcript as JSON (any site yt-dlp supports).

With --channel the argument is a channel/playlist URL: it is enumerated with
the yt-dlp binary and every video is handled in order - fetch its transcript,
and optionally push it to OpenViking (videos already stored there are skipped
unless --force is given). See enumerate_channel_videos() and run_channel_mode().

Import is stdlib-only: yt-dlp and rich are never imported (or installed) at
module load. --help never installs or re-execs. Each dependency self-bootstraps
(pip -> apt, then re-exec) the first time a run actually needs it. rich is
loaded only for a TTY status bar.
"""

import argparse
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone

PROG = 'yt-transcript'

OPENVIKING_BASE_URL_DEFAULT = 'http://127.0.0.1:1933'


def resolve_cookies_path(explicit=None):
    candidates = []
    if explicit:
        candidates.append(explicit)
    env = os.environ.get('TRANSCRIPT_COOKIES')
    if env:
        candidates.append(env)
    candidates.append(os.path.join(os.path.expanduser('~'), '.config', 'yt-dlp', 'transcript.cookies.txt'))
    for path in candidates:
        if path and os.path.isfile(path):
            return path
    return None


def _find_spec(module):
    try:
        return importlib.util.find_spec(module)
    except (ImportError, ValueError):
        return None


def _die(msg, hint):
    sys.stderr.write("%s: %s\n  fix: %s\n" % (PROG, msg, hint))
    sys.exit(2)


def _pip_install(pkg):
    '''Try plain pip, then --break-system-packages (PEP 668). Returns (ok, log).'''
    log = []
    for extra in ([], ["--break-system-packages"]):
        try:
            r = subprocess.run([sys.executable, "-m", "pip", "install"] + extra + [pkg],
                capture_output=True, text=True, timeout=300, stdin=subprocess.DEVNULL)
        except (OSError, subprocess.SubprocessError) as exc:
            log.append("pip %s: %s" % (" ".join(extra) or "plain", exc)); continue
        if r.returncode == 0:
            return True, "pip install %s: ok" % pkg
        tail = (r.stderr or r.stdout or "").strip().splitlines()
        log.append("pip %s: %s" % (" ".join(extra) or "plain", tail[-1] if tail else "exit %d" % r.returncode))
    return False, "; ".join(log)


def _apt_install(pkgs):
    cmd0 = ["apt-get"] if (hasattr(os, "geteuid") and os.geteuid() == 0) else ["sudo", "-n", "apt-get"]
    try:
        r = subprocess.run(cmd0 + ["install", "-y"] + pkgs, capture_output=True, text=True, timeout=600, stdin=subprocess.DEVNULL)
    except (OSError, subprocess.SubprocessError):
        return False
    return r.returncode == 0


def ensure_pkg(module, pip_name=None, apt_name=None, hint=None):
    '''Ensure `module` is importable; install (pip -> apt) and re-exec if needed.'''
    if _find_spec(module):
        return
    pip_name = pip_name or module
    apt_name = apt_name or ("python3-" + module)
    hint = hint or ("sudo apt install %s   (or: python3 -m pip install %s)" % (apt_name, pip_name))
    if os.environ.get("TRANSCRIPT_BOOTSTRAP") == "1":
        _die("dependency '%s' still not importable after install attempt (interpreter: %s)" % (module, sys.executable), hint)
    log = []
    ok, msg = _pip_install(pip_name); log.append(msg)
    if not ok and apt_name and os.path.exists("/usr/bin/apt-get"):
        ok = _apt_install([apt_name]); log.append("apt install %s: %s" % (apt_name, "ok" if ok else "failed"))
    if not _find_spec(module):
        _die("dependency '%s' is missing and could not be installed (%s)" % (module, "; ".join(log)), hint)
    os.environ["TRANSCRIPT_BOOTSTRAP"] = "1"
    os.execve(sys.executable, [sys.executable] + sys.argv, os.environ)


def ensure_rich():
    """Lazy-load rich. Called only when a TTY status bar is about to draw.
    --help and non-TTY runs never reach this, so they never install or import it.
    """
    ensure_pkg('rich', pip_name='rich', apt_name='python3-rich',
               hint='python3 -m pip install rich')
    import rich
    return rich


def ensure_yt_dlp():
    ensure_pkg('yt_dlp', pip_name='yt-dlp', apt_name='python3-yt-dlp', hint='-m pip install yt-dlp')
    import yt_dlp
    globals()['yt_dlp'] = yt_dlp
    return yt_dlp


def load_yt_dlp():
    try:
        import yt_dlp
        return yt_dlp
    except ImportError:
        return None


def find_yt_dlp_binary():
    path = shutil.which('yt-dlp')
    if path is None:
        venv_path = os.path.join(os.path.dirname(sys.executable), 'yt-dlp')
        if os.path.exists(venv_path) and os.access(venv_path, os.X_OK):
            path = venv_path
    if path is None:
        # an activated venv can hold yt-dlp even when this interpreter is not
        # the venv python (the '#!/usr/bin/env python3' shebang case)
        env_dir = os.environ.get('VIRTUAL_ENV')
        if env_dir:
            cand = os.path.join(env_dir, 'bin', 'yt-dlp')
            if os.path.exists(cand) and os.access(cand, os.X_OK):
                path = cand
    if path is None:
        # last resort: full self-bootstrapped venvs live as ~/.local/venv*;
        # use the newest one that ships an executable yt-dlp
        local_dir = os.path.expanduser('~/.local')
        try:
            names = os.listdir(local_dir)
        except OSError:
            names = []
        venvs = []
        for name in names:
            if not name.startswith('venv'):
                continue
            vdir = os.path.join(local_dir, name)
            if not os.path.isdir(vdir):
                continue
            try:
                stamp = os.path.getmtime(vdir)
            except OSError:
                stamp = 0
            venvs.append((stamp, vdir))
        for _stamp, vdir in sorted(venvs, reverse=True):
            cand = os.path.join(vdir, 'bin', 'yt-dlp')
            if os.path.exists(cand) and os.access(cand, os.X_OK):
                path = cand
                break
    return path


def _apply_js_solver(opts):
    """Enable the JS runtime + remote EJS challenge solver yt-dlp needs for
    YouTube signature/n challenges. Safe no-op on older yt-dlp builds."""
    opts['js_runtimes'] = {'node': {}}
    opts['remote_components'] = ['ejs:github']


def fetch_info(url, yt_dlp_module, cookies_path=None):
    if yt_dlp_module is not None:
        opts = {'skip_download': True, 'quiet': True, 'no_warnings': True}
        if cookies_path:
            opts['cookiefile'] = cookies_path
        # YouTube now requires a JS runtime + remote EJS solver for signature/n
        # challenges. Without these, format extraction returns nothing.
        _apply_js_solver(opts)
        with yt_dlp_module.YoutubeDL(opts) as ydl:
            return ydl.extract_info(url, download=False)
    binary = find_yt_dlp_binary()
    if binary is None:
        raise RuntimeError('yt-dlp binary not found on PATH')
    cmd = [binary, '--skip-download', '--no-warnings', '--dump-single-json',
           '--js-runtimes', 'node', '--remote-components', 'ejs:github']
    if cookies_path:
        cmd += ['--cookies', cookies_path]
    cmd.append(url)
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    if r.returncode != 0:
        raise RuntimeError('yt-dlp exited %d: %s' % (r.returncode, (r.stderr or '').strip()))
    return json.loads(r.stdout)


def pick_track(info, langs, want_auto=True):
    manual = info.get('subtitles') or {}
    auto = info.get('automatic_captions') or {}
    seen = set()
    for lang in langs:
        lang = lang.lower()
        for code in manual:
            low = code.lower()
            if low == lang or low.startswith(lang + '-'):
                if (code, 'manual') not in seen:
                    seen.add((code, 'manual'))
                    yield code, manual[code], 'manual'
    if want_auto:
        for lang in langs:
            lang = lang.lower()
            for code in auto:
                low = code.lower()
                if low == lang or low.startswith(lang + '-'):
                    if (code, 'auto') not in seen:
                        seen.add((code, 'auto'))
                        yield code, auto[code], 'auto'


def fmt_url(formats, preferred=('json3', 'vtt', 'srv3', 'ttml')):
    by_ext = {}
    for entry in formats or []:
        if isinstance(entry, dict) and entry.get('url') and entry.get('ext'):
            by_ext[entry['ext']] = entry['url']
    for ext in preferred:
        if ext in by_ext:
            return ext, by_ext[ext]
    for ext in by_ext:
        return ext, by_ext[ext]
    return None, None


def fetch_caption_text(url, cookies_path=None):
    headers = {'User-Agent': 'Mozilla/5.0'}
    if cookies_path:
        # Send only cookies scoped to the request's host; joining a full
        # multi-domain cookie export into one header makes YouTube return
        # HTTP 413 (Request Entity Too Large).
        host = (urllib.parse.urlsplit(url).hostname or '').lower()
        jar = []
        try:
            with open(cookies_path, encoding='utf-8') as fh:
                for line in fh:
                    line = line.strip()
                    if not line or line.startswith('#'):
                        continue
                    parts = line.split('\t')
                    if len(parts) >= 7:
                        cdom = (parts[0] or '').lstrip('.').lower()
                        if cdom and not (host == cdom or host.endswith('.' + cdom)):
                            continue
                        jar.append('%s=%s' % (parts[5], parts[6]))
        except OSError:
            jar = []
        if jar:
            headers['Cookie'] = '; '.join(jar)
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return resp.read().decode('utf-8', errors='replace')
    except urllib.error.HTTPError as exc:
        if exc.code == 429:
            raise RuntimeError('YouTube rate-limited the caption request (HTTP 429). Wait a minute and retry.') from exc
        raise


def parse_json3(raw):
    data = json.loads(raw)
    segments = []
    for event in data.get('events', []):
        if 'segs' not in event:
            continue
        text = ''.join(s.get('utf8', '') for s in event['segs']).strip()
        if not text:
            continue
        start = event.get('tStartMs', 0) / 1000
        duration = event.get('dDurationMs', 0) / 1000
        segments.append({'start': round(start, 3), 'duration': round(duration, 3), 'text': text})
    return segments


VTT_CUE_RE = re.compile(
    r'^\s*(\d{1,2}:)?(\d{1,2}):(\d{2})[.,](\d{1,3})\s*-->\s*'
    r'(\d{1,2}:)?(\d{1,2}):(\d{2})[.,](\d{1,3})')


def _vtt_ts(hours, minutes, seconds, millis):
    return (int(hours[:-1]) if hours else 0) * 3600 \
        + int(minutes) * 60 + int(seconds) \
        + int(millis.ljust(3, '0')) / 1000.0


def parse_vtt(raw):
    lines = raw.replace('\r\n', '\n').replace('\r', '\n').split('\n')
    segments = []
    i = 0
    total = len(lines)
    while i < total:
        m = VTT_CUE_RE.match(lines[i])
        if m is None:
            i += 1
            continue
        start = _vtt_ts(m.group(1), m.group(2), m.group(3), m.group(4))
        end = _vtt_ts(m.group(5), m.group(6), m.group(7), m.group(8))
        i += 1
        parts = []
        while i < total and lines[i].strip():
            line = re.sub(r'<[^>]+>', '', lines[i]).strip()
            if line:
                parts.append(line)
            i += 1
        text = ' '.join(parts)
        if text:
            segments.append({'start': round(start, 3), 'duration': round(end - start, 3), 'text': text})
    deduped = []
    for seg in segments:
        if deduped and seg['text'] == deduped[-1]['text']:
            continue
        deduped.append(seg)
    return deduped


def parse_srv(raw):
    import xml.etree.ElementTree as ET
    root = ET.fromstring(raw)
    segments = []
    for el in root.iter():
        if not isinstance(el.tag, str) or not el.tag.endswith('text'):
            continue
        start = float(el.get('start', el.get('t', '0')) or 0)
        dur = float(el.get('dur', '0') or 0)
        text = ''.join(el.itertext()).strip()
        if not text:
            continue
        segments.append({'start': round(start, 3), 'duration': round(dur, 3), 'text': text})
    return segments


def segments_from(ext, raw):
    if ext == 'json3':
        return parse_json3(raw)
    if ext in ('vtt', 'srt'):
        return parse_vtt(raw)
    if ext.startswith('srv'):
        return parse_srv(raw)
    if ext == 'ttml':
        return parse_srv(raw)
    raise RuntimeError('unsupported caption format: %s' % ext)


def build_text(segments):
    return '\n'.join(seg['text'] for seg in segments)


def hhmmss(seconds):
    total = int(seconds)
    return '%d:%02d:%02d' % (total // 3600, (total % 3600) // 60, total % 60)


def clean_metadata(info):
    drop = ('formats', 'requested_formats', 'requested_downloads', 'subtitles', 'automatic_captions', 'thumbnails', 'chapters')
    result = {}
    for key, value in info.items():
        if key in drop or key.startswith('_'):
            continue
        try:
            json.dumps(value)
        except (TypeError, ValueError):
            continue
        result[key] = value
    return result


class TranscriptError(RuntimeError):
    '''A per-video transcript failure tagged with a stage ('no_track', 'fetch',
    'empty') so callers can map stages to their own messages and exit codes.'''

    def __init__(self, stage, message, ext=None):
        RuntimeError.__init__(self, message)
        self.stage = stage
        self.ext = ext


def fetch_caption_segments(info, langs, want_auto=True, cookies_path=None):
    '''Pick a caption track for an already-fetched info dict, download and
    parse it. Returns (segments, code, kind, ext); raises TranscriptError
    tagged with a stage on any failure.'''
    chosen = None
    for code, formats, kind in pick_track(info, langs, want_auto=want_auto):
        ext, url = fmt_url(formats)
        if url:
            chosen = (code, kind, ext, url)
            break
    if chosen is None:
        raise TranscriptError('no_track', "no caption track with a usable URL for lang(s) '%s'" % ','.join(langs))
    code, kind, ext, url = chosen
    try:
        raw = fetch_caption_text(url, cookies_path)
        segments = segments_from(ext, raw)
    except Exception as exc:
        raise TranscriptError('fetch', str(exc), ext=ext) from exc
    if not segments:
        raise TranscriptError('empty', 'caption track was empty')
    return segments, code, kind, ext


def build_document(info, segments, code, kind, ext, include_metadata=True):
    '''Build the transcript JSON document (identical shape for the single-video
    write and for OpenViking pushes). Returns the doc dict; metadata is None
    when include_metadata is False.'''
    tr_text = build_text(segments)
    return {
        'metadata': clean_metadata(info) if include_metadata else None,
        'transcript': {
            'language': code,
            'kind': kind,
            'format': ext,
            'text': tr_text,
        },
        'fetched_at': datetime.now(timezone.utc).isoformat(),
    }


def fetch_transcript_for_video(url, yt_dlp_module, langs, want_auto=True, cookies_path=None):
    '''One-stop helper for channel mode: fetch info for one video URL, pick a
    caption track, download and parse it, and build the document. Returns
    (info, doc). The single-video path keeps its own fetch_info call so
    --list-langs still works without touching captions.'''
    info = fetch_info(url, yt_dlp_module, cookies_path)
    segments, code, kind, ext = fetch_caption_segments(info, langs, want_auto=want_auto, cookies_path=cookies_path)
    return info, build_document(info, segments, code, kind, ext)


def resolve_openviking_key():
    '''Return the OpenViking API key: env OPENVIKING_API_KEY first, then ~/.ov_user_key.'''
    key = os.environ.get('OPENVIKING_API_KEY')
    if key and key.strip():
        return key.strip()
    try:
        with open(os.path.expanduser('~/.ov_user_key'), 'r', encoding='utf-8') as fh:
            key = fh.read().strip()
    except OSError:
        return None
    return key or None


def resolve_openviking_base_url():
    '''Return the OpenViking base URL: --openviking-url CLI arg (the caller passes it as base_url) first, then env OPENVIKING_BASE_URL, then the OPENVIKING_BASE_URL_DEFAULT constant.'''
    base = (os.environ.get('OPENVIKING_BASE_URL') or '').strip()
    if not base:
        base = OPENVIKING_BASE_URL_DEFAULT
    return base.rstrip('/')


def slugify(text):
    if not text:
        return ''
    return re.sub(r'[^a-z0-9]+', '-', text.lower()).strip('-')


def format_upload_date(value):
    '''Human-readable upload date: a plain YYYYMMDD string renders as
    YYYY-MM-DD (raw YYYYMMDD); anything else (already ISO-shaped, garbage,
    non-strings) passes through as-is so the line can never crash.'''
    if isinstance(value, str):
        if len(value) == 8 and value.isdigit():
            return '%s-%s-%s (raw %s)' % (value[:4], value[4:6], value[6:8], value)
        if (len(value) == 10 and value[4] == '-' and value[7] == '-'
                and value[:4].isdigit() and value[5:7].isdigit() and value[8:10].isdigit()):
            return value
        return value
    return '%s' % value


def render_openviking_document(doc, info):
    '''Render the transcript document as one readable plain-text block.'''
    tr = doc.get('transcript') or {}
    meta = doc.get('metadata') or {}
    lines = [str(info.get('title') or meta.get('title') or 'Untitled video'), '']
    facts = []
    uploader = info.get('uploader') or meta.get('uploader')
    if uploader:
        facts.append('uploader: %s' % uploader)
    channel = info.get('channel') or meta.get('channel')
    if channel and channel != uploader:
        facts.append('channel: %s' % channel)
    video_id = info.get('id') or meta.get('id')
    if video_id:
        facts.append('video id: %s' % video_id)
    duration = info.get('duration')
    if isinstance(duration, (int, float)):
        facts.append('duration: %s (%d seconds)' % (hhmmss(duration), duration))
    upload_date = info.get('upload_date') or meta.get('upload_date')
    if upload_date:
        facts.append('upload date: %s' % format_upload_date(upload_date))
    fetched_at = doc.get('fetched_at')
    if fetched_at:
        try:
            stamp = datetime.fromisoformat(fetched_at)
        except (TypeError, ValueError):
            stamp = None
        if stamp is not None:
            if stamp.tzinfo is not None:
                stamp = stamp.astimezone(timezone.utc)
            facts.append('archived: %s' % stamp.strftime('%Y-%m-%d %H:%M:%S UTC'))
    view_count = info.get('view_count') or meta.get('view_count')
    if view_count:
        facts.append('view count: %s' % view_count)
    webpage_url = info.get('webpage_url') or meta.get('webpage_url') or info.get('original_url')
    if webpage_url:
        facts.append('url: %s' % webpage_url)
    lines.extend(facts)
    lines.append('')
    lines.append('transcript language: %s (%s captions)' % (
        tr.get('language') or 'unknown', tr.get('kind') or 'unknown'))
    lines.append('')
    lines.append(tr.get('text') or '(no transcript text)')
    return '\n'.join(lines)


def openviking_request(method, path, key, payload=None, query=None, timeout=30, base_url=None, allow_error=False):
    '''Call the OpenViking REST API; returns the parsed dict, raises RuntimeError on error.

    With allow_error=True an API-level error body is returned as-is so the
    caller can interpret it (e.g. the NOT_FOUND result of an existence probe);
    transport failures, HTTP errors, and unparseable bodies still raise.'''
    url = (base_url or resolve_openviking_base_url()) + path
    if query:
        url += '?' + urllib.parse.urlencode(query)
    headers = {'x-api-key': key}
    data = None
    if payload is not None:
        data = json.dumps(payload).encode('utf-8')
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read().decode('utf-8', errors='replace')
    except urllib.error.HTTPError as exc:
        try:
            detail = exc.read().decode('utf-8', errors='replace').strip()
        except OSError:
            detail = ''
        raise RuntimeError('openviking %s %s: HTTP %d: %s' % (
            method, path, exc.code, detail or exc.reason)) from exc
    except OSError as exc:
        raise RuntimeError('openviking %s %s: %s' % (method, path, exc)) from exc
    try:
        parsed = json.loads(body)
    except ValueError as exc:
        raise RuntimeError('openviking %s %s: invalid JSON response: %s' % (method, path, body[:200])) from exc
    if not isinstance(parsed, dict):
        raise RuntimeError('openviking %s %s: unexpected response: %s' % (method, path, body[:200]))
    if parsed.get('status') != 'ok':
        if allow_error:
            return parsed
        error = parsed.get('error') if isinstance(parsed.get('error'), dict) else {}
        message = error.get('message') or error.get('code') or json.dumps(parsed)
        raise RuntimeError('openviking %s %s: %s' % (method, path, message))
    return parsed


def push_to_openviking(doc, info, base_url=None):
    '''Push the rendered transcript document to OpenViking; prints the result line, returns the uri.'''
    base_url = base_url or resolve_openviking_base_url()
    key = resolve_openviking_key()
    if not key:
        raise RuntimeError('OpenViking key not found: set OPENVIKING_API_KEY or ~/.ov_user_key')
    video_id = str(info.get('id') or '')
    if not video_id:
        raise RuntimeError('video id missing; cannot build an OpenViking uri')
    slug = slugify(info.get('uploader') or '') or 'unknown'
    uri = 'viking://resources/media/youtube/%s/%s' % (slug, video_id)
    parent_uri = uri.rsplit('/', 1)[0]
    rendered = render_openviking_document(doc, info)
    try:
        # one mkdir is enough: it creates the full parent chain in a single
        # call, and failing here usually just means the directory already
        # exists; the content write below is the real gate for real errors.
        openviking_request('POST', '/api/v1/fs/mkdir', key, payload={'uri': parent_uri}, base_url=base_url)
    except RuntimeError:
        pass
    result = openviking_request('POST', '/api/v1/content/write', key, base_url=base_url,
        payload={'uri': uri, 'content': rendered, 'mode': 'replace', 'wait': False})
    written = (result.get('result') or {}).get('written_bytes')
    if not isinstance(written, int):
        written = len(rendered.encode('utf-8'))
    readback = openviking_request('GET', '/api/v1/content/read', key, query={'uri': uri}, base_url=base_url)
    content = readback.get('result')
    if not isinstance(content, str) or not content:
        raise RuntimeError('openviking read-back returned an empty document for %s' % uri)
    print('openviking: wrote %s (%d bytes)' % (uri, written))
    return uri


def normalize_channel_url(channel_url):
    """A bare channel URL (no tab) enumerates channel tabs, not videos.
    yt-dlp then returns playlist entries whose id is the channel id
    (UC + 22 chars). Those get passed to the video fetcher and fail as
    video unavailable after the id is truncated to 11 characters.
    Append /videos unless the URL already names a tab or is a playlist.
    """
    from urllib.parse import urlparse, urlunparse
    raw = (channel_url or "").strip()
    parsed = urlparse(raw)
    path = parsed.path.rstrip("/")
    tabs = ("/videos", "/streams", "/shorts", "/playlists", "/featured",
            "/about", "/community", "/posts")
    if "list=" in (parsed.query or ""):
        return raw
    if path.endswith(tabs):
        return raw
    parts = [part for part in path.split("/") if part]
    if parts and (parts[0].startswith("@") or parts[0] in ("channel", "c", "user")):
        path = path + "/videos"
        return urlunparse(parsed._replace(path=path))
    return raw


def is_video_entry(entry):
    """Flat-playlist channel-root dumps include tab playlists, not videos."""
    vid = str(entry.get("id") or "")
    if entry.get("_type") == "playlist":
        return False
    if vid.startswith("UC") and len(vid) == 24:
        return False
    return len(vid) == 11


def enumerate_channel_videos(channel_url, yt_dlp_binary, limit=None):
    '''Enumerate a channel/playlist with the yt-dlp binary (flat playlist, no
    module import needed); returns (channel_name, [{'id': ..., 'title': ...}, ...]).'''
    if yt_dlp_binary is None:
        raise RuntimeError('the yt-dlp binary is required to enumerate a channel; install yt-dlp and make sure it is on PATH')
    cmd = [yt_dlp_binary, '--flat-playlist', '--dump-single-json',
           '--js-runtimes', 'node', '--remote-components', 'ejs:github']
    if limit is not None:
        cmd += ['--playlist-end', str(int(limit))]
    channel_url = normalize_channel_url(channel_url)
    cmd.append(channel_url)
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError('channel enumeration timed out after 600s') from exc
    except OSError as exc:
        raise RuntimeError('could not run the yt-dlp binary for channel enumeration: %s' % exc) from exc
    if proc.returncode != 0:
        raise RuntimeError('channel enumeration failed (yt-dlp exit %d): %s' % (
            proc.returncode, (proc.stderr or '').strip()[:400]))
    try:
        data = json.loads(proc.stdout)
    except ValueError as exc:
        raise RuntimeError('channel enumeration returned unparseable JSON: %s' % exc) from exc
    if not isinstance(data, dict):
        raise RuntimeError('channel enumeration returned unexpected output: JSON was not a single object')
    videos = []
    for entry in (data.get('entries') or []):
        if not isinstance(entry, dict) or not is_video_entry(entry):
            continue
        videos.append({'id': str(entry['id']), 'title': entry.get('title')})
    if limit is not None:
        videos = videos[:int(limit)]
    if not videos:
        raise RuntimeError('channel enumeration returned no videos for %s' % channel_url)
    return data.get('channel') or data.get('uploader') or '', videos


def openviking_video_exists(uri, key, base_url=None):
    '''Cheap OpenViking existence probe for one uri: True when present, False
    when the API reports NOT_FOUND; anything else raises so the caller can
    record it as a per-video failure.'''
    try:
        parsed = openviking_request('GET', '/api/v1/fs/stat', key,
            query={'uri': uri}, base_url=base_url, allow_error=True)
    except RuntimeError as exc:
        # the API answers a missing file with HTTP 404 whose JSON body names
        # the NOT_FOUND code; that is the not-exists signal, not a hard error
        text = str(exc)
        if 'HTTP 404' in text and 'NOT_FOUND' in text:
            return False
        raise
    if parsed.get('status') == 'ok':
        return True
    error = parsed.get('error') if isinstance(parsed.get('error'), dict) else {}
    if error.get('code') == 'NOT_FOUND':
        return False
    raise RuntimeError('openviking stat check for %s: %s' % (
        uri, error.get('message') or error.get('code') or json.dumps(parsed)))


def run_channel_mode(args):
    """Channel scrape mode. Enumerates the channel with the yt-dlp binary and
    handles each video in order: with --push-openviking, a video already
    stored in OpenViking is skipped (resume-safe fast path, no fetch) unless
    --force; otherwise the transcript is fetched through the usual helpers and
    pushed. Without --push-openviking nothing is written anywhere (no files,
    no OpenViking); -o/--text-only/--with-timestamps are ignored here. Per-video
    failures (429, no captions, network, push errors) are counted and recorded
    with their reason and the loop continues; exit is 0 whenever enumeration
    itself worked, 7 only when it (or the OpenViking key) did not.

    On a TTY, a rich progress bar replaces the per-video print stream. Non-TTY
    keeps the plain lines so logs stay greppable. rich is not imported until
    that TTY path is taken.
    """
    langs = [part.strip() for part in args.lang.split(',') if part.strip()]
    cookies_path = resolve_cookies_path(getattr(args, 'cookies', None))
    push = bool(args.push_openviking)
    base_url = args.openviking_url
    use_bar = sys.stderr.isatty()
    console = None
    if use_bar:
        ensure_rich()
        from rich.console import Console
        from rich.status import Status
        console = Console(stderr=True)
        try:
            with Status('enumerating channel...', console=console, spinner='dots'):
                channel_name, videos = enumerate_channel_videos(args.channel, find_yt_dlp_binary(), args.limit)
        except Exception as exc:
            console.print('[red]error:[/] %s' % exc)
            return 7
    else:
        try:
            channel_name, videos = enumerate_channel_videos(args.channel, find_yt_dlp_binary(), args.limit)
        except Exception as exc:
            sys.stderr.write('error: %s\n' % exc)
            return 7
    push_key = None
    if push:
        push_key = resolve_openviking_key()
        if not push_key:
            msg = 'error: OpenViking key not found: set OPENVIKING_API_KEY or ~/.ov_user_key'
            if console is not None:
                console.print('[red]%s[/]' % msg)
            else:
                sys.stderr.write(msg + '\n')
            return 7
    total = len(videos)
    module = load_yt_dlp()
    slug = slugify(channel_name) or 'unknown'
    last = total - 1
    pushed = skipped = fetched = failed = 0
    failures = []
    note = ''
    if args.limit is not None:
        note = ', limit=%d' % args.limit
    label = channel_name or '(unknown)'

    progress = None
    task_id = None
    if use_bar:
        from rich.progress import (
            BarColumn, MofNCompleteColumn, Progress, SpinnerColumn,
            TextColumn, TimeElapsedColumn, TimeRemainingColumn,
        )
        progress = Progress(
            SpinnerColumn(),
            TextColumn('[bold]{task.fields[channel]}[/]'),
            BarColumn(bar_width=28),
            MofNCompleteColumn(),
            TimeElapsedColumn(),
            TimeRemainingColumn(),
            TextColumn('ok [green]{task.fields[ok]}[/]  skip [yellow]{task.fields[skip]}[/]  fail [red]{task.fields[fail]}[/]'),
            TextColumn('[dim]{task.fields[detail]}[/]'),
            console=console,
            transient=False,
            refresh_per_second=8,
        )
        progress.start()
        task_id = progress.add_task(
            'channel', total=total, channel=label,
            ok=0, skip=0, fail=0, detail='starting%s' % note,
        )
    else:
        print('channel: %s -> %d video(s) to process%s' % (label, total, note))

    def _detail(vid, title, state):
        title = ' '.join(str(title or '').split())
        if len(title) > 48:
            title = title[:47] + '\u2026'
        return '%s %s  %s' % (state, vid, title)

    def _tick(state, vid, title):
        if progress is None:
            return
        progress.update(
            task_id,
            ok=pushed + fetched,
            skip=skipped,
            fail=failed,
            detail=_detail(vid, title, state),
        )

    try:
        for index, entry in enumerate(videos):
            vid = entry['id']
            title = str(entry.get('title') or '')
            video_url = 'https://www.youtube.com/watch?v=%s' % vid
            handled = False
            try:
                if push and not args.force:
                    uri = 'viking://resources/media/youtube/%s/%s' % (slug, vid)
                    _tick('stat', vid, title)
                    if openviking_video_exists(uri, push_key, base_url):
                        skipped += 1
                        _tick('skip', vid, title)
                        if progress is None:
                            print('skipped: %s (already in OpenViking: %s)' % (vid, uri))
                        handled = True
                if not handled:
                    _tick('fetch', vid, title)
                    info, doc = fetch_transcript_for_video(
                        video_url, module, langs, not args.no_auto, cookies_path=cookies_path)
                    if push:
                        _tick('push', vid, title)
                        push_to_openviking(doc, info, base_url=base_url)
                        pushed += 1
                        _tick('pushed', vid, title)
                        if progress is None:
                            print('pushed: %s - %s' % (vid, title))
                    else:
                        fetched += 1
                        nchars = len(doc['transcript']['text'])
                        _tick('fetched', vid, title)
                        if progress is None:
                            print('fetched: %s - %s (%d text chars)' % (vid, title, nchars))
            except Exception as exc:
                failed += 1
                failures.append((vid, str(exc)))
                _tick('fail', vid, title)
                line = 'failed: %s - %s' % (vid, exc)
                if progress is not None:
                    progress.console.print('[red]%s[/]' % line)
                else:
                    print(line)
            if progress is not None:
                progress.update(
                    task_id, advance=1,
                    ok=pushed + fetched, skip=skipped, fail=failed,
                )
            if index != last:
                if progress is not None and args.sleep:
                    progress.update(task_id, detail='sleep %.1fs' % args.sleep)
                time.sleep(args.sleep)
    finally:
        if progress is not None:
            progress.stop()

    summary = 'summary: total=%d pushed=%d skipped-existing=%d failed=%d%s' % (
        total, pushed, skipped, failed,
        '' if push else ', fetched-not-pushed=%d' % fetched)
    if console is not None:
        style = 'green' if not failures else 'yellow'
        console.print('[%s]%s[/]' % (style, summary))
        if not failures:
            console.print('[green]all ok: %d video(s) processed without failure[/]' % total)
    else:
        print(summary)
        for vid, reason in failures:
            print('failed: %s - %s' % (vid, reason))
        if not failures:
            print('all ok: %d video(s) processed without failure' % total)
    return 0


def build_parser():
    parser = argparse.ArgumentParser(description='Download a video transcript as JSON (any site yt-dlp supports).')
    # nargs='?' leaves the single-video positional behaviour identical (the URL
    # is still normally given positionally and stays required in that mode);
    # --channel carries the channel URL itself so a scrape needs no positional
    # at all, and when both are supplied the --channel value wins (see the
    # dispatch in main() - that is the cleanest override point).
    parser.add_argument('url', nargs='?', default=None)
    parser.add_argument('-o', '--output')
    parser.add_argument('--lang', default='en')
    parser.add_argument('--no-auto', dest='no_auto', action='store_true')
    parser.add_argument('--text-only', action='store_true')
    parser.add_argument('--list-langs', action='store_true')
    parser.add_argument('--with-timestamps', action='store_true')
    parser.add_argument('--no-metadata', action='store_true')
    parser.add_argument('--channel', default=None, metavar='URL',
        help='scrape mode: enumerate this channel/playlist and handle every video transcript in order')
    parser.add_argument('--sleep', type=float, default=2.0, metavar='N',
        help='seconds to sleep between caption fetches in channel mode (default: 2.0)')
    parser.add_argument('--limit', type=int, default=None, metavar='N',
        help='only handle the first N channel videos (default: all)')
    parser.add_argument('--force', action='store_true',
        help='channel mode: re-push videos that already exist in OpenViking (default: skip them)')
    parser.add_argument('--push-openviking', action='store_true',
        help='also push the transcript to OpenViking at viking://resources/media/youtube/<uploader>/<video-id>')
    parser.add_argument('--openviking-url', default=None,
        help='OpenViking base URL (default: $OPENVIKING_BASE_URL or %s)' % OPENVIKING_BASE_URL_DEFAULT)
    parser.add_argument('--cookies', default=None, metavar='FILE',
        help='Netscape cookies.txt for YouTube auth (default: TRANSCRIPT_COOKIES env or ~/.config/yt-dlp/transcript.cookies.txt)')
    return parser


def main(argv=None):
    parser = build_parser()
    args = parser.parse_args(argv)

    # Channel-mode dispatch: --channel selects the scrape and holds the channel
    # URL (so no positional is needed); when a positional is also present, the
    # --channel value overrides it. A plain positional keeps the single-video
    # path exactly as before.
    if args.channel:
        if args.limit is not None and args.limit <= 0:
            parser.error('--limit must be a positive integer')
        if args.sleep < 0:
            parser.error('--sleep must be >= 0')
        return run_channel_mode(args)

    if not args.url:
        parser.error('a video URL is required (or pass --channel CHANNEL_URL to scrape a channel)')

    langs = [part.strip() for part in args.lang.split(',') if part.strip()]
    cookies_path = resolve_cookies_path(args.cookies)

    try:
        module = ensure_yt_dlp()
        info = fetch_info(args.url, module, cookies_path)
    except Exception as exc:
        sys.stderr.write('error: could not read video info: %s\n' % exc)
        return 2

    if args.list_langs:
        manual = info.get('subtitles') or {}
        auto = info.get('automatic_captions') or {}
        print('manual: ' + (', '.join(sorted(manual)) or '(none)'))
        print('auto:   ' + (', '.join(sorted(auto)) or '(none)'))
        return 0

    try:
        segments, code, kind, ext = fetch_caption_segments(info, langs, want_auto=not args.no_auto, cookies_path=cookies_path)
    except TranscriptError as exc:
        # the selection/fetch/parse block was folded into fetch_caption_segments();
        # these stderr lines and exit codes are byte-for-byte what it printed before
        if exc.stage == 'no_track':
            sys.stderr.write("error: no caption track with a usable URL for lang(s) '%s'; use --list-langs to see available languages\n" % args.lang)
            return 3
        if exc.stage == 'empty':
            sys.stderr.write('error: caption track was empty.\n')
            return 5
        sys.stderr.write('error: could not fetch/parse captions (%s): %s\n' % (getattr(exc, 'ext', None) or 'unknown', exc))
        return 4

    if args.text_only:
        if args.with_timestamps:
            for seg in segments:
                print('[%s] %s' % (hhmmss(seg['start']), seg['text']))
        else:
            print(build_text(segments))
        return 0

    doc = build_document(info, segments, code, kind, ext, include_metadata=not args.no_metadata)
    meta_block = doc.get('metadata')
    tr_text = doc['transcript']['text']

    output = args.output
    if not output:
        video_id = str(info.get('id') or 'video')
        output = re.sub(r'[^\w.-]+', '_', video_id)[:80] + '.transcript.json'

    with open(output, 'w', encoding='utf-8') as fh:
        json.dump(doc, fh, ensure_ascii=False, indent=2)

    if meta_block is None:
        meta_note = 'no metadata'
    else:
        meta_note = 'metadata keys=' + str(len(meta_block))

    print('%s: %d segments, %d text chars, language=%s, kind=%s, format=%s, %s' % (
        output, len(segments), len(tr_text), code, kind, ext, meta_note))

    if args.push_openviking:
        try:
            push_to_openviking(doc, info, base_url=args.openviking_url)
        except Exception as exc:
            sys.stderr.write('error: openviking push failed: %s\n' % exc)
            sys.stderr.write('note: the transcript file %s itself was written fine\n' % output)
            return 6

    return 0


if __name__ == '__main__':
    sys.exit(main())