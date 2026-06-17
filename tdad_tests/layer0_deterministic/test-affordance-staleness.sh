#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for harness-affordance-staleness.sh (step 6). --today fixes
# "now" so every scenario is hermetic; fixtures live in temp project dirs.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="$SCRIPT_DIR/../../ai-literacy-superpowers/scripts/harness-affordance-staleness.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

# mkproj <harness-body> -> temp dir
mkproj() { local d; d=$(mktemp -d); printf '%s\n' "$1" > "$d/HARNESS.md"; printf '%s' "$d"; }

run() { OUT=$("$S" "$@" 2>&1); }

BODY='# H
## Affordances
### stale-tool
- **Mode**: cli
- **Last reviewed**: 2025-01-01
### fresh-tool
- **Mode**: cli
- **Last reviewed**: 2026-06-01
### a-hook
- **Mode**: hook
- **Last reviewed**: 2024-01-01
### example-tool
<!-- affordance-example -->
- **Mode**: cli
- **Last reviewed**: 2020-01-01
### undated-tool
- **Mode**: cli
- **Last reviewed**: TODO
## Status'

d=$(mkproj "$BODY")

# Scenario 3/4/5/6/7: default threshold 180, today 2026-06-16.
run --today=2026-06-16 "$d"
echo "$OUT" | grep -q "STALE: affordance 'stale-tool'" || fail "stale-tool should be STALE: $OUT"
echo "$OUT" | grep -q "STALE: affordance 'a-hook'" || fail "hook entry must be INCLUDED in staleness: $OUT"
echo "$OUT" | grep -q "UNDATED: affordance 'undated-tool'" || fail "undated entry should be UNDATED: $OUT"
echo "$OUT" | grep -q "fresh-tool" && fail "fresh-tool (within 180d) must not be flagged: $OUT"
echo "$OUT" | grep -q "example-tool" && fail "example entry must be skipped: $OUT"
rm -rf "$d"

# Scenario 8: threshold override flags an otherwise-fresh entry.
d=$(mkproj "$BODY")
run --today=2026-06-16 --max-age-days=10 "$d"
echo "$OUT" | grep -q "STALE: affordance 'fresh-tool'" || fail "fresh-tool (15d) should flag at threshold 10: $OUT"
rm -rf "$d"

# All-fresh -> OK line, exit 0.
d=$(mkproj '# H
## Affordances
### t
- **Mode**: cli
- **Last reviewed**: 2026-06-10
## Status')
run --today=2026-06-16 "$d"
echo "$OUT" | grep -q "OK: all affordances reviewed within 180 days" || fail "all-fresh should report OK: $OUT"
rm -rf "$d"

# HARNESS.md marker threshold (read from INSIDE the ## Affordances section) is
# applied; the flag overrides it.
d=$(mkproj '# H
## Affordances
<!-- affordance-review-threshold-days: 30 -->
### t
- **Mode**: cli
- **Last reviewed**: 2026-05-01
## Status')
run --today=2026-06-16 "$d"
echo "$OUT" | grep -q "threshold 30" || fail "scanner should read the in-section marker threshold (30): $OUT"
echo "$OUT" | grep -q "STALE: affordance 't'" || fail "46d entry should be stale at marker threshold 30: $OUT"
run --today=2026-06-16 --max-age-days=180 "$d"
echo "$OUT" | grep -q "OK:" || fail "flag (180) should override the marker (30): $OUT"
rm -rf "$d"

# O1: a competing marker OUTSIDE the ## Affordances section must NOT win.
d=$(mkproj '# H
<!-- affordance-review-threshold-days: 999 -->
## Affordances
<!-- affordance-review-threshold-days: 30 -->
### t
- **Mode**: cli
- **Last reviewed**: 2026-05-01
## Status')
run --today=2026-06-16 "$d"
echo "$OUT" | grep -q "threshold 30" || fail "O1: the in-section marker (30) must win over an earlier out-of-section one (999): $OUT"
rm -rf "$d"

# O2: UTC machine-independence — the same fixture yields the same verdict
# under wildly different timezones.
d=$(mkproj '# H
## Affordances
### t
- **Mode**: cli
- **Last reviewed**: 2026-01-01
## Status')
a=$(TZ=Pacific/Kiritimati "$S" --today=2026-06-16 "$d")
b=$(TZ=Pacific/Pago_Pago "$S" --today=2026-06-16 "$d")
[ "$a" = "$b" ] || fail "O2: verdict must be timezone-independent (got '$a' vs '$b')"
rm -rf "$d"

# O3: a future Last reviewed date is FUTURE, not silently fresh.
d=$(mkproj '# H
## Affordances
### futuristic
- **Mode**: cli
- **Last reviewed**: 2099-01-01
## Status')
run --today=2026-06-16 "$d"
echo "$OUT" | grep -q "FUTURE: affordance 'futuristic'" || fail "O3: future date should be flagged FUTURE: $OUT"
rm -rf "$d"

# O4: a calendar-impossible date is UNDATED on any platform (not rolled over).
d=$(mkproj '# H
## Affordances
### bad-date
- **Mode**: cli
- **Last reviewed**: 2026-02-30
## Status')
run --today=2026-06-16 "$d"
echo "$OUT" | grep -q "UNDATED: affordance 'bad-date'" || fail "O4: impossible date should be UNDATED: $OUT"
rm -rf "$d"

# O6: a Notes line quoting the example marker must NOT skip a real entry.
d=$(mkproj '# H
## Affordances
### real
- **Mode**: cli
- **Last reviewed**: 2020-01-01
- **Notes**: this is not an <!-- affordance-example --> entry
## Status')
run --today=2026-06-16 "$d"
echo "$OUT" | grep -q "STALE: affordance 'real'" || fail "O6: a real entry mentioning the marker in Notes must still be scanned: $OUT"
rm -rf "$d"

# No ## Affordances section -> graceful, exit 0.
d=$(mkproj '# H
## Constraints')
run --today=2026-06-16 "$d"
echo "$OUT" | grep -qi "nothing to check" || fail "no section should report nothing to check: $OUT"
rm -rf "$d"

# UTC determinism: the same fixture + --today yields the same verdict.
d=$(mkproj '# H
## Affordances
### t
- **Mode**: cli
- **Last reviewed**: 2026-01-01
## Status')
a=$("$S" --today=2026-06-16 "$d")
b=$("$S" --today=2026-06-16 "$d")
[ "$a" = "$b" ] || fail "scanner must be deterministic for a fixed --today"
rm -rf "$d"

echo "All affordance-staleness tests passed."
