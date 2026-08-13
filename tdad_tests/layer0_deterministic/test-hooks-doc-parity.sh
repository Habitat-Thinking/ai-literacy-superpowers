#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for hook documentation parity
# (spec 2026-08-13-cadence-sentinels-s7-docs-design.md, §8; D2, D3).
#
# D3 IS THE ONE THAT MATTERS, and it is not about a docs page. PR #510 moved
# the constraint gate from PreToolUse to PostToolUse, because a PreToolUse
# prompt hook can only allow or deny and could not do what its own prompt asked.
# Three files kept the old claim, and one of them is `hooks.json` itself — its
# description field says PreToolUse while the same file registers PostToolUse
# eight lines below. A manifest contradicting its own registration is worse than
# a stale page: it is the artefact, not the documentation of it.
#
# S7's first revision scoped this to "no PAGE describes the constraint gate as
# PreToolUse", which the fix it had already planned satisfied by construction —
# an acceptance criterion that restates the plan rather than checking it. So D3
# is asserted over the whole repo.
#
# D2 counts. `hooks.json` declares 18; the page documented 16, and the spec's
# first revision said 17 under a heading reading "short by two". Neither the
# count nor the discrepancy was right, which is what a derived check prevents:
# nothing here pins a number.
#
# The advisory rail is why a naive heading count is always off by one —
# `lib/advisory-rail.sh` is sourced, never registered, and sat among the Stop
# hooks. It lives under `## Libraries` now, outside the event sections.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."

fail() { echo "FAIL: $*" >&2; exit 1; }

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

"$PY" - "$ROOT" <<'HARNESS_EOF'
import json, os, re, sys

root = sys.argv[1]
hooks_json = os.path.join(root, "ai-literacy-superpowers", "hooks", "hooks.json")
page = os.path.join(root, "docs", "plugins", "ai-literacy-superpowers", "reference", "hooks.md")

errors = []

with open(hooks_json, encoding="utf-8") as fh:
    raw = fh.read()
config = json.loads(raw)

# --- D3: nothing in the repo calls the constraint gate a PreToolUse hook -----
# Derive the gate's real event from the registration rather than assuming it.
gate_event = None
for event, groups in config.get("hooks", {}).items():
    for group in groups:
        for hook in group.get("hooks", []):
            if "HARNESS.md" in str(hook.get("prompt", "")):
                gate_event = event
if gate_event is None:
    errors.append("D3: no HARNESS.md constraint-gate hook found to check against")

# The manifest's own description field must not contradict its registration.
if gate_event and re.search(r"constraint gate \(PreToolUse\)", raw):
    errors.append(
        f"D3: hooks.json description says the constraint gate is PreToolUse, "
        f"but it is registered under {gate_event}"
    )

for rel in ("README.md",
            os.path.join("docs", "plugins", "ai-literacy-superpowers", "reference", "hooks.md")):
    path = os.path.join(root, rel)
    if not os.path.isfile(path):
        continue
    with open(path, encoding="utf-8") as fh:
        for number, line in enumerate(fh, start=1):
            if re.search(r"PreToolUse\s+constraint gate|constraint gate \(PreToolUse\)", line):
                errors.append(f"D3: {rel}:{number} calls the constraint gate a PreToolUse hook")

# --- D2: the page's event sections match the registration --------------------
with open(page, encoding="utf-8") as fh:
    page_text = fh.read()

# Split the page into `## ` sections; only the event ones carry hook entries.
sections = {}
current = None
for line in page_text.splitlines():
    top = re.match(r"^##\s+(.*?)\s*$", line)
    if top:
        current = top.group(1)
        sections[current] = []
        continue
    sub = re.match(r"^###\s+(.*?)\s*$", line)
    if sub and current is not None:
        sections[current].append(sub.group(1))

EVENT_SECTIONS = {
    "PreToolUse Hooks": "PreToolUse",
    "PostToolUse Hooks": "PostToolUse",
    "Stop Hooks": "Stop",
    "SessionStart Hooks": "SessionStart",
}

declared = {event: len(
    [h for g in groups for h in g.get("hooks", [])]
) for event, groups in config.get("hooks", {}).items()}

for heading, event in EVENT_SECTIONS.items():
    if event not in declared:
        continue
    if heading not in sections:
        errors.append(f"D2: hooks.md has no '## {heading}' section, but hooks.json declares {declared[event]}")
        continue
    documented = len(sections[heading])
    if documented != declared[event]:
        errors.append(
            f"D2: hooks.json declares {declared[event]} {event} hook(s); "
            f"hooks.md documents {documented}"
        )

# --- D2c: every registered SCRIPT is named in its event section --------------
# Counting alone is not parity: a renamed or wrong entry keeps the count and
# loses the hook. Match on the script basename, which is derivable from
# hooks.json and appears in each entry's body.
section_bodies = {}
current = None
for line in page_text.splitlines():
    top = re.match(r"^##\s+(.*?)\s*$", line)
    if top:
        current = top.group(1)
        section_bodies[current] = []
        continue
    if current is not None:
        section_bodies[current].append(line)

for heading, event in EVENT_SECTIONS.items():
    body = "\n".join(section_bodies.get(heading, []))
    for group in config.get("hooks", {}).get(event, []):
        for hook in group.get("hooks", []):
            command = hook.get("command", "")
            if not command:
                continue
            script = os.path.basename(command.split()[-1])
            stem = re.sub(r"\.sh$", "", script)
            if script not in body and stem.replace("-", " ").lower() not in body.lower():
                errors.append(
                    f"D2c: {script} is registered under {event} but is not named "
                    f"in '## {heading}'"
                )

# A registered event with no section at all is the #510 failure shape.
for event in declared:
    heading = f"{event} Hooks"
    if heading not in sections:
        errors.append(f"D2: hooks.json registers {event} hooks with no '## {heading}' section")

# --- D2b: the advisory rail is not counted as a hook -------------------------
for heading in EVENT_SECTIONS:
    if any("advisory rail" in h.lower() for h in sections.get(heading, [])):
        errors.append(
            f"D2b: 'The advisory rail' is a sourced library, not a registered "
            f"hook — it must not sit under '## {heading}'"
        )

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    sys.exit(1)

total = sum(declared.values())
print(f"PASS: hooks doc parity — {total} hooks declared and documented, events agree")
HARNESS_EOF
