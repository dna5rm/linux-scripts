#!/usr/bin/env python3
"""md-glow: glow-like markdown renderer (Glamour dark palette).

Usage:
    md-glow FILE.md                 # print to stdout (glow-style colors)
    md-glow -p FILE.md              # Textual pager
    md-glow -p -                     # pager from stdin
    cat FILE.md | md-glow           # stdout from stdin
    md-glow -w 100 FILE.md          # wrap width (0 = terminal)

Pager keys:
    j/Down  scroll down     k/Up    scroll up
    Space   page down       b       page up
    g       top             G       bottom
    t       speak visible (again = stop)
    q       quit
"""
from __future__ import annotations

import argparse
import importlib
import os
import shutil
import subprocess
import sys

CORE_PACKAGES = {
    "rich": "rich",
    "textual": "textual",
}


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
            print(f"[FATAL] Failed to install '{pip_name}': {e}")
            sys.exit(1)
    os.execv(sys.executable, [sys.executable] + sys.argv)


ensure_core()

from rich.console import Console
from rich.markdown import Markdown
from rich.style import Style
from rich.theme import Theme
from textual.app import App
from textual.binding import Binding
from textual.containers import ScrollableContainer
from textual.widgets import Footer, Header, Markdown as TuiMarkdown, Static

# Glamour "dark" (glow default on dark terminals) — 256-color + chroma hex.
# https://github.com/charmbracelet/glamour/blob/master/styles/dark.json
C = {
    "doc": "color(252)",          # grey82 body
    "h": "color(39)",             # deep_sky_blue1 headings
    "h1_fg": "color(228)",        # wheat1
    "h1_bg": "color(63)",         # medium_purple2
    "h6": "color(35)",            # dark_cyan
    "hr": "color(240)",           # grey35
    "link": "color(30)",          # turquoise4
    "link_text": "color(35)",     # dark_cyan
    "image": "color(212)",        # orchid
    "code_fg": "color(203)",      # indian_red1
    "code_bg": "color(236)",      # grey19
    "code_block": "color(244)",   # grey50
    "quote": "color(244)",
}

GLOW_THEME = Theme(
    {
        "markdown.h1": Style(color="color(228)", bgcolor="color(63)", bold=True),
        "markdown.h2": Style(color="color(39)", bold=True),
        "markdown.h3": Style(color="color(39)", bold=True),
        "markdown.h4": Style(color="color(39)", bold=True),
        "markdown.h5": Style(color="color(39)", bold=True),
        "markdown.h6": Style(color="color(35)"),
        "markdown.emph": Style(italic=True),
        "markdown.strong": Style(bold=True),
        "markdown.s": Style(strike=True),
        "markdown.code": Style(color="color(203)", bgcolor="color(236)"),
        "markdown.code_block": Style(color="color(244)"),
        "markdown.item": Style(color="color(252)"),
        "markdown.item.bullet": Style(color="color(39)"),
        "markdown.item.number": Style(color="color(39)"),
        "markdown.block_quote": Style(color="color(244)", italic=True),
        "markdown.hr": Style(color="color(240)"),
        "markdown.link": Style(color="color(30)", underline=True),
        "markdown.link_url": Style(color="color(35)", underline=True),
        "markdown.paragraph": Style(color="color(252)"),
        "markdown.text": Style(color="color(252)"),
        "none": Style(color="color(252)"),
    }
)

TTS_BIN_NAME = "termux-tts-speak"
TTS_DEFAULT_RATE = 1.5
TTS_RATE_ENV = "STUDY_FLASH_TTS_RATE"


def tts_binary() -> str | None:
    return shutil.which(TTS_BIN_NAME)


def tts_rate() -> float:
    raw = os.environ.get(TTS_RATE_ENV, str(TTS_DEFAULT_RATE))
    try:
        rate = float(raw)
    except (TypeError, ValueError):
        return TTS_DEFAULT_RATE
    return max(0.5, min(rate, 3.0))


