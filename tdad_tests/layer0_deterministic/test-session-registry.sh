#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the session registry
# (spec 2026-08-08-cadence-sentinels-s1-infrastructure-design.md, §4; R1–R13).
#
# The registry is a LEASE, not a liveness log. Entries are written on
# SessionStart, renewed on Stop, and retired only by lease expiry. That design
# exists because of R3: the Stop hook fires when the main agent finishes
# responding — many times per session, not once at session end. Every one of
# the nine existing Stop scripts declares "runs at session end" in its header
# and none carries a once-per-session guard, which is harmless for nine
# idempotent advisories and fatal for a destructive one. A delete-on-Stop
# registry empties itself after each session's first response, and the WIP
# Warden reports 1 while four sessions run.
#
# R3 is the test that would have caught the design this replaced. R8 and R9
# are the trust-boundary tests: a sentinel may source the read library, so the
# read library must be incapable of mutation (spec §4.4).
#
# Contract under test:
#   lib/session-registry-read.sh   registry_count -> "<n> <observed|inferred>", registry_list
#   lib/session-registry-write.sh  registry_touch, registry_prune
#   session-registry-start.sh      SessionStart hook — write-if-absent, renew
#   session-registry-sweep.sh      Stop hook — renew, then prune expired
#
# $CLAUDE_SESSIONS_DIR overrides the registry location so tests need no home
# directory, mirroring $CLAUDE_PACTS_FILE for the pact reader.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"
READ_LIB="$PLUGIN/hooks/scripts/lib/session-registry-read.sh"
WRITE_LIB="$PLUGIN/hooks/scripts/lib/session-registry-write.sh"
START_HOOK="$PLUGIN/hooks/scripts/session-registry-start.sh"
SWEEP_HOOK="$PLUGIN/hooks/scripts/session-registry-sweep.sh"
PACT_FIX="$SCRIPT_DIR/fixtures/cadence-pacts"

fail() { echo "FAIL: $*" >&2; exit 1; }

for f in "$READ_LIB" "$WRITE_LIB" "$START_HOOK" "$SWEEP_HOOK"; do
  [ -f "$f" ] || fail "not found: $f"
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export CLAUDE_SESSIONS_DIR="$TMP/sessions"

# hook_input <session-id> — the stdin JSON shape the hooks receive.
hook_input() { printf '{"session_id":"%s","cwd":"%s"}' "$1" "$TMP"; }

# heartbeat_of <session-id>
heartbeat_of() { grep -o '"heartbeat"[[:space:]]*:[[:space:]]*"[^"]*"' "$CLAUDE_SESSIONS_DIR/$1.json" | head -1; }
started_of()   { grep -o '"started_at"[[:space:]]*:[[:space:]]*"[^"]*"' "$CLAUDE_SESSIONS_DIR/$1.json" | head -1; }

# age_entry <session-id> <hours> — backdate an entry's heartbeat.
age_entry() {
  local id="$1" hours="$2" ts
  if date -u -v-"${hours}"H +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
    ts=$(date -u -v-"${hours}"H +%Y-%m-%dT%H:%M:%SZ)          # BSD/macOS
  else
    ts=$(date -u -d "${hours} hours ago" +%Y-%m-%dT%H:%M:%SZ) # GNU
  fi
  sed -i.bak -E "s#(\"heartbeat\"[[:space:]]*:[[:space:]]*\")[^\"]*#\1${ts}#" \
    "$CLAUDE_SESSIONS_DIR/$id.json"
  rm -f "$CLAUDE_SESSIONS_DIR/$id.json.bak"
}

# --- R1: write on start -------------------------------------------------------
hook_input "sess-alpha" | bash "$START_HOOK" >/dev/null 2>&1 || true
entry="$CLAUDE_SESSIONS_DIR/sess-alpha.json"
[ -f "$entry" ] || fail "R1: SessionStart must write $entry"
for key in id repo started_at heartbeat; do
  grep -q "\"$key\"" "$entry" || fail "R1: entry must carry '$key'"
done

