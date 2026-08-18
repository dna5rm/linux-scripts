#!/usr/bin/env python3
"""exif-edit: edit common metadata tags on any file exiftool can write.

Usage:
    exif-edit FILE                  # TUI editor
    exif-edit -p FILE               # print tags to stdout (JSON)
    exif-edit --set Title='Foo' FILE

Backend is exiftool. Overwrites in place.
Up/Down (and j/k) move between fields; Left/Right stay in the input.
"""
from __future__ import annotations

import argparse
import importlib
import json
import os
import shutil
import subprocess
import sys

CORE_PACKAGES = {"textual": "textual", "rich": "rich"}

# Cross-format set. Empty values are fine; exiftool maps what it can.
TAGS = (
    "Title",
    "Subject",
    "Description",
    "Author",
    "Artist",
    "Creator",
    "Producer",
    "Copyright",
    "Keywords",
    "Comment",
)


def ensure_core() -> None:
    missing = []
    for import_name, pip_name in CORE_PACKAGES.items():
        try:
            importlib.import_module(import_name)
        except ImportError:
            missing.append(pip_name)
    if not missing:
        return
    print(f"Missing required packages: {', '.join(missing)}")
    for pip_name in missing:
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", pip_name])
        except subprocess.CalledProcessError as e:
            print(f"[FATAL] Failed to install '{pip_name}': {e}", file=sys.stderr)
            sys.exit(1)
    os.execv(sys.executable, [sys.executable] + sys.argv)


def require_exiftool() -> str:
    path = shutil.which("exiftool")
    if not path:
        print("Error: exiftool is required but not installed.", file=sys.stderr)
        sys.exit(1)
    return path


