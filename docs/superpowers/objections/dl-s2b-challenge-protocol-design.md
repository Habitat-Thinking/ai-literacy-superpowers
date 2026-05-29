---
spec: docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md
date: 2026-05-28
mode: spec
diaboli_model: claude-opus-4-7[1m]
objections:
  - id: O1
    category: premise
    severity: high
    claim: "The five-question challenge structure is asserted as a fixed list without explaining why these five questions (and not e.g. three or seven) are the right cut. The choice of five is unevidenced and could equally have been 'three' or 'eight' — the spec treats this as design when it is actually undefended invention."
    evidence: "§3.5: 'Each LegibilityElement is challenged through five questions, asked once per element' followed by Boundary, Evidence, Confounders, Confidence, Description integrity. §10 row 'Number and form of challenge questions' says 'Five questions: boundary, evidence, confounders, confidence, description integrity (§3.5)' as if this were a settled design choice. No spec section explains why these five constitute a complete cover of the challenge surface, why fewer would be incomplete, or why more would be redundant. Compare the diaboli skill, which has six categories explicitly justified by their leverage at different pipeline stages."
    disposition: accepted
    disposition_rationale: "Add a §3.5 rationale paragraph naming what each of the five questions is meant to catch (boundary → smearing; evidence → ungrounded claim; confounders → near-misses; confidence → calibration; description integrity → textbook-definition drift) and mark the cover as a working hypothesis revisable when disposition data shows a category gap. The agent's own challenge_notes corpus becomes the falsification surface."
  - id: O2
    category: implementation
    severity: high
    claim: "Story 6.1 says 'every element has populated challenge_notes (or an explicit empty list when no question surfaced a change)' but the schema (PR #336) declares challenge_notes a required list-of-strings with no contract about when empty is meaningful. The spec's rule 'populate the field when a question surfaces a change, no note when nothing surfaces' means an empty list could mean either 'agent ran the challenge cleanly and nothing surfaced' or 'agent skipped the challenge entirely.' These are observationally indistinguishable to a downstream consumer."
    evidence: "§3.5: 'Questions that surface nothing add no note (avoid noise — empty notes are not evidence of due diligence).' §6.1 acceptance: 'every element has populated challenge_notes (or an explicit empty list when no question surfaced a change)'. Schema (PR #336 template, lines 23–25): challenge_notes is required, list of strings, may be empty when challenge protocol has not yet run. The downstream consumer (parent S3 cross-check, issue #332) cannot distinguish 'challenged and clean' from 'never challenged' on inspection."
    disposition: accepted
    disposition_rationale: "Require a sentinel note when the challenge runs and surfaces no changes — e.g. `Challenge applied; no questions surfaced changes` as the single entry. Empty challenge_notes[] then unambiguously means 'challenge protocol not run'. Update §3.5 (replace 'add no note' with 'add the sentinel note') and §6.1 acceptance. No schema change required."
  - id: O3
    category: implementation
    severity: high
    claim: "§3.4 commits to self-challenge in a single context but offers no mechanism for ensuring the challenge step actually happens. An LLM agent in a single context that drafts an element and then is asked to challenge it is statistically biased toward confirming its own draft — a documented failure mode of self-critique without independent perspective. The 'single-context self-challenge' decision is exactly the architecture that risks the agent rubber-stamping its own output."
    evidence: "§3.4: 'A self-challenge in one context preserves the agent's evidence chain: the same context that drafted the element raises objections against it.' Followed by: 'A later slice may revisit this if disposition data shows that self-blindness is a recurring failure mode. The agent's own context can fail to see things a fresh context would catch; that is real. But again, no signal yet — ship the simpler shape first.' The spec acknowledges the failure mode it is choosing to defer. The challenge-refine cycle is the entire anti-hallucination value proposition of the agent (per the sub-slicing record line 98: 'The challenge-refine cycle is where the anti-hallucination value of the agent lives'). Shipping the architecture with the named failure mode unaddressed weakens the central claim."
    disposition: accepted
    disposition_rationale: "Adopt the O6 middle option (fresh sub-context within the same agent file) to mitigate the named self-confirmation failure mode without doubling file surface. The agent's reasoning protocol gains an explicit context-separation step: an 'act as challenger' prompt segment with adversarial framing, evidence re-read instruction, and instruction to disagree where the evidence allows. Document the rationale in §3.4 and operationalise in §4.3."
  - id: O4
    category: specification quality
    severity: medium
    claim: "The five-question challenge's questions are dimension-flavoured (§3.5 says 'domain elements pressure-test against question 5 most heavily, architectural elements against question 1') but the agent file's protocol does not say how this flavouring is operationalised. An implementer reading §4.3 'apply the five-question challenge to each' will produce the same prompt for both dimensions; the dimension-flavouring is implementation-implicit."
    evidence: "§3.5 paragraph 2: 'The five questions are dimension-agnostic but apply with dimension-flavoured emphasis: domain elements pressure-test against question 5 most heavily (the textbook definition trap), and architectural elements pressure-test against question 1 most heavily (the smeared two services trap).' §4.3 protocol: 'apply the five-question challenge to each, populating challenge_notes[]' — no dimension-aware step. The agent file's 'The five-question challenge' section is described as 'the questions from §3.5, copy-pasted, with one paragraph per question explaining what it is looking for' (§4.3) but does not specify the dimension-flavoured emphasis as a separate step."
    disposition: accepted
    disposition_rationale: "Operationalise the dimension-flavoured emphasis in §4.3 as an explicit per-element step: 'When challenging a domain element, weight Q5 (description integrity) heavily and probe for textbook-definition drift; when challenging an architectural element, weight Q1 (boundary) heavily and probe for smeared services.' The agent file copies this guidance verbatim from the spec."
  - id: O5
    category: scope
    severity: medium
    claim: "The spec ships a how-to page and an explanation page in the same PR as the agent file, but never explains how a human actually invokes the agent. The how-to page is said in §6.5 to 'name the input form (scope)' but the agent is dispatched by Claude Code's Task tool — the actual invocation pattern (which command? what slash-command? direct Task tool? no command at all?) is unspecified. The spec describes the agent as if dispatchable but does not describe the dispatch surface."
    evidence: "§2.1: 'The agent does not enforce one form.' §6.5: 'I navigate to docs/plugins/diagnostic-legibility/how-to/, Then there is a page on invoking the diagnostic-legibility agent, And the page names the input form (scope).' §7.1 ships the how-to page. But nowhere in §2 (the agent's contract) or §4 (the agent file) does the spec say how the agent is invoked. The sibling model-card-researcher is dispatched by the /model-card command (model-cards/commands/model-card.md exists); the diagnostic-legibility plugin has no command, and the spec adds none. The how-to page is asked to document an invocation pattern the plugin does not provide."
    disposition: accepted
    disposition_rationale: "Document the bare-Task-tool dispatch pattern as the v0.3.0 invocation surface (subagent_type: diagnostic-legibility, prompt naming the scope). The how-to page references this pattern explicitly and links forward to parent S4 (#333), which will deliver a /diagnose command. This honours carpaccio's slice boundary (S4 owns the human-facing command) without leaving v0.3.0 with a how-to page documenting a non-existent invocation."
  - id: O6
    category: alternatives
    severity: medium
    claim: "§3.4 considers and rejects 'second-pass challenger agent dispatch' purely on the basis of file-surface cost ('that doubles the surface area to maintain for a v0.3.0 capability'). It does not weigh the alternative of running the challenge step in a fresh sub-context within the same agent file (e.g., the agent could spawn a sub-task or restart its reasoning with a clean slate to act as challenger). That alternative gets the independence benefit without the second-file cost."
    evidence: "§3.4: 'A second-pass dispatch would need a separate challenger agent with its own file, charter, and tool boundary. That doubles the surface area to maintain for a v0.3.0 capability.' The set of considered alternatives is binary: (a) one-context self-challenge, (b) two-agent dispatch. The middle option — same agent, two reasoning contexts (e.g., 'now drop everything you concluded and re-read the evidence as a challenger') — is not weighed. This middle option is what makes the anti-hallucination value of the cycle defensible without doubling the file surface."
    disposition: accepted
    disposition_rationale: "Adopt this middle option as the v0.3.0 architecture — pairs with O3's acceptance. §3.4 must name three alternatives (one-context, fresh-sub-context, two-agent dispatch), explain the choice of the middle option, and operationalise it in §4.3's reasoning protocol (explicit 'now act as challenger' segment, evidence re-read instruction, instruction to disagree where evidence allows)."
  - id: O7
    category: specification quality
    severity: medium
    claim: "Story 6.3 says the agent should 'refuse degenerate outputs' by emitting a low-confidence placeholder — but the schema requires LegibilityElement.evidence to have at least one entry when confidence is medium or high, and permits empty evidence only when confidence is low. The 'refuse degenerate output' rule is internally consistent with the schema only if the placeholder element carries low confidence AND empty evidence — meaning the agent's response to 'I couldn't find anything' is structurally indistinguishable from 'I found a candidate I have no evidence for'. The two failure modes need separate signal."
    evidence: "§6.3: 'And that element has confidence: low / And its description names the degenerate scope condition.' Schema (PR #336 §3.3): 'evidence must have at least one entry when confidence is medium or high. low-confidence elements may have empty evidence (the agent flagged a candidate without ground).' The downstream consumer reading a list of low-confidence elements with empty evidence cannot distinguish 'this is a placeholder for empty-scope' from 'this is an evidence-less guess'."
    disposition: accepted
    disposition_rationale: "Adopt option (a): the degenerate-output placeholder element uses a sentinel name `(empty scope)` (exactly this string, surrounding parens included). Downstream consumers can pattern-match on `name == '(empty scope)'` to disambiguate. Avoids schema change; documented in §3 (new sentinel value section) and §6.3."
  - id: O8
    category: specification quality
    severity: medium
    claim: "The spec name the version target 'plugin_version unchanged at v0.39.1' twice (header + §6.4 + §10), but the field's value depends on whatever was current at PR-creation time. If main moves before merge (e.g., another PR ships an ai-literacy-superpowers bump), this PR's marketplace.json edit could either incorrectly downgrade plugin_version or fail the version-consistency check. The spec hard-codes a value that is a function of external main state."
    evidence: "Header: 'Marketplace listing | Unchanged at v0.4.0; plugin_version (pointer to ai-literacy-superpowers) unchanged at v0.39.1'. §6.4: 'And the plugin_version field is unchanged at \"0.39.1\"'. §10: 'plugin_version pointer unchanged at 0.39.1'. The spec's correctness depends on the assumption that ai-literacy-superpowers stays at 0.39.1 from spec-time through merge-time. The check is a cross-repo race condition that the spec acknowledges (header) but does not protect against."
    disposition: accepted
    disposition_rationale: "Add a §9 (Compatibility and rollout) clarification: 'plugin_version is owned by whichever PR most recently bumps ai-literacy-superpowers. If main has moved between spec-time and merge-time, the integration-agent's rebase will surface a conflict on marketplace.json — take main's plugin_version verbatim; this PR only owns the diagnostic-legibility plugins[] entry version bump.' The hard-coded 0.39.1 stays in the spec as the snapshot at authoring time, but the §9 rule is the operative instruction at merge-time."
  - id: O9
    category: alternatives
    severity: low
    claim: "§3.3 commits to a shared protocol across both dimensions. The decision rests on 'the schema is shared (PR #336 settled this); the prompt construction is symmetric.' But the schema being shared (one record type) does not imply the construction protocol must be shared. The agent could legitimately use two distinct construction loops — one targeting moving parts, one targeting concepts — with the dimension-flavoured challenge questions §3.5 already hints at. The 'symmetric construction' decision is a separate design choice that hides behind the schema decision."
    evidence: "§3.3: 'The challenge protocol is the same shape for both architectural and domain elements, parameterised on the dimension. The schema is shared (PR #336 settled this); the prompt construction is symmetric.' Sub-slicing record line 140: 'per-model bespoke vs. parameterised prompts' was excluded as a separate slice on the grounds that 'the decision follows from the schema decision (same schema → parameterisable; distinct schemas → likely bespoke)'. The implication 'shared schema → shared construction' is asserted but not argued; the alternative is parameterised schema with bespoke construction loops."
    disposition: accepted
    disposition_rationale: "Add a §3.3 argument: shared construction is a design choice (not a logical consequence of shared schema). It is chosen because (a) the agent file's complexity scales linearly with protocol count and one shared loop is a smaller surface to maintain; (b) the dimension-flavoured emphasis (per O4) gives us dimension-aware behaviour without bifurcating the protocol; (c) bifurcation is recoverable — if signal emerges that the two dimensions need genuinely different construction sequences, the agent file can be split without schema changes."
  - id: O10
    category: specification quality
    severity: low
    claim: "§5.2 'Expected output shape' is presented as truncated YAML but the truncation hides whether the example demonstrates the schema's required `Q<N>` prefix discipline for challenge_notes. Both notes in the example use 'Q1' and 'Q5' prefixes — but §3.5 never establishes Q<N> as a required prefix; it is invented in §5.2 as illustrative."
    evidence: "§5.2 output example: 'challenge_notes: - \"Q1 (boundary): initially treated the template and the wrapper as one element...\"' and 'challenge_notes: - \"Q5 (description integrity): first draft was generic...\"'. §3.5 lists the five questions by name but never names a prefix format. §5.2 narration: 'the Q<N> prefix in challenge_notes linking back to the five-question structure.' The format is introduced in §5.2 as if established, but it isn't established anywhere. Either §3.5 should mandate the prefix or §5.2 should describe it as an example convention rather than a requirement."
    disposition: accepted
    disposition_rationale: "Mandate the `Q<N> (question name):` prefix in §3.5 (e.g. 'Q1 (boundary):', 'Q5 (description integrity):'). Cheap and improves downstream machine-readability — parent S3 cross-check can group notes by question. The sentinel note from O2 ('Challenge applied; no questions surfaced changes') is exempt from the prefix convention since it spans all five questions."
