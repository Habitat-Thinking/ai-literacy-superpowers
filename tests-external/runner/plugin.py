"""Plugin component discovery for the test suite.

Tests need to walk the packaged plugin's three component types — agents,
skills, and commands — to validate frontmatter, locate files, and
parametrise across the full inventory. This module centralises that
walking so individual tests do not each reimplement directory traversal
and frontmatter parsing.

Why a dedicated module rather than inline glob calls? Because the
*shape* of plugin layout is the kind of thing that drifts: today agents
live in ``agents/*.agent.md``, but a future plugin reorg might move them
into ``agents/<name>/agent.md``. When the layout changes, every test
should pick up the change from one place, not from a dozen ad hoc paths.

The module deliberately knows nothing about test assertions — it only
knows how to find components and read their frontmatter. Anything more
opinionated belongs in the tests themselves.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator

import yaml


@dataclass(frozen=True)
class Component:
    """A single plugin component (agent, skill, or command).

    The ``frontmatter`` field is whatever could be extracted — the full
    YAML mapping if parsing succeeded, or a best-effort fallback from
    line-by-line regex if YAML parsing failed. The ``parse_error`` field
    is the human-readable reason YAML parsing failed (``None`` on
    success). Splitting these two fields lets enumeration tests work
    even when individual files are malformed, and lets a separate
    structural test assert "every component has parseable frontmatter"
    against the same data.
    """

    name: str
    """Component identifier as it appears in the YAML ``name:`` field."""

    component_type: str
    """One of ``agent``, ``skill``, ``command``, ``hook``."""

    path: Path
    """Absolute path to the component's primary markdown file."""

    frontmatter: dict
    """Parsed YAML frontmatter, or best-effort fallback if parsing failed."""

    parse_error: str | None = None
    """Reason YAML parsing failed, if any. ``None`` on success."""


# Match a simple ``key: value`` line at the start of a YAML document.
# Used by the fallback parser when strict YAML parsing fails — it
# extracts what it can rather than abandoning the whole file.
_SIMPLE_KV_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_-]*)\s*:\s*(.*)$")


def _read_frontmatter(file: Path) -> tuple[dict, str | None]:
    """Return the YAML frontmatter at the top of a markdown file.

    Returns ``(frontmatter, parse_error)`` where ``parse_error`` is
    ``None`` on success and a human-readable message otherwise. This
    deliberately does *not* raise on malformed YAML, because the spike
    is exercising the plugin's real components — and at least one
    component (assessor.agent.md) carries a multi-line description
    with embedded colons that strict YAML cannot parse. Treating the
    malformation as data lets a dedicated test surface it as a real
    finding rather than crashing enumeration.

    The fallback parser is line-by-line regex: it extracts the first
    occurrence of any ``key: value`` line that does not contain
    obvious continuation markers. This catches the most common keys
    (``name``, ``description``) even from frontmatter that strict YAML
    rejects. It is intentionally simple — anything cleverer hides
    the malformation that the structural test is meant to catch.
    """
    text = file.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return {}, None

    lines = text.split("\n")
    closing = None
    for index, line in enumerate(lines[1:], start=1):
        if line == "---":
            closing = index
            break
    if closing is None:
        return {}, "frontmatter not closed by '---' line"

    body = "\n".join(lines[1:closing])
    try:
        parsed = yaml.safe_load(body)
        if isinstance(parsed, dict):
            return parsed, None
        return {}, "frontmatter is not a YAML mapping"
    except yaml.YAMLError as exc:
        # Fallback: extract simple key:value pairs line-by-line. Stops
        # at the first line that does not match the simple pattern,
        # which is enough to capture name and description for most
        # malformed-but-recognisable frontmatter.
        fallback: dict = {}
        for line in body.split("\n"):
            match = _SIMPLE_KV_RE.match(line)
            if not match:
                # Stop on the first non-matching line; downstream
                # content is multi-line content that the simple
                # parser cannot reason about.
                break
            key, value = match.group(1), match.group(2).strip()
            fallback[key] = value
        return fallback, f"YAML parse error: {exc.__class__.__name__}"


def list_agents(plugin_path: Path) -> Iterator[Component]:
    """Yield every agent in the plugin."""
    agents_dir = plugin_path / "agents"
    for file in sorted(agents_dir.glob("*.agent.md")):
        fm, error = _read_frontmatter(file)
        # Use the YAML name if present; otherwise fall back to the
        # filename stem. The structural test will assert that the YAML
        # name *is* present — but the listing helper itself should not
        # crash on a malformed component.
        name = fm.get("name") or file.stem.replace(".agent", "")
        yield Component(
            name=name,
            component_type="agent",
            path=file,
            frontmatter=fm,
            parse_error=error,
        )


def list_skills(plugin_path: Path) -> Iterator[Component]:
    """Yield every skill in the plugin.

    Each skill lives in its own directory containing a ``SKILL.md``.
    """
    skills_dir = plugin_path / "skills"
    for skill_dir in sorted(p for p in skills_dir.iterdir() if p.is_dir()):
        skill_file = skill_dir / "SKILL.md"
        if not skill_file.exists():
            # A directory without a SKILL.md is structurally invalid;
            # surface it as a Component anyway so the structural test
            # can fail it explicitly with a clear message.
            yield Component(
                name=skill_dir.name,
                component_type="skill",
                path=skill_file,
                frontmatter={},
                parse_error="SKILL.md not found",
            )
            continue
        fm, error = _read_frontmatter(skill_file)
        yield Component(
            name=fm.get("name") or skill_dir.name,
            component_type="skill",
            path=skill_file,
            frontmatter=fm,
            parse_error=error,
        )


def list_commands(plugin_path: Path) -> Iterator[Component]:
    """Yield every slash command in the plugin."""
    commands_dir = plugin_path / "commands"
    for file in sorted(commands_dir.glob("*.md")):
        fm, error = _read_frontmatter(file)
        yield Component(
            name=fm.get("name") or file.stem,
            component_type="command",
            path=file,
            frontmatter=fm,
            parse_error=error,
        )


def find_component(
    plugin_path: Path,
    name: str,
    component_type: str,
) -> Component:
    """Return the named component or raise ``LookupError`` if missing.

    This is the entry point used by Layer 2 and Layer 3 tests, which
    target one specific component by name rather than parametrising
    over the full inventory.
    """
    listings = {
        "agent": list_agents,
        "skill": list_skills,
        "command": list_commands,
    }
    if component_type not in listings:
        raise ValueError(
            f"Unknown component_type {component_type!r}. "
            f"Expected one of: {sorted(listings)}"
        )
    for component in listings[component_type](plugin_path):
        if component.name == name:
            return component
    raise LookupError(
        f"No {component_type} named {name!r} found under {plugin_path!r}"
    )
