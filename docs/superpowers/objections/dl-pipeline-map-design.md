---
spec: docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md
date: 2026-06-03
mode: spec
diaboli_model: claude-opus-4-8[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The capability's value rests on a relevance-scoping bet (task → bounded slice) whose accuracy the spec never commits to a target or acceptance bar for, so 'derive the slice my task touches' can ship technically-complete and still be useless."
    evidence: "§3.1 'Because the bound is a prediction rather than ground truth, the capability carries an honesty obligation the shipped plugin never had'; §9.2 lists 'the limiting aggressiveness' and precision/recall as still-open; the slicing record P2 decision_focus: 'Precision/recall on the bound is the central failure mode this decision must address.'"
    disposition: accepted
    disposition_rationale: "Accepted. The relevance bound is treated as the load-bearing bet it is, and the sequencing is changed (see O11) so it is validated before anything is built on it: a standalone 'what does my task touch?' surface — rendering the P2 scope_resolution alone, no map — ships as the FIRST human-visible slice, so a human inspects the in_scope / adjacent_excluded / scope_confidence disclosure on real tasks after one slice rather than after four. P2 additionally carries an explicit acceptance step: hand-validation against a handful of worked tasks on a real repo before P3 traces flow inside the bound. Disclosure remains the honesty mitigation, but the early standalone surface is what makes the bet's USEFULNESS (not just its honesty) inspectable. §3 and §9 are updated and the slicing record's sequencing recommendation now puts the scope surface first."
  - id: O2
    category: implementation
    severity: high
    claim: "The decoupling principle (model carries no display/implementation concerns) is asserted as load-bearing but leaks: the model encodes traversal-shaped fields (`entry`, `transitions`, `kind: decision/outcome`, `condition`) that are control-flow-tracing artefacts, not pure conceptual content, and the renderer cannot in fact derive numbering/shape from anything else."
    evidence: "§4.1 'The model holds only conceptual content … It carries no numbering, shapes, colours, layout, node text, or target format'; template §PipelineStage `kind` enum step|decision|outcome and the validation rule 'condition is legal only on a decision stage'; §7.2 maps `kind: decision` → diamond as a 'renderer's choice' while the model already fixed which stages are decisions."
    disposition: accepted
    disposition_rationale: "Accepted, resolved by reframing the claim rather than weakening the model. The over-broad 'implementation-agnostic' wording is narrowed to 'presentation-agnostic and producer-agnostic': the model is free of glyphs, numbering, layout, and target format, and is not tied to any particular tracer or renderer — but it is NOT structure-free, by design. It deliberately embeds a conceptual control-flow ontology (stages, transitions, decisions, outcomes), because a process genuinely HAS decision points and terminal outcomes independent of how they are drawn. So `kind: decision` is a conceptual property (this stage branches), and the diamond is the renderer's projection of it; the decoupling holds for the glyph, not for the existence of the decision — which is correct and intended. The template framing and spec §4.1 are updated to own the ontology explicitly and to state what the model is NOT agnostic about, closing the gap the objection names without pretending the model carries no structure."
  - id: O3
    category: specification quality
    severity: high
    claim: "The `--near` flag's binding semantics are internally contradictory: §7.1 says it 'bounds the scope-resolution search space' (a hard bound), while §9.2 lists 'does the hint bound or merely bias?' as still-open — a reasonable implementer cannot tell whether an agent may resolve scope outside `--near`."
    evidence: "§7.1: '`--near <path>` — optional hint that bounds the scope-resolution search space'; §9.2: 'how `--near` interacts with an agent that disagrees with the hint (does the hint bound or merely bias?)'."
    disposition: accepted
    disposition_rationale: "Accepted. `--near` is pinned to a single semantics: it BIASES, it does not BOUND. The agent treats `--near` as a strong starting prior for where to look, but may resolve the true touched process outside it; when it does, it records the out-of-hint inclusion and its reason in scope_resolution. This removes the wrong-guess correctness footgun (a developer narrowing to the wrong module can no longer silently exclude the real process) while keeping the cost/relevance benefit of a starting hint. §7.1 is rewritten to state 'biases, does not bound' and §9.2's open question is resolved."
  - id: O4
    category: specification quality
    severity: medium
    claim: "`scope_confidence` is specified as a single three-value enum, but the spec itself names two orthogonal failure modes (under-reach / over-reach, i.e. recall and precision) that a single scalar cannot disambiguate — a 'low' bound cannot tell the developer whether it missed files or over-included them."
    evidence: "§3.2 'Two failure modes bound the policy: under-reach (the bound misses a file the task needs) and over-reach (the bound stops being limited)'; template `scope_confidence` enum `low | medium | high`; §9.1 lists 'scope_confidence as one enum vs. precision/recall split' as open."
    disposition: accepted
    disposition_rationale: "Accepted, with a minimal-schema fix. `scope_confidence` stays a single enum (low|medium|high) to avoid over-engineering the schema every later slice freezes against, but the disclosure contract is strengthened: whenever scope_confidence is below high, the producer must name the suspected failure DIRECTION (under-reach: may have missed needed files; over-reach: may be wider than the task touches) in the scope_resolution prose. The direction is thus expressible where it matters (the honest disclosure) without splitting the scalar into two fields. The template and §3.2/§5 are updated."
  - id: O5
    category: risk
    severity: high
    claim: "The vendored Mermaid render breaks the project's self-contained-HTML norm in a way that is only partially acknowledged: the portfolio-dashboard precedent requires 'readable without JavaScript', and a Mermaid flowchart is the load-bearing content here, so a JS-disabled or JS-blocked reader gets an empty map, not a degraded one."
    evidence: "§2.2 'a deliberate, scoped exception to the repo's readable-without-JS / no-external-deps norm'; portfolio-dashboard SKILL.md Design Constraints: 'Readable without JavaScript: The dashboard must be fully readable with JavaScript disabled.'; §7.3 places the entire diagram inside `<div class=\"mermaid\">` rendered by the vendored JS."
    disposition: accepted
    disposition_rationale: "Accepted. The render must degrade, not blank. The P5 HTML embeds a static no-JS fallback inside <noscript> — the plain-text / indented-outline projection the model already supports (§7.2) — so a reader with JavaScript disabled, a script-stripping email client, or a PDF export still sees the flow structure rather than an empty box. This restores the portfolio-dashboard 'readable without JavaScript' norm the vendored-Mermaid exception otherwise broke; Mermaid remains the enhanced interactive view. §7.3 is updated and §7.4's validation checkpoint asserts the <noscript> fallback is present."
  - id: O6
    category: specification quality
    severity: medium
    claim: "The portability claim for the HTML artefact is left undecided while the spec simultaneously asserts the report is a 'self-contained single file' — §9.4 admits inline-the-~MB-bundle vs repo-local-asset is open, and the repo-local-asset choice would make every report non-portable, contradicting the self-contained framing the panel and header depend on."
    evidence: "§7.3 'A single self-contained file projected from the model'; §9.4 'the Mermaid vendoring mechanism (inline the ~MB bundle into every report vs. reference a repo-local asset) and whether the report stays a portable single file under that choice'."
    disposition: accepted
    disposition_rationale: "Accepted. §9.4 is resolved in favour of portability: the vendored, version-pinned Mermaid bundle is INLINED into each report, so 'self-contained single file' is literally true and a developer can share one .html to explain a process. The per-file size cost (in the gitignored output dir) is accepted as the price of portability; the repo-local-shared-asset alternative is dropped. §7.3 states inline-and-portable as the committed choice."
  - id: O7
    category: implementation
    severity: medium
    claim: "The empty-task sentinel design conflicts with the existing LegibilityModel degenerate-output contract in the three-collection world: the pipeline template emits `stages: []` for an empty task, but the shipped agent's `(empty scope)` rule forbids two empty collections and emits a sentinel element — when pipeline mode emits map + arch + domain together, it is unspecified which sentinel discipline governs and whether an empty task implies empty arch/domain too."
    evidence: "Template validation: 'Empty-task sentinel … emits an empty `stages: []` with a populated `scope_resolution`'; agent Honesty rules: 'do not return two empty collections. Emit exactly one element under `architectural[]`' with literal `(empty scope)`; §4.3 'the agent emits the `ConceptualPipelineMap` alongside the `architectural[]` / `domain[]` collections'."
    disposition: accepted
    disposition_rationale: "Accepted. The empty-result contract is fixed across all three collections at P1. The map's empty-task sentinel (empty stages[] + a populated low-confidence scope_resolution explaining the empty result) governs the MAP only; the architectural[] and domain[] collections continue to follow their own (empty scope) sentinel rule independently. The two sentinels are distinct and may co-occur (a task that resolves to no process yields an empty map AND, if the bound also surfaced no parts/concepts, an (empty scope) element in architectural[]). The template and §4.3 document that both disciplines coexist and which consumer matches which; the §6.2 scope-relevance loop is defined to short-circuit on an empty-task map."
  - id: O8
    category: specification quality
    severity: medium
    claim: "The backward-compatible three-collection cross-check status is named (`pipeline_cross_check_status`) but its value enum, its relationship to the existing scalar `cross_check_status`, and how `/diagnose` (which reads the scalar) behaves when a pipeline run is present are left undefined — a parallel field with no defined values is not a backward-compat design, only a backward-compat intention."
    evidence: "§6.3 'Add a `pipeline_cross_check_status` rather than re-typing the existing field, so the scalar reading stays valid'; §9.3 'the backward-compatible three-collection `cross_check_status` shape' is still open; the existing scalar contract in legibility-element.md fixes `completed | skipped_asymmetric | not_run` with absence meaning `not_run`."
    disposition: accepted
    disposition_rationale: "Accepted. `pipeline_cross_check_status` is fully specified at P4: legal values completed | skipped_asymmetric | not_run, with absence meaning not_run — mirroring the existing scalar exactly. The existing scalar `cross_check_status` retains its meaning UNCHANGED (the arch↔domain outcome); a three-collection run sets the arch↔domain scalar exactly as today and reports the pipeline's cross-check outcome only in the new field. `/diagnose`, which reads only the scalar, is unaffected and ignores the new field. §6.3 is rewritten from a named-but-undefined field to this value contract."
  - id: O9
    category: scope
    severity: medium
    claim: "The spec lists `/pipeline-map` joining the Output Validation Checkpoints but does not commit any docs-site pages (how-to, reference) despite CLAUDE.md requiring a how-to guide when a feature adds a new command — shipping the command without its how-to leaves the docs site inaccurate on the day P5 lands."
    evidence: "§7.4 '`/pipeline-map` joins the CLAUDE.md \"Output Validation Checkpoints\" list'; §8 'Out of scope' and the slices' 'Explicitly not slicing on' name docs only as 'mechanical per-slice follow-ons'; CLAUDE.md Docs Site Review: 'When a feature adds a new command, skill, or agent: check for an existing how-to guide and create one if missing.'"
    disposition: accepted
    disposition_rationale: "Accepted. The how-to and reference docs-site pages are promoted from 'mechanical follow-on' to an explicit P5 deliverable, shipped in the same PR as the command per CLAUDE.md Docs Site Review and matching the /diagnose precedent (which links both a how-to and a reference page). The slicing record's 'explicitly not slicing on' note is amended so docs are a named P5 deliverable, not an unscheduled follow-on; §7/§8 of the spec list the two pages."
  - id: O10
    category: alternatives
    severity: medium
    claim: "The 'third model, full treatment' call (build + self-challenge + three-way cross-check) is the most expensive path and the spec does not weigh a materially cheaper alternative — a derived flow projection over the already-cross-checked arch/domain collections — against it; the up-to-six directed-pair cross-check is acknowledged as a combinatorial-blow-up risk the spec defers rather than bounds."
    evidence: "§2.4 'Third model, full treatment … not a derived rendering that skips the challenge/cross-check cycle'; §6.3 'Which of the up-to-six pairs run is the core P4 decision (blow-up control)'; §9.3 'which of the up-to-six directed pairs run' is still open."
    disposition: accepted
    disposition_rationale: "Accepted; the full six directed pairs are run deliberately. 'Full treatment' is retained (the human's fixed input) and EXTENDED to maximal cross-correction: A↔D (existing) plus P→A, A→P, P→D, D→P — every directed pair touching the pipeline. The combinatorial cost the objection flags is accepted as the deliberate price of maximal mutual correction, and the cost trade-off (six-pair token cost vs the cheaper derived-projection alternative the objection names) is now recorded on the spec so the choice is explicit rather than inherited. §6.3 is rewritten to enumerate all six pairs, their direction-flavoured weighting, and the subject-only audit-trail extension to three collections; §2.4 notes the cost was weighed and the maximal option chosen."
  - id: O11
    category: scope
    severity: medium
    claim: "The headline-slice sequencing is left undecided (P4-before-P5 vs P5-before-P4, plus a possible standalone P2 surface), which means the first human-visible deliverable — and therefore what 'done enough to evaluate the premise' means — is unspecified at spec time; this is a scope question, not an implementation detail, because it determines which slice carries the acceptance burden for the relevance bet (O1)."
    evidence: "§9.5 'P4-before-P5 (first map already cross-corrected) vs. P5-before-P4 (visible map one slice sooner); whether P2 ships a standalone \"what does my task touch?\" surface first'; slicing record Sequencing recommendation marks both as 'open for disposition'."
    disposition: accepted
    disposition_rationale: "Accepted. Sequencing is fixed and the headline-slice question resolved: the standalone 'what does my task touch?' surface (a minimal render of P2's scope_resolution, no map) ships as the FIRST human-visible slice, then P3 (trace) → P4 (three-way cross-check) → P5 (full Mermaid map). This makes P2 itself the first observable deliverable and is the cheapest lever on O1's relevance risk — the bet is inspectable after one slice. The slicing record's sequencing recommendation and §9.5 are updated to commit to this order rather than leaving it open."
  - id: O12
    category: risk
    severity: medium
    claim: "The 'static-first but (live)-titled' framing risks shipping an artefact whose visual language promises runtime truth it does not have: the reference image is titled '(live)' with `Actual: 0.82 (true)` annotations, P6 (the overlay) is deferred, yet the P5 render mirrors that image's three-line nodes and legend — a developer could read the static map's gate conditions as observed runtime facts."
    evidence: "§2.1 'the green-check / grey-circle (live) overlay and the `Actual: 0.82 (true)` gate annotation become a later slice (P6)'; §7.2 'live status (P6) … seam only at P5'; §7.3 legend 'reserved for P6, the executed/not-executed key'; template `condition`: 'A conceptual rule, not a runtime value — the actual evaluated result is live data and is not part of this static model.'"
    disposition: accepted
    disposition_rationale: "Accepted. The P5 render must not imply runtime truth it lacks. It carries a visible 'Structural — not executed' banner, and the P6-reserved executed/not-executed legend slots are REMOVED from the static render (they reappear only when P6 actually ships the overlay), so a static map cannot be misread as a present-but-empty live view. This extends the capability's own honesty discipline (disclose the bound; never present a silent boundary) to 'never imply observed runtime facts'. §7.2/§7.3 are updated."
---

## O1 — premise — high

### Claim

The entire task-scoped framing rests on one new analytical capability — resolving
a natural-language task into a bounded, honest slice of the codebase — and the
spec treats the *accuracy* of that resolution as an open question rather than a
premise it has validated. If the relevance pass routinely under-reaches (misses
the file the task needs) or over-reaches (stops being "limited"), the headline
value proposition — "understand the process you are about to modify, limited to
what you will touch" — fails even when every slice is implemented exactly as
written. The spec never states a target precision/recall, an acceptance bar, or a
fallback when the bound is judged untrustworthy; it offers disclosure as the
mitigation, but disclosure makes a bad bound *honest*, not *useful*.

### Evidence

§3.1: "Because the bound is a prediction rather than ground truth, the capability
carries an honesty obligation the shipped plugin never had." §9.2 lists "the
limiting aggressiveness (touched-only vs. touched + one hop)" as still open. The
slicing record's P2 `decision_focus` is explicit: "Precision/recall on the bound
is the central failure mode this decision must address" — i.e. the central failure
mode is acknowledged but not resolved at spec time.

### Why this matters

This is the highest-leverage objection because P2 is the load-bearing new
capability every later slice consumes. If the bound cannot be made reliably useful
on real tasks, P3 traces flow within a wrong window, P4 cross-checks a wrong
window, and P5 renders a confidently-wrong map with a scope panel that honestly
explains an unhelpful boundary. The human should decide whether there is evidence
(even a handful of worked tasks against real repos) that the relevance pass clears
a usefulness bar before P3–P5 are built on top of it — or accept this explicitly
as a research bet and scope the first slice to test it.

## O2 — implementation — high

### Claim

The spec's central architectural claim — that `ConceptualPipelineMap` is
display-agnostic and implementation-agnostic, with every display concern *derived*
by the renderer — does not hold up against the model it defines. The model fixes
`entry`, `transitions`, `kind: decision | outcome`, and `condition`. These are not
neutral conceptual content: deciding that a fork is a `decision` stage and a sink
is an `outcome` stage *is* the control-flow tracing, and it is also exactly what
the renderer keys its diamond/stadium shapes off. The claim "the diamond is the
renderer's choice" is true only of the glyph; *which* stages are diamonds was
decided in the model. The decoupling is real for cosmetics (colour, layout, node
text) but illusory for the structural choices that matter.

### Evidence

§4.1: "The model holds only conceptual content: stages, transitions, decisions,
grounding … It carries no numbering, shapes, colours, layout, node text, or target
format." Template §PipelineStage: `kind` enum `step | decision | outcome`, with the
validation rule "condition is legal only on a decision stage." §7.2 maps
`stage.kind: decision` → `diamond`, presented under "Renderer-derived display,"
while the kind that drives the diamond is a required model field.

### Why this matters

The decoupling principle is sold (§4, slicing record P1 rationale) as the reason
the map is a standalone model rather than a collection on `LegibilityModel`, and as
the guarantee that a future live overlay or Graphviz/JSON projection needs no schema
change. If the model in fact bakes in trace-and-shape decisions, that guarantee is
weaker than claimed — a different renderer that wants to *recompute* whether a stage
is a decision (e.g. from richer evidence) cannot, and the "implementation-agnostic"
label invites a future producer to assume the model is free of tracing commitments
it is not. The human should decide whether the decoupling claim is stated more
narrowly (cosmetic-display-agnostic) or whether `kind`/`condition` are defended as
genuinely conceptual.

## O3 — specification quality — high

### Claim

The `--near` flag has two incompatible specifications in the same document. §7.1
says it "bounds the scope-resolution search space," which a reasonable implementer
reads as a hard constraint: the agent may not resolve scope outside the given path.
§9.2 then lists, as an open question, "does the hint bound or merely bias?" — which
states the opposite is undecided. An implementer building P2 cannot know whether an
agent that finds the real touched process *outside* `--near` should follow it
(bias) or suppress it (bound).

### Evidence

§7.1: "`--near <path>` — optional hint that **bounds the scope-resolution search
space** (a path, dir, or module the developer already suspects)." §9.2: "how
`--near` interacts with an agent that disagrees with the hint (does the hint bound
or merely bias?)."

### Why this matters

The two readings produce materially different products. Under "bound," `--near`
becomes a correctness footgun: a developer who guesses the wrong module silently
excludes the true process, and the honesty disclosure (O1's mitigation) reports a
confident boundary around the wrong slice. Under "bias," `--near` is a soft prior
the agent can override, which is safer but changes the cost story (§7.1 claims the
hint "cuts relevance error and cost"). Divergent implementations of the same flag
is exactly the spec-quality failure this category exists to catch. The human should
pin one semantics in the spec before P2.

## O4 — specification quality — medium

### Claim

`scope_confidence` is a single three-value enum, but the spec repeatedly frames the
bound's failure as two independent dimensions — under-reach (recall: missed a needed
file) and over-reach (precision: stopped being limited). A scalar `low` confidence
cannot tell the reader which way the bound failed, yet the two demand opposite
remedies (widen vs narrow). The model's honesty contract therefore cannot express
the very distinction the spec says is the central failure mode.

### Evidence

§3.2: "Two failure modes bound the policy: under-reach (the bound misses a file the
task needs) and over-reach (the bound stops being limited); §3.1's disclosure is
the mitigation for both." Template `scope_confidence`: enum `low | medium | high`.
§9.1 lists "`scope_confidence` as one enum vs. precision/recall split" as open.

