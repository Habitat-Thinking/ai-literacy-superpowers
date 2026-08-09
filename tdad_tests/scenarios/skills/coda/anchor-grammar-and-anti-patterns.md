---
component: coda
component_type: skill
tier: structural
---

# Scenario: the coda skill publishes the anchor grammar and its anti-patterns

## Given

The `coda` skill is the authoritative grounding for the ritual. Two of its
sections are contracts rather than prose.

The **anchor grammar** is published so a human who is asked for a better next
action can see exactly why and argue with it — a check whose decisive term
lives only in the implementation cannot be argued with. It is reproduced
verbatim in three places (the skill, `reference/parking-record-format.md`, and
`scripts/next-action-hint.sh`), and drift between them silently changes what a
person is told.

The **anti-patterns** are what keep the ritual from becoming a gate on the
person it is meant to serve.

## When

The skill file at `ai-literacy-superpowers/skills/coda/SKILL.md` is read
directly from the filesystem.

## Then

**Frontmatter:** `name: coda` with a description naming the ritual, the anchor
grammar, and the anti-patterns.

**The ritual:** four steps in order, with the reason parking precedes
reflection stated — the portable reason (`Closed` can only name what parking
produced) **first**, and the PR-workflow constraint as the local fact behind
it.

**The survey:** a per-item flag table, with thread grouping flagged `asked`
and described as the central epistemic act, and grouping stated as
propose-and-default-accept.

**The anchor grammar:** all six kinds present — path, code identifier,
backticked span, scenario or ticket id, line or section reference, and
**decision**. The decision row's rationale is stated: the other five are
artefacts of code-shaped work.

**The framing sentence:** the table is described as a trigger heuristic whose
complement is **not** "vague", and as saying what makes the Coda stop asking
rather than what makes a next action good.

**The evidence comments:** at least one `<!-- evidence: ... -->` comment
grounding the next-action question, naming specificity as the active
ingredient. Language discipline holds throughout — no "addiction", no
"dopamine".

**The anti-patterns section** names at least: refusing a next action, deciding
the grouping alone, recording why the human stopped, continuing after being
asked to stop, writing a file from the agent, and surfacing parked records
more than once a session.

## Rubric

Layer 1 structural scenario: checkable by reading the skill. It passes only
when all six anchor kinds are present, the not-"vague" framing is stated, the
evidence comment is present, and all six anti-patterns are named.

## Notes

The three-way duplication of the anchor grammar is a known cost, accepted
because publication is what makes the rule arguable. This scenario is one of
the two guards on that drift; `test-next-action.sh` N1–N8 is the other, and it
pins the behaviour the table describes.
