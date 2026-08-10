---
component: mast
component_type: command
tier: structural
---

# Scenario: /mast tune composes, shows, writes through the library, and verifies

## Given

`/mast tune` is the only sanctioned path that creates or amends the pact file,
and that file is the input to every other sentinel in the epic. Everything else
degrades safely when it is wrong; Tune is what makes it wrong.

`CLAUDE.md` requires a validation checkpoint of every command producing
structured output that downstream consumers parse. `pact-blocks.sh` parses this
output.

## When

`ai-literacy-superpowers/commands/mast.md` is read from the filesystem.

## Then

- Frontmatter with `name: mast` and a non-empty description.
- **Read mode offers Tune when the block is absent.** The pact file does not
  exist until someone authors it, and a human who does not know the command has
  no way in.
- Read mode presents **recital first**, flags second.
- Read mode states that a malformed block names its missing clause and
  continues in observe-only — never gates.
- **Tune reads current values back as question context**, with an explicit
  statement that this is not a proposed default.
- **Tune asks `hard_stop_hour` first** and offers to stop there.
- Tune states what nothing reads yet — `Sync cadence`, three of
  `Session WIP`'s keys, `notification_policy_after_stop`,
  `daily_cost_ceiling` — **before** asking.
- Tune **composes, shows, and takes accept / edit / abort** before writing.
- The write goes through `pact_write_block` from
  `hooks/scripts/lib/pact-write.sh`; the agent never writes.
- A **validation checkpoint** reads the block back and checks `block_state`,
  the mandatory clause (whitespace-normalised), value round-trips, and a single
  heading.
- The command states it never scaffolds, never proposes a default, never
  estimates, never gates, and never judges the pact.

## Rubric

Passes only when the Tune-offer, the stop-hour-first ordering, the
compose-and-show step, the library call, and the four-point validation
checkpoint are all present.

## Notes

The Tune-offer assertion guards the slice's whole value proposition: the epic is
blocked until a pact exists, and nothing else in the product mentions the
command that creates one.
