#!/usr/bin/env python3
"""
jira_tui.py - Textual TUI to review Jira issues assigned to you.

Env:
  JIRA_BASE_URL             e.g. https://yourorg.atlassian.net
  JIRA_EMAIL                your Atlassian account email
  JIRA_API_TOKEN            Atlassian API token
                            (https://id.atlassian.com/manage-profile/security/api-tokens)
  JIRA_CUSTOM_FIELD_FILTER  optional, comma-separated label substrings
                            (case-insensitive). If set, only "Additional Fields"
                            whose label contains one of these terms are shown.
                            e.g. "ITOps,Date,Completed"
                            If unset, all populated custom fields are shown.
  JIRA_DEFAULT_JQL          optional, overrides the default JQL query used on
                            startup. e.g. 'assignee = currentUser() AND
                            resolution = Unresolved ORDER BY "Priority (ITOps)"
                            ASC, status ASC, updated ASC'
                            If unset, defaults to:
                            "assignee = currentUser() AND resolution = Unresolved
                            ORDER BY updated DESC"

List screen keys:
  Enter  open ticket     j/k  down/up
  r      refresh         /    edit JQL
  q      quit

Detail screen keys:
  Esc    back to list
  o      open in browser
  t      transition status
  c      add comment
  q      quit
"""
from __future__ import annotations

import argparse
import asyncio
import importlib
import json
import os
import re
import shutil
import subprocess
import sys
import webbrowser
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

USAGE = """\
usage: jira_tui.py [options] [command ...]

Human TUI (no command) plus a CLI agents can call.

commands:
  list [--jql JQL] [--json]
  show KEY [--json]
  comment KEY (-m TEXT | -F FILE | stdin) [--dry-run]
  init KEY
  path KEY
  gitstatus KEY [--json]
  commit KEY [-m MSG]
  restore KEY
  undo-commit KEY
  gitlog KEY [-n N]

env: JIRA_BASE_URL JIRA_EMAIL JIRA_API_TOKEN
     JIRA_DEFAULT_JQL JIRA_CUSTOM_FIELD_FILTER JIRA_WORK_ROOT (default ~/Work)

TUI list: Enter open  w workdir  r refresh  / JQL  q quit
TUI detail: Esc back  o browser  t transition  c Jira-comment
            w workdir  f files  g git-commit  u restore
"""

if any(a in ("-h", "--help") for a in sys.argv[1:]) and not any(
    a in (
        "list", "show", "comment", "init", "path",
        "gitstatus", "commit", "restore", "undo-commit", "gitlog",
    )
    for a in sys.argv[1:]
):
    print(USAGE)
    sys.exit(0)

# --------------------------- Bootstrap: auto-install ---------------------------

CORE_PACKAGES = {
    "textual": "textual",
    "httpx": "httpx",
}


def _pip_install(pip_name: str) -> bool:
    attempts: list[list[str]] = []
    uv = shutil.which("uv")
    if uv:
        attempts.append([uv, "pip", "install", "--quiet", pip_name])
    base = [sys.executable, "-m", "pip", "install", "--disable-pip-version-check", "-q"]
    attempts.append(base + [pip_name])
    attempts.append(base + ["--user", pip_name])
    attempts.append(base + ["--break-system-packages", pip_name])
    for cmd in attempts:
        try:
            subprocess.check_call(cmd)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError, OSError):
            continue
    return False


def ensure_core() -> None:
    if os.environ.get("_JIRA_TUI_REEXEC") == "1":
        return

    missing = []
    for import_name, pip_name in CORE_PACKAGES.items():
        try:
            importlib.import_module(import_name)
        except ImportError:
            missing.append(pip_name)
    if not missing:
        return

    in_venv = sys.prefix != getattr(sys, "base_prefix", sys.prefix)
    print(f"[jira-tui] Missing required packages: {', '.join(missing)}")
    if not in_venv:
        print("[jira-tui] Not in a virtualenv - will try --user / uv / --break-system-packages.")

    failed = []
    for pip_name in missing:
        print(f"[jira-tui] Installing '{pip_name}'...")
        if not _pip_install(pip_name):
            failed.append(pip_name)

    if failed:
        print(f"[FATAL] Could not install: {', '.join(failed)}", file=sys.stderr)
        print("Try manually: pip install " + " ".join(failed), file=sys.stderr)
        sys.exit(1)

    print("[jira-tui] Install complete, restarting...")
    env = os.environ.copy()
    env["_JIRA_TUI_REEXEC"] = "1"
    os.execve(sys.executable, [sys.executable] + sys.argv, env)


ensure_core()

import httpx
from rich.text import Text
from textual import on, work
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Horizontal, Vertical, VerticalScroll
from textual.screen import ModalScreen, Screen
from textual.widgets import (
    DataTable,
    Footer,
    Header,
    Input,
    Label,
    ListItem,
    ListView,
    Markdown,
    Static,
    TextArea,
)


DEFAULT_JQL = "assignee = currentUser() AND resolution = Unresolved ORDER BY updated DESC"
SEARCH_FIELDS = [
    "summary",
    "status",
    "priority",
    "issuetype",
    "updated",
    "assignee",
    "reporter",
]
MAX_SEARCH_PAGES = 20

KNOWN_FIELD_KEYS = {
    "summary", "description", "status", "issuetype", "priority",
    "assignee", "reporter", "updated", "created", "comment",
    "project", "labels", "components", "fixVersions", "resolution",
}

_JIRA_WIKI_TAG_RE = re.compile(r"\{(color|panel|noformat|code)[^}]*\}", re.IGNORECASE)
_JIRA_MACRO_RE = re.compile(r"\[(CHART|GADGET)\]", re.IGNORECASE)

MAX_CUSTOM_FIELD_LEN = 200
HTTP_ERR_SNIP = 160


# --------------------------- Glamour "dark" palette ---------------------------
# Reference: https://github.com/charmbracelet/glamour/blob/master/styles/dark.json
GLAMOUR_DARK = {
    "bg":               "#1c1c1c",
    "bg_alt":           "#262626",
    "doc_fg":           "#C4C4C4",
    "muted":            "#9E9E9E",
    "h1_fg":            "#FFFFFF",
    "h1_bg":            "#5A56E0",
    "heading_fg":       "#00AAFF",
    "h6_fg":            "#5A56E0",
    "hr":               "#616161",
    "link":             "#4A9EE8",
    "link_text":        "#00AAFF",
    "code_fg":          "#FF5F87",
    "code_bg":          "#303030",
    "codeblock_border": "#616161",
    "codeblock_chroma": "#C4C4C4",
    "quote_fg":         "#9E9E9E",
    "quote_bar":        "#5A56E0",
    "accent":           "#00AAFF",
    "warn":             "#FFAF5F",
    "err":              "#FF5F87",
    "ok":               "#87D787",
}


# --------------------------- Jira client ---------------------------

@dataclass
class JiraConfig:
    base_url: str
    email: str
    token: str
    custom_field_filter: list[str]
    default_jql: str

    @classmethod
    def from_env(cls, jql_override: str | None = None) -> "JiraConfig":
        missing = [k for k in ("JIRA_BASE_URL", "JIRA_EMAIL", "JIRA_API_TOKEN") if not os.getenv(k)]
        if missing:
            sys.stderr.write(f"Missing env: {', '.join(missing)}\n")
            sys.stderr.write(
                "Set:\n"
                "  export JIRA_BASE_URL=https://yourorg.atlassian.net\n"
                "  export JIRA_EMAIL=you@example.com\n"
                "  export JIRA_API_TOKEN=...\n"
            )
            sys.exit(2)

        raw_filter = os.getenv("JIRA_CUSTOM_FIELD_FILTER", "")
        filters = [f.strip().lower() for f in raw_filter.split(",") if f.strip()]

        default_jql = (jql_override or "").strip() or os.getenv("JIRA_DEFAULT_JQL", "").strip() or DEFAULT_JQL

        return cls(
            base_url=os.environ["JIRA_BASE_URL"].rstrip("/"),
            email=os.environ["JIRA_EMAIL"],
            token=os.environ["JIRA_API_TOKEN"],
            custom_field_filter=filters,
            default_jql=default_jql,
        )


