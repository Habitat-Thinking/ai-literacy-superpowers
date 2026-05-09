#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/../scripts/migrate-reflection-log.sh"
FIXTURES="$SCRIPT_DIR/fixtures"

fail() { echo "FAIL: $*" >&2; exit 1; }
assert_contains() { grep -qF "$2" "$1" || fail "expected '$2' in $1"; }
assert_file_exists() { [ -f "$1" ] || fail "expected file $1"; }

setup_workspace() {
  WORK_DIR=$(mktemp -d)
  trap 'rm -rf "$WORK_DIR"' EXIT
  mkdir -p "$WORK_DIR/reflections"
}

test_proposes_agents_promotion_when_keyword_overlaps() {
  setup_workspace
  cp "$FIXTURES/reflection-log-many-entries.md" "$WORK_DIR/REFLECTION_LOG.md"
  cat >> "$WORK_DIR/REFLECTION_LOG.md" <<'ENTRY'

---

- **Date**: 2026-04-30
- **Agent**: claude-opus-4-7[1m]
- **Task**: Multi-repo agent work
- **Surprise**: Multi-repo scheduled agents are simpler than expected
- **Proposal**: workflow
- **Improvement**: none
- **Signal**: workflow
- **Constraint**: none
- **Session metadata**:
  - Duration: ~10 min
  - Model tiers used: capable
  - Pipeline stages completed: manual
  - Agent delegation: manual
ENTRY
  cp "$FIXTURES/agents-md-with-multi-repo-style.md" "$WORK_DIR/AGENTS.md"
  : > "$WORK_DIR/HARNESS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" )
  assert_file_exists "$WORK_DIR/reflections/migration-proposals.md"
  assert_contains "$WORK_DIR/reflections/migration-proposals.md" "Likely-promoted to AGENTS.md"
  assert_contains "$WORK_DIR/reflections/migration-proposals.md" "Multi-repo"
}

test_proposes_aged_out_for_old_unmatched_entry() {
  setup_workspace
  cat > "$WORK_DIR/REFLECTION_LOG.md" <<'L'
# Reflection Log

---

- **Date**: 2024-01-15
- **Agent**: claude
- **Task**: Old singleton
- **Surprise**: Unique unrepeated thing
- **Proposal**: none
- **Improvement**: none
- **Signal**: none
- **Constraint**: none
- **Session metadata**:
  - Duration: ~5 min
  - Model tiers used: capable
  - Pipeline stages completed: manual
  - Agent delegation: manual
L
  echo "# AGENTS" > "$WORK_DIR/AGENTS.md"
  echo "# HARNESS" > "$WORK_DIR/HARNESS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" )
  assert_contains "$WORK_DIR/reflections/migration-proposals.md" "aged-out"
}

test_self_skips_on_rerun() {
  setup_workspace
  cp "$FIXTURES/reflection-log-many-entries.md" "$WORK_DIR/REFLECTION_LOG.md"
  echo "# AGENTS" > "$WORK_DIR/AGENTS.md"
  echo "# HARNESS" > "$WORK_DIR/HARNESS.md"
  ( cd "$WORK_DIR" && bash "$SCRIPT" )
  output=$( cd "$WORK_DIR" && bash "$SCRIPT" 2>&1 )
  echo "$output" | grep -q "Skipping" || fail "expected self-skip message"
}

test_proposes_agents_promotion_when_keyword_overlaps
test_proposes_aged_out_for_old_unmatched_entry
test_self_skips_on_rerun
echo "All tests passed."
