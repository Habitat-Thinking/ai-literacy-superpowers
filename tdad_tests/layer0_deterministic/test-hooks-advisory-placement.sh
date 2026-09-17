#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for hook placement in ai-literacy-superpowers/hooks/hooks.json
# (issues #509, #615).
#
# THE BUG THIS PINS, IN TWO INSTALMENTS.
#
# #509: a `type: prompt` hook on PreToolUse has exactly two channels — return
# nothing (allow the call) or return text (DENY it). There is no warn channel.
# The constraint-checking hook's prompt ended "Do not block — only warn", an
# instruction addressed to a model with no mechanism to comply. Two legitimate
# writes were denied, each citing a constraint that does not exist.
#
# The fix moved it to PostToolUse. This file's first revision then asserted the
# constraint gate MUST be a prompt hook on PostToolUse, and that its prompt must
# require a verbatim quotation. Both assertions outlived their truth.
#
# #615: the same hook ended the turn after every edit. A prompt hook is a
# single-turn model call over the hook input payload — it has NO tool access, so
# "Read HARNESS.md in the project root" was never something it could do. It had
# never read a constraint in any repository, and its `{ok:false, reason:...}`
# was an improvised apology, which by default ends the turn. Moving events did
# not fix that, because the position was never the whole defect: a prompt hook
# cannot check a file, wherever it is registered.
#
# So the constraint gate is a COMMAND hook now, and the assertions below check
# the property that survives both instalments: no hook is asked for a capability
# it does not have. H3 no longer inspects prompt wording, because there is no
# prompt — the verbatim-quoting discipline moved into the script, where
# test-commit-constraint-check.sh pins it against real fixtures.
#
# WHY A STRUCTURAL TEST AND NOT A BEHAVIOURAL ONE. The failure is a property of
# how the hook is registered, not of what a model says on any given run — the
# same hook allowed three agent-file writes during the Cadence Sentinels epic
# and denied the fourth. A test that ran the prompt would be flaky in exactly
# the way the bug is.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
HOOKS="$ROOT/ai-literacy-superpowers/hooks/hooks.json"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$HOOKS" ] || fail "hooks.json not found at $HOOKS"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

"$PY" - "$HOOKS" "$ROOT" <<'HARNESS_EOF'
import json, os, re, sys

path, root = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as fh:
    config = json.load(fh)

hooks = config.get("hooks", {})
errors = []

def entries(event):
    for group in hooks.get(event, []):
        for hook in group.get("hooks", []):
            yield group.get("matcher", ""), hook

def all_entries():
    for event in hooks:
        for matcher, hook in entries(event):
            yield event, matcher, hook

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
    if ADVISORY.search(hook.get("prompt", "")):
        errors.append(
            f"H1: PreToolUse prompt hook (matcher {matcher!r}) asks to warn "
            "without blocking, but returning text on PreToolUse IS the block."
        )

# --- H1b: no prompt hook is told to read a file ------------------------------
# #615's root cause, generalised. A prompt hook gets the hook input payload and
# nothing else. Asked to read a file it will not error — it will improvise a
# sentence about the file, which is indistinguishable from a real finding and,
# at PostToolUse, ends the turn. Work that needs a file belongs in a command
# hook; work that needs a file AND judgement belongs in an agent hook.
READS_A_FILE = re.compile(
    r"\bread\b[^.]{0,40}\b(file|\w+\.md|\w+\.json|project root|repository)\b",
    re.IGNORECASE,
)
for event, matcher, hook in all_entries():
    if hook.get("type") != "prompt":
        continue
    prompt = hook.get("prompt", "")
    if READS_A_FILE.search(prompt):
        errors.append(
            f"H1b: {event} prompt hook (matcher {matcher!r}) instructs the model "
            "to read a file, but prompt hooks have no tool access. Use a command "
            "hook (#615)."
        )

# --- H2: the constraint gate exists, as a command hook on PostToolUse --------
# The fix must relocate the check, not delete it. A repo that silently lost its
# commit-scoped constraint warning would pass H1 for the wrong reason.
gate = None
gate_event = None
for event, _, hook in all_entries():
    command = str(hook.get("command", ""))
    if "commit-constraint-check.sh" in command:
        gate, gate_event = hook, event

if gate is None:
    errors.append("H2: the commit-constraint gate has gone missing entirely")
else:
    if gate_event != "PostToolUse":
        errors.append(
            f"H2: the constraint gate must run after the write, found on {gate_event}"
        )
    if gate.get("type") != "command":
        errors.append(
            f"H2: the constraint gate must be a command hook, found "
            f"{gate.get('type')!r} — a prompt hook cannot read HARNESS.md (#615)"
        )

# --- H3: the gate's script is on disk and executable -------------------------
# A registered hook pointing at a missing script fails silently, which is the
# same end state as having no gate.
if gate is not None:
    script = os.path.basename(str(gate.get("command", "")).split()[-1])
    script_path = os.path.join(
        root, "ai-literacy-superpowers", "hooks", "scripts", script
    )
    if not os.path.isfile(script_path):
        errors.append(f"H3: the gate registers {script}, which is not on disk")
    elif not os.access(script_path, os.X_OK):
        errors.append(f"H3: {script} is registered but not executable")

# --- H4: every hook declares a type and a timeout ----------------------------
# Cheap structural guard; a typo in `type` silently disables a hook.
VALID_TYPES = {"prompt", "command"}
for event, _, hook in all_entries():
    if hook.get("type") not in VALID_TYPES:
        errors.append(f"H4: {event} hook has invalid type {hook.get('type')!r}")
    if not isinstance(hook.get("timeout"), int):
        errors.append(f"H4: {event} hook is missing an integer timeout")

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    sys.exit(1)

print("PASS: hook placement — no hook is asked for a capability it does not have")
HARNESS_EOF
