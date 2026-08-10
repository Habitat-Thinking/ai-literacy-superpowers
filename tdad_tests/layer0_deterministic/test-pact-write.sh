#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the pact writer
# (spec 2026-08-10-cadence-sentinels-s3-mast-design.md, §5.5; T1–T9).
#
# T1 is the point of this file. The reader and the writer are one contract:
# whatever `pact_write_block` emits, `block_state` must call `declared`. S1
# built the reader with a preamble and ten scenarios; until this slice the
# producer of the file it parses was six sentences of prose in a command, and
# the failure mode of getting it wrong is the one S1 worked hardest to make
# quiet — a block reads `malformed`, every consumer drops to observe-only, and
# nothing tells the human which sentence is missing.
#
# The writer exists because these tests could not otherwise. A round trip
# through a model following prose is not a Layer-0 scenario.
#
# Two guarantees are easy to lose and are pinned here deliberately:
#
#   T5 — replace, never append. `_block_span` exits at the next known heading,
#        so a second `## Budgets` is silently unread and a human's newly tuned
#        values are invisible with no error anywhere.
#   T9 — the clause is DERIVED from templates/pacts.md, not restated. A
#        restated clause agrees with the reader only by coincidence of wording,
#        and the promoted decision is that harness artefacts derive from the
#        source of truth rather than pinning a copy of it.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$SCRIPT_DIR/../../ai-literacy-superpowers"
WRITER="$PLUGIN/hooks/scripts/lib/pact-write.sh"
READER="$PLUGIN/hooks/scripts/lib/pact-blocks.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

# Clause assertions match whitespace-normalised, exactly as pact-blocks.sh's
# `_flatten` does. The template wraps the Session WIP clause across two lines,
# so a raw grep would fail against a file the READER calls perfectly declared —
# which is the trap S2 hit on its first run and the reason the reader
# normalises at all. The clause's words are the interface; its line breaks are
# not.
flat_file() { tr '\n' ' ' < "$1" | tr -s '[:space:]' ' '; }
has_clause() { flat_file "$1" | grep -qF "$2"; }

[ -f "$WRITER" ] || fail "pact writer not found at $WRITER"
[ -f "$READER" ] || fail "pact reader not found at $READER"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export CLAUDE_PACTS_FILE="$TMP/pacts.md"

# shellcheck source=/dev/null
. "$WRITER"
# shellcheck source=/dev/null
. "$READER"

declare -F pact_write_block >/dev/null || fail "writer must define pact_write_block"

# body <line...> — a values-only block body on stdin, as Tune supplies it.
body() { printf '%s\n' "$@" > "$TMP/body"; printf '%s' "$TMP/body"; }

# --- T1: the writer's output reads as declared -------------------------------
# The round trip that makes the reader and the writer one contract.
pact_write_block "Budgets" "$(body '- hard_stop_hour: 18:30' '- sessions_per_day: 3')"
[ "$(block_state 'Budgets')" = "declared" ] \
  || fail "T1: a block written by the writer must read as declared, got '$(block_state 'Budgets')'"

# --- T2: the mandatory clause is present -------------------------------------
has_clause "$CLAUDE_PACTS_FILE" 'Unspent budget is not a debt.' \
  || fail "T2: the writer must emit the Budgets mandatory clause"

pact_write_block "Session WIP" "$(body '- max_concurrent_sessions: 2')"
[ "$(block_state 'Session WIP')" = "declared" ] \
  || fail "T2: Session WIP must also read as declared"
has_clause "$CLAUDE_PACTS_FILE" 'It counts; it does not assess.' \
  || fail "T2: the writer must emit the Session WIP mandatory clause"

# --- T3: the reserved marker is present --------------------------------------
pact_write_block "Sync cadence" "$(body '- interrupt_mode: coalesced')"
flat_file "$CLAUDE_PACTS_FILE" | grep -qiF 'Reserved. No sentinel reads this block yet.' \
  || fail "T3: the writer must emit the Sync cadence reserved marker"

# --- T7: colon- and space-bearing values survive the round trip --------------
# The S1 regression, now reachable from the writer's side.
val=$(block_key 'Budgets' 'hard_stop_hour' '')
[ "$val" = "18:30" ] || fail "T7: hard_stop_hour must round-trip as '18:30', got '$val'"

pact_write_block "Budgets" "$(body '- hard_stop_hour: 18:30' \
  '- focus_blocks: 09:00-12:00, 14:00-17:00' \
  '- daily_cost_ceiling: not observable')"
val=$(block_key 'Budgets' 'focus_blocks' '')
[ "$val" = "09:00-12:00, 14:00-17:00" ] \
  || fail "T7: focus_blocks must round-trip whole, got '$val'"
