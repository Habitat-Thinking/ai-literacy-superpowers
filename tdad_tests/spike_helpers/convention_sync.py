"""Convention-sync helper: HARNESS.md → Cursor conventions.mdc.

Extracts the Context section from a HARNESS.md and renders it in the
Cursor ``.cursor/rules/conventions.mdc`` format documented in
``ai-literacy-superpowers/skills/convention-sync/SKILL.md``. The
helper does *only* this — Copilot and Windsurf outputs, plus the
constraints.mdc file, are intentionally left for Phase 3.

The point of the helper is to demonstrate that a procedural command's
logic *can* be extracted into Python and tested with fixtures. Real
production roll-out will likely move this code into
``ai-literacy-superpowers/scripts/`` and update the slash command's
markdown to invoke it (see the design spec at
``docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md``).

Three deliberate design choices worth recording:

1. **Section parsing is line-based, not Markdown-AST-based.** HARNESS.md
   uses a stable convention: ``## Context`` opens the section,
   ``## Stack`` and ``## Conventions`` are subsections under it. A
   line-based scanner that tracks heading levels is enough — pulling
   in a markdown library would be more dependency surface than the
   problem warrants for a spike.

2. **The Cursor frontmatter is hard-coded.** ``description``, ``globs``,
   and ``alwaysApply`` are the same for every project today. If/when
   per-project frontmatter becomes a real requirement, this helper can
   take a config arg.

3. **Output is a string, not a file write.** The helper returns the
   rendered text; the caller decides whether to write it to disk. This
   makes tests trivial (assert on the string) and keeps the helper
   pure.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class ContextSections:
    """The Stack and Conventions subsections of HARNESS.md's Context.

    ``stack`` and ``conventions`` are the *body* of each subsection —
    the prose and bullet lists between the subsection heading and the
    next heading at level ≤ 2. Empty list when the subsection is
    absent or empty.
    """

    stack: list[str] = field(default_factory=list)
    conventions: list[str] = field(default_factory=list)


def parse_context(harness_text: str) -> ContextSections:
    """Extract Stack and Conventions subsections from HARNESS.md text.

    Walks the document line by line, tracking the current top-level
    section (level-2 heading) and subsection (level-3 heading). When
    in ``## Context`` and a level-3 heading matches Stack or
    Conventions, the following lines are collected until the next
    heading at level ≤ 3.
    """
    in_context = False
    current_subsection: str | None = None
    sections = ContextSections()

    for line in harness_text.split("\n"):
        # Level-2 heading: top-level section change.
        if line.startswith("## ") and not line.startswith("###"):
            heading = line[3:].strip()
            in_context = heading.lower() == "context"
            current_subsection = None
            continue

        # Level-3 heading: subsection change (only meaningful inside
        # the Context section).
        if line.startswith("### "):
            if in_context:
                sub = line[4:].strip().lower()
                if sub == "stack":
                    current_subsection = "stack"
                elif sub == "conventions":
                    current_subsection = "conventions"
                else:
                    current_subsection = None
            else:
                current_subsection = None
            continue

        # Body line. Append to the current subsection if we are in one.
        if in_context and current_subsection is not None:
            target = (
                sections.stack
                if current_subsection == "stack"
                else sections.conventions
            )
            target.append(line)

    # Trim leading and trailing blank lines from each subsection so the
    # rendered output does not carry incidental whitespace.
    sections.stack = _trim_blank_edges(sections.stack)
    sections.conventions = _trim_blank_edges(sections.conventions)
    return sections


def _trim_blank_edges(lines: list[str]) -> list[str]:
    """Strip blank lines from the start and end of a list."""
    start = 0
    while start < len(lines) and not lines[start].strip():
        start += 1
    end = len(lines)
    while end > start and not lines[end - 1].strip():
        end -= 1
    return lines[start:end]


def render_cursor_conventions_mdc(context: ContextSections) -> str:
    """Render the Cursor ``conventions.mdc`` content from a Context.

    Format follows the Cursor reference in the convention-sync skill:
    YAML frontmatter with ``description``, ``globs``, ``alwaysApply``,
    then a ``# Project Conventions`` heading with ``## Stack`` and
    ``## Conventions`` subsections in that order.
    """
    parts: list[str] = [
        "---",
        "description: Project conventions synced from HARNESS.md",
        "globs: **/*",
        "alwaysApply: true",
        "---",
        "",
        "# Project Conventions",
        "",
        "## Stack",
        "",
    ]
    if context.stack:
        parts.extend(context.stack)
    else:
        parts.append("(No stack section found in HARNESS.md.)")
    parts.append("")
    parts.append("## Conventions")
    parts.append("")
    if context.conventions:
        parts.extend(context.conventions)
    else:
        parts.append("(No conventions section found in HARNESS.md.)")
    parts.append("")
    return "\n".join(parts)


def sync_cursor_conventions(harness_path: Path, output_path: Path) -> str:
    """End-to-end: read HARNESS.md, render Cursor conventions, write file.

    Convenience wrapper. The pure helpers (``parse_context`` and
    ``render_cursor_conventions_mdc``) are what the tests primarily
    cover; this function exercises the file-system path for the
    happy-path integration test.

    Returns the rendered text (also written to ``output_path``) so the
    caller can assert on it without re-reading the file.
    """
    if not harness_path.exists():
        raise FileNotFoundError(
            f"HARNESS.md not found at {harness_path!r}. "
            "convention-sync requires HARNESS.md as its single source "
            "of truth. Run /harness-init first."
        )
    text = harness_path.read_text(encoding="utf-8")
    context = parse_context(text)
    rendered = render_cursor_conventions_mdc(context)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(rendered, encoding="utf-8")
    return rendered
