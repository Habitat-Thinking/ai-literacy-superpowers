#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Tests live in tdad_tests/layer0_deterministic/; the script under
# test ships inside the packaged plugin two levels up.
SCRIPT="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/archive-promoted-reflections.sh"
SPLIT="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/split-reflection-log.sh"
FIXTURES="$SCRIPT_DIR/fixtures"

fail() { echo "FAIL: $*" >&2; exit 1; }
assert_contains() { grep -qF "$2" "$1" || fail "expected '$2' in $1"; }
assert_not_contains() { ! grep -qF "$2" "$1" || fail "did not expect '$2' in $1"; }
assert_file_exists() { [ -f "$1" ] || fail "expected file $1"; }

# load_fixture: install a monolith fixture as the working log, then split it
# into per-entry fragments under reflections/active/ — the source of truth the
# archive script now consumes. Clears any prior fragments so the split runs.
load_fixture() {
  cp "$FIXTURES/$1" "$WORK_DIR/REFLECTION_LOG.md"
  rm -rf "$WORK_DIR/reflections/active"
  ( cd "$WORK_DIR" && bash "$SPLIT" >/dev/null )
}

setup_workspace() {
  WORK_DIR=$(mktemp -d)
  trap 'rm -rf "$WORK_DIR"' EXIT
  cp "$FIXTURES/agents-md-with-multi-repo-style.md" "$WORK_DIR/AGENTS.md"
  : > "$WORK_DIR/HARNESS.md"
  mkdir -p "$WORK_DIR/reflections/archive"
  load_fixture "reflection-log-promoted-agents.md"
}

test_happy_path_archives_agents_promoted_entry() {
  setup_workspace
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false )
  assert_file_exists "$WORK_DIR/reflections/archive/2026.md"
  assert_contains "$WORK_DIR/reflections/archive/2026.md" "Multi-repo scheduled agents"
  assert_contains "$WORK_DIR/reflections/archive/2026.md" "**Archived**:"
  assert_not_contains "$WORK_DIR/REFLECTION_LOG.md" "Multi-repo scheduled agents"
}

test_skips_when_agents_content_missing() {
  setup_workspace
  echo "# AGENTS.md (empty)" > "$WORK_DIR/AGENTS.md"
  local output
  output=$( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false 2>&1 )
  echo "$output" | grep -q "did not verify" || fail "expected 'did not verify' in script output: $output"
  assert_contains "$WORK_DIR/REFLECTION_LOG.md" "Multi-repo scheduled agents"
}

test_archives_aged_out_form() {
  setup_workspace
  load_fixture "reflection-log-promoted-aged-out.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false )
  assert_file_exists "$WORK_DIR/reflections/archive/2026.md"
  assert_contains "$WORK_DIR/reflections/archive/2026.md" "aged-out"
}

test_archives_harness_form_when_constraint_present() {
  setup_workspace
  echo "### Reflections via PR workflow" > "$WORK_DIR/HARNESS.md"
  load_fixture "reflection-log-promoted-harness.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false )
  assert_file_exists "$WORK_DIR/reflections/archive/2026.md"
  assert_contains "$WORK_DIR/reflections/archive/2026.md" "Reflections via PR workflow"
}

test_skips_harness_form_when_constraint_missing() {
  setup_workspace
  echo "# HARNESS.md (empty)" > "$WORK_DIR/HARNESS.md"
  load_fixture "reflection-log-promoted-harness.md"
  local output
  output=$( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false 2>&1 )
  echo "$output" | grep -q "did not verify" || fail "expected 'did not verify' in script output: $output"
  assert_contains "$WORK_DIR/REFLECTION_LOG.md" "Reflections via PR workflow"
}

test_2025_entry_archives_to_2025_md() {
  setup_workspace
  load_fixture "reflection-log-2025-promoted.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" --dry-run=false )
  assert_file_exists "$WORK_DIR/reflections/archive/2025.md"
  assert_contains "$WORK_DIR/reflections/archive/2025.md" "Multi-repo scheduled agents"
}

test_happy_path_archives_agents_promoted_entry
test_skips_when_agents_content_missing
test_archives_aged_out_form
test_archives_harness_form_when_constraint_present
test_skips_harness_form_when_constraint_missing
test_2025_entry_archives_to_2025_md
echo "All tests passed."
