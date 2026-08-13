#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for hook placement in ai-literacy-superpowers/hooks/hooks.json
# (issue #509).
#
# THE BUG THIS PINS. A `type: prompt` hook on PreToolUse has exactly two
# channels: return nothing (allow the call) or return text (DENY it, surfaced
# to the user as `PreToolUse:Write hook error`). There is no warn channel.
#
# The constraint-checking hook's prompt ended "Do not block — only warn." That
# instruction was addressed to a model with no mechanism to comply: the text it
# returns IS the block, whatever the text says. Two legitimate writes were
# denied during the Cadence Sentinels epic, each citing a constraint that does
# not exist in HARNESS.md.
#
# It is the same failure shape the epic keeps finding — a confident sentence
# describing a capability that is not there. S5's spec claimed an
# `agent-verified` enforcement rung that was never a value of the enum; S3
# specified a `strict` mode requiring a disposition no hook could collect. Here
# a hook config asked for advisory behaviour from a blocking position.
#
# So: an advisory prompt hook belongs on PostToolUse, where the write has
# landed, the file is still uncommitted, and returned text is genuinely a
# warning. That dissolves the mismatch rather than documenting it.
#
# WHY A STRUCTURAL TEST AND NOT A BEHAVIOURAL ONE. The failure is a property of
# where the hook is registered, not of what the model says on any given run —
# the same hook allowed three agent-file writes earlier in the epic and denied
# the fourth. A test that ran the prompt would be flaky in exactly the way the
# bug is.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS="$SCRIPT_DIR/../../ai-literacy-superpowers/hooks/hooks.json"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$HOOKS" ] || fail "hooks.json not found at $HOOKS"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

"$PY" - "$HOOKS" <<'HARNESS_EOF'
import json, re, sys

path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    config = json.load(fh)

hooks = config.get("hooks", {})
errors = []

def entries(event):
    for group in hooks.get(event, []):
        for hook in group.get("hooks", []):
            yield group.get("matcher", ""), hook

# --- H1: no advisory prompt hook sits on PreToolUse --------------------------
# A prompt hook there can only allow or deny. One whose text describes warning,
# advising, or flagging is asking for a channel it does not have.
ADVISORY = re.compile(
    r"do not block|only warn|warn only|advisory|non-blocking|informational",
    re.IGNORECASE,
)
for matcher, hook in entries("PreToolUse"):
    if hook.get("type") != "prompt":
        continue
    prompt = hook.get("prompt", "")
    if ADVISORY.search(prompt):
        errors.append(
            f"H1: PreToolUse prompt hook (matcher {matcher!r}) asks to warn "
            "without blocking, but returning text on PreToolUse IS the block. "
            "Move it to PostToolUse."
        )

# --- H2: the constraint check still exists somewhere -------------------------
# The fix must relocate the hook, not delete it. A repo that silently lost its
# commit-scoped constraint warning would pass H1 for the wrong reason.
found_event = None
for event in ("PreToolUse", "PostToolUse"):
    for _, hook in entries(event):
        if "HARNESS.md" in str(hook.get("prompt", "")):
            found_event = event
if found_event is None:
    errors.append("H2: the HARNESS.md constraint check has gone missing entirely")
elif found_event != "PostToolUse":
    errors.append(f"H2: the constraint check must live on PostToolUse, found on {found_event}")

# --- H3: the prompt forbids reporting an unquoted constraint -----------------
# Both live failures invented a constraint name. The second paraphrased an
# objection out of the payload it was inspecting and reframed it as a HARNESS
# violation — it was pattern-matching on the content, not reading the file.
# The prompt must require a verbatim heading and silence when it has none.
for event in ("PreToolUse", "PostToolUse"):
    for matcher, hook in entries(event):
        prompt = str(hook.get("prompt", ""))
        if "HARNESS.md" not in prompt:
            continue
        if not re.search(r"verbatim|quote|exact", prompt, re.IGNORECASE):
            errors.append(
                "H3: the constraint prompt must require the constraint heading "
                "be quoted verbatim from HARNESS.md"
            )
        if not re.search(r"return nothing|say nothing|report nothing", prompt, re.IGNORECASE):
            errors.append(
                "H3: the constraint prompt must say to return nothing when it "
                "cannot quote a real constraint"
            )

# --- H4: every hook declares a type and a timeout ----------------------------
# Cheap structural guard; a typo in `type` silently disables a hook.
VALID_TYPES = {"prompt", "command"}
for event, groups in hooks.items():
    for group in groups:
        for hook in group.get("hooks", []):
            if hook.get("type") not in VALID_TYPES:
                errors.append(f"H4: {event} hook has invalid type {hook.get('type')!r}")
            if not isinstance(hook.get("timeout"), int):
                errors.append(f"H4: {event} hook is missing an integer timeout")

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    sys.exit(1)

print("PASS: hook placement — no advisory prompt hook holds a blocking position")
HARNESS_EOF
