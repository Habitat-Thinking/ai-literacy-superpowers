---
task: "Diagnostic Legibility — S2: Two-model agent with per-model self-challenge"
task_slug: dl-s2-two-model-agent
date: 2026-05-26
carpaccio_model: claude-sonnet-4-6
inseparable: false
progressed_slice: S1
slices:
  - id: S1
    title: Schema decision — same or distinct data structures for the two model types
    scope: >
      Decide whether the architectural-model and domain-concepts-model are
      the same data structure (parameterised) or genuinely distinct schemas.
      Produce the schema definition(s) — field names, types, and descriptions —
      for each model type as the deliverable. No agent implementation yet;
      the deliverable is the schema artefact (markdown or inline spec section)
      that S2 can build directly on.
    decision_focus: >
      Are "big moving parts" and "domain concepts" the same record type (one
      schema, two instances) or distinct record types with different fields?
      This is a branching gate: if same, a single parameterised type suffices
      and S2b builds one construction path; if distinct, S2b needs two
      construction paths with different prompting targets. The wrong answer here
      propagates into every prompt the agent sends, into the cross-check
      (S3 of the parent), and into the surfacing format (S4 of the parent).
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: null
    file_as_issue: false
    issue_url: null
    merged_into: null

  - id: S2
    title: Challenge protocol and working agent — per-model self-challenge and refined output
    scope: >
      Design the challenge-refine cycle for each model type (given the schemas
      from S1) and implement the agent. Decisions include: single-pass vs.
      iterative challenge, what constitutes "good enough" refinement, and whether
      the agent self-challenges in one multi-turn context or dispatches a second
      pass. The deliverable is a working agent file in
      diagnostic-legibility/agents/ that accepts a scope, constructs both
      models, refines each through its challenge protocol, and emits the two
      refined models as structured output. Does not cross-check models against
      each other (that is S3 of the parent).
    decision_focus: >
      What is the challenge-refine cycle for each model type? Options range
      from: (a) a single critique-and-revise in one prompt, (b) a separate
      challenge dispatch that critiques and returns to the constructor, or
      (c) an iterative loop with a stopping condition (token budget, stability
      threshold, fixed count). The choice affects the agent's architecture
      (one pass vs. pipeline), its testability (where does the challenge output
      live?), its token cost, and what "refined" means in S3's cross-check
      inputs. This decision also determines whether there is one challenge
      protocol shared across both model types or two distinct protocols matched
      to each schema.
    lens_used: decision-boundary
    disposition: accepted
    disposition_rationale: null
    file_as_issue: true
    issue_url: https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/335
    merged_into: null
---

## S1 — Schema decision — same or distinct data structures for the two model types — decision-boundary

**Context**

