---
name: coda
description: Close a session deliberately — survey what landed and what is still live, park each open thread with a concrete next action, write the closure summary through /reflect, and end. Dispatches the read-only coda agent and persists what it returns after you confirm.
---

# /coda [resume RECORD]

The good ending. A ritual that closes a session on purpose rather than by
attrition, so the threads you leave open stop pulling at you and the next
session opens warm.

Nothing here gates you. You can stop the ritual at any point by saying so.

## When to use

- **`/coda`** — when you are finishing for the day, or finishing with this
  piece of work.
- **`/coda resume RECORD`** — when a thread you parked earlier is done.

## `/coda` versus `/reflect`

`/reflect` writes a learning. `/coda` closes a session, and calls `/reflect`
as part of doing so.

If you want to capture one surprise and carry on working, that is `/reflect`.
If you are stopping, that is `/coda`.

## Process

### 1. Read the skill

Read `skills/coda/SKILL.md` in full before anything else. It carries the
ritual, the anchor grammar, the evidence, and the anti-patterns.

### 2. Dispatch the coda agent

Pass the project root. The agent surveys what landed and what is still live,
flags each item, proposes a thread grouping with its reasoning, and returns
draft parking-record content.

The agent is `role: sentinel` and holds no `Write`. Everything it produces is
returned to you as text — **you** persist it, and only after the human has
confirmed.

### 3. Confirm the grouping

Show the proposed grouping. **It stands unless the human changes it.** Do not
require them to approve each thread; require only that they can change it.

This step lands after they have already decided they are finished. Demanding a
full manual partition here would put the ritual's heaviest thinking on the
person least equipped, at the moment they least want it.

### 4. Ask for a next action per thread

For each thread, ask for one concrete resume step.

Run the answer through `scripts/next-action-hint.sh`:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/next-action-hint.sh" "$answer"
```

- **exit 0** — an anchor was found. Move on.
- **exit 1** — ask once more, using the script's own question. It names a
  file, a test, or a decision. **Do not add a judgement of your own** and do
  not describe their answer as vague.

Whatever they say next is parked, **including the same words again**. If they
repeat themselves, write their answer into `## Next action` followed by a line
in their voice:

```text
(Asked again for a starting point; confirmed this is enough to go on.)
```

### 5. Write and commit the records

Write one record per thread to `docs/superpowers/parked/<YYYY-MM-DD>-<slug>.md`
per `reference/parking-record-format.md`. `next_action_flag` is always `asked`.

**Commit them before step 6.** `/reflect` stages only the reflection paths and
then relocates the tree to `main`; without this commit the ritual would publish
a summary describing records left behind uncommitted.

### 6. Ask about records already open

For each record `records_open` returns from a previous session, ask whether it
is still live. A "no longer live" answer writes its `.resumed.md` transition
now — see `/coda resume` below.

### 7. Closure summary and reflection

Invoke `/reflect`, supplying the optional `Closed` field:

```text
- **Closed**: [what landed this session; the filename of each record parked]
```

Filenames rather than a count: a count asserts that three threads were parked
without saying which three, and nothing can check it.

### 8. Close

Say what landed, what was parked, and stop.

## Stopping the ritual

If the human says plainly that they want to keep working, **stop**. Then say
exactly what has already been written — records are append-only, so nothing can
be withdrawn, and implying otherwise would be a lie about the artefacts.

- Stopped during or before the survey: nothing was written.
- Stopped after records exist: name each one and offer to supersede it.
- Stopped after `/reflect`: the fragment is committed and merged. Say so.

A request for *new work* after the ritual starts is different — park it, do not
execute it. That drift is what the ritual is for. A request to *abandon the
ritual* is the human changing their mind, which is always theirs to do.

## `/coda resume RECORD`

Writes a `.resumed.md` transition naming its predecessor in `supersedes:`, per
the S1 contract. Never edits or deletes the original.

```text
docs/superpowers/parked/2026-08-08-retry-branch.md            <- parked
docs/superpowers/parked/2026-08-09-retry-branch.resumed.md    <- supersedes it
```

## Validation checkpoint

After writing records, read them back and check against
`reference/parking-record-format.md`:

1. Frontmatter carries `session`, `repo`, `created`, `state`, `supersedes`,
   `next_action_flag`
2. `next_action_flag` is `asked` — S2 adds no other value
3. Both `## Context` and `## Next action` sections are present and non-empty
4. The filename carries the state: no suffix for parked, `.resumed.md` for a
   transition

Fix deviations in place. Do not re-dispatch the agent.