# --- R2: SessionStart re-fire renews heartbeat, never resets started_at -------
# SessionStart fires on startup, resume, clear and compact. A reset started_at
# would mean a long-running session never ages out.
started_before=$(started_of sess-alpha)
age_entry sess-alpha 1
hb_before=$(heartbeat_of sess-alpha)
hook_input "sess-alpha" | bash "$START_HOOK" >/dev/null 2>&1 || true
[ "$(started_of sess-alpha)" = "$started_before" ] \
  || fail "R2: SessionStart re-fire must not reset started_at"
[ "$(heartbeat_of sess-alpha)" != "$hb_before" ] \
  || fail "R2: SessionStart re-fire must renew heartbeat"

# --- R3: Stop renews, never deletes ------------------------------------------
# The scenario that would have caught the delete-on-Stop design.
age_entry sess-alpha 1
hb_before=$(heartbeat_of sess-alpha)
for _ in 1 2 3; do
  hook_input "sess-alpha" | bash "$SWEEP_HOOK" >/dev/null 2>&1 || true
done
[ -f "$entry" ] || fail "R3: Stop must NOT delete the entry — Stop fires per turn, not per session"
[ "$(heartbeat_of sess-alpha)" != "$hb_before" ] || fail "R3: Stop must renew heartbeat"

# --- R4: two overlapping sessions counted, flagged observed ------------------
# shellcheck source=/dev/null
. "$READ_LIB"
declare -F registry_count >/dev/null || fail "read lib must define registry_count"
declare -F registry_list  >/dev/null || fail "read lib must define registry_list"

hook_input "sess-beta" | bash "$START_HOOK" >/dev/null 2>&1 || true
read -r count flag <<<"$(registry_count)"
[ "$count" = "2" ] || fail "R4: two live sessions must count 2, got '$count'"
[ "$flag" = "observed" ] || fail "R4: an unpruned count must be flagged observed, got '$flag'"

# --- R8: registry_count mutates nothing --------------------------------------
before=$(find "$CLAUDE_SESSIONS_DIR" -type f | sort | xargs cksum 2>/dev/null || true)
registry_count >/dev/null
after=$(find "$CLAUDE_SESSIONS_DIR" -type f | sort | xargs cksum 2>/dev/null || true)
[ "$before" = "$after" ] || fail "R8: registry_count must be a pure read — contents changed"

# --- R9: the read library exposes no mutation --------------------------------
# A sentinel may source this file. sentinel-integrity-check.sh permits Bash and
# names its own limit: a write capability reached through an undeclared channel
# is out of scope for it. So the boundary has to hold here instead.
( unset -f registry_touch registry_prune 2>/dev/null || true
  # shellcheck source=/dev/null
  . "$READ_LIB"
  if declare -F registry_touch >/dev/null || declare -F registry_prune >/dev/null; then
    echo "FAIL: R9: sourcing the read library must not define a mutation function" >&2
    exit 1
  fi
) || exit 1
# No match is the passing case, so this must not sit in an `&&` chain: under
# `set -e` a failing grep would abort the script exactly when the test passes.
if grep -nE '(^|[^[:alnum:]_])(rm|mv)[[:space:]]' "$READ_LIB" | grep -vqE ':[[:space:]]*#'; then
  fail "R9: the read library must contain no delete/move operation"
fi

# --- R5: expired lease retired, count flagged inferred -----------------------
age_entry sess-beta 20
hook_input "sess-alpha" | bash "$SWEEP_HOOK" >/dev/null 2>&1 || true
[ ! -f "$CLAUDE_SESSIONS_DIR/sess-beta.json" ] \
  || fail "R5: an entry past its lease must be retired"
read -r count flag <<<"$(registry_count)"
[ "$count" = "1" ] || fail "R5: count after retirement must be 1, got '$count'"
[ "$flag" = "inferred" ] \
  || fail "R5: a count following a retirement must be flagged inferred, got '$flag'"

# --- R6: the flag survives repeated reads ------------------------------------
# The flag is a property of the count, not of whoever read first.
for _ in 1 2; do
  read -r _ flag <<<"$(registry_count)"
  [ "$flag" = "inferred" ] \
    || fail "R6: the inferred flag must persist across reads, got '$flag'"
