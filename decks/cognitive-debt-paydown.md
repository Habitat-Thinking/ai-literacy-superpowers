# Paying down cognitive debt at AI speed

Slide-deck source for the talk on how this framework's three
mechanisms — the Choice Cartographer, the Advocatus Diaboli, and the
alternative-options architecture for design and development agents —
intercept cognitive debt at named gates.

Intended consumer: Claude Design (or any markdown-driven deck tool).
Each `## Slide N` heading is one slide. Bullets are slide content.
`Speaker note:` lines are presenter prose, not slide text. Citations
in backticks point at the canonical source in this repo.

## Assumptions

- **Audience**: engineering leaders and AI-literate practitioners who
  already accept that AI accelerates production. They want to
  understand how this framework keeps humans owning the *why*.
- **Length**: ~9 slides, structured in three acts —
  problem → mechanisms → composition.
- **Vocabulary**: the framework's own terms — *cognitive debt*,
  *intent debt*, *silences*, *Henney-style pattern story*,
  *bounded trust*, *human-cognition gate*.

---

## Slide 1 — Title

- **Title**: *Paying down cognitive debt at AI speed*
- **Subtitle**: The Cartographer, the Diaboli, and choice architecture
  for agent pipelines

Speaker note: open by naming the gap. AI production is fast; human
understanding is slow. The space between them is where cognitive
debt accumulates.

