---
spec: docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md
date: 2026-06-03
mode: spec
cartographer_model: claude-opus-4-8[1m]
stories:
  - id: 1
    lens: [patterns, alternatives]
    title: Standalone model over a third LegibilityModel collection
    disposition: accepted
    disposition_rationale: "Accepted. The standalone-model-over-third-collection choice is sound and deliberate: it is the structural mechanism that makes the decoupling (#2) enforceable rather than aspirational. Recorded so a future refactor that folds the map back into LegibilityModel knows it reverses a deliberate contamination-resistance choice whose reversal cost compounds per slice that has consumed the standalone contract."
  - id: 2
    lens: [patterns, coherence]
    title: A conceptual control-flow ontology, named as principle
    disposition: promoted
    disposition_rationale: "Promoted to AGENTS.md ARCH_DECISIONS as 'Model what the artefact IS; decline only how it is SHOWN.' A model commits to its conceptual ontology (for the pipeline: stages, transitions, decisions, outcomes — so kind: decision is conceptual; the diamond is the renderer's) and is agnostic only about presentation and producer, never structure-free. Conceptual sibling of the promoted granularity-routing rule; governs future 'is this field conceptual or presentational?' calls plugin-wide. Promotion moves the principle off §4.1 prose (where pruning would reopen O2's 'implementation-agnostic' over-claim) into governing architecture. Watch item carried in the entry: it currently ships a single-dominant-pipeline ontology that will not fit concurrent / multi-entrant flow — revisit when such a process is modelled."
  - id: 3
    lens: [forces, coherence]
    title: Scope inverted — agent derives, human no longer supplies
    disposition: promoted
    disposition_rationale: "Promoted to AGENTS.md ARCH_DECISIONS as the disclosure-of-derived-judgment rule: when an agent DERIVES what a human previously supplied (here, scope from a task), it carries a disclosure obligation the supplied-input case never had — it must record what it included, what it consciously excluded, and its confidence (with failure direction when below high), and never present a silent boundary as fact. A reusable governance principle beyond this feature; the inverted-scope contract is its first instance. Recorded so future 'let the agent infer X' features inherit the obligation rather than re-deriving it. Pairs with #4 (the new judgment lives in this disclosure contract, not the unchanged tool boundary)."
  - id: 4
    lens: [defaults, consequences]
    title: Read-only boundary absorbs a genuinely new capability
    disposition: accepted
    disposition_rationale: "Accepted. The 'least privilege held constant under feature growth' framing is correct: the new relevance-scoping capability is genuinely read-shaped, so no new tool is warranted and the agent-emit minimum-trust architecture stays intact. Watch item recorded: 'same tools' understates 'new judgment' — the agent now makes a prediction (the derived bound) the trust surface does not signal; the disclosure contract (#3, now promoted), not the tool boundary, is where that new responsibility lives. A future trust-surface audit should read the disclosure obligation, not just the tool list."
  - id: 5
    lens: [patterns, forces]
    title: Sequence the risky slice first as risk management
    disposition: promoted
    disposition_rationale: "Promoted to AGENTS.md ARCH_DECISIONS as risk-first slice sequencing, complementing carpaccio: order slices by uncertainty reduction, not just dependency, and make the load-bearing bet human-inspectable in its cheapest observable form as early as possible (here, P2's standalone 'what does my task touch?' surface ships first, ahead of the headline map, with a hand-validation acceptance gate). Walking-skeleton inverted: the thinnest HIGHEST-RISK slice, not just the thinnest end-to-end one. The carpaccio decomposition gains an explicit risk-ordering criterion. Descends from the O1 + O11 joint resolution."
  - id: 6
    lens: [alternatives, consequences]
    title: Maximal six-pair cross-check over cheaper projection
    disposition: revisit
    disposition_rationale: "Revisit. The maximal six-pair cross-check is a defensible deliberate choice (maximal mutual correction; cost weighed and recorded; bounded at six), but it is the feature's largest cost driver chosen as a fixed input against the project's usual YAGNI posture. Flagged for falsification: instrument which directed pairs actually fire corrections on real invocations and trim any pair that never does — the same falsify-and-trim treatment S3 Story #5 gave direction-flavoured weighting. Reopen when invocation data exists; trimming would reverse a deliberately-maximal call, not fill a gap."
  - id: 7
    lens: [patterns, consequences]
    title: realises couples the map by name, not by id
    disposition: accepted
    disposition_rationale: "Accepted. Name-based realises keeps the map valid standalone — the property #1 exists to protect — and the soft cross-reference is reconciled by the P4 cross-check rather than enforced by schema. The on-stage-vs-reconstructed-from-evidence question stays open for per-slice specs (§9.2). Recorded residue: the model uses id-stability internally and name-stability across its boundary — a coherent split a future reader should know is deliberate, so a renamed element silently orphaning realises links is an understood trade, not a bug."
  - id: 8
    lens: [forces, patterns]
    title: --near biases but does not bound the search
    disposition: accepted
    disposition_rationale: "Accepted. The biases-not-bounds resolution (O3) is the right shape: the optional hint can accelerate but cannot silently cause a wrong answer, and the agent's derived bound wins ties with disclosure. Recorded that the hard-bound use case ('only look here, the rest is irrelevant') is deliberately foreclosed to close the footgun; if a concrete consumer ever needs a hard bound it returns as a separate explicit flag rather than overloading --near. An instance of the now-promoted #3 disclosure rule applied to an optional input."
  - id: 9
    lens: [patterns, coherence]
    title: Two empty-sentinels coexist, partitioned by collection
    disposition: accepted
    disposition_rationale: "Accepted. Partition-over-unification of the two empty-sentinels is an instance of the already-promoted granularity-routing discipline (the empty signal lives at the granularity of the thing that is empty) plus the additive-compat habit (extend by partition; never re-type the shipped (empty scope) contract). Not a fresh principle — a clean application of two existing ones — so accepted rather than promoted. The don't-cross-match consumer rule (match map-empty on stages==[], legibility-empty on the (empty scope) element, never one on the other) is the load-bearing detail recorded for implementers."
  - id: 10
    lens: [consequences, defaults]
    title: Vendored Mermaid breaks then re-floors the no-JS norm
    disposition: promoted
    disposition_rationale: "Promoted to AGENTS.md ARCH_DECISIONS as the scoped-norm-exception rule: when a surface must break a project norm, split the norm into its independent guarantees and preserve every guarantee you can — break only the part you genuinely must. The vendored-Mermaid case is the worked precedent: the self-contained / no-JS norm split into 'no external deps' (kept via vendor+inline) and 'readable without JS' (restored via the <noscript> outline floor), with only the enhanced Mermaid layer requiring JS. Future surfaces inherit a worked split-the-guarantees precedent rather than a blanket licence to break the norm wholesale. Descends from O5 + O6 jointly."
