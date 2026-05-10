---
spec: docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md
date: 2026-05-09
mode: spec
cartographer_model: claude-opus-4-7[1m]
stories:
  - id: 1
    lens: [forces, coherence]
    title: Forward-only pivot over self-demonstration ceremony
    disposition: accepted
    disposition_rationale: "The forward-only pivot is the right call given the Layer-1-vs-Layer-3 cost trade. The trade was named honestly in A2.6 and mitigated by O7's accepted disposition (in-file forward-pointer in orchestrator.agent.md and tdd-agent.agent.md). The cartographer's concern about future contributors generalising 'forward-only' into a maxim is exactly what governance audits exist to catch — promoting the pattern to a project-level rule now would be premature; the audit cadence is the natural watchpoint."
  - id: 2
    lens: [patterns, defaults]
    title: Deterministic CI inherits spec-first-check shape
    disposition: accepted
    disposition_rationale: "The deterministic-CI shape is already a project pattern (spec-first-check.yml, version-check.yml, docs-build-check.yml). Reusing the pattern is the point — that's leverage, not duplication. The cartographer's flag that future tier-content judgement can't live in this check is acknowledged but speaks to a future spec, not this one."
  - id: 3
    lens: [alternatives, patterns]
    title: Branch on existing agent over new tdad-agent
    disposition: accepted
    disposition_rationale: "The single-agent / two-charters Strategy pattern is correct here. The cartographer's contagion-risk concern (changes to one branch must be checked against the other) is real but is the same risk any conditional structure carries; the alternative (two agents sharing a charter) was the failure mode this project explicitly chose to avoid in the diaboli architectural decision. The branch-boundary preamble per A2.5 is the localised mitigation."
  - id: 4
    lens: [defaults, consequences]
    title: Path-based detection borrows convention as truth
    disposition: accepted
    disposition_rationale: "Path-based detection's correctness is coupled to two HARNESS Context conventions, but those conventions ARE actively enforced — by the harness-enforcer agent at PR time and by the Naming / File structure review during the agent-enforced spec-quality and frontmatter constraints. The dependency is named explicitly in §2 of the spec; the cartographer is right to surface it but not to alarm-bell. The pattern (convention-over-configuration with human-enforced conventions) is well-named for future reference."
  - id: 5
    lens: [consequences, alternatives]
    title: New-files-only scope accepts modification blind spot
    disposition: revisit
    disposition_rationale: "The cartographer's question is sharp: the deferred follow-up has no observation surface. Re-evaluation trigger set to the next quarterly /governance-audit (target 2026-07-19 per CLAUDE.md Quarterly Operations cadence). The audit should look at: number of agent-artefact PRs that modified existing components vs added new ones in the trailing 90 days, and whether modifications-without-scenarios surfaced as a real failure mode. If yes, follow-up spec extends the constraint. Paired with #6."
  - id: 6
    lens: [defaults, consequences]
    title: Three directories define the discipline's edge
    disposition: revisit
    disposition_rationale: "Same shape as #5 — deferred-without-trigger. Same re-evaluation trigger: next quarterly /governance-audit (target 2026-07-19). The audit should look at: PRs that touched hooks/, templates/, or scripts/ in the trailing 90 days, and whether any of them had behaviour worth a scenario. If a hook gains complexity, follow-up spec extends the constraint's scope."
  - id: 7
    lens: [alternatives, coherence]
    title: FINDING- coexists rather than collapses into scenarios
    disposition: accepted
    disposition_rationale: "FINDING- as a discriminated-union arm under scenarios/<type>/<name>/ is the right call — the corpus already encodes the distinction and Layer 3 has dedicated tests that depend on it. The pattern naming (discriminated union) is useful for future tooling that walks the directory. The constraint correctly excludes finding-tier files via the tier whitelist (per O5's accepted simplification)."
  - id: 8
    lens: [consequences, alternatives]
    title: Presence-and-tier check defers falsifiability test
    disposition: accepted
    disposition_rationale: "The two-phase verification (deterministic presence-and-tier + human review at orchestrator's RED-phase soft surface) is fragile at the seam, but the deferral matches O8's deferred disposition in the diaboli record — both pointed at the same trade. The Layer 1 non-empty-Then test remains the right long-term home for substantive-quality enforcement; cheap-now grep would expand the deterministic workflow's scope beyond its stated purpose."
  - id: 9
    lens: [patterns, defaults]
    title: Visible blockquote markers over invisible HTML comments
    disposition: promoted
    disposition_rationale: "The visible-blockquote redaction convention is small, reusable, and one-line to formalise. Promote to AGENTS.md STYLE at curation time: 'When a spec is amended, mark superseded prose with a visible > **SUPERSEDED by Amendment N §X.Y**: ... blockquote prefix above the original text. Do not use HTML comments — they vanish on every rendered surface (GitHub PR view, mkdocs material). Audit-trail-with-visible-redaction is the named pattern (FDA 21 CFR Part 11 lineage).' Future amended specs inherit the convention without rediscovery. Promotion happens as a separate small commit at the next AGENTS.md curation pass; this PR records the disposition only."