Suggested visual: two arrows of unequal length. The upper arrow
("AI production rate") is long; the lower arrow ("Human understanding
rate") is shorter. The space between them is labelled *cognitive debt*.

---

## Slide 2 — The four debts cycle

- **Claim**: Cognitive debt is not the same as technical debt. It
  sits one ring out, and it feeds tech debt.
- The cycle:
  - Governance debt → intent debt
  - Intent debt → cognitive debt
  - Cognitive debt → technical debt
  - Technical debt → governance debt
- **Why it matters**: unlike technical debt (visible in hours),
  governance and cognitive debt manifest over months or years as
  institutional crisis, not failed builds.

Source: `docs/plugins/ai-literacy-superpowers/explanation/governance-as-meaning-alignment.md:64-79`

Speaker note: cognitive debt is what AI accelerates most aggressively.
Tech debt is downstream — by the time the build breaks, the
understanding broke months ago.

Suggested visual: the four-debt loop as a closed cycle. Use this same
diagram again on Slide 7.

---

## Slide 3 — Where silences accumulate

- **Claim**: Cognitive debt enters through *silences* — in the spec,
  in the review, and in the dispatch.
- Three silences:
  - **Spec silences** — defaults from a framework or AI training
    prior slip in unannounced.
  - **Review silences** — reviewers approve because the output
    looks plausible.
  - **Dispatch silences** — the pipeline runs end-to-end without
    the human owning any choice.

Source: `docs/plugins/ai-literacy-superpowers/explanation/decision-archaeology.md:20-37`
— "Intent debt is the gap between what the team wanted and what the
spec wrote down. It accumulates in silences."

Speaker note: silences are not failures of attention; they are
predictable artefacts of speed. The framework's mechanisms exist to
make the silences audible.

---

## Slide 4 — Mechanism 1: the Choice Cartographer

- **Claim**: Pays down *intent debt* before it becomes cognitive debt.
- How it works:
  - Reconstructs the decisions a spec has *implicitly* committed to.
  - Emits each as a named, Henney-style pattern story with explicit
    disposition: `accepted` / `revisit` / `promoted`.
  - Read-only trust boundary — the cartographer cannot write the
    spec, so the human must dispose of each story before plan
    approval.

Source: `ai-literacy-superpowers/skills/choice-cartographer/SKILL.md:3`
— "pays down intent debt before plan approval."

Enforcement: HARNESS.md constraint *PRs have adjudicated choice stories*
gates merge on dispositions being resolved.

Suggested visual: a spec page with three hidden choices being lifted
out into named pattern cards, each with a disposition slot.

---

## Slide 5 — Mechanism 2: the Advocatus Diaboli

- **Claim**: Pays down *cognitive debt* by forcing rationale exposure
  under adversarial pressure.
- How it works:
  - Steel-manned objections across six categories — premise, design,
    threat, failure, and others.
  - Runs in two modes — **spec-time** (before plan approval) and
    **code-time** (after the final code-reviewer PASS).
  - Discloses what was *not* challenged. The disclosed silence is
    itself an artefact.

Source: `ai-literacy-superpowers/agents/advocatus-diaboli.agent.md`,
`ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md`

Enforcement: HARNESS.md constraint *PRs have adjudicated objections*
requires both spec-mode and code-mode records with all dispositions
resolved.

Suggested visual: a spec page with six red flags planted; each must
be answered or dismissed with rationale.

---

## Slide 6 — Mechanism 3: alternative-options architecture for agents

- **Claim**: Pays down cognitive debt *at every dispatch point* by
  making the human the chooser, not the consumer.
- Three places the orchestrator presents options:
  - **Which agent** — scope inspection at
    `ai-literacy-superpowers/agents/orchestrator.agent.md:76-88`
    surfaces TDAD-aware vs generic test paths.
  - **Which model** — `MODEL_ROUTING.md` routes spec and review work
    to the most capable model; implementation and integration to
    standard models.
  - **Which trust boundary** — each agent runs read-only or
    write-bounded. The boundary is what forces a human to dispose.

Frame: *choice is cognition*. The orchestrator never auto-flows past
a decision.

Speaker note: this is the slide most likely to underwhelm — "agent
choice" sounds infrastructural. Lead with the phrase *choice is
cognition*. Without it, the audience hears configuration, not
debt-payment.

---

## Slide 7 — How the three compose in the pipeline

- **Claim**: Three different mechanisms intercept three different
  debts — and they stack in the same pipeline.
- Pipeline order:
  1. `spec-writer`
  2. `advocatus-diaboli` (spec mode) — intercepts cognitive debt at
     intent formation
  3. `choice-cartographer` — intercepts intent debt
  4. **plan approval (human gate)**
  5. `tdd-agent`
  6. implementer(s)
  7. `code-reviewer`
  8. `advocatus-diaboli` (code mode) — intercepts cognitive debt at
     delivery
  9. `integration-agent`

Source: `ai-literacy-superpowers/agents/orchestrator.agent.md`

Speaker note: each gate is a *human-cognition gate*. The pipeline is
engineered to refuse to be a conveyor belt. The composition matters
more than any single mechanism — alone, each would be evadable.

Suggested visual: horizontal pipeline diagram with the four-debt loop
overlaid above the gates, showing which debt each gate pays down.

---

## Slide 8 — Evidence and instrumentation

- **Claim**: These mechanisms are enforced and observed, not
  aspirational.
- Constraints (HARNESS.md):
  - *PRs have adjudicated objections* — agent-enforced.
  - *PRs have adjudicated choice stories* — agent-enforced.
- Garbage collection (HARNESS.md):
  - *Objection record freshness* — re-flags stale records weekly.
- Snapshot signal:
  - *Sustainable Pace* field (added 2026-05-11) — tracks the
    depletable-collaborator signal, the human-side cost of
    sustained cognitive engagement.
- Quarterly literacy assessments confirm operational adoption
  (`assessments/2026-05-11-assessment.md` — Level 5, third
  consecutive sitting).

---

## Slide 9 — What is still owed

- **Claim**: Human-cognition gates only pay down debt if humans
  actually engage. The mechanisms are *necessary*, not *sufficient*.
- Open risks:
  - **Rubber-stamp disposition** — "accept all" without reading the
    rationale.
  - Disposition itself is not yet adversarially observable.
  - Cognitive debt is still measured at incident time, not at
    observation time.
- **Close**: the framework does not eliminate cognitive debt — it
  makes it *visible* and pays it down *deliberately, at named gates*.

Speaker note: the honest close. The mechanisms shift the load back
to humans at the decision points that matter; they do not absolve
humans of doing the thinking. That is the whole point.

---

## Framing notes for the deck builder

- Reuse the four-debt loop diagram on Slide 2 and Slide 7. Same
  mental model paying off twice.
- Slide 6 needs the *choice is cognition* line. Without it, the
  audience hears configuration, not debt-payment.
- If the deck must drop to 6 slides:
  - Fold Slide 3 into Slide 2 (silences become a third bullet on the
    cycle slide).
  - Fold Slide 8 into Slide 9 ("Evidence and open questions" as one
    closing slide).
- If the deck must drop to 4 slides:
  - Title, four-debt cycle + silences, the three mechanisms as a
    composed pipeline (Slide 7's diagram), open questions.
