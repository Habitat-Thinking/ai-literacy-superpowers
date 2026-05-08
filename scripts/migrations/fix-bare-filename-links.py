#!/usr/bin/env python3
"""
fix-bare-filename-links.py — append .md to bare-filename markdown links.

Jekyll's link resolver (and just-the-docs's permalinks) auto-strip the
`.md` extension from links, so writing `[X](getting-started)` works.
mkdocs is stricter — bare-filename links don't resolve and silently
404 on the deployed site (mkdocs logs them as INFO during build but
does not fail).

This script runs `mkdocs build` once, parses every "unrecognized
relative link" INFO line, and rewrites each link to add the `.md`
extension.

Handles:
- Bare slug:        `[X](getting-started)` → `[X](getting-started.md)`
- Path-style:       `[X](plugins/foo/getting-started)` → `[X](plugins/foo/getting-started.md)`
- With anchor:      `[X](getting-started#section)` → `[X](getting-started.md#section)`

Skips links that already end in `.md` or have a recognised file
extension.

Usage:
    python3 scripts/migrations/fix-bare-filename-links.py [--apply]
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

DOCS_DIR = Path("docs")

INFO_LINE = re.compile(
    r"Doc file '(?P<source>.+?\.md)' contains an unrecognized relative link "
    r"'(?P<target>[^']+?)', it was left as is\."
)


def collect_fixes() -> dict[Path, set[str]]:
    """Run mkdocs build and parse INFO lines into {source_path: {bare_target, ...}}."""
    env = os.environ.copy()
    # macOS/local: ensure mkdocs is on PATH
    env["PATH"] = f"{os.path.expanduser('~/Library/Python/3.9/bin')}:{env.get('PATH', '')}"
    result = subprocess.run(
        ["mkdocs", "build"],
        capture_output=True,
        text=True,
        env=env,
    )
    output = (result.stderr or "") + (result.stdout or "")

    fixes: dict[Path, set[str]] = defaultdict(set)
    for line in output.splitlines():
        m = INFO_LINE.search(line)
        if not m:
            continue
        source = DOCS_DIR / m.group("source")
        target = m.group("target")
        if target.endswith(".md") or "." in target.rsplit("/", 1)[-1]:
            # Already has an extension — skip (avoid clobbering .html, .png, etc.)
            continue
        fixes[source].add(target)
    return fixes


def apply_fixes(fixes: dict[Path, set[str]], apply: bool) -> tuple[int, int]:
    """Returns (links_rewritten, files_modified)."""
    total = 0
    files_modified = 0

    for source, targets in fixes.items():
        if not source.exists():
            print(f"  SKIP (not found): {source}", file=sys.stderr)
            continue
        content = source.read_text()
        new_content = content
        per_file = 0

        for target in sorted(targets, key=len, reverse=True):
            # Match `[label](target)` or `[label](target#anchor)` exactly
            pattern = re.compile(
                r"\]\(" + re.escape(target) + r"(?P<tail>\)|#[^)]*\))",
                re.MULTILINE,
            )
            new_content, n = pattern.subn(
                lambda m: f"]({target}.md{m.group('tail')[0:0]}{m.group('tail')[:1] if m.group('tail') == ')' else m.group('tail')}"
                if False else f"]({target}.md{m.group('tail') if m.group('tail') != ')' else ')'}",
                new_content,
            )
            # Fallback: simpler subn that handles both cases unambiguously
            if n == 0:
                # Try variant: target with /
                pattern2 = re.compile(
                    r"\]\(" + re.escape(target) + r"/?\)"
                )
                new_content, n = pattern2.subn(f"]({target}.md)", new_content)
            per_file += n

        if per_file > 0:
            total += per_file
            files_modified += 1
            if apply:
                source.write_text(new_content)
            else:
                print(f"  WOULD FIX {per_file:>2} link(s) in {source}", file=sys.stderr)

    return total, files_modified


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="write changes in place")
    args = parser.parse_args()

    fixes = collect_fixes()
    total, files_modified = apply_fixes(fixes, args.apply)

    verb = "would rewrite" if not args.apply else "rewrote"
    print(
        f"{verb} {total} bare-filename link(s) across {files_modified} file(s)",
        file=sys.stderr,
    )
    if not args.apply:
        print("(re-run with --apply to write changes)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
