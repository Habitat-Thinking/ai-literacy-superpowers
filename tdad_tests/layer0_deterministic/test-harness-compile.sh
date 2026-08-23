#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for compilation, the enforcement report, and the drift check
# (spec 2026-08-23-harness-evolution-s2-compile-check-design.md, §8; C1-C19).
#
# C12 IS THE ONE THE REPORT EXISTS FOR. A rule declaring `enforcement: blocked`
# on a surface that supports blocked reports as blocked - while nothing,
# anywhere, refuses anything. That is worse than no report: a confident, legible,
# wrong answer produced by the very mechanism built to tell enforced from merely
# written down. So `achieved` also asks whether a declared validator resolves to
# a file that exists.
#
# C14 IS THE ONE BYTE-IDENTITY CANNOT CATCH. Region drift catches a hand-edit to
# a compiled rule. It does not catch an agent rewording the rule in the ACCEPTED
# HDR and recompiling - the region then matches the corpus exactly and every
# byte-identity check passes, while the rule in force quietly differs from the
# one the human approved. Hence the git-backed frozen-record check.
#
# C2 AND C6 GUARD THE SAME THING FROM OPPOSITE SIDES: a generator that eats
# hand-written content. C2 proves it does not touch what is outside the markers;
# C6 proves it refuses rather than guessing when the markers themselves are
# ambiguous.

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
mkdir -p "$DEC" "$HARNESS/assay" "$TMP/.github/workflows"

reg() { set +e; OUT="$( cd "$TMP" && "$PY" "$REG" "$@" 2>&1 )"; RC=$?; set -e; }