---

## Story #1 — Standalone model over a third LegibilityModel collection

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§4, §4.2; template "Why its own model")
**Lens:** patterns, alternatives
**Refs:** O2

**Context.** The shipped plugin holds two flat enumerations (`architectural[]`, `domain[]`) on one `LegibilityModel` wrapper. The obvious extension — and the one the earlier draft took — is a third collection (`pipeline`) bolted onto the same wrapper. The spec instead defines `ConceptualPipelineMap` as a *standalone model in its own template*, cross-referencing the legibility models by name rather than living inside them. This is the load-bearing architectural pivot of P1, and the spec argues it as a one-way forcing function rather than a symmetry choice.

**Forces.** Symmetry and reuse (a third collection inherits the wrapper, the `confidence`/`challenge_notes[]` discipline, and the cross-check machinery for free) versus contamination resistance (a collection on the existing wrapper would "accrete whatever the first renderer needed" — a `kind` that means "draw a diamond", an `id` that encodes a display number). The spec resolves toward isolation: a standalone model forces every field to justify itself as *conceptual* rather than presentational, and the cost is that the pipeline cannot free-ride on the wrapper's existing affordances — it must restate `confidence`, `challenge_notes[]`, and an empty-sentinel discipline of its own (#9).

**Options not taken.**

