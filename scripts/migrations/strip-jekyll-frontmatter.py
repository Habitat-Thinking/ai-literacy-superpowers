#!/usr/bin/env python3
"""
strip-jekyll-frontmatter.py — one-shot cleanup of Jekyll-only frontmatter fields.

After the Jekyll → MkDocs Material migration, the following frontmatter
fields are dead weight (mkdocs ignores them) but remain in 90+ docs files:

  layout, parent, grand_parent, nav_order, nav_label, has_children,
  redirect_from

The redirect_from values were already migrated to mkdocs.yml's
redirect_maps by an earlier migration script (jekyll-to-mkdocs.py).
This cleanup removes the now-vestigial frontmatter.

Preserves: title (mkdocs uses it), and any non-Jekyll fields.

Usage:
    python3 scripts/migrations/strip-jekyll-frontmatter.py [--apply]

Without --apply the script reports what it would change.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

DOCS_DIR = Path("docs/plugins")

JEKYLL_FIELDS = {
    "layout",
    "parent",
    "grand_parent",
    "nav_order",
    "nav_label",
    "has_children",
    "redirect_from",
}

FRONTMATTER = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)


def strip_jekyll_fields(frontmatter: str) -> tuple[str, int]:
    """Return (cleaned_frontmatter, fields_removed_count)."""
    lines = frontmatter.split("\n")
    out: list[str] = []
    skipping = False  # True while we're inside a multi-line block (e.g. redirect_from list)
    removed = 0

    for line in lines:
        stripped = line.lstrip()
        # Top-level key (no indentation, ends with colon)
        key_match = re.match(r"^([A-Za-z_]\S*):", line)
        if key_match:
            key = key_match.group(1)
            if key in JEKYLL_FIELDS:
                skipping = True
                removed += 1
                continue
            else:
                skipping = False
                out.append(line)
        elif skipping and (line.startswith(" ") or line.startswith("\t") or stripped.startswith("-")):
            # Continuation line of a multi-line YAML block we're dropping
            continue
        else:
            skipping = False
            out.append(line)

    return "\n".join(out).rstrip(), removed


def process_file(path: Path, apply: bool) -> int:
    """Returns number of frontmatter fields removed."""
    content = path.read_text()
    m = FRONTMATTER.match(content)
    if not m:
        return 0

    fm = m.group(1)
    rest = content[m.end():]

    new_fm, removed = strip_jekyll_fields(fm)
    if removed == 0:
        return 0

    if not new_fm.strip():
        # All frontmatter fields were Jekyll-only; remove the frontmatter block entirely
        new_content = rest.lstrip("\n")
    else:
        new_content = f"---\n{new_fm}\n---\n{rest}"

    if apply:
        path.write_text(new_content)

    return removed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="write changes in place")
    args = parser.parse_args()

    files = sorted(DOCS_DIR.rglob("*.md"))
    total_removed = 0
    files_modified = 0

    for path in files:
        n = process_file(path, args.apply)
        if n > 0:
            total_removed += n
            files_modified += 1

    verb = "would remove" if not args.apply else "removed"
    print(
        f"{verb} {total_removed} Jekyll frontmatter field(s) across {files_modified} file(s)",
        file=sys.stderr,
    )
    if not args.apply:
        print("(re-run with --apply to write changes)", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
