# Changelog

## 0.9.0 — 2026-06-15

### Three-way (six-pair) cross-check (pipeline-map P4)

Extends pipeline-mode **Phase C** from the two-collection `A↔D`
cross-check to the maximal **three-collection** cover — slice P4 of the
task-scoped pipeline-map feature (#363–#367). The pipeline collection now
challenges and is challenged by the architectural and domain collections,
so a stage's `condition`/`realises` claim is corrected by — and corrects —
the other two models.

- **All six directed pairs run** (diaboli O10, the maximal cover chosen
  deliberately; the combinatorial token cost is the accepted price of
  maximal mutual correction): the existing `A→D` / `D→A`, plus the four
  pipeline-touching pairs `P→A`, `A→P`, `P→D`, `D→P`.
- **Four new direction-flavoured failure modes**, one per new pair:
  *flow-contradicts-architecture* (`P→A`), *architecture-unbacked gate*
  (`A→P`), *flow-mis-sequenced concept* (`P→D`), *concept-redefining
  label* (`D→P`). The existing `A↔D` failure modes are unchanged.
- **Mechanics carry over unchanged**: the same five cross-check questions
  (`CC1 (boundary contradiction):` … `CC5 (mutual description
  integrity):`), the canonical `CC<N>` prefix, the per-subject
  `Cross-check applied; …` clean-run sentinel, the subject-only
  single-writer audit trail (now a graph rooted at subjects over three
  collections), and the Q-before-CC ordering invariant.
- **Backward-compatible status reporting** (diaboli O8): the scalar
  `cross_check_status` on the `LegibilityModel` keeps its **unchanged**
  v0.4.0 meaning — the **arch↔domain** outcome — so a consumer that read
  only that scalar (e.g. `/diagnose`) is unaffected. A **new**
  `pipeline_cross_check_status` field on the `ConceptualPipelineMap`
  template (same `completed | skipped_asymmetric | not_run` enum, same
  absence-means-`not_run` rule) carries the **pipeline's** outcome. Two
  models, two self-describing scalars.
- **Pipeline mode now runs cross-check**: the P3-era
  `cross_check_status: not_run` deferral is lifted; `CC<N>` entries now
  appear on subject elements, and both status scalars are set. The
  P3 anti-pattern forbidding cross-check in pipeline mode is replaced by
  P4 anti-patterns (trimming a directed pair, conflating the two scalars,
  bidirectional CC writes across three collections).

Deterministic Layer-1 structural tests guard the new field and the
six-pair cover
(`tdad_tests/tests/test_diagnostic_legibility_structural.py`,
`TestDiagnosticLegibilityThreeWayCrossCheck`).

**Watch item (story #6, revisit):** instrument which directed pairs
actually fire corrections on real invocations and trim any pair that
never does — deferred, not scheduled.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§6.3);
slicing record `docs/superpowers/slices/diagnostic-legibility-pipeline-map.md`
(P4); spec-mode diaboli O8 (status back-compat) and O10 (maximal cover).

**Marketplace**: the `diagnostic-legibility` listing entry version bumps
0.8.0 → 0.9.0 and its `description` gains a clause naming the three-way
cross-check; the top-level listing `version` and `plugin_version` are
unchanged.

P4 of the pipeline-map slicing record. Closes issue #366; parent feature
(#363–#367) continues with P5 (the `/pipeline-map` command + render).

## 0.8.0 — 2026-06-15

### Flow-tracing within scope + self-challenge (pipeline-map P3)

Adds **`mode: pipeline`** to the `diagnostic-legibility` agent — slice P3
of the task-scoped pipeline-map feature (#363–#367). It is the full
task-scoped build: given a work `task:` (+ optional `near:` hint), the
agent resolves the bound (the P2 scope-resolution protocol), then
**within that bound** traces control flow into a `ConceptualPipelineMap`,
builds the `architectural[]` / `domain[]` collections, and self-challenges
every element. The cross-check across all three collections is the next
slice (P4); v0.8.0 ships the individually-refined build.

- **New `mode: pipeline`** (fourth mode, alongside `full`,
  `cross-check-only`, `scope-resolution`). Inputs are the same as
  scope-resolution (`task:` required, `near:` optional, biases-not-bounds).
- **Phase A (pipeline) — trace + build**: discover entry points within the
  bound, follow the one dominant call/data path, classify each stage
  (`step` / `decision` with a `condition` / `outcome`), record
  `transitions` (grounding non-trivial ones in evidence), record
  `realises` cross-model links by name (the P4 seam), and build the
  architectural/domain collections for the same bound. One dominant
  pipeline per task (multiple pipelines out of scope).
- **Phase B (pipeline) — flow-flavoured self-challenge**: every pipeline
  stage is challenged through a new **five-question cover** — *phantom
  edge, condition fidelity, missed branch, smeared step, ungrounded node*
  — recorded as `Q<N>` notes; architectural/domain elements keep the
  existing five-question cover. Control-flow inference is more error-prone
  than enumeration, so the cover targets edges, conditions, and ordering.
- **Scope-relevance feedback loop**: after tracing, the bound is re-tested
  against what the trace surfaced and under-reach/over-reach corrections
  are fed back into `scope_resolution`, closing the predicted-vs-traced
  loop. The corrected bound is what the emitted map carries.
- **Output — two standalone YAML blocks in one response**: a
  `ConceptualPipelineMap` then a `LegibilityModel` (`scope` = the resolved
  bound). The two are separate models (the map embeds neither collection —
  P1's decoupling holds); they travel together because P4's cross-check
  and P5's render consume both from one dispatch. This resolves the spec
  §4.3 open question (one response, two standalone blocks — not a merged
  envelope, not three dispatches).
- **Cross-check deferred**: the `LegibilityModel` carries
  `cross_check_status: not_run` and no `CC<N>` entries — the one place the
  agent legitimately emits `not_run` (Phase C is P4).
- **New anti-patterns**: phantom edges / straight-lined branches, tracing
  beyond the bound, multiple pipelines in one map, and running cross-check
  in pipeline mode.
- **Read-only boundary unchanged** (`Read`, `Glob`, `Grep`).

Deterministic Layer-1 structural tests guard the new mode
(`tdad_tests/tests/test_diagnostic_legibility_structural.py`,
`TestDiagnosticLegibilityPipelineMode`). The `resolve-task-scope.md`
how-to gains a pointer to the fuller pipeline build.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§6.1–§6.2;
the §4.3 bundle-shape resolution recorded there); slicing record
`docs/superpowers/slices/diagnostic-legibility-pipeline-map.md` (P3).

**Marketplace**: the `diagnostic-legibility` listing entry version bumps
0.7.0 → 0.8.0 and its `description` gains a clause naming the pipeline
mode; the top-level listing `version` and `plugin_version` are unchanged.

P3 of the pipeline-map slicing record. Closes issue #365; parent feature
(#363–#367) continues with P4 (three-way cross-check).

## 0.7.0 — 2026-06-15

### Task → bounded scope resolution (pipeline-map P2)

Adds the **front-of-pipeline** `mode: scope-resolution` capability to the
`diagnostic-legibility` agent — slice P2 of the task-scoped pipeline-map
feature (#363–#367). The agent gains a third mode that **inverts the
scoping direction**: instead of inspecting a code scope the human hands
it, it takes a natural-language **work task** a developer is considering
and **derives** the bounded slice of the system that task touches,
answering *"what does my task touch?"* This is the first human-visible
slice of the pipeline-map feature, surfaced via bare-Task agent dispatch
(mirroring sub-S2b); the full `/pipeline-map` command and the rendered
map are later slices (P5).

- **New mode `scope-resolution`** alongside `full` and
  `cross-check-only`. Inputs: a required `task:` and an optional `near:`
  hint. It runs no Phase A/B/C, builds no `LegibilityModel`, and traces
  no flow — it emits a **`ScopeResolution`** YAML (`task`,
  `scope_resolution` with `in_scope` / `adjacent_excluded` /
  `scope_confidence`, provenance) per the `conceptual-pipeline-map.md`
  template. This is the one mode whose output shape differs from
  `LegibilityModel`.
- **`near:` biases, does not bound** (diaboli O3). The hint is a strong
  starting prior; the agent may resolve the true touched process outside
  it and records any out-of-hint inclusion with its reason. A wrong hint
  cannot silently exclude the real process.
- **Derived-scope honesty contract** (diaboli O4). Because a derived
  bound is a prediction that can under- or over-reach, `adjacent_excluded`
  (the boundary the agent chose) is never omitted, and **when
  `scope_confidence` is below `high` the agent names the suspected failure
  *direction*** — `under-reach` ("may have missed needed files") or
  `over-reach` ("may be wider than the task touches") — since a bare
  scalar cannot say which way an uncertain bound failed.
- **Limiting policy**: the directly-touched process plus one hop of
  upstream/downstream context, context entries marked distinctly in their
  `reason` — limited, but not stranded.
- **Empty-task contract**: a well-formed task that resolves to no process
  is an honest empty result (`in_scope: []`, `scope_confidence: low`,
  reasons explaining the empty match), **not** a refusal; the agent
  refuses only when `task:` itself is missing or empty (a malformed
  dispatch).
- **New anti-patterns**: silent boundary, treating `near:` as a hard
  bound, and predicting the change site instead of the touched scope
  (change-site prediction is the deferred follow-on #368).
- **Read-only boundary unchanged** (`Read`, `Glob`, `Grep`) — resolving
  scope is more reading, not more capability.

Deterministic Layer-1 structural tests guard the new mode's contract
(`tdad_tests/tests/test_diagnostic_legibility_structural.py`,
`TestDiagnosticLegibilityScopeResolution`). New how-to page
`docs/plugins/diagnostic-legibility/how-to/resolve-task-scope.md`
documents the surface.

**Acceptance gate (spec §3.1).** P2 is the load-bearing relevance bet;
before P3 traces flow inside the bound, the scope-resolution surface is
hand-validated against a handful of worked tasks on a real repo. The
gate is a human acceptance step, not an automated check.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§3, §5);
slicing record `docs/superpowers/slices/diagnostic-legibility-pipeline-map.md`
(P2); spec-mode diaboli `docs/superpowers/objections/dl-pipeline-map-design.md`
(O1 the relevance bet, O3 `near`, O4 failure direction).

**Marketplace**: the `diagnostic-legibility` listing entry version bumps
0.6.0 → 0.7.0 and its `description` gains a clause naming the new mode;
the top-level listing `version` and `plugin_version` are unchanged.

P2 of the pipeline-map slicing record. Closes issue #364; parent feature
(#363–#367) continues with P3.

## 0.6.0 — 2026-06-14

### ConceptualPipelineMap data model (pipeline-map P1)

Ships the `ConceptualPipelineMap` as its **own standalone data-model
template** (`templates/conceptual-pipeline-map.md`) — the first slice
(P1) of the task-scoped conceptual pipeline map feature (#363–#367). The
map is a traced process through a codebase scope, expressed as stages
connected by transitions, with decision points, grounding, and the
provenance of the scope it was drawn for. It is **not** a collection
bolted onto `LegibilityModel`: a flat enumeration cannot express
ordering, branching, and convergence, so the pipeline map is its own
artefact, produced/cross-checked/rendered on its own terms.

- **Four record types**: the `ConceptualPipelineMap` wrapper (`task`,
  `scope_resolution`, `entry`, `stages`, `transitions`, provenance),
  `PipelineStage` (`id`, `label`, `kind`, `condition`, `part_of`,
  `realises`, `evidence`, `confidence`, `challenge_notes`),
  `PipelineTransition` (`from`, `to`, `condition_label`, `kind`,
  `evidence`), and `ScopeResolution` (`in_scope`, `adjacent_excluded`,
  `scope_confidence`).
- **Presentation- and producer-agnostic, not structure-free** (spec
  §4.1 / diaboli O2). The model deliberately commits to a conceptual
  control-flow ontology — `kind: step | decision | outcome` is a
  conceptual role, the diamond/rectangle/stadium glyph is the renderer's
  projection. The decoupling holds for the glyph, not the existence of
  the decision.
- **Stable opaque `id`** — the load-bearing decoupling choice. Display
  numbering (`1`/`5A`/`5A.1`), shapes, layout, node text, and target
  format are all renderer-derived and never stored. Sub-step hierarchy is
  expressed structurally via `part_of`.
- **Derived-scope honesty** — because the scope is inferred from the
  task rather than handed in, `ScopeResolution` records the bound for
  audit; below `high` confidence the producer names the suspected
  failure direction in the reasons.
- **Cross-model seam** — a stage `realises` an architectural element
  and/or domain concept **by name**, leaving the map valid standalone;
  this is the P4 cross-check seam. Stages reuse the legibility
  discipline's `confidence` + `challenge_notes` (`Q<N>`/`CC<N>`).
- **Empty-task sentinel** (diaboli O7) — a task that resolves to no
  process emits `stages: []` with a populated `scope_resolution` at
  `low` confidence; it coexists with, and is matched independently of,
  the `(empty scope)` sentinel governing the architectural[]/domain[]
  collections.
- **No agent logic and no rendering** in this slice — P1 fixes the
  schema only, mirroring sub-S2a's role for `LegibilityElement`. Flow
  tracing (P3), three-way cross-check (P4), and the `/pipeline-map`
  command + Mermaid HTML render (P5) are later slices.

Deterministic Layer-1 structural tests guard the template's documented
field contract and decoupling invariants
(`tdad_tests/tests/test_diagnostic_legibility_structural.py`).

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md`; slicing
record at
`docs/superpowers/slices/diagnostic-legibility-pipeline-map.md`;
spec-mode diaboli at
`docs/superpowers/objections/dl-pipeline-map-design.md` (12 objections,
all accepted); choice-cartographer at
`docs/superpowers/stories/dl-pipeline-map-design.md`.

**Marketplace**: the `diagnostic-legibility` listing entry version bumps
0.5.0 → 0.6.0 and its `description` gains a sentence naming the new
template; the top-level listing `version` and `plugin_version` are
unchanged (a per-plugin entry content change is the plugin's own
contract, not the listing contract — S1–S4 precedent).

P1 of the pipeline-map slicing record. Closes issue #363; parent feature
(#363–#367) continues with P2.

## 0.5.0 — 2026-06-01

### On-demand `/diagnose` command (S4)

Ships the human-facing `/diagnose` command — the surfacing interface
that exercises the full S2 + S3 pipeline end-to-end and renders the
mutually-corrected models as a readable report. This is the **last
slice** of the diagnostic-legibility plugin's carpaccio decomposition;
parent issue #327 closes with it.

- **Command** (`commands/diagnose.md`): `/diagnose <scope> [--out <dir>]`
  — a single verb. Forwards `<scope>` to the agent verbatim, dispatches
  in `mode: full`, renders the returned `LegibilityModel` as markdown,
  and writes the report after a human accept/abort gate.
- **Report geometry**: a compact two-column cross-check **summary table**
  (Architectural | Domain — the at-a-glance side-by-side) plus two
  **stacked** `### Architectural model` / `### Domain model` bodies, each
  element grouping its `Q<N>` (self-challenge) then `CC<N>` (cross-check)
  notes in canonical order. The wrapper `cross_check_status`
  (`completed | skipped_asymmetric | not_run`) is surfaced in the header
  and summary. Correction counts are "elements revised" — elements
  carrying ≥1 `CC<N>` entry per direction, not raw entry counts.
- **Confirm-before-write gate**: the command prints a summary naming the
  resolved target path (flagging an overwrite), then writes only on
  human **accept**; an **abort** writes nothing and creates no
  directory. The accept gate — not the validation checkpoint — is the
  last line of defence before write.
- **Output**: reports default to `diagnostic-legibility/output/`
  (gitignored — derived, regenerable artefacts, never committed or
  rsynced into the plugin cache), filename
  `<scope-slug>-legibility-<YYYY-MM-DD>.md`; overridable with `--out`.
- **Refusal contract**: a `diagnostic-legibility refusal:` line is
  surfaced verbatim and aborts with no file written.
- **Validation checkpoint**: reads the rendered report back and checks
  header completeness, no `<DISPATCHER:` leak, both collections
  rendered, Q/CC ordering, and correction counts consistent with the
  parsed YAML; deviations fixed in place, the agent is not re-dispatched.
- **Docs**: new how-to (`run-the-diagnose-command.md`) and reference
  (`diagnose-command.md` + reference quadrant `index.md`);
  `invoke-the-agent.md` forward-link to #333 resolved to the new how-to.
- **Agent clarification** (rides this bump): the both-empty branch of
  the agent now states it emits `cross_check_status: skipped_asymmetric`
  explicitly (S4 spec-mode diaboli O2 — the empty-scope contract was
  previously undefined for this wrapper field).

**Decision discipline** — spec at
`docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/dl-s4-diagnose-command-design.md`
(11 objections — 10 accepted, 1 deferred); choice-cartographer at
`docs/superpowers/stories/dl-s4-diagnose-command-design.md`
(8 stories: 2 promoted, 5 accepted, 1 revisit).

**Promoted to `AGENTS.md` from the cartographer's dispositions:**

- Story #1 — the gate-ordering invariant (the human disposition must
  *precede* the write; ordering is the invariant, not just the
  agent/command tool split). Sharpens the existing *agent-emit +
  dispatcher-persist + human-disposes* architecture entry.
- Story #8 — the declined-hand-off anti-pattern (a "natural home"
  hand-off in slice N does not bind slice N+1; re-file orphaned concerns
  as standalone issues). The orphaned invocation-persistence corpus for
  the Phase-C escalation trigger is re-filed as
  [#350](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/350).

**Marketplace**: the `diagnostic-legibility` listing entry version bumps
0.4.0 → 0.5.0 and its `description` is rewritten (the now-shipped
`/diagnose` command); the top-level listing `version` stays 0.4.0 (a
per-plugin entry description is the plugin's own contract, not the
listing contract — S1–S3 precedent).

S4 of the parent slicing record at
`docs/superpowers/slices/diagnostic-legibility-plugin.md`. Closes issue
#333 and parent issue #327.

## 0.4.0 — 2026-06-01

### Cross-check mechanism for mutual model correction (S3)

Adds Phase C (cross-check) to the `diagnostic-legibility` agent's
construction protocol. After Phase B (self-challenge) completes,
Phase C uses each refined collection (architectural, domain) to
challenge the other through five cross-check questions with
direction-flavoured weighting (CC1 heavy A→D; CC5 heavy D→A). The
agent emits a `LegibilityModel` whose elements carry both `Q<N>`
(self-challenge) and `CC<N>` (cross-check) entries; the model-level
`cross_check_status` field on the wrapper records the outcome.

- **Agent file**: extended with Phase C, the five cross-check
  questions, the structured refusal contract, and the two mode
  markers (full and cross-check-only).
- **Schema template**: `templates/legibility-element.md` adds an
  additive optional `cross_check_status` field on the
  `LegibilityModel` wrapper with three legal values (`completed`,
  `skipped_asymmetric`, `not_run`). v0.3.0 outputs remain valid;
  field-absence semantically means `not_run`.
- **Named direction-specific failure modes**:
  - A→D direction (CC1 weighted) targets *architectural-implicit
    assumption in domain description*.
  - D→A direction (CC5 weighted) targets *domain-concept smear in
    architectural element*.
  Both are working hypotheses revisable from disposition data.
- **Two mode markers**: `mode: full` (default — Phase A+B+C, the
  superset of v0.3.0) and `mode: cross-check-only` (Phase C only,
  against a fenced YAML payload). The earlier `mode: construct-only`
  was dropped at adjudication — no named consumer.
- **Subject-only audit trail**: `CC<N>` entries are written on the
  subject element only; side-effects on sibling elements are named
  in the subject's prose body rather than appended as duplicate CC
  entries on the side-effect element. One author per CC entry.
- **Structured refusal contract**: unrecognised mode value, missing
  preconditions, unfenced/multiple YAML blocks, or unsubstituted
  `<DISPATCHER: ...>` placeholders in `cross-check-only` mode
  trigger a structured refusal line. No silent fallback.
- **Two-layer ordering enforcement**: the agent self-verifies at
  emit time that `CC<N>` entries follow `Q<N>` entries in every
  element's `challenge_notes[]`, re-ordering in place if needed; a
  fixture-based structural test in `tdad_tests/` complements the
  emit-time check at CI time.

**Decision discipline** — spec at
`docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md`;
spec-mode diaboli at
`docs/superpowers/objections/dl-s3-cross-check-mechanism-design.md`
(10 objections, all accepted); choice-cartographer at
`docs/superpowers/stories/dl-s3-cross-check-mechanism-design.md`
(7 stories: 3 promoted, 4 accepted); code-mode diaboli at
`docs/superpowers/objections/dl-s3-cross-check-mechanism-design-code.md`
(4 objections — 0 critical/high; O1, O2, O4 accepted as
implementer-surface clarifications and absorbed here, O3 deferred to
S4 as the natural first test of the version-bump test pattern).

**Follow-up issues** opened from the cartographer's promoted
dispositions:

- [#347](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/347) —
  Promote: granularity-routing as schema-evolution discipline
  (paired Stories #1 + #4 — per-element facts route through prefix
  discipline on existing fields; model-level facts earn additive
  wrapper fields; single-writer invariant for audit-trail entries).
- [#348](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/348) —
  Promote: dispatcher-first error contracts for agent output
  (Story #6, third occurrence — agents producing structured output
  for programmatic consumers must specify a structured refusal shape
  and must not silently fall back on unrecognised input). Sister to
  the open #339 plugin_version promotion.

S3 of the parent slicing record at
`docs/superpowers/slices/diagnostic-legibility-plugin.md`. Closes
issue #332; parent issue #327 remains open until S4 (#333 — the
`/diagnose` command) also ships.

## 0.3.0 — 2026-05-28

### Two-model agent — challenge protocol and working agent (sub-S2b)

Ships the working `diagnostic-legibility` agent. The agent accepts a
codebase scope, drafts an architectural model and a domain model
against the `LegibilityElement` schema from v0.2.0, then runs a
**retained-challenge single-pass** cycle — five questions per element
in an explicit adversarial Phase B — and emits a `LegibilityModel`
YAML block with `challenge_notes[]` on every element.

- New agent file at `agents/diagnostic-legibility.agent.md` (~245
  lines, Read/Glob/Grep tool boundary, two-phase construction
  protocol with fresh-sub-context self-challenge per spec §3.4).
- Removes the `agents/.gitkeep` placeholder from v0.1.0.
- The five questions: *boundary, evidence, confounders, confidence,
  description integrity*. Each note carries a mandatory
  `Q<N> (question name):` prefix; the `Challenge applied; no
  questions surfaced changes` sentinel is the only exception.
- Empty-scope degenerate case is handled by the `(empty scope)`
  sentinel element name — exactly the literal string, parentheses
  included, so downstream consumers can pattern-match.
- New docs pages at `docs/plugins/diagnostic-legibility/how-to/`
  (invoke-the-agent how-to) and `…/explanation/` (challenge-refine
  protocol concept page).

Cross-check (parent S3, #332) and the human-facing `/diagnose`
command (parent S4, #333) remain out of scope. The how-to documents
bare Task-tool dispatch as the v0.3.0 invocation surface and links
forward to #333 for the command surface.

**Code-mode diaboli adjudication
(`docs/superpowers/objections/dl-s2b-challenge-protocol-design-code.md`):**
9 objections raised (4 high, 4 medium, 1 low); 7 accepted and
addressed in this PR, 2 deferred.

- O1 (high, prefix ambiguity) — Q\<N\> challenge-note prefix unified
  on the canonical `Q<N> (lowercase-name):` form; deprecated
  no-parens variants removed; structural test added.
- O2 (high, missing clock/model introspection) — `generated_at` and
  `generated_by` now emitted as `<DISPATCHER: ...>` placeholders;
  dispatcher fills at persistence.
- O3 (high, brittle test) — `test_marketplace_plugin_version_*`
  rewritten to compare against the canonical
  `ai-literacy-superpowers/.claude-plugin/plugin.json` `version`
  instead of a hard-coded literal; tracks main per spec §9.
- O4 (high, sentinel drift unguarded) — two static-text guards added
  asserting both literal sentinels appear in the agent body.
- O5 (medium, under-advertised contract) — agent description
  extended to name the Q\<N\> prefix and `(empty scope)` sentinel;
  matching test updated.
- O6 (medium, stale prose) — marketplace.json description and
  README Install section updated to reflect the v0.3.0 shipped agent.
- O8 (medium, Phase A ambiguity) — Phase A restructured: both-empty
  check fires after steps 3 *and* 4, asymmetric outputs (one
  collection populated, the other empty) explicitly named as valid.
- O7 (medium, observability gap) — *deferred*. The escalation
  trigger (sentinel-only ratio) needs invocation persistence, which
  belongs to parent S4 (#333). Explanation page updated to be
  honest about the gap at v0.3.0.
- O9 (low, plugin_version governance) — *deferred*. Already tracked
  at #339; current PR ships under existing per-spec discipline.

**Follow-up issues opened by the choice-cartographer adjudication
(`docs/superpowers/stories/dl-s2b-challenge-protocol-design.md`):**

- #338 — Meta-spec: cross-plugin discipline scoping (the *revisit*
  follow-up for Story #7 — TDAD-scenario-check and
  docs-reference-parity-check are currently scoped only to
  `ai-literacy-superpowers/`; whether they should extend to
  diagnostic-legibility and model-cards is a meta-decision deferred
  to a future spec).
- #339 — Promote: marketplace.json `plugin_version` cross-PR
  coordination rule (the *promoted* follow-up for Story #8 — the
  per-spec restatement of the merge-time rule should be promoted to
  `CLAUDE.md` so it governs every future PR without ceremony).

Sub-S2b of the meta-iteration recorded at
`docs/superpowers/slices/dl-s2-two-model-agent.md`. Closes issue
#335; parent issue #331 auto-closes per its own comment.

## 0.2.0 — 2026-05-26

### LegibilityElement schema

Adds the `LegibilityElement` schema artefact at
`templates/legibility-element.md`. The schema covers both the
architectural and domain dimensions of the diagnostic-legibility
agent (built in sub-S2b, issue #335) under a single flat record type;
the dimensions are typed by the collection wrapper `LegibilityModel`,
not by the record itself. Carries `name`, `description`, `evidence`
(list of `{path, excerpt?}`), `confidence` (low/medium/high), and
`challenge_notes`. Wrapper adds `scope`, `generated_at`,
`generated_by`, and the two collections.

Replaces the `templates/.gitkeep` placeholder from v0.1.0.

Validation is enforced by the agent during construction; no runtime
validator ships at this version.

Sub-S1 of the meta-iteration recorded at
`docs/superpowers/slices/dl-s2-two-model-agent.md`. Tracks parent
issue #331. Sub-S2b (challenge protocol + working agent) is deferred
to issue #335.

## 0.1.0 — 2026-05-26

### Scaffold

Initial plugin scaffold. Establishes the Diagnostic Legibility plugin
as a first-class entry in the marketplace.

- `.claude-plugin/plugin.json` declaring the plugin at v0.1.0 with the
  charter: *"Agents accountable for helping to maintain human
  understanding."*
- Empty placeholder directories `agents/`, `skills/`, `commands/`,
  `templates/` — structural signals for where future content lands.
- README documenting the charter, the v0.1.0 scaffold-only status,
  and links to the three deferred issues (#331 S2, #332 S3, #333 S4).
- Docs-site landing page at `docs/plugins/diagnostic-legibility/`.

No functional agents or commands yet — the first agent ships in
[#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331)
(S2).

Tracks parent issue [#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).
