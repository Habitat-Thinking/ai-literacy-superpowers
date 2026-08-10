# Spec: Cadence Sentinels S4 — The WIP Warden

**Status:** Approved (revision 1)
**Date:** 2026-08-10
**Issue:** #494
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
**Depends on:** S1 (0.67.0) — the session registry and `Session WIP`;
S3 (0.69.0) — `/mast tune`, which authors the block this reads
**Scope:** `ai-literacy-superpowers` plugin; one agent, skill, command, and a
`SessionStart` hook
**Explicitly out of scope:** the override *record*, which is **#501**; the
Convener (S5).

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S5) and
*Compulsive Continuation — A Research Exploration*.

---

## 1. Problem Statement

Three sessions open across three repositories is not three times the work. It
is one person switching, and the cost of the switch is paid in the quality of
every decision made after it.

The registry S1 built knows how many sessions are live. Nothing reads it. The
`Session WIP` block S3's Tune authors declares what the human decided their
limit was, in clear weather. Nothing reads that either.

The WIP Warden is what closes that loop: at the start of a session, it counts,
compares, and — if you are over the line you drew — says so.

**Epithet:** *the concurrency gate.* **Attacks:** thrash-switching.

## 2. The Constitutional Boundary

This is the most important section in the slice, and the build spec is right
that it belongs in two skills rather than one.

> The **Reservoir Warden** watches *the human* and never gates.
> The **WIP Warden** counts *sessions* and never watches the human.

The split is deliberate and it is what protects the Reservoir Warden's trust
model. That agent is advisory-forever by design: it reports proxies with
honesty flags, offers exactly one recommendation, and persists nothing about
the person — and it can be trusted precisely because it has no teeth and wants
none.

The moment a sibling agent starts inferring from session counts how tired
someone is, or how well they are working, the Warden's contract is retroactively
broken: a human who has told the harness their chronotype now has reason to
wonder what else is being read from it.

So the WIP Warden **counts sessions, full stop**. It reports a number, an age
per session, and a comparison against a declared limit. It never speculates
about attention, fatigue, focus, or capacity — not as a hedge, not as a
sympathetic aside, not in a footnote. Those words do not appear in its output.

**Documentation, not code, in the Reservoir Warden's direction.** Constraint 5
holds: this slice adds a cross-reference to `cognitive-reservoir/SKILL.md`
naming the boundary, and changes nothing else about that agent. The build spec
permits exactly this ("no changes beyond documentation cross-references").

## 3. What `strict` Can Honestly Mean

S1 defined the token, and defined it as something the harness cannot do.

> `strict` — the WIP Warden requires a **disposition** before the session
> proceeds. — S1 §3.3

**No hook can hold a session.** `reference/hooks.md` opens by saying so —
"Hooks are advisory only — they warn but never block" — and a `SessionStart`
hook in particular emits a message into a session that is already starting.
There is no mechanism, in this plugin or under it, that makes a session wait.

This is the same shape as S3's impossible CI critic check, and it is worth
naming as a pattern: **a token defined in a vocabulary slice can promise
behaviour the consuming slice cannot deliver**, and nobody notices until the
consumer is built. See §7.

### 3.1 The honest definition

| Mode | Behaviour |
| --- | --- |
| `advisory` | reports the breach and the live sessions, and moves on |
| `strict` | **asks** for a disposition — park one, or say what is urgent — and says plainly that it cannot compel one |

`strict` is a stronger *ask*, not a gate. The assistant in the session honours
it conversationally, which is how every other disposition in this epic works:
agents propose, humans dispose.

**Because it is not a gate, constraint 6's override machinery does not bind.**
There is nothing to override — the human can proceed at any point by saying so,
and no artefact stands between them and their work.

### 3.2 And it says so

The docs state the limit plainly rather than implying enforcement:

> `strict` asks. It cannot hold a session, and nothing in this plugin can. If
> you keep going, you keep going.

A sentinel that implied it could stop you would be claiming a power it does not
have — the same overclaim the Mast's weather check was corrected for, and the
same correction: state the coverage you have.

### 3.3 The override record is #501's

An override worth recording is worth recording *once*. #501 is already building
the mechanism — a session note the Coda consumes at close — for the Mast's
hard-stop override, and the WIP Warden's is the same shape arriving through a
different door.

So S4 ships the ask and **defers the record**, and says so in its docs. #501
widens from "the Mast's override" to "boundary events and their overrides".
Building a second note store here would duplicate the store, the retention
question, and the carve-out evaluation that #501 must do anyway.

## 4. What It Counts, and How Honestly

`registry_count` returns a count and a flag, and S4 reports **both**.

| Situation | Flag | What the report says |
| --- | --- | --- |
| Every entry fresh | `observed` | the count, plainly |
| An entry's lease expired but unpruned | `inferred` | the count, and that at least one session may have ended |
| A retirement happened recently | `inferred` | the count, and that a session aged out and may have been live |
| An `unknown` entry present | `inferred` | the count, and that one entry may stand for more than one session |

S1 was explicit that **no consumer may treat this count as an exact number of
open windows**. S4 is the first consumer, and it honours that: a count flagged
`inferred` is reported as approximate, in words, every time.

**The ages come from `registry_list`.** Each live session is listed with its
`started_at` and its repo, so the human can see *which* sessions rather than
only how many — that is what makes the breach report actionable rather than
merely true.

