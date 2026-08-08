# Spec: Cadence Sentinels S1 — Shared Infrastructure

**Status:** Approved (revision 3, post-cartographer)
**Date:** 2026-08-08
**Issue:** #491
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
**Objection record:** `docs/superpowers/objections/cadence-sentinels-s1-infrastructure-design.md`
— 12 objections, 11 accepted, 1 rejected
**Choice stories:** `docs/superpowers/stories/cadence-sentinels-s1-infrastructure-design.md`
— 9 stories, all accepted, 3 dissolved structurally
**Scope:** the `ai-literacy-superpowers` plugin and two new record directories
**Explicitly out of scope:** every sentinel that consumes this plumbing. S1
ships plumbing only and gates nothing.

**Provenance:** *The Second Front — Arc Insertion Remit* (slide S5, the roadmap
sentinels) and *Compulsive Continuation — A Research Exploration* (evidence
base), via the build spec *The Cadence Sentinels*.

---

## 1. Problem Statement

Four new sentinels are planned — the Coda (S2), the Mast (S3), the WIP Warden
(S4), and the Convener (S5). Three of them need to know the same two things:
what pacts the human has declared, and how many sessions are live. Two of them
need somewhere durable to put a record.

Built per-sentinel, that becomes three near-identical parsers, three
incompatible notions of "a live session", and two record directories invented
mid-slice with schemas that drift apart. Built once, it becomes a shared
substrate the later slices consume and none of them re-derive.

This slice builds it once.

## 2. Design Principles Inherited

Every constitutional constraint from the build spec binds this slice. Four
bind it concretely.

**Honesty flags (constraint 3).** Every count this infrastructure yields
carries `observed` / `inferred` / `asked`. The flag is a property of the
*count*, not of the reader who happened to take it — see §4.3.

**Persist nothing about the person (constraint 4), and its boundary.** The
constraint targets **claims an agent makes *about* the person** — inference,
telemetry, scoring, any assertion about capacity or state. It does **not**
cover a pact the person authored themselves. A declared budget is a statement
*by* the human, not an observation *about* them, and a pact that is not durable
is not a pact.

The existing `## Cognitive reservoir` block already works this way: it holds
`chronotype: intermediate`, self-declared, while its own prose forbids
recording "a claim about your cognitive state to disk". Self-authored
declaration is on one side of the line; agent-authored assertion is on the
other.

This distinction is load-bearing for S2–S5 — parking records and consultation
dispositions are both records of how the human works — so it is carried into
`skills/sentinel-design/SKILL.md` rather than left as a fact about this spec.

**Read-only trust boundary (constraint 1).** Any library a sentinel may source
must be incapable of mutation. See §4.4.

**Progressive hardening (constraint 6).** Nothing here enforces anything. Every
block is optional and every consumer degrades to observe-only.

## 3. Component 1 — The Pact File

### 3.1 Location: user-scoped, not repo-scoped

Pacts live in **`~/.claude/pacts.md`** — one file per human, per machine, never
committed.

A stop hour, a focus window, a daily session ceiling, and a concurrency limit
are all properties of **the person**, not of a repository. A repo-scoped pact
file cannot answer "whose pact is this" in a project with five contributors,
and a per-repo concurrency limit compared against a machine-global session
count is a units mismatch: the same three live sessions would be compliant in
one repo and in breach in another, with the advisory depending on which
directory the human happened to be sitting in.

This is symmetric with the session registry (§4.1), which is machine-global for
exactly the same reason.

**Divergence from the build spec, flagged for the PR.** The build spec located
these blocks "in the plugin's harness-template source, wherever
`Cognitive reservoir` is defined" — that is, in `HARNESS.md`. Disposed
otherwise by Russ at the cartographer gate, 2026-08-08, on stories #4 and #5.
`HARNESS.md` remains the *repo's* declaration surface and is untouched by this
slice; `~/.claude/pacts.md` is the *person's*.

`## Cognitive reservoir` stays in `HARNESS.md`, unchanged (constraint 5). It is
not migrated, not reinterpreted, and gains only a documentation cross-reference.

### 3.2 Shape

`ai-literacy-superpowers/templates/pacts.md` ships the authored template: three
level-2 blocks, values as clean `- key: value` lines, prose field notes below
the values.

