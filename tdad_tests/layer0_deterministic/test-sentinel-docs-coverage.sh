#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for sentinel documentation coverage
# (spec 2026-08-13-cadence-sentinels-s7-docs-design.md, §8.1; D1).
#
# WHY THIS EXISTS AT ALL. S7's first revision claimed the page count would be
# "derived from role: sentinel frontmatter rather than pinned". Half that
# derivation had no source: nine agents carry the tag, but nothing on disk
# linked a sentinel to the page explaining it, because pages are named for
# concepts — cadence-governance.md for carpaccio, watching-the-verifier.md for
# reservoir-warden — and never for agents.
#
# AGENTS.md is explicit that a heuristic re-derivation is the second
# anti-pattern, and that an unavoidable pin must say what makes it change. The
# cheaper and better option was to CREATE the missing relation: a `sentinels:`
# frontmatter key on every explanation page that covers one.
#
# So both sides are now derived — role: sentinel on the agent, the key on the
# page — and no literal count appears anywhere in this file. That is the same
# decision #507 asks for on the roster and #511 on the convention mirrors.
#
# The mapping is deliberately many-to-many. decision-discipline-triad.md covers
# three sentinels and the-cost-estimation-loop.md is a second page for
# cost-estimator; S7's first revision asserted a one-to-one convention by
# omitting exactly those two counterexamples.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."

fail() { echo "FAIL: $*" >&2; exit 1; }

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

"$PY" - "$ROOT" <<'HARNESS_EOF'
import glob, os, re, sys

root = sys.argv[1]
agents_dir = os.path.join(root, "ai-literacy-superpowers", "agents")
pages_dir = os.path.join(root, "docs", "plugins", "ai-literacy-superpowers", "explanation")

errors = []


def frontmatter(text):
    if not text.startswith("---"):
        return ""
    body = text[3:]
    end = body.find("\n---")
    return body[:end] if end != -1 else ""


# --- the source of truth on the agent side -----------------------------------
sentinels = set()
for path in sorted(glob.glob(os.path.join(agents_dir, "*.agent.md"))):
    with open(path, encoding="utf-8") as fh:
        fm = frontmatter(fh.read())
    if re.search(r"^role:\s*sentinel\s*$", fm, re.MULTILINE):
        name = re.search(r"^name:\s*(\S+)", fm, re.MULTILINE)
        if not name:
            errors.append(f"{os.path.basename(path)} is role: sentinel with no name")
            continue
        sentinels.add(name.group(1).strip())

if not sentinels:
    errors.append("no role: sentinel agents found — the derivation source is missing")

# --- the source of truth on the page side ------------------------------------
covered = {}
for path in sorted(glob.glob(os.path.join(pages_dir, "*.md"))):
    with open(path, encoding="utf-8") as fh:
        fm = frontmatter(fh.read())
    match = re.search(r"^sentinels:\s*\[(.*?)\]\s*$", fm, re.MULTILINE)
    if not match:
        continue
    names = [n.strip().strip("\"'") for n in match.group(1).split(",") if n.strip()]
    if not names:
        errors.append(f"{os.path.basename(path)} has an empty sentinels: key")
    for name in names:
        covered.setdefault(name, []).append(os.path.basename(path))

# --- D1a: every sentinel is explained somewhere ------------------------------
for name in sorted(sentinels):
    if name not in covered:
        errors.append(
            f"sentinel '{name}' is named by no explanation page's sentinels: key"
        )

# --- D1b: no page claims a sentinel that does not exist ----------------------
# Catches a rename on the agent side that the docs never followed — the drift
# three slices of this epic produced on the roster.
for name in sorted(covered):
    if name not in sentinels:
        errors.append(
            f"page(s) {covered[name]} claim '{name}', which is not a "
            "role: sentinel agent"
        )

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    sys.exit(1)

print(
    f"PASS: sentinel docs coverage — {len(sentinels)} sentinels, "
    f"all named by a page, no page claiming a non-sentinel"
)
HARNESS_EOF
