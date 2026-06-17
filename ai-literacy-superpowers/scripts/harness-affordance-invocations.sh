#!/usr/bin/env bash
set -euo pipefail
# harness-affordance-invocations.sh — analyzer for the runtime invocation log
# (spec 2026-06-17-affordance-runtime-recorder-design.md, step 7). Report-only.
#
#   --check=freshness       Is observability/affordance-invocations.json present
#                           and its newest ts within --max-age-days (default 7)?
#                           A stale/missing file => the recorder is probably not
#                           operating (LOCAL signal — the file is gitignored).
#   --check=dead-inventory  For each declared, non-example, NON-HOOK affordance,
#                           was any matching invocation seen within
#                           --max-age-days (default 30)? Unobserved => flagged.
#
# Matching: exact tool equality / mcp__server__* prefix for MCP and named tools;
# program-coarse for Bash (Bash(<prog> *) matches a tuple with program <prog> —
# conservative: an observed program marks every Bash affordance sharing it as
# observed, a false-alive never a false-dead). Hook affordances are excluded
# (a PostToolUse recorder cannot observe hook firings).
#
# Reads project files only; --today fixes "now" for hermetic tests. Exits 0
# always. NDJSON lines that do not parse are skipped (any line, not just the last).

CHECK="freshness"
MAX_AGE_FLAG=""
TODAY_OVERRIDE=""
PROJECT_DIR="."
for arg in "$@"; do
  case "$arg" in
    --check=freshness) CHECK="freshness" ;;
    --check=dead-inventory) CHECK="dead-inventory" ;;
    --check=*) echo "Unknown --check (freshness|dead-inventory)" >&2; exit 2 ;;
    --max-age-days=*) MAX_AGE_FLAG="${arg#--max-age-days=}" ;;
    --today=*) TODAY_OVERRIDE="${arg#--today=}" ;;
    --*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) PROJECT_DIR="$arg" ;;
  esac
done

command -v jq >/dev/null 2>&1 || { echo "jq not installed — cannot analyze invocations (brew install jq)."; exit 0; }

FILE="$PROJECT_DIR/observability/affordance-invocations.json"

# UTC epoch (midnight) for YYYY-MM-DD; round-trip validated; always returns 0.
date_to_epoch() {
  local epoch back
  epoch=$(date -u -j -f '%Y-%m-%d %H:%M:%S' "$1 00:00:00" '+%s' 2>/dev/null \
        || date -u -d "$1 00:00:00 UTC" '+%s' 2>/dev/null || true)
  [ -n "$epoch" ] || return 0
  back=$(date -u -j -f '%s' "$epoch" '+%Y-%m-%d' 2>/dev/null || date -u -d "@$epoch" '+%Y-%m-%d' 2>/dev/null || true)
  [ "$back" = "$1" ] && printf '%s' "$epoch"
  return 0
}

TODAY="${TODAY_OVERRIDE:-$(date -u '+%Y-%m-%d')}"
TODAY_EPOCH=$(date_to_epoch "$TODAY")
[ -n "$TODAY_EPOCH" ] || { echo "Could not parse today's date ($TODAY)." >&2; exit 0; }

if [ "$CHECK" = "freshness" ]; then
  MAX_AGE="${MAX_AGE_FLAG:-7}"
  if [ ! -f "$FILE" ]; then
    echo "STALE: no invocation file at $FILE — the recorder may not be operating."
    exit 0
  fi
  # -R 'fromjson?' reads NDJSON line-by-line and skips ANY unparseable line
  # (not just the trailing one), keeping jq's exit status 0.
  newest=$(jq -rR 'fromjson? | select(.ts != null) | .ts' "$FILE" 2>/dev/null | LC_ALL=C sort | tail -1)
  if [ -z "$newest" ]; then
    echo "STALE: invocation file has no parseable timestamps."
    exit 0
  fi
  newest_epoch=$(jq -rn --arg t "$newest" '($t | fromdateiso8601)' 2>/dev/null || true)
  if [ -z "$newest_epoch" ]; then
    echo "STALE: newest timestamp ($newest) is not parseable."
    exit 0
  fi
  age_days=$(( (TODAY_EPOCH - newest_epoch) / 86400 ))
  if [ "$age_days" -gt "$MAX_AGE" ]; then
    echo "STALE: newest invocation is $age_days days old (threshold $MAX_AGE) — recorder may be off."
  else
    echo "OK: recorder active (newest invocation $age_days days old, threshold $MAX_AGE)."
  fi
  exit 0
fi

# --- dead-inventory ---
MAX_AGE="${MAX_AGE_FLAG:-30}"

HARNESS=""
for cand in "$PROJECT_DIR/HARNESS.md" "$PROJECT_DIR/.claude/HARNESS.md"; do
  [ -f "$cand" ] && { HARNESS="$cand"; break; }
