#!/usr/bin/env python3
"""doc-view: Textual TUI viewer for PDF and EPUB (Rich formatting).

Usage:
    doc-view <file.pdf|file.epub>              # TUI viewer
    doc-view -m <file>                         # markdown to stdout
    doc-view -m -o out.md <file>               # markdown to file

Keys (TUI mode):
    j/Down     - scroll down        k/Up       - scroll up
    h/Left     - prev unit          l/Right    - next unit
    g          - first unit         G         - last unit
    /          - search             n         - next match
    q          - quit               Space     - page down
    b          - page up            t         - speak visible (again = stop)
"""
from __future__ import annotations

import argparse
import importlib
import os
import re
import shutil
import subprocess
import sys
from html import unescape
from html.parser import HTMLParser

CORE_PACKAGES = {
    "textual": "textual",
    "rich": "rich",
}


def ensure_core():
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

from rich.text import Text
from textual.app import App
from textual.binding import Binding
from textual.containers import ScrollableContainer
from textual.widgets import Footer, Header, Static

TTS_BIN_NAME = "termux-tts-speak"
TTS_DEFAULT_RATE = 1.5
TTS_RATE_ENV = "STUDY_FLASH_TTS_RATE"  # same knob as study-flash


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
    """Hard-wrap like a terminal cell grid (one row per wrapped fragment)."""
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
    """Rows currently in the viewport after wrap. Not the whole chapter."""
    rows = wrap_lines(text, width)
    y = max(0, int(scroll_y))
    h = max(1, int(height))
    chunk = rows[y : y + h]
    return "\n".join(chunk).strip()


def detect_kind(path: str, argv0: str = "") -> str:
    """pdf | epub from extension, then magic, then invocation name."""
    ext = os.path.splitext(path)[1].lower()
    if ext == ".pdf":
        return "pdf"
    if ext == ".epub":
        return "epub"
    try:
        with open(path, "rb") as f:
            head = f.read(8)
        if head.startswith(b"%PDF"):
            return "pdf"
        if head.startswith(b"PK"):
            return "epub"
    except OSError:
        pass
    name = os.path.basename(argv0).lower()
    if "epub" in name:
        return "epub"
    if "pdf" in name:
        return "pdf"
    print(f"Error: cannot detect type of {path} (use .pdf / .epub)", file=sys.stderr)
    sys.exit(1)


def _pip_import(pairs: list[tuple[str, str]], fatal: str):
    for import_name, pip_name in pairs:
        try:
            return importlib.import_module(import_name)
        except ImportError:
            pass
    for import_name, pip_name in pairs:
        try:
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", pip_name],
                stderr=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
            )
            return importlib.import_module(import_name)
        except (subprocess.CalledProcessError, ImportError):
            continue
    print(fatal, file=sys.stderr)
    sys.exit(1)


# --- PDF backend (pymupdf preferred; pdfminer.six on Termux) ---

class PDFDoc:
    def __init__(self, path: str):
        self.path = path
        self.kind = "pdf"
        self.unit = "Page"
        self._backend = None
        self._doc = None
        try:
            pymupdf = importlib.import_module("pymupdf")
            self._backend = "pymupdf"
            self._doc = pymupdf.open(path)
            self.page_count = self._doc.page_count
        except ImportError:
            try:
                from pdfminer.high_level import extract_text as _extract
                from pdfminer.pdfpage import PDFPage
            except ImportError:
                _pip_import(
                    [("pymupdf", "pymupdf"), ("pdfminer", "pdfminer.six")],
                    "[FATAL] Could not install pymupdf or pdfminer.six",
                )
                try:
                    pymupdf = importlib.import_module("pymupdf")
                    self._backend = "pymupdf"
                    self._doc = pymupdf.open(path)
                    self.page_count = self._doc.page_count
                except ImportError:
                    from pdfminer.high_level import extract_text as _extract
                    from pdfminer.pdfpage import PDFPage
                    self._backend = "pdfminer"
                    self._extract = _extract
                    with open(path, "rb") as f:
                        self.page_count = sum(1 for _ in PDFPage.get_pages(f))
            else:
                self._backend = "pdfminer"
                self._extract = _extract
                with open(path, "rb") as f:
                    self.page_count = sum(1 for _ in PDFPage.get_pages(f))
        self.book_title = os.path.splitext(os.path.basename(path))[0]

    def get_page_text(self, pno: int) -> str:
        if self._backend == "pymupdf":
            return self._doc[pno].get_text("text")
        return self._extract(self.path, page_numbers=[pno])

    def get_page_title(self, pno: int) -> str:
        return f"Page {pno + 1}"

    def close(self) -> None:
        if self._backend == "pymupdf" and self._doc:
            self._doc.close()
            self._doc = None