**Field notes go below the value lines, never on them.** This is not style.
The `read_key` helper in `hooks/scripts/reservoir-check.sh` strips whitespace
from a matched value but does not strip a trailing `# comment`, so
`window_hours: 8  # how far back` parses to a non-numeric string and degrades
silently to the built-in default. The live `HARNESS.md` reservoir block states
this rule; the shipped `HARNESS.md` template violates it. See §8, Note A.

**Adoption ramp.** The file does not exist until it is authored. S3's Tune
dialogue is the authoring path and creates it; until then every consumer
reports observe-only (§3.7). Nothing in S1–S7 writes a default pact file, and
nothing scaffolds one at install: an imposed default is precisely the budget
the clear-weather rule says does not hold.

### 3.3 `## Session WIP`

```text
- max_concurrent_sessions: <int>
- max_switches_per_hour: <int>
- stale_after_hours: <int>
- enforcement: advisory | strict
```

| Key | Grammar | Required |
| --- | --- | --- |
| `max_concurrent_sessions` | single integer | yes |
| `max_switches_per_hour` | single integer | no |
| `stale_after_hours` | single integer | no (defaults 12) |
| `enforcement` | one of `advisory`, `strict` | no (defaults `advisory`) |

`stale_after_hours` is the registry lease length (§4.2). It is declared rather
than compiled in because every other threshold in this harness — the whole
`## Cognitive reservoir` block, `window_hours` through `chronotype` — is
declared and human-tunable, and a slice premised on the human declaring their
pacts should not introduce the first threshold they cannot touch.

**`enforcement` semantics, defined here so S4 inherits a defined token rather
than defining one already declared in the wild:**

- `advisory` — the WIP Warden reports the breach and proceeds. No disposition
  required.
- `strict` — the WIP Warden requires a **disposition** before the session
  proceeds: either park an existing session, or override. It never blocks
  without an override path, and the override is always available.

The override is recorded in the new session's reflection entry, one line
naming what was urgent enough. That is the on-the-record human override
constraint 6 requires; there is no bypass, and `strict` never means
"unconditionally refuse".

Mandatory prose clause:

> This is a gate on sessions, never on the person. It counts; it does not
> assess.

### 3.4 `## Budgets`

```text
- daily_cost_ceiling: <amount> | not observable
- sessions_per_day: <int>
- hard_stop_hour: <HH:MM>
- focus_blocks: <HH:MM-HH:MM>, <HH:MM-HH:MM>
- notification_policy_after_stop: digest | none
- authored_at: <YYYY-MM-DD>
- authored_via: tune
```

| Key | Grammar | Notes |
| --- | --- | --- |
| `daily_cost_ceiling` | free text | the literal `not observable` is a valid, honest value |
| `sessions_per_day` | single integer | |
| `hard_stop_hour` | `HH:MM`, 24-hour, local | **contains a colon** |
| `focus_blocks` | comma-separated `HH:MM-HH:MM` ranges | **contains colons and spaces** |
| `notification_policy_after_stop` | one of `digest`, `none` | |
| `authored_at` | `YYYY-MM-DD` | |
| `authored_via` | `tune` | the only honest value; the file exists only if Tune authored it |

The grammar column is not decoration. Three of these values contain colons and
two contain spaces, which is precisely what the inherited parser destroys —
see §3.6.

Mandatory literal clause in the block's prose body:

> Unspent budget is not a debt.

The clause is part of the block, not a comment on it. A `Budgets` block whose
prose has lost the clause is **malformed** — a distinct state from absent,
defined in §3.7.

**On the clause as an interface.** Because detection is literal-string
matching, the sentence cannot be reworded, translated, shortened, or reflowed
across lines in any adopter's file without the block silently ceasing to read
as declared. That is deliberate — a pact enforced without its governing
sentence is a pact enforced against a framing nobody agreed to — but it makes
the wording a published interface. **Only a spec-first change may reword it**,
and rewording is a coordinated migration across every adopter, not a template
edit.

`authored_at` and `authored_via` serve S3's clear-weather rule: budgets that
hold are budgets their keeper authored deliberately, so the block records how
it came to hold its values.

### 3.5 `## Sync cadence` (reserved)

```text
- interrupt_mode: streaming | coalesced
- sync_points: <HH:MM>, <HH:MM> | on-demand
```

| Key | Grammar |
| --- | --- |
| `interrupt_mode` | one of `streaming`, `coalesced` |
| `sync_points` | comma-separated `HH:MM` times, or the literal `on-demand` |

