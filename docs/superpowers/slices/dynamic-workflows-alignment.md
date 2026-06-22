---
task: "Dynamic Workflows Alignment — introduce Claude Code dynamic workflows as an ephemeral execution substrate beneath the plugin's static agents, governed by INV-1 (ephemeral proposes, durable curates) and INV-2 (quarantine untrusted-content readers)"
task_slug: dynamic-workflows-alignment
date: 2026-06-22
carpaccio_model: claude-opus-4-8[1m]
inseparable: false
progressed_slice: null
slices:
  - id: S1
    title: "Foundational skill + election discipline (D1 + D8)"
    scope: "Ship the dynamic-workflows skill (SKILL.md + patterns/when-not-to-use/governance references) and the compute-discipline election rubric, including the MODEL_ROUTING.md workflow-election + token-budget section. Establishes the shared conceptual model and the rule that workflows are elected, not reflexive."
    decision_focus: "What is the durable/ephemeral boundary the rest of the alignment references, and what rubric and token-budget convention govern when a workflow is elected versus the static pipeline?"
    lens_used: decision-boundary
    disposition: accept
    disposition_rationale: "Accepted (Russ, 2026-06-22). Build first per §6 — foundation everything references."
    file_as_issue: yes
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/438
    merged_into: null
  - id: S2
    title: "Template library + INV-1/INV-2 firewall (D2 + §5.1)"
    scope: "Ship the four *.workflow.js templates via the skill, each with a literate preamble, plus the deterministic CI/GC grep rule that fails if any template writes directly to durable artefacts (HARNESS.md, AGENTS.md, CLAUDE.md, MODEL_ROUTING.md) and the INV-2 lint that withholds high-privilege tools from untrusted-content readers."
    decision_focus: "How is the INV-1 firewall mechanised deterministically — what exactly does the grep rule match as a 'direct write to a durable artefact', and how is INV-2 made lint-checkable on templates?"
    lens_used: decision-boundary
    disposition: accept
    disposition_rationale: "Accepted (Russ, 2026-06-22). Firewall (§5.1 grep + INV-2 lint) ships atomically with the templates — non-negotiable per §7 governance-erosion risk."
    file_as_issue: yes
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/439
    merged_into: null
  - id: S3
    title: "harness-enforcer fan-out upgrade (D3)"
    scope: "Add workflow mode to harness-enforcer: one verifier subagent per HARNESS.md rule plus a skeptic persona, with a synthesis barrier that waits for all N and a deterministic count-equality check (no silent drop). Document the fan-out slot in verification-slots SKILL.md."
    decision_focus: "What is the constraint-count threshold (open question 1, default 8) at which the enforcer switches to fan-out mode, confirmed or tuned per project?"
    lens_used: independence
    disposition: accept
    disposition_rationale: "Accepted (Russ, 2026-06-22). Open Q1 resolved: threshold = 8 (spec default), configurable per project. Highest-leverage slice — land early."
    file_as_issue: yes
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/440
    merged_into: null
  - id: S4
    title: "Adversarial verification for code-reviewer + deep-research assessor/auditor (D5 + D7)"
    scope: "Add workflow mode to code-reviewer (separate context window, Advocatus Diaboli as rubric-bearing adversary, per-CUPID-property verifiers) and to assessor + harness-auditor (fan-out-by-area, adversarial self-preference guard, cited report into the existing timestamped artefact). Both reuse the adversarial-verification pattern proven by D3."
    decision_focus: "Should the same adversarial-verification shape (separate-context review, dedicated per-property/per-area verifiers) be applied uniformly across the self-preference-exposed agents, or specialised per agent?"
    lens_used: acceptance-criterion
    disposition: accept
    disposition_rationale: "Accepted (Russ, 2026-06-22). Reuse the adversarial-verification shape uniformly across the self-preference-exposed agents; specialise only where an agent demands it."
    file_as_issue: yes
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/441
    merged_into: null
  - id: S5
    title: "orchestrator classify-and-act routing (D4)"
    scope: "Add a classification step before the existing pipeline: ordinary coding keeps the static default; design/naming routes to tournament; debugging routes to root-cause investigation; large backlogs route to triage-at-scale under INV-2 quarantine. Surface the chosen route in superpowers-status. GATE and MAX_REVIEW_CYCLES=3 GUARDRAIL hold on every route."
    decision_focus: "Should the tournament / root-cause / triage routes be on by default, or behind an explicit opt-in flag for the first release (open question 2)?"
    lens_used: independence
    disposition: accept
    disposition_rationale: "Accepted (Russ, 2026-06-22). Open Q2 resolved: routes are OPT-IN behind an explicit flag for the first release; static pipeline remains the sole default. Guards the §7 over-orchestration risk."
    file_as_issue: yes
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/442
    merged_into: null
  - id: S6
    title: "Reflection-mining curation workflow (D6)"
    scope: "Add an optional --mine mode to reflect that clusters REFLECTION_LOG.md entries with parallel agents, adversarially pre-filters candidates, and emits a vetted shortlist to a staging artefact — never to AGENTS.md (INV-1). Note in integration-agent that mining augments, never replaces, human curation."
    decision_focus: "Where should the staging artefact live (open question 3) — a new REFLECTION_STAGING.md or a section appended to the existing log? Either satisfies INV-1; the choice is ergonomic."
    lens_used: decision-boundary
    disposition: accept
    disposition_rationale: "Accepted (Russ, 2026-06-22). Open Q3 resolved: staging artefact is a new REFLECTION_STAGING.md (clean separation from the append-only log)."
    file_as_issue: yes
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/443
    merged_into: null
  - id: S7
    title: "Documentation, hooks, badge + Copilot degradation (D9 + §5.5)"
    scope: "Add the README Dynamic Workflows section, bump the skill-count badge 19→20, add the CHANGELOG entry, add the optional advisory Stop hook (warn, never block), add the CLAUDE.md pointer, and document the Copilot CLI degradation path. Finalises the alignment."
    decision_focus: "What is the Copilot CLI degradation contract (open question 4) — guidance-only fallback where the workflow runtime is absent, or omit the skill there entirely? — and is the advisory Stop hook shipped at all?"
    lens_used: independence
    disposition: accept
    disposition_rationale: "Accepted (Russ, 2026-06-22). Open Q4 (Copilot degradation) intentionally left open — decide during S7 build, as it shapes only the docs/fallback it ships."
    file_as_issue: yes
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/444
    merged_into: null
