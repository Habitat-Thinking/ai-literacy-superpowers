#!/usr/bin/env bash
set -euo pipefail
# Commit-constraint check — runs after a Write or Edit (PostToolUse hook).
#
# Tests: tdad_tests/layer0_deterministic/test-commit-constraint-check.sh (C1–C6)
#
# Replaces the prompt hook that #615 caught ending the turn on every edit in
# any repository without a HARNESS.md. A prompt hook has no silent channel: its
# model must return something, and at PostToolUse whatever it returns is read
# as a failed check, which stops continuation. So the common case — nothing to
# report — was unreachable by construction, exactly as #509 found one event
# earlier. The fix is not a better prompt. It is a script, which can say
# nothing by saying nothing.
#
# WHAT THIS CHECKS. Only constraints HARNESS.md declares with `Scope: commit`
# and `Enforcement: deterministic`, and only those whose `Tool:` names a tool
# this script knows how to run against a single file. Anything else is skipped
# in silence rather than approximated: a hook that guesses at a constraint is
# the failure #509 documented, and a guess dressed as a citation is worse than
# no check at all.
#
# This script is advisory only — it never blocks and never stops the turn.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"

# Tool input arrives on stdin as JSON.
input=$(cat 2>/dev/null || true)

file_path=$(printf '%s' "$input" \
  | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 \
  | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

# No file to check, no HARNESS.md to check it against: the common case.
[ -n "$file_path" ] || exit 0
[ -f "$file_path" ] || exit 0
[ -f "$HARNESS_FILE" ] || exit 0

# --- which commit-scoped deterministic constraints are declared? -------------
#
# Emits one `heading<TAB>tool` line per constraint in the `## Constraints`
# section carrying both `Scope: commit` and `Enforcement: deterministic`.
# Parsing stops at the next `## ` heading so a `Scope:` line elsewhere in
# HARNESS.md cannot manufacture a constraint.
declared=$(awk '
  /^## Constraints/ { inside = 1; next }
  /^## / { inside = 0 }
  !inside { next }
  /^### / {
    if (heading != "" && scope ~ /commit/ && enforcement ~ /deterministic/)
      printf "%s\t%s\n", heading, tool
    heading = substr($0, 5); scope = ""; enforcement = ""; tool = ""
    next
  }
  /\*\*Scope\*\*/       { scope = $0 }
  /\*\*Enforcement\*\*/ { enforcement = $0 }
  /\*\*Tool\*\*/        { tool = $0 }
  END {
    if (heading != "" && scope ~ /commit/ && enforcement ~ /deterministic/)
      printf "%s\t%s\n", heading, tool
  }
' "$HARNESS_FILE")

# No commit-scoped deterministic constraints: nothing to say.
[ -n "$declared" ] || exit 0

# heading_for <pattern> — the verbatim `### ` heading of a declared constraint
# whose Tool line matches, or empty. The heading is what gets quoted back, so
# it is read from the file rather than written into this script.
heading_for() {
  printf '%s\n' "$declared" | awk -F'\t' -v pattern="$1" \
    '$2 ~ pattern { print $1; exit }'
}

findings=()

case "$file_path" in
  *.sh)
    # `bash -n` — syntax. Cheap and exact.
    heading=$(heading_for 'bash -n')
    if [ -n "$heading" ] && ! error=$(bash -n "$file_path" 2>&1); then
      findings+=("${heading}: ${error}")
    fi

    # Strict mode within the first 15 lines.
    heading=$(heading_for 'set -euo pipefail')
    if [ -n "$heading" ] && ! head -15 "$file_path" | grep -q 'set -euo pipefail'; then
      findings+=("${heading}: no 'set -euo pipefail' in the first 15 lines of ${file_path}")
    fi

    # ShellCheck, when it is installed. When it is not, silence: an absent
    # tool is not a passing check and must not be reported as either.
    heading=$(heading_for 'shellcheck')
    if [ -n "$heading" ] && command -v shellcheck &>/dev/null; then
      if ! error=$(shellcheck --format=gcc "$file_path" 2>&1); then
        findings+=("${heading}: $(printf '%s' "$error" | head -3)")
      fi
    fi
    ;;
esac

# Markdown is deliberately absent: the PreToolUse markdownlint-check.sh already
# reports it per file, and secrets are covered by the Stop secrets-check.sh.
# Two hooks reporting one violation trains the reader to skim both.

[ ${#findings[@]} -gt 0 ] || exit 0

message="Commit-scoped constraint(s) this edit does not meet — the file is on disk and uncommitted, so this is for you to decide about:"
for finding in "${findings[@]}"; do
  message="${message}"$'\n'"- ${finding}"
done

# `systemMessage` is the advisory channel: shown to the user, exit 0, turn
# continues. Never `continue: false`, never a non-zero exit, never `decision`.
message=$(printf '%s' "$message" | tr '\n' ' ' | sed 's/"/\\"/g')
printf '{"systemMessage": "%s"}' "$message"

exit 0
