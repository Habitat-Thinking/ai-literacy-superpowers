---
name: mast
description: Read the pact you set for yourself, or author one. Read mode recites your declared budget and says where you stand against it, with each key flagged for what can honestly be seen. Tune mode is the only sanctioned path that creates or amends the pact file.
---

# /mast [read | tune [BLOCK]]

A limit you set in advance holds. A limit you set at the moment you are about
to breach it does not. `/mast` is what brings the first kind back into view.

Mode defaults to `read`. Nothing here gates anything.

## When to use

- **Read** — any time you want to see the pact you made, and where you stand.
- **Tune** — to author a pact for the first time, or to change one.

## Read mode

### 1. Check for a pact

Source `hooks/scripts/lib/pact-blocks.sh` and check `block_state 'Budgets'`.

If it is `absent`, say the project has not opted in and **offer Tune mode**.
Do not manufacture a read.

That offer matters more than it looks: the pact file does not exist until
someone authors it, `/mast tune` is the only path that does, and a human who
does not know the command has no way in.

If it is `malformed`, say which mandatory clause is missing, then continue in
observe-only. Malformed is never a gate.

### 2. Dispatch the mast agent

Pass the project root. The agent reads the `mast` skill, parses the block, and
returns the report.

The agent is `role: sentinel`, holds no `Write`, and must never source
`pact-write.sh`.

### 3. Present it — recital first

Lead with the human's own declared words. Annotate afterwards.

A pact nobody reads is not a pact; re-reading it *is* the intervention. Opening
with a table of what cannot be measured turns a gauge into an inventory of the
plugin's limits.

Then the flags: `hard_stop_hour` observed, `focus_blocks` and
`sessions_per_day` inferred, `daily_cost_ceiling` not observable — each with a
word on what could not be seen. **Never estimate spend.**

If `authored_at` is today, add the weather note **with its blind spot in the
same breath**: it sees a budget tuned today; a pact hand-edited outside `/mast
tune` never moves the stamp and is invisible to it.

## Tune mode

The only sanctioned path that writes the pact file.

### 1. Read what is already there

If a pact exists, read each current value so you can ask with it as context —
*your line is 18:30; what should it be?*

**That is not a proposed default.** What you are showing is the human's own
prior authorship, not the template's illustration. Never offer the template's
numbers.

`/mast tune budgets` scopes the ritual to one block.

### 2. Ask the stop hour first

`hard_stop_hour` is the one key a person can answer cold, and the one that
carries the point. Ask it, then **offer to stop there** — a useful two-line
pact in one question.

Offer the remaining keys; do not march through them.

### 3. Say what nothing reads yet — before asking

- `Sync cadence` — reserved entirely; nothing reads it.
- `Session WIP` — only `stale_after_hours` is read today. The rest waits for
  the WIP Warden.
- `notification_policy_after_stop` — declared intent; nothing here enforces it.
- `daily_cost_ceiling` — declared, never checkable.

Every block is skippable. An undeclared block is not an incomplete pact.

### 4. Compose, show, then write

Build the block from the answers and **show it before writing**. Take accept /
edit / abort.

Per-value confirmation alone is not enough: the mandatory clause, the reserved
marker and the stamps are what decide whether the block reads as `declared`,
and the human never authored them.

On accept, source `hooks/scripts/lib/pact-write.sh` and call:

```bash
pact_write_block "Budgets" "$body_file"
```

The writer derives the clause from the template, replaces rather than appends,
stamps `Budgets` only, and preserves the preamble.

### 5. Validation checkpoint

Read the block back and check it:

1. `block_state` returns `declared`
2. The mandatory clause is present (match whitespace-normalised — the clause's
   words are the interface, its line breaks are not)
3. Every value the human gave reads back through `block_key`, including
   colon-bearing times and comma-separated ranges
4. Exactly one heading exists for the block

Fix deviations in place. A malformed write is otherwise discovered later and
silently, as every sentinel drops to observe-only with no line saying why.

## What this command never does

- **Never scaffolds a pact.** Nothing is written until a human answers.
- **Never proposes a default.** Authorship is the active ingredient.
- **Never estimates.** Especially not spend.
- **Never gates.** Absent, malformed, tuned-today — all reports.
- **Never judges the pact.** A stop hour is not too late. It is theirs.
