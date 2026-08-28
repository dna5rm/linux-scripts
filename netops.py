#!/usr/bin/env python3
"""
NetOps Portal TUI - Textual frontend for wanportal API (https://github.com/dna5rm/wanportal)
Public read-only API - no authentication required.

Navigation:
  Home screen: Down Monitors (current_loss=100, is_active=1)
  g = Agents | t = Targets | / = Search | h = Home | Escape = Back | q = Quit
"""

import sys
import subprocess
import importlib

REQUIRED_PACKAGES = {
    "requests": "requests",
    "textual": "textual",
    "textual_plotext": "textual-plotext",
}


def ensure_dependencies():
    missing = []
    for import_name, pip_name in REQUIRED_PACKAGES.items():
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
    import os
    os.execv(sys.executable, [sys.executable] + sys.argv)


ensure_dependencies()

# ---------------------------------------------------------------------------
import os
import requests
from textual.app import App, ComposeResult
from textual.containers import Container
from textual.widgets import Header, Footer, DataTable, Static, LoadingIndicator, Input
from textual.screen import Screen
from textual.binding import Binding
from textual import work
from textual_plotext import PlotextPlot

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
API_BASE_URL = os.environ.get("NETOPS_URL", "").strip()
REQUEST_TIMEOUT = 15
VERIFY_SSL = False

if not VERIFY_SSL:
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


# ---------------------------------------------------------------------------
# API Client (public read-only endpoints - no auth required)
# ---------------------------------------------------------------------------
class WanPortalClient:
    def __init__(self, base_url, verify_ssl=True):
        self.base_url = base_url.rstrip("/")
        self.session = requests.Session()
        self.session.verify = verify_ssl

    def get(self, path, params=None):
        try:
            resp = self.session.get(f"{self.base_url}{path}", params=params, timeout=REQUEST_TIMEOUT)
            resp.raise_for_status()
            return resp.json()
        except requests.RequestException as e:
            return {"__error__": str(e)}


api = WanPortalClient(API_BASE_URL, verify_ssl=VERIFY_SSL)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def fmt(val, decimals=2):
    if val is None:
        return "-"
    if isinstance(val, float):
        return f"{val:.{decimals}f}"
    return str(val)


def loss_color(loss):
    if loss is None:
        return "-"
    try:
        v = float(loss)
    except (TypeError, ValueError):
        return str(loss)
    if v >= 100:
        return f"[bold red]{v:.0f}%[/bold red]"
    if v > 0:
        return f"[yellow]{v:.0f}%[/yellow]"
    return f"[green]{v:.0f}%[/green]"


def active_badge(is_active):
    return "[green]● active[/green]" if is_active else "[dim red]○ inactive[/dim red]"


def status_badge(loss):
    return "[bold red]DOWN[/bold red]" if (loss or 0) >= 100 else "[green]UP[/green]"


# ---------------------------------------------------------------------------
# Base screen with shared Home/Quit bindings
# ---------------------------------------------------------------------------
class BaseScreen(Screen):
    """Common bindings available on every screen."""

    BASE_BINDINGS = [
        Binding("h", "go_home", "Home"),
        Binding("slash", "open_search", "Search"),
        Binding("q", "app.quit", "Quit"),
    ]

    def action_go_home(self) -> None:
        self.app.pop_screen_all_and_home()

    def action_open_search(self) -> None:
        self.app.push_screen(SearchScreen())


