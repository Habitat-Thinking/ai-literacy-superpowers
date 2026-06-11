---
task: "Add a prospective cost-estimation capability (cost-estimation skill, read-only cost-estimator agent, /cost-estimate command) that estimates token usage, agent-compute vs human-gate time, and cost for work flowing through the orchestrator pipeline, surfaced at T0 (pre-carpaccio), T1 (Slice Adjudication), and T2 (Plan Approval); grounded in MODEL_ROUTING.md budgets and cost snapshot actuals; governed by the disclosure-of-derived-judgment decision."
task_slug: cost-estimator-pipeline
date: 2026-06-10
carpaccio_model: claude-opus-4-8
inseparable: false
progressed_slice: S1
slices:
  - id: S1
    title: Cost-estimation skill — methodology, estimate-record format, and the disclosure/confidence contract
    scope: >
      Author the `cost-estimation` skill under
      ai-literacy-superpowers/skills/cost-estimation/SKILL.md. It defines the
      estimation methodology (how MODEL_ROUTING.md per-stage token budgets and
      the agent→model-tier mapping combine with observability/costs snapshot
      $/token actuals to produce a cost figure), the estimate-record format
      (the structured artefact the agent emits), and the disclosure/confidence
      contract: every estimate is a RANGE with disclosed confidence, what it
      included, what it excluded, and the failure direction — as required by the
      promoted AGENTS.md "disclosure-of-derived-judgment" decision. The record
      format must split time into agent-compute time vs human-gate latency. No
      agent, no command, no orchestrator wiring yet — this slice ships the
      methodology and the format contract that every other slice consumes.
    decision_focus: >
      What IS an estimate in this system, and what honesty contract governs it?
      A point-value estimator and a ranges-with-disclosed-confidence estimator
      are materially different artefacts with different record schemas and
      different downstream-trust properties. This slice locks the estimate-record
      shape (fields, range representation, confidence tiers, included/excluded
      disclosure, failure direction, agent-compute vs human-gate time split) and
      the grounding methodology BEFORE any code reads or writes it. Getting this
      wrong is expensive to retrofit across the agent, command, and three
      insertion points.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: >
      Accepted and progressed this iteration. The foundation: zero dependencies,
      and every other slice consumes the estimate-record format and disclosure
      contract it defines. Spec-writer runs against this slice's scope. Because
      S6 (calibration) is accepted in-scope, S1's methodology must keep the seam
      open for a calibration data source even though S6 ships after the estimator.
    file_as_issue: false
    issue_url: null
    merged_into: null

  - id: S2
    title: Read-only cost-estimator agent — emits an estimate record, never decides
    scope: >
      Build the `cost-estimator` agent at
      ai-literacy-superpowers/agents/cost-estimator.agent.md with a Read/Glob/Grep
      trust boundary, mirroring the carpaccio / advocatus-diaboli /
      choice-cartographer pattern. The agent receives a target (raw task text, a
      slicing record, or a spec), reads MODEL_ROUTING.md and the latest
      observability/costs snapshot, and returns the estimate-record content (per
      the S1 format) for the orchestrator or command to write to disk. The agent
      never writes the file, never picks a confidence label as a verdict, and
      never decides go/no-go — it emits, the human reads. Observable output: a
      valid estimate record returned from a dispatch against a real target.
    decision_focus: >
      Does the estimator faithfully mirror the established read-only-agent-emits-
      record-human-disposes pattern, or does it become a "smart" component that
      returns a recommendation? The whole architecture hinges on the agent being
      a derived-judgment emitter, not a decider. This slice decides the trust
      boundary, the input contract (what targets it accepts), and the
      emits-not-writes discipline that the disclosure contract depends on.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: >
      Accepted; filed as a tracked issue for the next iteration. Build after S1.
      The read-only-emits-record trust boundary is the load-bearing decision that
      keeps the human in the disposition seat.
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/369
    merged_into: null

  - id: S3
    title: /cost-estimate command — manual entry point on a slice or spec
    scope: >
      Add the `/cost-estimate` command at
      ai-literacy-superpowers/commands/cost-estimate.md as a manual entry point.
      It dispatches the S2 agent against a user-supplied target (a slicing record
      path, a spec path, or pasted task text), writes the returned estimate
      record to disk, and applies an output-validation checkpoint against the S1
      format reference (per the CLAUDE.md Output Validation Checkpoints
      convention). This is the human-facing, end-to-end surface that exercises
      the skill + agent without depending on a full orchestrator run — the
      prospective counterpart to the existing /cost-capture command.
    decision_focus: >
      Should there be a standalone manual surface at all, and what does it accept?
      A command that only runs inside the orchestrator gates is a different
      product from one a human can invoke ad hoc against any slice or spec. This
      slice decides the command signature, the accepted target types, where the
      record is written, and that the manual path carries its own validation
      checkpoint rather than relying on orchestrator-only validation.
    lens_used: end-to-end
    disposition: accepted
    disposition_rationale: >
      Accepted; filed as a tracked issue. The cleanest standalone end-to-end
      proof of S1+S2 — exercises the skill and agent through a real surface
      without touching the orchestrator. Prospective sibling of /cost-capture.
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/370
    merged_into: null

  - id: S4
    title: Orchestrator fold-in at T1 and T2 — estimates as informational fields in existing gates
    scope: >
      Wire the estimator into the orchestrator's EXISTING gates without adding
      new hard gates. T1: after carpaccio, dispatch the estimator to produce a
      per-slice token/cost breakdown and surface it as informational fields
      inside the Slice Adjudication gate (step 0) so the human can see cost
      while choosing which slice to progress/file/defer. T2: after spec-writer,
      dispatch the estimator against the progressed slice's spec to produce a
      tighter estimate and surface it as informational fields inside the Plan
      Approval gate. Both fold in as fields alongside the existing record
      summaries — they do NOT block, do NOT add a keypress, and do NOT let any
      agent write dispositions.
    decision_focus: >
      Do estimates fold into existing gates as informational fields, or do they
      become new decision points? This is the highest-value architectural
      commitment in the task: T1 is named the most valuable moment because it
      informs slice progression. Deciding "informational fold-in, never a hard
      gate" — and exactly which fields appear in which gate summary — determines
      whether the capability adds cognitive value or cognitive friction. The
      fold-in must preserve the orchestrator's existing gate semantics
      (carpaccio's hard gate, plan approval's hard+soft composite) unchanged.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: >
      Accepted; filed as a tracked issue. The highest-value insertion — T1
      informs which slice to progress/file/defer. Committed shape: informational
      fold-in into the existing Slice Adjudication and Plan Approval gates, never
      a new hard gate, no extra keypress.
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/371
    merged_into: null

  - id: S5
    title: T0 pre-carpaccio ballpark — coarse whole-task go/no-go signal
    scope: >
      Add the T0 insertion: a cheap, coarse whole-task estimate from raw task
      text ONLY, dispatched as a bonus before orchestrator step 0 (before
      carpaccio). It produces an explicitly low-confidence ballpark surfaced to
      the human as a go/no-go signal, with the confidence disclosure (per S1)
      making its coarseness loud. It does not block carpaccio and carries no
      gate.
    decision_focus: >
      Is the lowest-confidence, earliest insertion point worth shipping at all?
      T0 estimates from raw text alone — before any slicing or spec — are the
      least accurate and the most likely to mislead if their confidence framing
      is weak. The decision is whether the go/no-go value of a pre-pipeline
      ballpark outweighs the risk of an anchoring number presented before the
      work is even sliced, and if so, where exactly it fires relative to branch
      creation and issue creation. This is separable from S4: T0 lives outside
      any existing gate, whereas T1/T2 fold into existing gates.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: >
      Accepted; filed as a tracked issue. The T0 go/no-go ballpark, separable
      from S4 because it lives outside any existing gate. Its in/out and exact
      firing position (relative to branch/issue creation) are decided in its own
      spec; the S1 confidence disclosure is what keeps a raw-text ballpark honest.
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/372
    merged_into: null

  - id: S6
    title: Calibration loop — per-PR actuals capture for self-calibration over time
    scope: >
      Close the calibration loop: have the integration-agent capture actual
      per-PR tokens/cost into observability/costs/ at merge time, so the
      estimator calibrates against this repo's own history rather than only the
      generic MODEL_ROUTING budgets. Today there is NO automatic per-PR actuals
      capture — only quarterly provider-level snapshots — so this slice adds the
      capture mechanism and the feedback path from captured actuals back into the
      estimation methodology.
    decision_focus: >
      Is the calibration loop in scope for the first version, or a recorded
      follow-on? The human explicitly flagged it as separable. First-version
      estimates calibrate only against generic MODEL_ROUTING budgets; the loop
      adds repo-specific accuracy but also adds a new integration-agent
      responsibility and a new actuals-capture format. The decision is whether to
      ship the estimator first and calibrate later, or treat self-calibration as
      part of the initial delivery — and the answer shapes whether S1's
      methodology must already accommodate a calibration data source.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: >
      Accepted in-scope (not deferred); filed as a tracked issue to ship after
      the estimator itself. Because it is in-scope, S1's methodology must keep
      the seam open for a calibration data source now. Adds a new integration-
      agent responsibility and a per-PR actuals format distinct from the
      quarterly snapshot.
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/373
    merged_into: null
