"""reflect helper: format a reflection entry from structured fields.

The ``/reflect`` command's procedural core is appending a reflection
entry to ``REFLECTION_LOG.md`` in the documented format. The
model-mediated wrapper is asking the user (or reading session
context) for the entry's content; the format itself is mechanical.

The Layer 0 bash tests already cover *parsing* of existing
REFLECTION_LOG entries (split_entries, parse_promoted, extract_field
in reflection-log-helpers.sh). What's not covered is the *writing*
side — formatting fresh entries before they go into the log. That's
what this helper exposes.
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class ReflectionEntry:
    """The structured fields of one reflection entry."""

    date: str
    """ISO date string (YYYY-MM-DD)."""

    agent: str
    """Identifier of the agent that produced the entry."""

    task: str
    """One-sentence summary of what was worked on."""

    surprise: str
    """What was unexpected during the work."""

    proposal: str = "none"
    improvement: str = "none"
    signal: str = "none"
    constraint: str = "none"
    session_metadata: list[str] = field(default_factory=list)
    """Optional sub-bullets under Session metadata. Each becomes its
    own indented bullet line; empty list omits the section."""


def format_entry(entry: ReflectionEntry) -> str:
    """Render a ``ReflectionEntry`` as the documented log format.

    The output begins with a top-level ``---`` separator on its own
    line followed by the named bullets. Callers append the result
    to REFLECTION_LOG.md at end of file. Formatting is whitespace-
    deterministic — same input produces same output, byte-for-byte.
    """
    lines: list[str] = ["", "---", ""]
    lines.append(f"- **Date**: {entry.date}")
    lines.append(f"- **Agent**: {entry.agent}")
    lines.append(f"- **Task**: {entry.task}")
    lines.append(f"- **Surprise**: {entry.surprise}")
    lines.append(f"- **Proposal**: {entry.proposal}")
    lines.append(f"- **Improvement**: {entry.improvement}")
    lines.append(f"- **Signal**: {entry.signal}")
    lines.append(f"- **Constraint**: {entry.constraint}")
    if entry.session_metadata:
        lines.append("- **Session metadata**:")
        for item in entry.session_metadata:
            lines.append(f"  - {item}")
    return "\n".join(lines) + "\n"