# ---------------------------------------------------------------------------
# Screen: Monitors (generic, filterable list - used for Home/Down/Agent/Target views)
# ---------------------------------------------------------------------------
class MonitorsScreen(BaseScreen):
    BINDINGS = [
        Binding("r", "refresh", "Refresh"),
        Binding("a", "toggle_auto", "Auto-refresh"),
        Binding("d", "goto_down", "Down Only"),
        Binding("g", "goto_agents", "Agents"),
        Binding("t", "goto_targets", "Targets"),
        Binding("escape", "app.pop_screen", "Back"),
        Binding("enter", "drill_in", "Detail", show=False),
    ] + BaseScreen.BASE_BINDINGS

    def __init__(self, title="Monitors", params=None,
                 filter_agent_id=None, filter_target_id=None,
                 filter_text=None):
        super().__init__()
        self._monitors = []
        self._auto_refresh = False
        self._timer = None
        self.screen_title = title
        self.params = params or {}
        self.filter_agent_id = filter_agent_id
        self.filter_target_id = filter_target_id
        self.filter_text = filter_text

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Container(
            Static(f"[b]NetOps Portal — {self.screen_title}[/b]", id="title"),
            Static("", id="summary"),
            LoadingIndicator(id="loader"),
            DataTable(id="table", zebra_stripes=True, cursor_type="row"),
            id="main",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.query_one("#table").display = False
        table = self.query_one(DataTable)
        table.add_columns(
            "Description", "Agent", "Target", "Proto", "Status", "Loss", "RTT (ms)", "Active"
        )
        self.load_data()

    @work(exclusive=True, thread=True)
    def load_data(self) -> None:
        result = api.get("/monitors", params=self.params)
        self.app.call_from_thread(self.populate, result)

    def populate(self, result) -> None:
        loader = self.query_one("#loader")
        table = self.query_one("#table", DataTable)
        summary = self.query_one("#summary", Static)
        loader.display = False
        table.display = True
        table.clear()

        if isinstance(result, dict) and "__error__" in result:
            self.notify(f"API error: {result['__error__']}", severity="error", timeout=8)
            return

        monitors = result.get("monitors", [])

        if self.filter_agent_id:
            monitors = [m for m in monitors if m.get("agent_id") == self.filter_agent_id]
        if self.filter_target_id:
            monitors = [m for m in monitors if m.get("target_id") == self.filter_target_id]
        if self.filter_text:
            needle = self.filter_text.lower()
            monitors = [
                m for m in monitors
                if needle in (m.get("description") or "").lower()
                or needle in (m.get("agent_name") or "").lower()
                or needle in (m.get("target_address") or "").lower()
            ]

        self._monitors = monitors

        total = len(monitors)
        active = sum(1 for m in monitors if m.get("is_active"))
        down = sum(1 for m in monitors if (m.get("current_loss") or 0) >= 100)
        degraded = sum(1 for m in monitors if 0 < (m.get("current_loss") or 0) < 100)
        auto_state = "on" if self._auto_refresh else "off"
        summary.update(
            f"[b]{total}[/b] monitors  ·  [green]{active} active[/green]  ·  "
            f"[bold red]{down} down[/bold red]  ·  [yellow]{degraded} degraded[/yellow]  ·  "
            f"[dim]auto-refresh: {auto_state}[/dim]"
        )

        for m in monitors:
            loss = m.get("current_loss")
            table.add_row(
                m.get("description") or "-",
                m.get("agent_name") or "-",
                m.get("target_address") or "-",
                m.get("protocol") or "-",
                status_badge(loss),
                loss_color(loss),
                fmt(m.get("current_median")),
                active_badge(m.get("is_active")),
            )
        table.focus()

    def action_refresh(self) -> None:
        self.query_one("#table").display = False
        self.query_one("#loader").display = True
        self.load_data()

    def action_toggle_auto(self) -> None:
        self._auto_refresh = not self._auto_refresh
        if self._auto_refresh:
            self._timer = self.set_interval(30, self.load_data)
            self.notify("Auto-refresh enabled (30s)", timeout=3)
        else:
            if self._timer:
                self._timer.pause()
            self.notify("Auto-refresh disabled", timeout=3)

    def action_goto_down(self) -> None:
        self.app.push_screen(
            MonitorsScreen(title="Down Monitors", params={"current_loss": 100, "is_active": 1})
        )

    def action_goto_agents(self) -> None:
        self.app.push_screen(AgentsScreen())

    def action_goto_targets(self) -> None:
        self.app.push_screen(TargetsScreen())

    def action_drill_in(self) -> None:
        table = self.query_one("#table", DataTable)
        if table.cursor_row is None or not self._monitors:
            return
        monitor = self._monitors[table.cursor_row]
        self.app.push_screen(MonitorDetailScreen(monitor))

    def on_data_table_row_selected(self, event: DataTable.RowSelected) -> None:
        self.action_drill_in()


# ---------------------------------------------------------------------------
# Screen: Agents
# ---------------------------------------------------------------------------
class AgentsScreen(BaseScreen):
    BINDINGS = [
        Binding("escape", "app.pop_screen", "Back"),
        Binding("r", "refresh", "Refresh"),
        Binding("enter", "drill_in", "View Monitors", show=False),
    ] + BaseScreen.BASE_BINDINGS

    def __init__(self):
        super().__init__()
        self._agents = []

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Container(
            Static("[b]NetOps Portal — Agents[/b]", id="title"),
            LoadingIndicator(id="loader"),
            DataTable(id="table", zebra_stripes=True, cursor_type="row"),
            id="main",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.query_one("#table").display = False
        table = self.query_one(DataTable)
        table.add_columns("Name", "Address", "Description", "Last Seen", "Active")
        self.load_data()

    @work(exclusive=True, thread=True)
    def load_data(self) -> None:
        result = api.get("/agents")
        self.app.call_from_thread(self.populate, result)

    def populate(self, result) -> None:
        loader = self.query_one("#loader")
        table = self.query_one("#table", DataTable)
        loader.display = False
        table.display = True
        table.clear()

        if isinstance(result, dict) and "__error__" in result:
            self.notify(f"API error: {result['__error__']}", severity="error", timeout=8)
            return

        agents = result.get("agents", [])
        self._agents = agents

        for a in agents:
            table.add_row(
                a.get("name") or "-",
                a.get("address") or "-",
                a.get("description") or "-",
                str(a.get("last_seen") or "-")[:19],
                active_badge(a.get("is_active")),
            )
        table.focus()

    def action_refresh(self) -> None:
        self.query_one("#table").display = False
        self.query_one("#loader").display = True
        self.load_data()

    def action_drill_in(self) -> None:
        table = self.query_one("#table", DataTable)
        if table.cursor_row is None or not self._agents:
            return
        agent = self._agents[table.cursor_row]
        self.app.push_screen(
            MonitorsScreen(
                title=f"Monitors — Agent: {agent.get('name')}",
                filter_agent_id=agent["id"],
            )
        )

    def on_data_table_row_selected(self, event: DataTable.RowSelected) -> None:
        self.action_drill_in()

# ---------------------------------------------------------------------------
# Screen: Targets
# ---------------------------------------------------------------------------
class TargetsScreen(BaseScreen):
    BINDINGS = [
        Binding("escape", "app.pop_screen", "Back"),
        Binding("r", "refresh", "Refresh"),
        Binding("enter", "drill_in", "View Monitors", show=False),
    ] + BaseScreen.BASE_BINDINGS

    def __init__(self):
        super().__init__()
        self._targets = []

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Container(
            Static("[b]NetOps Portal — Targets[/b]", id="title"),
            LoadingIndicator(id="loader"),
            DataTable(id="table", zebra_stripes=True, cursor_type="row"),
            id="main",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.query_one("#table").display = False
        table = self.query_one(DataTable)
        table.add_columns("Address", "Description", "Active")
        self.load_data()

    @work(exclusive=True, thread=True)
    def load_data(self) -> None:
        result = api.get("/targets")
        self.app.call_from_thread(self.populate, result)

    def populate(self, result) -> None:
        loader = self.query_one("#loader")
        table = self.query_one("#table", DataTable)
        loader.display = False
        table.display = True
        table.clear()

        if isinstance(result, dict) and "__error__" in result:
            self.notify(f"API error: {result['__error__']}", severity="error", timeout=8)
            return

        targets = result.get("targets", [])
        self._targets = targets

        for t in targets:
            table.add_row(
                t.get("address") or "-",
                t.get("description") or "-",
                active_badge(t.get("is_active")),
            )
        table.focus()

    def action_refresh(self) -> None:
        self.query_one("#table").display = False
        self.query_one("#loader").display = True
        self.load_data()

    def action_drill_in(self) -> None:
        table = self.query_one("#table", DataTable)
        if table.cursor_row is None or not self._targets:
            return
        target = self._targets[table.cursor_row]
        self.app.push_screen(
            MonitorsScreen(
                title=f"Monitors — Target: {target.get('address')}",
                filter_target_id=target["id"],
            )
        )

    def on_data_table_row_selected(self, event: DataTable.RowSelected) -> None:
        self.action_drill_in()


# ---------------------------------------------------------------------------
# Screen: Search
# ---------------------------------------------------------------------------
class SearchScreen(BaseScreen):
    BINDINGS = [
        Binding("escape", "app.pop_screen", "Cancel"),
    ] + BaseScreen.BASE_BINDINGS

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Container(
            Static("[b]Search Monitors[/b]", id="title"),
            Static(
                "[dim]Matches against description, agent name, or target address[/dim]",
                id="subtitle",
            ),
            Input(placeholder="e.g. atl0, 172.25.0.130, cur6...", id="search_input"),
            id="main",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.query_one("#search_input", Input).focus()

    def on_input_submitted(self, event: Input.Submitted) -> None:
        query = event.value.strip()
        if not query:
            return
        self.app.pop_screen()
        self.app.push_screen(
            MonitorsScreen(title=f"Search Results: '{query}'", filter_text=query)
        )


# ---------------------------------------------------------------------------
# Screen: Monitor Detail
# ---------------------------------------------------------------------------
class MonitorDetailScreen(BaseScreen):
    BINDINGS = [
        Binding("escape", "app.pop_screen", "Back"),
        Binding("r", "refresh", "Refresh"),
        Binding("g", "goto_agent", "Go to Agent"),
        Binding("t", "goto_target", "Go to Target"),
    ] + BaseScreen.BASE_BINDINGS

    def __init__(self, monitor: dict):
        super().__init__()
        self._monitor_data = monitor
        self.monitor_id = monitor["id"]
        self.description = monitor.get("description", "Monitor")

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Container(
            Static(f"[b]{self.description}[/b]", id="title"),
            LoadingIndicator(id="loader"),
            PlotextPlot(id="plot"),
            DataTable(id="detail_table", zebra_stripes=True, cursor_type="row"),
            id="main",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.query_one("#plot").display = False
        self.query_one("#detail_table").display = False
        table = self.query_one(DataTable)
        table.add_columns("Field", "Value")
        self.render_fields()
        self.load_rrd()

    def render_fields(self) -> None:
        table = self.query_one("#detail_table", DataTable)
        table.clear()
        m = self._monitor_data
        fields = [
            ("Agent", f"{m.get('agent_name')}  [dim](press 'g')[/dim]"),
            ("Target", f"{m.get('target_address')}  [dim](press 't')[/dim]"),
            ("Protocol", m.get("protocol")),
            ("Port", m.get("port")),
            ("DSCP", m.get("dscp")),
            ("Poll Interval", f"{m.get('pollinterval')}s"),
            ("Poll Count", m.get("pollcount")),
            ("Current Loss", loss_color(m.get("current_loss"))),
            ("Current RTT (median)", fmt(m.get("current_median"))),
            ("Current Min/Max", f"{fmt(m.get('current_min'))} / {fmt(m.get('current_max'))}"),
            ("Avg Loss", loss_color(m.get("avg_loss"))),
            ("Avg RTT (median)", fmt(m.get("avg_median"))),
            ("Total Down Events", m.get("total_down")),
            ("Last Update", str(m.get("last_update") or "-")[:19]),
            ("Last Down", str(m.get("last_down") or "-")[:19]),
            ("Active", active_badge(m.get("is_active"))),
        ]
        for label, value in fields:
            table.add_row(label, str(value if value is not None else "-"))
        table.display = True
        table.focus()

    @work(exclusive=True, thread=True)
    def load_rrd(self) -> None:
        rrd = api.get("/rrd", params={"id": self.monitor_id, "ds": "rtt"})
        self.app.call_from_thread(self.populate_plot, rrd)

    def populate_plot(self, rrd) -> None:
        loader = self.query_one("#loader")
        plot_widget = self.query_one("#plot", PlotextPlot)
        loader.display = False
        plot_widget.display = True

        plt = plot_widget.plt
        plt.clear_data()
        plt.clear_figure()
        plt.theme("dark")
        plt.title(f"RTT over time — {self.description}")
        plt.xlabel("time")
        plt.ylabel("ms")

        if isinstance(rrd, dict) and "__error__" not in rrd and rrd.get("data"):
            points = rrd["data"]
            n = len(points)
            x = list(range(n))

            up_series = [p.get("rtt") if (p.get("loss") or 0) < 100 else None for p in points]
            down_series = [0 if (p.get("loss") or 0) >= 100 else None for p in points]

            if any(v is not None for v in up_series):
                plt.plot(x, up_series, marker="braille", color="cyan", label="RTT (ms)")
            if any(v is not None for v in down_series):
                plt.plot(x, down_series, marker="braille", color="red", label="Down")

            labels = []
            for p in points:
                dt_str = p.get("datetime")
                labels.append(str(dt_str)[11:19] if dt_str else "")
            if labels:
                step = max(1, len(labels) // 6)
                xticks = list(range(0, len(labels), step))
                xlabels = [labels[i] for i in xticks]
                plt.xticks(xticks, xlabels)
        else:
            self.notify("No RRD data available for this monitor.", severity="warning", timeout=5)

        plot_widget.refresh()

    def action_refresh(self) -> None:
        self.query_one("#plot").display = False
        self.query_one("#loader").display = True
        self.load_rrd()

    def action_goto_agent(self) -> None:
        agent_id = self._monitor_data.get("agent_id")
        agent_name = self._monitor_data.get("agent_name", "Agent")
        if not agent_id:
            self.notify("No agent info available.", severity="warning", timeout=3)
            return
        self.app.push_screen(
            MonitorsScreen(title=f"Monitors — Agent: {agent_name}", filter_agent_id=agent_id)
        )

    def action_goto_target(self) -> None:
        target_id = self._monitor_data.get("target_id")
        target_address = self._monitor_data.get("target_address", "Target")
        if not target_id:
            self.notify("No target info available.", severity="warning", timeout=3)
            return
        self.app.push_screen(
            MonitorsScreen(title=f"Monitors — Target: {target_address}", filter_target_id=target_id)
        )


# ---------------------------------------------------------------------------
# App
# ---------------------------------------------------------------------------
class NetOpsApp(App):
    CSS = """
    Screen {
        background: $surface;
    }

    #main {
        padding: 1 2;
    }

    #title {
        padding: 0 1;
        margin-bottom: 1;
        color: $text;
        background: $primary-darken-2;
    }

    #subtitle {
        padding: 0 1;
        margin-bottom: 1;
    }

    #summary {
        padding: 0 1;
        margin-bottom: 1;
    }

    #loader {
        margin: 4 0;
        color: $accent;
    }

    #plot {
        height: 45%;
        border: round $primary;
        margin-bottom: 1;
    }

    DataTable {
        height: 1fr;
        border: round $primary;
    }

    DataTable > .datatable--header {
        background: $primary;
        color: $text;
        text-style: bold;
    }

    DataTable > .datatable--cursor {
        background: $accent;
        color: $text;
    }

    Header {
        background: $primary-darken-1;
    }

    Footer {
        background: $primary-darken-2;
    }
    """

    TITLE = "NetOps Portal"
    SUB_TITLE = API_BASE_URL

    def on_mount(self) -> None:
        self.push_screen(
            MonitorsScreen(title="Down Monitors", params={"current_loss": 100, "is_active": 1})
        )

    def pop_screen_all_and_home(self) -> None:
        """Clear the entire screen stack and return to the home (Down Monitors) screen."""
        while len(self.screen_stack) > 1:
            self.pop_screen()
        self.push_screen(
            MonitorsScreen(title="Down Monitors", params={"current_loss": 100, "is_active": 1})
        )


if __name__ == "__main__":
    NetOpsApp().run()
