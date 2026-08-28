# jira_tui

Textual TUI plus a small CLI for Jira Cloud. Human-first. A later agent can shell the same commands; this program does not call an LLM.

`comment` = Jira issue comment. `commit` = git in the local work folder. Different verbs on purpose.

Requires: Python 3.10+, `textual`, `httpx`, `git` on PATH.

---

## Environment

```
export JIRA_BASE_URL=https://yourorg.atlassian.net
export JIRA_EMAIL=you@example.com
export JIRA_API_TOKEN=...   # https://id.atlassian.com/manage-profile/security/api-tokens
```

Optional:

```
JIRA_DEFAULT_JQL            # startup / list query
JIRA_CUSTOM_FIELD_FILTER    # comma-separated label substrings for Additional Fields
JIRA_WORK_ROOT              # default: ~/Work
```

Token stays in the environment. Never in `.jira.json`, git, or the audit log.

---

## TUI

```
python3 jira_tui.py
python3 jira_tui.py --jql 'assignee = currentUser() AND resolution = Unresolved'
```

List:

| key | action |
|-----|--------|
| Enter | open issue |
| j / k | down / up |
| r | refresh |
| / | edit JQL |
| w | create work folder (and git init) |
| q | quit |

Detail:

| key | action |
|-----|--------|
| Esc | back |
| o | open in browser (`/browse/KEY`) |
| t | transition (prompts for required fields) |
| c | Jira comment (Ctrl+S submit) |
| w | create / reuse work folder |
| f | files pane (`git status`) |
| g | git commit |
| u | restore uncommitted changes (confirm) |
| q | quit |

List colors follow Jira: Task blue, Epic purple, Story green, Bug red. Status grey / blue / green. Priority Highest red through Lowest blue. **Key** is the Jira id (`PROJ-123`), not a nickname.

---

## CLI

No command launches the TUI. Subcommands print **data on stdout**, chatter on stderr. Exit: 0 ok, 1 usage/bad key, 2 missing env, 3 Jira HTTP, 4 git/workdir.

```
jira_tui.py list [--jql JQL] [--json]
jira_tui.py show KEY [--json]
jira_tui.py comment KEY -m TEXT | -F FILE | stdin  [--dry-run]
jira_tui.py init KEY
jira_tui.py path KEY
jira_tui.py gitstatus KEY [--json]
jira_tui.py commit KEY [-m MSG]
jira_tui.py restore KEY
jira_tui.py undo-commit KEY
jira_tui.py gitlog KEY [-n N]
```

`init` and `path` print only the absolute directory. Idempotent: second `init` reprints the existing path.

`--dry-run` on `comment` prints the body and does not POST.

Agent-shaped loop (later, not in this script):

```
jira_tui.py list --json
jira_tui.py show KEY --json
jira_tui.py path KEY
jira_tui.py gitstatus KEY --json
jira_tui.py comment KEY --dry-run -F draft.md
```

---

## Work folders

Default: `{JIRA_WORK_ROOT}/{KEY}-{slug}` e.g. `~/Work/TAR-1302-vlan-untag`.

- Key first, no spaces. Slug from summary at **first** create only. Never renamed if Jira title changes.
- Lookup: `{KEY}-*` with `.jira.json`. Will not clobber `~/Work/JIRA`.
- `git init` happens in **that directory only**. Never `git init ~/Work`.
- First commit: `{KEY}: init` (scaffold only). No remote.

Tree:

```
notes/  comms/  change/  configs/  diagrams/  evidence/  scripts/  vendor/
README.md  .jira.json  .gitignore
```

`.jira.json` has key, browse URL, timestamps. No token.

Git helpers: `restore` drops uncommitted edits. `undo-commit` is CLI-only, refuses to drop the init commit. `git clean` is not bound in the TUI.

---

## Security (short)

Treat work trees as company-confidential. No credentials, pcaps, or keys in them.

- Dirs `0700`, `.jira.json` `0600` on create.
- Git identity in the ticket repo is `jira-tui@localhost` (not your work email).
- Commit refuses pcap/kdbx/pem/`.env` **and** secret-like file content (`enable secret`, TACACS key, PEM, etc.). Speed bump, not DLP.
- TLS verify on. Mutating actions append `~/.local/state/jira-tui/audit.jsonl` (action, key, user, time — not bodies or tokens).
- API token is yours to scope and rotate. This script does not vault it.

---

## Notes

- Cloud REST v3. Search is `POST /rest/api/3/search/jql` with `nextPageToken`.
- Missing `textual`/`httpx`: the script tries `uv` / pip / `--user` / `--break-system-packages`.
- TUI does not show full diffs (running-configs are too large).