### Why this matters

If disclosure is the mitigation for both failure modes (O1), and the disclosure
field collapses both into one scalar, the mitigation is blunter than the problem.
A developer reading `scope_confidence: low` learns the agent is unsure but not
whether to suspect missing files or over-inclusion — and the §6.2 scope-relevance
self-challenge feeds corrections back into a field that cannot record *which*
direction it corrected. The human should decide whether the single enum is adequate
or whether the precision/recall split (already raised in §9.1) is required before
P1 freezes the schema that every later slice consumes.

## O5 — risk — high

### Claim

The vendored-Mermaid decision creates a hard dependency on client-side JavaScript
for the artefact's *primary content*, not for progressive enhancement. The
project's self-contained-HTML precedent (portfolio-dashboard) requires the output
be "fully readable with JavaScript disabled," with JS allowed only for optional
enhancement. Here the flow map — the headline deliverable — exists only as Mermaid
source rendered by the vendored JS at view time. A reader with JS disabled, an
email client that strips scripts, a PDF export, or a corporate browser policy gets
the scope panel and detail table but a blank where the map should be.

### Evidence

§2.2: "a deliberate, scoped exception to the repo's readable-without-JS /
no-external-deps norm, justified because a branching flow graph needs a real layout
engine." portfolio-dashboard SKILL.md Design Constraints: "Readable without
JavaScript: The dashboard must be fully readable with JavaScript disabled.
JavaScript may be used for progressive enhancement … but is not required for the
content to be visible." §7.3: the diagram is "`<div class=\"mermaid\">…</div>` +
the vendored `mermaid.min.js` + an `initialize` call."