---

## S1 — Cost-estimation skill — methodology, estimate-record format, and the disclosure/confidence contract — decision-boundary

**Context**

The plugin already has a retrospective cost sibling: the `cost-tracking`
skill and `/cost-capture` command record actuals into
`observability/costs/YYYY-MM-DD-costs.md`. This task adds the prospective
counterpart. Before any agent or command can produce an estimate, the system
needs a definition of what an estimate is: the methodology that combines
MODEL_ROUTING.md per-stage token budgets (spec-writer 50-100k, tdd-agent
50-150k, implementer 100-250k, code-reviewer 50-100k, integration 30-80k) and
the agent→model-tier mapping with the snapshot $/token actuals, plus the
record format and the honesty contract. The promoted AGENTS.md decision
"disclosure-of-derived-judgment" governs that contract: an estimate is a
derived prediction and must disclose what it included, what it excluded, and
its confidence with failure direction.

**Decision content**

What IS an estimate in this system, and what honesty contract binds it? The
material choice is between a point-value figure and a range-with-disclosed-
confidence artefact — these are different record schemas with different
downstream-trust consequences. This slice decides the estimate-record field
set (range representation, confidence tiers, the included/excluded disclosure,
the failure-direction statement), the agent-compute-time vs human-gate-latency
split, and the grounding methodology that ties budgets and actuals to a cost
range. Every other slice consumes this format; deciding it first prevents
expensive retrofit across the agent, the command, and three insertion points.

