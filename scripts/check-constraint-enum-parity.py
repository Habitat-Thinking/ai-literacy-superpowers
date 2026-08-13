#!/usr/bin/env python3
"""Verify the convention mirrors carry every member of every constraint enum.

`check-convention-parity.py` requires each active `### ` constraint heading in
`HARNESS.md` to appear in all three convention files. Matching is a substring
test **of the heading**, so a change to a constraint's *body* — the rule text
people and agents actually follow — passes untouched while the three mirrors
keep the old wording (#511).

The dangerous case is an **enumeration**. `HARNESS.md` names a closed set of
valid values; a mirror listing five of six does not merely omit prose, it
actively misleads, and it is the shape the S6 gate found one step from
shipping: adding a seventh objection category to `HARNESS.md` would have left
four files declaring a six-value enum that the deterministic checker no longer
enforced, with every gate green.

WHY ENUMS RATHER THAN WHOLE BODIES. The mirrors legitimately **abridge**. They
drop explanatory clauses that belong in `HARNESS.md` and would be noise in an
assistant's context — 38 of 450 code-formatted literals in the rules differ
today, and most of those differences are correct. A whole-body equality check
would fail everywhere and be switched off within a week; a check that fires
only on enum members is one nobody has to argue with.

So this is deliberately narrow: it does not ask the mirrors to say the same
thing, only to offer the same *choices*.

Enums are recognised as "one of [a few words] `a`, `b`, `c`" — three or more
code-formatted literals in a run. Two-item pairs are excluded: they are
usually a contrast ("`accepted` or `rejected`" in prose) rather than a
declared vocabulary, and the false-positive cost is higher than the coverage.

No third-party dependencies (CI-friendly).
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

# Three or more code literals in a run, introduced by "one of".
ENUM = re.compile(
    r"one of(?:\s+\w+){0,4}[:\s]\s*((?:`[^`]+`(?:\s*,\s*|\s+(?:or|and)\s+)?){3,})"
)


def flatten(text: str) -> str:
    """Collapse whitespace, so a rule wrapped at 72 columns compares equal to
    the same rule on one line. The mirrors do not wrap; `HARNESS.md` does."""
    return re.sub(r"\s+", " ", text).strip()


def constraint_blocks(harness: str) -> list[tuple[str, str]]:
    """(heading, body) for each `### ` constraint inside `## Constraints`."""
    try:
        start = harness.index("\n## Constraints\n")
    except ValueError:
        return []
    section = harness[start:]
    end = section.find("\n## ", 1)
    if end != -1:
        section = section[:end]
    blocks = []
    for chunk in re.split(r"\n### ", section)[1:]:
        heading, _, body = chunk.partition("\n")
        blocks.append((heading.strip(), body))
    return blocks


def rule_text(body: str) -> str:
    """The `- **Rule**:` field, up to the next `- **` field."""
    match = re.search(r"\*\*Rule\*\*:(.*?)(?=\n- \*\*|\Z)", body, re.S)
    return flatten(match.group(1)) if match else ""


def main() -> int:
    harness = (REPO_ROOT / "HARNESS.md").read_text(encoding="utf-8")
    mirrors = {}
    for rel in CONVENTION_FILES:
        path = REPO_ROOT / rel
        if not path.is_file():
            print(f"::error::convention file missing: {rel}")
            return 1
        mirrors[rel] = flatten(path.read_text(encoding="utf-8"))

    failed = False
    enums = 0
    checks = 0

    for heading, body in constraint_blocks(harness):
        rule = rule_text(body)
        if not rule:
            continue
        for run in ENUM.findall(rule):
            members = re.findall(r"`([^`]+)`", run)
            enums += 1
            for rel, text in mirrors.items():
                for member in members:
                    checks += 1
                    if f"`{member}`" not in text:
                        print(
                            f"::error file={rel}::constraint '{heading}' offers "
                            f"`{member}` as a valid value; {rel} does not list it"
                        )
                        failed = True

    if failed:
        print(
            "\nConstraint enum parity FAILED. HARNESS.md declares a set of valid "
            "values that a convention mirror does not offer. A mirror listing "
            "five of six does not omit prose — it misleads about what is "
            "allowed. Mirrors may abridge explanation; they may not abridge a "
            "vocabulary."
        )
        return 1

    print(
        f"Constraint enum parity passed ({enums} enums, {checks} member checks "
        f"across {len(CONVENTION_FILES)} convention files)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