### Why this matters

The spec acknowledges the exception but treats it as purely a no-CDN /
supply-chain matter, not a readability-degradation matter. The two norms are
distinct: vendoring the bundle satisfies "no external deps" but not "readable
without JS." Because the map is the content (the detail table is the audit trail,
not the legible flow), the artefact has no graceful-degradation story — it is
all-or-nothing on JS. The human should decide whether that is acceptable, or
whether the renderer must also emit a static fallback (e.g. an SVG snapshot or the
plain-text outline the model can already project to per §7.2) so the artefact
degrades rather than blanks.

## O6 — specification quality — medium

### Claim

The spec asserts the HTML artefact is a "single self-contained file" while
simultaneously listing, as open, a vendoring mechanism (repo-local shared asset)
that would make the file *not* self-contained. The portability property the scope
panel and header lean on (a file a developer can share to explain a process) is
left undecided at the same time it is asserted.

### Evidence

§7.3: "A single self-contained file projected from the model." §9.4: "the Mermaid
vendoring mechanism (inline the ~MB bundle into every report vs. reference a
repo-local asset) **and whether the report stays a portable single file under that
choice**."

### Why this matters

The two resolutions are not interchangeable polish: inlining a ~MB bundle into
every report bloats each gitignored output file but keeps it portable; a repo-local
asset keeps reports small but makes them non-portable (they break when moved out of
the repo). The §7.4 validation checkpoint and the "self-contained" framing assume
the portable resolution, but the spec has not committed to it. An implementer could
ship either and claim conformance. The human should resolve §9.4 before P5, because
it changes both the validation checkpoint's checks and the artefact's distribution
story.

