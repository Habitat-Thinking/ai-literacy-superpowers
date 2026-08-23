#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the Harness Decision Record validator
# (spec 2026-08-23-harness-evolution-s0-schema-validator-design.md, §8; V1-V19).
#
# WHY THIS TEST IS THE PHASE. The epic resolved the Registrar to be a plugin
# agent with Write/Edit, which puts a model in the governance write path. The
# compensating control is that every refusal lives in deterministic code that CI
# also runs — so a rule the agent might talk itself past turns the build red
# instead. This file is what makes that claim checkable.
#
# TWO RULES HERE CANNOT BE CHECKED FROM ONE FILE. The promotion threshold (V12)
# and the cycle cap (V13) are corpus-level: they compare HDRs against each other.
# That is the second reason they live in the validator rather than in the
# accepting command — CI re-checks the whole corpus, so a threshold cannot be
# evaded by a merge that combines two individually-valid branches.
#
# V17 IS THE ONE THAT MUST PASS. A rule intending `blocked` on a surface that can
# only advise is an enforcement GAP, not an error. Failing the build over it
# would train authors to declare the weakest enforcement any surface supports,
# which discards exactly the information the Phase 2 gap report exists to carry.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/../.."
CHECK="$ROOT/ai-literacy-superpowers/scripts/check-harness-decisions.py"

fail() { echo "FAIL: $*" >&2; exit 1; }
[ -f "$CHECK" ] || fail "harness decision validator not found at $CHECK"

PY=/usr/bin/python3
command -v "$PY" >/dev/null 2>&1 || PY=python3

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
HARNESS="$TMP/harness"
DEC="$HARNESS/decisions"
# Deliberately NOT created yet - V1 must run against a genuinely absent
# harness/ directory, and an empty one is a different (and weaker) test.

run() {
  set +e
  OUT="$( cd "$TMP" && "$PY" "$CHECK" 2>&1 )"
  RC=$?
  set -e
}