---

This record slices the Dynamic Workflows Alignment spec into seven
independently-shippable pieces. Each passes through the plugin's own
pipeline (spec-writer → tdd-agent → implementer → code-reviewer →
integration-agent) with a deterministic or agent-backed scenario to
verify against, and each carries one material decision for human
disposition. The nine deliverables (D1–D9) are clustered where they
share a decision or an acceptance criterion rather than emitted one
slice per D-number. The ordering follows the §6 dependency sequence
and honours the highest-leverage / smallest-blast-radius signal on D3.

## Runtime scope — Claude Code only (read before any slice)

**Dynamic workflows are a Claude Code runtime capability** (the
self-authored multi-agent harness substrate, trigger word `ultracode`).
The runtime is **not** present in GitHub Copilot CLI or any other coding
agent, and it is **not transferable** to them. This boundary applies to
**every slice in this record**, not only the documentation slice:

- **Where the runtime exists (Claude Code):** the workflow *modes* and
  *templates* the slices add are executable.
- **Where it does not (Copilot CLI, other agents):** the `dynamic-workflows`
  skill and every workflow-mode section degrade to **guidance only** — the
  knowledge (patterns, election rubric, INV-1/INV-2) is still readable, but
  no workflow can be spawned. A workflow-mode agent on such a tree must fall
  back to its existing static behaviour, never error or pretend to fan out.

