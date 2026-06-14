#!/usr/bin/env bash
# Reservoir check — runs at session end (Stop hook).
set -euo pipefail
#
# An advisory watch on the human verifier the harness cannot verify.
# Counts observable proxies (continuous session span, decision volume,
# context switches, wall-clock hour) over the recent git window and, if
# a tunable threshold is crossed, emits at most ONE {"systemMessage": ...}
# advisory grounded in the cognitive-reservoir skill.
#
# Discipline (see skills/cognitive-reservoir/SKILL.md):
#   - Advisory only. Never blocks, never exits non-zero, never gates CI.
#   - Counts are `observed`; risk is `inferred`; anything about the human
#     (chronotype) is `asked` and only used when declared.
#   - Never a fatigue score. Never asserts ego depletion or the
#     hungry-judges figure. Every trigger is a precaution under uncertainty.
#   - Persists NO record of the human's state to disk.
#
# Opt-in: a project opts in by adding an active `## Cognitive reservoir`
# heading to HARNESS.md. The template ships the block commented out (the
# `<!--` sits on the heading line), so a freshly scaffolded project is
# NOT opted in until the human uncomments it.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HARNESS_FILE="${PROJECT_DIR}/HARNESS.md"

# --- Self-gate (FR-006): silent exit 0 unless opted in and in a git repo ---
[ -f "$HARNESS_FILE" ] || exit 0
# Match an ACTIVE level-2..6 heading, not the commented template block.
grep -qiE '^#{1,6}[[:space:]]+Cognitive reservoir' "$HARNESS_FILE" || exit 0
git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# --- Read tunable thresholds from the Cognitive reservoir block (FR-008) ---
read_key() {
  # read_key <key> <default> — first matching `key: value` / `key = value`
  local key="$1" def="$2" val
  val=$(grep -iE "^[[:space:]]*[-*]?[[:space:]]*${key}[[:space:]]*[:=]" "$HARNESS_FILE" 2>/dev/null \
        | head -1 \
        | sed -E "s/.*[:=][[:space:]]*//" \
        | tr -d '[:space:]' \
        | tr -d '`' || true)
  if [ -n "$val" ]; then printf '%s' "$val"; else printf '%s' "$def"; fi
}

WINDOW_HOURS=$(read_key 'window_hours' '8')
SPAN_MIN=$(read_key 'span_minutes' '180')
DECISION_VOL=$(read_key 'decision_volume' '8')
CTX_SWITCHES=$(read_key 'context_switches' '4')
CHRONOTYPE=$(read_key 'chronotype' '')

# Guard against non-numeric tuning (degrade to defaults rather than abort).
case "$WINDOW_HOURS" in ''|*[!0-9]*) WINDOW_HOURS=8 ;; esac
case "$SPAN_MIN" in ''|*[!0-9]*) SPAN_MIN=180 ;; esac
case "$DECISION_VOL" in ''|*[!0-9]*) DECISION_VOL=8 ;; esac
case "$CTX_SWITCHES" in ''|*[!0-9]*) CTX_SWITCHES=4 ;; esac

SINCE="${WINDOW_HOURS} hours ago"

# --- Gather proxies (observed). Every pipeline degrades to 0 (FR-007) ---

# Continuous span (minutes): newest - oldest commit timestamp in the window.
span_min=0
commit_ts=$(git -C "$PROJECT_DIR" log --since="$SINCE" --format=%ct 2>/dev/null || true)
if [ -n "$commit_ts" ]; then
  newest=$(printf '%s\n' "$commit_ts" | head -1)
  oldest=$(printf '%s\n' "$commit_ts" | tail -1)
  if [ -n "$newest" ] && [ -n "$oldest" ] && [ "$newest" -ge "$oldest" ]; then
    span_min=$(( (newest - oldest) / 60 ))
  fi
fi

# Decision volume: approval-like events (commits/merges) in the window.
decisions=$(git -C "$PROJECT_DIR" log --since="$SINCE" --oneline 2>/dev/null | wc -l | tr -d '[:space:]' || true)
case "$decisions" in ''|*[!0-9]*) decisions=0 ;; esac