**This block is reserved.** No S1–S7 sentinel consumes it. It ships now because
the three blocks form one vocabulary and introducing them piecemeal would leave
the template internally inconsistent — but the block's prose and the reference
page both carry a reserved marker:

> Reserved. No sentinel reads this block yet. Values declared here are inert;
> the slice that adds a consumer will define their behaviour.

Without it, an adopter who writes `interrupt_mode: coalesced` in good faith
binds a future consumer to a declaration made before any behaviour existed for
it — the argument O11 made about `enforcement: strict`, which was accepted.

### 3.6 The value-extraction rule

`block_key` splits on the **first** delimiter and trims whitespace **at the
ends only**. It does not reuse `read_key`'s extraction.

`read_key`'s `sed -E "s/.*[:=][[:space:]]*//"` is greedy — `.*[:=]` consumes
through the *last* colon on the line — and its `tr -d '[:space:]'` deletes
interior spaces. Verified empirically at the spec gate:

| Input line | `read_key` yields | Correct |
| --- | --- | --- |
| `hard_stop_hour: 18:30` | `30` | `18:30` |
| `focus_blocks: 09:00-12:00, 14:00-17:00` | `00` | `09:00-12:00, 14:00-17:00` |
| `daily_cost_ceiling: not observable` | `notobservable` | `not observable` |
| `window_hours: 8` | `8` | `8` |

`read_key` is safe today only because every reservoir value is a bare integer
or a single word. Three of the seven `Budgets` keys break it. This is the same
class of silent-degradation defect as Note A, and it bites harder, because a
`hard_stop_hour` that parses to `30` looks like nothing in particular to a
reader while S3 holds them to a budget nobody authored.

**Block scoping.** A key lookup is confined to the span between its block's
heading and the next heading of equal-or-higher level. This is the property
that justifies a purpose-built parser, and B8 tests it with two blocks
declaring the same key — a single-block fixture cannot distinguish
block-scoped lookup from whole-file lookup.

### 3.7 Three block states, and the Null Object contract

A block is in exactly one of three states.

| State | Test | Consumer behaviour |
| --- | --- | --- |
| **Absent** | no pact file, or no heading of that name | observe-only note, continue |
| **Malformed** | heading present, mandatory clause or required key missing | observe-only note **plus** a line naming what is missing, continue |
| **Declared** | heading present and well-formed | read it |

The observe-only note is a fixed sentence, emitted by the library so every
consumer says the same thing:

> no `<block name>` block declared — running in observe-only mode

**The Null Object contract.** `block_absent_note` plus `block_key`'s default
argument exist so that **a consumer never branches on absence**. Every sentinel
in S2–S5 runs one code path whether or not the block exists; the library
supplies the null behaviour. This is why absent and malformed collapse to the
same behaviour rather than that collapse being a coincidence, and it is the
library's real contract to the later slices.

**Malformed degrades to observe-only, never to a gate.** This is the reachable
case: someone edits their pact file, deletes prose they read as boilerplate,
and now holds a block that is present, parseable, and missing its governing
clause. Treating that as declared would let S3 hold them to a pact whose
governing clause they deleted.

Absence is never an error, never a warning, and never a gate. Malformed is a
note, and also never a gate. Observe-only is the expected resting state of a
project whose human has not authored a pact file, and that is correct: nothing
in this epic should happen to someone who never asked for it.

### 3.8 Shared block reader

`ai-literacy-superpowers/hooks/scripts/lib/pact-blocks.sh` exposes:

- `pact_file` — the resolved path (`$CLAUDE_PACTS_FILE` if set, else
  `~/.claude/pacts.md`); the override exists so tests need no home directory
- `block_state <heading>` — `absent` | `malformed` | `declared`
- `block_key <heading> <key> <default>` — per §3.6
- `block_absent_note <heading>` — the fixed sentence

This library is the only thing in S1 that reads a pact. It is plumbing, not a
sentinel: it has no opinion, no threshold, and no output of its own beyond the
value it was asked for.

## 4. Component 2 — Session Registry

### 4.1 Location, scope, and format

`~/.claude/sessions/<sanitised-session-id>.json`, one file per live session:

```json
{
  "id": "<sanitised session id>",
  "repo": "<absolute path to project root>",
  "started_at": "<ISO-8601 UTC>",
  "heartbeat": "<ISO-8601 UTC>"
}
```