`max_switches_per_hour` is **not read**. Nothing in the registry records a
switch, and inferring one from session activity would be exactly the
speculation §2 forbids. It stays declared and unread, and Tune says so.

## 5. Files

| File | Purpose |
| --- | --- |
| `agents/wip-warden.agent.md` | `role: sentinel`, read-only — counts, lists, compares |
| `skills/wip-warden/SKILL.md` | the boundary, the honest meaning of `strict`, the flag discipline, the anti-patterns |
| `commands/wip.md` | `/wip` on demand |
| `hooks/scripts/wip-check.sh` | `SessionStart` — the breach report |
| `skills/cognitive-reservoir/SKILL.md` | one cross-reference naming the boundary (docs only) |
| `commands/mast.md` | one line corrected — see §6 |

The agent sources `lib/session-registry-read.sh` and `lib/pact-blocks.sh`, both
read surfaces. It must never source `session-registry-write.sh` or
`pact-write.sh`.

## 6. A Stale Disclosure, Corrected

S3's Tune tells the human that three of `Session WIP`'s four keys "wait for
S4". Shipping S4 makes that false for two of them.

Correcting a statement of fact that has become false is not mutating a
contract — it is keeping a derived claim true, and the claim was only ever
about which components exist. S4 updates the line.

**The deeper fix is recorded, not built here.** That sentence pinned a copy of
something it should have derived: which keys have live consumers is a fact
about the shipped components, and `AGENTS.md`'s promoted decision is that
harness artefacts derive from the source of truth rather than pinning a copy of
it. The same rule caught the README count badges two slices ago. A derived
disclosure is a follow-up, on the record.

## 7. A Pattern Worth Naming

Twice now, a vocabulary slice has defined a token whose promised behaviour the
consuming slice could not deliver:

- S1 promised a CI critic check on `Budgets` diffs. S3 found there are no diffs
  — the pact file is never committed.
- S1 promised `strict` would require a disposition before a session proceeds.
  S4 finds no hook can hold a session.

Both were caught, and both cost a slice's spec gate to catch. The pattern is
that **defining a token is cheap and defining its enforcement is not**, and a
slice that ships the vocabulary before any consumer exists has no way to
discover the gap.

This goes into `sentinel-design` as a note for the next author: when a
vocabulary slice defines an enforcement token, name the mechanism that will
deliver it, or mark the token explicitly as awaiting one.

## 8. Non-Goals

- **No gating.** Nothing here can hold a session, and the docs say so.
- **No override record.** #501.
- **No speculation about the human.** No fatigue, no attention, no capacity —
  not in the output, not in the skill, not as a hedge.
- **No `max_switches_per_hour`.** Nothing observes a switch.
- **No changes to the Reservoir Warden** beyond one documentation
  cross-reference.
- **No changes to the registry.** S4 is a reader.

## 9. Acceptance Scenarios (TDAD)

Prefixed **C** for the count-and-compare hook, **B** for the boundary
discipline.

### 9.1 The hook — `tdad_tests/layer0_deterministic/test-wip-check.sh`

- **C1 — silent when no `Session WIP` block is declared.** Not an observe-only
  line; a hook with nothing to say says nothing. Exit 0.
- **C2 — silent when under the limit.** Two live sessions, limit two, no
  output.
- **C3 — reports a breach.** Three live, limit two: the output names the count
  and the limit.
- **C4 — lists the live sessions with ages**, so the report is actionable.
- **C5 — an `inferred` count is reported as approximate**, in words, and never
  as an exact number.
- **C6 — `strict` asks; `advisory` does not.** The strict output requests a
  disposition and the advisory output does not.
- **C7 — `strict` discloses that it cannot compel.** The output says so
  plainly.
- **C8 — a malformed block degrades to silence**, never to a gate.
- **C9 — exits 0 on every path**, including an unreadable registry and `HOME`
  unset.
- **C10 — fires on startup only.** `SessionStart` re-fires on resume, clear and
  compact; a breach report re-injected mid-session is the thrash it exists to
  name. Same guard S2 used, and it writes nothing.

### 9.2 The boundary — `test-wip-check.sh` and the TDAD scenarios

- **B1 — no speculation vocabulary anywhere.** The hook, agent, skill and
  command contain no instance of `fatigue`, `tired`, `attention`, `capacity`,
  `focus` (as a state), `burnout`, or `depleted`.
- **B2 — the boundary is stated in both skills**, in the same terms.
- **B3 — the Reservoir Warden's agent file is unchanged.** Only its skill gains
  a cross-reference.

### 9.3 Agent-verified

- **A1** — `/wip` reports count, flag, and per-session ages.
- **A2** — it never infers anything about the human from the count.
- **A3** — it offers to park via the Coda rather than parking anything itself.
- **A4** — it says plainly that `strict` cannot hold a session.

## 10. Migration & Rollout

Minor bump, 0.69.0 → 0.70.0. Five CI-checked locations, the README
plugin-table cell, and the README count badges, anchors, and headings —
39 skills → 40, 18 agents → 19, 30 commands → 31.

A TDAD scenario per new component. Docs: a how-to, reference entries on all
three component pages, the hook in `reference/hooks.md`, the boundary on
`explanation/sentinels.md`, and the roster 7 → 8.

No breaking changes. S4 reads what S1 and S3 already ship.
