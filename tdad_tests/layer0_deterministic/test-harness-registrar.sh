#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the Harness Registrar's write path
# (spec 2026-08-23-harness-evolution-s1-registrar-design.md, §9; R1-R16).
#
# R2 IS THE ONE THIS PHASE EXISTS FOR. The build spec says /harness-propose
# "copies proposed rule text verbatim". An agent asked to copy text usually
# copies it and occasionally improves it - fixes a typo, tidies a bullet,
# rewraps a line - and every one of those is a silent edit to a rule a human is
# about to approve believing it to be the Assayer's words. So the copy is done
# by a script, and R2 asserts byte-identity rather than trusting an instruction.
#
# R13 IS THE OTHER ONE. Acceptance must be all-or-nothing, and the cycle cap is
# corpus-level: it cannot be evaluated from the candidate alone. So accept
# validates against a staging copy of the whole corpus and only then writes.
# R13 hashes every file under harness/ before and after each refusal, because
# "nothing was written" is a claim that deserves a measurement rather than a
# reading of the code.
#
# THE CLOCK IS INJECTED, NOT READ (#527). --today and --now exist so this suite
# cannot fail because it ran at the wrong hour or on the wrong day.

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
ASSAY="$HARNESS/assay"
mkdir -p "$DEC" "$ASSAY"

A1="harness/assay/2026-08-21T16-02Z-assay.md"
A0="harness/assay/2026-08-12T14-03Z-assay.md"

reg() {
  set +e
  OUT="$( cd "$TMP" && "$PY" "$REG" "$@" 2>&1 )"
  RC=$?
  set -e
}