- A third `pipeline[]` collection on `LegibilityModel` (the earlier draft). Maximal reuse; the spec rejects it precisely because the reuse is what lets display concerns leak in.
- A pipeline as a *derived projection* over the cross-checked arch/domain collections, with no standalone schema at all. The cheaper-still alternative the spec weighs and rejects in §2.4 (see #6) — it would have avoided a new model entirely.
- A standalone model that still imports `LegibilityElement` as its stage type. Rejected implicitly: the stage needs `kind`/`condition`/`part_of`/`realises` that `LegibilityElement` does not carry, so a shared element type would have bloated both.

**Choice as written.** A separate template, separate top-level type, name-based `realises` cross-references, and an explicit "does not contain, references" relationship to `LegibilityModel` (§4.3). The spec frames the standalone choice as the *mechanism* that makes the decoupling claim (#2) enforceable, not merely as a filing decision.

**Consequences.** The decoupling is now structural, not aspirational — but the schema discipline the project promoted on S3 (granularity-routing: per-element facts on the row, model-level facts on the table; the additive-wrapper-field rule) does not automatically govern a model that lives outside `LegibilityModel`. Future schema evolution on the map cannot lean on those promoted rules by inheritance; it must re-derive them. The choice is reversible-in-principle (a future refactor could fold the map back in) but every later slice consumes the standalone contract, so the reversal cost compounds per slice shipped.

**Pattern.** **Separated interface / standalone aggregate** (Fowler) — the map is its own aggregate root rather than a member of an existing one, chosen so the aggregate's invariants (conceptual-only) cannot be diluted by a host's affordances. Kin to the **anti-corruption layer** stance: the standalone boundary exists specifically to keep renderer-shaped concepts from corrupting a conceptual model.

**Notes.** The diaboli's O2 was about whether the decoupling *claim* holds; this story is about the structural choice (standalone vs collection) that the claim is the justification for. #2 carries the claim itself.

---

## Story #2 — A conceptual control-flow ontology, named as principle

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§4.1; template "What the model is *not* agnostic about")
**Lens:** patterns, coherence
**Refs:** O2, #1

**Context.** O2 forced the spec to narrow "implementation-agnostic" to "presentation- and producer-agnostic" and to own, explicitly, that the model is **not structure-free** — it embeds a *conceptual control-flow ontology* (stages, transitions, decisions, outcomes). `kind: decision` is a conceptual property ("this stage branches"); only the diamond is the renderer's. That reframing is now a *named principle* in both the spec and the template. The choice the cartographer marks is not the reframing (O2 owns that) but the decision to elevate it to a stated stance the whole model is justified against — and to leave its promotion status unaddressed.

**Forces.** Honesty about what the model commits to (a traced process genuinely *has* order and decision points independent of drawing) versus the seductive over-claim that a "pure" model carries no structure at all. The deeper, unstated force: a control-flow ontology is a *theory of what a process is*, and the spec adopts one (entry → stages → decisions/outcomes, one dominant path) without naming it as one theory among several. The single-dominant-pipeline restriction (§6.1, §8) is part of that ontology — a process with genuinely concurrent or multiply-entrant flow does not fit, and that is an ontological commitment, not just a scope cut.

**Options not taken.**

- Keep "implementation-agnostic" and treat `kind`/`condition` as derivable hints. The over-claim O2 killed; it invited a future producer to assume the model carried no tracing commitments.
- A structure-free model (bag of stages + freeform edges) with the renderer inferring decisions. Pushes the ontology into the renderer, where every renderer would re-derive it differently — the opposite of the decoupling goal.
- A richer ontology (concurrency, fan-out, re-entrancy) admitted now. Rejected by the one-dominant-pipeline cut; the spec picks the smallest honest ontology.

**Choice as written.** The model owns a minimal control-flow ontology explicitly and declines only presentation. The principle — *commit to what the process is, decline only how it looks* — is stated as a reusable stance, mirroring the project's habit of naming a discipline rather than leaving it as folklore (cf. S3 Story #4's granularity-routing).

**Consequences.** This is a candidate for promotion to an AGENTS.md ARCH_DECISION ("model what the artefact *is*, decline only how it is *shown*") — it is the conceptual sibling of the promoted granularity-routing rule and would govern future "is this field conceptual or presentational?" calls across the plugin. Left un-promoted, the principle is load-bearing on §4.1's prose alone; if that prose is pruned, the next schema edit re-opens the "implementation-agnostic" over-claim O2 already closed once. Whether the single-dominant-pipeline ontology survives contact with real multi-path processes is a question this story foreshadows but does not raise as a failure.

**Pattern.** **Ubiquitous language / domain model** (Evans) — the model is a deliberate ontology, not a neutral container. The "decline only presentation" half is the **presentation–domain separation** (kin to MVC's model/view split) stated as a model-design invariant rather than a UI one.

**Notes.** Promotion-worthiness is the live question for the human: this is a principle the spec *states* but does not *promote*; #1 is the structural decision it justifies.

---

## Story #3 — Scope inverted — agent derives, human no longer supplies

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§1, §3.1)
**Lens:** forces, coherence
**Refs:** O1

**Context.** Every shipped surface in the plugin takes scope as ground truth handed in by the human (`/diagnose <scope>`). S4 Story #5 recorded that `/diagnose` delegates the *whole* scope contract to the agent precisely because scope was never the agent's to invent. This capability inverts that: the developer states a *task*, and the agent **derives** the bound. The spec calls this out as "the heart of the revision" (§3) — but the deeper choice is silent: it relocates the locus of a *judgment* from the human to the agent, which is a different move from relocating *work*.

