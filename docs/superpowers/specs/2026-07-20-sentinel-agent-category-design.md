# Spec: Introduce the Sentinel Agent Category

**Status:** Approved
**Date:** 2026-07-20
**Scope:** `ai-literacy-superpowers` plugin only
**Explicitly out of scope:** the `diagnostic-legibility` plugin (no changes, no
migration, no renaming — see Non-Goals)

---

## 1. Problem Statement

The plugin ships sixteen agents, currently presented as a flat table
differentiated only by role description and trust boundary. Hidden inside that
table is a coherent sub-family that has emerged organically: agents whose object
of care is not the codebase, the pipeline, or the harness, but **the human**.
They protect and support the understanding and judgement of the human in the
workflow.

These agents already share a signature — read-only trust boundary, advisory
output, positioning at or feeding a human gate, an explicit honesty rule — but
the category is unnamed. Unnamed categories cannot be documented, enforced,
taught, or extended deliberately. This spec names it.

## 2. Definition

> **Sentinel** — any agent whose primary purpose is to protect and support the
> understanding and judgement of the human in the workflow.

A sentinel acts on the human's epistemic state, not on artefacts. It informs,
challenges, surfaces, or warns — it never fixes, writes, merges, or decides.

## 3. Membership Criteria (the Sentinel Signature)

An agent qualifies as a sentinel if and only if it satisfies all three:

| # | Criterion | Testable form |
|---|-----------|---------------|
| S1 | **Read-only trust boundary** | Agent frontmatter denies Write/Edit (Bash may be permitted for read-only inspection, e.g. `git log`) |
| S2 | **Advisory output for a human** | The agent's output is a record, objection, story, estimate, or recommendation that a *human* disposes; it triggers no automated action |
| S3 | **Explicit epistemic honesty rule** | The agent declares the status of its claims (e.g. observed/inferred/asked flags, objection categories with evidence requirements, refusal-over-fabrication) |

S1 is deterministically CI-checkable. S2 and S3 are agent-verifiable via the
harness-enforcer.

## 4. Sentinel Roster

| Agent | Guards | Signature evidence |
|-------|--------|--------------------|
| `reservoir-warden` | The decider — the verifier's cognitive reservoir | Read-only (no Write/Edit); single decide-your-stop-first recommendation; observed/inferred/asked flags; persists no record of human state |
| `advocatus-diaboli` | Decisions at both gates — spec-time premises, code-time risks | Read-only; six-category objection record disposed by human; evidence requirements per objection |
| `choice-cartographer` | Understanding of implicit decisions | Read-only; choice stories disposed at soft gate; six-lens map declares what was found vs. inferred |
| `carpaccio` | Judgement scale — keeps each decision small enough to hold | Read-only; slice dispositions are a hard human gate |
| `cost-estimator` | The decision's inputs — what a choice will cost before it is made | Read-only; human disposes the estimate record; refuses rather than fabricating an ungroundable estimate |

**Disposition of Open Question 1 (human-approved, 2026-07-20):**
`cost-estimator` **joins the roster**. It satisfies S1–S3 without qualification.
Its object of care is arguably the *decision's inputs* rather than the decider
directly, but supplying a human with a grounded, refusable estimate before they
commit is squarely "protecting and supporting judgement". The adjacent-tier
alternative was rejected as a distinction without an enforceable difference.

### Explicitly not sentinels

`orchestrator`, `spec-writer`, `tdd-agent`, `code-reviewer`,
`integration-agent`, `harness-discoverer`, `harness-enforcer`, `harness-gc`,
`harness-auditor`, `assessor`, `governance-auditor` — each acts on artefacts,
pipeline state, or the harness itself.

`code-reviewer` and `harness-auditor` are near-misses. Both are read-only
(S1 ✓) and both report to a human (S2 ✓). Neither is a sentinel, because the
category turns on the *object of care*, not the trust boundary: the
code-reviewer's object of care is the code, and the harness-auditor's is the
harness. A sentinel's finding is about what the human can or should hold in
mind; a near-miss's finding is about an artefact that happens to be reported to
a human. This distinction is documented in the `sentinel-design` skill's
near-miss gallery so future authors do not read "read-only + advisory" as
sufficient.

## 5. Changes

### 5.1 Agent frontmatter: `role: sentinel`

Add an optional `role` field to agent frontmatter. **Enum with a single
permitted value, `sentinel`** (disposition of Open Question 2). Applied to the
five roster agents in §4. Absence of the field means "pipeline/harness agent" —
no change to existing agents' behaviour. The enum is widened only when a second
category earns a name.

### 5.2 README: Sentinels section

Restructure the *Agents (16)* table into two tables:

1. **Sentinels (5)** — with the definition (§2), the signature (§3), and a
   one-line narrative: *the decision-discipline triad guards decisions; the
   reservoir-warden guards the decider; the cost-estimator guards the decision's
   inputs.*
