"""harness-health helper: aggregate quick-mode health signals.

Quick mode of ``/harness-health`` reads several files at the project
root (HARNESS.md, REFLECTION_LOG.md, AGENTS.md) and a couple of
directories (assessments/, observability/snapshots/) to produce an
aggregate snapshot. The deep mode dispatches agents and is out of
scope here — that is model-mediated by definition.

Quick mode is procedural: walk the inputs, count, look up, return
a structured report. This helper exposes that walk as a pure
function plus a thin file-system shim.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .markdown import get_field, split_sections


@dataclass
class HealthSnapshot:
    """Structured health-snapshot output."""

    enforcement_ratio: str | None = None
    drift_status: str | None = None
    reflection_count: int = 0
    agents_md_present: bool = False
    last_assessment_date: str | None = None
    last_snapshot_date: str | None = None


def _count_reflection_entries(text: str) -> int:
    """Count separator-delimited reflection entries.

    Project convention is one ``---`` line preceding each entry —
    the first separator after the title introduces entry 1, the
    second introduces entry 2, and so on. So the number of bare
    ``---`` lines equals the entry count. Verified against the live
    REFLECTION_LOG.md (separator count and ``Date:`` field count
    match exactly).
    """
    if not text.strip():
        return 0
    return sum(1 for line in text.split("\n") if line.strip() == "---")


def aggregate(project_root: Path) -> HealthSnapshot:
    """Walk the inputs and return an aggregate snapshot.

    Each missing input degrades gracefully — fields stay at their
    default (``None`` or ``False``/``0``). The model-mediated
    rendering layer surfaces missing-input warnings; the helper just
    reports what it found.
    """
    snapshot = HealthSnapshot()

    harness_path = project_root / "HARNESS.md"
    if harness_path.exists():
        sections = split_sections(harness_path.read_text(encoding="utf-8"))
        status = sections.get("Status")
        if status is not None:
            snapshot.enforcement_ratio = get_field(
                status.body, "Constraints enforced"
            )
            snapshot.drift_status = get_field(
                status.body, "Drift detected"
            )

    reflection_path = project_root / "REFLECTION_LOG.md"
    if reflection_path.exists():
        snapshot.reflection_count = _count_reflection_entries(
            reflection_path.read_text(encoding="utf-8")
        )

    snapshot.agents_md_present = (project_root / "AGENTS.md").exists()

    assessments_dir = project_root / "assessments"
    if assessments_dir.is_dir():
        candidates = sorted(assessments_dir.glob("*-assessment.md"))
        if candidates:
            snapshot.last_assessment_date = candidates[-1].stem.split(
                "-assessment"
            )[0]

    snapshots_dir = project_root / "observability" / "snapshots"
    if snapshots_dir.is_dir():
        candidates = sorted(snapshots_dir.glob("*-snapshot.md"))
        if candidates:
            snapshot.last_snapshot_date = candidates[-1].stem.split(
                "-snapshot"
            )[0]

    return snapshot
