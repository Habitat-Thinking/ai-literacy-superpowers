---
spec: docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md
date: 2026-05-09
mode: spec
diaboli_model: claude-opus-4-7[1m]
objections:
  - id: O1
    category: specification quality
    severity: high
    claim: "A2.2 specifies a deterministic CI workflow but its prose is not yet implementable without the implementer making load-bearing decisions about ref resolution, frontmatter parsing, and missing-directory handling."
    evidence: "A2.2 Tool entry: '.github/workflows/tdad-scenario-check.yml (runs a small bash check that lists added files matching the canonical paths via git diff --name-only --diff-filter=A, then verifies that tdad_tests/scenarios/<type>/<name>/ contains at least one non-FINDING- prefixed file with tier: in {structural, trigger, behavioural})'. Compare with the existing spec-first-check.yml (130 lines including ref resolution, exemption handling, error messages) — the prose hand-waves all of that."
    disposition: accepted
    disposition_rationale: "Fixed in implementation, not spec. A2.7 step 3 will inline the bash explicitly, patterned after spec-first-check.yml — resolve BASE via origin/${{ github.base_ref }}, walk git diff --name-only --diff-filter=A \"$BASE..HEAD\", parse YAML frontmatter using Python invocation of tdad_tests/runner/scenario.py's existing Scenario.parse helper. The hand-wave is acceptable at spec level once the implementation step names the pattern to follow."
  - id: O2
    category: specification quality
    severity: high
    claim: "A2.2 specifies git diff --name-only --diff-filter=A with no comparison ref; existing analogous project workflows all specify origin/${{ github.base_ref }}...HEAD explicitly. An implementer picking the wrong default will produce a check that silently misses multi-commit PRs."
    evidence: "A2.2: 'lists added files matching the canonical paths via git diff --name-only --diff-filter=A' — no ref. version-check.yml:147 (existing pattern): git diff --name-only \"origin/${{ github.base_ref }}...HEAD\" -- 'ai-literacy-superpowers/'. spec-first-check.yml:67-80: BASE=\"origin/$BASE_REF\" then git rev-list --reverse \"$BASE\"..HEAD."
    disposition: accepted
    disposition_rationale: "Subsumed by O1's fix — the same workflow inline will use origin/${{ github.base_ref }}...HEAD per the project pattern at version-check.yml:147. Resolved together with O1 in the implementation step."
  - id: O3
    category: implementation
    severity: medium
    claim: "A2.4's amendment-redacted HTML comment markers are invisible in every rendered markdown surface (GitHub PR view, mkdocs material, docs site). The contradicted prose renders with no warning; the fix is illusory for any reader on a rendered surface."
    evidence: "A2.4: 'The amendment-redacted markers are added inline in the original text below to flag the contradicted sentences for readers.' The marker is an HTML comment wrapping superseded prose. GitHub markdown renderers and mkdocs strip HTML comments; the visible rendered output shows only the contradicted prose."
    disposition: accepted
    disposition_rationale: "Fixed in implementation by replacing the three <!-- amendment-redacted: ... --> HTML comments with visible > **SUPERSEDED by Amendment N §X.Y**: ... blockquote prefixes. Three mechanical edits; closes the rendered-surface gap immediately. The agent's catch was right — the original choice of HTML comments was a markdown-literacy slip; visible blockquote markers preserve the redaction signal across raw and rendered surfaces alike."
  - id: O4
    category: implementation
    severity: medium
    claim: "A2.5 directs the implementer to add a one-sentence preamble to the new tdd-agent branch about RED's semantic extension, but this is instruction-to-the-implementer with no enforcement path. The deterministic check in A2.2 cannot inspect agent prose. If the preamble matters, it belongs in A2.7 step 1 as a verifiable acceptance condition."
    evidence: "A2.5: 'when authoring the agent-artefact branch in tdd-agent.agent.md, the implementer must … (c) add a one-sentence preamble at the top of the new branch noting that RED carries a semantic extension specifically inside this branch.' A2.7 step 1 cites '(per A1.5 + A2.5)' but does not separately name the preamble as load-bearing."
    disposition: deferred
    disposition_rationale: "Acknowledged as soft guidance rather than enforced behaviour. The deterministic check cannot inspect agent prose; promoting the preamble to a verifiable item would require Layer 3 SDK assertions (deferred per A2.8) or mechanical inspection of agent file content (out of scope for the workflow). The code-mode /diaboli pass after implementation will catch the omission if it occurs — that's the natural catch-net for instruction-to-implementer items at this level. Acceptable to ship with current soft-guidance framing."
  - id: O5
    category: specification quality
    severity: medium
    claim: "A2.3's filename-prefix rule and A2.2's tier whitelist are framed as defence-in-depth but collapse to a single substantive filter once the existing FINDING-prefix invariant is recognised. The compound check is muddled rather than layered."
    evidence: "A2.2: 'at least one non-FINDING- prefixed file with tier: in {structural, trigger, behavioural}'. test_layer3_behavioural.py:309 enforces FINDING- prefix → tier=finding (one-directional only). A scenario with tier=finding and no FINDING- prefix is current-corpus-legal and would still fail the new check; the spec does not name this case."
    disposition: accepted
    disposition_rationale: "Fixed in implementation by simplifying the workflow's check to the substantive filter only — exclude scenarios with tier: finding. The corpus invariant (FINDING- prefix → tier=finding, enforced at test_layer3_behavioural.py:309) means the prefix exclusion adds no coverage beyond the tier check. Spec text gets a clarifying inline edit during implementation noting that the substantive filter is tier-based; FINDING- prefix remains relevant only to the runner's separate dispatch logic."
  - id: O6
    category: specification quality
    severity: low
    claim: "Vocabulary slip between <descriptor>.md and <aspect>.md for the same scenario filename. A1.4 establishes <aspect>.md as canonical; A2.2 reverts to <descriptor>.md once; the original §6 and §7 also use <descriptor>.md."
    evidence: "<descriptor>.md appears at lines 58, 627, 745. <aspect>.md appears at lines 54, 95, 99, 148, 177, 247, 270, 312-325, 414. A1.4:322 declares <aspect>.md canonical but does not retire <descriptor>.md as a synonym."
    disposition: accepted
    disposition_rationale: "Trivial mechanical fix during implementation: global-replace <descriptor>.md with <aspect>.md throughout the spec. No design implications, ~30 seconds of editing. The agent prose that lands in tdd-agent.agent.md will then inherit the canonical placeholder consistently."
  - id: O7
    category: scope
    severity: medium
    claim: "The pivot's forward-only stance is honest but the modified agent files (orchestrator.agent.md, tdd-agent.agent.md) will ship with no in-place forward-pointer to A2.6's modification clause. A future reader of the agent file or the absent scenario directory has no signpost back to this spec."
    evidence: "A2.6: 'This PR (the one shipping Amendment 2) is itself a modification PR under the rule above. No scenarios are authored for the orchestrator or tdd-agent edits; the discipline applies forward.' A2.7 has eight steps; none leaves a forward-pointer in the agent files or in the (absent) scenario directories."
    disposition: accepted
    disposition_rationale: "Fixed in implementation by adding a two-line comment near the top of both orchestrator.agent.md and tdd-agent.agent.md linking forward to this spec and naming Amendment 2 §A2.6 as the reason for the absent scenario directory. The implementation plan (A2.7) gains a new sub-step. Closes the gap A2.6 explicitly acknowledged was open; future contributors who modify these agent files and ask 'why is there no scenario here?' will find the answer in the file itself rather than having to discover the spec."
  - id: O8
    category: alternatives
    severity: low
    claim: "A2.8 defers a Layer 1 non-empty-Then test as a follow-up but does not weigh the alternative of adding the same grep to the deterministic workflow now. Cost is a few lines of bash; coverage gain closes a known bypass."
    evidence: "A2.8: 'bad scenarios can pass the deterministic check (the check only verifies presence and tier, not falsifiability of Then clauses)… A Layer 1 test asserting non-empty Then sections is a follow-up if quality drift becomes observable.' The cheap-now alternative is not weighed against the deferred Layer 1 path."
    disposition: deferred
    disposition_rationale: "Real coverage opportunity, but consistent with the spec's forward-only stance and A2.8's existing deferral. Substantive-quality enforcement (non-empty Then, non-trivial Rubric) is the job of human review at the orchestrator's RED-phase soft surface and a future Layer 1 test. The decision to defer is principled rather than oversight; adding it now would expand the new workflow's scope beyond 'did you author a non-finding-tier scenario?' which is the simple, focused thing the constraint is meant to verify."