Each per-slice spec (S2–S7) must restate this boundary explicitly: any
workflow-mode behaviour it adds is Claude-Code-gated, with a guidance-only
fallback elsewhere. The precise Copilot degradation *contract* (guidance-only
vs omit) is open-question 4 and is dispositioned in **S7**, but the
Claude-Code-only nature itself is settled and binds all slices now.

## S1 — Foundational skill + election discipline (D1 + D8) — decision-boundary

**Context.** D1 establishes the shared conceptual model (the six
patterns, the decision rubric, INV-1/INV-2) as knowledge agents read;
D8 encodes the compute-discipline gate so every subsequent workflow is
*elected*, not reflexive. The §6 sequence places these first and
adjacent (D1 → D8) precisely because everything downstream references
both. They are clustered because the skill is the vehicle and the
election rubric is the decision the vehicle carries — separating them
would ship a skill with no discipline, or a discipline with no home.

**Decision content.** The human must engage with the durable/ephemeral
boundary as the plugin will state it (governance.md restating
INV-1/INV-2 for agents) and with the election rubric: the
when-not-to-use questions, the MODEL_ROUTING.md workflow-election
section, and the token-budget convention (e.g. an explicit per-workflow
cap). An alternative framing of "when does compute get spent" produces
visibly different downstream work in every later slice. Note: the D3
threshold is *not* decided here — it rides on S3.

**Dependencies.** None upstream; this is the foundation. S2–S7 all
reference the skill and the election rubric established here.

**Rationale.** Decision-boundary fits: the durable/ephemeral boundary
and the election rubric are one coherent material decision whose
alternatives reshape every later slice. End-to-end is satisfied — the
skill enumerates against the schema and passes markdownlint, an
observable edge-to-edge output.

## S2 — Template library + INV-1/INV-2 firewall (D2 + §5.1) — decision-boundary

**Context.** D2 ships the four `*.workflow.js` templates (enforcer-
fanout, adversarial-review, reflection-mining, deep-assessment) with
literate preambles. §5.1 attaches the deterministic CI/GC grep rule
that is INV-1's *teeth*; §6's governance-erosion risk says explicitly
"do not ship without it." The template substrate and its firewall share
one acceptance criterion and must land together — a template library
without the firewall is the regression the spec warns against.

**Decision content.** The human must engage with how the INV-1 firewall
is mechanised deterministically: what string/path patterns the grep
rule treats as a "direct write to a durable artefact," and how INV-2
(withhold high-privilege tools from untrusted-content readers) is made
lint-checkable on each template. The alternative mechanisations (path
denylist vs. write-API match; lint vs. CI-only) produce visibly
different enforcement guarantees downstream.

**Dependencies.** Depends on S1 (templates are distributed via the
skill and reference its conceptual model). Every later agent slice
(S3–S6) adapts a template that must already pass this firewall.

**Rationale.** Decision-boundary fits because the firewall mechanism is
the load-bearing decision, not a file-organisation cut. End-to-end is
satisfied: templates parse as valid JavaScript, are referenced by
relative path, and the grep rule fails CI on violation — observable at
the system's edge.

## S3 — harness-enforcer fan-out upgrade (D3) — independence

**Context.** D3 is flagged highest-leverage and smallest-blast-radius
in both §4 and §6: a drop-in to the existing verification-slots
machinery that directly defeats the enforcer's signature "35 of 50
constraints checked" lazy stop. It replaces single-context enforcement
with one verifier subagent per HARNESS.md rule plus a skeptic persona.

**Decision content.** The material decision is open question 1: the
constraint-count threshold (default 8, configurable) at which the
enforcer switches to fan-out mode. Confirming 8 versus tuning per
project produces visibly different runtime behaviour — too low burns
compute on small HARNESS files; too high reinstates the lazy-stop risk.
The deterministic count-equality check (verifier results == enforceable
constraints) is the no-silent-drop guarantee.

**Dependencies.** Depends on S1 (election rubric) and S2 (it adapts
`enforcer-fanout.workflow.js`). Independent of S4–S7 — it can ship and
deliver value before any other agent gains workflow mode.

