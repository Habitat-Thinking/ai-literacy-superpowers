#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for hooks/scripts/commit-constraint-check.sh (issue #615).
#
# THE BUG THIS PINS. The constraint gate used to be a `type: prompt` hook whose
# first instruction was "Read HARNESS.md in the project root". A prompt hook is
# a single-turn model call over the hook input payload: it has no tool access
# and cannot read any file. So the instruction was addressed to a model with no
# mechanism to comply — the same shape #509 found one event earlier, where the
# prompt asked for a warn channel that PreToolUse does not have.
#
# What it actually returned was an improvised sentence about being unable to
# read HARNESS.md, whose wording varied per call. A prompt hook's schema is
# `{ok, reason}`, and `ok: false` ends the turn by default. So in every
# repository without a HARNESS.md — and, it turned out, in repositories WITH
# one — each edit ended the turn. A hook that could never evaluate a constraint
# was stopping work on behalf of constraints it had never read.
#
# The fix is not a better prompt. A script can say nothing by saying nothing,
# and can read the file. These tests pin the three silences and the one
# advisory, because the silences are the common case and the regression that
# would hurt.
#
# WHY SILENCE IS ASSERTED AND NOT JUST "NO CRASH". #615's whole damage was a
# hook that spoke when it had nothing to say. A test that only checked exit 0
# would have passed against the broken hook.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../../ai-literacy-superpowers/hooks/scripts/commit-constraint-check.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$HOOK" ] || fail "commit-constraint-check.sh not found at $HOOK"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# run_hook <project_dir> <file_path> — stdout of the hook, with its exit code
# asserted to be 0. The hook is advisory: a non-zero exit is itself a failure.
run_hook() {
  local project="$1" file="$2" out status
  set +e
  out=$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$file" \
    | CLAUDE_PROJECT_DIR="$project" bash "$HOOK" 2>/dev/null)
  status=$?
  set -e
  [ "$status" -eq 0 ] || fail "hook exited $status; an advisory hook must always exit 0"
  printf '%s' "$out"
}

CLEAN_SCRIPT='#!/usr/bin/env bash
set -euo pipefail
echo hello
'

# A file that breaks three commit-scoped constraints at once: no strict mode,
# an unterminated `if` (bash -n), and the shellcheck errors that follow from it.
DIRTY_SCRIPT='#!/usr/bin/env bash
if true; then
  echo hello
'

# --- C1: no HARNESS.md is silent --------------------------------------------
# The reported case. A consulting-notes repo with no harness at all had every
# edit cut off.
mkdir -p "$WORK/c1"
printf '%s' "$CLEAN_SCRIPT" > "$WORK/c1/script.sh"
out=$(run_hook "$WORK/c1" "$WORK/c1/script.sh")
[ -z "$out" ] || fail "C1: no HARNESS.md must produce no output, got: $out"

# --- C2: a HARNESS.md with no commit-scoped constraints is silent ------------
mkdir -p "$WORK/c2"
cat > "$WORK/c2/HARNESS.md" <<'EOF'
## Constraints

### Shell scripts use strict mode

- **Rule**: Every `.sh` file must contain `set -euo pipefail`
- **Enforcement**: deterministic
- **Tool**: head -15 "$f" | grep -q "set -euo pipefail"
- **Scope**: pr
EOF
printf '%s' "$DIRTY_SCRIPT" > "$WORK/c2/script.sh"
out=$(run_hook "$WORK/c2" "$WORK/c2/script.sh")
[ -z "$out" ] || fail "C2: a pr-scoped constraint must not be reported at commit, got: $out"

# --- C3: commit-scoped but not deterministic is silent -----------------------
# An agent-enforced constraint needs a reviewer with file access and judgement.
# This hook has the file and no judgement, so it says nothing rather than
# approximating one. #605 tracks the missing dispatch path for these.
mkdir -p "$WORK/c3"
cat > "$WORK/c3/HARNESS.md" <<'EOF'
## Constraints

### Scripts read like prose