## O7 — implementation — medium

### Claim

The empty-result contracts of the two models collide in pipeline mode and the spec
does not reconcile them. The pipeline template introduces an empty-task sentinel —
`stages: []` plus a `low`-confidence `scope_resolution`. But the shipped agent's
honesty rule explicitly forbids two empty collections and instead emits a literal
`(empty scope)` element. §4.3 says pipeline mode emits the map *alongside* the
`architectural[]` / `domain[]` collections. It is unspecified whether an empty task
yields an empty pipeline with a populated `(empty scope)` arch collection, an
empty everything, or some third shape — and which sentinel a downstream consumer
should match on.

### Evidence

Template validation: "**Empty-task sentinel.** A map whose `task` resolves to no
process emits an **empty `stages: []`** with a populated `scope_resolution` whose
`scope_confidence` is `low`." Agent Honesty rules: "do not return two empty
collections. Emit exactly one element under `architectural[]`: … name: '(empty
scope)'." §4.3: "the agent emits the `ConceptualPipelineMap` alongside the
`architectural[]` / `domain[]` collections it cross-checked against."

### Why this matters

Two sentinel disciplines (empty `stages: []` vs the `(empty scope)` element) now
coexist in one agent run, and the spec does not say which governs the bundle or
how the §6.2 scope-relevance loop interacts with a task that resolved to nothing.
A consumer (the §7.4 checkpoint, the render) that pattern-matches the wrong
sentinel mis-renders the degenerate case — and the degenerate case (task touches
nothing) is precisely where honest signalling matters most. The human should fix
the empty-task contract across all three collections at P1.

