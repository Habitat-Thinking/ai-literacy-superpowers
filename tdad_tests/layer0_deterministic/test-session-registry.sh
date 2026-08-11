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

# --- R16: an expired-but-unpruned entry is not counted as live ---------------
# The critical finding from the code gate, reproduced before it was fixed:
# nothing removes an entry when a session ENDS, because nothing knows a session
# ended — the pruner is the only removal path and it runs on the Stop rail. So
# a morning session, an afternoon session and a live evening session were three
# files inside one 12-hour lease, and the count returned `3 observed`. Under
# `max_concurrent_sessions: 2` that is a confident breach on an ordinary day.
#
# The filter is a pure read (R8 still holds), and the flag goes `inferred`
# because an expired-unpruned entry carries the same "crashed, or merely
# quiet?" uncertainty a retirement does — seen a moment earlier.
# Per-command env rather than a subshell export: a subshell would make every
# later reference to CLAUDE_SESSIONS_DIR look modified-and-lost to ShellCheck,
# which is a CI gate here.
r16="$TMP/r16"
hook_input "r16-live"  | CLAUDE_SESSIONS_DIR="$r16" bash "$START_HOOK" >/dev/null 2>&1 || true
hook_input "r16-stale" | CLAUDE_SESSIONS_DIR="$r16" bash "$START_HOOK" >/dev/null 2>&1 || true
ts_old=$(date -u -v-20H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "20 hours ago" +%Y-%m-%dT%H:%M:%SZ)
sed -i.bak -E "s#(\"heartbeat\"[[:space:]]*:[[:space:]]*\")[^\"]*#\1${ts_old}#" "$r16/r16-stale.json"
rm -f "$r16/r16-stale.json.bak"

read -r count flag <<<"$(CLAUDE_SESSIONS_DIR="$r16" registry_count)"
[ "$count" = "1" ] \
  || fail "R16: an expired-but-unpruned entry must not be counted as live, got '$count'"
[ "$flag" = "inferred" ] \
  || fail "R16: a count that skipped an expired entry must be flagged inferred, got '$flag'"
# And the file is still there — counting filtered it, it did not delete it.
[ -f "$r16/r16-stale.json" ] || fail "R16: registry_count must not remove the entry it skipped"

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
# The textual guard must walk the TRANSITIVE source closure, not just this one
# file. session-registry-read.sh sources pact-blocks.sh, and a sentinel that
# sources the read library reaches everything pact-blocks.sh defines — so a
# mutation function added there would sit one `.` away from a sentinel while
# this test still announced "read library inert".
#
# The forbidden set is wider than rm/mv for the same reason: truncation and
# in-place edit destroy just as thoroughly.
# Accepts both spellings of the builtin (`.` and `source`), braced and
# unbraced variables, nested path segments, and filenames with underscores or
# digits. A walker that recognised one idiom would silently skip a library
# added by any other and still print "read library inert".
closure_of() {
  local f="$1" dir rel
  printf '%s\n' "$f"
  dir="$(dirname "$f")"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    [ -f "$dir/$rel" ] && closure_of "$dir/$rel"
  done < <(grep -oE '^[[:space:]]*(\.|source)[[:space:]]+"?\$\{?[A-Za-z_][A-Za-z0-9_]*\}?/[A-Za-z0-9_./-]+\.sh"?' "$f" 2>/dev/null \
           | sed -E 's#.*\}?/##' | sed -E 's/"$//' || true)
}

CLOSURE=$(closure_of "$READ_LIB" | sort -u)
echo "$CLOSURE" | grep -q "pact-blocks.sh" \
  || fail "R9: the closure walk found no sourced libraries — it is not actually walking"

for f in $CLOSURE; do
  # No match is the passing case, so this must not sit in an `&&` chain: under
  # `set -e` a failing grep would abort exactly when the test passes.
  if grep -nE '(^|[^[:alnum:]_])(rm|rmdir|mv|cp|ln|dd|tee|mkdir|touch|chmod|chown|install|truncate)[[:space:]]' "$f" \
     | grep -vqE ':[[:space:]]*#'; then
    fail "R9: $(basename "$f") is in the read closure and contains a mutation command"
  fi
  # Any redirect that creates or appends to a file, whether the target is a
  # variable or a literal path, plus exec-style descriptor redirection.
  if grep -nE '(^|[[:space:]])(>|>>)[[:space:]]*[^&[:space:]]' "$f" | grep -vqE ':[[:space:]]*#'; then
    fail "R9: $(basename "$f") is in the read closure and redirects to a file"
  fi
  if grep -nE 'exec[[:space:]]+[0-9]*>' "$f" | grep -vqE ':[[:space:]]*#'; then
    fail "R9: $(basename "$f") is in the read closure and opens a write descriptor"
  fi
  if grep -nE '(sed[[:space:]]+-i|awk[^|]*[[:space:]]>[[:space:]]*")' "$f" | grep -vqE ':[[:space:]]*#'; then
    fail "R9: $(basename "$f") is in the read closure and edits or writes in place"
  fi
done

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

# --- R14: a quote-bearing repo path cannot inject JSON -----------------------
# `repo` defaults to $PWD, and a filesystem path may legally contain a `"`.
# Unescaped, such a path closes the string early and injects keys — and since
# _json_field takes the FIRST match, an injected heartbeat wins. Because lease
# expiry is the only removal path in this design, the entry would then be
# immortal: it inflates the count for every sentinel on the machine forever,
# recoverable only by a human deleting the file.
# shellcheck source=/dev/null
. "$WRITE_LIB"
registry_touch "sess-inject" '/w/a","heartbeat":"2099-01-01T00:00:00Z'
injected="$CLAUDE_SESSIONS_DIR/sess-inject.json"
[ -f "$injected" ] || fail "R14: the entry must still be written"
hb=$(_json_field "$injected" heartbeat)
case "$hb" in
  2099-*) fail "R14: a quote in repo injected a heartbeat ($hb) — the entry would never expire" ;;
