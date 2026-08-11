---
component: wip-warden
component_type: agent
tier: structural
---

# Scenario: the WIP Warden counts sessions and never watches the human

## Given

This agent exists alongside the `reservoir-warden`, whose entire value rests on
being advisory-forever and persisting nothing about the person. It is
trustworthy precisely because it has no teeth and wants none.

If a sibling starts inferring from session counts how tired someone is, that
contract breaks **retroactively** — a human who told the harness their
chronotype now has reason to wonder what else is being read from it.

**No script enforces this boundary.** A word-ban was tried and rejected: it
would pass every sentence that actually violates it ("three sessions is a lot
to be holding at once") while failing on `focus_blocks`, a live pact key. This
scenario is the guard.

## When

`ai-literacy-superpowers/agents/wip-warden.agent.md` is read from the
filesystem.

## Then

**Frontmatter:** `name: wip-warden`, non-empty description, `role: sentinel`,
`tools` exactly `Read, Glob, Grep, Bash` — no `Write`, no `Edit`.

**Charter:**

- States the boundary in the same terms as the skill: the Reservoir Warden
  watches the human and never gates; this agent counts sessions and never
  watches the human — **with the reason**, that the trust model breaks
  retroactively.
- States that no script enforces it and that it is the author's to hold.
- Names the read surfaces it may source and the two write surfaces it may not,
  noting the frontmatter check cannot see a `source` line.
- Requires the count's flag to be reported, with "at least" on `inferred`, and
  cites the no-exact-count rule.
- Requires age to be **time since heartbeat**, and says why `started_at` would
  advise the opposite.
- States that it never invents a limit, and what it does instead.
- States that `strict` asks and cannot compel.
- Offers `/coda` for parking rather than parking anything itself.

## Rubric

Passes only when the tool list carries no write capability, the boundary
appears with its retroactive-trust reasoning, the never-invent-a-limit rule is
present, and the heartbeat-not-started_at distinction is stated with its
consequence.

## Notes

The heartbeat distinction looks like a detail and is not: age-since-start would
point the human at the session they are actively working in as the obvious one
to park.