tree_hash() {
  ( cd "$TMP" && "$PY" -c "
import hashlib, os
h = hashlib.sha256()
for dirpath, dirs, files in os.walk('.'):
    dirs[:] = sorted(d for d in dirs if d != '.git')
    for name in sorted(files):
        p = os.path.join(dirpath, name)
        h.update(p.encode()); h.update(open(p, 'rb').read())
print(h.hexdigest())
" )
}

# A no-op commit exits 1, which under `set -e` would kill the suite. Whether a
# given step produced a change is not what any of these tests assert.
# `|| true` sits OUTSIDE the subshell deliberately: `A && B || C` is not
# if-then-else, and ShellCheck is right to say so (SC2015).
commit_all() {
  ( cd "$TMP" && git add -A && git commit -qm "$1" >/dev/null 2>&1 ) || true
}

expect_ok()   { [ "$RC" -eq 0 ] || fail "$1: expected exit 0, got $RC. Out: $OUT"; }
expect_fail() {
  [ "$RC" -ne 0 ] || fail "$1: expected non-zero exit, got 0. Out: $OUT"
  printf '%s' "$OUT" | grep -q 'Traceback' \
    && fail "$1: crashed instead of refusing. Out: $OUT"
  printf '%s' "$OUT" | grep -qi -- "$2" \
    || fail "$1: message must mention '$2'. Out: $OUT"
}

cat > "$HARNESS/surfaces.yaml" <<'EOF'
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md

surfaces:
  claude-code:
    targets: [CLAUDE.md, .claude/agents/]
    supports: [advisory, validated, blocked]
  codex:
    targets: [AGENTS.md]
    supports: [advisory]

  copilot:
    targets: [.github/copilot-instructions.md]
    supports: [advisory]
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF

# The hand-written target artifacts. Their content matters: C2 asserts every
# byte outside the markers is still here at the end.
cat > "$TMP/HARNESS.md" <<'EOF'
# Harness

## Context

Hand-written. Nothing generated may touch this line.

## Constraints

### An existing hand-written constraint

- **Rule**: Something a person wrote.
EOF
cp "$TMP/HARNESS.md" "$TMP/HARNESS.md.orig"

cat > "$TMP/AGENTS.md" <<'EOF'
# Agents

Hand-written turn instructions.
EOF

mkdir -p "$TMP/.claude/agents"
cat > "$TMP/.claude/agents/example.agent.md" <<'EOF'
---
name: example
---

# Example agent

Hand-written agent instructions.
EOF

cat > "$TMP/mkhdr.py" <<'PYEOF'
import json, os, sys

d = json.load(sys.stdin)
root = os.environ["FIXTURE_ROOT"]
hid = d["id"]
cls = d["classification"]
status = d.get("status", "accepted")
enf = d.get("enforcement", "validated")
surfaces = d.get("surfaces", ["claude-code"])
provisional = d.get("provisional", True)

L = ["---", f"id: {hid}", "title: " + d.get("title", "A governance rule"),
     f"status: {status}", f"classification: {cls}", f"enforcement: {enf}",
     "surfaces: [" + ", ".join(surfaces) + "]"]
if provisional:
    L += ["provisional: true", "expires: " + d.get("expires", "2026-11-19")]
else:
    L.append("provisional: false")
if d.get("target"):
    L.append("target: " + d["target"])
v = d.get("validator")
if isinstance(v, list):
    L.append("validator:")
    L += [f"  - {x}" for x in v]
elif v:
    L.append(f"validator: {v}")
L.append("evidence:")
for e in d.get("evidence", ["harness/assay/2026-08-21T16-02Z-assay.md#finding-1"]):
    L.append(f"  - {e}")
L += ["proposed_cost: |", "  The Assayer's estimate."]
if status == "accepted":
    L += ["cost: |", "  " + d.get("cost", "The approver's own words about this rule."),
          "approver: russ@russmiles.com", "approved_at: 2026-08-21T16:41Z"]
else:
    L.append('cost: ""')
# Each fixture gets its OWN assay by default. The three-per-cycle cap is S1's
# rule and S1's test proves it; here it would just be an unrelated tripwire.
L += ["proposer:", "  agent: harness-assayer", "  model: claude-opus-5",
      "  assay: " + d.get("assay", "harness/assay/" + hid + "-assay.md"),
      "supersedes: null", "superseded_by: null", "---", ""]

L += ["## Finding", "", d.get("finding", "Something was observed happening."), ""]
L += ["## Rule", ""]
if cls == "no-change":
    L.append("No change.")
else:
    rule = d.get("rule", "- **Rule**: The default fixture rule.")
    if d.get("rule_file"):
        rule = open(os.path.join(root, d["rule_file"])).read().rstrip("\n")
    L += ["````markdown", rule, "````"]
L += ["", "## Cost", "", "What this demands of whoever works here next.", ""]
if cls in ("harness-loop", "script-validator", "new-agent"):
    for h in ("Why this layer", "Enforcement", "Validation", "Rejected alternatives"):
        L += [f"## {h}", "", "A real, human-written answer.", ""]

path = os.path.join(root, "harness", "decisions", hid + ".md")
with open(path, "w") as fh:
    fh.write("\n".join(L).rstrip("\n") + "\n")
print(path)
PYEOF

mkhdr() { FIXTURE_ROOT="$TMP" "$PY" "$TMP/mkhdr.py" >/dev/null; }

cat > "$TMP/rule.txt" <<'EOF'
- **Rule**: A phase may not be reported complete on the strength of a  
  planned command. Cite observed output.

  ```bash
  npm test  # planned, never run
  ```
EOF

# === C1: compile establishes the markers, changing nothing else ==============
mkhdr <<'EOF'
{"id": "HDR-2026-08-21-observed-evidence",
 "title": "Require observed evidence",
 "classification": "harness-loop", "enforcement": "validated",
 "surfaces": ["claude-code", "copilot"], "rule_file": "rule.txt",
 "evidence": ["harness/assay/2026-08-04T09-12Z-assay.md#finding-1",
              "harness/assay/2026-08-21T16-02Z-assay.md#finding-3"]}
EOF

reg compile
expect_ok "C1 (compile establishes markers)"
grep -q 'BEGIN GENERATED: harness-registrar' "$TMP/HARNESS.md" \
  || fail "C1: no BEGIN marker in HARNESS.md"
grep -q 'END GENERATED: harness-registrar' "$TMP/HARNESS.md" \
  || fail "C1: no END marker in HARNESS.md"

# === C2: hand-written content outside the markers survives byte for byte =====
"$PY" - "$TMP/HARNESS.md" "$TMP/HARNESS.md.orig" <<'PYEOF'
import re, sys
now, orig = open(sys.argv[1]).read(), open(sys.argv[2]).read()
outside = re.sub(r"(?s)<!-- BEGIN GENERATED.*?END GENERATED[^>]*-->", "", now)
assert orig.strip() == outside.strip(), (
    "C2: content outside the markers changed.\n"
    f"--- was ---\n{orig!r}\n--- now ---\n{outside!r}")
PYEOF
echo "C2 ok (hand-written content survived)"

# === C3: the compiled rule body is byte-identical to the HDR's block =========
"$PY" - "$TMP/HARNESS.md" "$DEC/HDR-2026-08-21-observed-evidence.md" <<'PYEOF'
import sys
target, hdr = open(sys.argv[1]).read(), open(sys.argv[2]).read()
buf, blocks = None, []
for line in hdr.splitlines():
    if line.startswith("````") and (buf is None or line.strip() == "````"):
        if buf is None: buf = []
        else: blocks.append("\n".join(buf)); buf = None
        continue
    if buf is not None: buf.append(line)
assert len(blocks) == 1, "C3: HDR should hold exactly one rule block"
assert blocks[0] in target, (
    "C3: the compiled rule is NOT byte-identical to the HDR block.\n"
    f"--- want ---\n{blocks[0]!r}")
PYEOF
echo "C3 ok (compiled rule byte-identical, hard line break survived)"

# === C4: compilation is idempotent ==========================================
BEFORE="$(tree_hash)"
reg compile
expect_ok "C4 (second compile)"
[ "$(tree_hash)" = "$BEFORE" ] || fail "C4: compile is not idempotent"

# === C4b: two rules on one target, ordered deterministically =================
# Without a second rule on the same target, region ordering is untestable and a
# nondeterministic compiler would pass every other assertion here.
mkhdr <<'EOF'
{"id": "HDR-2026-08-20-earlier-rule", "title": "An earlier rule",
 "classification": "harness-loop", "enforcement": "advisory",
 "surfaces": ["claude-code"],
 "evidence": ["harness/assay/2026-08-01T09-00Z-assay.md#finding-1",
              "harness/assay/2026-08-04T09-12Z-assay.md#finding-2"]}
EOF
reg compile; expect_ok "C4b (two rules on one target)"
"$PY" - "$TMP/HARNESS.md" <<'PYEOF'
import sys
text = open(sys.argv[1]).read()
a = text.find("HDR-2026-08-20-earlier-rule")
b = text.find("HDR-2026-08-21-observed-evidence")
assert a != -1 and b != -1, "C4b: both rules must appear in the region"
assert a < b, "C4b: rules must be ordered by HDR id, oldest first"
PYEOF
echo "C4b ok (region ordered by id)"
BEFORE="$(tree_hash)"
reg compile; expect_ok "C4b (still idempotent with two rules)"
[ "$(tree_hash)" = "$BEFORE" ] || fail "C4b: compile is not idempotent with two rules"

# === C7: hand-editing a region fails check, and compile repairs it ===========
reg check
expect_ok "C7 (clean check)"
"$PY" - "$TMP/HARNESS.md" <<'PYEOF'
import sys
p = sys.argv[1]
t = open(p).read().replace("Cite observed output.", "Cite observed output, please.")
open(p, "w").write(t)
PYEOF
reg check
expect_fail "C7 (hand-edited region)" "drift"
reg compile
expect_ok "C7 (compile repairs)"
reg check
expect_ok "C7 (repaired)"

# === C8: rewording a rule body inside the region fails check =================
"$PY" - "$TMP/HARNESS.md" <<'PYEOF'
import sys
p = sys.argv[1]
text = open(p).read()
open(p, "w").write(text.replace("A phase may not be", "A phase must not be"))
PYEOF
reg check
expect_fail "C8 (reworded rule body)" "drift"
reg compile >/dev/null 2>&1 || true

# === C9: an accepted HDR whose target has no region fails check ==============
"$PY" - "$TMP/HARNESS.md" <<'PYEOF'
import re, sys
p = sys.argv[1]
open(p, "w").write(
    re.sub(r"(?s)\n?<!-- BEGIN GENERATED.*?END GENERATED[^>]*-->\n?", "\n", open(p).read()))
PYEOF
reg check
expect_fail "C9 (target has no generated region)" "never applied"
reg compile
expect_ok "C9 (compile reapplies)"

# === C5: a missing target artifact is refused, writing nothing ===============
mkhdr <<'EOF'
{"id": "HDR-2026-08-21-missing-target", "title": "Points at nothing",
 "classification": "agent-instruction", "enforcement": "advisory",
 "surfaces": ["claude-code"],
 "target": ".claude/agents/does-not-exist.agent.md"}
EOF
BEFORE="$(tree_hash)"
reg compile
expect_fail "C5 (target artifact does not exist)" "does-not-exist"
[ "$(tree_hash)" = "$BEFORE" ] || fail "C5: a refusal wrote to the tree"
rm -f "$DEC/HDR-2026-08-21-missing-target.md"

# === C6: malformed marker pairs are refused, writing nothing =================
malform() { "$PY" - "$TMP/HARNESS.md" "$1" <<'PYEOF'
import re, sys
p, mode = sys.argv[1], sys.argv[2]
t = open(p).read()
B = "<!-- BEGIN GENERATED: harness-registrar — do not edit by hand -->"
E = "<!-- END GENERATED: harness-registrar -->"
if mode == "end-first":
    t = t.replace(B, "PLACEHOLDER").replace(E, B).replace("PLACEHOLDER", E)
elif mode == "no-end":
    t = t.replace(E, "")
elif mode == "two-pairs":
    t = t + "\n" + B + "\n\nsecond region\n\n" + E + "\n"
open(p, "w").write(t)
PYEOF
}
for mode in end-first no-end two-pairs; do
  reg compile >/dev/null 2>&1
  cp "$TMP/HARNESS.md" "$TMP/HARNESS.md.good"
  malform "$mode"
  BEFORE="$(tree_hash)"
  reg compile
  expect_fail "C6 ($mode)" "marker"
  [ "$(tree_hash)" = "$BEFORE" ] || fail "C6 ($mode): a refusal wrote to the tree"
  reg check
  expect_fail "C6 ($mode) check" "marker"
  cp "$TMP/HARNESS.md.good" "$TMP/HARNESS.md"
done
rm -f "$TMP/HARNESS.md.good"
reg compile; expect_ok "C6 (recovered)"

# === C10/C11/C12: the enforcement report ====================================
REPORT="$HARNESS/enforcement-report.md"
[ -f "$REPORT" ] || fail "C10: no enforcement report at $REPORT"

mkhdr <<'EOF'
{"id": "HDR-2026-08-21-blocked-everywhere", "title": "Wants to block",
 "classification": "turn-instructions", "enforcement": "blocked",
 "surfaces": ["claude-code", "copilot", "ci"]}
EOF
reg compile; expect_ok "C10 (compile with a blocked rule)"

grep -q 'HDR-2026-08-21-blocked-everywhere' "$REPORT" \
  || fail "C10: the blocked rule is missing from the report"
# copilot supports advisory only: a blocked intent degrades, and says so.
grep -qi 'copilot.*blocked.*advisory.*gap' "$REPORT" \
  || fail "C11: copilot's degradation is not reported as a gap. Report:
$(cat "$REPORT")"
# No validator anywhere: claude-code supports blocked but nothing enforces it.
grep -qi 'no validator' "$REPORT" \
  || fail "C12: a blocked rule with no validator is not reported as degraded.
$(cat "$REPORT")"

# === C12b: a validator that does not exist must not lift the degradation =====
# A declared-but-absent validator is exactly the failure this report is built to
# catch. Believing the declaration would defeat the mechanism at the one point it
# actually bites, and the resulting report would be confidently wrong - which is
# worse than no report at all.
rm -f "$DEC/HDR-2026-08-21-blocked-everywhere.md"
mkhdr <<'EOF'
{"id": "HDR-2026-08-21-blocked-everywhere", "title": "Wants to block",
 "classification": "turn-instructions", "enforcement": "blocked",
 "surfaces": ["claude-code", "copilot", "ci"],
 "validator": ".github/workflows/ghost-that-does-not-exist.sh"}
EOF
reg compile; expect_ok "C12b (compile with an absent validator)"
# Scoped to THIS record's section. A bare grep over the whole report matched the
# identical message emitted for a different HDR, and passed against a checker
# mutated to trust the declaration - the same shape of false pass twice over.
"$PY" - "$REPORT" <<'PYEOF'
import re, sys
report = open(sys.argv[1]).read()
block = report.split("HDR-2026-08-21-blocked-everywhere", 1)[1].split("\n## ", 1)[0]
rows = {m.group(1): (m.group(3), m.group(5)) for m in
        re.finditer(r"^\| (\S+) \| (\S+) \| (\S+) \| (\S+) \| ([^|]*)\|", block, re.M)}
achieved, why = rows.get("claude-code", ("?", "?"))
assert achieved == "advisory", (
    "C12b: a declared-but-ABSENT validator lifted the degradation; "
    f"claude-code achieved {achieved!r}")
assert "no validator" in why, f"C12b: the reason should name the validator, got {why!r}"
PYEOF
echo "C12b ok (an absent validator does not lift the degradation)"

# === C13: a resolvable validator lifts the degradation ======================
printf '#!/usr/bin/env bash\nset -euo pipefail\nexit 0\n' \
  > "$TMP/.github/workflows/enforce.sh"
rm -f "$DEC/HDR-2026-08-21-blocked-everywhere.md"
mkhdr <<'EOF'
{"id": "HDR-2026-08-21-blocked-everywhere", "title": "Wants to block",
 "classification": "turn-instructions", "enforcement": "blocked",
 "surfaces": ["claude-code", "copilot", "ci"],
 "validator": ".github/workflows/enforce.sh"}
EOF
reg compile; expect_ok "C13 (compile with a resolvable validator)"
"$PY" - "$REPORT" <<'PYEOF'
import re, sys
report = open(sys.argv[1]).read()
block = report.split("HDR-2026-08-21-blocked-everywhere", 1)[1].split("\n## ", 1)[0]
rows = {m.group(1): m.group(3) for m in
        re.finditer(r"^\| (\S+) \| (\S+) \| (\S+) \|", block, re.M)}
assert rows.get("claude-code") == "blocked", \
    f"C13: claude-code should achieve blocked with a validator, got {rows}"
assert rows.get("ci") == "blocked", \
    f"C13: ci should achieve blocked with a validator, got {rows}"
assert rows.get("copilot") == "advisory", \
    f"C13: copilot still cannot exceed advisory, got {rows}"
PYEOF
echo "C13 ok (a resolvable validator lifts the degradation)"

# === C18: a no-change HDR compiles nowhere ==================================
mkhdr <<'EOF'
{"id": "HDR-2026-08-21-nothing-to-do", "title": "Nothing to do",
 "classification": "no-change", "enforcement": "advisory",
 "surfaces": [], "provisional": false}
EOF
reg compile; expect_ok "C18 (compile with a no-change HDR)"
grep -q 'HDR-2026-08-21-nothing-to-do' "$TMP/HARNESS.md" \
  && fail "C18: a no-change HDR was compiled into HARNESS.md"
grep -q 'HDR-2026-08-21-nothing-to-do' "$TMP/AGENTS.md" \
  && fail "C18: a no-change HDR was compiled into AGENTS.md"
reg check; expect_ok "C18 (check still clean)"

# === C19: report and index drift both fail check ============================
printf '\nhand-added line\n' >> "$REPORT"
reg check; expect_fail "C19 (report drift)" "drift"
reg compile >/dev/null; reg check; expect_ok "C19 (repaired)"
printf '\nhand-added line\n' >> "$DEC/index.md"
reg check; expect_fail "C19 (index drift)" "drift"
reg compile >/dev/null; reg check; expect_ok "C19 (repaired)"

# === C14/C15: the frozen-record check =======================================
( cd "$TMP" && git init -q && git config user.email t@example.invalid \
    && git config user.name Test )
commit_all seed
reg check; expect_ok "C14 (clean after commit)"

# C15 first: an accepted HDR that has never been committed is SKIPPED, not
# failed. Otherwise the accept-then-commit cycle could never pass its own check.
mkhdr <<'EOF'
{"id": "HDR-2026-08-22-never-committed", "title": "Not yet in git",
 "classification": "turn-instructions", "enforcement": "advisory",
 "surfaces": ["codex"]}
EOF
reg compile >/dev/null 2>&1 || true
reg check
[ "$RC" -eq 0 ] || fail "C15: an uncommitted accepted HDR must not fail check. Out: $OUT"
printf '%s' "$OUT" | grep -qi 'not yet committed\|never committed\|uncommitted' \
  || fail "C15: the skip must be reported as a note. Out: $OUT"
rm -f "$DEC/HDR-2026-08-22-never-committed.md"
reg compile >/dev/null
commit_all compile

# C14: editing an accepted HDR after the commit that accepted it.
"$PY" - "$DEC/HDR-2026-08-21-observed-evidence.md" <<'PYEOF'
import sys
p = sys.argv[1]
text = open(p).read()
open(p, "w").write(text.replace("Cite observed output.", "Cite observed output, or say why not."))
PYEOF
reg compile >/dev/null
reg check
expect_fail "C14 (accepted HDR edited after acceptance)" "frozen"

# Put it back and re-commit so the remaining tests run on a clean tree.
"$PY" - "$DEC/HDR-2026-08-21-observed-evidence.md" <<'PYEOF'
import sys
p = sys.argv[1]
text = open(p).read()
open(p, "w").write(text.replace("Cite observed output, or say why not.", "Cite observed output."))
PYEOF
reg compile >/dev/null
reg check; expect_ok "C14 (restored)"

# === C14b: the baseline is the ACCEPTING revision, not the first =============
# An HDR committed while still `proposed` and accepted later has a first
# revision that differs from its accepted content by design. A frozen check
# comparing against the first revision would fail every such record - which is
# most of them, since proposals are committed and reviewed before acceptance.
printf 'A cost written by a person, in their own words.\n' > "$TMP/cost.txt"
mkhdr <<'EOF'
{"id": "HDR-2026-08-23-proposed-then-accepted", "title": "Proposed first",
 "classification": "turn-instructions", "status": "proposed",
 "enforcement": "advisory", "surfaces": ["codex"]}
EOF
commit_all propose
reg accept --hdr harness/decisions/HDR-2026-08-23-proposed-then-accepted.md \
  --cost-file cost.txt --approver russ@russmiles.com --now 2026-08-23T09:00Z
expect_ok "C14b (accept a record that was committed while proposed)"
commit_all accept
reg check
expect_ok "C14b (frozen check uses the accepting revision, not the first)"

# === C16/C17: acceptance applies and compiles in one transaction ============
mkhdr <<'EOF'
{"id": "HDR-2026-08-22-needs-a-target", "title": "Needs a target",
 "classification": "agent-instruction", "status": "proposed",
 "enforcement": "advisory", "surfaces": ["claude-code"]}
EOF
printf 'A cost written by a person, in their own words.\n' > "$TMP/cost.txt"

BEFORE="$(tree_hash)"
reg accept --hdr harness/decisions/HDR-2026-08-22-needs-a-target.md \
  --cost-file cost.txt --approver russ@russmiles.com --now 2026-08-22T10:00Z
expect_fail "C17 (no route and no target)" "target"
[ "$(tree_hash)" = "$BEFORE" ] || fail "C17: a refusal wrote to the tree"

# Give it a target that exists; acceptance must now apply AND compile.
"$PY" - "$DEC/HDR-2026-08-22-needs-a-target.md" <<'PYEOF'
import sys
p = sys.argv[1]
t = open(p).read().replace("surfaces: [claude-code]",
    "surfaces: [claude-code]\ntarget: .claude/agents/example.agent.md")
open(p, "w").write(t)
PYEOF
reg accept --hdr harness/decisions/HDR-2026-08-22-needs-a-target.md \
  --cost-file cost.txt --approver russ@russmiles.com --now 2026-08-22T10:00Z
expect_ok "C16 (accept applies and compiles)"
grep -q 'HDR-2026-08-22-needs-a-target' "$TMP/.claude/agents/example.agent.md" \
  || fail "C16: acceptance did not apply the rule to its target"
grep -q 'Hand-written agent instructions.' "$TMP/.claude/agents/example.agent.md" \
  || fail "C16: acceptance clobbered hand-written content in the target"
reg check; expect_ok "C16 (check clean after accept)"

# And a failing acceptance leaves every artifact byte-identical.
commit_all accepted
mkhdr <<'EOF'
{"id": "HDR-2026-08-22-bad-target", "title": "Bad target",
 "classification": "agent-instruction", "status": "proposed",
 "enforcement": "advisory", "surfaces": ["claude-code"],
 "target": ".claude/agents/nope.agent.md"}
EOF
BEFORE="$(tree_hash)"
reg accept --hdr harness/decisions/HDR-2026-08-22-bad-target.md \
  --cost-file cost.txt --approver russ@russmiles.com --now 2026-08-22T10:05Z
expect_fail "C16 (accept with an unreachable target)" "nope.agent.md"
[ "$(tree_hash)" = "$BEFORE" ] \
  || fail "C16: a failed acceptance changed the tree"

echo "harness compile/check: all checks passed (C1-C19)"