**Dependencies**

None. The skill is the foundation. It can be authored against the existing
MODEL_ROUTING.md and cost snapshot data without any new code.

**Rationale**

This is the decision that the entire capability rests on. The disclosure
contract is not a presentation detail — it is the governance commitment that
makes a prospective estimate honest rather than an anchoring number dressed as
fact. Separating it as the first slice forces the format and the honesty
contract to be reviewed before any consumer is built, which is where the
disclosure-of-derived-judgment decision is cheapest to honour correctly.

---

## S2 — Read-only cost-estimator agent — emits an estimate record, never decides — decision-boundary

**Context**

The plugin's carpaccio, advocatus-diaboli, and choice-cartographer agents are
all read-only by tool boundary (Read/Glob/Grep), return a structured record
the orchestrator writes to disk, and surface that record at a human
disposition gate. The agent never decides — the human reads the record and
disposes. The cost estimator must mirror this exact pattern: it is a derived-
judgment emitter, not a recommender.

**Decision content**

Does the estimator faithfully mirror the read-only-agent-emits-record-human-
disposes pattern, or does it drift into returning a recommendation or a
go/no-go verdict? The architecture hinges on the agent emitting an estimate
record (per S1) and nothing more. This slice decides the Read/Glob/Grep trust
boundary, the input contract (what targets the agent accepts — raw task text,
a slicing record, a spec), and the emits-not-writes discipline. A "smart"
agent that picks the answer would break both the established pattern and the
disclosure contract, which depends on the human engaging with the range rather
than receiving a verdict.

**Dependencies**

S1 (the estimate-record format and methodology must exist for the agent to
emit a valid record).

**Rationale**

Mirroring the established read-only pattern is the load-bearing architectural
decision for the agent. It is what keeps the human in the disposition seat and
keeps the agent honest. Slicing it separately from the surfaces that invoke it
(S3, S4, S5) lets the emits-not-decides contract be reviewed in isolation,
before the agent is wired into any gate where a stray recommendation would do
the most damage.

---

## S3 — /cost-estimate command — manual entry point on a slice or spec — end-to-end

**Context**

The retrospective sibling exposes `/cost-capture` as a manual command. The
prospective capability needs an equivalent manual surface so a human can ask
for an estimate ad hoc — against a slicing record, a spec, or pasted task text
— without running a full orchestrator pipeline. The CLAUDE.md Output
Validation Checkpoints convention requires any command that writes structured
markdown to read it back and validate against the format reference.

**Decision content**

Should there be a standalone manual surface at all, and what targets does it
accept? A command usable only inside orchestrator gates is a different product
from one a human invokes directly against any slice or spec. This slice decides
the `/cost-estimate` signature, the accepted target types, where the record is
written, and that the manual path carries its own validation checkpoint rather
than relying on orchestrator-only validation.