def http_err_msg(exc: httpx.HTTPError) -> str:
    if isinstance(exc, httpx.HTTPStatusError):
        code = exc.response.status_code
        if code in (401, 403):
            return f"HTTP {code}: auth failed (email/token or permissions)"
        text = ""
        try:
            data = exc.response.json()
            msgs = data.get("errorMessages") or []
            if isinstance(msgs, list) and msgs:
                text = "; ".join(str(m) for m in msgs[:3])
            elif data.get("errors"):
                text = ", ".join(f"{k}: {v}" for k, v in list(data["errors"].items())[:4])
        except Exception:
            text = (exc.response.text or "")[:HTTP_ERR_SNIP]
        text = re.sub(r"\s+", " ", text).strip()[:HTTP_ERR_SNIP]
        return f"HTTP {code}" + (f": {text}" if text else "")
    return f"Network error: {exc}"


def text_to_adf(body_text: str) -> dict[str, Any]:
    paragraphs = body_text.replace("\r\n", "\n").split("\n\n")
    content: list[dict[str, Any]] = []
    for para in paragraphs:
        nodes: list[dict[str, Any]] = []
        parts = para.split("\n")
        for i, line in enumerate(parts):
            if line:
                nodes.append({"type": "text", "text": line})
            if i < len(parts) - 1:
                nodes.append({"type": "hardBreak"})
        if not nodes:
            nodes = [{"type": "text", "text": " "}]
        content.append({"type": "paragraph", "content": nodes})
    if not content:
        content = [{"type": "paragraph", "content": [{"type": "text", "text": " "}]}]
    return {"type": "doc", "version": 1, "content": content}


class JiraClient:
    def __init__(self, cfg: JiraConfig) -> None:
        self.cfg = cfg
        self._client = httpx.AsyncClient(
            base_url=cfg.base_url,
            auth=(cfg.email, cfg.token),
            headers={"Accept": "application/json", "Content-Type": "application/json"},
            timeout=20.0,
            verify=True,
        )

    async def aclose(self) -> None:
        await self._client.aclose()

    async def search(self, jql: str, max_results: int = 100) -> list[dict[str, Any]]:
        issues: list[dict[str, Any]] = []
        token: str | None = None
        for _ in range(MAX_SEARCH_PAGES):
            payload: dict[str, Any] = {
                "jql": jql,
                "maxResults": max_results,
                "fields": SEARCH_FIELDS,
            }
            if token:
                payload["nextPageToken"] = token
            r = await self._client.post("/rest/api/3/search/jql", json=payload)
            r.raise_for_status()
            data = r.json()
            issues.extend(data.get("issues") or [])
            token = data.get("nextPageToken") or None
            if not token:
                break
        return issues

    async def issue(self, key: str) -> dict[str, Any]:
        params = {"fields": "*all", "expand": "names"}
        r = await self._client.get(f"/rest/api/3/issue/{key}", params=params)
        r.raise_for_status()
        return r.json()

    async def comments(self, key: str) -> list[dict[str, Any]]:
        r = await self._client.get(
            f"/rest/api/3/issue/{key}/comment",
            params={"orderBy": "created", "maxResults": 100},
        )
        r.raise_for_status()
        return r.json().get("comments", [])

    async def transitions(self, key: str) -> list[dict[str, Any]]:
        r = await self._client.get(
            f"/rest/api/3/issue/{key}/transitions",
            params={"expand": "transitions.fields"},
        )
        r.raise_for_status()
        return r.json().get("transitions", [])

    async def do_transition(
        self,
        key: str,
        transition_id: str,
        fields: dict[str, Any] | None = None,
    ) -> None:
        body: dict[str, Any] = {"transition": {"id": transition_id}}
        if fields:
            body["fields"] = fields
        r = await self._client.post(f"/rest/api/3/issue/{key}/transitions", json=body)
        r.raise_for_status()
        audit_event("jira_transition", key, transition_id=str(transition_id))

    async def add_comment(self, key: str, body_text: str) -> None:
        r = await self._client.post(
            f"/rest/api/3/issue/{key}/comment",
            json={"body": text_to_adf(body_text)},
        )
        r.raise_for_status()
        audit_event("jira_comment", key, chars=len(body_text))


# --------------------------- Work folders + git ---------------------------

KEY_RE = re.compile(r"^[A-Za-z][A-Za-z0-9]+-\d+$")
SCAFFOLD_DIRS = (
    "notes", "comms", "change", "configs", "diagrams", "evidence", "scripts", "vendor",
)
GITIGNORE_BODY = """\
*.pcap
*.pcapng
*.kdbx
*.pem
*.key
*secret*
*password*
.env
.DS_Store
"""
DENY_RE = re.compile(
    r"(?i)(\.(pcap|pcapng|kdbx|pem|key)$|secret|password|(^|/)\.env$)",
)
SECRET_LINE_RE = re.compile(
    r"(?i)(enable secret|enable password|password\s+7\s+|snmp-server community|"
    r"tacacs.*key|radius-server key|private[_-]?key|api[_-]?token\s*[:=]|"
    r"BEGIN (RSA |OPENSSH |EC |CERTIFICATE)|aws_secret_access_key)",
)


def audit_event(action: str, key: str, **extra: Any) -> None:
    """Append-only local accountability log. No tokens, no comment bodies."""
    log_dir = Path.home() / ".local" / "state" / "jira-tui"
    try:
        log_dir.mkdir(parents=True, exist_ok=True)
        os.chmod(log_dir, 0o700)
        rec = {
            "ts": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "user": os.environ.get("USER", ""),
            "action": action,
            "key": key,
        }
        for k, v in extra.items():
            if k in ("token", "password", "body", "message"):
                continue
            rec[k] = v
        path = log_dir / "audit.jsonl"
        with path.open("a", encoding="utf-8") as fh:
            fh.write(json.dumps(rec, separators=(",", ":")) + "\n")
        os.chmod(path, 0o600)
    except OSError:
        pass


def work_root() -> Path:
    raw = os.environ.get("JIRA_WORK_ROOT", "").strip()
    return Path(raw).expanduser() if raw else Path.home() / "Work"


def normalize_key(key: str) -> str:
    k = (key or "").strip()
    if not KEY_RE.match(k):
        raise ValueError(f"bad issue key: {key!r}")
    proj, num = k.rsplit("-", 1)
    return f"{proj.upper()}-{num}"


def slugify(summary: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", (summary or "").lower()).strip("-")
    s = re.sub(r"-{2,}", "-", s)
    return s[:60].rstrip("-") or "work"


def _git(dirpath: Path, *args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(dirpath), *args],
        check=check,
        capture_output=True,
        text=True,
    )


