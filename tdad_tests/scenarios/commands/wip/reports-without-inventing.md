---
component: wip
component_type: command
tier: structural
---

# Scenario: /wip answers the question it was asked, and invents nothing

## Given

`/wip` is invoked deliberately, which makes its absent-block behaviour the
opposite of the hook's. The hook stays silent because announcing an
observe-only line to every user who never asked for this epic is an imposition;
the command must speak, because a human who asked a question and got nothing
cannot tell an absent block from a compliant one.

## When

`ai-literacy-superpowers/commands/wip.md` is read from the filesystem.

## Then

- Frontmatter with `name: wip` and a non-empty description.
- States that it never says anything about the human, and that the boundary is
  held by the author rather than by a script.
- **Absent block → the observe-only sentence and an offer of `/mast tune`**,
  explicitly contrasted with the hook's silence.
- **Malformed block →** name the missing clause, continue.
- Dispatches the `wip-warden` agent; the agent holds no `Write`.
- Requires the count's flag to be surfaced, with "at least" on `inferred`.
- Requires per-session ages measured from **heartbeat**.
- **No limit declared → say so and point at `/mast tune`; never supply a
  default.**
- `strict` asks and says it cannot compel; `advisory` reports and stops.
- Offers `/coda` for parking rather than parking anything.
- States that a spoken override is **not** recorded, rather than implying it
  was.

## Rubric

Passes only when the command speaks on an absent block, never supplies a
default limit, and discloses that an override goes unrecorded.

## Notes

The last assertion matters because the shipped pact template still described an
on-the-record override when this slice was written. Saying plainly that the
record does not exist yet is what keeps the promise honest until the slice that
builds it lands.