---

# Adversarial Review — dl-s2b-challenge-protocol-design (spec mode)

Spec under review: `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md`
Mode: `spec`. Reviewer: `claude-opus-4-7[1m]`. Ten objections raised: 3 high (O1, O2, O3), 5 medium (O4, O5, O6, O7, O8), 2 low (O9, O10).

Distribution across categories:

- premise: 1 (O1)
- implementation: 2 (O2, O3)
- specification quality: 4 (O4, O7, O8, O10)
- scope: 1 (O5)
- alternatives: 2 (O6, O9)
- risk: 0 (deprioritised at spec-time per the skill — no concrete code or runtime behaviour to ground)

The spec is structurally sound — slicing intent, versioning ceremony, file inventory, and acceptance scenarios all map cleanly. What is weak is the **defence of the design decisions in §3**. The challenge-refine architecture is the central artefact this slice ships, and the spec defends three of those design decisions (single-pass over iterative, shared over bespoke, self-challenge over dispatch) more thinly than the decision warrants. The choice of *five* challenge questions is undefended (O1), the self-challenge in one context has a named failure mode that the spec acknowledges and ships anyway (O3), and the dimension-flavoured emphasis is described but not operationalised (O4).

These are not blockers — they are honest debts. The "ship the simpler shape and observe" stance is principled, but the spec could be more honest about *what would constitute a signal to revisit* and *what we lose if the signal never comes*.

