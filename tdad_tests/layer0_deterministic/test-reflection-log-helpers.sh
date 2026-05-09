#!/usr/bin/env bash
set -euo pipefail
# Test harness for reflection-log-helpers.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_PATH="$SCRIPT_DIR/../scripts/lib/reflection-log-helpers.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# shellcheck source=/dev/null
source "$LIB_PATH"

# Simple assertion helpers
fail() { echo "FAIL: $*" >&2; exit 1; }
assert_eq() { [ "$1" = "$2" ] || fail "expected '$2' got '$1'"; }

test_split_entries_on_empty_log() {
  local count
  count=$(split_entries "$FIXTURES_DIR/reflection-log-empty.md" | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "0"
}

test_split_entries_on_single_entry() {
  local count
  count=$(split_entries "$FIXTURES_DIR/reflection-log-single-entry.md" | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "1"
}

test_parse_promoted_agents_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-agents.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "AGENTS.md STYLE: \"Multi-repo scheduled agents\""
}
test_parse_promoted_harness_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-harness.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "HARNESS.md: Reflections via PR workflow"
}
test_parse_promoted_aged_out_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-aged-out.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "aged-out, no promotion warranted"
}
test_parse_promoted_absent() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-single-entry.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" ""
}
test_parse_promoted_malformed_returns_empty() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-malformed.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" ""
}

test_parse_promoted_supersede_form() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-supersede.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "superseded by 2026-04-15"
}

test_parse_promoted_trims_trailing_whitespace() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-trailing-space.md")
  local rhs; rhs=$(parse_promoted "$entry")
  assert_eq "$rhs" "AGENTS.md STYLE: \"Multi-repo scheduled agents\""
}

test_extract_field_date() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-single-entry.md")
  local val; val=$(extract_field "$entry" "Date")
  assert_eq "$val" "2026-01-15"
}
test_extract_field_signal() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-promoted-agents.md")
  local val; val=$(extract_field "$entry" "Signal")
  assert_eq "$val" "workflow"
}
test_resolve_year() {
  local entry; entry=$(cat "$FIXTURES_DIR/reflection-log-single-entry.md")
  local year; year=$(resolve_year "$entry")
  assert_eq "$year" "2026"
}

test_bounded_entries_count_is_inclusive_of_max() {
  # 60 synthetic entries; ask for last 50 OR last 1000 days. Day window dominates → 60.
  local count
  count=$(bounded_entries "$FIXTURES_DIR/reflection-log-many-entries.md" 50 1000 \
          | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "60"
}
test_bounded_entries_day_window_clips() {
  # 60 entries Feb-Apr; ask for last 50 entries OR 7 days from "today" (script run date).
  # Most recent entry is 2026-04-01, all 60 are >7 days old, but count window says 50.
  local count
  count=$(bounded_entries "$FIXTURES_DIR/reflection-log-many-entries.md" 50 7 \
          | grep -c "^---ENTRY---$" || true)
  assert_eq "$count" "50"
}

test_split_entries_on_empty_log
test_split_entries_on_single_entry
test_parse_promoted_agents_form
test_parse_promoted_harness_form
test_parse_promoted_aged_out_form
test_parse_promoted_absent
test_parse_promoted_malformed_returns_empty
test_parse_promoted_supersede_form
test_parse_promoted_trims_trailing_whitespace
test_extract_field_date
test_extract_field_signal
test_resolve_year
test_bounded_entries_count_is_inclusive_of_max
test_bounded_entries_day_window_clips
echo "All tests passed."
