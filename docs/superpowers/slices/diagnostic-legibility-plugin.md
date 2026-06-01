---
task: "Create new plugin called the Diagnostic Legibility plugin and its first agent"
task_slug: diagnostic-legibility-plugin
date: 2026-05-26
carpaccio_model: claude-sonnet-4-6
inseparable: false
progressed_slice: S1
slices:
  - id: S1
    title: Plugin scaffold — Diagnostic Legibility plugin structure
    scope: >
      Establish the Diagnostic Legibility plugin as a first-class plugin in this
      marketplace: plugin.json, README, CHANGELOG, docs landing page, and the
      standard directory layout (agents/, skills/, commands/, templates/). No
      agent logic. The deliverable is a structurally complete, loadable plugin
      with no functional commands yet.
    decision_focus: >
      Is the Diagnostic Legibility agent a new standalone plugin (own plugin.json,
      own versioning, own marketplace entry) or does it live as a skill/agent
      inside ai-literacy-superpowers? The task names a new plugin explicitly.
      Establishing the scaffold as its own plugin locks in the structural decision
      before any agent code is written.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: null
    file_as_issue: false
    issue_url: null
    merged_into: https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/334

  - id: S2
    title: Two-model agent — architectural and domain models with per-model self-challenge
    scope: >
      Build the first agent inside the plugin. The agent accepts a scope (e.g.
      a directory path or list of files), constructs two distinct models — one
      for big moving parts/architectural structures, one for domain concepts —
      and subjects each model to a challenge-refine cycle before emitting the
      two refined models as structured output. The agent does not yet cross-check
      the models against each other; that is S3.
    decision_focus: >
      Are the "big moving parts" model and the "domain concepts" model the same
      data structure processed twice, or do they have distinct structure,
      prompting strategies, and challenge criteria? The task treats them as
      distinct. This slice decides the model schema and challenge protocol for
      each dimension independently, producing two models that are refined but
      not yet mutually corrected.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: null
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331
    merged_into: [https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/336, https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/341]

  - id: S3
    title: Cross-check mechanism — mutual model correction
    scope: >
      Add the cross-check step to the agent: take the two refined models from S2
      and use each to challenge and correct the other, producing mutually-corrected
      final models. The observable output is the corrected model pair, distinct
      from the individually-refined outputs of S2. The cross-check protocol
      (single-pass, multi-pass, structured comparison, or iterative) is decided here.
    decision_focus: >
      What is the protocol for mutual correction? The task specifies the outcome
      (mutually-corrected models) but not the mechanism. A second agent pass
      differs materially from a single agent holding both models simultaneously
      and doing structured comparison. This decision determines the cross-check
      architecture: pass count, state management, and when to stop.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: null
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332
    merged_into: https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/349

  - id: S4
    title: Surfacing interface — on-demand human legibility command
    scope: >
      Deliver a command (or agent invocation surface) that a human can call to
      request the corrected models. The command decides the output format:
      structured markdown report, queryable interactive session, or side-by-side
      model summary. The deliverable is an observable, human-facing surface that
      exercises the full S2 + S3 pipeline end-to-end.
    decision_focus: >
      How are the corrected models surfaced to a human "on demand"? The task
      requires surfacing but does not specify the interface. A /diagnose command
      that prints a structured report is a different contract from an interactive
      agent that a human can query. This decision defines the output format and
      command signature, which affects how the results are consumed and whether
      they are cacheable.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: null
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333
    merged_into: https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/351
---

## S1 — Plugin scaffold — Diagnostic Legibility plugin structure — decision-boundary

**Context**

This repository hosts multiple plugins in a shared marketplace, each with its own versioned plugin.json, README, CHANGELOG, and directory layout. The model-cards plugin is the structural anchor: it has agents/, skills/, commands/, templates/, seed/, and a .claude-plugin/ directory. Adding a new plugin to the marketplace is a structural action with downstream consequences for versioning, CI checks (version consistency), and docs-site organisation.

**Decision content**

Does the Diagnostic Legibility agent belong as a new standalone plugin (with its own plugin.json and marketplace entry), or as a skill or agent nested inside ai-literacy-superpowers? The task names "a new plugin called the Diagnostic Legibility plugin" explicitly — this is the human's stated intent. The decision here is to honour that framing by establishing the scaffold before writing any agent code, so that downstream slices build on a structurally stable foundation rather than retrofitting an agent that was initially dropped into the wrong container.

**Dependencies**

None. The scaffold requires no existing agent or skill logic. It can land first and independently.

**Rationale**

Establishing the scaffold as its own slice forces the structural decision to be made and reviewed before any agent code is written. If the human decides during disposition that the agent should live inside ai-literacy-superpowers instead, that redirection is cheap at this stage and expensive after S2 and S3 are built into the wrong container.

---

## S2 — Two-model agent — architectural and domain models with per-model self-challenge — decision-boundary

**Context**

The task describes an agent that builds a "cohesive, self-challenged and reassessed model" with two distinct dimensions: (1) big moving parts and architectural structures, and (2) domain concepts. Each dimension involves recognition, challenge, and refinement to reduce the chance of hallucination. The task treats these as two separate models that are each subjected to a challenge-refine cycle before being used together.

**Decision content**

Are the architectural model and the domain model the same data structure and prompting strategy applied to different content, or do they require distinct schemas, distinct challenge criteria, and distinct refinement protocols? This is a material decision: if they share a schema, one parameterised model type suffices; if they differ structurally, the agent needs two separate construction phases with different logic. This slice decides the schema and per-model challenge protocol, and delivers an agent that produces two individually-refined models as its observable output.

**Dependencies**

S1 (the plugin scaffold must exist for the agent file to have a home).

**Rationale**