The parent issue (#331) names the central question of S2 explicitly: "Are the 'big moving parts' model and the 'domain concepts' model the same data structure processed twice, or do they have distinct structure, prompting strategies, and challenge criteria?" The parent slicing record treated the entire schema + challenge + implementation as one slice, with the rationale that it was separable from cross-check (S3) and surfacing (S4). At meta-iteration granularity — slicing S2 itself — this schema question is a genuine gate. It is not merely a design preference; it determines the branching structure of every subsequent step.

The model-card-researcher agent (pattern anchor) shows what a well-defined agent schema looks like: the agent produces a single record type (the model card), driven by a single template. The diagnostic legibility agent is distinctive in that it produces *two* records in one pass, which makes the schema question non-trivial. If the architectural model has fields like `component_name`, `boundary_description`, `dependency_surface` and the domain model has fields like `concept_name`, `definition`, `ubiquitous_language_term`, then the schemas differ fundamentally — neither field set is a renaming of the other. If both models have fields like `name`, `description`, `confidence_score`, `challenge_notes` then one schema suffices and the difference is only in the prompting target and challenge criteria.

**Decision content**

The schema decision is the branching gate for S2. Two materially different outcomes:

1. **Same schema, different prompting target**: One `LegibilityModel` type with fields `name`, `description`, `confidence`, `challenge_notes`. The architectural-model instance uses a prompt targeting components, boundaries, and data flows; the domain-model instance uses a prompt targeting concepts, definitions, and ubiquitous language. The challenge criteria differ only in their content, not their structure.

2. **Distinct schemas**: `ArchitecturalModel` has fields specific to structural concerns (e.g. `moving_parts[]`, `interface_boundaries[]`, `coupling_points[]`); `DomainModel` has fields specific to semantic concerns (e.g. `ubiquitous_terms[]`, `aggregates[]`, `context_boundaries[]`). Different fields, different validation rules, and different challenge questions.

The difference propagates directly into S2's challenge protocol (what a good challenge question looks like for each type), into S3's cross-check (what it means for an architectural concept to challenge a domain concept, and vice versa), and into S4's surfacing format (how the two models are presented side by side). The schema artefact from this slice is the input specification for S2.

**Dependencies**

S1 of the parent (the plugin scaffold) must exist — the schema artefact will be committed as part of the diagnostic-legibility plugin's design documentation, and the directory structure (agents/, templates/) must be in place. S1 of the parent is shipped (PR #334 merged).

**Rationale**

The schema decision is genuinely separable from the challenge-protocol decision (S2 of this record). You can define the schema fields without deciding whether the challenge cycle is a single-pass critique or an iterative loop. The reverse is not true: you cannot write challenge criteria or challenge prompts without knowing what the fields being challenged are. Establishing the schema first is therefore not just an ordering preference — it is a dependency that the challenge-protocol design must respect. Gating on it separately preserves the human's ability to redirect at a low-cost moment: if the human decides during disposition that a shared schema is preferable, the challenge-protocol design (S2) adjusts accordingly without any agent code needing rewrite.

---

## S2 — Challenge protocol and working agent — per-model self-challenge and refined output — decision-boundary

**Context**

Once the schemas are settled (S1 of this record), the agent needs a challenge-refine cycle for each model. The parent issue says the agent "subjects each model to a challenge-refine cycle" — but leaves the cycle mechanics open. The model-card-researcher provides a partial pattern: it runs a tiered source strategy and produces refined content, but it does not have an explicit self-challenge step. The carpaccio and advocatus-diaboli agents are read-only emitters; neither provides a pattern for iterative refinement within a single agent pass.

The challenge-refine cycle is where the anti-hallucination value of the agent lives. A single critique-and-revise step is simpler but may miss persistent errors; an iterative loop with a convergence criterion is more thorough but has variable token cost and needs a stopping condition. The choice is architecturally material for both quality and cost.

**Decision content**

Three candidate challenge-protocol architectures:

1. **Single-pass critique-revise**: The agent constructs the model, then sends a challenge prompt ("What is wrong or under-specified in this model?"), then sends a revise prompt ("Revise the model to address the challenge"). One round. Fixed cost. Observable output: the revised model. Challenge output is an intermediate artifact, not retained in the final output.

2. **Retained-challenge single-pass**: Same as above, but the challenge questions and their resolutions are retained in the output alongside the revised model. The challenge output becomes part of the deliverable, available for S3's cross-check to use as diagnostic context.

3. **Iterative loop with stopping condition**: The agent runs challenge-revise cycles until the model stabilises (e.g. challenge produces no material changes, or a fixed iteration count is reached). Higher quality ceiling but variable cost. Stopping condition is a design decision in its own right.

The choice among these three also determines whether both model types share a challenge protocol (structure is identical, just applied to different schemas) or whether each type has a bespoke challenge protocol matching its schema's domain-specific concerns.

The deliverable of this slice is a working agent file at `diagnostic-legibility/agents/<name>.agent.md` that: accepts a scope, constructs the two models (per the schemas from S1), applies the challenge protocol to each, and emits both refined models as structured output.

**Dependencies**

S1 of this record (schema definitions must be settled before challenge criteria can be written). The diagnostic-legibility scaffold (S1 of parent, shipped in PR #334).

**Rationale**

The challenge protocol is architecturally independent from the schema question — it is the design of *how* the agent improves each model, not *what* the model contains. Separating them allows the human to engage with the challenge-mechanics question on its own merits after the schema is established. It also makes the working agent the first observable, runnable deliverable of the S2 track — this slice satisfies the end-to-end filter (a human can invoke the agent against a real codebase scope and observe two refined model outputs). Sequencing S1 first keeps the cost of a schema revision bounded to updating the challenge prompts rather than reconstructing a completed agent.

---

## Sequencing recommendation

S1 → S2. The schema definition (S1) is a hard dependency for the challenge-protocol design and implementation (S2). The challenge criteria, challenge prompts, and the agent's internal structure all reference the schema fields by name. Writing the challenge protocol without settled schemas produces work that is likely to require partial rewrite when the schema is revised.

There is no case for interleaving these two slices. S2 should not begin until S1's schema artefact is in place and the disposition has confirmed the same-or-distinct choice.

---

## Explicitly not slicing on

- **Scope ingestion mechanism.** How the agent reads the target codebase (filesystem walk, context-window injection, LSP query, incremental summarisation) is an implementation choice inside the agent, not a design gate. The parent slicing record correctly excluded this, and the exclusion holds at meta-iteration. It would only become a slice if the context-window constraint for large codebases is identified as a binding architectural constraint — but the issue does not surface that.

- **Convergence stopping condition as a standalone slice.** The iterative-loop option for the challenge protocol has a nested decision (what is the stopping condition?). This is not sliced out separately because the stopping condition is a parameter inside the challenge-protocol design, not an independently disposable gate. If the human picks the iterative-loop option in S2 disposition, the stopping condition is specified in the same spec.

- **Output format of the refined model pair.** The parent slicing record assigned the output format decision to S4 (surfacing interface). S2's deliverable is "structured output" — the format decision belongs to S4 because the output format is the contract between the agent pipeline and the human-facing surface. Pre-deciding format here would create a forward dependency on S4's interface decision.

- **Per-model bespoke challenge prompts vs. parameterised prompts.** Whether the architectural challenge prompt and domain challenge prompt are written as two separate prompt strings or as one parameterised template is an implementation choice within S2, not a design gate. The decision follows from the schema decision (same schema → parameterisable; distinct schemas → likely bespoke) and does not need its own slice.

- **Slicing on the two model types separately.** Constructing the architectural model and constructing the domain model could have been treated as two slices. This would be slicing on semantic content rather than on decisions — both constructions live inside the same agent, share the same execution context, and are designed in the same spec session. Treating them as separate slices would pad the count without adding cognitive-engagement value.

- **TDAD scenarios as a separate slice.** The project convention (CLAUDE.md) requires TDAD scenarios alongside each agent file. Writing the scenarios is an obligation that follows from S2's agent deliverable, not an independent design decision. It is implementation ceremony, not a design gate.