# --- EPUB backend ---

class _HTMLToText(HTMLParser):
    _BLOCK = {
        "p", "div", "section", "article", "header", "footer", "nav",
        "h1", "h2", "h3", "h4", "h5", "h6", "li", "tr", "blockquote",
        "pre", "figure", "figcaption", "aside", "main", "ul", "ol",
        "table", "thead", "tbody",
    }

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self._parts: list[str] = []
        self._skip = 0

    def handle_starttag(self, tag, attrs):
        tag = tag.lower()
        if tag in ("script", "style", "head"):
            self._skip += 1
            return
        if self._skip:
            return
        if tag in ("br", "hr"):
            self._parts.append("\n")
        elif tag in self._BLOCK:
            self._parts.append("\n")

    def handle_endtag(self, tag):
        tag = tag.lower()
        if tag in ("script", "style", "head") and self._skip:
            self._skip -= 1
            return
        if self._skip:
            return
        if tag in self._BLOCK:
            self._parts.append("\n")

    def handle_data(self, data):
        if not self._skip:
            self._parts.append(data)

    def text(self) -> str:
        raw = unescape("".join(self._parts)).replace("\xa0", " ")
        raw = re.sub(r"[ \t]+", " ", raw)
        raw = re.sub(r"\n[ \t]+", "\n", raw)
        raw = re.sub(r"[ \t]+\n", "\n", raw)
        raw = re.sub(r"\n{3,}", "\n\n", raw)
        return raw.strip()


def html_to_text(html: bytes | str) -> str:
    if isinstance(html, bytes):
        html = html.decode("utf-8", errors="replace")
    html = re.sub(r"<\?xml[^>]*\?>", "", html, flags=re.I)
    html = re.sub(r"<!DOCTYPE[^>]*>", "", html, flags=re.I)
    parser = _HTMLToText()
    try:
        parser.feed(html)
        parser.close()
    except Exception:
        return re.sub(r"<[^>]+>", "", html)
    return parser.text()


class EpubDoc:
    def __init__(self, path: str):
        self.path = path
        self.kind = "epub"
        self.unit = "Ch"
        _pip_import(
            [("ebooklib", "ebooklib")],
            "[FATAL] Could not install ebooklib",
        )
        import ebooklib
        from ebooklib import epub
        self._book = epub.read_epub(path)
        self._items: list[tuple[str, str]] = []
        titles = self._toc_titles()
        seen: set[str] = set()
        for item in self._book.get_items_of_type(ebooklib.ITEM_DOCUMENT):
            name = item.get_name()
            if name in seen:
                continue
            seen.add(name)
            text = html_to_text(item.get_content())
            if not text.strip():
                continue
            title = titles.get(name) or self._guess_title(text, name)
            self._items.append((title, text))
        self.page_count = len(self._items)
        self.book_title = self._meta_title()

    def _meta_title(self) -> str:
        try:
            vals = self._book.get_metadata("DC", "title")
            if vals:
                return str(vals[0][0])
        except Exception:
            pass
        return os.path.splitext(os.path.basename(self.path))[0]

    def _toc_titles(self) -> dict[str, str]:
        out: dict[str, str] = {}

        def walk(nodes):
            for node in nodes:
                if isinstance(node, tuple):
                    section, children = node
                    href = getattr(section, "href", "") or ""
                    title = getattr(section, "title", "") or ""
                    if href:
                        out[href.split("#", 1)[0]] = title
                    walk(children or [])
                else:
                    href = getattr(node, "href", "") or ""
                    title = getattr(node, "title", "") or ""
                    if href:
                        out[href.split("#", 1)[0]] = title

        try:
            walk(self._book.toc or [])
        except Exception:
            pass
        return out

    @staticmethod
    def _guess_title(text: str, name: str) -> str:
        for line in text.split("\n"):
            line = line.strip()
            if line:
                return line[:80]
        return os.path.basename(name)

    def get_page_text(self, pno: int) -> str:
        return self._items[pno][1]

    def get_page_title(self, pno: int) -> str:
        return self._items[pno][0]

    def close(self) -> None:
        self._book = None


