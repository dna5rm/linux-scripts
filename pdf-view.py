#!/usr/bin/env python3
"""pdf-view: A Textual TUI PDF viewer with Rich formatting.

Usage:
    pdf-view <file.pdf>              # TUI viewer
    pdf-view -m <file.pdf>           # output markdown to stdout
    pdf-view -m -o out.md <file.pdf> # output markdown to file
    pdf-view ~/Documents/document.pdf

Keys (TUI mode):
    j/Down     - scroll down        k/Up       - scroll up
    h/Left     - prev page          l/Right    - next page
    g          - first page         G         - last page
    /          - search             n         - next match
    q          - quit               Space     - page down
    b          - page up
"""
import sys
import re
import os
import argparse
import subprocess
import importlib

REQUIRED_PACKAGES = {
    "textual": "textual",
    "rich": "rich",
}
# pymupdf is preferred but fails to build on Termux (Android); pdfminer.six is the fallback.
PDF_PACKAGES = [
    ("pymupdf", "pymupdf"),
    ("pdfminer", "pdfminer.six"),
]


def ensure_dependencies():
    missing = []
    for import_name, pip_name in REQUIRED_PACKAGES.items():
        try:
            importlib.import_module(import_name)
        except ImportError:
            missing.append(pip_name)
    # Try pymupdf first; if it won't import or install, fall back to pdfminer.six
    pdf_ok = False
    for import_name, pip_name in PDF_PACKAGES:
        try:
            importlib.import_module(import_name)
            pdf_ok = True
            break
        except ImportError:
            pass
    if not pdf_ok:
        for import_name, pip_name in PDF_PACKAGES:
            try:
                subprocess.check_call([sys.executable, "-m", "pip", "install", pip_name],
                                     stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
                importlib.import_module(import_name)
                pdf_ok = True
                break
            except (subprocess.CalledProcessError, ImportError):
                continue
        if not pdf_ok:
            print("[FATAL] Could not install pymupdf or pdfminer.six")
            sys.exit(1)
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


ensure_dependencies()

# --- PDF backend abstraction: pymupdf (preferred) or pdfminer.six (fallback) ---
try:
    import pymupdf
    _PDF_BACKEND = "pymupdf"
except ImportError:
    from pdfminer.high_level import extract_text as _pdfminer_extract
    from pdfminer.pdfparser import PDFParser as _PDFParser
    from pdfminer.pdfdocument import PDFDocument as _PDFDocument
    from pdfminer.pdfpage import PDFPage as _PDFPage
    _PDF_BACKEND = "pdfminer"


class PDFDoc:
    """Thin wrapper: pymupdf if available, pdfminer.six as Termux fallback."""
    def __init__(self, path):
        self.path = path
        if _PDF_BACKEND == "pymupdf":
            self._doc = pymupdf.open(path)
            self.page_count = self._doc.page_count
        else:
            with open(path, "rb") as f:
                self.page_count = sum(1 for _ in _PDFPage.get_pages(f))

    def get_page_text(self, pno):
        if _PDF_BACKEND == "pymupdf":
            return self._doc[pno].get_text("text")
        else:
            return _pdfminer_extract(self.path, page_numbers=[pno])

    def close(self):
        if _PDF_BACKEND == "pymupdf" and self._doc:
            self._doc.close()

from rich.text import Text
from textual.app import App
from textual.containers import Container
from textual.widgets import Header, Footer, Static
from textual.binding import Binding


class PDFViewer(App):
    CSS = """
    Screen {
        background: $surface;
    }
    #pdf-container {
        padding: 1 2;
        height: 1fr;
        width: 1fr;
    }
    .pdf-page {
        padding: 0 1;
        margin: 0 0 1 0;
        border: round $primary;
        height: auto;
    }
    .page-header {
        color: $accent;
        text-style: bold;
        padding-bottom: 0;
    }
    .question-num {
        color: $warning;
        text-style: bold;
    }
    .answer-letter {
        color: $success;
        text-style: bold;
    }
    .correct {
        color: $success;
        text-style: bold;
        background: $boost;
    }
    .search-hit {
        background: $warning 30%;
        text-style: bold;
    }
    #status {
        dock: bottom;
        height: 1;
        background: $panel;
        color: $text;
        padding: 0 1;
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
        Binding("q", "quit", "Quit", show=False),
    ]

    def __init__(self, pdf_path: str):
        super().__init__()
        self.pdf_path = pdf_path
        self.doc = None
        self.current_page = 0
        self.total_pages = 0
        self.search_term = ""
        self.search_matches = []
        self.search_idx = 0

    def compose(self):
        yield Header(show_clock=False)
        yield Container(id="pdf-container")
        yield Static("", id="status")
        yield Footer()

    def on_mount(self) -> None:
        self.doc = PDFDoc(self.pdf_path)
        self.total_pages = self.doc.page_count
        self.title = f"PDF View: {self.pdf_path.split('/')[-1]}"
        self.sub_title = f"Page 1/{self.total_pages}"
        self.render_page()

    def render_page(self) -> None:
        container = self.query_one("#pdf-container")
        container.remove_children()

        text = self.doc.get_page_text(self.current_page)

        # Parse and format the text
        rich_text = self._format_text(text)

        page_widget = Static(rich_text, classes="pdf-page")
        header_text = Text(f" Page {self.current_page + 1} / {self.total_pages} ", style="bold cyan")
        header_widget = Static(header_text, classes="page-header")

        container.mount(header_widget)
        container.mount(page_widget)

        self.sub_title = f"Page {self.current_page + 1}/{self.total_pages}"
        self._update_status()

    def _format_text(self, text: str) -> Text:
        """Format raw PDF text with Q&A-aware coloring."""
        lines = text.split("\n")
        result = Text()

        for i, line in enumerate(lines):
            stripped = line.strip()
            if not stripped:
                result.append("\n")
                continue

            # Question number pattern: "Q 1." or "Question 1:" or "1."
            if re.match(r"^(Q\s*\d+|Question\s+\d+|#\d+)\s*[\.\):]", stripped, re.I):
                result.append(stripped + "\n", style="bold yellow")

            # Answer options: A. B. C. D. etc
            elif re.match(r"^[A-Z]\s*[\.\)]\s", stripped):
                result.append(stripped + "\n", style="green")

            # Correct answer markers
            elif re.match(r"^(Correct|Answer)\s*[:\-]", stripped, re.I):
                result.append(stripped + "\n", style="bold green on dark_green")

            # Section headers (all caps, short)
            elif len(stripped) < 80 and stripped.isupper() and len(stripped) > 3:
                result.append(stripped + "\n", style="bold magenta")

            # Lines with "Correct Answer:" inline
            elif "Correct Answer:" in stripped or "Answer:" in stripped:
                result.append(stripped + "\n", style="bold green")

            # URLs
            elif re.match(r"^https?://", stripped):
                result.append(stripped + "\n", style="blue underline")

            # Default
            else:
                # Highlight search term if active
                if self.search_term and self.search_term.lower() in stripped.lower():
                    parts = re.split(
                        f"({re.escape(self.search_term)})",
                        stripped,
                        flags=re.IGNORECASE,
                    )
                    for part in parts:
                        if part.lower() == self.search_term.lower():
                            result.append(part, style="black on yellow")
                        else:
                            result.append(part)
                    result.append("\n")
                else:
                    result.append(stripped + "\n")

        return result

    def _update_status(self) -> None:
        status = self.query_one("#status")
        info = f" {self.pdf_path.split('/')[-1]}  |  Page {self.current_page + 1}/{self.total_pages}"
        if self.search_term:
            if self.search_matches:
                info += f"  |  Search: '{self.search_term}' ({self.search_idx + 1}/{len(self.search_matches)})"
            else:
                info += f"  |  Search: '{self.search_term}' (no matches)"
        status.update(info)

    def _search_all(self, term: str) -> list:
        """Search all pages for term, return list of (page_num, line_num)."""
        matches = []
        for pno in range(self.total_pages):
            page_text = self.doc.get_page_text(pno)
            for i, line in enumerate(page_text.split("\n")):
                if term.lower() in line.lower():
                    matches.append((pno, i))
        return matches

    # --- Actions ---

    def action_scroll_down(self) -> None:
        container = self.query_one("#pdf-container")
        container.scroll_down()

    def action_scroll_up(self) -> None:
        container = self.query_one("#pdf-container")
        container.scroll_up()

    def action_page_down(self) -> None:
        container = self.query_one("#pdf-container")
        container.scroll_page_down()

    def action_page_up(self) -> None:
        container = self.query_one("#pdf-container")
        container.scroll_page_up()

    def action_next_page(self) -> None:
        if self.current_page < self.total_pages - 1:
            self.current_page += 1
            self.render_page()
            self.query_one("#pdf-container").scroll_home(animate=False)

    def action_prev_page(self) -> None:
        if self.current_page > 0:
            self.current_page -= 1
            self.render_page()
            self.query_one("#pdf-container").scroll_home(animate=False)

    def action_first_page(self) -> None:
        self.current_page = 0
        self.render_page()
        self.query_one("#pdf-container").scroll_home(animate=False)

    def action_last_page(self) -> None:
        self.current_page = self.total_pages - 1
        self.render_page()
        self.query_one("#pdf-container").scroll_home(animate=False)

    def action_search(self) -> None:
        from textual.widgets import Input, Label
        from textual.containers import Vertical
        from textual.screen import ModalScreen

        class SearchScreen(ModalScreen):
            CSS = """
            SearchScreen {
                align: center middle;
            }
            SearchScreen > Vertical {
                width: 60;
                height: auto;
                padding: 1 2;
                border: round $accent;
                background: $surface;
            }
            SearchScreen Label {
                margin-bottom: 1;
                color: $text;
            }
            SearchScreen Input {
                margin-top: 1;
            }
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
                    pno = self.search_matches[0][0]
                    self.current_page = pno
                    self.render_page()
                self._update_status()

        self.push_screen(SearchScreen(), on_result)

    def action_next_match(self) -> None:
        if not self.search_matches:
            return
        self.search_idx = (self.search_idx + 1) % len(self.search_matches)
        pno = self.search_matches[self.search_idx][0]
        self.current_page = pno
        self.render_page()

    def action_quit(self) -> None:
        if self.doc:
            self.doc.close()
        self.exit()


def _text_to_markdown(text: str) -> str:
    """Convert raw PDF text to markdown with Q&A-aware formatting."""
    lines = text.split("\n")
    result = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            result.append("")
            continue

        # Question number: "Q 1." / "Question 1:" / "#1."
        if re.match(r"^(Q\s*\d+|Question\s+\d+)\s*[\.\):]", stripped, re.I):
            result.append(f"### {stripped}")

        # Answer options: A. B. C. D.
        elif re.match(r"^[A-Z]\s*[\.\)]\s", stripped):
            result.append(f"- {stripped}")

        # Correct answer markers
        elif re.match(r"^(Correct|Answer)\s*[:\-]", stripped, re.I) or "Correct Answer:" in stripped:
            result.append(f"**{stripped}**")

        # Section headers (all caps, short)
        elif len(stripped) < 80 and stripped.isupper() and len(stripped) > 3:
            result.append(f"\n## {stripped}\n")

        # URLs
        elif re.match(r"^https?://", stripped):
            result.append(f"<{stripped}>")

        # Default
        else:
            result.append(stripped)

    return "\n".join(result)


def convert_to_markdown(pdf_path: str, output_path: str | None = None) -> None:
    """Extract all pages from PDF and output as markdown."""
    doc = PDFDoc(pdf_path)
    parts = []

    # Title from filename
    filename = os.path.basename(pdf_path).replace(".pdf", "")
    parts.append(f"# {filename}\n")

    for pno in range(doc.page_count):
        page_text = doc.get_page_text(pno)
        md = _text_to_markdown(page_text)
        parts.append(f"\n<!-- Page {pno + 1} / {doc.page_count} -->\n")
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


def main():
    parser = argparse.ArgumentParser(
        prog="pdf-view",
        description="TUI PDF viewer with Rich formatting, or markdown export.",
    )
    parser.add_argument("pdf", help="Path to PDF file")
    parser.add_argument("-m", "--markdown", action="store_true",
                        help="Output as markdown instead of launching TUI")
    parser.add_argument("-o", "--output", default=None,
                        help="Output file for markdown (default: stdout)")
    args = parser.parse_args()

    pdf_path = args.pdf
    if not pdf_path.startswith("/"):
        pdf_path = os.path.abspath(pdf_path)

    if not os.path.exists(pdf_path):
        print(f"Error: {pdf_path} not found", file=sys.stderr)
        sys.exit(1)

    if args.markdown:
        convert_to_markdown(pdf_path, args.output)
    else:
        app = PDFViewer(pdf_path)
        app.run()


if __name__ == "__main__":
    main()