**Scope: machine-global.** Thrash-switching is a property of the human, not of
a repository. Three sessions in three repos is exactly the case the WIP Warden
exists to catch, and a per-repo registry reports `1` for each of them. This is
what makes the `repo` field load-bearing rather than vestigial: it is how a
consumer lists the other live sessions and says where they are.

Because the registry lives outside every work tree, no `.gitignore` entry is
needed and nothing can accidentally commit it.

**Session id sanitisation.** The id arrives from the hook's stdin JSON
(`session_id`) and becomes a filesystem path component, so it is sanitised
before use with the pattern this repo already adjudicated for the same field
in `affordance-invocation-recorder.sh:55`:

```bash
printf '%s' "$session" | grep -qE '^[A-Za-z0-9._-]+$' || session="unknown"
```

A value containing `/` or `..` in a path context is strictly worse than the
JSON-injection case already fixed there, because the write lands outside the
intended directory.

**Collision rule.** Sanitisation maps every hostile id to the single fallback
`unknown`, so at most one `unknown.json` can exist. A count including an
`unknown` entry is flagged `inferred`, since that one file may stand for more
than one session.

### 4.2 Lifecycle — a lease with heartbeat renewal

The registry is a **lease**: an entry is valid for `stale_after_hours` from its
last heartbeat, and staying alive means renewing.

- **`SessionStart` hook** writes the entry if absent, and refreshes `heartbeat`
  if present. It does **not** reset `started_at` — `SessionStart` fires on
  startup, resume, clear, and compact, and a reset `started_at` would mean a
  long-running session never ages out.
- **`Stop` hook** refreshes `heartbeat`. It does **not** delete.
- **Retirement** is by lease expiry alone: an entry whose `heartbeat` is older
  than `stale_after_hours` (§3.3, default 12) is retired by the pruner.

**Why renewal rather than delete-on-`Stop`.** The `Stop` hook fires when the
main agent finishes responding — many times per session, not once at session
end. Every one of the nine existing `Stop` scripts declares "runs at session
end" in its header comment and none carries a once-per-session guard; that is
harmless for all nine, because each is an idempotent advisory whose worst
failure is a duplicate nudge. The registry would be the first *destructive*
consumer of that rail, and a destructive operation does not inherit an
idempotent one's tolerance for unverified firing semantics. A
delete-on-`Stop` registry would empty itself after each session's first
response, and the WIP Warden would report `1` while four sessions ran.

Renewal makes correctness independent of how often `Stop` fires. Once per
session, once per turn, or fifty times per turn all produce the same result: a
live session stays fresh, a dead one expires.

**Known limit of the lease, disclosed.** The renewal interval is "whenever the
agent finishes a turn", which is unbounded above — a session where the human is
reading, thinking, or waiting on a long tool run emits no heartbeat. Liveness
here means *recency of a completed turn*, not "a window is open". A human who
finds the default too short tunes `stale_after_hours`; that is what makes it a
declared key rather than a constant.

### 4.3 The honesty flag

The flag is a property of the count, not of the reader. It derives from durable
state — a retirement marker written by the pruner, and the presence of an
`unknown` entry — never from whether *this particular read* pruned something.

| Situation | Flag |
| --- | --- |
| No entry retired within the window; no `unknown` entry | `observed` |
| One or more entries retired within the window | `inferred` |
| An `unknown` entry present (§4.1) | `inferred` |
| No registry directory at all | `observed`, count 0 |

A count that followed a retirement is `inferred` because the pruner cannot
distinguish a crashed session from a long-running healthy one — it only knows
the lease expired. That uncertainty persists for every subsequent read, so the
flag must persist with it. A flag surviving only the first read after a prune
would disclose the uncertainty to whichever consumer happened to be first and
hide it from all the others.

### 4.4 Two libraries, split on the trust boundary

`sentinel-integrity-check.sh` enforces the read-only boundary by rejecting
`Write`/`Edit` in an agent's `tools:` list, and explicitly permits `Bash`. Its
own header names the limit: an agent reaching a write capability through an
undeclared channel is out of scope. A single shared library exposing mutation
to every sentinel would manufacture exactly that case, and CI would stay green
while a `role: sentinel` agent deleted files.

| File | Exposes | Who may source it |
| --- | --- | --- |
| `hooks/scripts/lib/session-registry-read.sh` | `registry_count` (count + flag), `registry_list` | hook scripts **and** sentinels |
| `hooks/scripts/lib/session-registry-write.sh` | `registry_touch`, `registry_prune` | hook scripts **only** |

