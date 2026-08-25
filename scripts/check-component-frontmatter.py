#!/usr/bin/env python3
"""Every plugin component carries `name` and `description` in its frontmatter.

Promoted from agent-enforced to deterministic on 2026-08-25. It was declared
`agent` with `Tool: harness-enforcer` since April, and no workflow dispatches
that agent — so the constraint could not fire. The check it describes is
entirely mechanical: parse the frontmatter, look for two keys. An agent was
never needed, and declaring one meant the constraint reported nothing for four
months.
"""
import glob
import re
import sys

PATTERNS = (
    "ai-literacy-superpowers/agents/*.agent.md",
    "ai-literacy-superpowers/skills/*/SKILL.md",
    "ai-literacy-superpowers/commands/*.md",
)


def main() -> int:
    checked, bad = 0, []
    for pattern in PATTERNS:
        for path in sorted(glob.glob(pattern)):
            checked += 1
            text = open(path, encoding="utf-8").read()
            if not text.startswith("---"):
                bad.append((path, "no frontmatter block"))
                continue
            parts = text.split("---", 2)
            if len(parts) < 3:
                bad.append((path, "unterminated frontmatter"))
                continue
            fm = parts[1]
            missing = [
                key for key in ("name", "description")
                if not re.search(rf"^{key}:", fm, re.M)
            ]
            if missing:
                bad.append((path, "missing " + ", ".join(missing)))

    if not checked:
        print("FAIL: no component files matched — the patterns are wrong, "
              "and a check that examines nothing must not report a pass.")
        return 1
    for path, why in bad:
        print(f"FAIL: {path}: {why}")
    if bad:
        print(f"\n{len(bad)} of {checked} component file(s) missing frontmatter keys.")
        return 1
    print(f"component frontmatter: OK ({checked} files checked)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