---

## Story #1 — Forward-only pivot over self-demonstration ceremony

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (Amendment 2, §A2.1, §A2.6)
**Lens:** forces, coherence
**Refs:** O4

**Context.** Amendment 1 instructed the spec to author Layer 1 scenarios for its own `orchestrator.agent.md` and `tdd-agent.agent.md` edits, on the grounds that "a change that adds TDAD discipline benefits from being itself subjected to the discipline" (A1.8). Amendment 2 reverses this: scenarios that target Layer 1 only "cannot fail before implementation and cannot fail after, so calling them RED phase is theatre" (A2.1). The spec now applies forward-only — to PRs that ship _after_ this one merges — and explicitly accepts that the introducing PR is itself outside the discipline.

**Forces.** The visible tension: messaging coherence (a discipline-introducing PR ought to wear the discipline) versus epistemic honesty about what Layer 1 can detect. The unspoken third force: scope ambition (escalating to Layer 3 SDK fixtures was available but ruled out by the companion `command-tdad-testing-design.md` Amendment 1). The spec resolved toward honesty at the cost of the rhetorical loop — a non-trivial trade given how much of the project's ethos is "demonstrate by doing."

**Options not taken.**

- Ship the Layer-1-only scenarios anyway, accepting that they are paperwork (Amendment 1's stance). Coheres with self-demonstration; sacrifices honesty.
- Escalate the in-PR demonstration to Layer 3 SDK fixtures (out of scope per the companion spec). Coheres fully; widens scope substantially.
- Defer the entire spec until a Layer 3 fixture rig exists. Coheres later; ships nothing now.

**Choice as written.** The spec ships forward-only. It names the trade in A2.1 ("the pivot accepts that this PR ships forward-only discipline") and in A2.6 ("This PR is itself a modification PR under the rule above. No scenarios are authored… the discipline applies forward").

**Consequences.** A future reader of `orchestrator.agent.md` or `tdd-agent.agent.md` will encounter the artefact-type branch instructing them to author scenarios under `tdad_tests/scenarios/agents/`, look for the directory, find it absent, and have no proximate explanation. O7's accepted disposition mitigates this by adding an in-file forward-pointer to A2.6 — but the cartographer notes that the mitigation is itself a workaround for the central pivot's awkwardness. If future contributors generalise "the discipline applies forward" into "rules introduced after this point grandfather their introducer," the project will have ratified a maxim that was actually a one-time concession.

**Pattern.** Self-exemption clause (legal-drafting). The pattern appears wherever a rule's introducer cannot satisfy the rule because the rule does not yet exist; the standard remedies are explicit grandfathering, retroactive application, or a delayed effective date. Forward-only is grandfathering.

**Notes.** This is the spec's most load-bearing decision and worth re-reading at the next governance audit if a similar discipline-introducing spec appears.

## Story #2 — Deterministic CI inherits spec-first-check shape

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (Amendment 2, §A2.2)
**Lens:** patterns, defaults
**Refs:** O1, O2

**Context.** Amendment 1 introduced the constraint with `Enforcement: agent` and `Tool: harness-enforcer agent` (A1.1). Amendment 2 reverses this — `Enforcement: deterministic`, `Tool: .github/workflows/tdad-scenario-check.yml`. The reversal cites the project's "pattern for analogous file-presence checks (`Spec-first commit ordering`, `Version consistency`) is deterministic CI workflows."

**Forces.** The unspoken tradeoff: enforcement-mechanism judgement vs. enforcement-mechanism convention. A file-presence-plus-frontmatter check has no judgement component, so an agent enforcer would burn LLM inference and clock time on a check that bash + python can do offline. The convention argument is also a coherence claim — the project's enforcement vocabulary is becoming "agent for judgement, deterministic for invariants," and inconsistency would muddy that grammar.

**Options not taken.**

- Keep agent enforcement (Amendment 1's choice). Cheaper to write the rule in prose, more expensive at every PR.
- Hybrid: deterministic for presence + agent for tier-content review. Defensible but doubles the integration surface.
- Rely on Layer 1 structural test post-merge with no PR-time gate. The original spec's stance, rejected by Amendment 1's O1.

**Choice as written.** Deterministic CI workflow. The spec hand-waves the implementation — a few lines of bash that resolve `BASE` from `origin/${{ github.base_ref }}`, walk `git diff --name-only --diff-filter=A "$BASE..HEAD"`, and parse YAML frontmatter via `tdad_tests/runner/scenario.py`'s existing `Scenario.parse` helper (per O1's accepted disposition).

**Consequences.** The constraint is now structurally identical to `spec-first-check.yml` and `version-check.yml` — this is leverage, not duplication, because the bash idiom is uniform across the three checks. The cost: any future requirement for tier-content judgement (e.g. "the `Then` clauses must look falsifiable") cannot be added to this check; it would require a different enforcement type. O8's deferred non-empty-Then test is the visible early instance.

**Pattern.** Polya's "have you seen a similar problem?" heuristic operationalised as a project-level enforcement vocabulary. The deterministic-vs-agent split is a recurring design pattern in this codebase — reuse of the pattern is the point.

## Story #3 — Branch on existing agent over new tdad-agent

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (§5 "Trade-off — tdd-agent branching vs new tdad-agent")
**Lens:** alternatives, patterns
**Refs:** —

**Context.** The original spec considered creating a separate `tdad-agent` for the discipline and rejected it for three reasons: (a) the orchestrator already dispatches `tdd-agent` at step 2, so a new agent would force pipeline changes; (b) the discipline is the same RED→GREEN shape with a different artefact type; (c) maintaining two agents that share a charter is a failure mode the project's prior architectural decision (single agent, two dispatches) was chosen to avoid.

**Forces.** Cohesion of charter ("RED phase, regardless of artefact type") versus separation by artefact type ("scenarios are different enough to warrant their own agent"). The spec resolved toward charter cohesion, treating "scenarios" and "tests" as varieties of the same thing rather than different things.

**Options not taken.**

- New `tdad-agent` with its own dispatch slot. Clean charter per agent; doubles the pipeline-change surface.
- Make `tdd-agent` polymorphic via subagent dispatch (the agent itself dispatches to a "scenario" sub-routine for agent artefacts). Higher cohesion, more orchestration overhead at the agent layer.
- Inline the scenario authoring into the orchestrator itself. Lowest surface area; conflates orchestrator and TDD discipline.

**Choice as written.** Single `tdd-agent` with an artefact-type branch keyed off the scope context the orchestrator passes in. The branch is documented in the agent file; the dispatch contract is unchanged.

**Consequences.** The agent file gains a conditional structure — its prose now has to teach two different concepts of "RED" (per A1.5 and A2.5). Future amendments to either branch carry contagion risk: a change to the generic-test branch must be checked against the agent-artefact branch. The "Confirming red" section is now operating two definitions simultaneously, which is why A2.5 had to mandate an explicit branch-boundary preamble.

**Pattern.** Strategy (GoF) implemented via prose-conditional within a single agent rather than via dispatch to separate agent files. The naming "Strategy" here is loose — the agent isn't selecting an algorithm, it's selecting a charter — but the structural compression is the same: one decision point branches the behaviour.

## Story #4 — Path-based detection borrows convention as truth

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (§2 "Why path-based detection", §4 "Detection")
**Lens:** defaults, consequences
**Refs:** —

**Context.** The orchestrator detects agent-artefact scope by scanning the plan's intended file paths for matches under `ai-literacy-superpowers/skills/`, `agents/`, or `commands/`. Frontmatter-based detection (parse the file, look at `name` and component shape) and content-based detection (heuristics over the file body) are explicitly rejected: "Frontmatter-based detection would be more precise but is redundant given the path convention is already enforced (by the `Naming` and `File structure` conventions in HARNESS.md Context)."

**Forces.** Detection accuracy versus implementation cheapness. Path-based detection is a string match; frontmatter-based detection requires reading and parsing every file in the plan; content-based detection requires inference. The spec's path-based choice is the cheapest of the three — but it depends on a convention the project already enforces elsewhere.

**Options not taken.**

- Frontmatter-based detection (parse `component_type` from frontmatter). Robust to file moves; expensive per dispatch.
- Hybrid (path-based as fast path, frontmatter as fallback for ambiguous cases). Marginal value; not justified for a small artefact set.
- Plan-tag-based (the spec author tags artefacts explicitly in the plan). Robust but adds spec ceremony.

**Choice as written.** Path-based, with the convention dependency named explicitly: "the path convention is already enforced by the `Naming` and `File structure` conventions in HARNESS.md Context."

**Consequences.** The detection's correctness is now coupled to two HARNESS conventions in the Context block — neither of which is a "Constraint" with deterministic enforcement; they are written-down norms that the harness-enforcer agent reviews. If those Context conventions are ever loosened (e.g. allowing agent files outside `agents/`), the detection silently misses artefacts. The cartographer notes this is an inherited default — the spec did not choose path-as-canonical; it borrowed an existing project decision and is now relying on it.

**Pattern.** Convention over configuration (Ruby on Rails, 2004) — but the convention here is enforced by humans-with-checklists rather than by a deterministic check. The pattern's classic risk (the convention drifts; the consumers built atop it break silently) applies fully.

## Story #5 — New-files-only scope accepts modification blind spot

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (Amendment 2, §A2.6, §A2.8)
**Lens:** consequences, alternatives
**Refs:** #1

**Context.** The HARNESS constraint enforces scenario presence only when a PR _adds_ a new file under the canonical paths. A PR that _modifies_ an existing skill, agent, or command — even a behavioural-contract-changing modification — is not blocked by the constraint. A2.8 names this as the first of three known limitations carried forward.

**Forces.** Detection certainty (added files are unambiguous; modified files require a "is this behavioural?" judgement) versus coverage completeness. The constraint chose certainty; coverage of the modification path is left to the orchestrator pipeline (which "surfaces the question for modifications but does not enforce an answer") and to manual review.

**Options not taken.**

- Constraint applies to modifications too, with an exemption label for non-behavioural refactors. More coverage; more friction; load-bearing on the labelling discipline.
- Constraint applies to modifications gated by a deterministic file-content diff (e.g. "if the modification touches the agent's frontmatter `description` field, require scenario update"). Narrower; still requires judgement at the boundary.
- Layer 3 SDK fixtures verify behaviour-after-modification regardless of scenario. Out of scope per the companion spec.

**Choice as written.** New-files-only. A2.8 frames this honestly: "Existing components can be modified without scenario coverage… If practice shows legitimate modifications silently skipping the discipline, a tighter rule is a follow-up spec."

**Consequences.** The classic "build the easy thing, defer the hard thing" trade. The deferred follow-up has no trigger condition — A2.8 says "if practice shows" but does not name what observation would qualify, who would notice, or when the question gets re-asked. The cartographer asks whether the deferred follow-up should have an explicit review trigger (e.g. quarterly audit, or N modifications without scenario update) rather than being trusted to surface organically.

**Pattern.** YAGNI (Beck, _Extreme Programming Explained_) applied to constraint scope. The trade is correct in shape; the cartographer's note is that YAGNI without a re-evaluation trigger drifts from "deferred" to "forgotten."

## Story #6 — Three directories define the discipline's edge

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (Amendment 1 §A1.10, Amendment 2 §A2.8)
**Lens:** defaults, consequences
**Refs:** —

**Context.** The discipline applies to `skills/`, `agents/`, and `commands/`. It does not apply to `hooks/`, `templates/`, or `scripts/`. A1.10 owns the exclusion with a per-directory rationale: templates are passive content with no agent behaviour to test; scripts are tested at Layer 0 via the bash test suite; hooks are advisory and small enough that Layer 1 manifest validation is sufficient.

**Forces.** Discipline coverage (more is better) versus discipline cost-per-artefact-type (TDAD scenarios for passive content is paperwork). The spec resolved toward "where the discipline produces value" rather than "where the discipline could mechanically apply."

**Options not taken.**

- Apply to all six directories uniformly. Maximum coverage; maximum paperwork for `templates/`.
- Apply to a different subset (e.g. include `hooks/` because hooks have advisory behaviour; exclude `commands/` because they are procedural scripts). Defensible but un-argued.
- Per-directory tier override (`hooks/` only requires Layer 0; `templates/` exempt entirely). More granular; more rules to remember.

**Choice as written.** A flat in/out partition with three directories in scope. The orchestrator's detection step prose names the exclusion explicitly so future readers do not infer "all plugin surfaces."

**Consequences.** If a future hook gains enough complexity to warrant a scenario, the exclusion has to be revisited as a follow-up spec. A2.8 carries the rationale forward but does not weight when revisiting becomes due. The cartographer notes this is the same shape as Story #5 — a deferred-without-trigger condition. The exclusion is defensible today and may not be in 18 months.

**Pattern.** Open-Closed Principle (Meyer, 1988) at the constraint-scope level: the rule is closed against modification (the directory list is hard-coded in the workflow) and open for extension (a new spec can add a directory). The pattern's classic question — _which axis of change does the rule anticipate?_ — is the cartographer's question for this scope choice.

## Story #7 — FINDING- coexists rather than collapses into scenarios

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (Amendment 2, §A2.3)
**Lens:** alternatives, coherence
**Refs:** O5

**Context.** The corpus contains `tdad_tests/scenarios/commands/harness-init/FINDING-command-tdab-gap.md` — a documentary architectural finding that is _not_ a falsifiable scenario. Layer 3 has dedicated tests that depend on the FINDING- prefix invariant. Amendment 2 names FINDING- as a recognised, separate artefact category that coexists with `<aspect>.md` files in the same directory and explicitly does _not_ satisfy the new constraint.

**Forces.** Vocabulary economy (one scenario type, one prefix) versus expressive distinction (falsifiable scenarios and architectural findings are genuinely different things and the corpus already encodes the distinction). The spec resolved toward expressive distinction, accepting two co-existing artefact categories under the same directory tree.

**Options not taken.**

- Collapse FINDING- into scenarios with `tier: finding`, removing the prefix. Cleaner naming; breaks the existing Layer 3 prefix-dependent tests.
- Move FINDING- files out of `scenarios/` into a sibling `findings/` directory. Clearer separation; widens the directory taxonomy and breaks existing paths.
- Disallow FINDING- entirely; require every architectural question to be expressed as a falsifiable scenario or not recorded. Cleaner; loses the documented finding the corpus relies on.

**Choice as written.** FINDING- is a recognised, separate category. The constraint excludes it via the tier whitelist (per O5's accepted simplification — substantive filter is `tier != finding`, not the prefix). The tdd-agent's prose authors `<aspect>.md` files; FINDING- authoring remains a manual decision.

**Consequences.** The directory `tdad_tests/scenarios/<type>/<name>/` is now polymorphic — it holds scenarios and findings, distinguished by tier. Future readers of a component directory cannot assume every file there is falsifiable. The two-artefact-type structure must be carried forward in any future tooling that walks the directory.

**Pattern.** Discriminated union (type-theory): the directory holds values of a sum type `Scenario | Finding`, distinguished by a discriminator field (`tier`). The pattern is well-known but worth naming because future tooling will need to handle both arms, not just the scenario arm.

## Story #8 — Presence-and-tier check defers falsifiability test

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (Amendment 2, §A2.8)
**Lens:** consequences, alternatives
**Refs:** O8, #2

**Context.** The deterministic check verifies scenario file presence and tier (one of `structural`, `trigger`, `behavioural`). It does not verify that the `## Then` section contains falsifiable assertions. A2.8 names this as a known limitation: "bad scenarios can pass the deterministic check (the check only verifies presence and tier, not falsifiability of `Then` clauses). Mitigation: the tdd-agent's RED-phase output is surfaced to the user before the implementer is dispatched."

**Forces.** Constraint scope (small, focused, fast to implement) versus coverage of the substantive failure mode (an empty `Then` is technically a passing scenario but materially worthless). The spec resolved toward focus, mitigating substantive-quality concerns through human review at the orchestrator's RED-phase soft surface.

**Options not taken.**

- Add a `## Then` non-empty grep to the same workflow now. Cheap (a few lines of bash); closes a known bypass; expands scope beyond "presence-and-tier."
- Layer 1 test asserting non-empty `Then`. Better-located but requires extending Layer 1's discovery to the new corpus shape.
- Soft-warning rather than hard-fail on empty `Then`. Less coverage; surfaces the question.

**Choice as written.** Deferred. The deferral is principled (consistent with the forward-only stance and the spec's general "small, focused" framing) — but, like Story #5, the deferral has no explicit re-evaluation trigger.

**Consequences.** The first abuse of the constraint (a contributor authors a scenario with `tier: structural` and an empty `## Then`) will pass the check, surface to the user via the orchestrator's soft surface, and rely on the user to catch it. If that user surface is silently bypassed (e.g. someone runs the implementer directly without the orchestrator), the constraint is satisfied with no substantive coverage.

**Pattern.** Two-phase commit (Gray, 1978) at the verification boundary — phase 1 (deterministic) verifies presence; phase 2 (human review at the soft surface) verifies substance. The pattern is fragile at the seam: if either phase is bypassed, the other does not catch the failure mode. Worth naming so future hardening (the deferred Layer 1 test or the deferred Layer 3 fixture) knows what gap it is closing.

## Story #9 — Visible blockquote markers over invisible HTML comments

**Source:** `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md` (Amendment 2, §A2.4) and the accepted disposition of objection O3
**Lens:** patterns, defaults
**Refs:** O3

**Context.** Amendment 2 originally used `<!-- amendment-redacted -->` HTML comments to flag superseded sentences in the original spec text. O3 surfaced that HTML comments are stripped by every rendered markdown surface (GitHub PR view, mkdocs material) — the redaction marker would be invisible to readers on rendered surfaces. The accepted disposition replaces the markers with visible `> **SUPERSEDED by Amendment N §X.Y**: …` blockquote prefixes.

**Forces.** Auditability (the original prose must be preserved) versus visibility-on-rendered-surfaces (a redaction signal that disappears in the most-used reading mode is not a redaction signal). The original choice resolved toward minimum-visual-weight markers; the disposition reverses the resolution toward visibility.

**Options not taken.**

- Delete the superseded prose entirely, losing auditability. Cleanest reading; worst for archaeology.
- Keep HTML comments and rely on raw-markdown readers. Quietest; fails for the largest reader audience.
- Strikethrough the prose with `~~…~~`. Visible; less semantic than a labelled blockquote.

**Choice as written.** Visible blockquote prefix with explicit pointer to the superseding amendment. Implementation-level fix, but the choice itself is a small pattern worth naming for project-wide reuse.

**Consequences.** The project now has a working redaction convention for spec amendments — useful immediately for this spec and reusable for any future amended spec. The cartographer asks whether this convention should be promoted to AGENTS.md or to a templates entry under `templates/spec-template.md` so future amendments inherit it without rediscovery.

**Pattern.** Audit-trail-with-visible-redaction (legal-document convention; FDA 21 CFR Part 11 in regulated software). Applied at markdown granularity rather than at version-control granularity. Naming the pattern is the cheap cognitive-debt payment available — a future reader who sees the blockquote will recognise the convention rather than having to re-derive it.

**Notes.** Promotion candidate: this is the kind of small operational convention that costs nothing to formalise and saves a question every time someone amends a spec.
