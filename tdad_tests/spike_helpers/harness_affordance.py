"""harness-affordance helper: scan config files for declared affordances.

The ``/harness-affordance discover`` subcommand scans the project's
Claude Code configuration for declared tools (permissions, hooks, MCP
servers) and emits a draft inventory entry per tool. The procedural
core is the *parsing*: read each config file, extract declared
permissions / hooks / MCP-server names. The model-mediated wrapper
fills in the human-owned governance fields (Identity, Audit trail,
Notes) — the helper deliberately stops at parsing.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class AffordanceInventory:
    """Discovered affordances grouped by source."""

    permissions_allow: list[str] = field(default_factory=list)
    """Tool/command patterns from .claude/settings.json's permissions.allow."""

    permissions_deny: list[str] = field(default_factory=list)
    hook_events: list[str] = field(default_factory=list)
    """Event names that have at least one hook registered."""
    mcp_servers: list[str] = field(default_factory=list)


def _load_json_safely(path: Path) -> dict:
    """Read a JSON file or return an empty dict if missing/malformed.

    The discoverer's whole point is to surface the configuration that
    exists; absent or malformed configs aren't fatal. The structural
    test for ``hooks.json`` (test_hooks_structural.py) is the right
    place to assert manifest validity, not this helper.
    """
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}


def discover(project_root: Path) -> AffordanceInventory:
    """Scan a project for declared affordances."""
    inventory = AffordanceInventory()

    settings_path = project_root / ".claude" / "settings.json"
    settings = _load_json_safely(settings_path)
    permissions = settings.get("permissions", {}) or {}
    inventory.permissions_allow = list(permissions.get("allow", []) or [])
    inventory.permissions_deny = list(permissions.get("deny", []) or [])

    hooks_path = project_root / ".claude" / "hooks.json"
    hooks = _load_json_safely(hooks_path)
    inventory.hook_events = sorted(
        (hooks.get("hooks") or {}).keys()
    )

    mcp_path = project_root / ".mcp.json"
    mcp = _load_json_safely(mcp_path)
    servers = mcp.get("mcpServers", {}) or {}
    inventory.mcp_servers = sorted(servers.keys())

    return inventory
