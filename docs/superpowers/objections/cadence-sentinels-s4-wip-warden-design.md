---
spec: docs/superpowers/specs/2026-08-10-cadence-sentinels-s4-wip-warden-design.md
date: 2026-08-10
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "Section 4 asserts the per-session list comes from registry_list, but registry_list does not filter by lease — so the hook's count and its list will contradict each other on the ordinary working day S1 built the filter for."
    evidence: "Spec 4: 'The ages come from registry_list. Each live session is listed with its started_at and its repo.' session-registry-read.sh registry_list iterates every *.json with no heartbeat check; only registry_count filters expired leases. The function's own docstring says 'one line per live entry', which is where the spec's error came from."
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: implementation
    severity: high
    claim: "The hook's placement on the SessionStart rail alongside S1's own session-registry-start.sh leaves it undefined whether the count includes the session that is starting, and the spec states no ordering requirement."
    evidence: "hooks.json runs session-registry-start.sh on SessionStart, which writes the entry for the starting session. Spec 5 adds wip-check.sh to the same event. C2 says 'Two live sessions, limit two, no output' without saying whether the starting session is one of the two, and the spec fixes neither the inclusion rule nor the comparison operator."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: specification quality
    severity: high
    claim: "The spec never names the key holding the limit, and defines no behaviour for a Session WIP block that is declared but omits it — a case block_state reports as declared, so C8's malformed path will not catch it and the implementer must invent a default limit."
    evidence: "max_concurrent_sessions appears zero times in the spec. pact-blocks.sh block_state checks the mandatory clause only, never a required key, despite S1 3.7 defining malformed as 'mandatory clause OR required key missing'. block_key then returns the caller's default. Tune deliberately offers a two-line pact, so a block with the clause and no limit is a plausible product of the sanctioned authoring path."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: specification quality
    severity: high
    claim: "C1 and C8 specify silence on absent and malformed blocks, which departs from S1's Null Object contract and from the shipped test asserting a malformed block still emits the observe-only sentence — and the spec neither acknowledges the departure nor says whether /wip follows the hook into silence."
    evidence: "Spec C1 and C8 specify silence. S1 3.7: 'The observe-only note is a fixed sentence, emitted by the library so every consumer says the same thing... a consumer never branches on absence.' test-pact-blocks.sh B6 asserts a malformed block still emits it. session-registry-read.sh's own comment addresses this slice by name: 'that value advises a person, so a malformed block must degrade to observe-only.'"
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: implementation
    severity: high
    claim: "B1 tests a vocabulary list rather than the behaviour section 2 forbids: the list is under-inclusive against every speculation an implementer would actually write, over-inclusive against the live focus_blocks key, and its 'focus (as a state)' carve-out is not machine-checkable in a Layer-0 script."
    evidence: "Spec B1 bans seven nouns under a deterministic test file. Every one of 'Three sessions is a lot to be holding at once', 'You have been switching between these for a while', and 'Might be worth slowing down' passes B1 and violates section 2. focus_blocks is a live pact key. A green B1 will be read as evidence that the boundary section 2 calls the most important in the slice is machine-enforced. It is not."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: specification quality
    severity: high
    claim: "B1 extends the word ban to the WIP Warden's skill, while section 5 makes that skill responsible for stating the boundary and section 2 states that boundary using four of the banned words — and B2 then requires both skills to state it in the same terms while only one is under the ban."
    evidence: "Spec 5 tasks skills/wip-warden/SKILL.md with 'the boundary... the anti-patterns'. Section 2 states it as 'never speculates about attention, fatigue, focus, or capacity'. Section 2's own scope is OUTPUT; B1's is files. cognitive-reservoir/SKILL.md contains ten instances of the banned vocabulary and is not under the ban. B1, B2, section 2 and section 5 cannot all be satisfied."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: scope
    severity: high
    claim: "The two shipped surfaces stating S1's old meaning of strict — the pact template the human authors from and the pacts reference page — are not in section 5's file list or section 10's docs list, so on the day S4 ships they promise an on-the-record override the slice deliberately does not build."
    evidence: "templates/pacts.md: 'strict asks you to park something or say, on the record, what was urgent enough. There is always an override.' reference/pacts-format.md repeats it. Spec 5 lists commands/mast.md as the only corrected existing file; section 10's docs list omits reference/pacts-format.md entirely."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: specification quality
    severity: medium
    claim: "Section 4's per-session 'age' is not defined and the field it would be computed from measures something other than the liveness the count uses: registry_list returns started_at, while registry_count's liveness turns on heartbeat, which the list does not return at all."
    evidence: "Spec 2 promises 'an age per session'; section 4 says the list carries started_at and repo. registry_list prints id, started_at, repo — no heartbeat. S1 4.2: 'Liveness here means recency of a completed turn, not a window is open.' The two readings give opposite advice about which session to park."
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: premise
    severity: medium
    claim: "Section 7's 'pattern worth naming' rests on one supporting instance rather than two — its first example misattributes to S1 a promise the build spec made — and it omits that S1's own gate already raised this exact concern as O11 and disposed it with the weaker remedy section 7 now finds insufficient."
    evidence: "Spec 7 says 'S1 promised a CI critic check on Budgets diffs'; S3 2.2 attributes it to the build spec, made impossible by S1's location decision. S1's O11 said shipping strict undefined 'pre-authorises S4 to interpret it as blocking', and was disposed with 'gains a one-line semantics' — which is what produced a token whose defined semantics no mechanism could deliver. S1 3.5 shows the stronger remedy, the reserved marker, was available and applied to Sync cadence but not to enforcement."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: alternatives
    severity: medium
    claim: "The spec does not weigh shipping /wip alone against adding a SessionStart hook, though the hook is the source of most of the slice's cost and three of this record's objections."
    evidence: "Ten of the slice's fourteen scenarios exist only because of the hook. S3's evidence comment, recorded for #501, distinguishes a boundary-moment check from an ambient reminder. A SessionStart breach report arrives AFTER the switch it exists to discourage, so its ask is remediation rather than prevention — which may still be the best moment available, but the spec asserts the placement rather than arguing it."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: scope
    severity: medium
    claim: "Section 5's file list omits skills/sentinel-design/SKILL.md, which section 7 requires this slice to change, and omits the sentinel rosters that must gain the new agent."
    evidence: "Section 7's only deliverable is a note in sentinel-design; section 5's six-file table does not include it, and no B or C scenario would catch the omission. sentinel-design also carries a five-agent roster table and a checklist step requiring the README Sentinels section to be updated; section 10 mentions only the docs page roster."
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: risk
    severity: medium
    claim: "Section 5 states the write-library prohibition as a guarantee, but nothing checks it: sentinel-integrity-check.sh reads only the declared tools list, and no scenario asserts the agent sources no write surface."
    evidence: "Spec 5: 'It must never source session-registry-write.sh or pact-write.sh.' sentinel-integrity-check.sh contains no match for either name. sentinel-design states the principle: 'a shared library that exposes a mutation function to a sentinel breaches this boundary through a channel the frontmatter check cannot see.' S1's R9 is the machine check for the analogous claim; S4 has none."
    disposition: pending
    disposition_rationale: null
