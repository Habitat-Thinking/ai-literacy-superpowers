#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the Observatory intervention feed
# (spec 2026-08-23-harness-evolution-s5-observatory-design.md, §8; T1-T13).
#
# T3 IS THE ONE THAT DECIDES WHETHER THE FEED IS USABLE. Whether a rule is
# expired RIGHT NOW depends on the clock, so a feed carrying that produces
# different output on different days from a corpus nobody touched - and a
# difference-in-differences run in November would disagree with the same run in
# September. `expires` is emitted as data and the consumer decides what it means
# at their analysis date.
#
# T9 IS THE OTHER HALF. An intervention with no end is a step function that never
# steps back: without `superseded_by` and `ends`, every rule ever retired is
# still counted as in force.
#
# T5's `none` case matters more than it looks. A no-change record says governance
# was examined at a known moment and deliberately not changed - a control
# observation, not an absence. Dropping it would convert "we looked and decided
# no" into "nobody looked", which is the difference a governance study is trying
# to measure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
REG="$ROOT/ai-literacy-superpowers/scripts/harness-registrar.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$REG" ] || fail "harness registrar not found at $REG"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
HARNESS="$TMP/harness"
DEC="$HARNESS/decisions"
mkdir -p "$DEC" "$HARNESS/assay"

reg() { set +e; OUT="$( cd "$TMP" && "$PY" "$REG" "$@" 2>&1 )"; RC=$?; set -e; }

