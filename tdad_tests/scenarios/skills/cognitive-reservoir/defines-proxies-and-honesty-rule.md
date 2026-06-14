---
component: cognitive-reservoir
component_type: skill
tier: structural
---

# Scenario: cognitive-reservoir defines the proxies, the confidence discipline, and the honesty rule

## Given

The `cognitive-reservoir` skill (spec
`docs/superpowers/specs/2026-06-14-reservoir-warden-design.md`) is the shared
grounding that both the `reservoir-warden` agent and the `reservoir-check` Stop
hook inherit from rather than re-derive (FR-001, FR-009).

## When

The skill file at
`ai-literacy-superpowers/skills/cognitive-reservoir/SKILL.md` is read directly
from the filesystem.

## Then

**Frontmatter**:

- YAML frontmatter present with `name: cognitive-reservoir` and a non-empty
  `description`.

**Content** (FR-001):

- Defines the **four observable proxies**: continuous session span, decision
  volume, context switches, and wall-clock hour.
- Defines the **confidence-flag discipline** with all three flags — `observed`
  (the counts), `inferred` (defeasible risk), `asked` (anything about the
  human, e.g. chronotype) — and states that every `inferred` claim must sit on
  an `observed` proxy.
- States the **default thresholds** — span 180 min, decision volume 8, context
  switches 4, window 8 h — and that they are **disjunctive** and tunable.
- States the **one firm principle**: decide your stop before the next session
  begins; do not negotiate the boundary with your tired self.
- Provides **six-level scaling** guidance across the framework's literacy
  levels (0–5).
- Lists **anti-patterns**, including that the mechanism never produces a
  combined fatigue score and is never a gate.

**Honesty rule** (FR-009):

- The skill makes the **contested-vs-robust distinction visible**: it names ego
  depletion (and the 2016 multi-lab replication, d = 0.04) and the
  hungry-judges study as **contested** and explicitly **not asserted as fact**,
  while standing on the **robust** basis — task-switching cost / attention
  residue, vigilance decrement, chronotype-dependent circadian variation, and
  (as suggestive) Ericsson's deliberate-practice ceiling.
- States that every output is framed as a **precaution under uncertainty**,
  never a diagnosis.

## Rubric

Layer 1 structural scenario: every assertion is mechanically checkable by
reading the skill and matching against its section headings and key phrases.
The scenario passes only when the four proxies, the three confidence flags, the
disjunctive thresholds, the one firm principle, the six-level scaling, the
anti-patterns, and the contested-vs-robust honesty rule are all present.