def inspect_file(exiftool: str, path: str) -> dict:
    proc = subprocess.run(
        [exiftool, "-j", "-FileType", "-MIMEType", "-Error", path],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        err = (proc.stderr or proc.stdout or "exiftool failed").strip()
        print(f"Error: {err}", file=sys.stderr)
        sys.exit(1)
    try:
        data = json.loads(proc.stdout)[0]
    except (json.JSONDecodeError, IndexError) as e:
        print(f"Error: could not parse exiftool JSON: {e}", file=sys.stderr)
        sys.exit(1)
    if data.get("Error"):
        print(f"Error: {data['Error']}", file=sys.stderr)
        sys.exit(1)
    if not data.get("FileType"):
        print(f"Error: {path} has no readable metadata (unknown type)", file=sys.stderr)
        sys.exit(1)
    return data


def _norm(val) -> str:
    if isinstance(val, list):
        return ", ".join(str(x) for x in val)
    if val in (None, "-"):
        return ""
    return str(val)


def read_tags(exiftool: str, path: str) -> dict[str, str]:
    args = [exiftool, "-j", "-f", *[f"-{t}" for t in TAGS], path]
    proc = subprocess.run(args, capture_output=True, text=True)
    if proc.returncode != 0:
        print(proc.stderr or "exiftool failed", file=sys.stderr)
        sys.exit(1)
    try:
        data = json.loads(proc.stdout)[0]
    except (json.JSONDecodeError, IndexError, KeyError) as e:
        print(f"Error: could not parse exiftool JSON: {e}", file=sys.stderr)
        sys.exit(1)
    out = {"SourceFile": data.get("SourceFile") or path}
    for tag in TAGS:
        out[tag] = _norm(data.get(tag, ""))
    return out


def write_tags(exiftool: str, path: str, tags: dict[str, str]) -> None:
    cmd = [exiftool, "-overwrite_original"]
    for tag in TAGS:
        cmd.append(f"-{tag}={tags.get(tag, '')}")
    cmd.append(path)
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        print(proc.stderr or "exiftool write failed", file=sys.stderr)
        sys.exit(1)
    if proc.stdout.strip():
        print(proc.stdout.strip())


def parse_set(items: list[str]) -> dict[str, str]:
    out: dict[str, str] = {}
    known = {t.lower(): t for t in TAGS}
    for item in items:
        if "=" not in item:
            print(f"Error: --set expects Tag=value, got {item!r}", file=sys.stderr)
            sys.exit(1)
        key, val = item.split("=", 1)
        canon = known.get(key.lower())
        if not canon:
            print(f"Error: unknown tag {key!r} (want {', '.join(TAGS)})", file=sys.stderr)
            sys.exit(1)
        out[canon] = val
    return out


def run_tui(path: str, current: dict[str, str], exiftool: str, kind: str) -> None:
    ensure_core()
    from textual.app import App
    from textual.binding import Binding
    from textual.containers import Vertical, Horizontal, VerticalScroll
    from textual.widgets import Button, Footer, Header, Input, Label, Static

    FOCUSABLE_IDS = [f"in-{t}" for t in TAGS] + ["save", "cancel"]

    class ExifEditApp(App):
        CSS = """
        Screen { background: #282a36; color: #f8f8f2; }
        Header { background: #21222c; color: #8be9fd; text-style: bold; }
        Footer { background: #21222c; color: #6272a4; }
        #form {
            padding: 1 2;
            height: 1fr;
        }
        .row { height: 3; }
        .tag {
            width: 14;
            color: #8be9fd;
            content-align: left middle;
        }
        Input {
            background: #21222c;
            color: #f8f8f2;
            border: tall #44475a;
        }
        Input:focus { border: tall #8be9fd; }
        #buttons {
            height: 1;
            width: 100%;
            align: center middle;
            background: #21222c;
            padding: 0;
        }
        #buttons Button {
            margin: 0 1;
            min-width: 10;
            height: 1;
            min-height: 1;
            border: none;
            padding: 0 1;
        }
        """
        BINDINGS = [
            Binding("up", "field_prev", "Up", show=True, priority=True),
            Binding("down", "field_next", "Down", show=True, priority=True),
            Binding("k", "field_prev", "Up", show=False, priority=True),
            Binding("j", "field_next", "Down", show=False, priority=True),
            Binding("ctrl+s", "save", "Save", show=True),
            Binding("escape", "quit", "Quit", show=True),
        ]

        def __init__(self):
            super().__init__()
            self._saved = False

        def compose(self):
            yield Header(show_clock=False)
            with VerticalScroll(id="form"):
                for tag in TAGS:
                    with Horizontal(classes="row"):
                        yield Label(tag, classes="tag")
                        yield Input(value=current.get(tag, ""), id=f"in-{tag}")
            with Horizontal(id="buttons"):
                yield Button("Save", id="save", variant="success", compact=True)
                yield Button("Cancel", id="cancel", compact=True)
            yield Footer()

        def on_mount(self) -> None:
            self.title = "EXIF Tagger"
            self.sub_title = f"{kind} · {os.path.basename(path)}"
            self.query_one(f"#in-{TAGS[0]}", Input).focus()

        def _focus_index(self) -> int:
            focused = self.focused
            fid = getattr(focused, "id", None) if focused else None
            if fid in FOCUSABLE_IDS:
                return FOCUSABLE_IDS.index(fid)
            return 0

        def action_field_next(self) -> None:
            idx = (self._focus_index() + 1) % len(FOCUSABLE_IDS)
            self.query_one(f"#{FOCUSABLE_IDS[idx]}").focus()

        def action_field_prev(self) -> None:
            idx = (self._focus_index() - 1) % len(FOCUSABLE_IDS)
            self.query_one(f"#{FOCUSABLE_IDS[idx]}").focus()

        def _values(self) -> dict[str, str]:
            return {tag: self.query_one(f"#in-{tag}", Input).value for tag in TAGS}

        def action_save(self) -> None:
            new = self._values()
            if new == {t: current.get(t, "") for t in TAGS}:
                self.notify("No changes")
                self.exit()
                return
            write_tags(exiftool, path, new)
            self._saved = True
            self.exit()

        def action_quit(self) -> None:
            self.exit()

        def on_button_pressed(self, event: Button.Pressed) -> None:
            if event.button.id == "save":
                self.action_save()
            else:
                self.action_quit()

    ExifEditApp().run()


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="exif-edit",
        description="Edit Title/Subject/Author/… on any file exiftool supports.",
    )
    parser.add_argument("file", help="Path to a file with metadata (PDF, JPEG, …)")
    parser.add_argument("-p", "--print", action="store_true", dest="dump",
                        help="Print current tags as JSON and exit")
    parser.add_argument("--set", action="append", default=[], metavar="TAG=VALUE",
                        help="Set a tag non-interactively (repeatable)")
    args = parser.parse_args()

    path = args.file if args.file.startswith("/") else os.path.abspath(args.file)
    if not os.path.isfile(path):
        print(f"Error: {path} not found", file=sys.stderr)
        sys.exit(1)

    exiftool = require_exiftool()
    info = inspect_file(exiftool, path)
    kind = info.get("FileType") or "unknown"
    current = read_tags(exiftool, path)
    current["FileType"] = kind
    if info.get("MIMEType"):
        current["MIMEType"] = info["MIMEType"]

    if args.dump:
        print(json.dumps(current, indent=2))
        return

    if args.set:
        merged = {t: current.get(t, "") for t in TAGS}
        merged.update(parse_set(args.set))
        if merged == {t: current.get(t, "") for t in TAGS}:
            print("No changes")
            return
        write_tags(exiftool, path, merged)
        print(json.dumps(read_tags(exiftool, path), indent=2))
        return

    if not sys.stdin.isatty():
        print(json.dumps(current, indent=2))
        return

    run_tui(path, current, exiftool, kind)


if __name__ == "__main__":
    main()
