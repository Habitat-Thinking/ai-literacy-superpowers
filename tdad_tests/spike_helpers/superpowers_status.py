"""superpowers-status helper: check expected habitat files exist.

The ``/superpowers-status`` command runs a checklist of expected files
in the project (CLAUDE.md, AGENTS.md, HARNESS.md, MODEL_ROUTING.md,
plus their canonical fallback locations) and reports OK / WARNING /
MISSING per file. The procedural core is the file-existence sweep; the
model-mediated wrapper is the dashboard formatting and any human-
readable narrative around the results.

This helper exposes the sweep as a structured result. Callers (the
test, future SDK runners) get ``StatusReport`` and decide how to
display it.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class FileStatus:
    name: str
    """Display name (e.g. ``"CLAUDE.md"``)."""

    relative_path: str
    """Path relative to the project root."""

    present: bool
    """Whether the file exists on disk."""


@dataclass
class StatusReport:
    files: list[FileStatus] = field(default_factory=list)

    @property
    def all_present(self) -> bool:
        return all(f.present for f in self.files)

    @property
    def missing(self) -> list[FileStatus]:
        return [f for f in self.files if not f.present]


# The canonical habitat files the command checks for at the project
# root. Any file absent here is a habitat gap.
HABITAT_FILES: list[tuple[str, str]] = [
    ("CLAUDE.md", "CLAUDE.md"),
    ("AGENTS.md", "AGENTS.md"),
    ("HARNESS.md", "HARNESS.md"),
    ("MODEL_ROUTING.md", "MODEL_ROUTING.md"),
    ("REFLECTION_LOG.md", "REFLECTION_LOG.md"),
]


def check_habitat(project_root: Path) -> StatusReport:
    """Run the existence sweep against a project root."""
    results: list[FileStatus] = []
    for name, relpath in HABITAT_FILES:
        path = project_root / relpath
        results.append(
            FileStatus(
                name=name,
                relative_path=relpath,
                present=path.exists(),
            )
        )
    return StatusReport(files=results)
