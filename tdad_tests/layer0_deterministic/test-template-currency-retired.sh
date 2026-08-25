#!/usr/bin/env bash
# Layer 0 test — the template-currency mechanism is retired and leaves no residue.
#
# Spec: docs/superpowers/specs/2026-08-25-template-currency-measure-content-design.md
#   criterion 1  — hook script and registration are gone
#   criterion 2  — no marker or Template currency GC rule in either harness
#   criterion 8a — no residue by term, case-insensitively, outside the allow-list
#   criterion 8b — no prose describing the deleted SessionStart behaviour
#   criterion 9  — the observatory totals agree with the per-source breakdown
#
# Criterion 8 exists because hand enumeration of the surfaces failed three
# times during design: 7 files, then 12, then 19, against a real 22 plus two
# prose surfaces no term search reaches. The assertion is what guarantees
# completeness, not a table in the spec.
#
# The allow-list is a data file, not an array in this script. A rule forbidding
# its widening, written where the test cannot read it, is an unenforced lint
# rule — and a one-line array edit that turns CI green draws no reviewer's eye.
#
# The search runs over tracked files only (git ls-files). Gitignored build
# artefacts — .pytest_cache, diagnostic-legibility/output — are not residue.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

ALLOWLIST="tdad_tests/layer0_deterministic/fixtures/template-currency-residue-allowlist.txt"
errors=()

# --- criterion 1 ---------------------------------------------------------
if [ -f "ai-literacy-superpowers/hooks/scripts/template-currency-check.sh" ]; then
  errors+=("C1: hooks/scripts/template-currency-check.sh still exists")
fi
if grep -q "template-currency-check" ai-literacy-superpowers/hooks/hooks.json 2>/dev/null; then
  errors+=("C1: hooks.json still registers template-currency-check")
fi

# --- criterion 2 ---------------------------------------------------------
for h in HARNESS.md ai-literacy-superpowers/templates/HARNESS.md; do
  [ -f "$h" ] || { errors+=("C2: $h not found"); continue; }
  if grep -qE '^<!-- template-version: [0-9]+\.[0-9]+\.[0-9]+ -->' "$h"; then
    errors+=("C2: $h still carries a template-version marker")
  fi
  if grep -qE '^### Template currency$' "$h"; then
    errors+=("C2: $h still declares a Template currency GC rule")
  fi
done

# --- allow-list ----------------------------------------------------------
[ -f "$ALLOWLIST" ] || { echo "FAIL: allow-list missing at $ALLOWLIST"; exit 1; }
allowed=()
while IFS= read -r line; do
  case "$line" in ''|'#'*) continue ;; esac
  allowed+=("${line%% :: *}")
done < "$ALLOWLIST"

is_allowed() {
  local f="$1" a
  for a in "${allowed[@]}"; do
    case "$a" in
      */) [ "${f#"$a"}" != "$f" ] && return 0 ;;
      *)  [ "$f" = "$a" ] && return 0 ;;
    esac
  done
  return 1
}

# --- criterion 8a: residue by term ---------------------------------------
TERMS='template-version|template currency|template-currency|template drift|template version drift|harness-upgrade-dismissed'
while IFS= read -r f; do
  f="${f#./}"
  is_allowed "$f" || errors+=("C8a: residue term in $f")
done < <(git ls-files -z | xargs -0 grep -liE "$TERMS" 2>/dev/null | sort -u)

# --- criterion 8b: residue by description --------------------------------
# Prose can describe the deleted hook without using any term in 8a:
# first-time-tour.md and the-harness-lifecycle.md both did.
#
# The match is line-level, not file-level. A file-level co-occurrence test
# flags reference/commands.md, which documents a SessionStart hook for WIP
# breaches and, elsewhere, says /harness-upgrade adopts new template content.
# Neither describes the deleted nudge. What does is a claim that something
# *tells you* about template state.
# The reverse direction is bounded to one sentence: "…new template content.
# All skills, agents, hooks…" is two clauses, not a claim about a nudge.
NUDGE='(sessionstart|nudge|nudges|prompts? you|tells you|notifies)[^.]{0,80}template (version|content)|template (version|content)[^.]{0,60}(nudge|nudges|sessionstart|hook nudges)'
while IFS= read -r hit; do
  f="${hit%%:*}"
  is_allowed "$f" && continue
  errors+=("C8b: $hit")
done < <(git ls-files -z | xargs -0 grep -inE "$NUDGE" 2>/dev/null | sort -u)

# --- criterion 9: observatory count guard --------------------------------
SIGNALS="ai-literacy-superpowers/skills/harness-observability/references/observatory-signals.md"
VERIFY="ai-literacy-superpowers/commands/observatory-verify.md"
if [ -f "$SIGNALS" ]; then
  breakdown_sum=$(grep -oE '^\| [A-Za-z][^|]*\| [0-9]+ \|' "$SIGNALS" \
                  | grep -oE '[0-9]+ \|$' | grep -oE '[0-9]+' \
                  | awk '{s+=$1} END {print s+0}')
  declared=$(grep -oE '^\| \*\*Total\*\* \| \*\*[0-9]+\*\* \|' "$SIGNALS" | grep -oE '[0-9]+' | head -1)
  if [ "$breakdown_sum" != "$declared" ]; then
    errors+=("C9: observatory per-source breakdown sums to $breakdown_sum but Total says $declared")
  fi
  if [ -f "$VERIFY" ]; then
    while IFS= read -r n; do
      [ "$n" = "$declared" ] || errors+=("C9: observatory-verify.md carries total $n; signals reference says $declared")
    done < <(grep -oE '[0-9]+-signal checklist|[0-9]+ signals|\*\*[0-9]+\*\* \|' "$VERIFY" \
             | grep -oE '[0-9]+' | sort -u)
  fi
fi

# --- report --------------------------------------------------------------
if [ ${#errors[@]} -gt 0 ]; then
  echo "FAIL: template-currency retirement left residue"
  printf '  %s\n' "${errors[@]}"
  exit 1
fi
echo "PASS: template-currency retired — hook gone, markers gone, no residue, counts agree"