reset() { rm -f "$DEC"/*.md; }

# The valid capability matrix every test but V18 runs against.
write_surfaces() {
  cat > "$HARNESS/surfaces.yaml" <<'EOF'
surfaces:
  claude-code:
    targets: [CLAUDE.md, .claude/agents/]
    supports: [advisory, validated, blocked]
  copilot-cli:
    targets: [.github/copilot-instructions.md]
    supports: [advisory]
  ci:
    targets: [.github/workflows/harness-check.yml]
    supports: [validated, blocked]
EOF
}

# --- Body generators ---------------------------------------------------------
# The Rule block is delimited by FOUR backticks, not three, because rule text is
# markdown and routinely contains a three-backtick fence of its own. A
# three-backtick delimiter terminates on the first nested fence and silently
# truncates the rule (spec §4.6).

body_tier1() {
  cat <<'EOF'
## Finding

Claude Code twice reported the integration suite passed when it had only been
planned. Evidence: the build log records the plan, never the run.

## Rule

````markdown
- **Rule**: A phase may not be reported complete on the strength of a planned
  command. Cite observed output.
````

## Cost

One extra check per phase boundary; roughly two minutes.
EOF
}

body_tier2() {
  body_tier1
  cat <<'EOF'

## Why this layer

The behaviour is not specific to one agent; every agent that reports a phase
boundary can make the claim.

## Enforcement

`validated` on Claude Code via the harness-enforcer; `advisory` on Copilot CLI,
which supports nothing stronger.

## Validation

The next two assays should show zero unevidenced completion claims on Claude
Code. A recurrence on Copilot CLI would confirm the gap rather than refute the
rule.

## Rejected alternatives

No change — rejected because the failure recurred across two phases. Tightening
the existing spec-captures-intent constraint — rejected because that constraint
governs specs, not completion claims.
EOF
}

body_nochange() {
  cat <<'EOF'
## Finding

Context files grew large during one unusually exploratory phase. No rule was
missing; the phase was atypical.

## Rule

No change.

## Cost

None. Recording that nothing needed to change is itself evidence.
EOF
}

body_missing_cost_section() {
  cat <<'EOF'
## Finding

A finding.

## Rule

````markdown
- **Rule**: Something.
````
EOF
}

body_empty_finding() {
  cat <<'EOF'
## Finding

## Rule

````markdown
- **Rule**: Something.
````

## Cost

Two minutes.
EOF
}

body_no_fence() {
  cat <<'EOF'
## Finding

A finding.

## Rule

A phase may not be reported complete on the strength of a planned command.

## Cost

Two minutes.
EOF
}

body_two_fences() {
  cat <<'EOF'
## Finding

A finding.

## Rule

````markdown
- **Rule**: One.
````

````markdown
- **Rule**: Two.
````

## Cost

Two minutes.
EOF
}

# --- HDR generator -----------------------------------------------------------

defaults() {
  FNAME=HDR-2026-08-21-observed-evidence.md
  ID=HDR-2026-08-21-observed-evidence
  TITLE="Require observed evidence for completion claims"
  STATUS=proposed
  CLASSIFICATION=agent-instruction
  ENFORCEMENT=validated
  SURFACES="[claude-code]"
  PROVISIONAL=true
  EXPIRES="expires: 2026-11-19"
  IMPORTED=""
  EVIDENCE="  - harness/assay/2026-08-21T16-02Z-assay.md#finding-3"
  PROPOSED_COST="One extra check per phase boundary."
  COST=""
  PROPOSER_AGENT=harness-assayer
  ASSAY="harness/assay/2026-08-21T16-02Z-assay.md"
  APPROVAL=""
  BODY=body_tier1
  OMIT=""
}

accepted() {
  STATUS=accepted
  COST="Two minutes per boundary. Risk: reviewers paste output to satisfy it."
  APPROVAL=$'approver: russ@russmiles.com\napproved_at: 2026-08-21T16:41Z'
}

gen() {
  {
    printf -- '---\n'
    [ "$OMIT" = id ] || printf 'id: %s\n' "$ID"
    [ "$OMIT" = title ] || printf 'title: %s\n' "$TITLE"
    [ "$OMIT" = status ] || printf 'status: %s\n' "$STATUS"
    [ "$OMIT" = classification ] || printf 'classification: %s\n' "$CLASSIFICATION"
    [ "$OMIT" = enforcement ] || printf 'enforcement: %s\n' "$ENFORCEMENT"
    [ "$OMIT" = surfaces ] || printf 'surfaces: %s\n' "$SURFACES"
    [ "$OMIT" = provisional ] || printf 'provisional: %s\n' "$PROVISIONAL"
    if [ -n "$EXPIRES" ]; then printf '%s\n' "$EXPIRES"; fi
    if [ -n "$IMPORTED" ]; then printf '%s\n' "$IMPORTED"; fi
    if [ "$OMIT" != evidence ]; then
      printf 'evidence:\n'
      printf '%s\n' "$EVIDENCE"
    fi
    if [ -n "$PROPOSED_COST" ]; then
      printf 'proposed_cost: |\n  %s\n' "$PROPOSED_COST"
    fi
    if [ -n "$COST" ]; then
      printf 'cost: |\n  %s\n' "$COST"
    else
      printf 'cost: ""\n'
    fi
    if [ "$OMIT" != proposer ]; then
      printf 'proposer:\n  agent: %s\n  model: claude-opus-5\n  assay: %s\n' \
        "$PROPOSER_AGENT" "$ASSAY"
    fi
    if [ -n "$APPROVAL" ]; then printf '%s\n' "$APPROVAL"; fi
    printf 'supersedes: null\nsuperseded_by: null\n'
    printf -- '---\n\n'
    "$BODY"
  } > "$DEC/$FNAME"
}

# Assert the run failed AND the message names the thing the author must fix.
# A generic parse error that happens to exit non-zero is not a passing test:
# the point of the validator is telling someone what to change.
expect_fail() {  # expect_fail <label> <substring>
  [ "$RC" -ne 0 ] || fail "$1: expected non-zero exit, got 0. Out: $OUT"
  # A crash is not a refusal. Without this, a validator that raised
  # AttributeError on `surfaces.items()` "passed" V18a, because the traceback
  # happens to contain the word the assertion greps for. Non-zero exit plus a
  # matching substring is not evidence of a considered rejection.
  printf '%s' "$OUT" | grep -q 'Traceback' \
    && fail "$1: validator crashed instead of refusing. Out: $OUT"
  printf '%s' "$OUT" | grep -qi -- "$2" \
    || fail "$1: message must mention '$2'. Out: $OUT"
}

expect_pass() {  # expect_pass <label>
  [ "$RC" -eq 0 ] || fail "$1: expected exit 0, got $RC. Out: $OUT"
}

# === V1: a repository with no harness/ directory passes =======================
# Adopting this mechanism stays a choice. A project that has never run
# /harness-assay has not made a mistake a merge gate should punish.
run
expect_pass "V1 (no harness/ dir)"

mkdir -p "$DEC"
write_surfaces

# === V2: a well-formed minimal HDR passes ====================================
defaults; gen; run
expect_pass "V2 (minimal valid proposed HDR)"

# === V3: filename / id mismatch fails, naming both ===========================
reset; defaults; ID=HDR-2026-08-21-something-else; gen; run
expect_fail "V3 (id/filename mismatch)" "observed-evidence"

# === V4: bad slug and impossible date ========================================
reset; defaults; FNAME=HDR-2026-08-21-Observed_Evidence.md
ID=HDR-2026-08-21-Observed_Evidence; gen; run
expect_fail "V4a (bad slug)" "slug"

reset; defaults; FNAME=HDR-2026-02-31-observed-evidence.md
ID=HDR-2026-02-31-observed-evidence; gen; run
expect_fail "V4b (impossible date)" "date"

# === V5: each always-required field, missing, names itself ===================
for field in id title status classification enforcement surfaces provisional evidence proposer; do
  reset; defaults; OMIT="$field"; gen; run
  expect_fail "V5 (missing $field)" "$field"
done

# === V6: unknown enum values fail loudly =====================================
# A typo must never be a silent exemption - the sentinel-integrity-check.sh
# precedent, which fails on `role: sentinal` rather than skipping the file.
reset; defaults; STATUS=acepted; gen; run
expect_fail "V6a (unknown status)" "status"

reset; defaults; CLASSIFICATION=harness-lop; gen; run
expect_fail "V6b (unknown classification)" "classification"

reset; defaults; ENFORCEMENT=blocking; gen; run
expect_fail "V6c (unknown enforcement)" "enforcement"

# === V7: tier-2 classification missing an extra section ======================
for missing in "Why this layer" "Enforcement" "Validation" "Rejected alternatives"; do
  reset; defaults
  CLASSIFICATION=harness-loop
  EVIDENCE=$'  - harness/assay/2026-08-04T09-12Z-assay.md#finding-1\n  - harness/assay/2026-08-21T16-02Z-assay.md#finding-3'
  BODY=body_tier2
  gen
  # Drop exactly one required tier-2 section from the generated file.
  "$PY" - "$DEC/$FNAME" "$missing" <<'PYEOF'
import re, sys
path, heading = sys.argv[1], sys.argv[2]
text = open(path).read()
text = re.sub(r"\n## " + re.escape(heading) + r"\n.*?(?=\n## |\Z)", "\n", text, flags=re.S)
open(path, "w").write(text)
PYEOF
  run
  expect_fail "V7 (tier-2 missing '$missing')" "$missing"
done

# A tier-2 HDR with all four extra sections passes.
reset; defaults
CLASSIFICATION=harness-loop
EVIDENCE=$'  - harness/assay/2026-08-04T09-12Z-assay.md#finding-1\n  - harness/assay/2026-08-21T16-02Z-assay.md#finding-3'
BODY=body_tier2; gen; run
expect_pass "V7 (complete tier-2)"

# A tier-1 classification does NOT require the tier-2 sections.
reset; defaults; BODY=body_tier1; gen; run
expect_pass "V7 (tier-1 needs no extra sections)"

# === V8: an empty required section fails =====================================
# A heading with nothing under it is a missing section that looks present,
# which is worse than an absent one.
reset; defaults; BODY=body_empty_finding; gen; run
expect_fail "V8 (empty Finding section)" "Finding"

reset; defaults; BODY=body_missing_cost_section; gen; run
expect_fail "V8 (missing Cost section)" "Cost"

# === V9: the four-backtick Rule block ========================================
reset; defaults; BODY=body_no_fence; gen; run
expect_fail "V9a (Rule with no fenced block)" "Rule"

reset; defaults; BODY=body_two_fences; gen; run
expect_fail "V9b (Rule with two fenced blocks)" "Rule"

# === V10: the cost rule ======================================================
# The single most important anti-theatre requirement in the design, and the one
# the source spec left unimplementable: it required refusing a cost
# "byte-identical to the Assayer's proposal" without saying where that proposal
# was stored. `proposed_cost` is where.
reset; defaults; accepted; COST=""; gen; run
expect_fail "V10a (accepted with empty cost)" "cost"

reset; defaults; accepted
PROPOSED_COST="One extra check per phase boundary."
COST="One extra check per phase boundary."
gen; run
expect_fail "V10b (cost identical to proposed_cost)" "cost"

# A PROPOSED HDR with an empty cost is the correct state, not a malformed one.
# The human authors the cost at the gate; requiring it earlier would force
# /harness-propose to fabricate one, which is the laundering the rule prevents.
reset; defaults; COST=""; gen; run
expect_pass "V10c (proposed with empty cost)"

# === V11: the expiry rule ====================================================
reset; defaults; PROVISIONAL=true; EXPIRES=""; gen; run
expect_fail "V11a (provisional with neither expires nor review_trigger)" "expires"

reset; defaults; PROVISIONAL=true
EXPIRES='review_trigger: "Two consecutive assays with zero findings in this class"'
gen; run
expect_pass "V11b (review_trigger substitutes for expires)"

reset; defaults; PROVISIONAL=true; EXPIRES="expires: not-a-date"; gen; run
expect_fail "V11c (malformed expires)" "expires"

# === V12: the promotion threshold ============================================
# A single incident cannot reach the loop layer.
reset; defaults; accepted
CLASSIFICATION=harness-loop; BODY=body_tier2
EVIDENCE="  - harness/assay/2026-08-21T16-02Z-assay.md#finding-3"
gen; run
expect_fail "V12a (accepted harness-loop citing one assay)" "two"

# Two anchors into the SAME assay are one assay. Distinctness is by file.
reset; defaults; accepted
CLASSIFICATION=harness-loop; BODY=body_tier2
EVIDENCE=$'  - harness/assay/2026-08-21T16-02Z-assay.md#finding-3\n  - harness/assay/2026-08-21T16-02Z-assay.md#finding-5'
gen; run
expect_fail "V12b (two anchors into one assay)" "two"

reset; defaults; accepted
CLASSIFICATION=harness-loop; BODY=body_tier2
EVIDENCE=$'  - harness/assay/2026-08-04T09-12Z-assay.md#finding-1\n  - harness/assay/2026-08-21T16-02Z-assay.md#finding-3'
gen; run
expect_pass "V12c (two distinct assays)"

# A PROPOSED harness-loop HDR citing one assay is fine - the threshold binds at
# acceptance, so the proposal can sit and wait for corroboration.
reset; defaults
CLASSIFICATION=harness-loop; BODY=body_tier2
EVIDENCE="  - harness/assay/2026-08-21T16-02Z-assay.md#finding-3"
gen; run
expect_pass "V12d (proposed harness-loop, single assay)"

# === V13: the cycle cap ======================================================
reset
for n in 1 2 3; do
  defaults; accepted
  FNAME="HDR-2026-08-21-rule-$n.md"; ID="HDR-2026-08-21-rule-$n"
  gen
done
run
expect_pass "V13a (three accepted HDRs from one assay)"

defaults; accepted
FNAME="HDR-2026-08-21-rule-4.md"; ID="HDR-2026-08-21-rule-4"
gen; run
expect_fail "V13b (fourth accepted HDR from one assay)" "three"

# A fourth left PROPOSED carries forward rather than failing the build.
rm -f "$DEC/HDR-2026-08-21-rule-4.md"
defaults
FNAME="HDR-2026-08-21-rule-4.md"; ID="HDR-2026-08-21-rule-4"
gen; run
expect_pass "V13c (fourth left proposed carries forward)"

# === V14: grandfathering =====================================================
# Importing legacy rules as provisional would manufacture an expiry cliff on
# roughly day 90 of adoption, teaching people to ignore a red check.
reset; defaults; accepted
IMPORTED="imported: true"; PROVISIONAL=false; EXPIRES=""
PROPOSER_AGENT=imported
EVIDENCE="  - HARNESS.md#shell-scripts-use-strict-mode"
gen; run
expect_pass "V14a (imported, no expiry)"

# Isolated deliberately: a review_trigger rather than an expiry, so the ONLY
# rule that can fire is the contradiction itself. With `expires` set, the
# "imported must not carry expires" rule fires too and also says "imported" -
# and the test would then pass with the contradiction check deleted.
reset; defaults; accepted
IMPORTED="imported: true"; PROVISIONAL=true
EXPIRES='review_trigger: "Reviewed at the next governance audit"'
PROPOSER_AGENT=imported
EVIDENCE="  - HARNESS.md#shell-scripts-use-strict-mode"
gen; run
expect_fail "V14b (imported AND provisional is a contradiction)" "contradiction"

# An imported HDR carrying an expiry is the grandfathering rule's other half.
reset; defaults; accepted
IMPORTED="imported: true"; PROVISIONAL=false; EXPIRES="expires: 2026-11-19"
PROPOSER_AGENT=imported
EVIDENCE="  - HARNESS.md#shell-scripts-use-strict-mode"
gen; run
expect_fail "V14d (imported must not carry expires)" "must not carry"

# An imported HDR must name `imported` as its proposer - an imported rule has no
# Assayer behind it, and saying otherwise invents provenance.
reset; defaults; accepted
IMPORTED="imported: true"; PROVISIONAL=false; EXPIRES=""
PROPOSER_AGENT=harness-assayer
EVIDENCE="  - HARNESS.md#shell-scripts-use-strict-mode"
gen; run
expect_fail "V14e (imported must declare proposer.agent: imported)" "proposer.agent"

# An imported harness-loop rule is exempt from the two-assay threshold - there
# were no assays before the mechanism existed.
reset; defaults; accepted
CLASSIFICATION=harness-loop; BODY=body_tier2
IMPORTED="imported: true"; PROVISIONAL=false; EXPIRES=""
PROPOSER_AGENT=imported
EVIDENCE="  - HARNESS.md#spec-first-commit-ordering"
gen; run
expect_pass "V14c (imported harness-loop exempt from threshold)"

# === V15: accepted requires approver and approved_at =========================
reset; defaults; accepted; APPROVAL="approved_at: 2026-08-21T16:41Z"; gen; run
expect_fail "V15a (accepted without approver)" "approver"

reset; defaults; accepted; APPROVAL="approver: russ@russmiles.com"; gen; run
expect_fail "V15b (accepted without approved_at)" "approved_at"

# === V16: an HDR naming an undeclared surface fails ==========================
reset; defaults; SURFACES="[claude-code, windsurf]"; gen; run
expect_fail "V16 (undeclared surface)" "windsurf"

# === V17: an enforcement gap PASSES ==========================================
# copilot-cli supports advisory only. A rule intending `blocked` there is a true
# and useful fact about the world, reported by the Phase 2 gap report. Failing
# here would push authors to declare the weakest enforcement any surface
# supports, destroying the information the report exists to carry.
reset; defaults; ENFORCEMENT=blocked; SURFACES="[copilot-cli]"; gen; run
expect_pass "V17 (enforcement gap is not a validation error)"

# === V18: malformed surfaces.yaml ============================================
reset; defaults; gen

bad_surfaces() { cat > "$HARNESS/surfaces.yaml"; }

bad_surfaces <<'EOF'
claude-code:
  targets: [CLAUDE.md]
  supports: [advisory]
EOF
run; expect_fail "V18a (no top-level surfaces key)" "surfaces"

bad_surfaces <<'EOF'
surfaces:
  claude-code:
    targets: []
    supports: [advisory]
EOF
run; expect_fail "V18b (empty targets)" "targets"

bad_surfaces <<'EOF'
surfaces:
  claude-code:
    targets: [CLAUDE.md]
    supports: []
EOF
run; expect_fail "V18c (empty supports)" "supports"

bad_surfaces <<'EOF'
surfaces:
  claude-code:
    targets: [CLAUDE.md]
    supports: [advisory, blocking]
EOF
run; expect_fail "V18d (unknown supports value)" "blocking"

bad_surfaces <<'EOF'
surfaces:
  claude-code:
    targets: [CLAUDE.md]
    supports: [advisory, advisory]
EOF
run; expect_fail "V18e (duplicate supports value)" "duplicate"

bad_surfaces <<'EOF'
surfaces:
  Claude_Code:
    targets: [CLAUDE.md]
    supports: [advisory]
EOF
run; expect_fail "V18f (bad surface key)" "Claude_Code"

# V18g: a malformed matrix with ZERO HDRs still fails. This is day one of
# adoption - surfaces.yaml is authored before any decision exists - so a
# validator that only looks at the matrix when HDRs are present would be blind
# during the exact window when the matrix is being written.
reset
bad_surfaces <<'EOF'
surfaces:
  claude-code:
    targets: [CLAUDE.md]
    supports: [advisory, blocking]
EOF
run; expect_fail "V18g (malformed matrix, no HDRs yet)" "blocking"

write_surfaces
run; expect_pass "V18h (valid matrix, no HDRs yet)"

# V18i: a README.md in the decisions directory is documentation, not an HDR.
# The corpus needs a file explaining what it is, and treating that file as a
# malformed decision would make the directory impossible to document.
reset; defaults; gen
printf '# Harness Decision Records\n\nOne file per governance change.\n' \
  > "$DEC/README.md"
run; expect_pass "V18i (README.md in decisions/ is not an HDR)"
rm -f "$DEC/README.md"

# === V19: no-change is a first-class outcome =================================
# An assay in which every finding resolves to no-change is a SUCCESSFUL assay.
reset; defaults
CLASSIFICATION=no-change
ENFORCEMENT=advisory
SURFACES="[]"
PROVISIONAL=false
EXPIRES=""
BODY=body_nochange
gen; run
expect_pass "V19a (no-change HDR)"

# no-change with a non-advisory enforcement is incoherent: nothing is enforced.
reset; defaults
CLASSIFICATION=no-change; ENFORCEMENT=blocked; SURFACES="[]"
PROVISIONAL=false; EXPIRES=""; BODY=body_nochange
gen; run
expect_fail "V19b (no-change must be advisory)" "no-change"

# A no-change HDR whose Rule section says anything OTHER than "No change." is
# the failure worth catching: it reads as a rule to every downstream consumer
# while being classified as no rule at all.
reset; defaults
CLASSIFICATION=no-change; ENFORCEMENT=advisory; SURFACES="[]"
PROVISIONAL=false; EXPIRES=""; BODY=body_no_fence
gen; run
expect_fail "V19c (no-change Rule section must say 'No change.')" "No change"

echo "harness decision validator: all checks passed (V1-V19)"
