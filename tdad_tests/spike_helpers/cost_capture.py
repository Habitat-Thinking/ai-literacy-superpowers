"""cost-capture helper: read the most recent cost snapshot.

The ``/cost-capture`` command guides the user through provider
dashboards, records the captured spend in
``observability/costs/YYYY-MM-DD-costs.md``, and (when a previous
snapshot exists) computes the delta. The data-entry phase is
model-mediated; the snapshot reading and delta calculation are
procedural.

This helper exposes the read-and-compare side. It does not write
files — capturing fresh data requires user input the helper has no
access to.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .markdown import get_field, split_sections


@dataclass
class CostSnapshot:
    """Headline fields from a cost snapshot file."""

    capture_date: str | None = None
    total_spend: str | None = None
    primary_provider: str | None = None


def find_latest_snapshot(costs_dir: Path) -> Path | None:
    """Return the most recent ``*-costs.md`` file or ``None``."""
    if not costs_dir.is_dir():
        return None
    matches = sorted(costs_dir.glob("*-costs.md"))
    return matches[-1] if matches else None


def parse_snapshot(text: str) -> CostSnapshot:
    """Extract headline fields from a cost snapshot."""
    sections = split_sections(text)
    summary = sections.get("Summary") or sections.get("Cost Summary")
    if summary is None:
        return CostSnapshot()
    body = summary.body
    return CostSnapshot(
        capture_date=get_field(body, "Capture date"),
        total_spend=get_field(body, "Total spend"),
        primary_provider=get_field(body, "Primary provider"),
    )


def read_latest(costs_dir: Path) -> CostSnapshot | None:
    """End-to-end: find latest snapshot, parse, return."""
    path = find_latest_snapshot(costs_dir)
    if path is None:
        return None
    return parse_snapshot(path.read_text(encoding="utf-8"))