def find_workdir(key: str) -> Path | None:
    key = normalize_key(key)
    root = work_root()
    if not root.is_dir():
        return None
    cands: list[Path] = []
    for p in root.iterdir():
        if not p.is_dir():
            continue
        if p.name == key or p.name.startswith(key + "-"):
            cands.append(p)
    if not cands:
        return None

    def score(p: Path) -> tuple[int, int, float]:
        has_meta = 1 if (p / ".jira.json").is_file() else 0
        has_git = 1 if (p / ".git").exists() else 0
        return (has_meta, has_git, p.stat().st_mtime)

    cands.sort(key=score, reverse=True)
    return cands[0]


def gitstatus_data(key: str) -> dict[str, Any]:
    path = find_workdir(key)
    if path is None:
        raise FileNotFoundError("no workdir; run init first")
    if not (path / ".git").exists():
        raise FileNotFoundError("not a git ticket folder")
    st = _git(path, "status", "--porcelain=v1")
    br = _git(path, "rev-parse", "--abbrev-ref", "HEAD")
    files: list[dict[str, str]] = []
    for line in st.stdout.splitlines():
        if len(line) < 4:
            continue
        code = line[:2].strip() or line[:2]
        rel = line[3:]
        if rel.startswith('"') and rel.endswith('"'):
            rel = rel[1:-1]
        files.append({"status": code, "path": rel})
    return {
        "key": normalize_key(key),
        "path": str(path),
        "branch": br.stdout.strip(),
        "dirty": bool(files),
        "files": files,
    }


def _denied_paths(files: list[dict[str, str]]) -> list[str]:
    return [f["path"] for f in files if DENY_RE.search(f["path"])]


def _secret_hits(workdir: Path, files: list[dict[str, str]]) -> list[str]:
    hits: list[str] = []
    for f in files:
        if "D" in (f.get("status") or ""):
            continue
        rel = f["path"]
        p = workdir / rel
        if not p.is_file() or p.stat().st_size > 2_000_000:
            continue
        try:
            text = p.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        if SECRET_LINE_RE.search(text):
            hits.append(rel)
    return hits


def ensure_local_git_identity(dirpath: Path) -> None:
    # Local-only identity. Do not stamp work email into every commit (D2/D5).
    name = _git(dirpath, "config", "user.name", check=False)
    email = _git(dirpath, "config", "user.email", check=False)
    if not (name.stdout or "").strip():
        _git(dirpath, "config", "user.name", "jira-tui")
    if not (email.stdout or "").strip():
        _git(dirpath, "config", "user.email", "jira-tui@localhost")


def git_commit_all(key: str, message: str) -> None:
    path = find_workdir(key)
    if path is None or not (path / ".git").exists():
        raise FileNotFoundError("no git workdir")
    data = gitstatus_data(key)
    denied = _denied_paths(data["files"])
    if denied:
        raise PermissionError("refusing to commit (filename): " + ", ".join(denied))
    secrets = _secret_hits(path, data["files"])
    if secrets:
        raise PermissionError("refusing to commit (secret-like content): " + ", ".join(secrets))
    if not data["dirty"]:
        raise RuntimeError("nothing to commit")
    ensure_local_git_identity(path)
    _git(path, "add", "-A")
    _git(path, "commit", "-m", message)
    audit_event("git_commit", key, path=str(path))


def git_restore(key: str) -> None:
    path = find_workdir(key)
    if path is None or not (path / ".git").exists():
        raise FileNotFoundError("no git workdir")
    _git(path, "restore", "--worktree", "--staged", ".")
    audit_event("git_restore", key, path=str(path))


def git_undo_commit(key: str) -> None:
    path = find_workdir(key)
    if path is None or not (path / ".git").exists():
        raise FileNotFoundError("no git workdir")
    count = _git(path, "rev-list", "--count", "HEAD")
    n = int((count.stdout or "0").strip() or "0")
    if n <= 1:
        raise RuntimeError("refusing to undo the init commit")
    _git(path, "reset", "--soft", "HEAD~1")
    audit_event("git_undo_commit", key)


def git_log_text(key: str, n: int = 10) -> str:
    path = find_workdir(key)
    if path is None or not (path / ".git").exists():
        raise FileNotFoundError("no git workdir")
    r = _git(path, "log", f"-n{n}", "--oneline")
    return r.stdout.strip() or "(no commits)"


def create_workdir(key: str, summary: str, base_url: str, issue_id: str | None = None) -> Path:
    key = normalize_key(key)
    existing = find_workdir(key)
    if existing is not None:
        return existing
    root = work_root()
    root.mkdir(parents=True, exist_ok=True)
    dirname = f"{key}-{slugify(summary)}"
    dest = root / dirname
    if dest.exists():
        return dest
    dest.mkdir(parents=False)
    os.chmod(dest, 0o700)
    for d in SCAFFOLD_DIRS:
        sub = dest / d
        sub.mkdir()
        os.chmod(sub, 0o700)
        (sub / ".gitkeep").write_text("", encoding="utf-8")
    meta = {
        "schema": 1,
        "key": key,
        "url": f"{base_url.rstrip('/')}/browse/{key}",
        "issue_id": issue_id,
        "created_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "summary": summary,
        "classification": "company-confidential",
    }
    meta_path = dest / ".jira.json"
    meta_path.write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    os.chmod(meta_path, 0o600)
    (dest / ".gitignore").write_text(GITIGNORE_BODY, encoding="utf-8")
    readme = (
        f"# {key}\n\n"
        f"- **Summary:** {summary}\n"
        f"- **URL:** {meta['url']}\n"
        f"- **Created:** {meta['created_utc']}\n"
        f"- **Classification:** company confidential. No credentials, keys, or pcaps in this tree.\n\n"
        "Local working tree. Jira remains source of truth for status.\n"
    )
    (dest / "README.md").write_text(readme, encoding="utf-8")
    _git(dest, "init")
    ensure_local_git_identity(dest)
    _git(dest, "add", "-A")
    _git(dest, "commit", "-m", f"{key}: init")
    audit_event("workdir_init", key, path=str(dest))
    return dest


# --------------------------- ADF -> text ---------------------------

def _is_all_code_paragraph(content: list) -> bool:
    """True if every text node in this paragraph carries a 'code' mark."""
    text_nodes = [n for n in content if isinstance(n, dict) and n.get("type") == "text"]
    if not text_nodes:
        return False
    return all(
        any(m.get("type") == "code" for m in (n.get("marks") or []))
        for n in text_nodes
    )


def _extract_code_paragraph_lines(content: list) -> list[str]:
    lines: list[str] = []
    current: list[str] = []
    for n in content:
        if not isinstance(n, dict):
            continue
        t = n.get("type")
        if t == "text":
            current.append(n.get("text", ""))
        elif t == "hardBreak":
            lines.append("".join(current))
            current = []
    lines.append("".join(current))
    return lines