## O8 — specification quality — medium

### Claim

The backward-compatibility design for cross-check status is named but not
specified. §6.3 says "add a `pipeline_cross_check_status` rather than re-typing the
existing field." That sentence fixes a field name but leaves undefined: its legal
value set, whether absence means `not_run` (as the existing scalar does), and how
`/diagnose` — which reads only the scalar `cross_check_status` and has elaborate
gloss logic around it — behaves when a pipeline run populates the new field. A
backward-compat field with no value contract cannot be verified as backward-compatible.

### Evidence

§6.3: "**`cross_check_status` (backward-compat).** v0.5.0 consumers read a scalar.
Add a `pipeline_cross_check_status` rather than re-typing the existing field, so the
scalar reading stays valid." §9.3 still lists "the backward-compatible
three-collection `cross_check_status` shape" as open. The existing contract
(legibility-element.md) fixes `cross_check_status: completed | skipped_asymmetric |
not_run`, absence = `not_run`, and forbids inferring status from CC entries.

### Why this matters

The whole point of the backward-compat call is that v0.5.0 consumers keep working.
But "the scalar reading stays valid" only holds if the new field's semantics are
defined relative to the old — e.g. does `cross_check_status: completed` now mean
"two-way completed" or "three-way completed"? Does a three-way run leave the scalar
at `completed` (lying about scope) or `skipped_asymmetric`? Without that, P4 can
ship a field that technically preserves the scalar's *type* while silently changing
its *meaning*, which is the subtle compat break the call meant to avoid. The human
should specify the value enum and the scalar's meaning under three collections at
P4.

