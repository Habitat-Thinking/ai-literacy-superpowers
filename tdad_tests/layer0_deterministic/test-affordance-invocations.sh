#!/usr/bin/env bash
# shellcheck disable=SC2016
# (SC2016 suppressed file-wide: the single-quoted HARNESS.md fixtures contain
# literal markdown backticks — the affordance Permission field — that must not
# expand. A file-level directive must precede the first command.)
set -euo pipefail
# Layer 0 test for harness-affordance-invocations.sh (step 7 analyzer).
# Hermetic via --today + fixture project dirs.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
A="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/harness-affordance-invocations.sh"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not installed — skipping analyzer test (matches the script's own jq guard)."
  exit 0
fi

fail() { echo "FAIL: $*" >&2; exit 1; }
run() { OUT=$("$A" "$@" 2>&1); }

HARNESS='# H
## Affordances
### gh-cli
- **Mode**: cli
- **Permission**: `Bash(gh *)` (allowlist)
### gh-pr-cli
- **Mode**: cli
- **Permission**: `Bash(gh pr *)` (allowlist)
### git-cli
- **Mode**: cli
- **Permission**: `Bash(git *)` (allowlist)
### honeycomb
- **Mode**: central-mcp
- **Permission**: `mcp__honeycomb__*` (allowlist)
### a-hook
- **Mode**: hook
- **Permission**: `hooks.Stop` entry
### example
<!-- affordance-example -->
- **Mode**: cli
- **Permission**: `Bash(echo *)` (allowlist)
## Status'

mkproj() {
  local d; d=$(mktemp -d); mkdir -p "$d/observability"
  printf '%s\n' "$HARNESS" > "$d/HARNESS.md"
  [ -n "${1:-}" ] && printf '%s\n' "$1" > "$d/observability/affordance-invocations.json"
  printf '%s' "$d"
}

LOG='{"tool":"Bash","program":"gh","invoker":"unknown","session":"s","ts":"2026-06-15T10:00:00Z"}
{"tool":"mcp__honeycomb__query","program":null,"invoker":"unknown","session":"s","ts":"2026-06-16T10:00:00Z"}
this line is malformed and must be skipped'

# Freshness: newest 2026-06-16, today 2026-06-17, threshold 7 -> OK.
d=$(mkproj "$LOG"); run --check=freshness --today=2026-06-17 "$d"
echo "$OUT" | grep -q "^OK: recorder active" || fail "fresh file should be OK: $OUT"
rm -rf "$d"

# Freshness: stale (today far future) -> STALE.
d=$(mkproj "$LOG"); run --check=freshness --today=2026-09-01 "$d"
echo "$OUT" | grep -q "^STALE:" || fail "old file should be STALE: $OUT"
rm -rf "$d"

# Freshness: no file -> STALE (recorder not operating).
d=$(mkproj ""); run --check=freshness --today=2026-06-17 "$d"
echo "$OUT" | grep -q "no invocation file" || fail "missing file should be STALE: $OUT"
rm -rf "$d"

# Dead-inventory: git DEAD; gh-cli + gh-pr-cli alive (conservative); honeycomb
# alive; hook + example excluded; malformed line skipped.
d=$(mkproj "$LOG"); run --check=dead-inventory --today=2026-06-17 "$d"
echo "$OUT" | grep -q "DEAD: affordance 'git-cli'" || fail "git-cli should be DEAD: $OUT"
echo "$OUT" | grep -q "gh-cli" && fail "gh-cli should be alive (gh observed): $OUT"
echo "$OUT" | grep -q "gh-pr-cli" && fail "gh-pr-cli must be alive (conservative program match): $OUT"
echo "$OUT" | grep -q "honeycomb" && fail "honeycomb should be alive (mcp observed): $OUT"
echo "$OUT" | grep -q "a-hook" && fail "hook affordance must be excluded from dead-inventory: $OUT"
echo "$OUT" | grep -q "example" && fail "example affordance must be skipped: $OUT"
rm -rf "$d"

# Dead-inventory: no file -> all matchable DEAD (gh, gh-pr, git, honeycomb).
d=$(mkproj ""); run --check=dead-inventory --today=2026-06-17 "$d"
for a in gh-cli gh-pr-cli git-cli honeycomb; do
  echo "$OUT" | grep -q "DEAD: affordance '$a'" || fail "$a should be DEAD with no log: $OUT"
done
echo "$OUT" | grep -q "a-hook" && fail "hook must stay excluded even with no log: $OUT"
rm -rf "$d"

# Window: an invocation older than the window does not keep an affordance alive.
d=$(mkproj '{"tool":"Bash","program":"git","invoker":"unknown","session":"s","ts":"2026-01-01T10:00:00Z"}')
run --check=dead-inventory --today=2026-06-17 --max-age-days=30 "$d"
echo "$OUT" | grep -q "DEAD: affordance 'git-cli'" || fail "a >30d-old git invocation should not keep git-cli alive: $OUT"
rm -rf "$d"

echo "All affordance-invocations tests passed."
