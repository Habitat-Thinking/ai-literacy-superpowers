#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the sentinel usage path (#519).
#
# WHAT WENT WRONG. The sentinel documentation was written for people who BUILD
# sentinels rather than people who USE them. `explanation/sentinels.md` — the
# canonical page for the category, 219 lines — carried exactly one how-to link,
# and it pointed at `design-a-sentinel.md`, a guide to authoring one. Its roster
# columns were `Agent | Guards | Signature evidence`, the third being proof that
# the agent qualifies. Two of its eight sections were explicitly for authors.
#
# The result: a reader who had just learned what the nine sentinels are had
# almost no path onward. `reference/agents.md` named the command for two of
# them. Nothing anywhere answered "which one should I reach for, and when".
#
# WHAT THIS ASSERTS, AND WHY IT IS DERIVED. Three relations, each read from both
# ends so no list is pinned anywhere:
#
#   sentinel  <- `role: sentinel` frontmatter in agents/*.agent.md
#   command   <- the `Agents dispatched` field in reference/commands.md
#   guide     <- the usage table in explanation/sentinels.md
#
# The command relation is the one worth noting: reference/commands.md already
# declared which agent each command dispatches, so the mapping existed and
# nothing consumed it. Deriving from it means a new sentinel with a new command
# is covered the day both are documented, and a renamed command fails here
# rather than silently pointing readers at nothing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."

fail() { echo "FAIL: $*" >&2; exit 1; }

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

"$PY" - "$ROOT" <<'HARNESS_EOF'
import glob, os, re, sys

root = sys.argv[1]
agents_dir = os.path.join(root, "ai-literacy-superpowers", "agents")
commands_dir = os.path.join(root, "ai-literacy-superpowers", "commands")
docs = os.path.join(root, "docs", "plugins", "ai-literacy-superpowers")
sentinels_page = os.path.join(docs, "explanation", "sentinels.md")
commands_ref = os.path.join(docs, "reference", "commands.md")
agents_ref = os.path.join(docs, "reference", "agents.md")

errors = []


def frontmatter(text):
    if not text.startswith("---"):
        return ""
    body = text[3:]
    end = body.find("\n---")
    return body[:end] if end != -1 else ""


# --- source of truth 1: who is a sentinel ------------------------------------
sentinels = set()
for path in sorted(glob.glob(os.path.join(agents_dir, "*.agent.md"))):
    with open(path, encoding="utf-8") as fh:
        fm = frontmatter(fh.read())
    if re.search(r"^role:\s*sentinel\s*$", fm, re.MULTILINE):
        name = re.search(r"^name:\s*(\S+)", fm, re.MULTILINE)
        if name:
            sentinels.add(name.group(1).strip())
if not sentinels:
    print("FAIL: no role: sentinel agents found", file=sys.stderr)
    sys.exit(1)

# --- source of truth 2: which command dispatches it ---------------------------
# The field is not consistently backticked, so match bare words too.
dispatch = {}
current = None
with open(commands_ref, encoding="utf-8") as fh:
    for line in fh:
        heading = re.match(r"^###\s+(/[a-z-]+)", line)
        if heading:
            current = heading.group(1)
            continue
        field = re.match(r"^-\s+\*\*Agents dispatched\*\*:\s*(.+)$", line)
        if field and current:
            for agent in re.findall(r"[a-z][a-z-]{2,}", field.group(1).replace("`", "")):
                dispatch.setdefault(agent, set()).add(current)

# --- U1: every sentinel has a documented command that exists ------------------
for name in sorted(sentinels):
    commands = dispatch.get(name)
    if not commands:
        errors.append(
            f"U1: sentinel '{name}' is dispatched by no command in "
            "reference/commands.md — a reader cannot learn how to run it"
        )
        continue
    for command in sorted(commands):
        target = os.path.join(commands_dir, command.lstrip("/") + ".md")
        if not os.path.isfile(target):
            errors.append(
                f"U1: reference/commands.md says {command} dispatches '{name}', "
                f"but {os.path.relpath(target, root)} does not exist"
            )

# --- U2: the usage table names every sentinel, its command and its guide ------
with open(sentinels_page, encoding="utf-8") as fh:
    page = fh.read()

section = re.search(r"\n##\s+Using them\s*\n(.*?)(?=\n##\s|\Z)", page, re.S)
if not section:
    errors.append(
        "U2: explanation/sentinels.md has no '## Using them' section — the "
        "category page must answer which sentinel to reach for, not only what "
        "one is"
    )
else:
    body = section.group(1)
    for name in sorted(sentinels):
        if f"`{name}`" not in body:
            errors.append(f"U2: '{name}' is missing from the Using them table")
            continue
        row = next((ln for ln in body.splitlines() if f"`{name}`" in ln), "")
        for command in sorted(dispatch.get(name, [])):
            if command not in row:
                errors.append(
                    f"U2: the '{name}' row does not name its command {command}"
                )
        if "how-to/" not in row:
            errors.append(f"U2: the '{name}' row links to no how-to guide")

# --- U3: every guide the table links to exists --------------------------------
for target in re.findall(r"\.\./how-to/([a-z0-9-]+\.md)", page):
    if not os.path.isfile(os.path.join(docs, "how-to", target)):
        errors.append(f"U3: sentinels.md links to how-to/{target}, which does not exist")

# --- U4: each sentinel's agents.md entry names its command --------------------
# Someone reading the reference entry for an agent should not have to go
# elsewhere to learn how to run it.
with open(agents_ref, encoding="utf-8") as fh:
    agents_text = fh.read()
for name in sorted(sentinels):
    entry = re.search(rf"\n###\s+{re.escape(name)}\s*\n(.*?)(?=\n###\s|\Z)", agents_text, re.S)
    if not entry:
        errors.append(f"U4: reference/agents.md has no '### {name}' entry")
        continue
    if not any(c in entry.group(1) for c in dispatch.get(name, [])):
        commands = ", ".join(sorted(dispatch.get(name, []))) or "(none known)"
        errors.append(
            f"U4: the reference/agents.md entry for '{name}' never names its "
            f"command ({commands})"
        )

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    sys.exit(1)

print(
    f"PASS: sentinel usage path — {len(sentinels)} sentinels, each with a "
    "command that exists, a row in Using them, and a guide"
)
HARNESS_EOF