---

# Objection record — Cadence Sentinels S4: The WIP Warden (spec mode)

Twelve objections: one critical, six high, five medium.

Three items were disposed at the design gate and are not re-litigated: the
redefinition of `strict`, the deferral of the override record to #501, and S4
correcting S3's stale disclosure line. Where an objection touches those areas
(O4, O7) it accepts the disposition and challenges only what the spec did not
follow through on.

**Dispatcher verification note (2026-08-10).** Three claims verified before
recording. `registry_list` iterates every `*.json` with no heartbeat check
while `registry_count` filters expired leases — **and the function's own
docstring says "one line per live entry", which is false and was written in
S1**. `max_concurrent_sessions` appears **zero** times in this spec. And
`block_state` checks the mandatory clause only, never a required key, despite
S1 §3.7 defining malformed as "mandatory clause **or required key** missing" —
a latent S1 defect this slice is the first to expose.

## O1 — implementation — critical

§4 says the per-session ages come from `registry_list`. That function does not
filter by lease: it emits one line for every `*.json` in the registry,
including entries whose heartbeat expired hours ago and which `registry_count`
deliberately excludes. C3 and C4 together specify a report that contradicts
itself on exactly the working day S1 added the filter to survive.

On a machine with one live session and three finished ones whose leases have
expired but which the pruner has not yet swept, C3 reports "1 live session" and
C4 lists four. A report whose halves disagree is worse than no report: the
human cannot tell which number to act on, and the slice's stated purpose is to
be "actionable rather than merely true".

