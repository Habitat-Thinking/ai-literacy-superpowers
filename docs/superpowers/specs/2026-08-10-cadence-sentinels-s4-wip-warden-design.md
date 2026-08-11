# Spec: Cadence Sentinels S4 — The WIP Warden

**Status:** Approved (revision 2, post-diaboli)
**Date:** 2026-08-10
**Issue:** #494
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
**Depends on:** S1 (0.67.0) — the session registry and `Session WIP`;
S3 (0.69.0) — `/mast tune`, which authors the block this reads
**Objections:** `docs/superpowers/objections/cadence-sentinels-s4-wip-warden-design.md`
— 12 objections, all accepted
**Scope:** `ai-literacy-superpowers` plugin; one agent, skill, command, and a
`SessionStart` hook. Plus one repair to S1's `registry_list`, carved as its own
commit (§4.1).
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

**Why session start, and not somewhere better.** The report arrives *after* the
switch it exists to discourage, so its ask is remediation ("park one") rather
than prevention. That is a real cost and worth stating rather than assuming.

It is still the right rail. Session start is the earliest moment at which the
fact is knowable — the count is only a breach once the new session exists — and
the human is present and not yet mid-thought. The `Stop` rail was considered and
rejected: it fires every turn, and the epic's own evidence is that repeating a
boundary prompt makes adherence worse rather than better.

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
sympathetic aside, not in a footnote.

**The ban is on what it emits, not on what its files may say.** The skill has
to name what it refuses, or it is not a usable rule for the next author — a
refusal that cannot say what it refuses inverts the write-the-honesty-rule-first
discipline. So this section, and the skill's copy of it, name the forbidden
words freely; the Warden's *output* contains none of them.

**And this boundary is not machine-enforced.** An earlier draft tested it by
banning seven nouns in a Layer-0 script. That check would have passed every
sentence that actually violates it — "three sessions is a lot to be holding at
once", "you have been switching between these for a while", "might be worth
slowing down" — while failing on `focus_blocks`, a live pact key.

Worse, a green word-grep would have been read by the next author as evidence
that the most important boundary in this slice is checked. It is the same
overclaim §3.2 forbids for `strict`, and the spec was applying the rule to
`strict` and not to itself. B1 is therefore an **agent-verified** scenario with
a rubric, and the skill says plainly that no script enforces this.

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

**The limit is `max_concurrent_sessions`**, and a breach is `count > limit`.
The count **includes the session that is starting**: a human writing
`max_concurrent_sessions: 2` means two *including* the one they are in, which
is what the template's own field note says. The hook is therefore ordered after
S1's `session-registry-start.sh` on the same rail, so the entry exists when the
count is taken.

**When a declared block omits the limit, nothing is compared.** The Warden says
how many sessions are live, says no limit is declared, and points at
`/mast tune`. It never invents one — an imposed limit is precisely the pact the
clear-weather rule says does not hold, and reporting a breach of a line the
human never drew is the worst output this slice can produce.

That case is not pathological. Tune deliberately offers a two-line pact, so a
block with its clause and `stale_after_hours` and nothing else is a plausible
product of the sanctioned authoring path — and `block_state` returns `declared`
for it, because S1 defined malformed as "mandatory clause **or required key**
missing" and only the clause half was ever implemented. That gap is **#503**;
S4 works around it rather than changing a contract it does not own.

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

**The ages come from `registry_list`** — after the repair in §4.1. Each live
session is listed with its id, its repo, and its **time since last heartbeat**,
so the human can see *which* sessions rather than only how many. That is what
makes the report actionable rather than merely true.

Age is time since heartbeat, not since `started_at`. The distinction decides
what the report advises: age-since-start says the session you are actively
working in is the oldest and therefore the obvious one to park, which is exactly
backwards. Time-since-heartbeat says the one you have not touched since this
morning is.

### 4.1 A repair to S1, carved

`registry_list` did not filter by lease, while `registry_count` did — and the
function's docstring claimed "one line per live entry" from the day S1 shipped.
This slice would have reported "1 live session" and then listed four, on the
ordinary working day the count's filter exists to survive. A report whose halves
disagree is worse than no report.

