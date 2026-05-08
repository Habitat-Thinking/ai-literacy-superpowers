---
title: Run a Determinacy Calibration Review
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 40
redirect_from:
  - /how-to/run-a-calibration-review/
  - /how-to/run-a-calibration-review.html
---

# Run a Determinacy Calibration Review

Run a periodic calibration review to interpret the signal from
`/harness-audit`, `/harness-gc`, and `REFLECTION_LOG.md` and decide,
for each capability, whether its current placement on the determinacy
spectrum is still correct.

This is a deliberate, evidence-based review activity, not an automated
loop. The plugin's existing commands surface raw signal; this guide
describes the procedure for *interpreting* that signal and producing
calibration decisions — including the decision to leave things alone.

For the conceptual background, see
[Determinacy Calibration](determinacy-calibration.md).

---

## When to run it

Cadence depends on the project's rate of change.

- **End-of-iteration** (every sprint, fortnight, or release cycle)
  for actively-changing projects.
- **Monthly** for steady-state projects with slower change.
- **Quarterly** for portfolio-scale calibration across multiple
  repositories (use `/portfolio-assess` to gather cross-repo signal).

Pick the longest cadence that still catches drift before it
accumulates. A team running calibration every iteration on a slow
project will mostly produce "leave unchanged" decisions and learn to
skip the review. A team running it quarterly on a fast project will
let drift accumulate beyond what the cycle can recover.

The cadence is itself part of calibration. If reviews consistently
produce mostly refusals, the cadence is too tight; if reviews
consistently produce surprises that suggest unrecorded drift, the
cadence is too loose.

---

## 1. Gather signal from the four classes

Calibration is grounded in evidence, not introspection. Open four
sources before starting the review:

```text
# Change records and current health
/superpowers-status

# Drift between declared and runtime state
/harness-audit

# Entropy and rule-bound checks
/harness-gc
```

Then read by hand:

