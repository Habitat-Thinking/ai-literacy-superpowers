#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for sentinel roster membership (#507).
#
# WHAT WENT WRONG. `README.md`'s `#### Sentinels (N)` heading and
# `skills/sentinel-design/SKILL.md`'s roster table were both still at 5 after
# S2, S3 and S4 had each shipped a `role: sentinel` agent. Three slices of
# drift — and each of those slices DID update `explanation/sentinels.md`, and
# missed the other two. Nobody was careless; there were three places and one
# habit.
#
# Which agents are sentinels is a DERIVED fact: exactly the set of
# `agents/*.agent.md` carrying `role: sentinel`, which
# `scripts/sentinel-integrity-check.sh` already enumerates on every PR.
# AGENTS.md's promoted decision says harness artefacts derive from the source of
# truth rather than pinning a copy of it, and the same rule had already caught
# the README count badges twice in this epic.
#
# MEMBERSHIP, NOT GENERATION. The three rosters have different jobs — the
# conceptual page, the authoring guide's worked examples, the shop window — and
# each carries a per-agent "Guards" column and narrative prose no generator
# would write well. A check that treated them as one list would be right about
# membership and wrong about everything else. So this asserts only the part
# worth enforcing: every sentinel appears, and nothing else claims to be one.
#
# Nothing here pins a number. The count in the README heading is compared
# against the derived set, not against a literal.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."

fail() { echo "FAIL: $*" >&2; exit 1; }

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

"$PY" - "$ROOT" <<'HARNESS_EOF'
import glob, os, re, sys

root = sys.argv[1]
agents_dir = os.path.join(root, "ai-literacy-superpowers", "agents")

errors = []


def frontmatter(text):
    if not text.startswith("---"):
        return ""
    body = text[3:]
    end = body.find("\n---")
    return body[:end] if end != -1 else ""


# --- the source of truth -----------------------------------------------------
sentinels = set()
for path in sorted(glob.glob(os.path.join(agents_dir, "*.agent.md"))):
    with open(path, encoding="utf-8") as fh:
        fm = frontmatter(fh.read())
    if re.search(r"^role:\s*sentinel\s*$", fm, re.MULTILINE):
        name = re.search(r"^name:\s*(\S+)", fm, re.MULTILINE)
        if name:
            sentinels.add(name.group(1).strip())

if not sentinels:
    print("FAIL: no role: sentinel agents found — the derivation source is missing",
          file=sys.stderr)
    sys.exit(1)

# Every agent name, so a roster row naming a real-but-non-sentinel agent is
# reported differently from one naming nothing at all.
all_agents = set()
for path in sorted(glob.glob(os.path.join(agents_dir, "*.agent.md"))):
    with open(path, encoding="utf-8") as fh:
        name = re.search(r"^name:\s*(\S+)", frontmatter(fh.read()), re.MULTILINE)
    if name:
        all_agents.add(name.group(1).strip())


def roster_rows(path, start_pattern, end_pattern=None):
    """Agent names in the first-column cells of the roster table at `path`."""
    with open(path, encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    try:
        start = next(i for i, ln in enumerate(lines) if re.search(start_pattern, ln))
    except StopIteration:
        return None
    names = []
    for line in lines[start:]:
        if end_pattern and re.search(end_pattern, line) and names:
            break
        row = re.match(r"^\|\s*`?([a-z][a-z0-9-]*)`?\s*\|", line)
        if row:
            names.append(row.group(1))
        elif names and not line.startswith("|") and line.strip():
            break
    return names


ROSTERS = [
    ("README.md", r"^####\s+Sentinels\s*\(", r"^####\s+(?!Sentinels)"),
    (os.path.join("ai-literacy-superpowers", "skills", "sentinel-design", "SKILL.md"),
     r"^##\s+The roster", r"^##\s+(?!The roster)"),
    (os.path.join("docs", "plugins", "ai-literacy-superpowers", "explanation", "sentinels.md"),
     r"^##\s+The roster", r"^##\s+(?!The roster)"),
]

for rel, start, end in ROSTERS:
    path = os.path.join(root, rel)
    if not os.path.isfile(path):
        errors.append(f"{rel} not found")
        continue
    names = roster_rows(path, start, end)
    if names is None:
        errors.append(f"{rel}: no roster table found at {start!r}")
        continue
    listed = set(names)

    for missing in sorted(sentinels - listed):
        errors.append(f"{rel}: sentinel '{missing}' is missing from the roster")
    for extra in sorted(listed - sentinels):
        if extra in all_agents:
            errors.append(
                f"{rel}: roster lists '{extra}', which is an agent but not "
                "role: sentinel"
            )
        else:
            errors.append(f"{rel}: roster lists '{extra}', which is not an agent")
    if len(names) != len(listed):
        dupes = sorted({n for n in names if names.count(n) > 1})
        errors.append(f"{rel}: roster lists {dupes} more than once")

# --- the README heading's count is derived, never pinned ---------------------
readme = os.path.join(root, "README.md")
with open(readme, encoding="utf-8") as fh:
    heading = re.search(r"^####\s+Sentinels\s*\((\d+)\)", fh.read(), re.MULTILINE)
if not heading:
    errors.append("README.md: no '#### Sentinels (N)' heading found")
elif int(heading.group(1)) != len(sentinels):
    errors.append(
        f"README.md: heading says Sentinels ({heading.group(1)}), but "
        f"{len(sentinels)} agents carry role: sentinel"
    )

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    sys.exit(1)

print(
    f"PASS: sentinel roster parity — {len(sentinels)} sentinels, "
    f"present in all {len(ROSTERS)} rosters, no roster claiming a non-sentinel"
)
HARNESS_EOF
