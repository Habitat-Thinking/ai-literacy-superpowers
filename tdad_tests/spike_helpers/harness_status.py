"""harness-status helper: parse HARNESS.md Status section.

The ``/harness-status`` command's procedural core is reading the
``## Status`` section of HARNESS.md and surfacing the same fields as
a quick dashboard. The model-mediated wrapping (asking the user to
run /harness-audit if the harness is missing, formatting cosmetic
output) is not testable; the parsing of the Status section is.

Phase 2 design pattern applied: pure parsing function + thin
file-reading shim. Tests target the parsing function with fixture
input.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .markdown import get_field, split_sections


@dataclass
class HarnessStatus:
    """Structured view of HARNESS.md's Status section.

    Fields mirror the snapshot template's documented field names. Any
    field absent from the section becomes ``None`` — the caller
    decides what to surface vs flag.
    """

    last_audit: str | None = None
    constraints_enforced: str | None = None
    gc_active: str | None = None
    drift_detected: str | None = None


def parse_status(harness_text: str) -> HarnessStatus:
    """Extract Status fields from HARNESS.md content.

    Returns ``HarnessStatus`` with every documented field populated
    or ``None``. Fields that exist but are empty come back as empty
    strings so the caller can distinguish "absent" from "blank".
    """
    sections = split_sections(harness_text)
    status_section = sections.get("Status")
    if status_section is None:
        return HarnessStatus()
    body = status_section.body
    return HarnessStatus(
        last_audit=get_field(body, "Last audit"),
        constraints_enforced=get_field(body, "Constraints enforced"),
        gc_active=get_field(body, "Garbage collection active"),
        drift_detected=get_field(body, "Drift detected"),
    )


def read_status(harness_path: Path) -> HarnessStatus:
    """End-to-end: read HARNESS.md and return its Status."""
    if not harness_path.exists():
        raise FileNotFoundError(
            f"HARNESS.md not found at {harness_path!r}. "
            "Run /harness-init to set up a harness first."
        )
    return parse_status(harness_path.read_text(encoding="utf-8"))