The read library performs no mutation on any path. This generalises the
reasoning that keeps the Coda read-only (§8, Note D): the boundary is preserved
by what the agent *can* reach, not by what it is trusted not to call.

## 5. Component 3 — Record Directories and Schemas

Two directories, `docs/superpowers/parked/` and
`docs/superpowers/consultations/`, each with a `README.md` that **points at**
its format reference rather than duplicating it.

The schemas themselves live at:

- `docs/plugins/ai-literacy-superpowers/reference/parking-record-format.md`
- `docs/plugins/ai-literacy-superpowers/reference/consultation-record-format.md`

matching the repo's three existing `reference/*-format.md` pages. A README
inside `docs/superpowers/` would be committed but never published —
`mkdocs.yml:15` carries `exclude_docs: superpowers/` — so a format contract
homed there is the one contract in the repo an adopter cannot read.

**S1 owns these two contracts; S2 and S5 consume them.** Per the promoted
ARCH_DECISION, a consumer never mutates the contract it consumes: the first
time S2 needs a field the parking schema lacks, it carves a contract-owning
slice with its own adversarial pass rather than editing the reference page.

### 5.1 Append-only via state-in-the-path

Constraint 7 says records are append-only. A single mutable `status` key
contradicts that: editing `parked` to `resumed` in place *is* an in-place edit.
So **state lives in the filename**, and a transition writes a new file.

```text
docs/superpowers/parked/2026-08-08-retry-branch.md              <- parked
docs/superpowers/parked/2026-08-09-retry-branch.resumed.md      <- resumed
docs/superpowers/parked/2026-08-09-retry-branch.superseded.md   <- superseded
```

"What is still parked" is a glob: every `*.md` that is not itself a transition
file and is not named by any transition's `supersedes` field. Nothing is ever
edited, and nothing is ever deleted.

This also fits the Coda's trust boundary: resuming is a *write* by the `/coda`
command, not an *edit* of an existing record, so the read-only agent never
needs a mutation path.

### 5.2 Parking record

```yaml
---
session: <sanitised session id>
repo: <absolute path to project root>
created: <YYYY-MM-DD>
state: parked | resumed | superseded
supersedes: <filename> | null
next_action_flag: asked
---
```

Body: a `## Context` section (one paragraph) and a `## Next action` section
(one concrete resume step).

`state` restates what the filename already says, for readability; the filename
is authoritative. `next_action_flag` is always `asked` — the next action is
supplied by the human at the ritual, never inferred by the agent. Recording the
flag satisfies constraint 3 without implying the Coda observed anything.

`session` is **opaque provenance, not a lookup key**. The registry forgets an
entry one lease after its last heartbeat; a parking record is permanent. S2
must never resolve a parking record's `session` against the live registry.

### 5.3 Consultation record

```yaml
---
spec: <path to the spec under approval>
date: <YYYY-MM-DD>
state: open | resolved | superseded
supersedes: <filename> | null
voices:
  - voice: <role or group>
    source_flag: observed | inferred | asked
    question: <the concrete question worth asking them>
    disposition: pending | consulted | deliberately-not-consulted
    outcome: <one line> | null
---
```

`source_flag` records how the voice was identified: `observed` when a declared
stakeholder map named it, `inferred` when derived from the change itself,
`asked` when the human named it. `deliberately-not-consulted` requires an
`outcome` giving the because.

Because dispositions accumulate during a review, a consultation record is
written once per **revision**: disposing voices produces a new `.resolved.md`
file carrying the full voice list with dispositions filled, `supersedes`-ing
the open one. The frontmatter of a written record is never edited.

## 6. Non-Goals

- **No gating.** Nothing in this slice blocks, warns, or requires a
  disposition.
- **No sentinel agents, skills, or commands.** S1 ships no `role: sentinel`
  agent. The block reader (§3.8) is a parsing library, not a consumer: it
  answers "what does the block say", never "what should be done about it".
- **No changes to the Reservoir Warden**, its `HARNESS.md` block, its hook, or
  its skill. `## Cognitive reservoir` is not migrated to the pact file.
- **No `Sync cadence` consumer.**
- **No pact file created for anyone.** S1 ships the template; S3's Tune
  authors the file.
- **No fix to the template's inline-comment trap** (§8, Note A).

## 7. Acceptance Scenarios (TDAD)