tree_hash() {
  ( cd "$TMP" && "$PY" -c "
import hashlib, os
h = hashlib.sha256()
for dirpath, dirs, files in os.walk('.'):
    dirs[:] = sorted(dirs)
    for name in sorted(files):
        p = os.path.join(dirpath, name)
        h.update(p.encode()); h.update(open(p, 'rb').read())
print(h.hexdigest())
" )
}

cat > "$HARNESS/surfaces.yaml" <<'EOF'
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md

surfaces:
  claude-code:
    targets: [CLAUDE.md]
    supports: [advisory, validated, blocked]
  codex:
    targets: [AGENTS.md]
    supports: [advisory]
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF

cat > "$TMP/mkhdr.py" <<'PYEOF'
import json, os, sys

d = json.load(sys.stdin)
root = os.environ["FIXTURE_ROOT"]
hid = d["id"]
cls = d.get("classification", "turn-instructions")
status = d.get("status", "accepted")

L = ["---", f"id: {hid}", "title: " + d.get("title", "A rule"),
     f"status: {status}", f"classification: {cls}",
     "enforcement: " + d.get("enforcement", "advisory"),
     "surfaces: [" + ", ".join(d.get("surfaces", ["claude-code"])) + "]"]
if d.get("provisional", True):
    L += ["provisional: true", "expires: " + d.get("expires", "2099-01-01")]
else:
    L.append("provisional: false")
if d.get("cohort"):
    L.append("cohort: " + d["cohort"])
L.append("evidence:")
for e in d.get("evidence", ["harness/build-log.md#x"]):
    L.append(f"  - {e}")
L += ["proposed_cost: |", "  An estimate."]
if status == "accepted":
    L += ["cost: |", "  The approver's own words.",
          "approver: russ@russmiles.com",
          "approved_at: " + d.get("approved_at", "2026-01-01T00:00Z")]
else:
    L.append('cost: ""')
L += ["proposer:", "  agent: harness-assayer", "  model: claude-opus-5"]
if d.get("assay", "x"):
    L.append("  assay: harness/assay/" + hid + "-assay.md")
L.append("supersedes: " + (d["supersedes"] if d.get("supersedes") else "null"))
L.append("superseded_by: null")
L += ["---", "", "## Finding", "", "Something was observed.", "", "## Rule", ""]
if d.get("withdrawn"):
    L.append("Withdrawn.")
elif cls == "no-change":
    L.append("No change.")
else:
    L += ["````markdown", "- **Rule**: The fixture rule.", "````"]
L += ["", "## Cost", "", "What this demands of whoever works here next.", ""]
if cls in ("harness-loop", "script-validator", "new-agent"):
    for h in ("Why this layer", "Enforcement", "Validation", "Rejected alternatives"):
        L += [f"## {h}", "", "A real, human-written answer.", ""]

with open(os.path.join(root, "harness", "decisions", hid + ".md"), "w") as fh:
    fh.write("\n".join(L).rstrip("\n") + "\n")
PYEOF
mkhdr() { FIXTURE_ROOT="$TMP" "$PY" "$TMP/mkhdr.py"; }

# --- the corpus --------------------------------------------------------------
mkhdr <<'EOF'
{"id": "HDR-2026-01-01-first", "title": "A new rule", "enforcement": "validated",
 "surfaces": ["claude-code"], "cohort": "b", "approved_at": "2026-01-01T09:00Z"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-02-01-weakened", "title": "Weakened", "enforcement": "advisory",
 "surfaces": ["claude-code"], "supersedes": "HDR-2026-01-01-first",
 "approved_at": "2026-02-01T09:00Z"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-03-01-nothing", "title": "Nothing to change",
 "classification": "no-change", "enforcement": "advisory", "surfaces": [],
 "provisional": false, "approved_at": "2026-03-01T09:00Z"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-04-01-lapsed", "title": "Past its date", "enforcement": "advisory",
 "expires": "2026-05-01", "approved_at": "2026-04-01T09:00Z"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-05-01-narrow", "title": "Narrow surfaces", "enforcement": "advisory",
 "surfaces": ["claude-code"], "approved_at": "2026-05-01T09:00Z"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-06-01-widened", "title": "Widened surfaces", "enforcement": "advisory",
 "surfaces": ["claude-code", "codex"], "supersedes": "HDR-2026-05-01-narrow",
 "approved_at": "2026-06-01T09:00Z"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-07-01-strong", "title": "Strong rule", "enforcement": "blocked",
 "surfaces": ["ci"], "approved_at": "2026-07-01T09:00Z"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-08-01-retired", "title": "Withdraw the strong rule",
 "enforcement": "blocked", "surfaces": ["ci"], "withdrawn": true,
 "supersedes": "HDR-2026-07-01-strong", "approved_at": "2026-08-01T09:00Z",
 "evidence": ["harness/decisions/HDR-2026-07-01-strong.md"]}
EOF
# Not interventions: nothing was ever in force.
mkhdr <<'EOF'
{"id": "HDR-2026-09-01-draft", "title": "Still a draft", "status": "proposed"}
EOF
mkhdr <<'EOF'
{"id": "HDR-2026-09-02-declined", "title": "Declined", "status": "rejected"}
EOF

# === T13: the command writes nothing =========================================
BEFORE="$(tree_hash)"
reg timeline
[ "$RC" -eq 0 ] || fail "T1: timeline exited $RC. Out: $OUT"
[ "$(tree_hash)" = "$BEFORE" ] || fail "T13: timeline wrote to disk"
printf '%s\n' "$OUT" > "$TMP/feed-1.jsonl"

# === T2: byte-identical on re-run ============================================
reg timeline
printf '%s\n' "$OUT" > "$TMP/feed-2.jsonl"
cmp -s "$TMP/feed-1.jsonl" "$TMP/feed-2.jsonl" \
  || fail "T2: the feed is not byte-identical on re-run"

"$PY" - "$TMP/feed-1.jsonl" "$DEC" <<'PYEOF'
import json, os, sys

lines = [ln for ln in open(sys.argv[1]).read().splitlines() if ln.strip()]
dec = sys.argv[2]

# --- T4: every line is valid JSON, with a stable key order -------------------
rows = []
for ln in lines:
    rows.append(json.loads(ln))
keysets = {tuple(json.loads(ln).keys()) for ln in lines}
assert len(keysets) == 1, f"T4: key order/set differs between lines: {keysets}"

by_id = {r["id"]: r for r in rows}

# --- T1/T12: one line per accepted record, no more and no fewer --------------
accepted = set()
for name in os.listdir(dec):
    if not name.startswith("HDR-"):
        continue
    text = open(os.path.join(dec, name)).read()
    fm = text.split("---", 2)[1]
    if "\nstatus: accepted\n" in fm:
        accepted.add(name[:-3])
assert set(by_id) == accepted, (
    "T1/T12: the feed does not match the accepted records exactly.\n"
    f"  missing: {sorted(accepted - set(by_id))}\n"
    f"  spurious: {sorted(set(by_id) - accepted)}")
assert len(rows) == len(by_id), "T12: duplicate lines in the feed"

# --- T3: no field derives from the current date ------------------------------
lapsed = by_id["HDR-2026-04-01-lapsed"]
assert lapsed["state"] == "in force", (
    "T3: a record past its expiry reports "
    f"{lapsed['state']!r}. Expiry is a CLOCK fact, and a feed carrying one "
    "produces different output on different days from an unchanged corpus.")
assert lapsed["expires"] == "2026-05-01", \
    "T3: `expires` must be emitted as data so the consumer can decide"

# --- T5: a first rule tightens; a no-change record is `none` -----------------
assert by_id["HDR-2026-01-01-first"]["direction"] == "tighten", \
    "T5: a rule that was not there before is a tightening"
assert by_id["HDR-2026-03-01-nothing"]["direction"] == "none", \
    "T5: a no-change record is an intervention of size zero, not an absence"

# --- T6: a retirement loosens ------------------------------------------------
# Its declared enforcement and surfaces are IDENTICAL to its predecessor's, so
# the ladder and the surface comparison both say `same`. Only the retirement
# branch can explain a `loosen` here. The first version of this fixture also
# lowered the enforcement, and passed against a checker with the retirement
# branch deleted.
assert by_id["HDR-2026-08-01-retired"]["direction"] == "loosen", \
    "T6: withdrawing a rule is a loosening"

# --- T7: the enforcement ladder ---------------------------------------------
assert by_id["HDR-2026-02-01-weakened"]["direction"] == "loosen", \
    "T7: validated -> advisory is a loosening"

# --- T8: surfaces break the tie only at equal enforcement -------------------
assert by_id["HDR-2026-06-01-widened"]["direction"] == "tighten", \
    "T8: the same enforcement reaching more surfaces is a tightening"

# --- T9: a superseded record carries its end --------------------------------
first = by_id["HDR-2026-01-01-first"]
assert first["state"] == "superseded", f"T9: state is {first['state']!r}"
assert first["superseded_by"] == "HDR-2026-02-01-weakened", \
    "T9: the successor must be derived into the feed"
assert first["ends"] == "2026-02-01", (
    "T9: `ends` must carry the successor's date. An intervention with no end is "
    "a step function that never steps back.")
live = by_id["HDR-2026-06-01-widened"]
assert live["state"] == "in force" and live["superseded_by"] is None \
    and live["ends"] is None, "T9: a live record must not claim an end"

# --- T10: cohort -------------------------------------------------------------
assert by_id["HDR-2026-01-01-first"]["cohort"] == "b", "T10: cohort not emitted"
assert by_id["HDR-2026-05-01-narrow"]["cohort"] is None, \
    "T10: an absent cohort must be null, not omitted"

# --- T11: deterministic ordering --------------------------------------------
order = [(r["date"], r["id"]) for r in rows]
assert order == sorted(order), f"T11: the feed is not ordered by date then id: {order}"

print(f"parsed {len(rows)} intervention(s)")
PYEOF

# === T8b: overlapping-but-different surface sets are `same` ==================
# Nothing honest can be said about which of two overlapping sets is stronger.
mkhdr <<'EOF'
{"id": "HDR-2026-10-01-sideways", "title": "Sideways", "enforcement": "advisory",
 "surfaces": ["codex"], "supersedes": "HDR-2026-06-01-widened",
 "approved_at": "2026-10-01T09:00Z",
 "evidence": ["harness/decisions/HDR-2026-06-01-widened.md"]}
EOF
reg timeline
printf '%s' "$OUT" | "$PY" -c "
import json, sys
rows = {json.loads(l)['id']: json.loads(l) for l in sys.stdin if l.strip()}
d = rows['HDR-2026-10-01-sideways']['direction']
assert d == 'loosen', f'expected loosen for a narrowed subset, got {d!r}'
print('T8b ok (a narrowed surface set loosens)')
"

echo "harness timeline: all checks passed (T1-T13)"