The error's provenance matters. `registry_list`'s docstring reads "one line per
live entry" — written in S1, false since S1, and the spec inherited it.

The fix is not free, which is why this is critical rather than high. S4 cannot
simply change `registry_list`: S1 owns it, and the promoted decision is that a
consumer never mutates the contract it consumes. The alternatives are to
re-derive the lease filter inside `wip-check.sh` — duplicating the logic S1
built one library to prevent three copies of — or to reach for `_lease_hours`
and `_iso_to_epoch`, two underscore-private helpers of another slice's library.
Each has scope consequences the spec has not budgeted for.

A related gap rides along: an `unknown.json` entry appears in the list as one
row with one `repo`, though S1's collision rule says it may stand for more than
one session. §4's flag table handles that for the count and says nothing about
the list.

## O2 — implementation — high

`wip-check.sh` and S1's `session-registry-start.sh` are both `SessionStart`
hooks, and the spec states no ordering. So it is undefined whether the count
includes the session the human is opening.

Two problems, both invisible to the Layer-0 tests, which will invoke the hook
directly against a pre-seeded registry rather than through the rail.

Ordering: if the hooks are not guaranteed sequential, the count is racy — the
same machine state produces a breach on one launch and silence on the next. A
sentinel whose output flickers teaches the human to discount it.

Semantics, which bites even if ordering is deterministic. A human writing
`max_concurrent_sessions: 2` — whose field note reads "how many sessions you
are willing to have live at once" — almost certainly means two *including* the
one they are in. The spec fixes neither the inclusion rule nor the comparison
operator, so an implementer has a one-in-four chance of matching intent.

## O3 — specification quality — high

The spec never names the key it reads. `max_concurrent_sessions` appears zero
times. And it defines no behaviour for a `Session WIP` block carrying its
mandatory clause but omitting that key — a case `block_state` returns
`declared` for, so C8 will not catch it and the implementer must invent a
default.

That block is not a pathological fixture. Tune explicitly offers a two-line
pact and declines to march the human through the rest, so a block with the
clause and `stale_after_hours` but no limit is a plausible product of the
sanctioned authoring path.

Against such a block C1 does not fire, C8 does not fire, and the hook compares
a real count against a number the plugin chose. S1 §3.2 states the rule this
breaks: "an imposed default is precisely the budget the clear-weather rule says
does not hold." The Warden would report a breach of a limit the human never
set — the worst output this slice can produce, and the one §3.2 argues hardest
against.

Underneath sits a latent S1 defect: S1 §3.7 defines malformed as "mandatory
clause **or required key** missing" and `block_state` implements only the
clause half.

## O4 — specification quality — high

C1 and C8 specify silence where S1's Null Object contract specifies the fixed
observe-only sentence. The departure may be right for a hook — a `SessionStart`
hook announcing "no `Session WIP` block declared" to every user who never asked
for this epic would be exactly the imposition S1 warns against — but the spec
asserts it in a scenario line rather than arguing it, and leaves three things
undecided.

