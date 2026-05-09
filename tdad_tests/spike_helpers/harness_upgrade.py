"""harness-upgrade helper: diff plugin template vs project HARNESS.md.

The ``/harness-upgrade`` command identifies new content in the plugin's
HARNESS.md template that the project's HARNESS.md doesn't yet have.
Procedural core: load both files, find the section headings each
declares, return the headings present in the template but missing
from the project. The model-mediated wrapper presents each new item
for selective adoption.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

from .markdown import split_sections


@dataclass
class UpgradeDiff:
    """Section-level diff between two HARNESS.md files."""

    new_headings: list[str] = field(default_factory=list)
    """Headings in the template that the project's HARNESS.md lacks."""

    removed_headings: list[str] = field(default_factory=list)
    """Headings the project has that the template no longer ships.
    Surfaced for inspection but not auto-removed — the project's
    customisations may be deliberate."""


def diff_harness(template_text: str, project_text: str) -> UpgradeDiff:
    """Compare two HARNESS.md files at the section level."""
    template_sections = set(split_sections(template_text).keys())
    project_sections = set(split_sections(project_text).keys())
    new = sorted(template_sections - project_sections)
    removed = sorted(project_sections - template_sections)
    return UpgradeDiff(new_headings=new, removed_headings=removed)


def compute_upgrade_diff(
    template_path: Path, project_path: Path
) -> UpgradeDiff:
    """End-to-end: read both files, return the diff."""
    if not template_path.exists():
        raise FileNotFoundError(
            f"Plugin HARNESS.md template not found at {template_path!r}. "
            "The marketplace cache may need refreshing."
        )
    if not project_path.exists():
        raise FileNotFoundError(
            f"Project HARNESS.md not found at {project_path!r}. "
            "Run /harness-init first."
        )
    return diff_harness(
        template_path.read_text(encoding="utf-8"),
        project_path.read_text(encoding="utf-8"),
    )
