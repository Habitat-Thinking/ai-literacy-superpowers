---
spec: docs/superpowers/specs/2026-08-13-cadence-sentinels-s7-docs-design.md
date: 2026-08-13
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "S7 establishes that the epic's cited source document cannot be found in either repository, then quarantines that finding to a single acceptance item instead of drawing the conclusion it forces — that every S1-S6 provenance line cites a document nobody can produce."
    evidence: "Spec line 10: 'Provenance: The Second Front — Arc Insertion Remit (slide S7).' Spec section 3: 'That deck is not in either repository.' A search for 'Second Front|Arc Insertion|slide 18' across both repos returns hits only in this repo's own seven spec provenance lines."
    disposition: accepted
    disposition_rationale: "The finding is followed where it leads. The spec now records that the epic's provenance is a citation the repo cannot resolve, and #514 carries it so the next reader inherits a known gap rather than a confident reference. The objection is right that seven provenance lines pointing at a document nobody can produce is the epic's own recurring defect at epic scale — and right that S7, the slice whose job is to give the results a home, is the last moment anyone looks."
  - id: O2
    category: scope
    severity: high
    claim: "The spec declares one of issue #497's four acceptance items undeliverable and closes #497 anyway, which is the overclaim pattern the spec says this epic exists to catch."
    evidence: "Section 3: 'The keynote sync (#497 item 4) is blocked, and the slice ships without it.' Section 9: 'Closes #497 and #513.' 'Closes' is a machine instruction; merging shuts the issue whose fourth acceptance item was never met."
    disposition: accepted
    disposition_rationale: "The PR closes #513 only. #497 stays open with item 4 as its remaining scope, and a comment on it records exactly what shipped and what did not, so the unblocking condition lives on a durable surface rather than in a merged PR body. 'We openly declare this undone' and 'we close the issue tracking it' cannot both stand, and the objection is right that a PR body is not where a known gap survives."
  - id: O3
    category: premise
    severity: high
    claim: "Section 2.1's table asserts a one-to-one sentinel-to-page mapping that does not exist in the repo today: one page covers three sentinels and one sentinel has two pages, so D1 is already false for four of the five sentinels the spec lists as satisfied."
    evidence: "explanation/decision-discipline-triad.md covers carpaccio, advocatus-diaboli AND choice-cartographer ('Three agents in the plugin form a single discipline'). explanation/the-cost-estimation-loop.md is a second cost-estimator page. Both are linked from index.md, so neither is an orphan. Neither appears in the spec's table."
    disposition: accepted
    disposition_rationale: "This is the S6 finding repeated one slice later: a convention asserted by a table built from the cases that fit. The repo's actual pattern is mixed — per-agent pages AND per-discipline pages — and decision-discipline-triad.md is precisely the per-discipline shape. So S7 ships ONE cadence-discipline page mirroring it, not four per-agent pages. That is symmetric with what exists, dissolves the false premise rather than papering it, and makes the page count honest."
  - id: O4
    category: implementation
    severity: high
    claim: "D1's 'derived from role: sentinel frontmatter rather than pinned' is not implementable as stated, because no on-disk relation links a sentinel's name to its explanation page — and the spec names no script, workflow, or test that would perform the derivation."
    evidence: "The nine agent names are derivable. The page side is not: cadence-governance.md maps to carpaccio and watching-the-verifier.md to reservoir-warden, and the four proposed filenames contain none of coda, mast, wip-warden, convener. AGENTS.md:480-501 requires that where no on-disk source exists, a pin carry a comment saying what makes it change and why it was not derived."
    disposition: accepted
    disposition_rationale: "The missing relation is created rather than worked around. Each explanation page gains a `sentinels:` frontmatter key naming the agents it explains, and a Layer 0 check derives coverage from both sides — role: sentinel on one, the new key on the other. The objection is right that the phrase was the ARCH_DECISION invoked rather than implemented, and right that an implementer would otherwise have written a heuristic pairing, which that decision names as the second anti-pattern."
  - id: O5
    category: scope
    severity: high
    claim: "The PreToolUse error is in three files, not one; D3's wording ('no page') and the Files table between them exclude the two that are not docs pages, including a shipped plugin file."
    evidence: "hooks.json line 2 description: 'constraint gate (PreToolUse) warns on violations' — while the same file registers it under PostToolUse at lines 27-36, so the manifest contradicts itself. README.md:323 and README.md:428 carry it in prose and in the architecture diagram. The Files table lists only reference/hooks.md."
    disposition: accepted
    disposition_rationale: "All three fixed, and hooks.json first: it is the manifest a user or agent reads to learn what the hook set does, it is the shipped artefact rather than its documentation, and it currently contradicts its own registration eight lines later. D3 is rewritten to assert the property across the repo rather than over the one file the spec already planned to touch — an acceptance criterion scoped to the planned fix is a restatement, not a check."
  - id: O6
    category: specification quality
    severity: high
    claim: "Section 2.2's three numbers cannot all be true, and one is wrong on the file: 18 declared minus 17 documented is one, not two — and the page documents 16 hook entries, because one of its ### headings under Stop is a library rather than a hook."
    evidence: "hooks.json: 1 + 2 + 11 + 4 = 18. reference/hooks.md: PreToolUse 2 + Stop 11 + SessionStart 3 = 16, where the Stop count excludes '### The advisory rail' (lib/advisory-rail.sh, sourced, never registered). D2 states the invariant but no method for checking it."
    disposition: accepted
    disposition_rationale: "Corrected to 16, and the advisory-rail question is answered explicitly rather than left for the checker to trip over: it moves to a 'Libraries' section outside the event groups, so a count over event-section headings is exact. Getting the arithmetic wrong inside a finding that arithmetic drifted would have handed the implementer an off-by-one and a target that does not exist."
  - id: O7
    category: scope
    severity: high
    claim: "The two-discipline framing contradicts three shipped surfaces by reclassifying cost-estimator, and it is not a partition in any case — one sentinel sits in both, one in neither, and the bullet lists disagree with the prose."
    evidence: "sentinel-design/SKILL.md:139-143 already carries the framing and places cost-estimator outside it: 'the cost-estimator guards the decision's inputs'. sentinels.md:117-126 repeats it. decision-discipline-triad.md is titled for a triad with a 'Why three, not one' section. The spec's prose says carpaccio sits in both while its Cadence bullet omits carpaccio."
    disposition: accepted
    disposition_rationale: "The shipped framing wins and the reclassification is dropped: the triad guards decisions, the reservoir-warden the decider, the cost-estimator the decision's inputs, and the four cadence sentinels the shape of the work around them. The spec had described its own edit as 'mirroring the roster it already carries' while actually proposing to renumber a triad — which would have misnamed decision-discipline-triad.md on the day S7 merged, creating a page teaching a superseded model inside the slice built to remove them."
  - id: O8
    category: scope
    severity: high
    claim: "Section 2.4 diagnoses the one-axis ladder as 'a model the harness no longer follows', then scopes the correction to a single page while at least six other shipped pages teach the same model."
    evidence: "Also teaching the ladder: constraints-and-enforcement.md:72, understand-harness-engineering.md:66, harness-engineering.md:70-80, how-to/add-a-constraint.md:83, tutorials/harness-from-scratch.md:276, tutorials/getting-started.md:275, index.md:167, fitness-functions.md:181. progressive-hardening.md itself names three levels then documents a four-value enum whose fourth value has no rung."
    disposition: accepted
    disposition_rationale: "All of them, because add-a-constraint.md is the decisive one: it is a how-to that states the ladder at the exact moment someone is choosing an Enforcement value, which is where the missing reach axis has consequences. Fixing the page a reader consults after they already have the question, and leaving the page that forms the question, would have inverted the priority. The four-value enum with three rungs is corrected too."
  - id: O9
    category: implementation
    severity: high
    claim: "K6 tests the wrong absence: the pact file and session registry live outside every work tree, so 'a repo with none of these files' is not the adoption-absent state — and 'exits 0' is undefined for the sourced libraries K1, K2 and K4 exercise."
    evidence: "lib/pact-blocks.sh:43-45 defaults to $HOME/.claude/pacts.md. hooks.md: 'The registry is local, per-machine, outside every work tree.' sentinels.md:135-141 makes that separation the design's point. K1 sources a library, K2 and K4 call shell functions — none is a process with an exit status."
    disposition: accepted
    disposition_rationale: "K6 now constructs MACHINE-state absence — a pact path that does not exist and an empty registry directory — not repo-state absence. The objection identified a test that would have passed on a state it never constructed: anyone who has run /mast tune, which is everyone who built this epic, would have got the adopted behaviour and a green check attesting to a property nobody verified. That is the exact failure class the epic exists to catch. The exit-status half is resolved by asserting on emitted output for sourced functions."
  - id: O10
    category: risk
    severity: high
    claim: "The smoke test as described is non-hermetic: it names a toy repo in a temp directory but not one of the four test-only environment overrides the shipped scripts require, so a run would register entries in the developer's real machine-global session registry and read their real pact file."
    evidence: "hooks.md: '$CLAUDE_SESSIONS_DIR overrides the registry location... not intended for production use'; $CLAUDE_MAST_DIR and $CLAUDE_PARKED_DIR are test-only; $CLAUDE_PACTS_FILE from lib/pact-blocks.sh:43. Every shipped sibling sets them — test-wip-check.sh:32-33. K2 explicitly drives registry mutation including sweep."
    disposition: accepted
    disposition_rationale: "All four overrides are named in the spec and set in the test. The consequence the objection traced is why this is high and not medium: a smoke run against the real registry inflates the live-session count the WIP Warden reports, so the sentinel whose whole remit is a line the person drew would report a breach of a line nobody crossed — which test-wip-check.sh already names as the worst output this substrate can produce. Sweep against a real registry could also retire a merely-idle colleague session."
  - id: O11
    category: alternatives
    severity: medium
    claim: "K1-K5 re-run coverage that already ships per library, and the property section 5 calls most important is already asserted by an existing test — so the honest new surface is smaller than claimed and a cheaper option was not weighed."
    evidence: "test-pact-blocks.sh, test-session-registry.sh, test-wip-check.sh, test-next-action.sh, test-parked-resume.sh, test-record-contracts.sh and test-convene-check.sh cover K1-K5 respectively. test-wip-check.sh:64 already asserts silence with no block declared and :150 exit 0 on every path. Nothing in K1-K5 asserts an interaction between two libraries."
    disposition: accepted
    disposition_rationale: "The test is rebuilt around the one property per-library tests structurally cannot show, which the objection named better than the spec did: three libraries each read the pact independently, and the limit, the lease and the WIP comparison must agree with each other. K1-K5 as originally written were five independent assertions sharing an mktemp, which is not integration coverage. The redundant items are dropped rather than kept for reassurance."
  - id: O12
    category: scope
    severity: medium
    claim: "The Files table omits every surface the rollout requires and every surface the new pages create, and the bump level contradicts the non-goals under this repo's stated semver rule."
    evidence: "Five CI-checked version locations plus the README cell appear in no Files row. Also absent: index.md's hand-maintained Concepts list, the four how-to backlinks, and hooks.md's own Configuration section which still describes only PreToolUse and Stop arrays. sentinels.md:115 has a blank line orphaning the convener row into a second table, and :198 still reads 'The five roster agents'. CLAUDE.md makes a doc-only change to plugin files a patch, not the minor the spec names."
    disposition: accepted
    disposition_rationale: "Every surface is added, and the bump is corrected to 0.73.1 — with O7 dropping the reclassification, nothing behaves differently and the repo's own rule makes this a patch. The sentinels.md rendering break is the sharpest item: it is live on the docs site now, and it was introduced by the S5 edit that added the convener row. A slice whose thesis is that documentation did not keep pace, adding unlinked pages to a hand-maintained index, would have reproduced its own diagnosis."
