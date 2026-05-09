"""governance-health helper: read latest governance audit and summarise.

The ``/governance-health`` command's procedural core is finding the
most recent file in ``observability/governance/audit-*.md`` and
extracting the headline fields a health pulse displays. The
falling-back-to-lightweight-assessment branch (when no audit exists)
is the model-mediated wrapper; here we test the audit-summary path
that runs when an audit *does* exist.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .markdown import get_field, split_sections


@dataclass
class GovernanceSummary:
    """Headline fields from the latest governance audit."""

    audit_date: str | None = None
    constraint_count: str | None = None
    falsifiability_ratio: str | None = None
    drift_score: str | None = None
    debt_inventory_count: str | None = None


def find_latest_audit(governance_dir: Path) -> Path | None:
    """Return the most recent ``audit-*.md`` file, or ``None``.

    The command's ordering is alphabetical (audit files use
    ``audit-YYYY-MM-DD.md`` naming, which sorts chronologically), so
    a sorted glob is the right primitive.
    """
    if not governance_dir.is_dir():
        return None
    matches = sorted(governance_dir.glob("audit-*.md"))
    return matches[-1] if matches else None


def parse_summary(audit_text: str) -> GovernanceSummary:
    """Extract Summary fields from a governance audit."""
    sections = split_sections(audit_text)
    summary_section = sections.get("Summary") or sections.get(
        "Governance Summary"
    )
    if summary_section is None:
        return GovernanceSummary()
    body = summary_section.body
    return GovernanceSummary(
        audit_date=get_field(body, "Audit date"),
        constraint_count=get_field(body, "Constraint count"),
        falsifiability_ratio=get_field(body, "Falsifiability ratio"),
        drift_score=get_field(body, "Drift score"),
        debt_inventory_count=get_field(body, "Debt inventory"),
    )


def read_latest_audit_summary(
    governance_dir: Path,
) -> GovernanceSummary | None:
    """End-to-end: find latest audit, parse, return summary.

    Returns ``None`` if no audit file exists — the caller surfaces a
    "no audit found" message in the model-mediated layer.
    """
    audit_path = find_latest_audit(governance_dir)
    if audit_path is None:
        return None
    return parse_summary(audit_path.read_text(encoding="utf-8"))
