---
spec: docs/superpowers/specs/2026-06-11-cost-estimator-agent-design.md
date: 2026-06-11
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: specification quality
    severity: medium
    claim: "The honest-placeholder generated_by value `tier:Standard` is not a `model identifier`, which is exactly what the S1 field is documented to carry and what both S1 worked examples show — so the day-one-default record writes a value the format describes as something it is not, even though no machine check rejects it."
    evidence: "estimate-record-format.md:27 defines `generated_by` as 'Agent name + model identifier (e.g. \"cost-estimator / claude-opus-4-8\")'; both worked examples (lines 264, 330) carry a concrete model id. The validation checklist (lines 216-253) has NO check on `generated_by` shape, so `cost-estimator / tier:Standard` passes validation while contradicting the field's documented meaning."
    disposition: accepted
    disposition_rationale: >
      Accepted. Flag the `generated_by` "model identifier" field wording to the
      #377 format-revision slice as a spec↔contract tension (same class as the
      cost-snapshot-path flag). S2 keeps the honest `tier:Standard` placeholder
      as the least-bad option without touching the merged S1 reference; #377
      decides whether the field's documented meaning should widen to admit it.
  - id: O2
    category: specification quality
    severity: medium
    claim: "The mechanical cost-omission rule keys on whether 'every exercised stage's tier is mapped by the binding table', but the binding table's mapping is mediated by a non-trivial normalisation join key (prefix-strip + whitespace-insensitive tier compare) defined in S1; the spec never says the mechanical 'unmapped' test must apply that same normalisation, leaving room for a false-unmapped omission on a `Standard / Capable` vs `Standard/Capable` spacing mismatch."
    evidence: "§6.2/FR-10 states the agent 'omits cost_usd whenever ANY exercised stage's tier is unmapped by the binding table' but never references the S1 join-key normalisation. estimate-record-format.md:153-158 defines that a stage maps to a binding row only after 'stripping the {{LANGUAGE}}- prefix' and comparing tier labels 'whitespace-insensitively — so Standard/Capable ↔ Standard / Capable'. A mechanical test that does a literal string match would falsely report a mapped split tier as unmapped and over-omit cost."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. State that the mechanical mapped/unmapped test applies
      the S1 join-key normalisation (strip the {{LANGUAGE}}- prefix; compare tier
      labels whitespace-insensitively) before deciding a tier is unmapped, so a
      Standard/Capable vs Standard / Capable spacing mismatch cannot over-omit
      cost on the dominant (implementer) stage.
  - id: O3
    category: risk
    severity: low
    claim: "The deterministic conformance oracle (O9 fix) asserts the emitted frontmatter conforms to 'the S1 estimate-record field set', but the S1 field set includes `human_gate_time` as a 'qualitative caveat string, NOT a range' whose only constraint is prose — a property no structural parse can falsify, so one named S1 field is asserted by an oracle that cannot actually grade it."
    evidence: "§8 conformance oracle: 'assert it conforms to the S1 estimate-record field set (required fields present, enum values in range, every present range has low ≤ high)'. estimate-record-format.md:34 makes `human_gate_time` 'a qualitative caveat string, NOT a numeric range'; its correctness ('dominated by human availability', non-numeric) is a semantic prose property. The presence/absence and low≤high oracles cannot distinguish a faithful caveat string from an arbitrary one, so the field is nominally 'graded' but actually un-gradeable by the named oracles."
    disposition: accepted
    disposition_rationale: >
      Accepted — fix now. Reword §8 so human_gate_time's prose content is listed
      as out of deterministic-grading scope (alongside exact token numbers and
      prose wording); the conformance oracle asserts presence + not-a-range for
      it, not content correctness — no over-claim.
---

## O1 — specification quality — medium

### Claim

The round-1 O3 fix introduces a two-branch `generated_by` convention: branch (a)
records a dispatcher-supplied resolved model id; branch (b) — the default, since
`model: inherit` does not surface the resolved id — records the routing-tier
label `cost-estimator / tier:Standard`. The revision is honest in intent (it
refuses to fabricate a concrete model), and it is the correct fix for the
fabrication risk round-1 O3 named. But the value it writes in the common case is
not a *model identifier*, which is precisely what the S1 field is documented to
hold. The fix trades a fabrication risk for a faithfulness-to-format gap: the
day-one-default record now carries a `generated_by` value that the S1 reference's
own field description does not describe.

### Evidence