---
# Objection record — Cadence Sentinels S7: Documentation (spec mode)

Twelve objections: nine high, three medium, none critical. All accepted.

**Three of the spec's claims did not survive verification**, and the first is
the S6 finding arriving one slice later.

§2.1 asserted that five sentinels have one explanation page each and built a
five-row table to prove it. The table was constructed by omitting the
counterexamples: `decision-discipline-triad.md` covers **three** sentinels, and
`the-cost-estimation-loop.md` is a **second** page for `cost-estimator`. Both
are linked from the plugin landing page. The repo's real pattern is mixed —
per-agent pages *and* per-discipline pages — which means the "convention"
justifying four new pages does not exist, and the per-discipline shape S7 was
proposing for the framing is already the shape sitting in the directory (O3).

So S7 ships **one cadence-discipline page**, mirroring the triad page exactly.

§2.2 said the page documents 17 hooks under a heading reading "short by two".
Both cannot hold: it documents **16**, because `### The advisory rail` is a
sourced library that was never registered (O6).

§6 described the `sentinel-design/SKILL.md` edit as "mirroring the roster it
already carries". That file already carries the two-discipline narrative, and
places `cost-estimator` **outside** the decision discipline. The spec's framing
was a silent reclassification that would have misnamed
`decision-discipline-triad.md` on the day it merged (O7).