- `REFLECTION_LOG.md` — recent entries (last cycle's worth). Look
  for `Surprise:` text describing improvisation around tooling, and
  for recurring patterns across multiple entries.
- `observability/snapshots/` — recent harness-health snapshots.
  Watch for variance in metrics across nominally identical periods,
  and for trends in script count, hook count, or constraint
  enforcement ratio.

The four signal classes the explanation page describes —
**change records**, **temporal patterns**, **reflection-log
patterns**, and **seam integrity** — map directly to these sources.
You're not reading them looking for problems to fix individually
(audit and GC already do that). You're reading them looking for
*shape*: where is the determinacy distribution shifting, and what
does that shift suggest about which capabilities are now at the
wrong level?

---

## 2. List candidate movements per capability

For each capability surfaced by step 1, write a one-line proposal.
Capabilities include constraints (in `HARNESS.md`), GC rules, hooks,
skills, sub-agent prompts, and orchestrator pipeline stages.

The legitimate proposal types are:

| Type | When |
| --- | --- |
| **Promote** | Agent enforcement has caught the same class reliably; the rule is now expressible deterministically. |
| **Demote** | The deterministic tool is producing false positives, or the team's understanding of the underlying rule has shifted enough that the tool now misclassifies real cases. Move back to agent enforcement. |
| **Split** | One capability is doing two jobs with different determinacy needs. Separate them. |
| **Repair seam** | The capability is at the right level but its surrounding integration has rotted (orphaned references, dead pathways, scripts no skill invokes). Fix the seam without moving the level. |
| **Leave** | The capability is at the right level. The honest output. Surface the candidate even when the decision is to leave — refusals carry information. |

It's normal — and healthy — for a calibration cycle to produce mostly
"leave" decisions on capabilities. A cycle that always produces
movement is optimising for visibility, not for harness health.

---

## 3. Decide and record

For each candidate, decide and record. The format that works best in
practice mirrors a meeting record: what was considered, what was
moved, what was left in place, and the rationale for each.

A simple template:

```markdown
# Calibration review — YYYY-MM-DD

## Promotions

- `<capability>`: agent → deterministic. Tool: `<command>`. Reason:
  <one-sentence rationale grounded in cited signal>.

## Demotions

- `<capability>`: deterministic → agent. Reason: <signal showing the
  tool is misclassifying or the rule has shifted>.

## Splits

- `<capability>` → `<part-A>` (level X) and `<part-B>` (level Y).
  Reason: <evidence the two parts have different determinacy needs>.

## Seam repairs

- `<capability>`: <description of the rot fixed; level unchanged>.

## Refusals (deliberately left in place)

- `<capability>`: <considered for movement, not moved, reason>. This
  section is load-bearing — it captures what the team chose *not*
  to do, and why.

## Removals

- `<capability>`: removed because <reason>. Capabilities nobody
  proposes to move at all are candidates for removal — if it isn't
  worth debating, it may not be load-bearing.

## Cadence note

- Review took <duration>. Produced <N> movements and <M> refusals.
  Suggested next cadence: <unchanged | tighter | looser>, because
  <reason>.
```

Save the record under `observability/calibration/YYYY-MM-DD-review.md`
(creating the directory if it doesn't exist). The records accumulate
into a longitudinal trail of how the harness's determinacy
distribution has evolved.

---

## 4. Apply the decisions through existing commands

Calibration produces decisions; the plugin's existing commands apply
them. Use:

- `/harness-constrain` to write new or modified constraints into
  `HARNESS.md`. Constraints whose `Enforcement:` field changes from
  `agent` to `deterministic` (or vice versa) are applied through
  the same command — calibration's promote and demote both route
  here.
- `/governance-constrain` for governance-flavoured constraints
  (where the constraint references regulation, oversight, or
  accountability language).
- Direct edits to skill files, hook scripts, sub-agent prompts,
  and CI workflows for capabilities that aren't expressed in
  `HARNESS.md`.
- `/harness-sync` after the underlying `HARNESS.md` is settled, to
  propagate the changes to the push-direction surfaces (convention
  files and `ONBOARDING.md`) in one interactive pass. `/harness-sync`
  composes `/convention-sync` and `/harness-onboarding` as its
  underlying primitives; use either of those single-surface commands
  directly only when the focus is genuinely narrow.

Refusals are *not* applied through any command — they live in the
calibration record and that's where they belong. Recording them in
the review doc is the entire mechanism. The next cycle's review will
read them when deciding whether the same refusal still holds.

---

## 5. Run a follow-up audit

After applying the movements, run `/harness-audit` to confirm the
declared state in `HARNESS.md` matches the runtime reality the
calibration produced. Some movements will require a propagation
cycle (a new CI workflow, an updated hook script, a regenerated
convention file) — the audit catches anything that didn't land
correctly.

```text
/harness-audit
```

The audit's output is also raw signal for the *next* calibration
cycle. The loop continues.

---

## 6. What you have now

A dated calibration record under `observability/calibration/`,
movements applied to `HARNESS.md` and the surrounding harness
artefacts, refusals captured for next cycle, and an audit
confirming the harness reflects the decisions.

The most useful artefact for future calibration cycles is often the
refusals section — it tells the next reviewer what was already
considered and consciously left in place, so the next cycle doesn't
re-litigate the same questions without new evidence.

---

## Common patterns

- **First calibration on a mature project.** Expect a long candidate
  list and a high refusal rate. Most existing capabilities will be
  at roughly the right level; the value of the first review is
  surfacing the small handful that aren't, and establishing the
  baseline of refusals for next cycle to read.
- **A run that produces no movements.** Healthy if the refusal
  rationales are substantive. Concerning if the review feels rushed
  or the candidate list was thin — that suggests the signal-gather
  step (step 1) was too shallow.
- **A run that produces mostly demotions.** A signal worth taking
  seriously. Either the team's previous calibration over-scripted
  (chronic over-promotion drift), or the underlying problem domain
  has shifted enough that previously-stable rules are now too
  rigid. Either reading suggests the next cycle should look hard
  at the script and hook directories specifically.
- **A run that produces lots of seam repairs.** Indicates that
  capabilities are at the right level but the surrounding
  integration has rotted. Often a signal that GC rules need to be
  added or sharpened so the rot surfaces continuously rather than
  being discovered only at calibration time.

---

## See also

- [Determinacy Calibration](determinacy-calibration.md) —
  the conceptual background: bidirectional movement, four signal
  classes, refusals as outputs, the harness-as-habitat framing
- [Progressive Hardening](progressive-hardening.md) —
  the determinacy ladder calibration applies to
- [Run a Harness Audit](run-a-harness-audit.md) —
  the audit command that surfaces drift signal
- [Add a Constraint](add-a-constraint.md) —
  applying calibration's promote/demote decisions