**Dependencies**

S1 and S2 (the command dispatches the S2 agent, which emits the S1 record;
it cannot exist meaningfully without both).

**Rationale**

This slice is where the capability first becomes observable end-to-end for a
human: dispatch → record written → validated → presented. It exercises the
skill and agent through a real surface, independent of the orchestrator
integration, so the core estimator can be proven before it is folded into the
pipeline gates. It also matches the established symmetry with `/cost-capture`,
keeping the prospective and retrospective surfaces discoverable as a pair.

---

## S4 — Orchestrator fold-in at T1 and T2 — estimates as informational fields in existing gates — decision-boundary

**Context**

The orchestrator already runs two human-disposition gates relevant here: the
Slice Adjudication gate at step 0 (after carpaccio, where the human sets
`progressed_slice` and dispositions) and the Plan Approval gate (after
spec-writer and the diaboli/cartographer records). The task specifies that
estimates FOLD INTO these existing gates as informational fields — they are
explicitly NOT new hard gates. T1 (per-slice breakdown at Slice Adjudication)
is named the highest-value moment because it informs which slice to
progress/file/defer; T2 (tighter estimate at Plan Approval) is higher
confidence because the spec enumerates scenarios and files.

**Decision content**

Do estimates fold into existing gates as informational fields, or do they
become new decision points? This is the central architectural commitment of
the task. The decision is to surface estimates as fields in the existing gate
summaries — preserving carpaccio's hard gate and plan approval's hard+soft
composite unchanged, adding no keypress and no block — and to decide exactly
which estimate fields appear in which gate summary. An alternative that
introduced a new "Cost Approval" gate would change the cadence of the pipeline
and the human's cognitive load; this slice commits to fold-in, not a new gate.

**Dependencies**

S1 and S2 (needs the record format and the agent). Independent of S3 (the
manual command) and S5 (the T0 insertion) — the orchestrator can dispatch the
agent directly at T1/T2 without the command, and the T1/T2 fold-in does not
require T0.

**Rationale**

The fold-into-existing-gates decision is what determines whether the capability
adds value or friction. T1 is where cost most changes a human's choice (which
slice to progress), so getting the informational-field placement right at Slice
Adjudication is the payoff of the whole feature. Slicing T1 and T2 together is
deliberate: they share one decision (informational fold-in into existing gates,
never a new hard gate) and one mechanism (dispatch the S2 agent, surface fields
in the existing gate summary), differing only in target and confidence. Splitting
them per gate would be slicing on insertion points rather than on the decision.

---

## S5 — T0 pre-carpaccio ballpark — coarse whole-task go/no-go signal — decision-boundary

**Context**

The task proposes three insertion moments. T1 and T2 fold into existing gates
(S4). T0 is different in kind: a coarse whole-task ballpark from raw task text
ONLY, fired as a cheap bonus BEFORE orchestrator step 0 (before carpaccio),
explicitly low-confidence, intended as a go/no-go signal. It lives outside any
existing gate.

**Decision content**

Is the lowest-confidence, earliest insertion point worth shipping at all, and
if so, where exactly does it fire? T0 estimates from raw text alone — before
slicing or spec — are the least accurate and the most prone to anchoring a
human on a number before the work is even understood. The decision weighs the
go/no-go value of a pre-pipeline ballpark against that anchoring risk, and
fixes the firing position relative to branch creation and issue creation. The
S1 confidence disclosure is what makes a T0 ballpark defensible; whether that
is enough to justify the insertion is the call here.

**Dependencies**

S1 and S2 (needs the format and the agent). Independent of S4 — T0 lives
outside the existing gates, so it can land before or after the T1/T2 fold-in,
and either can be dropped without affecting the other.

**Rationale**

T0 is separated from S4 because it is a different architectural commitment: S4
folds into gates the orchestrator already owns and hard-enforces, whereas T0
adds a brand-new pre-step-0 touchpoint with no gate and the weakest confidence.
Conflating them would hide a genuine in/out decision (ship the riskiest, least
accurate insertion at all?) inside the higher-value gate-fold-in work. As its
own slice, the human can accept the high-value T1/T2 fold-in while deferring or
dropping T0 on its own merits.

---

## S6 — Calibration loop — per-PR actuals capture for self-calibration over time — decision-boundary

**Context**

The human explicitly flagged this as separable fast-follow. Today there is no
automatic per-PR actuals capture — only quarterly provider-level snapshots via
`/cost-capture` — so first-version estimates calibrate only against the generic
MODEL_ROUTING budgets. Closing the loop means having the integration-agent
capture actual per-PR tokens/cost into `observability/costs/` at merge time, so
the estimator calibrates against this repo's own history and grows more
accurate over time.

