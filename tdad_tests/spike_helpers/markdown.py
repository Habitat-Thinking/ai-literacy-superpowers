"""Shared markdown utilities for procedural-command helpers.

Several procedural commands read structured markdown files (HARNESS.md,
audit reports, cost snapshots) and extract specific sections. This
module owns the section-extraction primitive so helpers don't each
re-implement the same line-tracking logic.

The utility is deliberately scoped to level-2 sections (``## Heading``)
and inline key/value lines (``Key: value``). More elaborate markdown
parsing belongs in a real markdown library; this is the smallest
cross-helper code that earns its keep.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field


@dataclass
class Section:
    """One level-2 section from a markdown file.

    ``heading`` is the heading text without the ``## `` prefix.
    ``body_lines`` is the list of lines between this heading and the
    next level-2 heading (or end of file). Trailing blank lines are
    trimmed; leading ones are not, because they sometimes carry
    intentional whitespace structure.
    """

    heading: str
    body_lines: list[str] = field(default_factory=list)

    @property
    def body(self) -> str:
        return "\n".join(self.body_lines)


_H2_RE = re.compile(r"^##\s+(?P<heading>.+?)\s*$")


def split_sections(text: str) -> dict[str, Section]:
    """Split a markdown document into a heading -> Section map.

    Lines before the first level-2 heading are discarded. If a heading
    appears twice, the later occurrence wins — the use cases here
    don't have duplicate headings, but tolerating them is cheaper
    than failing.
    """
    sections: dict[str, Section] = {}
    current: Section | None = None
    for line in text.split("\n"):
        match = _H2_RE.match(line)
        if match:
            current = Section(heading=match.group("heading"))
            sections[current.heading] = current
            continue
        if current is not None:
            current.body_lines.append(line)

    # Trim trailing blank lines from each section's body.
    for section in sections.values():
        while section.body_lines and not section.body_lines[-1].strip():
            section.body_lines.pop()
    return sections


def get_field(body: str, field_name: str) -> str | None:
    """Extract the value after ``Field: `` in a section body.

    Used by helpers that read snapshot or status files where each
    line is ``KeyName: value``. Returns ``None`` if the field is
    absent, which the caller distinguishes from "field present but
    empty" (an empty string).

    Matching is whitespace-tolerant on both sides of the colon and
    case-sensitive on the field name (the project's snapshot
    convention is consistent about casing).
    """
    pattern = re.compile(
        rf"^\s*{re.escape(field_name)}\s*:\s*(?P<value>.*?)\s*$",
        re.MULTILINE,
    )
    match = pattern.search(body)
    if match is None:
        return None
    return match.group("value")