**Forces.** Ergonomics of intent ("state what you're about to do, not where the code is" is closer to how a developer thinks) versus epistemic safety (a human-supplied scope is ground truth that cannot be wrong; a derived scope is a *prediction* that can under- or over-reach). The shipped plugin had no boundary risk because the human owned the boundary; this capability manufactures a boundary risk that did not exist, and pays for it with an "honesty obligation the shipped plugin never had" (disclosure via `scope_resolution`). The spec names the obligation but treats the *relocation of judgment* as obvious rather than as the decision it is.

**Options not taken.**

- Keep the human-supplies-scope contract and add only the flow perspective (a pipeline map over a handed-in scope). Preserves ground-truth scope; loses the "limited to what my task touches" value proposition that motivates the whole capability.
- Two-step: agent *proposes* a scope, human *confirms* it before tracing. Keeps a human in the boundary loop; rejected implicitly by the one-shot stateless contract inherited from `/diagnose` (§8).
- Derive scope but present it as fact (no disclosure). The exact honesty failure §3.1 forbids — disclosure is the mitigation that makes the inverted contract honest.

**Choice as written.** The agent resolves task → bounded slice and *discloses* the bound (`in_scope`, `adjacent_excluded`, `scope_confidence`, and a failure direction when confidence < high). Disclosure keeps a bad bound honest; the early standalone surface (#5) keeps it inspectable. The human's role shifts from *supplying* the boundary to *auditing* a supplied one.

**Consequences.** The capability's headline value now rests entirely on a prediction the plugin never had to make before — the load-bearing bet the diaboli's O1 flagged. Disclosure makes the bet honest but not *useful*; that gap is what #5's sequencing is designed to test. The inversion also forecloses (for this command) the clean ground-truth property: no consumer of the map can assume the scope is correct, only that it is disclosed. This coheres with the plugin's honesty discipline but breaks the "scope is ground truth" assumption every prior slice relied on — a coherence shift across the plugin, not just within this spec.

**Pattern.** **Inversion of control** applied to the scope contract — the caller states intent and the system resolves the binding, rather than the caller supplying the binding. Kin to **declarative-over-imperative**: the developer declares the goal (the task) and the agent computes the means (the slice). The disclosure obligation is **honest-by-construction** provenance.

**Notes.** This is the silent parent decision under O1: O1 asks "is the bet validated?"; this story marks "the spec chose to make a bet at all, by inverting who owns the boundary."

---

## Story #4 — Read-only boundary absorbs a genuinely new capability

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§5 preamble; diaboli "explicitly not objecting to")
**Lens:** defaults, consequences
**Refs:** O1, #3

**Context.** Relevance scoping (task → bounded slice) is named throughout as the *new analytical capability* this feature adds — "does not exist anywhere in the shipped plugin" (§1). Yet the spec keeps the agent's trust boundary unchanged (`Read`, `Glob`, `Grep`) with a single sentence: "resolving scope is **more reading, not more capability**." The diaboli explicitly declined to object ("no failure class hides here"), routing the decision here. The choice the cartographer marks is the *framing move* that lets a genuinely new capability slip in under an unchanged trust surface.

**Forces.** Minimum-trust-surface (the promoted agent-emit + dispatcher-persist pattern wants the smallest possible tool boundary) versus honest accounting of what the agent now *does* (it now exercises judgment about relevance, not just retrieval). The spec resolves by reframing capability as *reading*: globbing for a task's nouns and bounding the result is, mechanically, file reads — so no new tool is needed. The reframe is correct at the tool level and load-bearing at the trust level, but it quietly equates "no new *tool*" with "no new *capability*", which are not the same claim.

**Options not taken.**

- Grant a richer tool (e.g. a code-index or AST tool) for relevance scoping. Would have expanded the trust surface and broken the agent-emit pattern's minimum-trust half for a convenience the spec shows is unnecessary.
- Treat relevance scoping as a separate, more-trusted agent mode. Fragments the agent and contradicts the "one agent, mode-weighted" precedent (AGENTS.md).
- Acknowledge relevance as new *capability* while keeping the tools — i.e. say "same tools, new judgment." The honest framing the spec gestures at but compresses into "more reading."

**Choice as written.** The boundary stays `Read`/`Glob`/`Grep`; the new capability is absorbed as "more reading." The spec keeps the promoted trust architecture intact and pays nothing at the tool layer — correctly, because the new work *is* read-shaped.