**Repairing a function to match the behaviour its own contract promised is not a
contract change; it is the defect.** It is carved as its own commit, with its
own scenarios (R17: the list and the count never disagree; R18: the line carries
the heartbeat), so the fix is reviewable apart from the slice that found it and
every future consumer inherits the honest version rather than each re-deriving
the filter.

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
| `templates/pacts.md` | the `strict` field note, which still promises a recorded override |
| `reference/pacts-format.md` | the same promise, on the published page |
| `skills/sentinel-design/SKILL.md` | §7's note, and the roster |
| `README.md` | the Sentinels roster |

The two `strict` surfaces matter more than they look. The template is what a
human reads while deciding whether to write `strict` at all — they would choose
it on the promise of a recorded override and get an ask with no record. **The
mandatory clause above those field notes must not move**: `pact-write.sh`
derives it and T9 pins it.

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

## 7. The Lesson, With Its Provenance Corrected

An earlier draft claimed a pattern from two instances. One of them was
misattributed: the CI critic check on `Budgets` diffs was called for by the
**build spec**, and made impossible by S1's user-scoped pact decision — which S1
flagged at the time. That is a different shape, and stripping it leaves a single
case, which is thin ground for a promoted rule.

The sharper reading is available, and it is about a disposition rather than a
definition.

**S1's own gate caught this.** Objection O11 said that shipping `strict` with no
definition "pre-authorises S4 to interpret it as blocking". It was accepted, and
the disposition was *define the semantics* — which is exactly what produced a
token whose defined semantics no mechanism could deliver. S1 §3.5 shows the team
already possessed the stronger remedy and used it one block over: `Sync cadence`
ships with a reserved marker saying plainly that nothing reads it.

So the lesson for `sentinel-design` is not "define a token, name a mechanism" as
a fresh discovery. It is:

> When a gate accepts an objection that a token may be undeliverable, **defining
> its semantics is not a sufficient disposition.** Either name the mechanism that
> will deliver it, or mark it as awaiting one — the reserved-marker treatment.

That rule would have caught this at S1, where it was cheap, rather than at S4,
where the token was already in the shipped template a human authors from.

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

- **C1 — the hook is silent when no `Session WIP` block is declared.** Not an
  observe-only line; a hook with nothing to say says nothing. Exit 0.

  This departs from S1's Null Object contract, deliberately, and the departure
  is argued rather than assumed: a `SessionStart` hook announcing "no
  `Session WIP` block declared" to every user who never asked for this epic is
  exactly the imposition S1 warns against. **`/wip` does not follow it into
  silence** — see C11. S1's contract note is amended so S5 inherits the split
  rather than re-deriving it.
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
- **C8 — a malformed block degrades to silence** in the hook, never to a gate.
- **C11 — `/wip` uses the observe-only sentence.** Given no block and an
  explicit invocation, the command emits S1's fixed sentence. A human who asked
  a question and got nothing cannot tell an absent block from a compliant one.
- **C12 — a declared block with no limit compares nothing.** The output states
  the count, states that no limit is declared, points at `/mast tune`, and
  contains no breach language.
- **C9 — exits 0 on every path**, including an unreadable registry and `HOME`
  unset.
- **C10 — fires on startup only.** `SessionStart` re-fires on resume, clear and
  compact; a breach report re-injected mid-session is the thrash it exists to
  name. Same guard S2 used, and it writes nothing.

### 9.2 The boundary — `test-wip-check.sh` and the TDAD scenarios

- **B1 — no speculation in the Warden's output** (agent-verified, §9.3). This
  is a rubric, not a grep: the sentences that violate the boundary — "three
  sessions is a lot to be holding at once", "you have been switching between
  these for a while" — contain none of the obvious nouns, and a word list would
  pass every one of them while failing on `focus_blocks`.
- **B2 — the boundary is stated in both skills**, in the same terms, naming
  what is refused.
- **B3 — the Reservoir Warden's agent file is unchanged.** Only its skill gains
  a cross-reference.
- **B4 — no write surface is reachable.** The agent and the hook contain no
  source of `session-registry-write.sh` or `pact-write.sh`. The frontmatter
  check cannot see this: `Bash` is permitted and it reads only the declared
  `tools:` list.

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