done
[ -n "$HARNESS" ] || { echo "No HARNESS.md under $PROJECT_DIR — nothing to check."; exit 0; }

SECTION=$(awk '
  /^## Affordances[[:space:]]*$/ { inside=1; next }
  /^## / { if (inside) exit }
  inside { print }
' "$HARNESS")
[ -n "$SECTION" ] || { echo "No ## Affordances section — nothing to check."; exit 0; }

# Declared, non-example, NON-HOOK affordances: emit name<TAB>permission-pattern.
DECLARED=$(printf '%s\n' "$SECTION" | awk '
  function is_pattern(t){ return (t ~ /^[A-Za-z_]+\(/ || t ~ /^mcp__/) }
  function flush(   i,n,tmp,tok,is_hook){
    if (name=="" || is_example) return
    n=0; delete pats; tmp=perm
    while (match(tmp, /`[^`]+`/)) { tok=substr(tmp,RSTART+1,RLENGTH-2); tmp=substr(tmp,RSTART+RLENGTH); if (is_pattern(tok)){n++; pats[n]=tok} }
    is_hook=(mode=="hook")
    for(i=1;i<=n;i++) if (pats[i] ~ /^hooks\./) is_hook=1
    if (is_hook || n!=1) return
    printf "%s\t%s\n", name, pats[1]
  }
  /^### / { flush(); name=$0; sub(/^### +/,"",name); sub(/[[:space:]]+$/,"",name); is_example=0; mode=""; perm="" ; next }
  /^[[:space:]]*<!--[[:space:]]*affordance-example[[:space:]]*-->[[:space:]]*$/ { is_example=1 }
  /^- \*\*Mode\*\*:/ { m=$0; sub(/^- \*\*Mode\*\*:[[:space:]]*/,"",m); split(m,a," "); mode=a[1] }
  /^- \*\*Permission\*\*:/ { perm=$0; sub(/^- \*\*Permission\*\*:[[:space:]]*/,"",perm) }
  END { flush() }
')
[ -n "$DECLARED" ] || { echo "No matchable (non-example, non-hook) affordances declared."; exit 0; }

# Observed tools and bash programs within the window (skip unparseable lines).
CUTOFF=$(( TODAY_EPOCH - MAX_AGE * 86400 ))
OBS_TOOLS=""
OBS_PROGRAMS=""
if [ -f "$FILE" ]; then
  OBS_TOOLS=$(jq -rR --argjson cutoff "$CUTOFF" '
    fromjson? | select(.ts != null and .tool != null)
    | select((.ts | fromdateiso8601? // 0) >= $cutoff)
    | .tool' "$FILE" 2>/dev/null | LC_ALL=C sort -u)
  OBS_PROGRAMS=$(jq -rR --argjson cutoff "$CUTOFF" '
    fromjson? | select(.ts != null and .tool == "Bash" and .program != null)
    | select((.ts | fromdateiso8601? // 0) >= $cutoff)
    | .program' "$FILE" 2>/dev/null | LC_ALL=C sort -u)
fi

findings=""
while IFS=$'\t' read -r name pat; do
  [ -z "$name" ] && continue
  observed=0
  case "$pat" in
    Bash\(*)
      # program = first token inside Bash( ... ), basename'd to mirror the
      # recorder (so a path-qualified declared pattern matches its invocation).
      prog=$(printf '%s' "$pat" | sed -E 's/^Bash\(//; s/[[:space:]].*$//; s/\)$//')
      prog=$(basename -- "$prog" 2>/dev/null || printf '%s' "$prog")
      printf '%s\n' "$OBS_PROGRAMS" | grep -qxF "$prog" && observed=1
      ;;
    mcp__*\*)
      # Glob prefix match (no regex escaping needed): mcp__server__* matches
      # any observed tool starting with mcp__server__.
      prefix="${pat%\*}"
      while IFS= read -r t; do
        [ -n "$t" ] || continue
        case "$t" in "$prefix"*) observed=1; break ;; esac
      done <<< "$OBS_TOOLS"
      ;;
    *)
      printf '%s\n' "$OBS_TOOLS" | grep -qxF "$pat" && observed=1
      ;;
  esac
  if [ "$observed" -eq 0 ]; then
    findings+="DEAD: affordance '$name' ($pat) — no observed invocation in the last $MAX_AGE days"$'\n'
  fi
done <<< "$DECLARED"

if [ -n "$findings" ]; then
  printf '%s' "$findings" | LC_ALL=C sort
  echo "(Bash matching is program-coarse; it cannot distinguish narrow from broad grants.)"
else
  echo "OK: every matchable affordance has a recent observed invocation."
fi
exit 0