def wrap_lines(text: str, width: int) -> list[str]:
    width = max(8, int(width))
    out: list[str] = []
    for raw in (text or "").split("\n"):
        line = raw.rstrip()
        if not line:
            out.append("")
            continue
        while len(line) > width:
            out.append(line[:width])
            line = line[width:]
        out.append(line)
    return out


def visible_slice(text: str, scroll_y: int, height: int, width: int) -> str:
    rows = wrap_lines(text, width)
    y = max(0, int(scroll_y))
    h = max(1, int(height))
    return "\n".join(rows[y : y + h]).strip()


def read_source(path: str | None) -> tuple[str, str]:
    """Return (markdown, display_name). path None or '-' = stdin."""
    if path is None or path == "-":
        return sys.stdin.read(), "stdin"
    if not os.path.exists(path):
        print(f"Error: {path} not found", file=sys.stderr)
        sys.exit(1)
    with open(path, encoding="utf-8", errors="replace") as f:
        return f.read(), os.path.basename(path)


def print_glow(md: str, width: int | None) -> None:
    console = Console(theme=GLOW_THEME, width=width, highlight=False)
    console.print(Markdown(md, hyperlinks=True, justify="left"))


PAGER_CSS = """
Screen {
    background: #1c1c1c;
    color: #d0d0d0;
}
#md-container {
    height: 1fr;
    padding: 0 1;
    background: #1c1c1c;
}
Markdown {
    margin: 0 1;
    padding: 1 1;
    background: #1c1c1c;
}
Markdown .em { text-style: italic; }
Markdown .strong { text-style: bold; }
Markdown .s { text-style: strike; }
Markdown .code_inline {
    color: #ff5f5f;
    background: #303030;
}
MarkdownFence {
    background: #303030;
    color: #808080;
    margin: 1 0;
    padding: 0 1;
}
MarkdownH1 {
    color: #ffff87;
    background: #5f5fff;
    text-style: bold;
    width: auto;
    padding: 0 1;
    margin: 1 0;
}
MarkdownH2, MarkdownH3, MarkdownH4, MarkdownH5 {
    color: #00afff;
    text-style: bold;
    margin: 1 0 0 0;
}
MarkdownH6 {
    color: #00af87;
}
MarkdownBlockQuote {
    color: #808080;
    text-style: italic;
    border-left: thick #585858;
    padding-left: 1;
}
MarkdownHR {
    color: #585858;
}
#status {
    dock: bottom;
    height: 1;
    background: #262626;
    color: #808080;
    padding: 0 1;
}
Footer { background: #262626; }
Header { background: #262626; color: #00afff; }
"""