**The error is in the shipped artefact, not only its documentation.**
`hooks.json`'s own description field says the constraint gate is `PreToolUse`
while the same file registers it under `PostToolUse` eight lines later, and the
README carries the error twice more (O5). D3 was scoped to the single file the
spec had already planned to fix.

**The smoke test would have polluted the developer's machine.** The pact file
and session registry live outside every work tree by design, so a toy repo does
not isolate them and the four test-only overrides were unnamed. A run would
have written into the real registry — inflating the live-session count the WIP
Warden reports against a line the person drew, which `test-wip-check.sh` already
names as the worst output this substrate can produce (O9, O10).

**#497 is not closed by this PR.** Declaring item 4 undone and closing the issue
tracking it are the same overclaim through two channels (O2).

## Explicitly not objecting to

- **The `mast` naming decision and the marketplace decision.** Both verified;
  the reasoning is argued rather than asserted.
- **§3's factual finding about the deck.** Independently confirmed across both
  repositories. O1 objects to the conclusion drawn, not the finding, and the
  refusal to approximate a link check on an unlocatable document is right.
- **§2.3, the `Stakeholders` gap.** Verified, and "a missed commitment, not a
  discovered gap" is the honest framing.
- **The half-automatable framing of §5.** That model-mediated command runs
  cannot be a CI test is correct and stated plainly rather than fudged.