- **Rule**: Every script explains why it exists, not what each line does
- **Enforcement**: agent
- **Scope**: commit
EOF
printf '%s' "$DIRTY_SCRIPT" > "$WORK/c3/script.sh"
out=$(run_hook "$WORK/c3" "$WORK/c3/script.sh")
[ -z "$out" ] || fail "C3: an agent-enforced constraint must not be evaluated here, got: $out"

# --- the fixture the remaining cases share -----------------------------------
mkdir -p "$WORK/c4"
cat > "$WORK/c4/HARNESS.md" <<'EOF'
## Constraints

### Shell scripts pass syntax check

- **Rule**: All `.sh` files must pass `bash -n` without errors
- **Enforcement**: deterministic
- **Tool**: find . -name "*.sh" -exec bash -n {} +
- **Scope**: commit

### Shell scripts use strict mode

- **Rule**: Every `.sh` file must contain `set -euo pipefail` within
  the first 15 lines
- **Enforcement**: deterministic
- **Tool**: head -15 "$f" | grep -q "set -euo pipefail"
- **Scope**: commit

## Cadence

- **Scope**: commit
EOF

# --- C4: a clean file under real constraints is silent -----------------------
# Returning nothing is the correct and common outcome — the sentence the old
# prompt could not act on.
printf '%s' "$CLEAN_SCRIPT" > "$WORK/c4/clean.sh"
out=$(run_hook "$WORK/c4" "$WORK/c4/clean.sh")
[ -z "$out" ] || fail "C4: a clean file must produce no output, got: $out"

# A non-shell file has no per-file check here: markdown is already reported by
# the PreToolUse markdownlint hook, and two hooks on one violation teach the
# reader to skim both.
printf '# notes\n' > "$WORK/c4/notes.md"
out=$(run_hook "$WORK/c4" "$WORK/c4/notes.md")
[ -z "$out" ] || fail "C4: markdown is covered by the PreToolUse hook, got: $out"

# --- C5: a violating file is reported, quoting the heading verbatim ----------
# #509's two live failures both invented a constraint name. The heading must
# come out of HARNESS.md, so it is asserted character-for-character.
printf '%s' "$DIRTY_SCRIPT" > "$WORK/c4/dirty.sh"
out=$(run_hook "$WORK/c4" "$WORK/c4/dirty.sh")
[ -n "$out" ] || fail "C5: a file breaking two commit-scoped constraints must be reported"
case "$out" in
  *'"systemMessage"'*) ;;
  *) fail "C5: advisory output must travel on systemMessage, got: $out" ;;
esac
case "$out" in
  *"Shell scripts pass syntax check"*) ;;
  *) fail "C5: must quote the 'Shell scripts pass syntax check' heading, got: $out" ;;
esac
case "$out" in
  *"Shell scripts use strict mode"*) ;;
  *) fail "C5: must quote the 'Shell scripts use strict mode' heading, got: $out" ;;
esac

# The hook must not name a constraint HARNESS.md does not declare. `Cadence` is
# a `## ` section carrying a `Scope: commit` line, placed there because the
# parser must stop at the next `## ` heading rather than sweeping the file.
case "$out" in
  *Cadence*) fail "C5: 'Cadence' is not a constraint — parsing ran past '## Constraints'" ;;
esac

# --- C6: the hook never stops the turn ---------------------------------------
# The regression that #615 is. `continue: false` and `decision: block` are the
# two fields that would reintroduce it; run_hook has already asserted exit 0.
for forbidden in '"continue"' '"decision"' '"hookSpecificOutput"'; do
  case "$out" in
    *"$forbidden"*) fail "C6: advisory output must not carry $forbidden, got: $out" ;;
  esac
done

# The output must be one JSON object — a malformed one is dropped silently by
# the runtime, which would make the hook look like it passed.
PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3
printf '%s' "$out" | "$PY" -c 'import json,sys; json.load(sys.stdin)' \
  || fail "C6: output is not valid JSON: $out"

echo "PASS: commit-constraint-check — silent on C1-C4, advisory on C5, never stops the turn"
