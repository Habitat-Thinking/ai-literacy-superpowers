---
component: wip-warden
component_type: skill
tier: structural
---

# Scenario: the skill states the boundary, its unenforceability, and strict's limit

## Given

Two sections of this skill are contracts.

The **boundary** is what lets this sentinel coexist with the Reservoir Warden,
and it is not machine-checked — so the skill must say both what it forbids and
that nothing verifies it.

**`strict`** was defined by an earlier slice as requiring a disposition before a
session proceeds, which no hook can do. The skill is where that honest
correction lives for the next author.

## When

`ai-literacy-superpowers/skills/wip-warden/SKILL.md` is read from the
filesystem.

## Then

- Frontmatter naming the boundary, `strict`, the flag discipline, and the
  anti-patterns.
- The boundary stated in the same terms as the agent, with the
  retroactive-trust reasoning and at least one `<!-- evidence: ... -->`
  comment.
- A section stating that **no script enforces the boundary**, with the worked
  examples of sentences a word-ban would pass and the `focus_blocks`
  false-positive.
- `strict` described as an ask that cannot compel, with the reason (hooks are
  advisory) and the consequence (no gate, so no override machinery binds).
- The flag table, "at least" on `inferred`, and the no-exact-count rule.
- Age from heartbeat, with the backwards-advice consequence.
- The never-invent-a-limit rule, with issue #503 named as the underlying gap.
- The hook-silent / command-speaks split, with the reason for each.
- An anti-patterns section naming at least: speculation about the person,
  inventing a limit, implying `strict` can stop you, reporting an inferred
  count as exact, age from `started_at`, parking anything, and sourcing a write
  surface.

## Rubric

Passes only when the not-machine-enforced section is present with its worked
examples, `strict`'s limit is stated with its reason, and all seven
anti-patterns are named.

## Notes

The not-machine-enforced section is the load-bearing one. Without it a future
author sees agent-verified scenarios passing and reasonably concludes the
boundary is checked.
