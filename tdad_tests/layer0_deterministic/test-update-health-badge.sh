#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for update-health-badge.sh — the /harness-health badge writer.
#
# Contract under test:
#   The badge status mirrors the authoritative `- Health: **X**` line the
#   /harness-health skill writes in the snapshot's Meta section (Healthy /
#   Attention / Degraded), NOT a re-derivation by keyword-sniffing.
#
# Regression guard (the bug this test was born from): a Healthy snapshot whose
# Meta contains the standard line "Trend alerts: none" must stay Healthy. The
# old heuristic matched the substring "alert" inside "alerts" and flagged
# Attention on a clean snapshot.
#
# Also covered:
#   - Attention and Degraded Health lines map to their statuses/colours.
#   - The <70% enforcement safety net forces Degraded even when the Health
#     line says Healthy.
#   - The Health line is honoured even when it sits past line 20 of Meta
#     (the old `head -20` window could miss it).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BADGE="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/update-health-badge.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[ -f "$BADGE" ] || fail "badge script not found at $BADGE"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Seed a README carrying a Harness Health badge (starting colour is irrelevant;
# the script rewrites it).
seed_readme() {
  printf '# Project\n[![Harness Health](https://img.shields.io/badge/Harness_Health-Unknown-000000?style=flat-square)](old)\n' \
    > "$WORK/README.md"
}

# run <snapshot-file> -> sets STATUS to the badge status token in the README
run() {
  seed_readme
  bash "$BADGE" "$WORK" "$1" >/dev/null 2>&1 || fail "badge script exited non-zero on $1"
  STATUS=$(grep -oE 'Harness_Health-[A-Za-z]+' "$WORK/README.md" | head -1 | sed 's/Harness_Health-//')
  [ -n "$STATUS" ] || fail "no Harness Health badge found in README after running on $1"
  LINK=$(grep -oE '\]\([^)]*\)$' "$WORK/README.md" | tail -1)
}

# --- Regression: Healthy snapshot with "Trend alerts: none" stays Healthy ----
cat > "$WORK/healthy.md" <<'EOF'
# Harness Health Snapshot — test

## Meta

- Snapshot cadence: on schedule
- Trend alerts: none
- Health: **Healthy**

## Changes Since Last Snapshot
EOF
run "$WORK/healthy.md"
[ "$STATUS" = "Healthy" ] || fail "Healthy snapshot with 'Trend alerts: none' must map to Healthy, got '$STATUS' (the 'alert' substring regression)"

# --- Attention Health line ---------------------------------------------------
cat > "$WORK/attention.md" <<'EOF'
## Meta

- Trend alerts: none
- Health: **Attention**

## Changes Since Last Snapshot
EOF
run "$WORK/attention.md"
[ "$STATUS" = "Attention" ] || fail "Health: **Attention** must map to Attention, got '$STATUS'"

# --- Degraded Health line ----------------------------------------------------
cat > "$WORK/degraded.md" <<'EOF'
## Meta

- Health: **Degraded**

## Changes Since Last Snapshot
EOF
run "$WORK/degraded.md"
[ "$STATUS" = "Degraded" ] || fail "Health: **Degraded** must map to Degraded, got '$STATUS'"

# --- Enforcement <70% safety net overrides a Healthy line --------------------
cat > "$WORK/collapsed.md" <<'EOF'
# Snapshot

- Constraints: 5/10 enforced (50%)

## Meta

- Health: **Healthy**

## Changes Since Last Snapshot
EOF
run "$WORK/collapsed.md"
[ "$STATUS" = "Degraded" ] || fail "50% enforcement must force Degraded regardless of the Health line, got '$STATUS'"

# --- Health line past line 20 of Meta is still honoured ----------------------
{
  printf '## Meta\n\n'
  for i in $(seq 1 25); do printf -- '- filler line %s with the word alerts in it\n' "$i"; done
  printf -- '- Health: **Attention**\n\n## Changes Since Last Snapshot\n'
} > "$WORK/deep.md"
run "$WORK/deep.md"
[ "$STATUS" = "Attention" ] || fail "Health line beyond 20 lines of Meta must still be read, got '$STATUS'"

# --- Link target points at the snapshot file ---------------------------------
run "$WORK/healthy.md"
case "$LINK" in
  *healthy.md*) : ;;
  *) fail "badge link must target the snapshot file, got '$LINK'" ;;
esac

echo "PASS: update-health-badge mirrors the authoritative Health line; 'Trend alerts: none' no longer false-positives"