val=$(block_key 'Budgets' 'daily_cost_ceiling' '')
[ "$val" = "not observable" ] \
  || fail "T7: daily_cost_ceiling must keep its interior space, got '$val'"

# --- T5: a second write replaces, never appends ------------------------------
# The silent failure: an appended second heading is unread, so the human's
# newly tuned values are invisible and nothing reports an error.
headings=$(grep -c '^## Budgets$' "$CLAUDE_PACTS_FILE" || true)
[ "$headings" = "1" ] || fail "T5: expected exactly one '## Budgets' heading, found $headings"

pact_write_block "Budgets" "$(body '- hard_stop_hour: 21:00')"
headings=$(grep -c '^## Budgets$' "$CLAUDE_PACTS_FILE" || true)
[ "$headings" = "1" ] || fail "T5: a rewrite must not add a heading, found $headings"
val=$(block_key 'Budgets' 'hard_stop_hour' '')
[ "$val" = "21:00" ] || fail "T5: a rewrite must win, got '$val'"

# --- T6: the stamps land on Budgets only -------------------------------------
# S1's grammar defines authored_at/authored_via inside Budgets. Stamping every
# block would leave 'when was this pact authored' a per-block fact with no rule
# for combining them.
[ -n "$(block_key 'Budgets' 'authored_via' '')" ] \
  || fail "T6: Budgets must carry authored_via"
[ -n "$(block_key 'Budgets' 'authored_at' '')" ] \
  || fail "T6: Budgets must carry authored_at"
[ -z "$(block_key 'Session WIP' 'authored_via' '')" ] \
  || fail "T6: Session WIP must NOT be stamped — S1's grammar puts the stamps in Budgets"
[ -z "$(block_key 'Sync cadence' 'authored_at' '')" ] \
  || fail "T6: Sync cadence must NOT be stamped"

# --- T8: content outside the replaced block survives -------------------------
[ "$(block_state 'Session WIP')" = "declared" ] \
  || fail "T8: rewriting Budgets must not disturb Session WIP"
val=$(block_key 'Session WIP' 'max_concurrent_sessions' '')
[ "$val" = "2" ] || fail "T8: another block's values must survive, got '$val'"

# There is no "after" in this format. Everything following a heading belongs to
# that block until the next heading — the reader's own span rule — so a note
# appended at end-of-file sits INSIDE the last block and is legitimately
# replaced when that block is rewritten. The only content genuinely outside
# every block is the preamble, before the first heading. That is what must
# survive, and it is where the template's editing guidance lives.
python3 - "$CLAUDE_PACTS_FILE" <<'EOP'
import sys, pathlib
p = pathlib.Path(sys.argv[1]); lines = p.read_text().split("\n")
i = next(n for n, l in enumerate(lines) if l.startswith("## "))
lines.insert(i, "A human note in the preamble.")
p.write_text("\n".join(lines))
EOP
pact_write_block "Budgets" "$(body '- hard_stop_hour: 22:00')"
grep -qF 'A human note in the preamble.' "$CLAUDE_PACTS_FILE" \
  || fail "T8: preamble content — the only content outside every block — must survive a rewrite"

# --- T4: a skipped block is absent, not empty --------------------------------
export CLAUDE_PACTS_FILE="$TMP/partial.md"
pact_write_block "Budgets" "$(body '- hard_stop_hour: 18:30')"
[ "$(block_state 'Session WIP')" = "absent" ] \
  || fail "T4: an unwritten block must read absent, got '$(block_state 'Session WIP')'"
grep -q '^## Session WIP' "$CLAUDE_PACTS_FILE" \
  && fail "T4: an unwritten block must leave no heading behind"

# --- T9: the clause is derived from the template, not restated ---------------
# Changing the template must change what the writer emits, with no edit to the
# writer. A restated clause agrees with the reader only by coincidence.
tpl="$PLUGIN/templates/pacts.md"
cp "$tpl" "$TMP/tpl.bak"
sed -i.bak 's/Unspent budget is not a debt\./Unspent budget is not a debt, truly./' "$tpl"
rm -f "$tpl.bak"
export CLAUDE_PACTS_FILE="$TMP/derived.md"
pact_write_block "Budgets" "$(body '- hard_stop_hour: 18:30')"
derived_ok=0
has_clause "$CLAUDE_PACTS_FILE" 'Unspent budget is not a debt, truly.' && derived_ok=1
cp "$TMP/tpl.bak" "$tpl"
[ "$derived_ok" -eq 1 ] \
  || fail "T9: the clause must be derived from templates/pacts.md, not restated in the writer"

echo "PASS: pact writer — output reads as declared, replaces never appends, stamps scoped, clause derived"
