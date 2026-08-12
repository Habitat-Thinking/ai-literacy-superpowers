#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the advisory rail
# (spec 2026-08-12-cadence-sentinels-s3b-boundary-notices-design.md, §3; AR1–AR6).
#
# AR2 is the reason this exists and the reason the design changed. Two
# sentinels counsel stopping on the Stop rail, and they operate on different
# periods: `reservoir-check.sh` has NO once-per-session guard and cannot have
# one — it persists nothing by charter and re-emits every turn while a
# threshold stays crossed — while the Mast's `reached` fires once, ever.
#
# First-claim-wins with the warden ordered first therefore preserved the
# message that repeats and permanently spent the one designed to arrive once.
# So the rail arbitrates by PRECEDENCE: a once-only advisory speaks, and a
# repeating one defers to the next turn it is going to get anyway.
#
# AR5 pins the atomicity. A check-then-act on a shared file is a race, and a
# rail whose guarantee flickers teaches the human to discount the sentinel —
# which is the failure the rail exists to prevent, arriving by another door.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"
RAIL="$PLUGIN/hooks/scripts/lib/advisory-rail.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$RAIL" ] || fail "advisory rail not found at $RAIL"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export CLAUDE_ADVISORY_DIR="$TMP/rail"

# shellcheck source=/dev/null
. "$RAIL"
for fn in advisory_claim advisory_defer_if_claimed advisory_reset; do
  declare -F "$fn" >/dev/null || fail "rail must define $fn"
done

# --- AR1: a once-only advisory claims and speaks -----------------------------
advisory_claim once-only stop || fail "AR1: a first once-only claim must succeed"

# --- AR2: a repeating advisory defers when a once-only has claimed -----------
# The finding that reshaped the slice. The warden defers to a turn it will get
# again; the Mast's notice has no next turn.
if advisory_defer_if_claimed stop; then
  : # deferred, as required
else
  fail "AR2: a repeating advisory must defer when a once-only has claimed this turn"
fi

# --- AR3: with no once-only claim, a repeating advisory speaks ---------------
advisory_reset
if advisory_defer_if_claimed stop; then
  fail "AR3: with no claim outstanding, a repeating advisory must speak"
fi

# --- AR4: a different kind claims independently ------------------------------
advisory_reset
advisory_claim once-only stop || fail "AR4: setup"
if advisory_defer_if_claimed park; then
  fail "AR4: a claim on 'stop' must not silence an unrelated kind"
fi

# --- AR6: the claim expires with the turn ------------------------------------
# A turn has no identifier a hook can read, so it is scoped by a short
# wall-clock window. Both failure modes are disclosed in the docs; this pins
# that the window exists and expires.
advisory_reset
advisory_claim once-only stop || fail "AR6: setup"
# A claim carries its window in its NAME, so an earlier turn's claim is simply
# a name nobody looks at. Rename it to a past window to simulate one.
for c in "$CLAUDE_ADVISORY_DIR"/stop.*.claim; do
  [ -d "$c" ] || continue
  mv "$c" "$CLAUDE_ADVISORY_DIR/stop.1.claim"
done
if advisory_defer_if_claimed stop; then
  fail "AR6: a claim from an earlier window must not silence this turn"
fi

# --- AR5: claiming is atomic -------------------------------------------------
# mkdir is atomic on every POSIX filesystem; a check-then-act would race.
advisory_reset
winners=0
for _ in 1 2 3 4 5 6 7 8; do
  ( advisory_claim once-only stop && echo won >> "$TMP/winners" ) &
done
wait
[ -f "$TMP/winners" ] && winners=$(grep -c . "$TMP/winners" || true)
[ "$winners" = "1" ] \
  || fail "AR5: exactly one concurrent claimant must win, got $winners"

# --- AR4b: never fails, never writes outside its store -----------------------
export CLAUDE_ADVISORY_DIR="$TMP/blocked/rail"
: > "$TMP/blocked"
set +e; advisory_claim once-only stop; rc=$?; set -e
[ "$rc" -le 1 ] || fail "AR4b: an unwritable store must not error out, got $rc"
set +e
( unset HOME; advisory_defer_if_claimed stop ); rc=$?
set -e
[ "$rc" -le 1 ] || fail "AR4b: HOME unset must not error out, got $rc"

echo "PASS: advisory rail — once-only speaks, repeating defers, claims are atomic and expire"
