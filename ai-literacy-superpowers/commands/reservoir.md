---
name: reservoir
description: Watch the human verifier the harness cannot verify — Read mode dispatches the reservoir-warden agent for a fuller cognitive-reservoir read; Tune mode helps you edit the HARNESS.md Cognitive reservoir block (thresholds and chronotype), proposing edits for you to confirm
---

# /reservoir [read | tune]

An on-demand, read-only advisory on **you**, the verifier — not on the
code. It counts observable proxies (session span, decision volume,
context switches, wall-clock hour) over the recent git window and, if a
threshold is crossed, offers the single decide-your-stop-first
recommendation. It never blocks, never scores, never persists a record
of your state.

Mode defaults to `read`.

## When to use

- **Read mode** (default): mid-session, when you want a fuller read than
  the automatic Stop-hook advisory gives — or any time you want to check
  the proxies deliberately.
- **Tune mode**: when the hook fires too often or too rarely, or when you
  want to declare a chronotype so the late-hour band is honest. A cluster
  of advisories you routinely ignore is a signal to tune thresholds —
  **not** to weaken the honesty rule.

## Read mode

### 1. Check opt-in

Confirm HARNESS.md contains a `Cognitive reservoir` block. If it does
not (or there is no HARNESS.md, or no git repo), tell the user the
project has not opted in and offer Tune mode to add the block. Do not
manufacture a read.

### 2. Dispatch the reservoir-warden agent

Pass the project root. The agent reads the `cognitive-reservoir` skill,
gathers proxies via `git`/`date`, evaluates the thresholds from the
HARNESS.md block (or defaults), and returns the report.

### 3. Present the report

Show the agent's report verbatim. It contains the proxy table (each line
flagged `observed`/`inferred`/`asked`), the defeasible inferred risk,
and — if any threshold crossed — the one firm principle plus one
concrete time-boxed option. Do not add a fatigue score, a second nudge,
or a diagnosis. The choice to continue is the user's.

## Tune mode

### 1. Read the current block

Read the `Cognitive reservoir` block from HARNESS.md if present;
otherwise propose adding one from the template.

### 2. Walk the tunable fields

Help the user set, defaulting per the `cognitive-reservoir` skill:

- `window_hours` (default 8)
- `span_minutes` (default 180)
- `decision_volume` (default 8)
- `context_switches` (default 4)
- `chronotype` — **optional**. Only when declared does the late-hour
  band get labelled (optimal / dip / suboptimal); otherwise it stays
  `asked` / unverified. Declaring it is the user's choice.

### 3. Propose, do not impose

Present the proposed block as a diff and ask the user to confirm before
writing. The user owns this block — it is the one place the mechanism
records anything, and it records only configuration, never a claim about
the user's state.

### 4. Validation checkpoint

After writing, read the block back and verify:

1. The heading is `## Cognitive reservoir` (case-insensitive marker the
   Stop hook greps for is intact).
2. Each present key is one of: `window_hours`, `span_minutes`,
   `decision_volume`, `context_switches`, `chronotype`.
3. Numeric values are positive integers; `chronotype`, if present, is a
   recognised label.
4. The not-a-constraint note is present so a future reader does not
   promote the block into CI.

Fix any deviation in place.

## Not a gate

This mechanism is advisory-only and is **not** a Constraint. It never
fails CI, never blocks a commit/merge/session, and writes no record of
your cognitive state. See the `cognitive-reservoir` skill for the
honesty rule and the contested-vs-robust scientific grounding.