## O1 — premise — high

### Claim

The five-question challenge structure is asserted as a fixed list without explaining why these five questions (and not e.g. three or seven) are the right cut. The choice of five is unevidenced and could equally have been three or eight — the spec treats this as design when it is actually undefended invention.

### Evidence

§3.5: "Each LegibilityElement is challenged through five questions, asked once per element" followed by:

1. Boundary
2. Evidence
3. Confounders
4. Confidence
5. Description integrity

§10 row "Number and form of challenge questions" says "Five questions: boundary, evidence, confounders, confidence, description integrity (§3.5)" as if this were a settled design choice. No spec section explains why these five constitute a complete cover of the challenge surface, why fewer would be incomplete, or why more would be redundant. Compare the diaboli skill, which has six categories explicitly justified by their leverage at different pipeline stages.

### Why this matters

The five questions are the main implementation deliverable of this slice — the challenge-refine cycle's *content*. If the questions are wrong or under-covering, the agent's output is wrong or under-covering. An undefended question list is the kind of decision that calcifies — once shipped, the next reader treats it as a primitive rather than a choice. Naming the rationale (or admitting "these are our best guess; observe and revise") is cheap; deferring it pushes the cost to whoever discovers the gap.

## O2 — implementation — high

### Claim

Story 6.1 says "every element has populated challenge_notes (or an explicit empty list when no question surfaced a change)" but the schema (PR #336) declares challenge_notes a required list-of-strings with no contract about when empty is meaningful. The spec's rule "populate the field when a question surfaces a change, no note when nothing surfaces" means an empty list could mean either "agent ran the challenge cleanly and nothing surfaced" or "agent skipped the challenge entirely." These are observationally indistinguishable to a downstream consumer.

### Evidence

§3.5: "Questions that surface nothing add no note (avoid noise — empty notes are not evidence of due diligence)."

§6.1 acceptance: "every element has populated challenge_notes (or an explicit empty list when no question surfaced a change)".

Schema (PR #336 template, lines 23–25): challenge_notes is required, list of strings, may be empty when challenge protocol has not yet run.

The downstream consumer (parent S3 cross-check, issue #332) cannot distinguish "challenged and clean" from "never challenged" on inspection.

### Why this matters

The schema field's semantic load is "evidence of due diligence." If empty means both "challenged and nothing surfaced" and "not challenged," the field loses its semantic load. A consumer needs either a separate boolean (`challenged: true/false`) or a sentinel note ("Challenge applied; no questions surfaced changes") to disambiguate. The spec doesn't choose either path.

## O3 — implementation — high

### Claim

§3.4 commits to self-challenge in a single context but offers no mechanism for ensuring the challenge step actually happens. An LLM agent in a single context that drafts an element and then is asked to challenge it is statistically biased toward confirming its own draft — a documented failure mode of self-critique without independent perspective. The "single-context self-challenge" decision is exactly the architecture that risks the agent rubber-stamping its own output.

### Evidence

§3.4: "A self-challenge in one context preserves the agent's evidence chain: the same context that drafted the element raises objections against it."

Followed by: "A later slice may revisit this if disposition data shows that self-blindness is a recurring failure mode. The agent's own context can fail to see things a fresh context would catch; that is real. But again, no signal yet — ship the simpler shape first."

The spec acknowledges the failure mode it is choosing to defer. The challenge-refine cycle is the entire anti-hallucination value proposition of the agent (per the sub-slicing record line 98: "The challenge-refine cycle is where the anti-hallucination value of the agent lives"). Shipping the architecture with the named failure mode unaddressed weakens the central claim.

### Why this matters

If the self-challenge in one context degenerates to self-confirmation, the challenge_notes[] field becomes window-dressing — present but devoid of real signal. The downstream cross-check (parent S3) inherits the same blindness. The cost of catching this later is a redesign of the agent's reasoning architecture (e.g., second-pass dispatch, fresh sub-context, explicit "now act as challenger" prompt segment with clear instructions to disagree). Catching it now is cheaper — see O6 for one alternative.

## O4 — specification quality — medium

### Claim

The five-question challenge's questions are dimension-flavoured (§3.5 says "domain elements pressure-test against question 5 most heavily, architectural elements against question 1") but the agent file's protocol does not say how this flavouring is operationalised. An implementer reading §4.3 "apply the five-question challenge to each" will produce the same prompt for both dimensions; the dimension-flavouring is implementation-implicit.

### Evidence

§3.5 paragraph 2: "The five questions are dimension-agnostic but apply with dimension-flavoured emphasis: domain elements pressure-test against question 5 most heavily (the textbook definition trap), and architectural elements pressure-test against question 1 most heavily (the smeared two services trap)."

§4.3 protocol: "apply the five-question challenge to each, populating challenge_notes[]" — no dimension-aware step. The agent file's "The five-question challenge" section is described as "the questions from §3.5, copy-pasted, with one paragraph per question explaining what it is looking for" (§4.3) but does not specify the dimension-flavoured emphasis as a separate step.

### Why this matters

If the agent file does not operationalise the dimension-flavouring, the spec's claim that "the protocol is dimension-flavoured" is decorative. The implementer can build a correct agent file that ignores the flavouring and the spec's acceptance scenarios all pass. The cost is a weaker output: domain elements that fail to pressure-test against textbook-definition drift, architectural elements that smear services. Fix is cheap — name the flavouring as a per-element step in §4.3.

## O5 — scope — medium

### Claim

The spec ships a how-to page and an explanation page in the same PR as the agent file, but never explains how a human actually invokes the agent. The how-to page is said in §6.5 to "name the input form (scope)" but the agent is dispatched by Claude Code's Task tool — the actual invocation pattern (which command? what slash-command? direct Task tool? no command at all?) is unspecified. The spec describes the agent as if dispatchable but does not describe the dispatch surface.

### Evidence

§2.1: "The agent does not enforce one form."

§6.5: "I navigate to docs/plugins/diagnostic-legibility/how-to/, Then there is a page on invoking the diagnostic-legibility agent, And the page names the input form (scope)."

§7.1 ships the how-to page.

But nowhere in §2 (the agent's contract) or §4 (the agent file) does the spec say how the agent is invoked. The sibling model-card-researcher is dispatched by the `/model-card` command (`model-cards/commands/model-card.md` exists); the diagnostic-legibility plugin has no command, and the spec adds none. The how-to page is asked to document an invocation pattern the plugin does not provide.

### Why this matters

A how-to page that documents a non-existent invocation pattern either (a) ships with hand-wavy instructions like "use the Task tool with subagent_type: diagnostic-legibility" that don't actually work in the Claude Code product, or (b) ships with instructions for an invocation surface that should have been part of this slice but was overlooked. The spec must either add a `/diagnostic-legibility` command to the file inventory (§7.1) or explicitly document the bare-Task-tool dispatch pattern as the invocation surface.

## O6 — alternatives — medium

### Claim

§3.4 considers and rejects "second-pass challenger agent dispatch" purely on the basis of file-surface cost ("that doubles the surface area to maintain for a v0.3.0 capability"). It does not weigh the alternative of running the challenge step in a fresh sub-context within the same agent file (e.g., the agent could spawn a sub-task or restart its reasoning with a clean slate to act as challenger). That alternative gets the independence benefit without the second-file cost.

### Evidence

§3.4: "A second-pass dispatch would need a separate challenger agent with its own file, charter, and tool boundary. That doubles the surface area to maintain for a v0.3.0 capability."

The set of considered alternatives is binary: (a) one-context self-challenge, (b) two-agent dispatch. The middle option — same agent, two reasoning contexts (e.g., "now drop everything you concluded and re-read the evidence as a challenger") — is not weighed.

### Why this matters

This middle option is what makes the anti-hallucination value of the cycle defensible without doubling the file surface. It directly addresses the failure mode named in O3 (self-confirmation in shared context) without invoking a second agent file. The spec should at least name and dismiss this alternative or adopt it.

## O7 — specification quality — medium

### Claim

Story 6.3 says the agent should "refuse degenerate outputs" by emitting a low-confidence placeholder — but the schema requires LegibilityElement.evidence to have at least one entry when confidence is medium or high, and permits empty evidence only when confidence is low. The "refuse degenerate output" rule is internally consistent with the schema only if the placeholder element carries low confidence AND empty evidence — meaning the agent's response to "I couldn't find anything" is structurally indistinguishable from "I found a candidate I have no evidence for". The two failure modes need separate signal.

### Evidence

§6.3: "And that element has confidence: low / And its description names the degenerate scope condition."

Schema (PR #336 §3.3): "evidence must have at least one entry when confidence is medium or high. low-confidence elements may have empty evidence (the agent flagged a candidate without ground)."

The downstream consumer reading a list of low-confidence elements with empty evidence cannot distinguish "this is a placeholder for empty-scope" from "this is an evidence-less guess".

### Why this matters

A consumer cannot tell whether to retry with a wider scope, abandon the scope, or follow up on a weak candidate. The fix is either (a) a sentinel `name` ("EMPTY_SCOPE" or similar) for the placeholder so consumers can pattern-match, or (b) a top-level field on LegibilityModel like `scope_yielded_results: bool`. Either would resolve the ambiguity without changing the schema's required fields.

## O8 — specification quality — medium

### Claim

The spec names the version target "plugin_version unchanged at v0.39.1" twice (header + §6.4 + §10), but the field's value depends on whatever was current at PR-creation time. If main moves before merge (e.g., another PR ships an ai-literacy-superpowers bump), this PR's marketplace.json edit could either incorrectly downgrade plugin_version or fail the version-consistency check. The spec hard-codes a value that is a function of external main state.

### Evidence

Header: "Marketplace listing | Unchanged at v0.4.0; plugin_version (pointer to ai-literacy-superpowers) unchanged at v0.39.1".

§6.4: "And the plugin_version field is unchanged at \"0.39.1\"".

§10: "plugin_version pointer unchanged at 0.39.1".

The spec's correctness depends on the assumption that ai-literacy-superpowers stays at 0.39.1 from spec-time through merge-time. The check is a cross-repo race condition that the spec acknowledges (header) but does not protect against.

### Why this matters

The integration-agent's pre-merge rebase will surface a conflict on `marketplace.json` if main has moved; the human resolving the conflict needs to know which side wins. The spec should say: "if main has bumped ai-literacy-superpowers in the interim, take main's plugin_version and leave the diagnostic-legibility entry's version bump." A one-line clarification in §9 (Compatibility and rollout) closes the gap.

## O9 — alternatives — low

### Claim

§3.3 commits to a shared protocol across both dimensions. The decision rests on "the schema is shared (PR #336 settled this); the prompt construction is symmetric." But the schema being shared (one record type) does not imply the construction protocol must be shared. The agent could legitimately use two distinct construction loops — one targeting moving parts, one targeting concepts — with the dimension-flavoured challenge questions §3.5 already hints at. The "symmetric construction" decision is a separate design choice that hides behind the schema decision.

### Evidence

§3.3: "The challenge protocol is the same shape for both architectural and domain elements, parameterised on the dimension. The schema is shared (PR #336 settled this); the prompt construction is symmetric."

Sub-slicing record line 140: "per-model bespoke vs. parameterised prompts" was excluded as a separate slice on the grounds that "the decision follows from the schema decision (same schema → parameterisable; distinct schemas → likely bespoke)".

The implication "shared schema → shared construction" is asserted but not argued; the alternative is parameterised schema with bespoke construction loops.

### Why this matters

Low-severity because the choice is recoverable — even if shared construction proves limiting, the agent file can be rewritten to bifurcate without schema changes. Worth naming so future readers know it was a design choice rather than a necessity.

## O10 — specification quality — low

### Claim

§5.2 "Expected output shape" is presented as truncated YAML but the truncation hides whether the example demonstrates the schema's required `Q<N>` prefix discipline for challenge_notes. Both notes in the example use 'Q1' and 'Q5' prefixes — but §3.5 never establishes Q<N> as a required prefix; it is invented in §5.2 as illustrative.

### Evidence

§5.2 output example:

```yaml
challenge_notes:
  - "Q1 (boundary): initially treated the template and the wrapper as one element..."
```

and

```yaml
challenge_notes:
  - "Q5 (description integrity): first draft was generic..."
```

§3.5 lists the five questions by name but never names a prefix format. §5.2 narration: "the Q<N> prefix in challenge_notes linking back to the five-question structure." The format is introduced in §5.2 as if established, but it isn't established anywhere. Either §3.5 should mandate the prefix or §5.2 should describe it as an example convention rather than a requirement.

### Why this matters

Low-severity formatting concern, but it affects machine-readability of challenge_notes downstream. If §3.5 mandates the `Q<N>` prefix, the cross-check (parent S3) can group notes by question; if not, consumers cannot rely on the convention. Cost of fixing: one sentence in §3.5 either way.

## Explicitly not objecting to

- **The choice of retained-challenge single-pass (option b) over option (a) or (c).** The rationale in §3.1 and §3.2 is well-evidenced — the schema already commits to `challenge_notes[]` as load-bearing, so option (a) self-contradicts; option (c) introduces a stopping-condition sub-decision with no signal to justify it. Option (b) is the right call.
- **The tool boundary (Read, Glob, Grep).** Matches the three sibling read-only emitters and is consistent with the project's "agent-emit + dispatcher-persist + human-disposes" architecture named in AGENTS.md ARCH_DECISIONS. No challenge here.
- **The agent name `diagnostic-legibility` matching the plugin name.** Reasonable convention when there is exactly one agent in a plugin; the carpaccio and choice-cartographer agents do the same within their plugins.
- **The version bump 0.2.0 → 0.3.0 as a minor (adding behaviour) rather than a major.** Pre-1.0 semver per CLAUDE.md says minor for behavioural changes; this is textbook.
- **The deliberate exclusion of cross-check (parent S3) and surfacing (parent S4) from this slice.** Carpaccio's parent slicing record is explicit on this; revisiting at sub-slice level would be re-slicing.
- **The 150–250 line target for the agent file.** Comparable to siblings; not load-bearing on correctness.
- **The free-text scope input form (§2.1).** Matches the model-card-researcher's permissive input style; downstream tightening is possible if it earns its keep.
- **The docs site folder pattern (how-to + explanation quadrants only).** Per CLAUDE.md "A quadrant folder is created only when the plugin has at least one page in that quadrant" — the spec ships exactly the two quadrants it has content for, no scaffolding theatre.