Whether `/wip` is also silent. Silence there is a bug: the human asked a
question and got nothing, with no way to distinguish an absent block from a
compliant one.

Whether S1's contract is now "every consumer says the sentence, except hooks",
and where that amendment is recorded so S5 inherits the right rule.

Whether C8's silence is reachable at all for the case that matters — per O3,
the missing-key block never reaches the malformed state C8 tests.

The shipped library's own comment addresses this slice by name: "that value
advises a person, so a malformed block must degrade to observe-only."

## O5 — implementation — high

B1 bans seven nouns. The behaviour §2 forbids is speculation about the person,
and the two do not coincide.

Every one of these passes B1 and violates §2:

- "Three sessions is a lot to be holding at once."
- "You have been switching between these for a while."
- "Might be worth slowing down."
- "You are spread across three repositories."

Meanwhile `focus_blocks` is a live pact key and a plausible cross-reference in
the skill, and the "(as a state)" qualifier is a judgement call — so the check
is either mechanically wrong or not mechanical at all, in which case it is an
agent-verified scenario wearing a deterministic one's clothes.

The deeper problem is the one this spec applies rigorously to `strict` and does
not apply to itself. §3.2: "A sentinel that implied it could stop you would be
claiming a power it does not have." A green B1 will be read — by the next
author, by S5's reviewer — as evidence that the boundary §2 calls "the most
important section in the slice" is machine-enforced. It is not.

## O6 — specification quality — high

B1 extends the ban to `skills/wip-warden/SKILL.md`, but §5 makes that file
responsible for stating the boundary, and §2 states it using four banned words.
B2 then requires the same boundary in both skills "in the same terms" while
only one is under the ban. B1, B2, §2 and §5 cannot all be satisfied.

Note that §2's own scope is **output**; B1's is files.

The likeliest resolution an implementer reaches for is a weaker boundary
statement that avoids naming what is forbidden. That inverts the discipline
`sentinel-design` promoted — decide what you will refuse to assert, then build
only what you can honestly report — and a refusal that cannot name what it
refuses is not a usable rule for the next author, who reads the skill.

## O7 — scope — high

Two shipped surfaces state S1's original meaning of `strict` verbatim, and
neither appears in §5's file list or §10's docs list.

The template's field note promises "on the record, what was urgent enough.
There is always an override, and it is always yours to take." The reference
page repeats it. S4 explicitly does not build that record.

§6 argues correctly that correcting a statement of fact that has become false
is not mutating a contract, and spends a paragraph on one line in
`commands/mast.md`. The same reasoning applies with more force here, and these
were missed. The template is the worse of the two, because it is what the human
reads while deciding whether to write `strict` at all: they choose it on the
promise of a recorded override and get an ask with no record.

One caution for whoever fixes this: `pact-write.sh` derives the mandatory
clause from `templates/pacts.md`, pinned by T9, so the clause must not move.
The field notes below it are free.

## O8 — specification quality — medium

"An age per session" is never defined, and the only available field measures a
different thing from the one the count's liveness turns on. `registry_list`
returns `started_at`; `registry_count` decides liveness from `heartbeat`, which
the list does not return.

The two readings give opposite advice. Age-since-start says a long-running
session you are actively working in is the oldest and therefore the obvious
one to park. Time-since-heartbeat says the session you have not touched since
this morning is. Only the second is the actionable fact C4 claims to deliver.

Computing either from an ISO timestamp requires `_iso_to_epoch`, an
underscore-private helper of S1's library — the same question O1 raises, and
probably with the same answer.

## O9 — premise — medium

Scoped to §7 and the `sentinel-design` change it proposes, not to the slice.

§7 generalises from two instances, but the first is misattributed: S1 promised
no CI critic check — the build spec did, and S1's location decision made it
impossible, which S1 flagged at the time. That is a different shape. Strip it
and §7 rests on a single case, which is thin ground for a promoted rule.