**Rationale.** Independence is recorded because S3 exemplifies the
land-without-blocking property the §6 sequence relies on: it is the
proving ground whose patterns S4 reuses, yet it ships standalone. It
carries its own material decision (the threshold), satisfying the
decision-boundary test, but independence is the load-bearing lens for
sequencing.

## S4 — Adversarial verification for code-reviewer + deep-research assessor/auditor (D5 + D7) — acceptance-criterion

**Context.** D5 moves code review into a separate context window with
Advocatus Diaboli as the rubric-bearing adversary; D7 gives assessor
and harness-auditor the deep-research shape (fan-out-by-area +
adversarial self-preference guard). §6 brackets them together: both
"reuse the same patterns as D3." They share the adversarial-verification
acceptance criterion — a verifier in a context distinct from the
producer — and clustering avoids three near-identical slices.

**Decision content.** The shared testable behaviour: review/assessment
operates in a context window distinct from the producing context, each
rubric property (CUPID, literate-programming) or repo area is checked by
a dedicated verifier, and findings are synthesised rather than
collapsed. No distinct open question rides on this cluster, so it falls
to acceptance-criterion rather than decision-boundary; the residual
choice (uniform shape vs. per-agent specialisation) is the engagement
point. MAX_REVIEW_CYCLES=3 holds; assessment stays a timestamped
artefact in the existing location and format.

**Dependencies.** Depends on S1, S2 (adapts `adversarial-review` and
`deep-assessment` templates), and is proven-out by S3's pattern.
Independent of S5–S7.

**Rationale.** Acceptance-criterion is the honest lens: the cluster has
no fresh material decision, only a set of Given/When/Then behaviours
that share one shape. Clustering D5 and D7 is the selectivity protocol
applied — they are pattern restatements of the same adversarial
verification scope across self-preference-exposed agents.

## S5 — orchestrator classify-and-act routing (D4) — independence

**Context.** D4 is the largest behavioural change: a classifier
front-end that routes by task type (static default / tournament /
root-cause / triage-at-scale). §6 deliberately sequences it *after* the
patterns are proven (post-D3/D5/D7) to de-risk the blast radius. The
default branch stays the static pipeline — the §7 over-orchestration
risk treats drift toward "everything is a workflow" as a regression.

**Decision content.** The material decision is open question 2: whether
the tournament / root-cause / triage routes are on by default or behind
an explicit opt-in flag for the first release. On-by-default maximises
leverage but raises token cost and over-classification risk; opt-in is
the conservative first cut. The alternatives produce visibly different
default behaviour for every classified task. The GATE and
MAX_REVIEW_CYCLES=3 GUARDRAIL remain in force on every route.

**Dependencies.** Depends on S1, S2, and the proven patterns from S3/S4.
Independent of S6 and S7.

**Rationale.** Independence is recorded because, despite being the
largest change, S5 lands without blocking S6 or S7 and is gated behind
the pattern-proving slices for sequencing reasons. It carries its own
material decision (route default), but independence governs where it
falls in the order.

## S6 — Reflection-mining curation workflow (D6) — decision-boundary