def open_doc(path: str, kind: str):
    return PDFDoc(path) if kind == "pdf" else EpubDoc(path)


# Dracula (matches study-test / study-flash). Rich styles use hex, not $tokens.
_D = {
    "bg": "#282a36",
    "bg2": "#21222c",
    "sel": "#44475a",
    "fg": "#f8f8f2",
    "comment": "#6272a4",
    "cyan": "#8be9fd",
    "green": "#50fa7b",
    "orange": "#ffb86c",
    "pink": "#ff79c6",
    "purple": "#bd93f9",
    "red": "#ff5555",
    "yellow": "#f1fa8c",
}


class DocViewer(App):
    CSS = """
    Screen {
        background: #282a36;
        color: #f8f8f2;
    }
    Header {
        background: #21222c;
        color: #8be9fd;
        text-style: bold;
    }
    Footer {
        background: #21222c;
        color: #6272a4;
    }
    #doc-container {
        padding: 1 2;
        height: 1fr;
        width: 1fr;
        scrollbar-background: #282a36;
        scrollbar-color: #6272a4;
        scrollbar-color-hover: #bd93f9;
    }
    .doc-page {
        padding: 0 1;
        margin: 0 0 1 0;
        border: round #44475a;
        background: #21222c;
        color: #f8f8f2;
        height: auto;
    }
    .page-header {
        color: #8be9fd;
        text-style: bold;
        padding: 0 1 0 0;
    }
    #status {
        dock: bottom;
        height: 1;
        background: #21222c;
        color: #6272a4;
        padding: 0 1;
        border-top: tall #44475a;
    }
    """

    BINDINGS = [
        Binding("j", "scroll_down", "Down", show=False),
        Binding("k", "scroll_up", "Up", show=False),
        Binding("down", "scroll_down", "Down", show=False),
        Binding("up", "scroll_up", "Up", show=False),
        Binding("l", "next_page", "Next", show=False),
        Binding("right", "next_page", "Next", show=False),
        Binding("h", "prev_page", "Prev", show=False),
        Binding("left", "prev_page", "Prev", show=False),
        Binding("space", "page_down", "PgDn", show=False),
        Binding("b", "page_up", "PgUp", show=False),
        Binding("g", "first_page", "First", show=False),
        Binding("G", "last_page", "Last", show=False),
        Binding("/", "search", "Search", show=False),
        Binding("n", "next_match", "Next Match", show=False),
        Binding("t", "speak_visible", "Speak", show=True),
        Binding("q", "quit", "Quit", show=False),
    ]

    def __init__(self, path: str, kind: str):
        super().__init__()
        self.doc_path = path
        self.kind = kind
        self.doc = None
        self.current_page = 0
        self.total_pages = 0
        self.search_term = ""
        self.search_matches = []
        self.search_idx = 0
        self._page_plain = ""
        self._tts_bin = tts_binary()
        self._tts_proc: subprocess.Popen | None = None

    def compose(self):
        yield Header(show_clock=False)
        yield ScrollableContainer(id="doc-container")
        yield Static("", id="status")
        yield Footer()

    def on_mount(self) -> None:
        self.doc = open_doc(self.doc_path, self.kind)
        self.total_pages = self.doc.page_count
        label = "PDF" if self.kind == "pdf" else "EPUB"
        self.title = f"{label} View: {self.doc.book_title}"
        self.sub_title = f"{self.doc.unit} 1/{self.total_pages}"
        self.render_page()

    def render_page(self) -> None:
        container = self.query_one("#doc-container")
        container.remove_children()
        text = self.doc.get_page_text(self.current_page)
        self._page_plain = text
        self._tts_stop()
        rich_text = self._format_text(text)
        ch_title = self.doc.get_page_title(self.current_page)
        header_text = Text(
            f" {self.current_page + 1}/{self.total_pages}  {ch_title} ",
            style=f"bold {_D['cyan']}",
        )
        container.mount(Static(header_text, classes="page-header"))
        container.mount(Static(rich_text, classes="doc-page"))
        self.sub_title = f"{self.doc.unit} {self.current_page + 1}/{self.total_pages}"
        self._update_status()

    def _format_text(self, text: str) -> Text:
        lines = text.split("\n")
        result = Text()
        for line in lines:
            stripped = line.strip()
            if not stripped:
                result.append("\n")
                continue
            if re.match(r"^(Q\s*\d+|Question\s+\d+|#\d+)\s*[\.\):]", stripped, re.I):
                result.append(stripped + "\n", style=f"bold {_D['yellow']}")
            elif re.match(r"^[A-Z]\s*[\.\)]\s", stripped):
                result.append(stripped + "\n", style=_D["cyan"])
            elif re.match(r"^(Correct|Answer)\s*[:\-]", stripped, re.I):
                result.append(stripped + "\n", style=f"bold {_D['green']}")
            elif len(stripped) < 80 and stripped.isupper() and len(stripped) > 3:
                result.append(stripped + "\n", style=f"bold {_D['purple']}")
            elif "Correct Answer:" in stripped or "Answer:" in stripped:
                result.append(stripped + "\n", style=f"bold {_D['green']}")
            elif re.match(r"^https?://", stripped):
                result.append(stripped + "\n", style=f"{_D['cyan']} underline")
            elif self.search_term and self.search_term.lower() in stripped.lower():
                parts = re.split(
                    f"({re.escape(self.search_term)})",
                    stripped,
                    flags=re.IGNORECASE,
                )
                for part in parts:
                    if part.lower() == self.search_term.lower():
                        result.append(part, style=f"{_D['bg']} on {_D['yellow']}")
                    else:
                        result.append(part, style=_D["fg"])
                result.append("\n")
            else:
                result.append(stripped + "\n", style=_D["fg"])
        return result

    def _update_status(self) -> None:
        status = self.query_one("#status")
        ch = self.doc.get_page_title(self.current_page) if self.doc else ""
        info = (
            f" {os.path.basename(self.doc_path)}  |  "
            f"{self.current_page + 1}/{self.total_pages}  {ch}"
        )
        if self.search_term:
            if self.search_matches:
                info += (
                    f"  |  Search: '{self.search_term}' "
                    f"({self.search_idx + 1}/{len(self.search_matches)})"
                )
            else:
                info += f"  |  Search: '{self.search_term}' (no matches)"
        status.update(info)

    def _search_all(self, term: str) -> list:
        matches = []
        for pno in range(self.total_pages):
            page_text = self.doc.get_page_text(pno)
            for i, line in enumerate(page_text.split("\n")):
                if term.lower() in line.lower():
                    matches.append((pno, i))
        return matches

    def _viewport_metrics(self) -> tuple[int, int, int]:
        container = self.query_one("#doc-container", ScrollableContainer)
        # padding 1 2 + page border ~2
        width = max(8, container.size.width - 6)
        height = max(1, container.size.height - 2)
        y = int(round(float(container.scroll_y)))
        return y, height, width

    def _visible_text(self) -> str:
        y, height, width = self._viewport_metrics()
        return visible_slice(self._page_plain, y, height, width)

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

    def on_unmount(self) -> None:
        self._tts_stop()

    def action_scroll_down(self) -> None:
        self.query_one("#doc-container").scroll_down()

    def action_scroll_up(self) -> None:
        self.query_one("#doc-container").scroll_up()

    def action_page_down(self) -> None:
        self.query_one("#doc-container").scroll_page_down()

    def action_page_up(self) -> None:
        self.query_one("#doc-container").scroll_page_up()

    def action_next_page(self) -> None:
        if self.current_page < self.total_pages - 1:
            self.current_page += 1
            self.render_page()
            self.query_one("#doc-container").scroll_home(animate=False)

    def action_prev_page(self) -> None:
        if self.current_page > 0:
            self.current_page -= 1
            self.render_page()
            self.query_one("#doc-container").scroll_home(animate=False)

    def action_first_page(self) -> None:
        self.current_page = 0
        self.render_page()
        self.query_one("#doc-container").scroll_home(animate=False)

    def action_last_page(self) -> None:
        self.current_page = self.total_pages - 1
        self.render_page()
        self.query_one("#doc-container").scroll_home(animate=False)

    def action_search(self) -> None:
        from textual.containers import Vertical
        from textual.screen import ModalScreen
        from textual.widgets import Input, Label

        class SearchScreen(ModalScreen):
            CSS = """
            SearchScreen { align: center middle; background: #282a36 60%; }
            SearchScreen > Vertical {
                width: 60; height: auto; padding: 1 2;
                border: round #8be9fd; background: #21222c;
            }
            SearchScreen Label { margin-bottom: 1; color: #8be9fd; }
            SearchScreen Input {
                margin-top: 1;
                background: #282a36;
                color: #f8f8f2;
                border: tall #44475a;
            }
            SearchScreen Input:focus { border: tall #8be9fd; }
            """

            def compose(self):
                yield Vertical(
                    Label("Search (Enter to search, Esc to cancel):"),
                    Input(placeholder="Enter search term..."),
                )

            def on_input_submitted(self, event):
                self.dismiss(event.value)

        def on_result(value):
            if value and value.strip():
                self.search_term = value.strip()
                self.search_matches = self._search_all(self.search_term)
                self.search_idx = 0
                if self.search_matches:
                    self.current_page = self.search_matches[0][0]
                    self.render_page()
                self._update_status()

        self.push_screen(SearchScreen(), on_result)

    def action_next_match(self) -> None:
        if not self.search_matches:
            return
        self.search_idx = (self.search_idx + 1) % len(self.search_matches)
        self.current_page = self.search_matches[self.search_idx][0]
        self.render_page()

    def action_quit(self) -> None:
        if self.doc:
            self.doc.close()
        self._tts_stop()
        self.exit()