**Consequences.** The agent now makes a *prediction* (the bound, #3) within an unchanged read-only surface — which is exactly right for trust but means the boundary no longer signals the agent's true responsibility. A future reader auditing the trust surface sees the same three tools as `/diagnose` and may not realise the pipeline agent shoulders a judgment `/diagnose` never made. No failure is undetected (the diaboli confirmed this), so it routes here: the residue is that "same tools" understates "new judgment", and the disclosure contract (#3), not the tool boundary, is where the new responsibility actually lives.

**Pattern.** **Capability vs authority** distinction — the spec correctly separates *what the agent is trusted to touch* (unchanged) from *what it is asked to decide* (new). The reframe is an instance of **least privilege held constant under feature growth**: prove the new feature needs no new privilege rather than granting privilege defensively.

**Notes.** Pairs with #3 — #3 marks the inversion of *who owns the boundary*; this marks that the inversion required no new *tool*, only new *judgment*, and that the spec's one-liner compresses the two.

---

## Story #5 — Sequence the risky slice first as risk management

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§3.1, §9.1; slicing record "Sequencing recommendation")
**Lens:** patterns, forces
**Refs:** O1, O11, #3

**Context.** O1 named the relevance bound the load-bearing bet; O11 named the headline-slice sequencing undecided. The joint resolution: the standalone "what does my task touch?" surface — a minimal render of `scope_resolution`, **no map** — ships as the *first human-visible slice* (P2), ahead of any flow tracing or rendering, and carries an explicit hand-validation acceptance step. The choice the cartographer marks is the *sequencing-as-risk-management pattern*: the slice order is deliberately arranged so the riskiest premise becomes inspectable after one slice rather than four.

**Forces.** Dependency-order convenience (P1 schema → P2 scope → P3 trace → P4 cross-check → P5 render is also the natural build order) versus risk-order discipline (build the thing most likely to be wrong *first*, in its cheapest observable form, so a bad premise is caught before four slices rest on it). The spec resolves so the two orders happen to coincide — but the *reason* P2 ships a standalone surface (rather than waiting to be visible inside P5's map) is risk, not dependency. The unspoken force: a derived bound (#3) can be technically complete and useless, and only a human looking at real disclosures on real tasks can tell.

**Options not taken.**

- P5-before-P4 (visible map one slice sooner) — the alternative O11 weighed and the spec rejects, because the standalone P2 surface already supplies the early human feedback that motivated pulling P5 forward.
- Ship P2 only as provenance consumed by later slices (no standalone surface). The bet stays invisible until P5; O1's risk is untested for four slices.
- A spike/throwaway relevance prototype outside the slice chain. Tests the bet but produces no shippable increment and no disposition record.

**Choice as written.** P2 ships a real, minimal, human-visible surface rendering `scope_resolution` alone, first in the chain, with a hand-validation acceptance gate before P3 builds on the bound. The riskiest decision is made the earliest *observable* one.

**Consequences.** The relevance bet is inspectable for *usefulness* (not just honesty) after one slice — the cheapest available lever on O1. The cost: P2 must carry render/surface work it would not need if it were pure provenance, and the acceptance step injects a human-judgment gate into the slice chain that can stall progression if the bound proves unhelpful. That stall is the *point* (friction where slowing down compounds), not a defect — but it means P2's "done" is contingent on a usefulness judgment, not just a structural test, unlike the other slices.

**Pattern.** **Risk-first / worst-things-first sequencing** (Cockburn; cf. the "spike the riskiest assumption" lean stance) — order work by uncertainty reduction, not just by dependency. Kin to **walking-skeleton** inverted: instead of the thinnest end-to-end slice, ship the thinnest *highest-risk* slice. The hand-validation gate is **acceptance-test-driven** premise validation.

**Notes.** Descends from O1 + O11 jointly; #3 is the bet this sequencing exists to de-risk.

---

## Story #6 — Maximal six-pair cross-check over cheaper projection

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§2.4, §6.3)
**Lens:** alternatives, consequences
**Refs:** O10, #1

**Context.** Adding a third collection to a cross-check that handled two (A↔D) opens up to six directed pairs. O10 pushed the spec to weigh the cheaper alternative — a *derived projection* of the flow over the already-cross-checked arch/domain collections, with no third cross-check participant. The spec chose the **maximal** cover deliberately: all six directed pairs run (`A↔D` plus `P→A`, `A→P`, `P→D`, `D→P`), the combinatorial token cost accepted as "the price of maximal mutual correction." The choice the cartographer marks is the deliberate selection of the *most expensive* correct option with the cost on the record.