def adf_to_text(node: Any) -> str:
    """Best-effort ADF (Atlassian Document Format) to plain markdown-ish text."""
    if node is None:
        return ""
    if isinstance(node, str):
        return node
    if isinstance(node, list):
        return "".join(adf_to_text(n) for n in node)
    if not isinstance(node, dict):
        return ""

    ntype = node.get("type", "")
    content = node.get("content", [])

    if ntype == "text":
        text = node.get("text", "")
        for mark in node.get("marks", []) or []:
            mt = mark.get("type")
            if mt == "code":
                text = f"`{text}`"
            elif mt == "strong":
                text = f"**{text}**"
            elif mt == "em":
                text = f"*{text}*"
            elif mt == "link":
                href = mark.get("attrs", {}).get("href", "")
                text = f"[{text}]({href})"
        return text
    if ntype == "paragraph":
        if _is_all_code_paragraph(content):
            code_lines = _extract_code_paragraph_lines(content)
            return "```\n" + "\n".join(code_lines) + "\n```\n\n"
        return adf_to_text(content) + "\n\n"
    if ntype == "hardBreak":
        return "  \n"
    if ntype in ("bulletList", "orderedList"):
        lines = []
        for i, item in enumerate(content, 1):
            prefix = "- " if ntype == "bulletList" else f"{i}. "
            lines.append(prefix + adf_to_text(item).strip())
        return "\n".join(lines) + "\n\n"
    if ntype == "listItem":
        return adf_to_text(content).strip()
    if ntype == "heading":
        level = node.get("attrs", {}).get("level", 1)
        return "#" * level + " " + adf_to_text(content).strip() + "\n\n"
    if ntype == "codeBlock":
        lang = node.get("attrs", {}).get("language", "") or ""
        return f"```{lang}\n{adf_to_text(content)}\n```\n\n"
    if ntype == "blockquote":
        inner = adf_to_text(content).strip().splitlines()
        return "\n".join(f"> {ln}" for ln in inner) + "\n\n"
    if ntype == "rule":
        return "\n---\n\n"
    if ntype == "mention":
        raw = node.get("attrs", {}).get("text", "user")
        name = raw.lstrip("@").strip()
        return f"`@{name}`"
    if ntype == "inlineCard":
        return node.get("attrs", {}).get("url", "")
    if ntype == "emoji":
        attrs = node.get("attrs") or {}
        return attrs.get("text") or attrs.get("shortName") or ""
    if ntype == "mediaSingle" or ntype == "mediaGroup":
        return adf_to_text(content)
    if ntype == "media":
        attrs = node.get("attrs") or {}
        alt = attrs.get("alt") or attrs.get("id") or "media"
        return f"[media:{alt}]"
    if ntype == "table":
        return adf_to_text(content) + "\n"
    if ntype == "tableRow":
        cells = [adf_to_text(c).strip().replace("\n", " ") for c in content]
        return "| " + " | ".join(cells) + " |\n"
    if ntype in ("tableCell", "tableHeader"):
        return adf_to_text(content)
    return adf_to_text(content)


def _strip_jira_wiki_markup(text: str) -> str:
    text = _JIRA_WIKI_TAG_RE.sub("", text)
    text = _JIRA_MACRO_RE.sub("", text)
    return re.sub(r"\s+", " ", text).strip()


def format_custom_field_value(value: Any) -> str | None:
    """Best-effort stringify of a customfield value. Returns None if empty."""
    if value is None:
        return None
    if isinstance(value, bool):
        return "Yes" if value else "No"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, str):
        cleaned = _strip_jira_wiki_markup(value)
        return cleaned or None
    if isinstance(value, dict):
        if value.get("type") == "doc" or "content" in value and value.get("version") == 1:
            text = adf_to_text(value).strip()
            return text or None
        for key in ("displayName", "name", "value", "key", "emailAddress"):
            if key in value and value[key]:
                return str(value[key])
        return None
    if isinstance(value, list):
        parts = [format_custom_field_value(v) for v in value]
        parts = [p for p in parts if p]
        return ", ".join(parts) if parts else None
    return str(value)


def build_custom_fields(
    issue: dict[str, Any], label_filter: list[str] | None = None
) -> list[tuple[str, str]]:
    names = issue.get("names", {}) or {}
    fields = issue.get("fields", {}) or {}
    out: list[tuple[str, str]] = []
    for key, value in fields.items():
        if key in KNOWN_FIELD_KEYS or not key.startswith("customfield_"):
            continue
        text = format_custom_field_value(value)
        if not text:
            continue
        if len(text) > MAX_CUSTOM_FIELD_LEN:
            text = text[:MAX_CUSTOM_FIELD_LEN].rstrip() + "..."
        label = names.get(key, key)

        if label_filter:
            label_lower = label.lower()
            if not any(term in label_lower for term in label_filter):
                continue

        out.append((label, text))
    out.sort(key=lambda kv: kv[0].lower())
    return out


def required_transition_fields(transition: dict[str, Any]) -> list[tuple[str, dict[str, Any]]]:
    fields = transition.get("fields") or {}
    out: list[tuple[str, dict[str, Any]]] = []
    for fid, meta in fields.items():
        if not isinstance(meta, dict):
            continue
        if meta.get("required"):
            out.append((fid, meta))
    return out


def coerce_transition_field(fid: str, meta: dict[str, Any], raw: str) -> Any:
    raw = raw.strip()
    schema = (meta.get("schema") or {})
    stype = schema.get("type") or ""
    if stype == "number":
        try:
            return float(raw) if "." in raw else int(raw)
        except ValueError:
            return raw
    if stype in ("option", "priority", "resolution", "issuetype", "status"):
        return {"name": raw} if raw else None
    if stype == "user":
        if "@" in raw:
            return {"emailAddress": raw}
        return {"name": raw}
    if stype == "array":
        parts = [p.strip() for p in raw.split(",") if p.strip()]
        item = (schema.get("items") or "")
        if item in ("option", "component", "version"):
            return [{"name": p} for p in parts]
        if item == "string":
            return parts
        return [{"name": p} for p in parts]
    if stype == "string" or fid in ("comment",):
        return raw
    if stype == "date":
        return raw
    if stype == "datetime":
        return raw
    return raw


# --------------------------- Glamour-styled CSS ---------------------------

