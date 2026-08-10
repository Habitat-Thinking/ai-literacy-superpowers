---
component: mast
component_type: skill
tier: structural
---

# Scenario: the mast skill states the clear-weather rule's limits and its anti-patterns

## Given

Two sections of this skill are contracts rather than prose.

The **clear-weather rule** is the epic's reason for the pact file, and the check
that supports it has a blind spot that must be disclosed wherever the rule is
stated — the skill, the agent, the command, and the reference page. A check that
claims coverage it lacks teaches the human to read its silence as an all-clear.

The **anti-patterns** are what keep a pact-keeper from becoming a gate.

## When

`ai-literacy-superpowers/skills/mast/SKILL.md` is read from the filesystem.

## Then

**Frontmatter:** `name: mast`, with a description naming the modes, the
clear-weather rule, and the anti-patterns.

**The flag table:** four rows, with `focus_blocks` and `sessions_per_day`
`inferred` and `daily_cost_ceiling` **not observable** — and the reasoning that
the clock being inside a block is not the same as having spent it working.

**The clear-weather section:** a two-row table showing that a hand-edit does
**not** fire the note and a calm tune **does**, plus the statement that
something stronger is unavailable because the pact file is never committed.

**Evidence comments:** at least two `<!-- evidence: ... -->` comments — one for
the recital-is-the-intervention claim, one for self-authored limits. Language
discipline holds: no "addiction", no "dopamine".

**The writer's four guarantees:** derive, replace-never-append, stamp `Budgets`
only, preserve the preamble — plus the validation checkpoint.

**The anti-patterns section** names at least: estimating anything unobservable,
gating on the weather note, claiming the check catches hand-edits, opening with
what cannot be seen, proposing a default in Tune, judging the pact, and writing
from the agent.

## Rubric

Passes only when the two-row hand-edit/tune table is present, both evidence
comments exist, and all seven anti-patterns are named.

## Notes

The two-row table is the guard against the honest-sounding regression: it is
easy to describe this check as catching in-the-moment edits, because that is
what one wants it to do.