estimate-record-format.md:27 defines the field as "Agent name + model identifier
(e.g. `\"cost-estimator / claude-opus-4-8\"`)." Both S1 worked examples carry a
concrete model id (`cost-estimator / claude-opus-4-8`, lines 264 and 330). The S2
spec's own §9.2 acceptance scenario asserts the default record emits
`generated_by` is `"cost-estimator / tier:Standard"`. Crucially, the S1
validation checklist (estimate-record-format.md:216-253) contains **no** check on
the shape or content of `generated_by` — so `tier:Standard` passes every machine
check the format defines. The gap is therefore not a validation failure; it is a
divergence between what the field is documented to mean and what the agent writes
into it on most runs.

### Why this matters

This is genuinely the least-bad option available to S2 without touching the S1
reference (which §2.3 forbids), and the `tier:` prefix is an honest marker. So
the objection is medium, not high: nothing breaks, and the value is honest. But
the revision has quietly made the *most common* record the agent emits carry a
`generated_by` that the format's worked examples and field description would not
recognise as a model identifier. Two consequences worth a conscious human call:
(1) a future reader or downstream consumer that parses `generated_by` expecting a
model id (the documented contract) gets a tier label instead, with no validation
signal that anything is off; (2) this is arguably the same class of
spec↔contract tension the revision deferred to #377 for the `cost-snapshot` path
(§5.3 conflict flag) — the honest thing may be to flag the `generated_by`
"model identifier" wording to #377 as well, rather than let S2 silently widen the
field's accepted contents by convention. The spec should say whether the
tier-label convention is a tension to flag for the format owner, or an accepted
permanent reading of the field.

## O2 — specification quality — medium

### Claim

The round-1 O4 fix makes the cost-omission rule mechanical — "omit `cost_usd`
whenever ANY exercised stage's tier is unmapped by the binding table" — to strip
out the discretionary "load-bearing" judgment. This correctly removes the
emit-vs-decide drift round-1 O4 named. But "unmapped by the binding table" is not
itself a primitive: S1 defines a non-trivial **normalisation join key** that must
be applied before a stage's tier can be tested against the binding table, and the
S2 spec's mechanical rule never references it. A literal-string mechanical test
would mis-classify a correctly-mapped split tier as unmapped and over-omit cost —
the very over-omission the brief asked to be checked for, arriving through the
join-key, not through the empty-snapshot path.

### Evidence

§6.2 / FR-10: "The agent omits `cost_usd` … whenever ANY exercised stage's tier
is unmapped by the binding table — or otherwise ungrounded." The spec describes
the test as a "yes/no check, not a judgment about salience" but never specifies
*how* a stage tier is matched against the table. S1 defines the match as
non-literal: estimate-record-format.md:153-158, "Stage/tier normalisation (the
join key) … by stripping the `{{LANGUAGE}}-` prefix … Tier labels are compared
**whitespace-insensitively** — so `Standard/Capable` ↔ `Standard / Capable`."
S1's own binding table row is written `Standard / Capable (split)` (line 146)
while `tokens_by_stage[].model_tier` records the literal `Standard/Capable`
(lines 30, 169) — the two differ by spacing precisely the case the join key
exists to reconcile. A mechanical rule that does not invoke this normalisation
would report the implementer's split tier (the largest-budget stage, line 161) as
unmapped on a spacing mismatch and omit cost on a record that is in fact fully
grounded.

### Why this matters

The mechanical rule was introduced to make the agent honest, but a mechanical
rule that omits cost on a *false* unmapped reading is a new false-omission risk —
the inverse of the false-precision risk it was meant to fix, and it bites
hardest on the implementer split tier that S1 says "dominates any cost figure"
(line 161-162). Because the implementer stage is on the split tier in *both* S1
worked examples, this is not a corner case — it is the normal cost-present
record. The fix is one clause: state that the mechanical mapped/unmapped test
applies the S1 join-key normalisation (prefix-strip + whitespace-insensitive tier
compare) before deciding a tier is unmapped. Without it, two implementers will
build two different "mechanical" tests and one of them silently over-omits cost
on the most common cost-present shape.

## O3 — risk — low

### Claim

The round-1 O9 fix defines a deterministic oracle suite (conformance parse,
presence/absence, `REFUSED:` prefix, fixture-pinned grounding) so the behavioural
TDAD layer can fail honestly against a `model: inherit` agent. The strategy is
sound and genuinely resolves the "guarantee in name only" risk for the
quantitative ranges, the refusal routing, and the no-verdict field-absence
check. But the conformance oracle claims to assert the emitted record "conforms
to the S1 estimate-record field set", and the S1 field set includes one required
field — `human_gate_time` — whose entire constraint is a semantic prose property
no structural parse can falsify. That one field is nominally covered by an oracle
that cannot actually grade it.

