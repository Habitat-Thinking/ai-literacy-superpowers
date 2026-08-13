# The Cadence Sentinels — epic charter

The constitutional constraints, non-goals, and working style that governed
slices S1–S7 (2026-08-08 → 2026-08-13, plugin versions 0.67.0 → 0.73.2).

## Why this file exists

Seven specs in this epic cite these constraints **by number** — "constraint 3",
"constraint 6", "constraint 7" — and the numbered list was nowhere in the
repository. A reader meeting *"Constraint 7 says records are append-only"* had
no way to see constraints 1 through 9.

The specs also carried a provenance line naming *The Second Front — Arc
Insertion Remit*, a slide deck that does not exist in this repository or in
`ai-literacy-for-software-engineers`, and never did. The epic originated in a
**build spec supplied in conversation** on 2026-08-08; the deck title was a
label for that remit rather than a document anyone can retrieve.

A second title, *Compulsive Continuation — A Research Exploration*, was cited by
S1–S4 as the evidence base. It is not in either repository either. **The
evidence itself is not missing** — every `<!-- evidence: ... -->` comment in the
skills cites named, published work inline (distributed cognition, the vigilance
decrement, task-switching cost, Ulysses pacts), and those citations are
retrievable. What did not exist was the umbrella document.

**This file is the transcription.** The constraints below are quoted verbatim
from that build spec. Where a slice's own spec argues with one — S5's O2 on the
enforcement enum, for instance — the slice's spec is the later and better
authority, and says so.

Per-slice scope lives in the epic's issues: **#491** (S1), **#492** (S2),
**#493** (S3), **#501** (S3b), **#494** (S4), **#495** (S5), **#496** (S6),
**#497** (S7).

## The nine constitutional constraints

Violations were review-blockers.

1. **Sentinels are read-only.** No Write/Edit tools for any new agent, with one
   narrowly scoped exception: the Coda may append to its own record files —
   never to source, specs, or `HARNESS.md`.
2. **Agents propose, humans dispose.** Every gate terminates in a human
   disposition recorded in the relevant record file. No sentinel ever
   auto-blocks silently or auto-approves.
3. **Honesty flags.** Every observation a sentinel reports is tagged
   `observed` / `inferred` / `asked`, exactly as the Reservoir Warden does. If a
   value cannot be observed, the sentinel says so rather than estimating
   silently.
4. **Persist nothing about the person.** Records describe sessions, work,
   budgets, and decisions — never assessments of the human's state, capacity, or
   fatigue.
5. **The Reservoir Warden is untouched.** It remains advisory-forever; gating
   lives in the new sentinels. Do not add strict modes, thresholds-as-gates, or
   new proxies to it in this work.
6. **Progressive hardening.** Every new constraint ships at **Unverified** or
   **Agent-verified** first. Deterministic enforcement is added only in the
   slice that specifies it, and always with an escape hatch: an on-the-record
   human override, never a bypass.
7. **Records are append-only.** Superseded entries are marked superseded, never
   edited.
8. **Evidence comments.** Cite research grounding in `<!-- evidence: ... -->`
   comments in skill files. **Language rule throughout all docs: "compulsive
   pattern," never "addiction"; "reinforcing," never "dopamine."**
9. **Category naming.** These four agents are documented under the **sentinel**
   category.

### Where a constraint was corrected in flight

**Constraint 6's vocabulary was wrong.** It names an "Agent-verified" rung;
`harness-md-format.md` gives the enforcement enum as
`deterministic | agent | unverified`, with no such value. S5's spec gate raised
this (objection O2) and the epic settled on a distinction the charter did not
have: **the rung** is how a check runs, and **the reach** is what it demands.
Progressive hardening applies to reach — a check may ship `deterministic` and
still be *complete-if-present*. See
`docs/plugins/ai-literacy-superpowers/explanation/progressive-hardening.md`.

**Constraint 4 gained a third category.** S1 established *operational state* —
permitted only when local and never committed, bounded, judging nothing, and
disclosed and declinable. It is a narrow carve-out for plumbing, not a route
around the rule; `skills/sentinel-design/SKILL.md` is authoritative, and it
places parking records and consultation dispositions on the **by the person**
side rather than inside the carve-out.

## Non-goals

- No changes to the Reservoir Warden beyond documentation cross-references.
- No deterministic (CI/hook-blocking) enforcement beyond what each slice names.
- No UI beyond existing surfaces; no platform notification enforcement;
  **no contacting humans on anyone's behalf**.
- No renaming or moving of existing agents.

## Working style

Quoted from the build spec:

> Implement slice by slice, in order. Each slice ends with a human review gate —
> do not proceed to the next slice without an explicit go. Where anything below
> conflicts with established repo conventions, **the repo wins**: read the
> existing agents, skills, and commands first, mirror their structure exactly,
> and raise a note in the PR description for every divergence between this spec
> and repo reality.

*The repo wins* was load-bearing. It is why S5 shipped `deterministic` instead
of the charter's `Agent-verified`, why S6 dropped a seventh objection category
once the existing hunt-list mechanism was found, and why S7 shipped one
discipline page rather than four per-agent pages.

## What the epic shipped

Four sentinels — `coda`, `mast`, `wip-warden`, `convener` — plus a
`sentinel` category extension, five hooks, three record contracts, two
deterministic constraints, and six derived parity checks.

See `docs/plugins/ai-literacy-superpowers/explanation/cadence-discipline.md`.