Scenarios carry stable prefixed ids: **B** for block behaviour, **R** for the
registry, **C** for the record contracts. Every block scenario runs against a
**fixture** pact file via `$CLAUDE_PACTS_FILE`; no test asserts a value a human
is expected to change.

### 7.1 Blocks — `tdad_tests/layer0_deterministic/test-pact-blocks.sh`

- **B1 — Template well-formed.** Given `templates/pacts.md`, then all three
  block headings exist, and no value line in any of the three carries a
  trailing `#` comment.
- **B2 — Mandatory clauses present.** Given `templates/pacts.md`, then the
  `Budgets` prose contains `Unspent budget is not a debt.` and the
  `Session WIP` prose contains its gate-on-sessions clause.
- **B3 — Reserved marker present.** Given `templates/pacts.md`, then the
  `Sync cadence` block prose carries the reserved marker.
- **B4 — No pact file at all.** Given `$CLAUDE_PACTS_FILE` points nowhere, when
  `block_state` runs for each of the three, then each reports `absent`,
  `block_absent_note` emits the §3.7 sentence, exit 0.
- **B5 — Absent block in a present file.** Given a pact file declaring only
  `Budgets`, when `block_state Session WIP` runs, then it reports `absent`.
- **B6 — Malformed block.** Given a pact file whose `Budgets` prose is missing
  the not-a-debt clause, when `block_state` runs, then it reports `malformed`,
  the consumer degrades to observe-only, and a note names the missing clause.
  No gate fires.
- **B7 — Colon- and space-bearing values survive.** Given a declared `Budgets`
  block, when `block_key` reads each key, then `hard_stop_hour` returns `18:30`
  (not `30`), `focus_blocks` returns the full comma-separated ranges (not
  `00`), and `daily_cost_ceiling` returns `not observable` with its interior
  space intact.
- **B8 — Block-scoped key isolation.** Given a pact file with **two** blocks
  declaring a key of the same name with different values, when `block_key` runs
  against each, then each returns its own block's value. A whole-file parser
  fails this scenario.
- **B9 — Default returned for an absent key.** Given a declared block missing
  an optional key, when `block_key` runs with a default, then the default is
  returned and no error is raised.

### 7.2 Registry — `tdad_tests/layer0_deterministic/test-session-registry.sh`

- **R1 — Write on start.** Given no entry for session X, when `SessionStart`
  runs, then the entry exists with `id`, `repo`, `started_at`, `heartbeat`.
- **R2 — `SessionStart` re-fire preserves `started_at`.** Given an existing
  entry, when `SessionStart` fires again, then `heartbeat` advances and
  `started_at` is unchanged.
- **R3 — `Stop` renews, never deletes.** Given an entry for X, when `Stop` runs
  three times, then the entry still exists and `heartbeat` has advanced. This
  is the scenario that would have caught the delete-on-`Stop` design.
- **R4 — Two overlapping sessions counted.** Given fresh entries for X and Y,
  when `registry_count` runs, then it reports `2` flagged `observed`.
- **R5 — Expired lease retired, count flagged inferred.** Given an entry whose
  `heartbeat` is older than the lease, when the pruner runs and
  `registry_count` follows, then the entry is gone and the count is `inferred`.
- **R6 — Flag survives repeated reads.** Given the state after R5, when
  `registry_count` runs again twice, then every read still reports `inferred`.
- **R7 — Lease length is declared.** Given a pact file declaring
  `stale_after_hours: 2` and an entry whose heartbeat is 3 hours old, when the
  pruner runs, then the entry is retired. Given `stale_after_hours: 24`, the
  same entry survives.
- **R8 — `registry_count` mutates nothing.** Given any registry state, when
  `registry_count` runs, then the directory's contents are byte-identical
  before and after.
- **R9 — Read library exposes no mutation.** Given
  `lib/session-registry-read.sh`, then it defines no function that writes,
  deletes, or moves a file, and `registry_touch` / `registry_prune` are
  undefined after sourcing it alone.
- **R10 — Hostile session id sanitised.** Given a hook input whose `session_id`
  contains `/` or `..`, when `SessionStart` runs, then the written path is
  `<registry>/unknown.json` and no file is created outside that directory.
- **R11 — `unknown` entry flags the count inferred.** Given a registry
  containing `unknown.json`, when `registry_count` runs, then the count is
  flagged `inferred`.
- **R12 — No registry directory.** Given the registry directory does not exist,
  when `registry_count` runs, then it reports `0` flagged `observed`, exit 0.