APP_CSS = f"""
Screen {{
    background: {GLAMOUR_DARK["bg"]};
    color: {GLAMOUR_DARK["doc_fg"]};
}}

Header {{
    background: {GLAMOUR_DARK["bg_alt"]};
    color: {GLAMOUR_DARK["accent"]};
    text-style: bold;
}}

Footer {{
    background: {GLAMOUR_DARK["bg_alt"]};
    color: {GLAMOUR_DARK["muted"]};
}}

#jql-bar {{
    height: 1;
    background: {GLAMOUR_DARK["bg_alt"]};
    color: {GLAMOUR_DARK["muted"]};
    padding: 0 1;
}}

.status-bar {{
    height: 1;
    background: {GLAMOUR_DARK["bg_alt"]};
    color: {GLAMOUR_DARK["muted"]};
    padding: 0 1;
}}

#list-table {{
    height: 1fr;
    background: {GLAMOUR_DARK["bg"]};
    color: {GLAMOUR_DARK["doc_fg"]};
}}

DataTable > .datatable--header {{
    background: {GLAMOUR_DARK["h1_bg"]};
    color: {GLAMOUR_DARK["h1_fg"]};
    text-style: bold;
}}

DataTable > .datatable--cursor {{
    background: {GLAMOUR_DARK["h1_bg"]};
    color: {GLAMOUR_DARK["h1_fg"]};
}}

DataTable > .datatable--hover {{
    background: {GLAMOUR_DARK["code_bg"]};
}}

DataTable > .datatable--odd-row {{
    background: {GLAMOUR_DARK["bg"]};
}}

DataTable > .datatable--even-row {{
    background: {GLAMOUR_DARK["bg_alt"]};
}}

#detail-main {{
    height: 1fr;
}}

#detail-body {{
    width: 70%;
    background: {GLAMOUR_DARK["bg"]};
    border-right: round {GLAMOUR_DARK["codeblock_border"]};
    padding: 0 1;
}}

#detail-meta {{
    width: 30%;
    background: {GLAMOUR_DARK["bg"]};
    padding: 0 1;
}}

Markdown {{
    background: {GLAMOUR_DARK["bg"]};
    color: {GLAMOUR_DARK["doc_fg"]};
    margin: 0;
    padding: 1 1;
}}

Markdown .em    {{ text-style: italic; }}
Markdown .strong {{ text-style: bold; }}
Markdown .s     {{ text-style: strike; }}
Markdown .code_inline {{
    color: {GLAMOUR_DARK["code_fg"]};
    background: {GLAMOUR_DARK["code_bg"]};
}}

MarkdownFence {{
    background: {GLAMOUR_DARK["code_bg"]};
    color: {GLAMOUR_DARK["codeblock_chroma"]};
    border: round {GLAMOUR_DARK["codeblock_border"]};
    margin: 1 0;
    padding: 0 1;
}}

MarkdownH1 {{
    color: {GLAMOUR_DARK["h1_fg"]};
    background: {GLAMOUR_DARK["h1_bg"]};
    text-style: bold;
    width: auto;
    padding: 0 1;
    margin: 1 0;
}}

MarkdownH2, MarkdownH3, MarkdownH4, MarkdownH5 {{
    color: {GLAMOUR_DARK["heading_fg"]};
    text-style: bold;
    margin: 1 0 0 0;
}}

MarkdownH6 {{
    color: {GLAMOUR_DARK["h6_fg"]};
}}

MarkdownBlockQuote {{
    color: {GLAMOUR_DARK["quote_fg"]};
    text-style: italic;
    border-left: thick {GLAMOUR_DARK["quote_bar"]};
    padding-left: 1;
}}

MarkdownHR {{
    color: {GLAMOUR_DARK["hr"]};
}}

MarkdownBullet {{
    color: {GLAMOUR_DARK["heading_fg"]};
}}

ModalScreen {{
    align: center middle;
}}

#modal-box {{
    width: 80%;
    height: 60%;
    background: {GLAMOUR_DARK["bg_alt"]};
    border: round {GLAMOUR_DARK["h1_bg"]};
    padding: 1 2;
}}

#modal-box Label {{
    color: {GLAMOUR_DARK["accent"]};
    text-style: bold;
    margin-bottom: 1;
}}

ListView {{
    background: {GLAMOUR_DARK["bg"]};
}}

ListItem {{
    background: {GLAMOUR_DARK["bg"]};
    color: {GLAMOUR_DARK["doc_fg"]};
}}

ListView > ListItem.--highlight {{
    background: {GLAMOUR_DARK["h1_bg"]};
    color: {GLAMOUR_DARK["h1_fg"]};
}}

Input {{
    background: {GLAMOUR_DARK["code_bg"]};
    color: {GLAMOUR_DARK["doc_fg"]};
    border: round {GLAMOUR_DARK["codeblock_border"]};
}}

Input:focus {{
    border: round {GLAMOUR_DARK["accent"]};
}}

TextArea {{
    background: {GLAMOUR_DARK["code_bg"]};
    color: {GLAMOUR_DARK["doc_fg"]};
    border: round {GLAMOUR_DARK["codeblock_border"]};
}}

TextArea:focus {{
    border: round {GLAMOUR_DARK["accent"]};
}}
"""


# --------------------------- Modals ---------------------------

class CommentModal(ModalScreen[str | None]):
    BINDINGS = [
        Binding("ctrl+s", "submit", "Submit"),
        Binding("escape", "cancel", "Cancel"),
    ]

    def compose(self) -> ComposeResult:
        with Vertical(id="modal-box"):
            yield Label("Add comment (Ctrl+S submit, Esc cancel)")
            yield TextArea(id="comment-body", language="markdown")

    def action_submit(self) -> None:
        ta = self.query_one("#comment-body", TextArea)
        text = ta.text.strip()
        self.dismiss(text or None)

    def action_cancel(self) -> None:
        self.dismiss(None)


@dataclass
class TransitionChoice:
    transition_id: str
    fields: dict[str, Any] = field(default_factory=dict)


class TransitionFieldsModal(ModalScreen[TransitionChoice | None]):
    BINDINGS = [
        Binding("ctrl+s", "submit", "Submit"),
        Binding("escape", "cancel", "Cancel"),
    ]

    def __init__(self, transition: dict[str, Any], required: list[tuple[str, dict[str, Any]]]) -> None:
        super().__init__()
        self.transition = transition
        self.required = required

    def compose(self) -> ComposeResult:
        name = self.transition.get("name", "?")
        with Vertical(id="modal-box"):
            yield Label(f"Required fields for '{name}' (Ctrl+S submit, Esc cancel)")
            with VerticalScroll():
                for fid, meta in self.required:
                    label = meta.get("name") or fid
                    hint = ""
                    allowed = meta.get("allowedValues") or []
                    if allowed:
                        names = [str(v.get("name") or v.get("value") or "") for v in allowed[:8] if isinstance(v, dict)]
                        names = [n for n in names if n]
                        if names:
                            hint = "  [" + ", ".join(names) + "]"
                    yield Label(f"{label}{hint}")
                    yield Input(placeholder=fid, id=f"tf-{fid}")

    def action_submit(self) -> None:
        fields: dict[str, Any] = {}
        for fid, meta in self.required:
            raw = self.query_one(f"#tf-{fid}", Input).value
            if not raw.strip():
                self.dismiss(None)
                return
            fields[fid] = coerce_transition_field(fid, meta, raw)
        self.dismiss(TransitionChoice(str(self.transition["id"]), fields))

    def action_cancel(self) -> None:
        self.dismiss(None)


class TransitionModal(ModalScreen[TransitionChoice | None]):
    BINDINGS = [Binding("escape", "cancel", "Cancel")]

    def __init__(self, transitions: list[dict[str, Any]]) -> None:
        super().__init__()
        self.transitions = transitions
        self._by_id: dict[str, dict[str, Any]] = {}

    def compose(self) -> ComposeResult:
        with Vertical(id="modal-box"):
            yield Label("Select transition (Enter to apply, Esc to cancel)")
            yield ListView(id="trans-list")

    def on_mount(self) -> None:
        lv = self.query_one("#trans-list", ListView)
        for t in self.transitions:
            tid = str(t["id"])
            self._by_id[tid] = t
            name = t.get("name", "?")
            to = t.get("to", {}).get("name", "?")
            req = required_transition_fields(t)
            extra = f"  ({len(req)} required)" if req else ""
            item = ListItem(Label(f"{name}  ->  {to}{extra}"), id=f"t-{tid}")
            lv.append(item)
        lv.focus()

    def on_list_view_selected(self, event: ListView.Selected) -> None:
        item_id = event.item.id or ""
        tid = item_id[2:] if item_id.startswith("t-") else ""
        trans = self._by_id.get(tid)
        if not trans:
            self.dismiss(None)
            return
        req = required_transition_fields(trans)
        if not req:
            self.dismiss(TransitionChoice(tid))
            return

        def after_fields(choice: TransitionChoice | None) -> None:
            self.dismiss(choice)

        self.app.push_screen(TransitionFieldsModal(trans, req), after_fields)

    def action_cancel(self) -> None:
        self.dismiss(None)


class JQLModal(ModalScreen[str | None]):
    BINDINGS = [Binding("escape", "cancel", "Cancel")]

    def __init__(self, current: str) -> None:
        super().__init__()
        self.current = current

    def compose(self) -> ComposeResult:
        with Vertical(id="modal-box"):
            yield Label("Edit JQL (Enter to apply, Esc to cancel)")
            yield Input(value=self.current, id="jql-input")

    def on_input_submitted(self, event: Input.Submitted) -> None:
        self.dismiss(event.value.strip() or None)

    def action_cancel(self) -> None:
        self.dismiss(None)


