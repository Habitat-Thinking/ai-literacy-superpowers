#!/usr/bin/env python3
"""
rewrite-relative-links.py — relative-path-aware link rewriter for docs reorgs.

Reads a move-map TSV (`<old-relative>\t<new-relative>` rows, paths from repo
root). For every markdown file under docs/, parses each `[label](target.md)`
link, resolves the target to an absolute docs path using the source file's
*current* location, then rewrites the link relative to the source file's
*new* location (if the source itself moved) and to the target's *new* location
(if the target moved).

This handles the post-MkDocs world where Jekyll's `{% link %}` tags have been
replaced with markdown-relative links. A simple sed substitution doesn't work
because relative paths depend on both the source's and target's locations.

Usage:
    python3 scripts/migrations/rewrite-relative-links.py <move-map.tsv> [--apply]

Without --apply the script reports what it would change (dry run).
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(".").resolve()
DOCS_DIR = REPO_ROOT / "docs"

# Match markdown links to .md files (excluding mailto:, http://, https://, etc.).
# Captures: (label, target). Target may have an anchor (#section).
MD_LINK = re.compile(r"\[([^\]]*)\]\(((?!https?://|mailto:|//)[^)#]*?\.md(?:#[^)]*)?)\)")


def load_move_map(path: Path) -> dict[Path, Path]:
    """Read TSV. Return dict mapping old absolute path → new absolute path."""
    mapping: dict[Path, Path] = {}
    for line in path.read_text().splitlines():
        if not line.strip():
            continue
        parts = line.split("\t")
        if len(parts) != 2:
            continue
        old_rel, new_rel = parts[0].strip(), parts[1].strip()
        old_abs = (REPO_ROOT / old_rel).resolve()
        new_abs = (REPO_ROOT / new_rel).resolve()
        mapping[old_abs] = new_abs
    return mapping


def rewrite_links_in_file(
    source_path: Path,
    move_map: dict[Path, Path],
) -> tuple[str, int]:
    """Return (new_content, count_of_rewrites) for the given source file.

    The file's *current* location is `source_path`. After the moves are
    applied, the file's *new* location is `move_map.get(source_path, source_path)`.

    For each `[label](target.md)` link in the file:
      1. Resolve `target.md` against the source's CURRENT directory to get
         the absolute target path.
      2. If that absolute target is in the move_map, the new absolute target
         is `move_map[absolute_target]`. Else unchanged.
      3. Compute the new relative path from the source's NEW directory to the
         (possibly new) target.
      4. Substitute the link.
    """
    content = source_path.read_text()
    new_source = move_map.get(source_path.resolve(), source_path.resolve())
    new_source_dir = new_source.parent

    rewrites = 0

    def replace(match: re.Match) -> str:
        nonlocal rewrites
        label = match.group(1)
        target = match.group(2)

        # Split off anchor if present
        anchor = ""
        if "#" in target:
            target, anchor = target.split("#", 1)
            anchor = "#" + anchor

        # Resolve target relative to the source's CURRENT directory
        try:
            old_target_abs = (source_path.parent / target).resolve()
        except (OSError, ValueError):
            return match.group(0)

        # If the target moved, use its new path
        new_target_abs = move_map.get(old_target_abs, old_target_abs)

        # Compute new relative path from new_source_dir to new_target_abs
        try:
            new_rel = os.path.relpath(new_target_abs, new_source_dir)
        except ValueError:
            return match.group(0)

        new_link = f"[{label}]({new_rel}{anchor})"
        if new_link != match.group(0):
            rewrites += 1
        return new_link

    new_content = MD_LINK.sub(replace, content)
    return new_content, rewrites


def iter_markdown_files() -> list[Path]:
    """All .md files in docs/ that mkdocs would build (mkdocs.yml exclude_docs aware)."""
    excluded_prefixes = ("superpowers/",)
    excluded_files = ("_template.md", "README.md")
    out: list[Path] = []
    for p in DOCS_DIR.rglob("*.md"):
        rel = p.relative_to(DOCS_DIR).as_posix()
        if any(rel.startswith(prefix) for prefix in excluded_prefixes):
            continue
        if rel in excluded_files or rel.endswith("/_template.md"):
            continue
        out.append(p)
    return sorted(out)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("move_map", type=Path, help="TSV move-map file")
    parser.add_argument("--apply", action="store_true", help="write changes in place")
    args = parser.parse_args()

    move_map = load_move_map(args.move_map)
    if not move_map:
        print(f"Empty or unreadable move-map: {args.move_map}", file=sys.stderr)
        return 2

    files = iter_markdown_files()
    total_rewrites = 0
    files_modified = 0

    for path in files:
        new_content, n = rewrite_links_in_file(path, move_map)
        if n > 0:
            total_rewrites += n
            files_modified += 1
            if args.apply:
                path.write_text(new_content)

    verb = "would rewrite" if not args.apply else "rewrote"
    print(
        f"{verb} {total_rewrites} link(s) across {files_modified} file(s)",
        file=sys.stderr,
    )
    if not args.apply:
        print("(re-run with --apply to write changes)", file=sys.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(main())