Separating this from S3 (cross-check) keeps the two decisions distinct. S2 is about building and internally validating each model. S3 is about using the models against each other. An agent that does both in one pass conflates two architecturally separate concerns and makes it harder to reason about where the model quality comes from.

---

## S3 — Cross-check mechanism — mutual model correction — decision-boundary

**Context**

Once both models are built and individually refined (S2), the task specifies that they should be used "to cross-check and challenge one another to result in mutually-corrected models." This is a second-order operation: the architectural model challenges the domain model, and vice versa, producing outputs that have been corrected by each other's perspective.

**Decision content**

What is the protocol for mutual correction? The task specifies the outcome but not the mechanism. The decision involves: how many cross-check passes to run (one mutual pass vs. iterative convergence); whether the cross-check is done by the same agent in a second pass holding both models in context simultaneously, or by dispatching a separate agent with each model as a challenge input; and when to declare convergence and emit the final corrected pair. Different choices produce materially different architectures, token costs, and quality characteristics.

**Dependencies**

S2 (the two individually-refined models must exist as inputs to the cross-check).

**Rationale**

The cross-check mechanism is architecturally independent from the model construction logic and warrants a separate design decision. The choice of protocol affects whether the agent is a single stateful pass or a multi-step pipeline, which in turn affects how it is tested, how failures are diagnosed, and what the intermediate outputs look like.

---

## S4 — Surfacing interface — on-demand human legibility command — decision-boundary

**Context**

The task's stated purpose is to "aid in human understanding" — the corrected models are not an internal artifact but something "surfaced on demand to a human." This implies a human-facing interface: a command, a slash command, or an agent session. The model-cards plugin provides a reference pattern: a /model-card command that drives a researcher agent and writes structured output.

**Decision content**

What is the interface by which a human invokes the diagnostic legibility pipeline and receives the corrected models? A /diagnose-legibility command that writes a structured markdown report is a different contract from an interactive agent session that accepts follow-up queries. The decision determines the command signature, the output format (file, stdout, structured report, or interactive), and whether results are cached for re-reading. This slice delivers an end-to-end observable human-facing surface that exercises the full pipeline from scope ingestion through S2 and S3 to human-readable output.

**Dependencies**

S3 (the cross-check mechanism must exist to produce the corrected models the command surfaces).

**Rationale**

Separating the surfacing interface into its own slice ensures the output contract is a deliberate decision, not an implementation afterthought. It also makes the end-to-end completeness of the preceding slices observable: S1 through S3 can be verified mechanically, but S4 is where a human actually sees the diagnostic output and can judge whether the legibility goal has been achieved.

---

## Sequencing recommendation

S1 → S2 → S3 → S4. This is a strict dependency chain: the plugin scaffold must exist before the agent can be placed, the two-model agent must produce models before the cross-check can run, and the cross-check must produce corrected models before the surfacing command has anything to show.

There are no independent slices in this record; all four slices are ordered by structural necessity. The recommendation is to resolve each disposition before speccing the next slice — specifically, the S1 scaffold decision (standalone plugin vs. nested) will affect the file paths and plugin.json configuration for S2, S3, and S4.

## Completion status

**All slices merged — the chain is complete (parent #327 closed).**

| Slice | Shipped | PR | Plugin version |
| --- | --- | --- | --- |
| S1 — Plugin scaffold | ✅ | [#334](https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/334) | v0.1.0 |
| S2 — Two-model agent | ✅ | [#336](https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/336) (S2a schema, v0.2.0) + [#341](https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/341) (S2b challenge protocol, v0.3.0) | v0.2.0 → v0.3.0 |
| S3 — Cross-check mechanism | ✅ | [#349](https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/349) | v0.4.0 |
| S4 — Surfacing interface (`/diagnose`) | ✅ | [#351](https://github.com/Habitat-Thinking/ai-literacy-superpowers/pull/351) | v0.5.0 |

S2 was delivered across two PRs during implementation: the
`LegibilityElement` schema (S2a) and the working two-model
challenge agent (S2b). Both are recorded in the S2 entry's
`merged_into` field.

---

## Explicitly not slicing on

- **Per-model challenge loop granularity.** The challenge-refine cycle within each model (in S2) is not a separate slice. Breaking out "construct model," "challenge model," and "refine model" as three slices per model type would be slicing on implementation steps, not decisions. The decision in S2 is the schema and challenge protocol; the loop mechanics are implementation.

- **Scope ingestion mechanism.** How the agent reads the codebase (filesystem walk, git tree, LSP query, context-window injection) is an implementation decision inside S2, not a separate design decision. The task specifies what the agent does with the scope, not how it reads it. This could become a slice if the ingestion strategy has significant constraints (e.g., context-window size for large codebases), but the task does not surface that constraint.

- **Hallucination reduction as a separate slice.** The task names hallucination reduction as a motivation for the challenge-refine and cross-check steps. It is not a separable feature; it is a quality property of S2 and S3. Slicing it out would produce a candidate with no observable output — it cannot pass the end-to-end filter independently.

- **Plugin marketplace registration.** Updating .claude-plugin/marketplace.json and the plugin version badge are maintenance steps that follow from S1, not decisions in their own right. They are covered by the standard versioning conventions in CLAUDE.md and do not require a separate slice.

- **Individual file creation within the scaffold.** The plugin.json, README, CHANGELOG, and directory layout are all part of the S1 scaffold decision. Slicing them individually would be slicing on files — the anti-pattern the lenses explicitly prohibit.

- **Separate "first version" scoping decision.** The task says "as a first version we want to build an agent that..." — this scoping language might suggest a slice for deciding what to defer. That is the orchestrator's and human's job during disposition; carpaccio slices the first-version scope as described, not the version planning exercise around it.