### Evidence

§8 conformance oracle: "Parse the returned string's YAML frontmatter and assert
it conforms to the S1 estimate-record field set (required fields present, enum
values in range, every present range has `low ≤ high`)." The S1 reference makes
`human_gate_time` a **required** field that is explicitly "a qualitative caveat
string, NOT a numeric range" carrying "a short prose statement to that effect"
(estimate-record-format.md:34, 69-74). Its correctness is whether the string
faithfully states that human-gate latency dominates and is not numerically
estimated — a semantic judgment. The three named oracles can confirm the field is
*present* and is *not* a `{low, high}` range, but cannot confirm the string says
what the field requires. §8 acknowledges "exact prose wording" is out of scope
for grading, which is correct — but that means a faithful `human_gate_time` is one
of the record's required guarantees that the deterministic suite cannot assert.

### Why this matters

Low severity: the field-absence and presence/absence oracles still catch the
high-value regressions (a verdict field, a missing section, a malformed range,
a wrong refusal route), and the §8 "descope, do not rubber-stamp" discipline is
the right posture. But the spec slightly over-claims when it says the conformance
oracle asserts conformance to "the S1 field set" — for at least one required
field the conformance is asserted only as presence-and-not-a-range, not as
correctness. The honest framing is that `human_gate_time`'s *content* is, like
exact token numbers and prose wording, explicitly out of deterministic grading
scope; the spec should list it alongside those rather than fold it under the
conformance oracle's "field set" claim. This prevents a future reader from
believing the suite grades a property it cannot.

## Explicitly not objecting to

- **Round-1 O1/O2/O8 — the un-fold (CONFIRMED GENUINELY RESOLVED):** S2 now makes
  no edit to `estimate-record-format.md`; §2.2, §2.3, §6.1, FR-9, the plan's
  removed Phase 2, and the module-touch list all consistently exclude the format
  reference, and the per-stage `cost_usd` sub-field is filed to #377 with the
  backward-compat demonstration assigned to its own diaboli pass. I checked for a
  lingering reference to the removed sub-field in scenarios, FR mapping, and the
  module list — there is none; the un-fold is complete, not cosmetic.
- **Round-1 O7 — the cost-omitted grounding path (CONFIRMED RESOLVED, no new
  conflict):** the directory-path convention (`observability/costs/`) is
  consistent with the as-merged S1 reference — line 28 requires "at minimum a
  cost-snapshot entry" (the entry is *present*, satisfying the rule) and Example 1
  (line 268) already uses the directory path for the empty case. The brief's
  worry that the fix would contradict the "at minimum a cost-snapshot entry" rule
  does not hold: a directory-valued `path` still satisfies the presence
  requirement, and §5.3 correctly flags the stricter "file-path-only" reading as a
  #377 tension rather than fixing it in S2.
- **Round-1 O4 — mechanical cost-omission removes the discretionary judgment
  (CONFIRMED RESOLVED in intent):** the "load-bearing" salience test is genuinely
  gone (§6.2, FR-10, §9.8); the only residual is the join-key under-specification
  raised as O2 above, which is a precision gap in the mechanical test, not a
  return of discretion. The over-omit-on-today's-repo worry the brief raised does
  NOT hold via the empty-snapshot path: S1 maps all three tiers (lines 142-146),
  so cost is omittable today only because `observability/costs/` is empty
  (cost-omitted, the correct §5.3 behaviour), not because the mechanical rule
  fires.
- **Round-1 O5/O6/O10 — refusal trigger, inference-basis disclosure, precedence
  rule (CONFIRMED RESOLVED):** the readable-but-tableless `MODEL_ROUTING.md`
  refusal trigger (§5.2.3, §9.5, FR-7), the inference-basis disclosure on every
  inferred kind (§4.2, §9.7, FR-6a), and the larger-magnitude `failure_direction`
  precedence rule (§6.3, §9.9, FR-11a) are each carried into a scenario and an FR
  with no internal contradiction against the S1 contract.
- **The Standard model-tier routing and the out-of-scope discipline (unchanged
  from round 1):** the read-and-author tier rationale (§7) and the S3–S6 boundary
  policing (§2.2) survived the revision intact and were already confirmed sound;
  I am not re-litigating settled, unchanged surface.