def _text_to_markdown(text: str) -> str:
    result = []
    for line in text.split("\n"):
        stripped = line.strip()
        if not stripped:
            result.append("")
            continue
        if re.match(r"^(Q\s*\d+|Question\s+\d+)\s*[\.\):]", stripped, re.I):
            result.append(f"### {stripped}")
        elif re.match(r"^[A-Z]\s*[\.\)]\s", stripped):
            result.append(f"- {stripped}")
        elif re.match(r"^(Correct|Answer)\s*[:\-]", stripped, re.I) or "Correct Answer:" in stripped:
            result.append(f"**{stripped}**")
        elif len(stripped) < 80 and stripped.isupper() and len(stripped) > 3:
            result.append(f"\n## {stripped}\n")
        elif re.match(r"^https?://", stripped):
            result.append(f"<{stripped}>")
        else:
            result.append(stripped)
    return "\n".join(result)


def convert_to_markdown(path: str, kind: str, output_path: str | None = None) -> None:
    doc = open_doc(path, kind)
    parts = [f"# {doc.book_title}\n"]
    for pno in range(doc.page_count):
        title = doc.get_page_title(pno)
        md = _text_to_markdown(doc.get_page_text(pno))
        parts.append(f"\n<!-- {doc.unit} {pno + 1} / {doc.page_count}: {title} -->\n")
        parts.append(md)
        if pno < doc.page_count - 1:
            parts.append("\n---\n")
    doc.close()
    output = "\n".join(parts).rstrip() + "\n"
    if output_path:
        with open(output_path, "w") as f:
            f.write(output)
        print(f"Written {len(output):,} bytes to {output_path}", file=sys.stderr)
    else:
        print(output, end="")


def main(argv: list[str] | None = None) -> None:
    argv = list(sys.argv if argv is None else argv)
    prog = os.path.basename(argv[0]) if argv else "doc-view"
    parser = argparse.ArgumentParser(
        prog=prog,
        description="TUI viewer for PDF/EPUB with Rich formatting, or markdown export.",
    )
    parser.add_argument("file", help="Path to PDF or EPUB")
    parser.add_argument("-m", "--markdown", action="store_true",
                        help="Output as markdown instead of launching TUI")
    parser.add_argument("-o", "--output", default=None,
                        help="Output file for markdown (default: stdout)")
    args = parser.parse_args(argv[1:])

    path = args.file
    if not path.startswith("/"):
        path = os.path.abspath(path)
    if not os.path.exists(path):
        print(f"Error: {path} not found", file=sys.stderr)
        sys.exit(1)

    kind = detect_kind(path, argv[0] if argv else prog)
    if args.markdown:
        convert_to_markdown(path, kind, args.output)
    else:
        DocViewer(path, kind).run()


if __name__ == "__main__":
    main()