**Context.** D6 raises the *proposal* quality of the compound-learning
loop without touching the human-curates principle: a workflow clusters
REFLECTION_LOG.md, adversarially pre-filters candidates ("would this
rule have prevented a real mistake?"), and emits a vetted shortlist to a
staging artefact. §6 sequences it last among behavioural changes — it
augments the learning loop once the patterns are mature.

**Decision content.** The material decision is open question 3: where
the staging artefact lives — a new `REFLECTION_STAGING.md` or a section
appended to the existing log. Both satisfy INV-1 (AGENTS.md stays
byte-for-byte unchanged until a human promotes), so the choice is
ergonomic, but it is visibly different downstream: a new file changes
the GC/snapshot surface, an appended section changes the log's shape.
The deterministic check is AGENTS.md immutability under mining.

**Dependencies.** Depends on S1, S2 (adapts `reflection-mining.
workflow.js`). Independent of S7.

**Rationale.** Decision-boundary fits cleanly: the staging-location
choice is exactly the kind of decision where an alternative reshapes
downstream work (GC rules, snapshots, ergonomics) without being a
mere implementation detail.

## S7 — Documentation, hooks, badge + Copilot degradation (D9 + §5.5) — independence

**Context.** D9 finalises the alignment: README section, skill-count
badge 19→20, CHANGELOG entry, the optional advisory Stop hook, and the
CLAUDE.md pointer. §5.5 (the Copilot CLI degradation cross-cutting
criterion) is dispositioned here because D9 is where the degradation
path is *documented* — open question 4 is naturally answered alongside
the documentation it shapes.

**Decision content.** Two coupled decisions: open question 4 — the
Copilot CLI degradation contract (guidance-only fallback where the
runtime is absent, or omit the skill there entirely) — and whether the
optional advisory Stop hook (warn, never block) is shipped at all. Both
shape what the README and hooks.json must contain; the alternatives
produce visibly different cross-CLI behaviour and onboarding guidance.
Badge counts and the skills table must match the filesystem.

**Dependencies.** Depends on every prior slice for accurate counts and
documentation (badge 19→20 presumes the skill from S1 has landed). It
is the terminal finalisation slice.

**Rationale.** Independence is the honest lens: S7 blocks nothing and is
blocked only by completeness of the surfaces it documents. The Copilot
degradation decision is folded in rather than given its own slice
because it has no implementation substrate of its own — it is a
documentation-and-fallback contract that lives where the docs live.

## Sequencing recommendation

Follow the §6 dependency order, which this slicing preserves:

1. **S1** (D1 + D8) — foundation; establishes the model and the
   election rubric everything references.
2. **S2** (D2 + §5.1) — the concrete template substrate plus the INV-1
   firewall; do not ship templates without the grep rule.
3. **S3** (D3) — highest-leverage, smallest-blast-radius; the
   pattern-proving ground. Land this early for value.
4. **S4** (D5 + D7) — reuses S3's adversarial-verification pattern.
5. **S5** (D4) — largest behavioural change; sequence after the
   patterns are proven to contain blast radius.
6. **S6** (D6) — augments the learning loop once patterns are mature.
7. **S7** (D9 + §5.5) — finalisation; depends on prior slices for
   accurate counts and documentation.

S3 onward are mutually independent in value delivery; the ordering is a
risk-containment recommendation, not a hard dependency chain beyond
S1→S2 (every later slice adapts a template that must already pass the
firewall).

## Explicitly not slicing on

- **One slice per D-number.** Emitting nine slices (D1–D9) would
  fragment shared decisions: D1 and D8 share the durable/ephemeral-
  boundary-and-election decision; D2 and §5.1 share the firewall
  acceptance criterion; D5 and D7 are pattern restatements of the same
  adversarial-verification shape. Clustering compresses to seven, within
  the 3–5 bias's reach given the spec's genuine breadth.
- **Slicing on files.** The spec lists files per deliverable
  (`agents/*.agent.md`, `skills/.../*.workflow.js`). A
  one-slice-per-file cut would be a code-organisation boundary, not a
  decision boundary, and would scatter the INV-1 firewall across slices
  that each ship nothing observable.
- **Slicing on the four open questions alone.** The §7 open questions
  are material decision *anchors*, but several attach to a deliverable
  that carries its own substrate (Q1→S3, Q2→S5, Q3→S6, Q4→S7). Slicing
  purely on open questions would strand the implementation work and
  produce slices with nothing to verify against — violating end-to-end.
- **Slicing the INV-1 firewall apart from the templates.** The §5.1
  grep rule could read as its own deliverable, but §6's governance-
  erosion risk forbids shipping templates without it; separating them
  would let a template land unguarded, the exact regression the spec
  names. Kept atomic within S2.
- **Slicing the Copilot degradation as a standalone piece.** §5.5 /
  open question 4 has no implementation substrate of its own — it is a
  documentation-and-fallback contract — so it folds into the
  documentation slice (S7) rather than producing a slice that ships
  nothing observable.