The stronger reading is available and §7 misses it. This was caught at S1's own
gate as O11 — "shipping `strict` with no definition and no override path
pre-authorises S4 to interpret it as blocking" — and accepted, with the remedy
"define the semantics". That remedy is what produced a token whose defined
semantics no mechanism could deliver. S1 §3.5 shows the team already possessed
the stronger remedy, the reserved marker, and applied it to `Sync cadence`
while declining to apply it to `enforcement`.

That asymmetry is the lesson: not "define a token, name a mechanism" as a fresh
discovery, but **when a gate accepts an objection about an undeliverable token,
defining its semantics is not a sufficient disposition — mark it as awaiting a
mechanism.**

## O10 — alternatives — medium

The spec does not weigh `/wip` alone against adding a `SessionStart` hook. Ten
of fourteen scenarios exist only because of the hook, along with three
objections in this record.

A `SessionStart` breach report arrives *after* the switch it exists to
discourage: its ask is remediation, not prevention. That may still be the best
moment available — the earliest at which the fact is knowable and the human is
present — but the spec should say so, because the alternative is materially
cheaper.

A second alternative goes unnamed: the `Stop` rail, where the registry already
runs and the human is between turns. It has the opposite trade — repeats, which
S3's evidence says makes adherence worse — and is probably wrong. "Probably
wrong for a stated reason" is what the record should contain.

## O11 — scope — medium

§5's file table is what an implementer works from, and it omits
`skills/sentinel-design/SKILL.md`, which §7 requires this slice to change. §7's
note is that section's only deliverable, and no scenario would catch its
absence. The sentinel rosters that must gain the new agent are also missing
from §5, and §10 mentions only the docs-page roster.

Worth flagging in passing: `sentinel-design`'s roster is itself a pinned copy
of a derived fact — which agents carry `role: sentinel` — and §6 of this very
spec argues that harness artefacts derive from the source of truth rather than
pinning a copy. The slice notices the pattern in `commands/mast.md` and not in
the roster it is about to edit by hand.

## O12 — risk — medium

§5 states the write-library prohibition as a guarantee and nothing checks it.
`sentinel-integrity-check.sh` parses the declared `tools:` list and has no
notion of what a script sources.

S1 solved this structurally for its own libraries: the read surface defines no
mutator, so the guarantee holds by construction. S4's is different in kind —
`pact-write.sh` exists, ships, and is reachable from a `Bash`-holding sentinel
with one `.` line, with the frontmatter check green.

This is pre-existing rather than invented here (S3 makes the same unchecked
claim), which is why it is medium. But S4 is the second slice to state it and
the first with two write surfaces in play, and a scenario grepping the agent
and hook for a source of either costs a line and would hold for S5 too.

## Explicitly not objecting to

- **The redefinition of `strict`, the deferral of its record to #501, and S4
  correcting S3's stale line.** All disposed at the design gate. O4 and O7
  accept them and challenge only what was not carried through.
- **The §2 boundary itself.** The split is the right line, and the argument
  that a sibling inferring state from session counts retroactively breaks the
  Warden's trust model is the best paragraph in the spec. O5 and O6 challenge
  the *mechanism*, not the boundary.
- **Not reading `max_switches_per_hour`.** Correct and correctly reasoned:
  nothing records a switch, and inferring one is the speculation §2 forbids.
- **C9 and C10.** Exit-0-everywhere and the once-per-session `source` guard both
  match shipped precedent, and C10's justification — a breach report
  re-injected on compact is the thrash it exists to name — is exactly right.
- **The count's honesty-flag table in §4.** It maps correctly onto
  `registry_count`'s three `inferred` triggers and honours S1's no-exact-count
  rule. O1 and O8 concern the list, not the count.
- **The `role: sentinel` classification.** Satisfies all three criteria and
  passes the near-miss test.
- **Version and rollout arithmetic.** Consistent with the convention and with
  S3's shipped counts.
