#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for affordance-invocation-recorder.sh (step 7). Drives the
# PostToolUse recorder with synthetic payloads and asserts the tuple shape and,
# critically, the privacy guarantees (no secrets / args / paths leak).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
R="$SCRIPT_DIR/../../ai-literacy-superpowers/hooks/scripts/affordance-invocation-recorder.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

newproj() { local d; d=$(mktemp -d); printf '%s' "$d"; }
rec() { CLAUDE_PROJECT_DIR="$1" bash "$R"; }   # reads payload on stdin
logfile() { printf '%s/observability/affordance-invocations.json' "$1"; }

# Normal Bash gh call -> tool Bash, program gh, no args.
d=$(newproj)
echo '{"session_id":"s1","tool_name":"Bash","tool_input":{"command":"gh pr create --title \"top secret\""}}' | rec "$d"
grep -q '"tool":"Bash"' "$(logfile "$d")" || fail "should record tool Bash"
grep -q '"program":"gh"' "$(logfile "$d")" || fail "should record program gh"
grep -qE 'secret|--title|create' "$(logfile "$d")" && fail "must NOT record arguments: $(cat "$(logfile "$d")")"
rm -rf "$d"

# Env-var-prefixed secret -> the secret is stripped, program is gh.
d=$(newproj)
echo '{"session_id":"s1","tool_name":"Bash","tool_input":{"command":"GH_TOKEN=ghp_supersecret gh pr list"}}' | rec "$d"
grep -q '"program":"gh"' "$(logfile "$d")" || fail "env-prefixed call should record program gh"
grep -q 'ghp_supersecret' "$(logfile "$d")" && fail "SECRET LEAKED: $(cat "$(logfile "$d")")"
rm -rf "$d"

# Path-form program -> basename only, no path.
d=$(newproj)
echo '{"session_id":"s1","tool_name":"Bash","tool_input":{"command":"/Users/alice/private/deploy.sh --env prod"}}' | rec "$d"
grep -q '"program":"deploy.sh"' "$(logfile "$d")" || fail "path-form should basename to deploy.sh"
grep -qE '/Users|alice|private|prod' "$(logfile "$d")" && fail "PATH/ARGS LEAKED: $(cat "$(logfile "$d")")"
rm -rf "$d"

# Subshell/pipeline -> program null.
d=$(newproj)
echo '{"session_id":"s1","tool_name":"Bash","tool_input":{"command":"( echo hi ) | tee x"}}' | rec "$d"
grep -q '"program":null' "$(logfile "$d")" || fail "shell syntax should record program null: $(cat "$(logfile "$d")")"
rm -rf "$d"

# MCP tool -> recorded with program null.
d=$(newproj)
echo '{"session_id":"s1","tool_name":"mcp__honeycomb__query","tool_input":{"q":"x"}}' | rec "$d"
grep -q '"tool":"mcp__honeycomb__query"' "$(logfile "$d")" || fail "should record the MCP tool"
rm -rf "$d"

# Built-in file tool -> NOT recorded (no file created, or empty).
d=$(newproj)
echo '{"session_id":"s1","tool_name":"Edit","tool_input":{"file_path":"/secret/path.txt"}}' | rec "$d"
if [ -f "$(logfile "$d")" ]; then
  [ -s "$(logfile "$d")" ] && fail "built-in Edit must not be recorded: $(cat "$(logfile "$d")")"
fi
rm -rf "$d"

# Malformed/empty payload -> silent, harmless (exit 0, nothing recorded).
d=$(newproj)
echo 'not json at all' | rec "$d"
echo "" | rec "$d"
if [ -f "$(logfile "$d")" ] && [ -s "$(logfile "$d")" ]; then fail "garbage payload must record nothing"; fi
rm -rf "$d"

# Tuple is small (atomic-append safe, well under PIPE_BUF 512).
d=$(newproj)
echo '{"session_id":"abcdef123456","tool_name":"Bash","tool_input":{"command":"git status"}}' | rec "$d"
len=$(wc -c < "$(logfile "$d")" | tr -d ' ')
[ "$len" -lt 512 ] || fail "tuple line should be < 512 bytes (got $len)"
rm -rf "$d"

# --- adversarial privacy cases (O2) ---

# Escaped quote before the program: must never leak, program collapses to null.
d=$(newproj)
printf '%s\n' '{"session_id":"s1","tool_name":"Bash","tool_input":{"command":"\"secretword\" run --token abc"}}' | rec "$d"
if [ -s "$(logfile "$d")" ]; then
  grep -q 'secretword\|--token\|abc' "$(logfile "$d")" && fail "escaped-quote command must not leak: $(cat "$(logfile "$d")")"
  grep -q '"program":null' "$(logfile "$d")" || fail "escaped-quote command should record program null"
fi
rm -rf "$d"

# Hostile session_id carrying JSON metacharacters: must be sanitised to unknown.
d=$(newproj)
printf '%s\n' '{"session_id":"s\"},{\"x\":\"y","tool_name":"Bash","tool_input":{"command":"git status"}}' | rec "$d"
grep -q '"session":"unknown"' "$(logfile "$d")" || fail "hostile session_id must sanitise to unknown: $(cat "$(logfile "$d")")"
rm -rf "$d"

# Every emitted line must be valid JSON (privacy + consumability contract).
if command -v jq >/dev/null 2>&1; then
  d=$(newproj)
  for cmd in 'gh pr list' 'GH_TOKEN=ghp_x gh x' '/a/b/c.sh --flag' '( echo ) | tee f' '"q" run'; do
    printf '{"session_id":"s1","tool_name":"Bash","tool_input":{"command":"%s"}}\n' "$cmd" | rec "$d"
  done
  printf '{"session_id":"s1","tool_name":"mcp__h__q","tool_input":{}}\n' | rec "$d"
  while IFS= read -r line; do
    printf '%s' "$line" | jq -e . >/dev/null 2>&1 || fail "emitted a non-JSON line: $line"
  done < "$(logfile "$d")"
  rm -rf "$d"
fi

echo "All affordance-recorder tests passed."
