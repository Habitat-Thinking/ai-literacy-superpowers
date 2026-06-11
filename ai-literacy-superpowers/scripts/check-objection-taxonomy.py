#!/usr/bin/env python3
"""Verify every objection record uses the canonical advocatus-diaboli taxonomy.

The advocatus-diaboli charter (skills/advocatus-diaboli/SKILL.md) defines ONE
six-category set used in BOTH spec and code mode — only the per-mode weighting
differs. The 2026-04-19 taxonomy migration
(docs/superpowers/specs/2026-04-19-docs-advocatus-diaboli-and-harness-upgrade.md)
made that set canonical and retired the old `design|threat|failure|operational|
cost` + `major|minor` taxonomy. This guard is a deterministic backstop so an
objection record cannot silently drift back to the retired vocabulary — the
failure first observed in REFLECTION_LOG (2026-06-11), where the agent file and
the orchestrator's spec-mode validation still carried the old set.

It scans the YAML frontmatter of every `docs/superpowers/objections/*.md`
record and checks each objection's `category` and `severity` against the
canonical sets. No third-party dependencies (CI-friendly).
"""

from __future__ import annotations

import glob
import re
import sys

CANONICAL_CATEGORIES = {
    "premise",
    "scope",
    "implementation",
    "risk",
    "alternatives",
    "specification quality",
}
CANONICAL_SEVERITIES = {"critical", "high", "medium", "low"}

# The taxonomy migration landed 2026-04-19. Objection records authored on or
# before that day legitimately use the retired taxonomy (the migration spec's
# OWN objection record is the canonical example), so they are grandfathered.
# Records dated after the migration must use the canonical set.
MIGRATION_CUTOVER = "2026-04-19"


def frontmatter(text: str) -> str:
    """Return the YAML frontmatter block (between the opening and next `---`)."""
    if not text.startswith("---"):
        return ""
    body = text[3:]
    end = body.find("\n---")
    return body[:end] if end != -1 else ""


def check_record(path: str) -> list[str]:
    errors: list[str] = []
    fm = frontmatter(open(path, encoding="utf-8").read())
    date_match = re.search(r"^date:\s*(\d{4}-\d{2}-\d{2})", fm, re.MULTILINE)
    if date_match and date_match.group(1) <= MIGRATION_CUTOVER:
        return errors  # pre-migration record — grandfathered
    for match in re.finditer(r"^\s+category:\s*(.+?)\s*$", fm, re.MULTILINE):
        value = match.group(1).strip().strip("\"'")
        if value not in CANONICAL_CATEGORIES:
            errors.append(f"invalid category '{value}'")
    for match in re.finditer(r"^\s+severity:\s*(.+?)\s*$", fm, re.MULTILINE):
        value = match.group(1).strip().strip("\"'")
        if value not in CANONICAL_SEVERITIES:
            errors.append(f"invalid severity '{value}'")
    return errors


def main() -> int:
    failed = False
    records = sorted(glob.glob("docs/superpowers/objections/*.md"))
    for path in records:
        for error in check_record(path):
            print(f"::error file={path}::{error}")
            failed = True
    if failed:
        print(
            "\nObjection taxonomy check FAILED. Canonical categories: "
            f"{sorted(CANONICAL_CATEGORIES)}; severities: "
            f"{sorted(CANONICAL_SEVERITIES)}. The old design/threat/failure/"
            "operational/cost + major/minor taxonomy was retired on 2026-04-19."
        )
        return 1
    print(f"Objection taxonomy check passed ({len(records)} records).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