## O9 — scope — medium

### Claim

The change adds a new command (`/pipeline-map`), a new agent mode/behaviour, and a
new template, but the spec scopes docs-site work out as a "mechanical per-slice
follow-on." CLAUDE.md's Docs Site Review section requires a how-to guide when a
feature adds a new command and updates to reference pages when a format changes.
The `/diagnose` precedent ships with both a how-to and a reference page (its
"See also" links them). Omitting them here leaves the docs site inaccurate on the
day P5 ships.

### Evidence

§7.4 lists `/pipeline-map` joining the Output Validation Checkpoints, but §8 "Out
of scope" and the slicing record's "Explicitly not slicing on" treat docs as
mechanical follow-ons, not deliverables. `/diagnose` command "See also" links
`docs/plugins/diagnostic-legibility/how-to/run-the-diagnose-command.md` and
`docs/plugins/diagnostic-legibility/reference/diagnose-command.md`. CLAUDE.md Docs
Site Review: "When a feature adds a new command, skill, or agent: check for an
existing how-to guide and create one if missing … Include docs changes in the same
PR as the implementation, not as a follow-up."

### Why this matters

CLAUDE.md is explicit that docs ship in the same PR, not as a follow-up, and the
sibling command set the precedent. Treating the how-to and reference pages as
out-of-scope mechanics risks them being dropped, leaving the new command
undocumented relative to `/diagnose`. The human should decide whether the docs
pages are an explicit P5 deliverable rather than an unscheduled follow-on.