**Decision content**

Is the calibration loop in scope for the first version, or a recorded follow-on?
The loop adds repo-specific accuracy but also adds a new responsibility to the
integration-agent and a new per-PR actuals-capture format distinct from the
quarterly snapshot. The decision is whether to ship the estimator calibrated
only against generic budgets first and add self-calibration later, or to treat
the loop as part of the initial delivery — and that answer feeds back into S1,
because the methodology must accommodate a calibration data source if the loop
is in scope from the start.

**Dependencies**

Conceptually depends on S1 (the methodology must know how to ingest calibration
data) and on the estimator existing (S2). It does not block S1–S5: the
estimator ships and functions against generic budgets without it. This is the
slice most likely to be dispositioned as a deferred follow-on.

**Rationale**

The human named this as separable, and the lens agrees: it is a distinct
decision (ship now vs. defer) with a distinct downstream artefact (per-PR
actuals capture wired into the integration-agent). Surfacing it as its own
slice lets the human make the in/out call deliberately rather than having it
silently bundled into the first version. If deferred, it becomes a clean
follow-on issue; if accepted, S1's methodology must be specced to accept the
calibration source from the outset.

---

## Sequencing recommendation

S1 is the foundation and must land first — it defines the estimate-record
format and the disclosure/confidence contract that S2 through S6 all consume.
S2 (the read-only agent) follows directly, as it emits the S1 record.

After S1 and S2, the consuming surfaces are largely independent of each other:

- **S3** (`/cost-estimate` command) is the cleanest standalone proof — it
  exercises S1+S2 end-to-end without touching the orchestrator. Good candidate
  to progress first among the consumers.
- **S4** (T1/T2 fold-in) and **S5** (T0 ballpark) both wire the agent into the
  pipeline but at different points; neither depends on the other, and neither
  depends on S3. S4 is the highest-value insertion (T1 informs slice
  progression) and is the recommended progressed slice after the foundation if
  the human wants impact first.
- **S6** (calibration loop) is the natural last/deferred slice — it improves
  accuracy over time but the estimator functions without it. Its disposition
  also feeds back into S1's methodology scope, so if accepted it should be
  decided before S1 is specced.

Recommended chain if shipping incrementally: S1 → S2 → (S3 to prove
end-to-end) → S4 (highest-value gate fold-in) → S5 → S6.

## Explicitly not slicing on

- **One slice per component (skill / agent / command).** Slicing strictly on
  the three named components would be a code-organisation cut. The skill (S1)
  is genuinely its own decision because it carries the disclosure contract; the
  command (S3) is its own decision because it is a standalone surface. But the
  agent (S2) is sliced on the read-only-emits-record DECISION, not because it
  is a separate file — the file boundary and the decision boundary happen to
  coincide here, and the slice is justified by the latter.

- **One slice per insertion moment (T0 / T1 / T2).** Tempting, but T1 and T2
  share a single decision — informational fold-in into existing gates, never a
  new hard gate — and a single mechanism, so they are clustered into S4.
  Splitting them would be slicing on insertion points (a layer/step cut) rather
  than on the decision. T0 is split out from them because it is a genuinely
  different decision (a new pre-step-0 touchpoint with no gate), not merely a
  third insertion point.

- **Grounding-data plumbing (reading MODEL_ROUTING.md and the cost snapshot).**
  How the agent reads the budget table, the tier mapping, and the snapshot
  $/token actuals is implementation detail inside S1 (methodology) and S2
  (agent), not a separate design decision. The task specifies the data sources,
  not a choice between them.

- **The disclosure/confidence contract as a separate slice.** The
  disclosure-of-derived-judgment contract is the core of S1's record format,
  not a bolt-on. It cannot pass the end-to-end filter on its own (it ships
  nothing observable independently of the record it governs), so it is folded
  into S1 where it belongs.

- **Time-split (agent-compute vs human-gate latency) as a separate slice.** The
  two-way time split is a field-level property of the S1 estimate-record format,
  not an independent decision with its own observable output. It is decided
  within S1.

- **Versioning, CHANGELOG, marketplace pointer, and docs pages.** Plugin
  version bumps, CHANGELOG entries, marketplace `plugin_version` updates, and
  the how-to/explanation docs pages follow from whichever component slices land,
  per the standard CLAUDE.md conventions. They are maintenance steps attached to
  each slice's PR, not decisions in their own right.