**Forces.** Maximal mutual correction (the pipeline's `condition`/`realises` claims are exactly what the other two models can refute, and a derived projection would never be challenged *back*) versus cost containment (six directed pairs is the largest single token driver in the feature, and P3+P4 are the two most expensive slices). The spec resolves entirely toward correction depth and names the cost as accepted rather than minimised — the inverse of the project's usual YAGNI-with-named-consumer posture (S3 Story #2, S4 Story #3).

**Options not taken.**

- Derived projection (pipeline as a view over cross-checked arch/domain; no third participant). The cheaper alternative O10 named; rejected because the flow's own claims would never be refuted.
- A subset of pairs (e.g. pipeline as *subject* only, never *challenger* — `A→P`, `D→P` but not `P→A`, `P→D`). Halves the cost; the spec rejects it because a stage's claims about architectural boundaries and domain concepts are the highest-value refutations.
- Pipeline self-challenge (Phase B) only, no cross-check. The map is internally consistent but never reconciled against the other two models.

**Choice as written.** All six directed pairs run, with direction-flavoured weighting per pair, the subject-only audit trail (S3 Story #3) extended to three collections, and the cost weighed-and-recorded so the maximal choice is deliberate rather than inherited.

**Consequences.** The map is maximally cross-corrected, but the feature now carries its largest cost driver as a *fixed* input rather than a tunable — and the project has, for once, chosen maximalism over YAGNI, with the justification being correction quality rather than a named consumer. If real invocations show some directed pairs never fire a correction, the six-pair cover becomes a candidate for the same falsification-and-trim treatment S3 Story #5 gave direction-flavoured weighting — but trimming would reverse a deliberately-maximal call, not fill a gap. The combinatorial cost is bounded at six (two-then-three collections), not open-ended, so the blow-up O10 feared is capped, not unbounded.

**Pattern.** **N×N mutual validation / redundant cross-check** chosen over **derived view** — the opposite of the projection (single-source-of-truth) pattern, justified when each participant can refute the others. The cost-weighed-and-recorded discipline is **deliberate-over-inherited decision capture** (the ADR impulse applied to a fixed input).

**Notes.** O10 routed the cost/feasibility angle; this story records the *alternatives* angle (maximal vs projection) as a deliberate, reversible-by-falsification choice. #1 is the standalone-model decision that makes a third *full* cross-check participant possible at all.

---

## Story #7 — realises couples the map by name, not by id

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§4.3; template `realises`, "Why its own model")
**Lens:** patterns, consequences
**Refs:** #1

**Context.** A stage may cross-reference the architectural element and/or domain concept it `realises`. The spec couples this **by element *name***, not by a stable id: `realises: { architectural?: <element name>, domain?: <concept name> }`. The diaboli explicitly did not object (name-based references keep the map valid standalone), routing the choice here. The cartographer's mark: the spec uses *opaque stable ids* internally (stages reference each other by `id`, explicitly not by display number) but *human-readable names* for the cross-model seam — two different coupling disciplines in one model, chosen for different reasons.

**Forces.** Standalone validity (the map must be readable and valid without the legibility collections present — a name is self-describing; a foreign id is a dangling pointer) versus referential integrity (a name is a soft link that breaks silently when the referenced element is renamed, where an id could be validated). The spec resolves toward standalone validity and self-description, accepting that `realises` is a *soft* cross-reference the cross-check (P4) reconciles rather than the schema enforces. Internally, the same spec chose the *opposite* — opaque ids over names — precisely because internal references must be stable across renames for the live-overlay seam.

**Options not taken.**

- `realises` by element id. Referentially checkable; but ids into a separately-persisted collection are dangling pointers when the map is read alone — breaking the standalone-validity property #1 exists to protect.
- `realises` reconstructed at cross-check time from shared `evidence.path` overlap, not stored on the stage at all. The recorded open question (§4.3, §9.2); avoids the coupling entirely but loses the producer's explicit intent.
- Embed the referenced element inline. Contains rather than references — exactly what #1 rejects.

**Choice as written.** Name-based, on-stage `realises` links, soft and self-describing, reconciled by cross-check rather than enforced by schema. Whether the link lives on the stage or is reconstructed from shared evidence is left open for per-slice specs (§9.2).

**Consequences.** The map stays valid standalone (the win) at the cost of a cross-reference that no validator can check — a renamed architectural element silently orphans every `realises` pointing at its old name, and only the P4 cross-check (or a human) would notice. The map thus uses *id-stability* where it controls both ends (internal references) and *name-stability* where it does not (the cross-model seam) — a coherent split, but one that means the model's referential guarantees are stronger inside than across its boundary. The on-stage-vs-reconstructed question is still open, so this coupling may yet be removed in favour of evidence-overlap inference.

**Pattern.** **Soft reference / reference-by-value** at an aggregate boundary (Evans/Vernon: aggregates reference other aggregates by identity, and a human-readable name *is* the identity here) versus **hard pointer** internally. Kin to the **late-binding cross-reference** — the link is resolved at cross-check time, not at model-construction time.

**Notes.** The diaboli routed this here as "a recorded choice with no failure shape." The cartographer's distinct contribution: naming that the spec uses *two* coupling disciplines (id inside, name across) for principled but unstated reasons.

---

## Story #8 — --near biases but does not bound the search

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§5 step 2, §7.1)
**Lens:** forces, patterns
**Refs:** O3, #3

**Context.** O3 caught `--near` specified contradictorily (bound vs bias). The resolution: `--near` **biases, does not bound** — a strong starting prior the agent may resolve *outside*, recording any out-of-hint inclusion and its reason. The choice the cartographer marks is the *resolution shape*: the spec picks the reading that makes the optional hint unable to silently cause a wrong answer, subordinating the hint to the agent's derived judgment (#3) rather than letting the human's guess override it.

**Forces.** Cost/relevance benefit of a starting point (a developer who knows roughly where to look saves the agent a blind search) versus the wrong-guess footgun (a developer who narrows to the *wrong* module would, under "bound", silently exclude the real process and get a confidently-wrong bound). The spec resolves so the hint can only ever *help and be overridden*, never *constrain and mislead* — which subordinates a human-supplied input to the agent's derived scope, the same locus-of-judgment shift #3 makes for scope itself.

**Options not taken.**

- `--near` as a hard bound (the contradictory reading O3 killed). Cheapest search; turns an optional convenience into a correctness footgun.
- No hint at all (always blind search). Removes the footgun but loses the cost lever the flag exists to provide.
- A two-tier flag (`--near` soft, `--only` hard) exposing both semantics. Doubles the surface for a hard-bound mode no consumer asked for — the named-consumer YAGNI the project repeatedly declines (S3 Story #2).

**Choice as written.** One semantics: bias, with mandatory disclosure when the agent resolves outside the hint. The optional input can accelerate but cannot silently constrain; the agent's derived bound (#3) wins ties, and the override is recorded in `scope_resolution`.

**Consequences.** The flag is now incapable of the silent-wrong-answer failure, at the cost that a developer who *wants* a hard bound (e.g. "only look in this module, I know the rest is irrelevant") cannot express it — the spec foreclosed the hard-bound use case to close the footgun. This coheres with the disclosure-everywhere discipline (an overridden hint is disclosed like any boundary judgment) and with #3's "agent owns the derived boundary" stance: even an explicit human hint does not override the agent's honest resolution, only seeds it.

**Pattern.** **Hint / advisory parameter** (soft constraint) over **hard precondition** — the optional input is a prior, not a contract. Kin to the **tolerant-reader** posture applied to an interactive flag: accept the hint as guidance, never as a binding the system must honour against its own evidence.

**Notes.** Descends from O3's resolution; pairs with #3 — the same "agent's derived judgment outranks supplied scope input" stance, here applied to the optional hint rather than the primary contract.

---

## Story #9 — Two empty-sentinels coexist, partitioned by collection

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§4.3; template "Coexistence with the `(empty scope)` sentinel")
**Lens:** patterns, coherence
**Refs:** O7, #1

**Context.** O7 caught a collision: the map's empty-task sentinel (`stages: []` + a low-confidence `scope_resolution`) versus the shipped `(empty scope)` element sentinel governing `architectural[]`/`domain[]`. Because pipeline mode emits all three collections together, the spec had to say which discipline governs. The resolution: the two sentinels **coexist, each governing a different collection**, and may co-occur. The choice the cartographer marks is *partition over unification* — the spec keeps two distinct degenerate-output idioms rather than reconciling them into one.

**Forces.** Backward compatibility (the shipped `(empty scope)` rule and its consumers must keep working unchanged — the same compat constraint that shaped `cross_check_status`, S3 Story #1) versus single-idiom simplicity (one degenerate-output convention across all three collections would be easier to consume). The spec resolves toward partition: the new sentinel is necessarily *shaped differently* (a map's emptiness is `stages == []` plus a populated scope disclosure; a collection's emptiness is a literal sentinel element), so unifying them would distort one. The consequence is a consumer rule that is explicitly *don't-cross-match*: match the map's empty state on `stages == []`, the legibility empty state on the `(empty scope)` element, never one rule on the other collection.

**Options not taken.**

- One unified empty-result sentinel across all three collections. Cleaner to consume; impossible without re-typing the shipped `(empty scope)` discipline and breaking its consumers.
- A model-level "empty run" flag covering the whole bundle. A wrapper field (the granularity-routing move, S3 Story #1) — but the map and the legibility collections can be empty *independently*, so a single flag would lose which collection is empty.
- Forbid co-occurrence (an empty task implies empty everything). Over-couples: a task can touch no *process* while still surfacing parts/concepts, or vice versa.

**Choice as written.** Two sentinels, two collections, may co-occur, with an explicit partitioned matching rule and a short-circuit (§6.2's scope-relevance loop stops on an empty-task map — no flow to re-test). Each degenerate idiom governs exactly its own collection.

**Consequences.** Backward compatibility is preserved exactly (a v0.5.0 consumer reading `(empty scope)` is untouched), at the cost that a consumer of the *bundle* must now know two sentinel idioms and the rule that they never cross-apply. The degenerate case — task touches nothing — is precisely where honest signalling matters most, and the partition keeps each signal in its native shape rather than forcing a lowest-common-denominator one. Coheres with #1 (a standalone model carries its own empty discipline) and with the project's additive-compat habit (S3 Story #1): extend by partition, never by re-typing an existing contract.

**Pattern.** **Null Object / sentinel** (Woolf) applied per-collection rather than globally — two sentinels partitioned by the aggregate each describes, the granularity-routing discipline (S3 Story #4) applied to *degenerate-output* signalling: the empty signal lives at the granularity of the thing that is empty.

**Notes.** Descends from O7's resolution. The cartographer's mark is the design *posture* (partition over unification, granularity-routed sentinels) that the resolution is an instance of — a posture the project has now reached for repeatedly.

---

## Story #10 — Vendored Mermaid breaks then re-floors the no-JS norm

**Source:** `docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md` (§2.2, §7.3)
**Lens:** consequences, defaults
**Refs:** O5, O6

**Context.** The repo's HTML norm (portfolio-dashboard) is "readable without JavaScript; no external deps." A branching flow graph needs a real layout engine, so the spec takes a *deliberate, scoped exception*: a vendored, version-pinned, inlined Mermaid bundle. O5 then forced a `<noscript>` plain-text-outline fallback, and O6 forced the bundle inlined (not a repo-local asset) for portability. The choice the cartographer marks is the shape of the exception: the spec breaks one half of the norm (JS-required for the *enhanced* view) while re-flooring the other half (the outline is the readable floor; the inlined bundle keeps "no external deps").

**Forces.** Fidelity of the artefact (a branching pipeline genuinely needs a layout engine; a hand-laid-out diagram would be unmaintainable) versus the inherited self-contained-no-JS norm (a default the project holds precisely so its outputs survive script-stripping clients, PDF export, and JS-disabled readers). The spec resolves by *splitting the norm into its two independent guarantees* — "no external deps" (kept, via vendoring+inlining) and "readable without JS" (restored, via the `<noscript>` outline) — and breaking neither outright. The Mermaid view becomes the *enhancement*; the outline becomes the *floor*. The inherited norm is not the team's original call (it came from portfolio-dashboard), so honouring it here is a choice to keep faith with a default rather than to override it for convenience.

**Options not taken.**

- CDN-linked Mermaid. Smallest files; breaks "no external deps" and adds a supply-chain/availability dependency the repo's vendoring culture forbids.
- Repo-local shared Mermaid asset. Keeps files small; breaks portability — a report moved out of the repo blanks. O6 rejected it for inlining.
- Server-side / build-time SVG snapshot instead of client-side Mermaid. A static SVG floor with no JS at all; heavier render toolchain, and the spec's renderer is a text-emitting agent, not an image pipeline.
- Accept the JS-required blank for no-JS readers. The O5 failure shape; rejected.

**Choice as written.** Vendored + version-pinned + inlined Mermaid as the enhanced view, with a `<noscript>` indented-outline projection (the same model the renderer already projects from) as the readable floor, plus a "structural — not executed" banner (O12) so the static map is not misread as live. The per-file size cost of inlining is accepted as the price of portability.

**Consequences.** The artefact degrades rather than blanks (O5) and is genuinely portable (O6), at the cost that every report carries an inlined ~MB bundle — a size tax accepted because the output dir is gitignored. The exception is now *scoped and floored*: it does not erode the norm for other surfaces, because the norm was split into its two guarantees and only the "enhanced" layer relies on JS. A future surface tempted to take the same exception inherits a worked precedent (split the guarantees, floor the no-JS path) rather than a blanket licence to require JS.

**Pattern.** **Progressive enhancement** (Champeon) — the outline is the baseline content, Mermaid is the enhancement layer, exactly the portfolio-dashboard norm's own stated intent restored. The vendoring+inlining is **dependency-internalisation** (vendor over CDN) for supply-chain and portability control; the banner is the same **honest-by-construction** discipline (#3) applied to the render's runtime implications.

**Notes.** Two diaboli objections (O5, O6) converge on this one choice — the readability floor and the portability inlining are the two halves of keeping the self-contained norm's *guarantees* while taking its *JS* exception. The cartographer's mark is that the spec split one norm into two guarantees and honoured both rather than treating the exception as wholesale.