# Context switches: max(distinct top-level dirs touched, reflog branch switches).
dirs=$(git -C "$PROJECT_DIR" log --since="$SINCE" --name-only --format= 2>/dev/null \
       | awk -F/ 'NF{print $1}' | sort -u | grep -c . || true)
case "$dirs" in ''|*[!0-9]*) dirs=0 ;; esac
branch_switches=$(git -C "$PROJECT_DIR" reflog --since="$SINCE" 2>/dev/null \
                  | grep -c 'checkout: moving' || true)
case "$branch_switches" in ''|*[!0-9]*) branch_switches=0 ;; esac
ctx=$dirs
[ "$branch_switches" -gt "$ctx" ] && ctx=$branch_switches

# Wall-clock hour (local). Band applied only when chronotype declared (FR-010).
hour=$(date +%H)
hour=$((10#$hour))
band="unverified"
hour_suboptimal=0
if [ -n "$CHRONOTYPE" ]; then
  case "$CHRONOTYPE" in
    early|lark|morning)
      if [ "$hour" -ge 20 ] || [ "$hour" -lt 6 ]; then band="suboptimal"; hour_suboptimal=1
      elif [ "$hour" -ge 14 ] && [ "$hour" -lt 16 ]; then band="dip"
      else band="optimal"; fi ;;
    late|owl|evening)
      if [ "$hour" -lt 9 ]; then band="suboptimal"; hour_suboptimal=1
      else band="optimal"; fi ;;
    *)
      if [ "$hour" -ge 22 ] || [ "$hour" -lt 6 ]; then band="suboptimal"; hour_suboptimal=1
      elif [ "$hour" -ge 13 ] && [ "$hour" -lt 15 ]; then band="dip"
      else band="optimal"; fi ;;
  esac
fi

# --- Evaluate disjunctive thresholds (FR-008). Build the observed lines. ---
crossed_count=0
crossed_lines=""
add_cross() {
  crossed_lines="${crossed_lines}- ${1}
"
  crossed_count=$((crossed_count + 1))
}

[ "$span_min" -ge "$SPAN_MIN" ]   && add_cross "continuous span ${span_min} min (threshold ${SPAN_MIN})"
[ "$decisions" -ge "$DECISION_VOL" ] && add_cross "decision volume ${decisions} (threshold ${DECISION_VOL})"
[ "$ctx" -ge "$CTX_SWITCHES" ]    && add_cross "context switches ${ctx} (threshold ${CTX_SWITCHES})"
if [ "$hour_suboptimal" -eq 1 ]; then
  add_cross "wall-clock hour ${hour}:00 in your ${band} circadian band (chronotype: ${CHRONOTYPE})"
fi

# Below all thresholds → say nothing (Scenario B).
[ "$crossed_count" -gt 0 ] || exit 0

# --- Compose the single advisory (precaution under uncertainty) ---
message="Reservoir advisory — a precaution under uncertainty, not a diagnosis.

Observed in the last ${WINDOW_HOURS}h:
${crossed_lines}
Inferred (defeasible): the robust basis is sustained time-on-task (vigilance decrement) and task-switching cost (attention residue) — not ego depletion, and no 'hungry judges' figure is claimed. The instrument that would notice fatigue runs on the same capacity being spent, so this watch is external by design.

Decide your stop BEFORE the next session begins, while the judgment making the call is still one you would trust — do not negotiate the boundary with your tired self. One option: re-review today's last approvals tomorrow morning on a full reservoir.

The choice to continue is yours. Run /reservoir for a fuller read or to tune the thresholds."

# JSON-encode: escape backslash and quote, then join lines with \n (valid JSON).
encoded=$(printf '%s' "$message" \
  | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' \
  | awk 'BEGIN{ORS=""} {if (NR>1) printf "\\n"; printf "%s", $0}')

printf '{"systemMessage": "%s"}\n' "$encoded"

exit 0