class GlowPager(App):
    CSS = PAGER_CSS
    TITLE = "md-glow"
    BINDINGS = [
        Binding("j,down", "scroll_down", "Down", show=False),
        Binding("k,up", "scroll_up", "Up", show=False),
        Binding("space", "page_down", "PgDn", show=True),
        Binding("b,pageup", "page_up", "PgUp", show=False),
        Binding("g,home", "scroll_home", "Top", show=False),
        Binding("G,end", "scroll_end", "End", show=False),
        Binding("t", "speak_visible", "Speak", show=True),
        Binding("q", "leave", "Quit", show=True),
    ]

    def __init__(self, markdown: str, name: str):
        super().__init__()
        self._md = markdown
        self._name = name
        self._tts_bin = tts_binary()
        self._tts_proc: subprocess.Popen | None = None

    def compose(self):
        yield Header(show_clock=False)
        yield ScrollableContainer(TuiMarkdown(self._md, id="body"), id="md-container")
        yield Static("", id="status")
        yield Footer()

    def on_mount(self) -> None:
        self.title = f"md-glow: {self._name}"
        self._update_status()

    def _update_status(self) -> None:
        speak = "Speak" if self._tts_bin else "no TTS"
        self.query_one("#status", Static).update(
            f" {self._name}  |  t {speak}  |  q quit"
        )

    def _viewport_metrics(self) -> tuple[int, int, int]:
        container = self.query_one("#md-container", ScrollableContainer)
        width = max(8, container.size.width - 4)
        height = max(1, container.size.height - 1)
        y = int(round(float(container.scroll_y)))
        return y, height, width

    def _visible_text(self) -> str:
        y, height, width = self._viewport_metrics()
        return visible_slice(self._md, y, height, width)

    def _tts_stop(self) -> None:
        proc = self._tts_proc
        self._tts_proc = None
        if proc is None or proc.poll() is not None:
            return
        try:
            proc.terminate()
        except OSError:
            return
        try:
            proc.wait(timeout=0.4)
        except Exception:
            try:
                proc.kill()
            except OSError:
                pass

    def _tts_speak(self, text: str) -> None:
        self._tts_stop()
        if not self._tts_bin:
            return
        text = (text or "").strip()
        if not text:
            return
        try:
            proc = subprocess.Popen(
                [self._tts_bin, "-s", "MUSIC", "-r", f"{tts_rate():.2f}"],
                stdin=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except OSError:
            return
        assert proc.stdin is not None
        try:
            proc.stdin.write(text.encode("utf-8", errors="replace"))
            proc.stdin.close()
        except OSError:
            self._tts_proc = proc
            self._tts_stop()
            return
        self._tts_proc = proc

    def action_speak_visible(self) -> None:
        if not self._tts_bin:
            self.notify("termux-tts-speak not on PATH", severity="warning")
            return
        if self._tts_proc is not None and self._tts_proc.poll() is None:
            self._tts_stop()
            self.notify("TTS stopped", severity="information")
            return
        text = self._visible_text()
        if not text:
            self.notify("Nothing visible to speak", severity="warning")
            return
        self._tts_speak(text)
        self.notify(f"Speaking {len(text.splitlines())} visible lines", timeout=2)

    def action_scroll_down(self) -> None:
        self.query_one("#md-container").scroll_down()

    def action_scroll_up(self) -> None:
        self.query_one("#md-container").scroll_up()

    def action_page_down(self) -> None:
        self.query_one("#md-container").scroll_page_down()

    def action_page_up(self) -> None:
        self.query_one("#md-container").scroll_page_up()

    def action_scroll_home(self) -> None:
        self.query_one("#md-container").scroll_home()

    def action_scroll_end(self) -> None:
        self.query_one("#md-container").scroll_end()

    def action_leave(self) -> None:
        self._tts_stop()
        self.exit()

    def on_unmount(self) -> None:
        self._tts_stop()


def _visible_slice_unit() -> None:
    sample = "aaa\n" + ("b" * 20) + "\nccc"
    got = visible_slice(sample, 1, 1, 8)
    assert got == "bbbbbbbb", got
    assert visible_slice("hello", 0, 5, 80) == "hello"


def main(argv: list[str] | None = None) -> None:
    argv = list(sys.argv if argv is None else argv)
    parser = argparse.ArgumentParser(
        prog=os.path.basename(argv[0]) if argv else "md-glow",
        description="Glow-like markdown highlighter (Glamour dark). -p opens a Textual pager.",
    )
    parser.add_argument(
        "file",
        nargs="?",
        default="-",
        help="Markdown file, or - for stdin",
    )
    parser.add_argument(
        "-p",
        "--pager",
        action="store_true",
        help="Open in Textual pager (t = speak visible viewport)",
    )
    parser.add_argument(
        "-w",
        "--width",
        type=int,
        default=0,
        help="Wrap width for stdout (0 = terminal width)",
    )
    args = parser.parse_args(argv[1:])

    path = args.file
    if path not in ("-", "") and not path.startswith("/"):
        path = os.path.abspath(path)

    md, name = read_source(None if path in ("-", "") else path)
    if args.pager:
        GlowPager(md, name).run()
        return
    width = args.width if args.width > 0 else None
    print_glow(md, width)


if __name__ == "__main__":
    if os.environ.get("MD_GLOW_SELFTEST") == "1":
        _visible_slice_unit()
        print("selftest ok")
        sys.exit(0)
    main()
