#!/usr/bin/env bash
set -euo pipefail
# Test harness for reflection-log-helpers.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Tests live in tdad_tests/layer0_deterministic/; the library under
# test ships inside the packaged plugin two levels up.
LIB_PATH="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/lib/reflection-log-helpers.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

# shellcheck source=/dev/null
source "$LIB_PATH"

# Simple assertion helpers
fail() { echo "FAIL: $*" >&2; exit 1; }
assert_eq() { [ "$1" = "$2" ] || fail "expected '$2' got '$1'"; }

# mk_workspace: create a throwaway tree wired for verify_rhs, which greps
# promotion targets relative to the current directory.
mk_workspace() {
  local ws; ws=$(mktemp -d)
  printf '## STYLE\n- Multi-repo scheduled agents\n' > "$ws/AGENTS.md"
  printf '# Project Conventions\n- Treat ports as the domain boundary\n' > "$ws/CLAUDE.md"
  mkdir -p "$ws/src" "$ws/.claude"
  printf '# Module Notes\n- Renderer wraps at column 80\n' > "$ws/src/CLAUDE.md"
  printf '## Constraints\n### Reflections via PR workflow\n' > "$ws/.claude/HARNESS.md"
  printf '%s' "$ws"
}

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
test_bounded_entries_preserves_entry_bodies() {
  # Regression (#478): the multi-line entry body must survive the tmpfile
  # round-trip through sort/awk, not collapse to empty. The count tests
  # above only assert the number of ---ENTRY--- markers, which stayed
  # correct even while every body read back blank. Assert every returned
  # entry still carries its own Date line (bodies == markers).
  local out markers dates
  out=$(bounded_entries "$FIXTURES_DIR/reflection-log-many-entries.md" 50 1000)
  markers=$(printf '%s\n' "$out" | grep -c "^---ENTRY---$" || true)
  dates=$(printf '%s\n' "$out" | grep -c "^- \*\*Date\*\*:" || true)
  assert_eq "$markers" "60"
  assert_eq "$dates" "60"
}

# --- verify_rhs promotion-target coverage (#319, #320) ---
# verify_rhs greps targets relative to cwd; a ( cd … ) subshell inherits the
# sourced functions, so each case runs against a purpose-built workspace.

test_verify_rhs_agents_form() {
  local ws; ws=$(mk_workspace)
  ( cd "$ws" && verify_rhs 'AGENTS.md STYLE: "Multi-repo scheduled agents"' ) \
    || fail "AGENTS form should verify"
  rm -rf "$ws"
}
test_verify_rhs_claude_root_form() {
  local ws; ws=$(mk_workspace)
  ( cd "$ws" && verify_rhs 'CLAUDE.md "Treat ports as the domain boundary"' ) \
    || fail "root CLAUDE.md form should verify"
  rm -rf "$ws"
}
test_verify_rhs_claude_subcomponent_form() {
  local ws; ws=$(mk_workspace)
  ( cd "$ws" && verify_rhs 'src/CLAUDE.md "Renderer wraps at column 80"' ) \
    || fail "sub-component CLAUDE.md form should verify"
  rm -rf "$ws"
}
test_verify_rhs_claude_form_negative() {
  local ws; ws=$(mk_workspace)
  ( cd "$ws" && ! verify_rhs 'CLAUDE.md "text that is not present"' ) \
    || fail "CLAUDE.md form with absent quote should not verify"
  rm -rf "$ws"
}
test_verify_rhs_harness_form_resolves_dot_claude() {
  # Only .claude/HARNESS.md exists; the bare HARNESS.md: form must still verify.
  local ws; ws=$(mk_workspace)
  ( cd "$ws" && verify_rhs 'HARNESS.md: Reflections via PR workflow' ) \
    || fail "HARNESS.md: form should resolve .claude/HARNESS.md"
  rm -rf "$ws"
}
test_verify_rhs_dot_claude_harness_explicit_form() {
  local ws; ws=$(mk_workspace)
  ( cd "$ws" && verify_rhs '.claude/HARNESS.md: Reflections via PR workflow' ) \
    || fail "explicit .claude/HARNESS.md: form should verify"
  rm -rf "$ws"
}
test_verify_rhs_harness_form_resolves_root() {
  local ws; ws=$(mk_workspace)
  printf '## Constraints\n### Root-only constraint\n' > "$ws/HARNESS.md"
  ( cd "$ws" && verify_rhs 'HARNESS.md: Root-only constraint' ) \
    || fail "HARNESS.md: form should still resolve a root HARNESS.md"
  rm -rf "$ws"
}
test_verify_rhs_unknown_form_fails() {
  local ws; ws=$(mk_workspace)
  ( cd "$ws" && ! verify_rhs 'README.md: something' ) \
    || fail "unknown target should not verify"
  rm -rf "$ws"
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
test_bounded_entries_preserves_entry_bodies
test_verify_rhs_agents_form
test_verify_rhs_claude_root_form
test_verify_rhs_claude_subcomponent_form
test_verify_rhs_claude_form_negative
test_verify_rhs_harness_form_resolves_dot_claude
test_verify_rhs_dot_claude_harness_explicit_form
test_verify_rhs_harness_form_resolves_root
test_verify_rhs_unknown_form_fails
echo "All tests passed."
