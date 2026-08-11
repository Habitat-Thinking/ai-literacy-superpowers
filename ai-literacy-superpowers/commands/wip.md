---
name: wip
description: Count live sessions against the limit you declared for yourself — how many, which ones, and how long since each last took a turn. Counts sessions and never watches you; never invents a limit you did not set.
---

# /wip

Three sessions open across three repositories is not three times the work. It
is one person switching.

`/wip` tells you how many sessions are live, which they are, and how that
compares against the line you drew in clear weather.

## What it will never do

- **Say anything about you.** Not how tired you seem, not how well it is going.
  It counts sessions. That boundary is what lets the `/reservoir` warden stay
  trustworthy, and it is held by whoever writes the output — no script checks
  it.
- **Invent a limit.** If you have not declared one, it says so.
- **Stop you.** Nothing here can, and it says so rather than implying
  otherwise.

## Process

### 1. Read the skill

Read `skills/wip-warden/SKILL.md` first. The boundary section is not optional
background.

### 2. Check for a declared block

Source `hooks/scripts/lib/pact-blocks.sh` and check `block_state 'Session WIP'`.

- **Absent** — emit S1's fixed observe-only sentence and offer `/mast tune`.
  Do not be silent: the human asked a question, and silence leaves them unable
  to tell an absent block from a compliant one. (The `SessionStart` hook *is*
  silent here, which is a different case — it was not asked.)
- **Malformed** — name the missing clause, then continue in observe-only.

### 3. Dispatch the wip-warden agent

The agent counts via `registry_count`, lists via `registry_list`, and returns
the report. It holds no `Write` and must never source a write surface.

### 4. Present it

**The count, with its flag.** If `registry_count` returned `inferred`, say
"at least" and say why. No consumer may treat this as an exact number of open
windows.

**Which sessions**, with time since each last took a turn, and where. Age is
time since heartbeat — never since `started_at`, which would point you at the
session you are actively working in as the obvious one to park.

**The comparison**, if `max_concurrent_sessions` is declared.

### 5. If no limit is declared

Say how many are live, say no limit is declared, and point at `/mast tune`.

Never supply a default. An imposed limit is exactly the pact the clear-weather
rule says does not hold, and a block with its clause and no limit is a normal
file — `/mast tune` offers a two-line pact on purpose.

### 6. If over the line

**`advisory`** — report and stop.

**`strict`** — ask: park one, or say what is urgent enough to keep them all
open. Then say plainly that this asks and cannot compel, and honour whatever
they answer.

If they want to park one, offer `/coda`. Do not park it yourself.

## The record

An override you speak here is not written down. The mechanism that would carry
it — a session note the Coda collects at close — is a separate slice, and this
command says so rather than implying the conversation was recorded.