- **R13 — Registry lives outside every work tree.** Given a written entry, when
  `git status --porcelain` runs in this repo, then no session path appears.

### 7.3 Record contracts — `tdad_tests/layer0_deterministic/test-record-contracts.sh`

- **C1 — Reference pages carry the schemas.** Given the two
  `reference/*-record-format.md` pages, then each contains every field named in
  §5.2 and §5.3 respectively, and each states the state-in-the-path rule.
- **C2 — Directory READMEs point, not duplicate.** Given each record
  directory's README, then it links its reference page and declares no field
  set of its own.
- **C3 — State-in-path glob.** Given a fixture directory containing a parked
  record, its `.resumed.md` successor, and an unrelated parked record, then the
  documented glob yields exactly the one still-parked record.

## 8. Notes and Divergences from the Build Spec

**Note A — template inline-comment trap (pre-existing, out of scope).** The
shipped `## Cognitive reservoir` template block carries inline `#` comments on
its value lines (`templates/HARNESS.md:614–621`). A downstream project that
uncomments the block and tunes a value gets a silent degrade to the built-in
default. Raised as a follow-up issue, not fixed here.

**Note B — pacts are user-scoped.** `~/.claude/pacts.md`, not `HARNESS.md` and
not `.superpowers/`. The build spec located the blocks in the harness template;
disposed otherwise at the cartographer gate on stories #4 and #5. See §3.1.
**Flag this in the PR description.**

**Note C — lease with heartbeat renewal, not delete-on-`Stop`.** See §4.2.

**Note D — the sentinel category is already load-bearing.** Build-spec
constraint 9 anticipates a repo that has not yet adopted the sentinel category
and asks for a docs-only introduction. The category shipped in v0.66.0 with a
spec, the `sentinel-design` skill, a README section, `role: sentinel`
frontmatter, and `scripts/sentinel-integrity-check.sh` gating both PRs and the
weekly GC sweep. Consequences for later slices:

- Every new sentinel must satisfy S1–S3 and carry `role: sentinel`.
- The Coda cannot hold `Write`. Its agent returns record content; the `/coda`
  command persists it after a human disposes — the `cost-estimator` precedent.
- The same reasoning generalises to shared libraries, which is why §4.4 splits
  read from write rather than trusting sentinels not to call a mutator.
- S7's "create a sentinel category page" becomes "extend the existing one",
  roster 5 → 9.
- The rename open note in constraint 9 is moot.

**Note E — deriving the count from the invocation log was considered and
rejected.** `observability/affordance-invocations.json` already records
`{"session": ..., "ts": ...}` per tool call. Rejected because the recorder's
`PostToolUse` matcher is `Bash|mcp__.*`: a session that only reads and edits
files never appears, so the derived count would silently undercount exactly the
long-running sessions the WIP Warden exists to notice. The `asked` fallback
remains available to S4 when observation fails.

**Note F — nothing about the person is committed.** Revision 2 activated a
`Budgets` block in this repo's public `HARNESS.md` and argued it was permitted
by §2's BY/ABOUT boundary. Revision 3's user-scoped pact file moots the
question: no pact is committed anywhere. The BY/ABOUT distinction still goes
into `sentinel-design`, because S2's and S5's records *are* committed and need
the rule.

## 9. Migration & Rollout

Minor version bump, 0.66.2 → 0.67.0.

Version locations (five CI-checked, plus one human-facing):

- `ai-literacy-superpowers/.claude-plugin/plugin.json`
- `README.md` shields.io badge
- `CHANGELOG.md` top heading
- `.claude-plugin/marketplace.json` — `plugin_version`
- `.claude-plugin/marketplace.json` — this plugin's `plugins[].version`
- `README.md` plugin-table row cell (not CI-checked)

Docs, in the same PR per the `Docs Site Review` convention:

- `reference/pacts-format.md` — new; the three blocks and the value grammar
- `reference/parking-record-format.md` and
  `reference/consultation-record-format.md` — new; §5.2 and §5.3
- `reference/hooks.md` — the `SessionStart` and `Stop` registry entries
- `explanation/sentinels.md` — a pointer noting the pact file as a new
  declaration surface distinct from `HARNESS.md`

No breaking changes. `HARNESS.md` is untouched. The pact file does not exist
until authored; the registry is machine-local state outside every work tree
that no existing hook reads; the record directories are new.