## O10 — alternatives — medium

### Claim

The spec fixes "third model, full treatment" — the pipeline gets the full build +
self-challenge + three-way cross-check cycle — as a non-negotiable input (§2.4),
and the resulting up-to-six-directed-pair cross-check is acknowledged as a
combinatorial-blow-up the design defers rather than bounds. A materially cheaper
alternative — projecting the flow as a *derived* view over the already-cross-checked
architectural and domain collections, with the pipeline's own challenge cover but
without a third full cross-check participant — is named only to be rejected, with no
cost comparison.

### Evidence

§2.4: "**Third model, full treatment.** The pipeline is a first-class
`LegibilityModel` collection … not a derived rendering that skips the
challenge/cross-check cycle." §6.3: "Which of the up-to-six pairs run is the core
P4 decision (blow-up control)." §9.3: "which of the up-to-six directed pairs run"
remains open.

### Why this matters

The full-treatment call is the single largest cost driver in the design (P3 trace +
P4 three-way cross-check are the two most expensive slices), and the spec carries
its hardest sub-decision (which of six pairs run) into the gates unresolved. Because
this is a fixed input (§2), the spec forecloses the cheaper alternative without
weighing it — which is exactly the spec-time moment to ask. If the human still wants
full treatment, the cost comparison should be on the record so the choice is
deliberate rather than inherited. (Routing note: this is raised as an alternative
because the unbounded six-pair expansion is a *cost/feasibility* failure shape, not
merely an unrecorded decision; if the human reads it as pure decision-archaeology it
belongs to the cartographer instead.)