class ConfirmModal(ModalScreen[bool]):
    BINDINGS = [
        Binding("enter,y", "yes", "Yes"),
        Binding("escape,n", "no", "No"),
    ]

    def __init__(self, prompt: str) -> None:
        super().__init__()
        self.prompt = prompt

    def compose(self) -> ComposeResult:
        with Vertical(id="modal-box"):
            yield Label(self.prompt)
            yield Label("Enter/y yes, Esc/n no")

    def action_yes(self) -> None:
        self.dismiss(True)

    def action_no(self) -> None:
        self.dismiss(False)


class CommitModal(ModalScreen[str | None]):
    BINDINGS = [
        Binding("ctrl+s", "submit", "Submit"),
        Binding("escape", "cancel", "Cancel"),
    ]

    def __init__(self, default: str) -> None:
        super().__init__()
        self.default = default

    def compose(self) -> ComposeResult:
        with Vertical(id="modal-box"):
            yield Label("Git commit message (Ctrl+S submit, Esc cancel)")
            yield Input(value=self.default, id="commit-msg")

    def on_mount(self) -> None:
        self.query_one("#commit-msg", Input).focus()

    def on_input_submitted(self, event: Input.Submitted) -> None:
        self.dismiss(event.value.strip() or None)

    def action_submit(self) -> None:
        text = self.query_one("#commit-msg", Input).value.strip()
        self.dismiss(text or None)

    def action_cancel(self) -> None:
        self.dismiss(None)


# --------------------------- Status icons ---------------------------

_STATUS_TODO = frozenset({"to do", "open", "backlog", "new", "todo"})
_STATUS_PROG = frozenset({"in progress", "in review", "in development", "in test", "testing"})
_STATUS_DONE = frozenset({"done", "closed", "resolved", "complete", "completed"})


def colored_cell(text: str, color: str) -> Text:
    return Text((text or "-").strip() or "-", style=f"bold {color}", no_wrap=True)


def status_cell(status_name: str) -> Text:
    name = (status_name or "?").strip() or "?"
    low = name.lower()
    if low in _STATUS_DONE:
        color = "#00875A"
    elif low in _STATUS_PROG:
        color = "#2684FF"
    elif low in _STATUS_TODO:
        color = "#6B778C"
    else:
        color = GLAMOUR_DARK["warn"]
    return colored_cell(name, color)


def type_cell(type_name: str) -> Text:
    name = (type_name or "?").strip() or "?"
    low = name.lower()
    if low in ("task", "sub-task", "subtask"):
        color = "#2684FF"
    elif low == "epic":
        color = "#6554C0"
    elif low == "story":
        color = "#36B37E"
    elif low == "bug":
        color = "#E34935"
    else:
        color = GLAMOUR_DARK["doc_fg"]
    return colored_cell(name, color)


def key_cell(key: str) -> Text:
    return Text((key or "-").strip() or "-", style="bold", no_wrap=True)


def priority_cell(priority_name: str) -> Text:
    name = (priority_name or "-").strip() or "-"
    low = name.lower()
    if low in ("highest", "blocker", "critical"):
        color = "#FF5630"
    elif low in ("high", "major"):
        color = "#FF8B00"
    elif low in ("medium", "normal"):
        color = "#FFAB00"
    elif low in ("low", "minor"):
        color = "#36B37E"
    elif low in ("lowest", "trivial"):
        color = "#0065FF"
    else:
        color = GLAMOUR_DARK["muted"]
    return colored_cell(name, color)


# --------------------------- Detail Screen ---------------------------