done

# --- R7: the lease length is declared, not compiled in -----------------------
hook_input "sess-gamma" | bash "$START_HOOK" >/dev/null 2>&1 || true
age_entry sess-gamma 3

export CLAUDE_PACTS_FILE="$TMP/short-lease.md"
cat > "$CLAUDE_PACTS_FILE" <<'EOF'
## Session WIP

- max_concurrent_sessions: 2
- stale_after_hours: 2

This is a gate on sessions, never on the person. It counts; it does not
assess.
EOF
hook_input "sess-alpha" | bash "$SWEEP_HOOK" >/dev/null 2>&1 || true
[ ! -f "$CLAUDE_SESSIONS_DIR/sess-gamma.json" ] \
  || fail "R7: with stale_after_hours: 2, a 3-hour-old entry must be retired"

hook_input "sess-delta" | bash "$START_HOOK" >/dev/null 2>&1 || true
age_entry sess-delta 3
export CLAUDE_PACTS_FILE="$PACT_FIX/full.md"   # stale_after_hours: 12
hook_input "sess-alpha" | bash "$SWEEP_HOOK" >/dev/null 2>&1 || true
[ -f "$CLAUDE_SESSIONS_DIR/sess-delta.json" ] \
  || fail "R7: with stale_after_hours: 12, a 3-hour-old entry must survive"
unset CLAUDE_PACTS_FILE

# --- R10: hostile session id sanitised ---------------------------------------
# Already adjudicated once in this repo for the same field
# (affordance-invocation-recorder.sh:55). A `/` or `..` in a path context is
# strictly worse than the JSON-injection case fixed there.
printf '{"session_id":"../../escaped","cwd":"%s"}' "$TMP" | bash "$START_HOOK" >/dev/null 2>&1 || true
[ -f "$CLAUDE_SESSIONS_DIR/unknown.json" ] \
  || fail "R10: a hostile session id must be sanitised to 'unknown'"
[ ! -e "$TMP/escaped.json" ] || fail "R10: no file may be written outside the registry directory"
[ "$(find "$CLAUDE_SESSIONS_DIR" -maxdepth 1 -name '*.json' | wc -l | tr -d ' ')" \
  = "$(find "$CLAUDE_SESSIONS_DIR" -name '*.json' | wc -l | tr -d ' ')" ] \
  || fail "R10: sanitisation must keep every entry flat inside the registry directory"

# --- R11: an unknown entry flags the count inferred --------------------------
# One unknown.json may stand for more than one session, so the count is not
# something the registry can claim to have observed.
read -r _ flag <<<"$(registry_count)"
[ "$flag" = "inferred" ] \
  || fail "R11: a registry containing unknown.json must flag the count inferred, got '$flag'"

# --- R12: no registry directory at all ---------------------------------------
export CLAUDE_SESSIONS_DIR="$TMP/nonexistent"
set +e; out=$(registry_count); rc=$?; set -e
[ "$rc" -eq 0 ] || fail "R12: registry_count must exit 0 when the directory is absent (got $rc)"
read -r count flag <<<"$out"
[ "$count" = "0" ] || fail "R12: absent registry must count 0, got '$count'"
[ "$flag" = "observed" ] || fail "R12: absent registry must be flagged observed, got '$flag'"

# --- R13: the default registry lives outside every work tree -----------------
unset CLAUDE_SESSIONS_DIR
default_dir=$(registry_dir)
case "$default_dir" in
  "$HOME"/.claude/sessions*) : ;;
  *) fail "R13: the default registry must resolve under ~/.claude/sessions, got '$default_dir'" ;;
esac
repo_root="$(cd "$SCRIPT_DIR/../.." && pwd)"
case "$default_dir" in
  "$repo_root"/*) fail "R13: the default registry must not live inside a work tree ($default_dir)" ;;
esac

echo "PASS: session registry — lease renewed not deleted, flag durable, read library inert, hostile ids sanitised"
