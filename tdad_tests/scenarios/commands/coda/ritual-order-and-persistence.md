---
component: coda
component_type: command
tier: structural
---

# Scenario: /coda parks before it reflects, and commits before it does

## Given

`/coda` runs a four-step ritual: survey, park, closure summary and reflection,
close.

The order is not stylistic. `/reflect` in a repository declaring a
*Reflections via PR workflow* constraint runs `git checkout -b`,
`gh pr create`, `gh pr merge --squash --delete-branch` and `git pull` on
`main`. Run before parking, it would move the working tree off the branch
holding the uncommitted work the survey had just enumerated, and the ritual
would then write parking records from wherever the merge left the tree.

`/reflect` also stages only `reflections/active/` and `REFLECTION_LOG.md` — so
records written but not committed at the park step would be left behind, in a
tree that has just moved, while a `Closed` field describing them reaches
`main`.

## When

The command file at `ai-literacy-superpowers/commands/coda.md` is read
directly from the filesystem.

## Then

- Frontmatter with `name: coda` and a non-empty `description`.
- The process states the four steps **in order**: survey, park, closure
  summary and reflection, close.
- Parking is step 2 and **precedes** the `/reflect` invocation.
- The command states that parking records are **committed before `/reflect`
  runs**, and gives the staging reason.
- The command dispatches the `coda` agent and states that the agent holds no
  `Write` and that the command persists what it returns.
- The next-action step invokes `scripts/next-action-hint.sh` and documents
  **exit 0 = move on, exit 1 = ask once more** — never reject. It instructs
  the caller not to add a judgement of its own.
- The repeated-answer path writes the human's own words plus a
  human-voice confirmation line into `## Next action`; `next_action_flag`
  stays `asked`.
- A section states how to stop the ritual, and distinguishes *new work*
  (parked) from *abandoning the ritual* (always the human's).
- `/coda resume RECORD` writes a `.resumed.md` transition naming its
  predecessor in `supersedes:`, and never edits or deletes the original.
- A validation checkpoint reads the written records back against
  `reference/parking-record-format.md`.
- The command states when to reach for `/coda` versus `/reflect`.

## Rubric

Layer 1 structural scenario: checkable by reading the command file. It passes
only when parking demonstrably precedes reflection, the commit-before-reflect
instruction is present with its reason, the exit-1-means-ask semantics is
documented, and the stop path distinguishes new work from abandonment.

## Notes

The ordering assertion is the load-bearing one. A future maintainer who reads
the order as arbitrary and "tidies" it into the build spec's original sequence
would reintroduce the failure this scenario exists to prevent.