2. **Pipeline & harness agents (11)** — the existing table, unchanged rows.

No agent is renamed. `carpaccio`, `advocatus-diaboli`, `choice-cartographer`,
and `reservoir-warden` keep their names; "decision-discipline triad" remains
valid vocabulary and is cross-referenced from the Sentinels section.

### 5.3 New skill: `sentinel-design`

A skill documenting the category for humans and agents authoring new sentinels:

- The definition and the three-part signature
- The near-miss gallery (why code-reviewer and harness-auditor don't qualify)
- Design guidance: a sentinel's honesty rule must be written *before* its
  detection logic (mirrors the cognitive-reservoir skill's contested-vs-robust
  science discipline)
- Anti-patterns: a sentinel that scores the human, persists human-state
  records, or gates automatically has left the category

### 5.4 HARNESS constraint: sentinel integrity

New constraint in the plugin's own HARNESS.md:

> Any agent whose frontmatter declares `role: sentinel` MUST NOT be granted
> Write or Edit tools.

- **Verification slot:** deterministic — `sentinel-integrity-check.sh` parses
  agent frontmatter and tool grants.
- **Scope:** pr, via `.github/workflows/harness.yml`.
- **Also a GC rule:** the same script runs in the weekly GC sweep, catching a
  violation introduced by a path that bypassed the PR gate.
- The script additionally rejects a `role:` value outside the enum (§5.1), so a
  typo like `role: sentinal` fails loudly rather than silently exempting the
  agent from the check.

This makes the category *load-bearing* rather than decorative: mislabel an agent
and CI fails.

### 5.5 Docs

- New docs page:
  `docs/plugins/ai-literacy-superpowers/explanation/sentinels.md` — definition,
  signature, roster, narrative framing, extension guide.
- Cross-links from the agent pipeline docs, the decision-discipline-triad page,
  the watching-the-verifier page, and the cognitive-reservoir skill.
- Reference-page entries for the new skill (`reference/skills.md`) and a
  Sentinels grouping note in `reference/agents.md`.

**Disposition of the spec's stated docs path (human-approved, 2026-07-20):**
the spec originally named `docs/plugins/ai-literacy-superpowers/sentinels.md`.
That path sits outside every Diataxis quadrant and conflicts with the
`Docs Site Review` convention in CLAUDE.md, which the `mkdocs-awesome-pages`
nav derivation depends on. The page is placed in `explanation/` instead,
alongside its conceptual neighbours.

### 5.6 `/superpowers-status`: sentinel coverage

**Disposition of Open Question 3 (human-approved, 2026-07-20): yes.**
`/superpowers-status` gains a `Sentinels` line reporting the count of agents
declaring `role: sentinel` and the state of the integrity constraint, e.g.
`5 sentinels active, integrity constraint green`. Reported descriptively; a
sentinel count of zero is not a warning (a downstream project may legitimately
ship none). The constraint state is WARNING only when a violation is detected.

## 6. Non-Goals

- **No changes to the `diagnostic-legibility` plugin.** Its charter
  ("maintaining human understanding") makes it a natural future sentinel host,
  but migration, renaming, or cross-plugin tagging is deferred to a separate
  spec.
- **No agent renames.**
- **No behavioural changes** to any agent — this is categorisation,
  documentation, and one new enforceable constraint.
- **No new gates.** Sentinels feed existing gates; none are added.

## 7. Acceptance Scenarios (TDAD)

1. **Frontmatter tagging** — Given the five roster agents, when the plugin is
   built, then each declares `role: sentinel` and passes schema validation.
2. **Sentinel integrity constraint (green)** — Given all `role: sentinel`
   agents deny Write/Edit, when the CI constraint check runs, then it passes.
3. **Sentinel integrity constraint (red)** — Given a test fixture agent
   declaring `role: sentinel` *and* a Write grant, when the check runs, then CI
   fails with a message naming the agent and the violated criterion (S1).
4. **Unknown role value rejected** — Given a fixture agent declaring a `role`
   value outside the enum, when the check runs, then it fails naming the agent
   and the invalid value.
5. **README structure** — Given the README, then a *Sentinels* section exists
   containing exactly the roster agents, and no agent appears in both tables.
6. **Skill discovery** — Given a session in a project with the plugin
   installed, when an agent is asked to design a new human-guarding agent, then
   the `sentinel-design` skill is loadable and its anti-patterns section is
   present.

## 8. Migration & Rollout

Single minor version bump (0.65.1 → 0.66.0). No breaking changes: the `role`
field is additive, the constraint only binds agents that opt into the tag, and
README restructuring is presentational. `/harness-upgrade` surfaces the new
constraint and skill to downstream projects as optional template content.