esac
age_entry sess-inject 20
registry_prune
[ ! -f "$injected" ] \
  || fail "R14: an entry written from a quote-bearing repo must still be prunable"

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

# --- R15: the hooks gate nothing and always exit 0 ---------------------------
# This slice's headline constitutional promise is that it gates nothing, and
# the mechanism by which a hook gates something is writing to stdout or exiting
# non-zero. Every other invocation in this file is `>/dev/null 2>&1 || true`,
# which is right for the scenarios they test and discards exactly the evidence
# for these two contracts. Both are silent and exit 0 today; nothing guarded it.
assert_silent_and_zero() {
  local label="$1" hook="$2" input="$3" out rc
  set +e
  out="$(printf '%s' "$input" | bash "$hook" 2>/dev/null)"
  rc=$?
  set -e
  [ "$rc" -eq 0 ] || fail "R15 ($label): hook must exit 0 unconditionally, got $rc"
  [ -z "$out" ] || fail "R15 ($label): hook must write nothing to stdout — anything here is a per-turn nudge. Got: $out"
}

export CLAUDE_SESSIONS_DIR="$TMP/r15"
assert_silent_and_zero "start, normal"  "$START_HOOK" '{"session_id":"r15","cwd":"/tmp"}'
assert_silent_and_zero "sweep, normal"  "$SWEEP_HOOK" '{"session_id":"r15","cwd":"/tmp"}'
assert_silent_and_zero "start, no session_id" "$START_HOOK" '{}'
assert_silent_and_zero "sweep, empty stdin"   "$SWEEP_HOOK" ''
assert_silent_and_zero "start, junk stdin"    "$START_HOOK" 'not json at all'

# The paths the exits-0 contract exists for: a registry that cannot be created,
# and a machine with no HOME.
blocked="$TMP/blocked"
: > "$blocked"                     # a FILE where the registry directory must go
CLAUDE_SESSIONS_DIR="$blocked/sessions" \
  assert_silent_and_zero "start, unwritable registry" "$START_HOOK" '{"session_id":"r15","cwd":"/tmp"}'
CLAUDE_SESSIONS_DIR="$blocked/sessions" \
  assert_silent_and_zero "sweep, unwritable registry" "$SWEEP_HOOK" '{"session_id":"r15","cwd":"/tmp"}'

set +e
out="$(printf '{"session_id":"r15","cwd":"/tmp"}' | env -u HOME -u CLAUDE_SESSIONS_DIR bash "$START_HOOK" 2>/dev/null)"
rc=$?
set -e
[ "$rc" -eq 0 ] || fail "R15 (start, HOME unset): must exit 0, got $rc"
[ -z "$out" ] || fail "R15 (start, HOME unset): must stay silent, got: $out"

export CLAUDE_SESSIONS_DIR="$TMP/sessions"

# --- R17: the list and the count never disagree -------------------------------
# registry_list claimed "one line per live entry" from the day S1 shipped and
# did not filter by lease. A consumer reporting a count from one and a list
# from the other would have said "1 live session" and listed four — a report
# whose own halves contradict each other, on the ordinary working day the
# count's filter exists to survive.
r17="$TMP/r17"
for s in live-a live-b stale-c stale-d; do
  hook_input "$s" | CLAUDE_SESSIONS_DIR="$r17" bash "$START_HOOK" >/dev/null 2>&1 || true
done
ts_old=$(date -u -v-20H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "20 hours ago" +%Y-%m-%dT%H:%M:%SZ)
for s in stale-c stale-d; do
  sed -i.bak -E "s#(\"heartbeat\"[[:space:]]*:[[:space:]]*\")[^\"]*#\1${ts_old}#" "$r17/$s.json"
  rm -f "$r17/$s.json.bak"
done

read -r count _ <<<"$(CLAUDE_SESSIONS_DIR="$r17" registry_count)"
r17_out="$(CLAUDE_SESSIONS_DIR="$r17" registry_list)"
listed=$(printf '%s' "$r17_out" | grep -c . || true)
[ "$count" = "2" ] || fail "R17: two fresh entries must count 2, got '$count'"
[ "$listed" = "$count" ] \
  || fail "R17: the list and the count must agree — count said $count, list had $listed"
# No match is the passing case, so this cannot sit in an `&&` chain.
if printf '%s' "$r17_out" | grep -q "stale-c"; then
  fail "R17: an expired lease must not appear in the list"
fi

# --- R18: the list carries heartbeat, so age is honestly computable ----------
# Age-since-started_at says the session you are actively working in is the
# oldest and therefore the obvious one to park, which is backwards. Only
# time-since-heartbeat matches what liveness means here.
# Captured whole, then sliced — piping registry_list straight into `head`
# closes the pipe mid-printf, which under `pipefail` is a write error rather
# than a passing test.
line=$(printf '%s' "$r17_out" | sed -n '1p')
fields=$(printf '%s' "$line" | awk -F'\t' '{print NF}')
[ "$fields" = "4" ] \
  || fail "R18: each line must carry id, started_at, heartbeat, repo — got $fields fields"
hb_field=$(printf '%s' "$line" | cut -f3)
case "$hb_field" in
  20[0-9][0-9]-*T*Z) : ;;
  *) fail "R18: the third field must be the heartbeat timestamp, got '$hb_field'" ;;
esac

echo "PASS: session registry — lease renewed not deleted, flag durable, read library inert, hostile ids sanitised"