---

# Adversarial Review — orchestrator-tdad-discipline-design (post Amendment 2 — third pass, dispositions resolved)

Spec under review: `docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md`
Mode: `spec`. Reviewer: `claude-opus-4-7[1m]`. Eight objections raised: 2 high (O1, O2), 4 medium (O3, O4, O5, O7), 2 low (O6, O8). All dispositions resolved 2026-05-09: 6 accepted (with implementation-step fixes named), 2 deferred (consistent with A2.8's named limitations).

The pivot in Amendment 2 substantively closed the harder concerns from prior passes. What remains is implementation polish — particularly around the deterministic check's bash specificity (O1, O2, both fixed in implementation), the visibility of redaction markers (O3, fixed in implementation), and the absence of an in-place forward-pointer for future readers of the modified agent files (O7, fixed in implementation). The agent's own assessment is that pass three is hitting diminishing returns: the spec is "within the band where further objection becomes pattern-matching rather than reasoning."

## O1 — specification quality — high

### Claim

A2.2 specifies a deterministic CI workflow at `.github/workflows/tdad-scenario-check.yml` but its prose is not yet implementable without the implementer making load-bearing decisions: which git ref to diff against, how to enumerate candidate scenario files in the matching component directory, how to parse YAML frontmatter from each candidate to read `tier`, and what to do when the directory does not yet exist (a brand-new component's scenarios directory is itself an added path). One sentence of prose is being asked to do the work of the 130-line `spec-first-check.yml`.

### Evidence

A2.2's Tool entry:

> `.github/workflows/tdad-scenario-check.yml` (runs a small bash check that lists added files matching the canonical paths via `git diff --name-only --diff-filter=A`, then verifies that `tdad_tests/scenarios/<type>/<name>/` contains at least one non-`FINDING-`-prefixed file with `tier:` in `{structural, trigger, behavioural}`)

Compare with `spec-first-check.yml` lines 56–129 — exemption handling, ref resolution (`BASE="origin/$BASE_REF"`), explicit error messages, label-vs-prefix logic. The new workflow needs an analogous shape but the spec does not provide it.

### Disposition: accepted

Fixed in implementation, not spec. A2.7 step 3 will inline the bash explicitly, patterned after `spec-first-check.yml` — resolve BASE via `origin/${{ github.base_ref }}`, walk `git diff --name-only --diff-filter=A "$BASE..HEAD"`, parse YAML frontmatter using Python invocation of `tdad_tests/runner/scenario.py`'s existing `Scenario.parse` helper. The hand-wave is acceptable at spec level once the implementation step names the pattern to follow.

## O2 — specification quality — high

### Claim

A2.2 says `git diff --name-only --diff-filter=A` with no comparison ref. The project's existing analogous workflows (`spec-first-check.yml`, `version-check.yml`) all specify `origin/${{ github.base_ref }}...HEAD` or `"$BASE..HEAD"` explicitly because PR-only branches lack a sensible default. The spec leaves this implicit; the implementer who picks the wrong default will produce a check that passes by accident on most PRs and fails on the first multi-commit branch.

### Evidence

A2.2: "lists added files matching the canonical paths via `git diff --name-only --diff-filter=A`" — ref unspecified.

`version-check.yml` line 147 (existing pattern): `git diff --name-only "origin/${{ github.base_ref }}...HEAD" -- 'ai-literacy-superpowers/'`.

`spec-first-check.yml` lines 67–80: `BASE="origin/$BASE_REF"` then `git rev-list --reverse "$BASE"..HEAD`.

### Disposition: accepted

Subsumed by O1's fix — the same workflow inline will use `origin/${{ github.base_ref }}...HEAD` per the project pattern at `version-check.yml:147`. Resolved together with O1 in the implementation step.

## O3 — implementation — medium

### Claim

A2.4 introduces `<!-- amendment-redacted -->` HTML comment markers to "flag the contradicted sentences for readers." HTML comments are invisible in every rendered markdown surface (GitHub PR view, mkdocs material, the docs site). The contradicted prose at the §1, §3, §5 redaction sites will render with no warning. Readers using the rendered surface will not see the marker; only readers of the raw `.md` file in an editor will.

### Evidence

A2.4: "The `<!-- amendment-redacted -->` markers are added inline in the original text below to flag the contradicted sentences for readers."

The line immediately after each marker is the contradicted prose. Render this in any markdown viewer — the warning vanishes.

### Disposition: accepted

Fixed in implementation by replacing the three `<!-- amendment-redacted: ... -->` HTML comments with visible `> **SUPERSEDED by Amendment N §X.Y**: ...` blockquote prefixes. Three mechanical edits; closes the rendered-surface gap immediately. The agent's catch was right — the original choice of HTML comments was a markdown-literacy slip; visible blockquote markers preserve the redaction signal across raw and rendered surfaces alike.

## O4 — implementation — medium

### Claim

A2.5 directs the implementer to add a one-sentence preamble to the new tdd-agent branch about RED's semantic extension. This is instruction-to-the-implementer with no enforcement path. The deterministic check in A2.2 only verifies scenario file presence; it cannot inspect agent prose.

### Evidence

A2.5: "when authoring the agent-artefact branch in tdd-agent.agent.md, the implementer must (a) include the new A1.5 RED definition for modifications, (b) keep the existing 'Confirming red' prose for the generic-test path unchanged, and (c) add a one-sentence preamble at the top of the new branch noting that 'RED' carries a semantic extension specifically inside this branch."

A2.7 step 1: "Edit `ai-literacy-superpowers/agents/tdd-agent.agent.md` — add the agent-artefact branch with the modification-branch RED semantics (per A1.5 + A2.5)…" — does not separately call out the preamble as a verifiable item.

### Disposition: deferred

Acknowledged as soft guidance rather than enforced behaviour. The deterministic check cannot inspect agent prose; promoting the preamble to a verifiable item would require Layer 3 SDK assertions (deferred per A2.8) or mechanical inspection of agent file content (out of scope for the workflow). The code-mode `/diaboli` pass after implementation will catch the omission if it occurs — that's the natural catch-net for instruction-to-implementer items at this level. Acceptable to ship with current soft-guidance framing.

## O5 — specification quality — medium

### Claim

A2.3's filename-prefix rule and A2.2's tier whitelist together create a compound check whose two halves are not orthogonal. The current corpus invariant (`test_layer3_behavioural.py:302-312`) is one-directional: `FINDING-` prefix implies `tier: finding`, but the converse is not enforced.

### Evidence

A2.2: "verifies that `tdad_tests/scenarios/<type>/<name>/` contains at least one non-`FINDING-`-prefixed file with `tier:` in `{structural, trigger, behavioural}`."

`test_layer3_behavioural.py:309`: `assert finding.tier == "finding"` (FINDING- → tier=finding direction only).

A2.3: "Files with `tier: finding` do NOT satisfy the constraint (they are documentary, not falsifiable…)" — names the tier check as the substantive filter.

### Disposition: accepted

Fixed in implementation by simplifying the workflow's check to the substantive filter only — exclude scenarios with `tier: finding`. The corpus invariant (FINDING- prefix → tier=finding, enforced at `test_layer3_behavioural.py:309`) means the prefix exclusion adds no coverage beyond the tier check. Spec text gets a clarifying inline edit during implementation noting that the substantive filter is tier-based; FINDING- prefix remains relevant only to the runner's separate dispatch logic.

## O6 — specification quality — low

### Claim

The spec uses two placeholder names for the same scenario filename: `<aspect>.md` (canonical, established by A1.4 with citations to the existing corpus) and `<descriptor>.md` (used in A2.2, the original §6, and the original §7).

### Evidence

`<descriptor>.md`: lines 58, 627, 745. `<aspect>.md`: lines 54, 95, 99, 148, 177, 247, 270, 312-325, 414. A1.4 line 322: "**`tdad_tests/scenarios/<type>/<name>/<aspect>.md`**" — declared canonical.

### Disposition: accepted

Trivial mechanical fix during implementation: global-replace `<descriptor>.md` with `<aspect>.md` throughout the spec. No design implications, ~30 seconds of editing. The agent prose that lands in `tdd-agent.agent.md` will then inherit the canonical placeholder consistently.

## O7 — scope — medium

### Claim

The pivot's central trade — discipline applies forward, not retroactively or self-referentially — is honest, but the artefact a future reader will encounter does not signpost its own exemption. `orchestrator.agent.md` and `tdd-agent.agent.md` will ship modified with no corresponding scenario directory; a future reader running the pipeline against these files (or a future GC rule walking `tdad_tests/scenarios/agents/`) has no in-place pointer back to A2.6's modification clause.

### Evidence

A2.6 final paragraph: "This PR (the one shipping Amendment 2) is itself a modification PR under the rule above. No scenarios are authored for the orchestrator or tdd-agent edits; the discipline applies forward."

A2.7: eight implementation steps, none of which leave a forward-pointer in the agent files or the absent scenario directories.

### Disposition: accepted

Fixed in implementation by adding a two-line comment near the top of both `orchestrator.agent.md` and `tdd-agent.agent.md` linking forward to this spec and naming Amendment 2 §A2.6 as the reason for the absent scenario directory. The implementation plan (A2.7) gains a new sub-step. Closes the gap A2.6 explicitly acknowledged was open; future contributors who modify these agent files and ask "why is there no scenario here?" will find the answer in the file itself rather than having to discover the spec.

## O8 — alternatives — low

### Claim

A2.8 acknowledges that bad scenarios with empty `Then` sections pass the deterministic check, and defers a Layer 1 non-empty-Then test as a follow-up. The alternative of including a `## Then` non-empty grep in the same workflow now is not weighed.

### Evidence

A2.8: "bad scenarios can pass the deterministic check (the check only verifies presence and tier, not falsifiability of `Then` clauses). Mitigation: the tdd-agent's RED-phase output is surfaced to the user before the implementer is dispatched; user reviews scenario quality. A Layer 1 test asserting non-empty `Then` sections is a follow-up if quality drift becomes observable."

### Disposition: deferred

Real coverage opportunity, but consistent with the spec's forward-only stance and A2.8's existing deferral. Substantive-quality enforcement (non-empty `Then`, non-trivial Rubric) is the job of human review at the orchestrator's RED-phase soft surface and a future Layer 1 test. The decision to defer is principled rather than oversight; adding it now would expand the new workflow's scope beyond "did you author a non-finding-tier scenario?" which is the simple, focused thing the constraint is meant to verify.

## Explicitly not objecting to

- **The pivot itself (forward-only discipline, no self-demonstration).** Two prior `/diaboli` passes pushed on the self-application question; Amendment 2's choice to drop the in-PR scenarios rather than ship Layer-1-only paperwork is honest and defensible.
- **Switching enforcement from agent to deterministic.** A2.2's choice to use a deterministic CI workflow rather than the harness-enforcer agent is correct for this rule's shape (file-presence + frontmatter-key check, no judgement).
- **Naming FINDING- as a separate artefact category.** A2.3's explicit recognition that FINDING- coexists with `<aspect>.md` is the right shape.
- **Layer-targeting precedence (A1.6).** Deferring to the per-component judgement in `command-tdad-testing-design.md` when defaults conflict is the right call.
- **Numbering hygiene across A1.7 and A2.7.** A2.7 explicitly states it replaces A1.7; the two-amendment structure is auditable.
- **Plugin version bump and ceremony rationale (A1.8 / original §6).** The choice of feature ceremony for a behavioural change to two shipping agents is well-justified.
- **Diminishing returns at pass three.** Two prior passes were thorough; this third pass surfaces eight concerns, all medium-or-below except O1/O2 which are about deterministic-check implementability rather than design soundness.