class IssueDetailScreen(Screen):
    BINDINGS = [
        Binding("escape", "back", "Back"),
        Binding("o", "open_browser", "Browser"),
        Binding("t", "transition", "Transition"),
        Binding("c", "comment", "Comment"),
        Binding("w", "workdir", "Workdir"),
        Binding("f", "toggle_files", "Files"),
        Binding("g", "git_commit", "Commit"),
        Binding("u", "git_restore", "Restore"),
    ]

    def __init__(
        self,
        client: JiraClient,
        base_url: str,
        key: str,
        custom_field_filter: list[str] | None = None,
    ) -> None:
        super().__init__()
        self.client = client
        self.base_url = base_url
        self.key = key
        self.custom_field_filter = custom_field_filter or []
        self._files_mode = False

    def compose(self) -> ComposeResult:
        yield Header(show_clock=False)
        with Horizontal(id="detail-main"):
            with VerticalScroll(id="detail-body"):
                yield Markdown("_Loading..._", id="detail-body-md")
                table = DataTable(id="detail-files", cursor_type="row")
                table.add_columns("St", "Path")
                table.display = False
                yield table
            with VerticalScroll(id="detail-meta"):
                yield Markdown("_Loading..._", id="detail-meta-md")
        yield Static("Ready.", classes="status-bar", id="detail-status")
        yield Footer()

    def on_mount(self) -> None:
        self.title = self.key
        self.load_detail()

    def set_status(self, msg: str) -> None:
        self.query_one("#detail-status", Static).update(msg)

    @work(exclusive=True, group="detail-load")
    async def load_detail(self) -> None:
        self.set_status(f"Loading {self.key}...")
        try:
            issue = await self.client.issue(self.key)
            comments = await self.client.comments(self.key)
        except httpx.HTTPError as e:
            self.set_status(f"Error loading {self.key}: {http_err_msg(e)}")
            return

        fields = issue["fields"]

        desc = adf_to_text(fields.get("description"))
        body_md = [
            f"# {fields['summary']}",
            "",
            "## Description",
            "",
            desc or "_No description._",
            "",
            "## Comments",
            "",
        ]
        if comments:
            for c in comments:
                author = c.get("author", {}).get("displayName", "Unknown")
                created = c.get("created", "")
                text = adf_to_text(c.get("body"))
                body_md.append(f"**{author}** _{created}_")
                body_md.append("")
                body_md.append(text)
                body_md.append("")
        else:
            body_md.append("_No comments._")
        self.query_one("#detail-body-md", Markdown).update("\n".join(body_md))

        assignee = (fields.get("assignee") or {}).get("displayName", "-")
        reporter = (fields.get("reporter") or {}).get("displayName", "-")
        meta_md = [
            "## Details",
            "",
            f"- **Status:** {fields['status']['name']}",
            f"- **Type:** {fields['issuetype']['name']}",
            f"- **Priority:** {(fields.get('priority') or {}).get('name', '-')}",
            f"- **Assignee:** {assignee}",
            f"- **Reporter:** {reporter}",
            f"- **Updated:** {fields.get('updated', '-')}",
            f"- **Created:** {fields.get('created', '-')}",
            "",
            "---",
            "",
            "## Additional Fields",
            "",
        ]
        custom = build_custom_fields(issue, self.custom_field_filter)
        if custom:
            for label, value in custom:
                meta_md.append(f"- **{label}:** {value}")
                meta_md.append("")
        else:
            meta_md.append(
                "_No fields match the current filter._"
                if self.custom_field_filter
                else "_None populated._"
            )
        self.query_one("#detail-meta-md", Markdown).update("\n".join(meta_md))

        self.set_status(f"Loaded {self.key}.")

    def action_back(self) -> None:
        self.app.pop_screen()

    def action_open_browser(self) -> None:
        url = f"{self.base_url}/browse/{self.key}"
        webbrowser.open(url)
        self.set_status(f"Opened {url}")

    def action_comment(self) -> None:
        def apply_comment(text: str | None) -> None:
            if text:
                self.post_comment(text)

        self.app.push_screen(CommentModal(), apply_comment)

    @work(exclusive=True, group="detail-comment")
    async def post_comment(self, text: str) -> None:
        self.set_status(f"Posting comment to {self.key}...")
        try:
            await self.client.add_comment(self.key, text)
        except httpx.HTTPError as e:
            self.set_status(f"Error posting comment: {http_err_msg(e)}")
            return
        self.set_status(f"Comment added to {self.key}.")
        self.load_detail()

    def action_transition(self) -> None:
        self.load_transitions()

    @work(exclusive=True, group="detail-trans")
    async def load_transitions(self) -> None:
        try:
            transitions = await self.client.transitions(self.key)
        except httpx.HTTPError as e:
            self.set_status(f"Error loading transitions: {http_err_msg(e)}")
            return
        if not transitions:
            self.set_status("No transitions available.")
            return

        def apply_transition(choice: TransitionChoice | None) -> None:
            if choice:
                self.run_transition(choice)

        self.app.push_screen(TransitionModal(transitions), apply_transition)

    @work(exclusive=True, group="detail-trans")
    async def run_transition(self, choice: TransitionChoice) -> None:
        self.set_status(f"Transitioning {self.key}...")
        try:
            await self.client.do_transition(self.key, choice.transition_id, choice.fields or None)
        except httpx.HTTPError as e:
            self.set_status(f"Error transitioning: {http_err_msg(e)}")
            return
        self.set_status(f"Transitioned {self.key}.")
        self.load_detail()

    def _show_files_table(self, show: bool) -> None:
        md = self.query_one("#detail-body-md", Markdown)
        table = self.query_one("#detail-files", DataTable)
        md.display = not show
        table.display = show

    def refresh_files_table(self) -> None:
        table = self.query_one("#detail-files", DataTable)
        table.clear()
        try:
            data = gitstatus_data(self.key)
        except FileNotFoundError:
            self.set_status("No workdir. Press w to create.")
            return
        except Exception as e:
            self.set_status(str(e))
            return
        if not data["files"]:
            self.set_status(f"{data['path']}  clean")
            return
        for f in data["files"]:
            st = f["status"]
            if "D" in st:
                color = "#E34935"
            elif st in ("??", "A", "A "):
                color = "#36B37E"
            else:
                color = GLAMOUR_DARK["warn"]
            table.add_row(colored_cell(st, color), f["path"])
        self.set_status(f"{data['path']}  {len(data['files'])} change(s)")

    def action_toggle_files(self) -> None:
        self._files_mode = not self._files_mode
        self._show_files_table(self._files_mode)
        if self._files_mode:
            self.refresh_files_table()
            self.query_one("#detail-files", DataTable).focus()

    @work(exclusive=True, group="detail-work")
    async def action_workdir(self) -> None:
        try:
            issue = await self.client.issue(self.key)
        except httpx.HTTPError as e:
            self.set_status(http_err_msg(e))
            return
        summary = issue["fields"]["summary"]
        try:
            path = create_workdir(self.key, summary, self.base_url, issue.get("id"))
        except Exception as e:
            self.set_status(f"workdir: {e}")
            return
        self.set_status(str(path))

    def action_git_commit(self) -> None:
        default = f"{self.key}: snapshot {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%MZ')}"

        def apply(msg: str | None) -> None:
            if not msg:
                return
            try:
                git_commit_all(self.key, msg)
                self.set_status(f"committed: {msg}")
                if self._files_mode:
                    self.refresh_files_table()
            except Exception as e:
                self.set_status(str(e))

        self.app.push_screen(CommitModal(default), apply)

    def action_git_restore(self) -> None:
        def apply(ok: bool) -> None:
            if not ok:
                return
            try:
                git_restore(self.key)
                self.set_status("restored uncommitted changes")
                if self._files_mode:
                    self.refresh_files_table()
            except Exception as e:
                self.set_status(str(e))

        self.app.push_screen(
            ConfirmModal(f"Discard uncommitted changes in {self.key}?"),
            apply,
        )


# --------------------------- List Screen ---------------------------

class IssueListScreen(Screen):
    BINDINGS = [
        Binding("r", "refresh", "Refresh"),
        Binding("slash", "edit_jql", "JQL"),
        Binding("w", "workdir", "Workdir"),
        Binding("enter", "open_issue", "Open", show=False),
        Binding("j", "cursor_down", show=False),
        Binding("k", "cursor_up", show=False),
    ]

    def __init__(
        self,
        client: JiraClient,
        base_url: str,
        custom_field_filter: list[str] | None = None,
        default_jql: str | None = None,
    ) -> None:
        super().__init__()
        self.client = client
        self.base_url = base_url
        self.custom_field_filter = custom_field_filter or []
        self.jql = default_jql or DEFAULT_JQL
        self.issues: list[dict[str, Any]] = []

    def compose(self) -> ComposeResult:
        yield Header(show_clock=False)
        yield Static(f"JQL: {self.jql}", id="jql-bar")
        table = DataTable(id="list-table", cursor_type="row", zebra_stripes=True)
        table.add_columns("Key", "Type", "Status", "Pri", "Summary")
        yield table
        yield Static("Ready.", classes="status-bar", id="list-status")
        yield Footer()

    def on_mount(self) -> None:
        self.title = "Jira TUI"
        self.query_one(DataTable).focus()
        self.load_issues()

    def set_status(self, msg: str) -> None:
        self.query_one("#list-status", Static).update(msg)

    @work(exclusive=True, group="list-load")
    async def load_issues(self) -> None:
        self.set_status("Loading issues...")
        try:
            issues = await self.client.search(self.jql)
        except httpx.HTTPError as e:
            self.set_status(f"Error: {http_err_msg(e)}")
            return

        self.issues = issues
        table = self.query_one(DataTable)
        table.clear()
        for issue in issues:
            fields = issue["fields"]
            status_name = fields["status"]["name"]
            table.add_row(
                key_cell(issue["key"]),
                type_cell(fields["issuetype"]["name"]),
                status_cell(status_name),
                priority_cell((fields.get("priority") or {}).get("name", "-")),
                fields["summary"],
                key=issue["key"],
            )
        self.query_one("#jql-bar", Static).update(f"JQL: {self.jql}")
        self.set_status(f"Loaded {len(issues)} issue(s). Enter to open.")

    def action_refresh(self) -> None:
        self.load_issues()

    def action_cursor_down(self) -> None:
        self.query_one(DataTable).action_cursor_down()

    def action_cursor_up(self) -> None:
        self.query_one(DataTable).action_cursor_up()

    def action_edit_jql(self) -> None:
        def apply_jql(result: str | None) -> None:
            if result:
                self.jql = result
                self.load_issues()

        self.app.push_screen(JQLModal(self.jql), apply_jql)

    @on(DataTable.RowSelected)
    def on_row_selected(self, event: DataTable.RowSelected) -> None:
        self._open_current(event.row_key.value)

    def action_open_issue(self) -> None:
        table = self.query_one(DataTable)
        row_key = table.coordinate_to_cell_key(table.cursor_coordinate).row_key
        self._open_current(row_key.value if row_key else None)

    def _current_key(self) -> str | None:
        table = self.query_one(DataTable)
        row_key = table.coordinate_to_cell_key(table.cursor_coordinate).row_key
        return row_key.value if row_key else None

    @work(exclusive=True, group="list-work")
    async def action_workdir(self) -> None:
        key = self._current_key()
        if not key:
            self.set_status("No row selected.")
            return
        try:
            issue = await self.client.issue(key)
        except httpx.HTTPError as e:
            self.set_status(http_err_msg(e))
            return
        summary = issue["fields"]["summary"]
        try:
            path = create_workdir(key, summary, self.base_url, issue.get("id"))
        except Exception as e:
            self.set_status(f"workdir: {e}")
            return
        self.set_status(str(path))

    def _open_current(self, key: str | None) -> None:
        if key:
            self.app.push_screen(
                IssueDetailScreen(self.client, self.base_url, key, self.custom_field_filter)
            )