# Every file under harness/, path and content, in one digest. "Nothing was
# written" is a measurable claim; asserting it by reading the code is not.
corpus_hash() {
  ( cd "$TMP" && "$PY" -c "
import hashlib, os
h = hashlib.sha256()
for dirpath, dirs, files in os.walk('harness'):
    dirs.sort()
    for name in sorted(files):
        p = os.path.join(dirpath, name)
        h.update(p.encode())
        h.update(open(p, 'rb').read())
print(h.hexdigest())
" )
}

expect_ok()   { [ "$RC" -eq 0 ] || fail "$1: expected exit 0, got $RC. Out: $OUT"; }
expect_fail() {
  [ "$RC" -ne 0 ] || fail "$1: expected non-zero exit, got 0. Out: $OUT"
  printf '%s' "$OUT" | grep -q 'Traceback' \
    && fail "$1: crashed instead of refusing. Out: $OUT"
  printf '%s' "$OUT" | grep -qi -- "$2" \
    || fail "$1: message must mention '$2'. Out: $OUT"
}

# The artifacts rules are applied to. Acceptance now applies AND compiles in one
# transaction, so a record routing to a file that does not exist refuses the
# whole acceptance - the Registrar writes records, not governance documents.
printf '# Harness\n\nHand-written.\n' > "$TMP/HARNESS.md"
printf '# Agents\n\nHand-written.\n' > "$TMP/AGENTS.md"
mkdir -p "$TMP/.claude/agents"
printf -- '---\nname: example\n---\n\n# Example agent\n\nHand-written.\n' \
  > "$TMP/.claude/agents/example.agent.md"

cat > "$HARNESS/surfaces.yaml" <<'EOF'
routes:
  harness-loop: HARNESS.md
  turn-instructions: AGENTS.md

surfaces:
  claude-code:
    targets: [CLAUDE.md, .claude/agents/]
    supports: [advisory, validated, blocked]
  copilot:
    targets: [.github/copilot-instructions.md]
    supports: [advisory]
  ci:
    targets: [.github/workflows/]
    supports: [validated, blocked]
EOF

# --- The assay fixtures ------------------------------------------------------
# Written by hand here rather than generated, because this file IS the contract
# S3's Assayer must satisfy. A fixture assembled by a helper would let the
# contract drift into whatever the helper happened to emit.

cat > "$TMP/$A1" <<'EOF'
---
assay: harness/assay/2026-08-21T16-02Z-assay.md
date: 2026-08-21
agent: harness-assayer
model: claude-opus-5
---

# Assay 2026-08-21T16-02Z

## Findings

### finding-3 — Unevidenced completion claims

Claude Code reported the integration suite passing on 2026-08-04 and again on
2026-08-12. The build log records the command being planned on both dates and
never records it running.

```yaml
classification: agent-instruction
enforcement: validated
surfaces: [claude-code, copilot]
target: .claude/agents/example.agent.md
priority: P1
evidence:
  - harness/build-log.md#2026-08-04T09-12Z
overfitting_risk: low
```

#### Proposed rule

````markdown
- **Rule**: A phase may not be reported complete on the strength of a planned  
  command. Cite observed output.

  Example of what does *not* count:

  ```bash
  npm test  # planned, never run
  ```
````

#### Cost estimate

One extra check per phase boundary; roughly two minutes.

### finding-5 — Context files capture narration

Phase context files grew to a size nobody reads. The growth is confined to one
unusually exploratory phase, and no rule asked for the narration that filled
them.

```yaml
classification: no-change
enforcement: advisory
surfaces: []
priority: P3
evidence:
  - harness/build-log.md#2026-08-19T11-00Z
```

#### Proposed rule

No change.

#### Cost estimate

None. Recording that nothing needed to change is itself evidence.

### finding-7 — Completion claims across every surface

The same unevidenced-completion pattern appears on Copilot CLI as well as
Claude Code, which suggests the behaviour belongs to the loop rather than to
one agent's instructions.

```yaml
classification: harness-loop
enforcement: validated
surfaces: [claude-code, ci]
priority: P0
evidence:
  - harness/build-log.md#2026-08-04T09-12Z
```

#### Proposed rule

````markdown
- **Rule**: Every agent reporting a phase boundary must cite observed output.
````

#### Cost estimate

A check at every phase boundary on every surface.

### finding-9 — Corroborated across two assays

The 2026-08-12 assay recorded the same failure class, so this is a second
independent observation rather than a repeat reading of the first.

```yaml
classification: harness-loop
enforcement: validated
surfaces: [claude-code, ci]
priority: P0
evidence:
  - harness/assay/2026-08-12T14-03Z-assay.md#finding-2
```

#### Proposed rule

````markdown
- **Rule**: Corroborated loop-level rule.
````

#### Cost estimate

A check at every phase boundary on every surface.

### finding-13 — Rule with no seen failure behind it

```yaml
classification: agent-instruction
enforcement: validated
surfaces: [claude-code]
priority: P2
evidence:
  - harness/build-log.md#2026-08-20T11-00Z
```

#### Proposed rule

````markdown
- **Rule**: A rule with no observed failure behind it.
````

#### Cost estimate

A cost estimate for a rule nobody saw a reason for.

### finding-11 — Malformed on purpose

This finding exists to be rejected: it carries an observation and metadata but
no proposed-rule section at all.

```yaml
classification: agent-instruction
enforcement: validated
surfaces: [claude-code]
priority: P2
evidence:
  - harness/build-log.md#2026-08-20T10-00Z
```

#### Cost estimate

Missing its proposed-rule section entirely.
EOF

printf -- '---\nassay: %s\ndate: 2026-08-12\nagent: harness-assayer\nmodel: claude-opus-5\n---\n\n## Findings\n' "$A0" > "$TMP/$A0"

# The exact rule text finding-3 proposes. R2 compares against this.
#
# Two things in it are deliberate. It contains a THREE-backtick fence, which is
# why the block delimiter is four backticks - a copier that mishandles nesting
# fails here. And the first line ends in TWO SPACES: a markdown hard line break,
# meaningful syntax that a well-meaning .rstrip() destroys silently. Without it
# the fixture was too clean to catch the exact failure R2 exists for.
cat > "$TMP/expected-rule.txt" <<'EOF'
- **Rule**: A phase may not be reported complete on the strength of a planned  
  command. Cite observed output.

  Example of what does *not* count:

  ```bash
  npm test  # planned, never run
  ```
EOF

field() {  # field <hdr-path> <key> — a frontmatter scalar, for assertions
  "$PY" -c "
import sys, re
text = open(sys.argv[1]).read()
fm = text.split('---', 2)[1]
for line in fm.splitlines():
    if line.startswith(sys.argv[2] + ':'):
        print(line.split(':', 1)[1].strip()); break
" "$1" "$2"
}

# === R1: propose writes a valid proposed HDR =================================
reg propose --assay "$A1" --finding finding-3 --today 2026-08-21
expect_ok "R1 (propose finding-3)"
HDR="$DEC/HDR-2026-08-21-unevidenced-completion-claims.md"
[ -f "$HDR" ] || fail "R1: expected HDR at $HDR. Out: $OUT"
HDR_REL="harness/decisions/$(basename "$HDR")"

# The S0 validator is the arbiter of "valid" - re-asserting its rules here would
# create a second opinion about what a well-formed HDR is.
set +e
VOUT="$( cd "$TMP" && "$PY" "$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py" 2>&1 )"
VRC=$?
set -e
[ "$VRC" -eq 0 ] || fail "R1: proposed HDR fails the S0 validator. Out: $VOUT"

[ "$(field "$HDR" status)" = "proposed" ] || fail "R1: status must be proposed"
[ "$(field "$HDR" classification)" = "agent-instruction" ] || fail "R1: classification not copied"
[ "$(field "$HDR" enforcement)" = "validated" ] || fail "R1: enforcement not copied"
# A finding that knows its target says so; propose copies it rather than leaving
# the human to rediscover it at the gate.
[ "$(field "$HDR" target)" = ".claude/agents/example.agent.md" ] \
  || fail "R1: target not copied from the finding metadata"
[ "$(field "$HDR" provisional)" = "true" ] || fail "R1: provisional must default true"
[ "$(field "$HDR" expires)" = "2026-11-19" ] \
  || fail "R1: expires must be today+90 (2026-11-19), got '$(field "$HDR" expires)'"

# === R2: the Rule block is byte-identical to the finding's ===================
"$PY" - "$HDR" "$TMP/expected-rule.txt" <<'PYEOF'
import sys
text = open(sys.argv[1]).read()
want = open(sys.argv[2]).read().rstrip("\n")
# Extract the four-backtick block from the ## Rule section.
lines, buf, blocks = text.splitlines(), None, []
for line in lines:
    if line.startswith("````") and (buf is None or line.strip() == "````"):
        if buf is None:
            buf = []
        else:
            blocks.append("\n".join(buf)); buf = None
        continue
    if buf is not None:
        buf.append(line)
assert len(blocks) == 1, f"R2: expected exactly one four-backtick block, got {len(blocks)}"
got = blocks[0].rstrip("\n")
assert got == want, (
    "R2: rule text is NOT byte-identical.\n"
    f"--- want ---\n{want!r}\n--- got ---\n{got!r}"
)
PYEOF
echo "R2 ok (rule text byte-identical, nested fence survived)"

# === R3: evidence = finding's evidence + the assay anchor, deduplicated ======
"$PY" - "$HDR" "$A1" <<'PYEOF'
import sys
text = open(sys.argv[1]).read()
fm = text.split("---", 2)[1]
ev, collecting = [], False
for line in fm.splitlines():
    if line.startswith("evidence:"):
        collecting = True; continue
    if collecting:
        if line.startswith("  - "):
            ev.append(line[4:].strip()); continue
        break
want = ["harness/build-log.md#2026-08-04T09-12Z", sys.argv[2] + "#finding-3"]
assert ev == want, f"R3: evidence is {ev}, expected {want}"
PYEOF
echo "R3 ok (assay anchor appended)"

# === R4: proposed_cost verbatim, cost empty ==================================
grep -q 'One extra check per phase boundary; roughly two minutes.' "$HDR" \
  || fail "R4: proposed_cost not copied verbatim"
[ "$(field "$HDR" cost)" = '""' ] \
  || fail "R4: cost must be empty at propose, got '$(field "$HDR" cost)'"

# === R5: propose refuses bad input, writing nothing ==========================
BEFORE="$(corpus_hash)"
reg propose --assay harness/assay/nope.md --finding finding-3 --today 2026-08-21
expect_fail "R5a (missing assay)" "not found"
reg propose --assay "$A1" --finding finding-99 --today 2026-08-21
expect_fail "R5b (unknown finding id)" "finding-99"
reg propose --assay "$A1" --finding finding-11 --today 2026-08-21
expect_fail "R5c (finding with no proposed rule)" "Proposed rule"
# A finding with no observation is a rule with a citation attached. The HDR it
# would produce has nothing to say about what actually went wrong, which is the
# whole reason a governance change is supposed to cite evidence.
#
# The finding is titled so its derived SLUG cannot contain the asserted phrase.
# The first version was called "No observation at all", and the assertion passed
# against a validator that had been mutated to remove the check - because the
# refused filename, HDR-...-no-observation-at-all.md, contained the word being
# grepped for. An assertion that can be satisfied by the fixture's own name is
# not an assertion.
reg propose --assay "$A1" --finding finding-13 --today 2026-08-21
expect_fail "R5d (finding with no observation prose)" "must say what was observed"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "R5: a refusal wrote to the corpus"

# === R6: propose never overwrites ============================================
reg propose --assay "$A1" --finding finding-3 --today 2026-08-21
expect_fail "R6 (would overwrite)" "already exists"
reg propose --assay "$A1" --finding finding-3 --today 2026-08-21 --slug second-take
expect_ok "R6 (--slug resolves the collision)"
rm -f "$DEC/HDR-2026-08-21-second-take.md"

# === R8: a no-change finding ================================================
reg propose --assay "$A1" --finding finding-5 --today 2026-08-21
expect_ok "R8 (propose no-change)"
NC="$DEC/HDR-2026-08-21-context-files-capture-narration.md"
[ -f "$NC" ] || fail "R8: expected $NC"
[ "$(field "$NC" provisional)" = "false" ] || fail "R8: no-change must be provisional: false"
grep -q '^expires:' "$NC" && fail "R8: no-change must carry no expires"
grep -q 'No change\.' "$NC" || fail "R8: no-change Rule section must say 'No change.'"

# === R9/R10: accept ==========================================================
printf 'Two minutes per boundary. Risk: reviewers paste output to satisfy it.\n' \
  > "$TMP/cost.txt"
printf '' > "$TMP/empty-cost.txt"
printf 'One extra check per phase boundary; roughly two minutes.\n' \
  > "$TMP/copied-cost.txt"

BEFORE="$(corpus_hash)"
reg accept --hdr "$HDR_REL" --cost-file empty-cost.txt --approver russ@russmiles.com --now 2026-08-21T16:41Z
expect_fail "R10a (empty cost)" "whoever works here next"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "R10a: refusal wrote to the corpus"

reg accept --hdr "$HDR_REL" --cost-file copied-cost.txt --approver russ@russmiles.com --now 2026-08-21T16:41Z
expect_fail "R10b (cost copied from proposed_cost)" "own words"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "R10b: refusal wrote to the corpus"

reg accept --hdr "$HDR_REL" --cost-file cost.txt --approver russ@russmiles.com --now 2026-08-21T16:41Z
expect_ok "R9 (accept)"
[ "$(field "$HDR" status)" = "accepted" ] || fail "R9: status must be accepted"
[ "$(field "$HDR" approver)" = "russ@russmiles.com" ] || fail "R9: approver not recorded"
[ "$(field "$HDR" approved_at)" = "2026-08-21T16:41Z" ] || fail "R9: approved_at not recorded"
grep -q 'Risk: reviewers paste output' "$HDR" || fail "R9: cost not written"

# The `## Cost` SECTION must be replaced wholesale, not merely have the
# frontmatter updated around it. An accepted record has to read as the
# approver's decision, not as the Assayer's proposal with an annotation.
"$PY" - "$HDR" <<'PYEOF'
import re, sys
body = open(sys.argv[1]).read().split("---", 2)[2]
m = re.search(r"(?ms)^## Cost\n(.*?)(?=^## |\Z)", body)
assert m, "R9: no ## Cost section after acceptance"
section = m.group(1)
assert "Risk: reviewers paste output" in section, \
    "R9: the ## Cost section does not carry the approver's words"
assert "Proposed by the Assayer" not in section, \
    "R9: the ## Cost section still carries the Assayer's proposal label"
assert "One extra check per phase boundary" not in section, \
    "R9: the ## Cost section still carries the Assayer's estimate"
PYEOF
echo "R9 ok (## Cost section replaced wholesale)"

# The `## Finding` section must carry the finding's observation prose.
grep -q 'The build log records the command being planned on both dates' "$HDR" \
  || fail "R1/R9: the ## Finding section is missing the observation prose"

# The Rule block must survive acceptance untouched - from here it is the
# byte-for-byte source S2's compiler applies.
"$PY" - "$HDR" "$TMP/expected-rule.txt" <<'PYEOF'
import sys
text = open(sys.argv[1]).read()
want = open(sys.argv[2]).read().rstrip("\n")
buf, blocks = None, []
for line in text.splitlines():
    if line.startswith("````") and (buf is None or line.strip() == "````"):
        if buf is None: buf = []
        else: blocks.append("\n".join(buf)); buf = None
        continue
    if buf is not None: buf.append(line)
assert len(blocks) == 1 and blocks[0].rstrip("\n") == want, \
    "R9: acceptance altered the Rule block"
PYEOF
echo "R9 ok (Rule block survived acceptance)"

# === R14: accept refuses an HDR that is not proposed =========================
BEFORE="$(corpus_hash)"
reg accept --hdr "$HDR_REL" --cost-file cost.txt --approver russ@russmiles.com --now 2026-08-21T16:41Z
expect_fail "R14 (already accepted)" "proposed"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "R14: refusal wrote to the corpus"

# === R7/R11: the loop-layer promotion threshold ==============================
reg propose --assay "$A1" --finding finding-7 --today 2026-08-21
expect_ok "R7 (propose tier-2 finding)"
L="$DEC/HDR-2026-08-21-completion-claims-across-every-surface.md"
[ -f "$L" ] || fail "R7: expected $L"
for section in "Why this layer" "Enforcement" "Validation" "Rejected alternatives"; do
  grep -q "^## $section" "$L" || fail "R7: missing placeholder section '$section'"
done

BEFORE="$(corpus_hash)"
reg accept --hdr "harness/decisions/$(basename "$L")" --cost-file cost.txt --approver russ@russmiles.com --now 2026-08-21T16:41Z
expect_fail "R7/R11 (tier-2 placeholders unfilled, single assay)" "Why this layer"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "R11: refusal wrote to the corpus"

# Fill the placeholders; the promotion threshold must still refuse, because one
# assay is one incident and a single incident cannot reach the loop layer.
"$PY" - "$L" <<'PYEOF'
import re, sys
p = sys.argv[1]
t = open(p).read()
for h in ("Why this layer", "Enforcement", "Validation", "Rejected alternatives"):
    t = re.sub(r"(?m)^(## " + re.escape(h) + r")\n\n_[^\n]*_\n",
               r"\1\n\nA real, human-written answer for this section.\n", t)
open(p, "w").write(t)
PYEOF
BEFORE="$(corpus_hash)"
reg accept --hdr "harness/decisions/$(basename "$L")" --cost-file cost.txt --approver russ@russmiles.com --now 2026-08-21T16:41Z
expect_fail "R11 (harness-loop citing one assay)" "two distinct assays"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "R11: refusal wrote to the corpus"

# A corroborated finding cites a prior assay in its own evidence, reaches two
# with the appended anchor, and passes.
reg propose --assay "$A1" --finding finding-9 --today 2026-08-21
expect_ok "R11 (propose corroborated loop finding)"
C="$DEC/HDR-2026-08-21-corroborated-across-two-assays.md"
"$PY" - "$C" <<'PYEOF'
import re, sys
p = sys.argv[1]
t = open(p).read()
for h in ("Why this layer", "Enforcement", "Validation", "Rejected alternatives"):
    t = re.sub(r"(?m)^(## " + re.escape(h) + r")\n\n_[^\n]*_\n",
               r"\1\n\nA real, human-written answer for this section.\n", t)
open(p, "w").write(t)
PYEOF
printf 'A different cost, in different words, for the corroborated rule.\n' > "$TMP/cost2.txt"
reg accept --hdr "harness/decisions/$(basename "$C")" --cost-file cost2.txt --approver russ@russmiles.com --now 2026-08-21T17:00Z
expect_ok "R11 (two distinct assays passes)"

# === R16: precheck reports refusals without any cost being supplied ==========
reg propose --assay "$A1" --finding finding-3 --today 2026-08-21 --slug third-take
expect_ok "R16 (propose for precheck)"
reg precheck --hdr harness/decisions/HDR-2026-08-21-third-take.md
expect_ok "R16 (precheck on a clean HDR)"
reg precheck --hdr "harness/decisions/$(basename "$L")"
expect_fail "R16 (precheck surfaces the loop-layer refusal)" "two distinct assays"

# === R12: the cycle cap ======================================================
# Two accepted from this assay already. Take it to three, then four.
printf 'Cost number three, written in its own words by a person.\n' > "$TMP/cost3.txt"
printf 'Cost number four, written in its own words by a person.\n' > "$TMP/cost4.txt"
reg accept --hdr harness/decisions/HDR-2026-08-21-third-take.md --cost-file cost3.txt --approver russ@russmiles.com --now 2026-08-21T17:10Z
expect_ok "R12 (third accepted HDR from one assay)"

reg propose --assay "$A1" --finding finding-3 --today 2026-08-21 --slug fourth-take
expect_ok "R12 (propose a fourth)"
BEFORE="$(corpus_hash)"
reg accept --hdr harness/decisions/HDR-2026-08-21-fourth-take.md --cost-file cost4.txt --approver russ@russmiles.com --now 2026-08-21T17:20Z
expect_fail "R12 (fourth accepted HDR from one assay)" "three"
[ "$(corpus_hash)" = "$BEFORE" ] || fail "R12: refusal wrote to the corpus"

# === R15: the index is a pure function of the corpus =========================
reg index
expect_ok "R15 (index)"
IDX="$DEC/index.md"
[ -f "$IDX" ] || fail "R15: expected $IDX"
grep -q 'BEGIN GENERATED: harness-registrar' "$IDX" || fail "R15: missing generated marker"
cp "$IDX" "$TMP/idx-1.md"
reg index
expect_ok "R15 (index re-run)"
cmp -s "$TMP/idx-1.md" "$IDX" || fail "R15: index is not byte-identical on re-run"

# Every HDR appears, and the rows are ordered by id.
"$PY" - "$IDX" "$DEC" <<'PYEOF'
import os, re, sys
idx, dec = open(sys.argv[1]).read(), sys.argv[2]
ids = sorted(n[:-3] for n in os.listdir(dec)
             if n.startswith("HDR-") and n.endswith(".md"))
for hid in ids:
    assert hid in idx, f"R15: {hid} missing from the index"
rows = [m.group(1) for m in re.finditer(r"^\| (HDR-[^ |]+)", idx, re.M)]
assert rows == sorted(rows), f"R15: index rows are not sorted by id: {rows}"
assert rows == ids, f"R15: index rows {rows} != corpus {ids}"
PYEOF
echo "R15 ok (index complete, sorted, idempotent)"

# === R13: the corpus still validates after everything ========================
set +e
VOUT="$( cd "$TMP" && "$PY" "$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py" 2>&1 )"
VRC=$?
set -e
[ "$VRC" -eq 0 ] || fail "R13: corpus does not validate at the end. Out: $VOUT"

echo "harness registrar: all checks passed (R1-R16)"
