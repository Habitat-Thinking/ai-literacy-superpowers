---
component: mast
component_type: agent
tier: structural
---

# Scenario: mast reports what it cannot see and never estimates

## Given

The `mast` agent reads a pact a human authored for themselves and reports where
they stand against it. Most of a budget is not observable, and saying so is the
job — three of its four keys cannot be measured by anything in this plugin.

The failure this scenario guards is the flattering one: a report that presents
an unobservable quantity as observed, or fills a gap with an estimate. A
fabricated spend figure against a real ceiling would make a person stop, or not
stop, on a number nobody measured.

## When

`ai-literacy-superpowers/agents/mast.agent.md` is read from the filesystem.

## Then

**Frontmatter:** `name: mast`, a non-empty description, `role: sentinel`, and
`tools` exactly `Read, Glob, Grep, Bash` — no `Write`, no `Edit`.

**Charter:**

- Instructs the agent to read `skills/mast/SKILL.md` first.
- States it must never source `pact-write.sh`, and that `Bash` is read-only.
- Carries the flag table with `hard_stop_hour` observed, `focus_blocks` and
  `sessions_per_day` inferred, and `daily_cost_ceiling` **not observable** —
  and states that a missing row reads as a row that was fine.
- States plainly that it **never estimates spend**, with the reason.
- Carries the weather note **and its blind spot**: the note sees a budget
  *tuned* today, and a hand-edit outside `/mast tune` is invisible to it
  permanently.
- Instructs the agent to **recite the pact's own words first** and annotate
  after.
- Instructs it to offer `/mast tune` when no block is declared.
- States it never gates and never judges the pact.

## Rubric

Passes only when the tool list carries no write capability, the flag table has
all four rows with those exact flags, the never-estimate rule is present, and
the weather note's blind spot is disclosed rather than implied.

## Notes

The blind-spot assertion is the load-bearing one. An earlier draft claimed the
check caught an 18:00 hand-edit "and nothing else"; it catches the precise
opposite, and a check that claims coverage it lacks teaches the human to read
its silence as an all-clear.