# --------------------------- App ---------------------------

class JiraTUI(App):
    CSS = APP_CSS

    BINDINGS = [
        Binding("q", "quit", "Quit"),
    ]

    def __init__(self, cfg: JiraConfig) -> None:
        super().__init__()
        self.cfg = cfg
        self.client = JiraClient(self.cfg)

    def on_mount(self) -> None:
        self.push_screen(
            IssueListScreen(
                self.client,
                self.cfg.base_url,
                self.cfg.custom_field_filter,
                self.cfg.default_jql,
            )
        )

    async def on_unmount(self) -> None:
        await self.client.aclose()


def _out_json(obj: Any) -> None:
    sys.stdout.write(json.dumps(obj, indent=2) + "\n")


def _die(msg: str, code: int) -> None:
    sys.stderr.write(msg.rstrip() + "\n")
    sys.exit(code)


def _issue_brief(issue: dict[str, Any]) -> dict[str, Any]:
    fields = issue.get("fields") or {}
    return {
        "key": issue.get("key"),
        "summary": fields.get("summary"),
        "status": (fields.get("status") or {}).get("name"),
        "issuetype": (fields.get("issuetype") or {}).get("name"),
        "priority": (fields.get("priority") or {}).get("name"),
        "assignee": (fields.get("assignee") or {}).get("displayName"),
        "updated": fields.get("updated"),
    }


async def _cli_with_client(cfg: JiraConfig):
    return JiraClient(cfg)


def _read_comment_body(args: argparse.Namespace) -> str:
    if args.message:
        return args.message
    if args.file:
        return Path(args.file).read_text(encoding="utf-8")
    if not sys.stdin.isatty():
        return sys.stdin.read()
    _die("comment: provide -m, -F, or stdin", 1)
    return ""


async def run_cli(args: argparse.Namespace) -> int:
    cmd = args.command
    try:
        if cmd in ("path", "gitstatus", "commit", "restore", "undo-commit", "gitlog"):
            key = normalize_key(args.key)
            if cmd == "path":
                p = find_workdir(key)
                if p is None:
                    _die("no workdir; run init first", 4)
                sys.stdout.write(str(p) + "\n")
                return 0
            if cmd == "gitstatus":
                data = gitstatus_data(key)
                if args.json:
                    _out_json(data)
                else:
                    sys.stdout.write(f"{data['path']}  {data['branch']}\n")
                    if not data["files"]:
                        sys.stdout.write("clean\n")
                    for f in data["files"]:
                        sys.stdout.write(f"{f['status']:2} {f['path']}\n")
                return 0
            if cmd == "commit":
                msg = args.message or (
                    f"{key}: snapshot {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%MZ')}"
                )
                git_commit_all(key, msg)
                return 0
            if cmd == "restore":
                git_restore(key)
                return 0
            if cmd == "undo-commit":
                git_undo_commit(key)
                return 0
            if cmd == "gitlog":
                sys.stdout.write(git_log_text(key, args.n) + "\n")
                return 0

        cfg = JiraConfig.from_env(jql_override=getattr(args, "jql", None) or None)
        client = JiraClient(cfg)
        try:
            if cmd == "list":
                issues = await client.search(cfg.default_jql)
                briefs = [_issue_brief(i) for i in issues]
                if args.json:
                    _out_json(briefs)
                else:
                    for b in briefs:
                        sys.stdout.write(
                            f"{b['key']}\t{b['issuetype']}\t{b['status']}\t{b['priority']}\t{b['summary']}\n"
                        )
                return 0
            if cmd == "show":
                key = normalize_key(args.key)
                issue = await client.issue(key)
                if args.json:
                    _out_json(_issue_brief(issue) | {"description": adf_to_text(issue["fields"].get("description"))})
                else:
                    b = _issue_brief(issue)
                    sys.stdout.write(f"{b['key']}  {b['summary']}\n")
                    sys.stdout.write(f"status={b['status']} type={b['issuetype']} pri={b['priority']}\n")
                    sys.stdout.write(adf_to_text(issue["fields"].get("description")) + "\n")
                return 0
            if cmd == "comment":
                key = normalize_key(args.key)
                body = _read_comment_body(args).strip()
                if not body:
                    _die("empty comment", 1)
                if args.dry_run:
                    sys.stdout.write(body + "\n")
                    return 0
                await client.add_comment(key, body)
                return 0
            if cmd == "init":
                key = normalize_key(args.key)
                issue = await client.issue(key)
                path = create_workdir(
                    key,
                    issue["fields"]["summary"],
                    cfg.base_url,
                    issue.get("id"),
                )
                sys.stdout.write(str(path) + "\n")
                return 0
        except httpx.HTTPError as e:
            _die(http_err_msg(e), 3)
        finally:
            await client.aclose()
    except ValueError as e:
        _die(str(e), 1)
    except FileNotFoundError as e:
        _die(str(e), 4)
    except PermissionError as e:
        _die(str(e), 4)
    except RuntimeError as e:
        _die(str(e), 4)
    except subprocess.CalledProcessError as e:
        _die((e.stderr or e.stdout or str(e)).strip(), 4)
    return 0


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="jira_tui.py",
        description="Jira TUI + CLI (comment = Jira, commit = git).",
        add_help=False,
    )
    parser.add_argument("-h", "--help", action="store_true")
    parser.add_argument("--jql", default="", help="TUI / list JQL override")
    sub = parser.add_subparsers(dest="command")

    p_list = sub.add_parser("list", add_help=True)
    p_list.add_argument("--jql", default="")
    p_list.add_argument("--json", action="store_true")

    p_show = sub.add_parser("show")
    p_show.add_argument("key")
    p_show.add_argument("--json", action="store_true")

    p_comment = sub.add_parser("comment")
    p_comment.add_argument("key")
    p_comment.add_argument("-m", "--message", default="")
    p_comment.add_argument("-F", "--file", dest="file", default="")
    p_comment.add_argument("--dry-run", action="store_true")

    p_init = sub.add_parser("init")
    p_init.add_argument("key")

    p_path = sub.add_parser("path")
    p_path.add_argument("key")

    p_gs = sub.add_parser("gitstatus")
    p_gs.add_argument("key")
    p_gs.add_argument("--json", action="store_true")

    p_commit = sub.add_parser("commit")
    p_commit.add_argument("key")
    p_commit.add_argument("-m", "--message", default="")

    p_restore = sub.add_parser("restore")
    p_restore.add_argument("key")

    p_undo = sub.add_parser("undo-commit")
    p_undo.add_argument("key")

    p_log = sub.add_parser("gitlog")
    p_log.add_argument("key")
    p_log.add_argument("-n", type=int, default=10)

    args = parser.parse_args()
    if args.help and not args.command:
        print(USAGE)
        sys.exit(0)
    if args.command:
        raise SystemExit(asyncio.run(run_cli(args)))
    cfg = JiraConfig.from_env(jql_override=args.jql or None)
    JiraTUI(cfg).run()


if __name__ == "__main__":
    main()
