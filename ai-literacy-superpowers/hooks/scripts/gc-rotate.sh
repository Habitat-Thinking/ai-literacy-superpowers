#!/usr/bin/env bash
# Rotating GC check — runs at session end (Stop hook).
#
# Picks one GC rule per session (rotating by day-of-year) and runs
# a lightweight check. Covers deterministic GC rules only (secret
# scanner, snapshot staleness, shell syntax, strict mode). Agent-scoped
# rules need LLM judgement and are not included.
#
# This script is advisory only — it never blocks.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"

# If no HARNESS.md exists, nothing to check
if [ ! -f "$HARNESS_FILE" ]; then
  exit 0
fi

# Read configured cadence from HARNESS.md Observability section
STALENESS_THRESHOLD=30
cadence=$(grep -A5 '## Observability' "$HARNESS_FILE" 2>/dev/null \
  | grep 'Snapshot cadence:' \
  | sed 's/.*Snapshot cadence:[[:space:]]*//' \
  | tr -d '[:space:]') || true
case "$cadence" in
  weekly)      STALENESS_THRESHOLD=10 ;;
  fortnightly) STALENESS_THRESHOLD=21 ;;
  monthly)     STALENESS_THRESHOLD=30 ;;
esac

# Emit the shell scripts the project actually owns, NUL-delimited.
#
# Prefer git's tracked-file set: it skips node_modules, nested worktrees,
# CLAUDE_CONFIG_DIR zsh snapshots, and build output for free, so the shell
# rules only ever see scripts this project is responsible for. Fall back to
# a filesystem walk when the project is not a git repo. Paths from
# `git ls-files` are relative to PROJECT_DIR, so re-anchor them.
list_owned_shell_scripts() {
  if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$PROJECT_DIR" ls-files -z -- '*.sh' \
      | while IFS= read -r -d '' rel; do
          printf '%s\0' "${PROJECT_DIR%/}/$rel"
        done
  else
    find "$PROJECT_DIR" -name "*.sh" -not -path "*/.git/*" -print0 2>/dev/null
  fi
}

# Rotate through rules by day-of-year
day_of_year=$(date +%j | sed 's/^0*//')
rule_index=$((day_of_year % 4))

case $rule_index in
  0)
    # Secret scanner operational
    if ! command -v gitleaks &>/dev/null; then
      printf '{"systemMessage": "GC check (secret scanner): gitleaks is not installed. The No secrets in source constraint cannot run locally. Install with: brew install gitleaks"}'
      exit 0
    fi
    if ! gitleaks detect --source "$PROJECT_DIR" --no-banner --no-git 2>/dev/null; then
      printf '{"systemMessage": "GC check (secret scanner): gitleaks found potential secrets. Run gitleaks detect --source . --no-banner --no-git for details."}'
    fi
    ;;
  1)
    # Snapshot staleness
    snapshot_dir="${PROJECT_DIR}/observability/snapshots"
    if [ ! -d "$snapshot_dir" ]; then
      exit 0
    fi
    latest=$(find "$snapshot_dir" -maxdepth 1 -name "*-snapshot.md" 2>/dev/null | sort -r | head -1)
    if [ -z "$latest" ]; then
      printf '{"systemMessage": "GC check (snapshot staleness): no snapshots found. Run /harness-health to create one."}'
      exit 0
    fi
    filename=$(basename "$latest")
    snapshot_date="${filename%-snapshot.md}"
    if date -d "$snapshot_date" >/dev/null 2>&1; then
      snapshot_epoch=$(date -d "$snapshot_date" +%s)
    else
      snapshot_epoch=$(date -j -f "%Y-%m-%d" "$snapshot_date" +%s 2>/dev/null || exit 0)
    fi
    current_epoch=$(date +%s)
    age_days=$(( (current_epoch - snapshot_epoch) / 86400 ))
    if [ "$age_days" -gt "$STALENESS_THRESHOLD" ]; then
      printf '{"systemMessage": "GC check (snapshot staleness): latest snapshot is %d days old (cadence threshold: %d days). Run /harness-health to update."}' "$age_days" "$STALENESS_THRESHOLD"
    fi
    ;;
  2)
    # Shell scripts syntax
    failed_files=""
    while IFS= read -r -d '' f; do
      if ! bash -n "$f" 2>/dev/null; then
        failed_files="${failed_files}\n- $f"
      fi
    done < <(list_owned_shell_scripts)
    if [ -n "$failed_files" ]; then
      printf '{"systemMessage": "GC check (shell syntax): syntax errors found in:%s"}' "$failed_files"
    fi
    ;;
  3)
    # Shell scripts strict mode
    #
    # Detect any start-of-line `set` that enables errexit/nounset/pipefail,
    # anywhere in the file. Scanning the whole file (not just head -15)
    # sees `set` lines that sit below a documented header comment block,
    # and matching the strict-mode family rather than the exact literal
    # `set -euo pipefail` accepts deliberate fail-open subsets — e.g.
    # `set -uo pipefail` (hooks that must not abort mid-run) and `set -u`
    # (telemetry/CI scripts that must never fail the run). The `[euo]`
    # anchor still rejects `set -- "$@"` (positional-params reset) and a
    # script with no strict mode at all is still flagged.
    missing_files=""
    while IFS= read -r -d '' f; do
      if ! grep -qE '^[[:space:]]*set -[a-z]*[euo]' "$f"; then
        missing_files="${missing_files}\n- $f"
      fi
    done < <(list_owned_shell_scripts)
    if [ -n "$missing_files" ]; then
      printf '{"systemMessage": "GC check (strict mode): missing strict mode (set -e/-u/-o pipefail) in:%s"}' "$missing_files"
    fi
    ;;
esac

exit 0
