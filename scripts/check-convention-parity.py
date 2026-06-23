#!/usr/bin/env python3
"""Convention-parity check — fail when a convention file is missing a constraint.

The Cursor / Copilot / Windsurf convention files are generated from
HARNESS.md by /convention-sync. They can silently fall behind by whole
constraints (content drift, not just a stale mtime) — the weekly
"Convention file sync" GC rule only runs on cadence, so drift can
accumulate across many PRs unnoticed. This deterministic PR-time gate
catches it the moment it happens: every *active* constraint heading in
HARNESS.md must appear in all three convention constraint files.

"Active" excludes the HTML-commented `<!-- Uncomment ... -->` template
blocks in the Constraints section (those are not in force). Matching is a
case-sensitive substring test of the constraint heading against the file
body — the same notion of "appears" the project's audit uses.

Exit 0 when every active constraint is present in every file; exit 1 with
a per-file list of the missing headings otherwise. Pure standard library,
no shell-tool calls — immune to the BSD/GNU coreutils divergence that
motivated the sibling "Layer 0 bash tests run on macOS and Linux"
constraint.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

CONVENTION_FILES = [
    ".cursor/rules/constraints.mdc",
    ".github/copilot-instructions.md",
    ".windsurf/rules/constraints.md",
]


def active_constraint_headings(harness_text: str) -> list[str]:
    """Return the `### ` headings inside ## Constraints, excluding commented blocks."""
    start = harness_text.index("\n## Constraints")
    end = harness_text.index("\n## Garbage Collection", start)
    section = harness_text[start:end]
    # Strip HTML comment blocks so commented-out example constraints
    # (Spec conformance, governance template, the affordance examples)
    # are not counted as active.
    section = re.sub(r"<!--.*?-->", "", section, flags=re.DOTALL)
    return re.findall(r"^### (.+)$", section, flags=re.M)


def main() -> int:
    harness = (REPO_ROOT / "HARNESS.md").read_text(encoding="utf-8")
    headings = active_constraint_headings(harness)
    if not headings:
        print("FAIL: no active constraints parsed from HARNESS.md", file=sys.stderr)
        return 1

    missing_any = False
    for rel in CONVENTION_FILES:
        path = REPO_ROOT / rel
        if not path.exists():
            print(f"FAIL: convention file missing: {rel}", file=sys.stderr)
            missing_any = True
            continue
        body = path.read_text(encoding="utf-8")
        missing = [h for h in headings if h not in body]
        if missing:
            missing_any = True
            print(f"FAIL: {rel} is missing {len(missing)} constraint(s):", file=sys.stderr)
            for h in missing:
                print(f"  - {h}", file=sys.stderr)

    if missing_any:
        print(
            "\nRun /convention-sync (or add the missing headings by hand) so the "
            "convention files mirror HARNESS.md.",
            file=sys.stderr,
        )
        return 1

    print(f"OK: all {len(headings)} active constraints present in all "
          f"{len(CONVENTION_FILES)} convention files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