## O11 — scope — medium

### Claim

The first human-visible deliverable is left undecided: P4-before-P5 (cross-corrected
map first), P5-before-P4 (visible map one slice sooner), or a standalone P2 "what
does my task touch?" surface ahead of the map. Until that is fixed, the spec has not
said which slice carries the burden of demonstrating the relevance bet (O1) is good
enough to build on — which is a scope decision (what is the minimum shippable proof),
not an implementation detail.

### Evidence

§9.5: "P4-before-P5 (first map already cross-corrected) vs. P5-before-P4 (visible map
one slice sooner); whether P2 ships a standalone 'what does my task touch?' surface
first." Slicing record Sequencing recommendation marks both ordering choices "open
for disposition."

### Why this matters

The ordering determines when a human first sees real output and can judge whether the
premise holds. If P5 comes last (after P4), the relevance bet (O1) is untested against
a real artefact until four slices are built; if P2 ships a standalone surface first,
the bet is testable after one slice. This is the cheapest lever on O1's risk, and it
is currently unowned. The human should fix the sequencing — and, ideally, pull the
earliest slice that makes the relevance bound human-inspectable.

## O12 — risk — medium

### Claim

The "static-first but (live)-titled" framing risks an artefact whose visual idiom
implies runtime truth it does not possess. The reference image the render mirrors is
titled "(live)" and annotates gates with `Actual: 0.82 (true)`; P6 (the overlay that
would make those real) is deferred; yet the P5 render reproduces the same three-line
nodes, gate conditions, and a legend with a P6-reserved executed/not-executed key. A
developer familiar with the reference image may read the static map's `condition`
values as observed runtime facts rather than conceptual rules.

### Evidence

§2.1: "the green-check / grey-circle (live) overlay and the `Actual: 0.82 (true)`
gate annotation become a later slice (P6)." §7.2: "live status (P6) … **seam only at
P5**." §7.3 legend: "(and, reserved for P6, the executed/not-executed key)." Template
`condition`: "A conceptual rule, *not* a runtime value — the actual evaluated result
is live data and is not part of this static model."

### Why this matters

The model is careful that `condition` is conceptual, but the render deliberately
mirrors a "(live)" reference image and reserves live-status legend slots — so the
visual surface leans toward a runtime reading the data cannot support. The honesty
discipline the whole capability advertises (disclose the bound, never present a
silent boundary) applies equally to "never imply runtime truth the static map does
not have." The human should decide whether the P5 render must visibly mark itself
static (e.g. an explicit "structural, not executed" banner) so the deferred-overlay
seam does not read as a present-but-empty live view.

## Explicitly not objecting to

- **The decision to make `/pipeline-map` a new command rather than a flag on
  `/diagnose`**: the inverted scoping direction (task-derived vs human-supplied) is a
  genuinely different contract, and a separate command is consistent with the
  `/diagnose` single-verb precedent — this is a sound, well-justified call.
- **The read-only trust boundary staying `Read`/`Glob`/`Grep`**: the spec correctly
  observes that resolving scope is "more reading, not more capability," and keeping the
  agent-emit + dispatcher-persist + human-disposes architecture is exactly right; no
  failure class hides here.
- **The choice to record `realises` links by element name rather than by id**:
  name-based cross-references keep the map valid standalone and avoid embedding the
  legibility collections, which is consistent with the decoupling goal; whether
  `realises` lives on the stage vs is reconstructed at cross-check time is a recorded
  open question with no failure shape, so it belongs to the cartographer, not here.
- **The deferral of change-site prediction (§3.3)**: distinguishing "what my task
  touches" from "which node I will edit" is a clean scope line with its own honesty
  burden, explicitly recorded as a follow-on — deferring it is a reasonable boundary,
  not an omission.
- **The `part_of` structural sub-step grouping over dotted-id encoding**: expressing
  hierarchy structurally and deriving `5A.1`-style numbering at render time is the one
  place the decoupling claim clearly *does* hold, and it is the right call.
