# Spec: Cadence Sentinels S1 — Shared Infrastructure

**Status:** Approved (revision 2, post-diaboli)
**Date:** 2026-08-08
**Issue:** #491
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
**Objection record:** `docs/superpowers/objections/cadence-sentinels-s1-infrastructure-design.md`
— 12 objections, 11 accepted, 1 rejected on the record
**Scope:** `ai-literacy-superpowers` plugin, this repo's own `HARNESS.md`, and
two new record directories
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

Built per-sentinel, that becomes three near-identical `HARNESS.md` parsers,
three incompatible notions of "a live session", and two record directories
invented mid-slice with schemas that drift apart. Built once, it becomes a
shared substrate the later slices consume and none of them re-derive.

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
`chronotype: intermediate`, self-declared, in committed `HARNESS.md`, while
its own prose forbids recording "a claim about your cognitive state to disk".
Self-authored declaration is on one side of the line; agent-authored assertion
is on the other.

This distinction is load-bearing for S2–S5 — parking records and consultation
dispositions are both records of how the human works — so it is carried into
`skills/sentinel-design/SKILL.md` rather than left as a fact about this spec.

**Read-only trust boundary (constraint 1).** Any library a sentinel may source
must be incapable of mutation. See §4.4.

**Progressive hardening (constraint 6).** Nothing here enforces anything. All
three blocks are optional; every consumer degrades to observe-only.

## 3. Component 1 — Three `HARNESS.md` Block Schemas

### 3.1 Placement and shape

The blocks are defined in `ai-literacy-superpowers/templates/HARNESS.md`,
adjacent to the existing `## Cognitive reservoir` block, and follow its shape
exactly: a commented-out optional block that a downstream project opts into by
removing the `<!--` fence, values as clean `- key: value` lines, and prose
field notes below the values.

**Field notes go below the value lines, never on them.** This is not style.
The `read_key` helper in `hooks/scripts/reservoir-check.sh` strips whitespace
from a matched value but does not strip a trailing `# comment`, so
`window_hours: 8  # how far back` parses to a non-numeric string and degrades
silently to the built-in default. The live `HARNESS.md` block already states
this rule; the shipped template violates it. See §8, Note A.

### 3.2 `## Session WIP`

```text
- max_concurrent_sessions: <int>
- max_switches_per_hour: <int>
- enforcement: advisory | strict
```

| Key | Grammar | Required |
| --- | --- | --- |
| `max_concurrent_sessions` | single integer | yes |
| `max_switches_per_hour` | single integer | no |
| `enforcement` | one of `advisory`, `strict` | no (defaults `advisory`) |

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

`max_concurrent_sessions` counts sessions **machine-wide**, not in this repo —
see §4.1. The limit is declared per-repo; the count it is compared against is
global.

The block carries a mandatory prose clause, mirroring `Budgets`:

> This is a gate on sessions, never on the person. It counts; it does not
> assess.

### 3.3 `## Budgets`

```text
- daily_cost_ceiling: <amount> | not observable
- sessions_per_day: <int>
- hard_stop_hour: <HH:MM>
- focus_blocks: <HH:MM-HH:MM>, <HH:MM-HH:MM>
- notification_policy_after_stop: digest | none
- authored_at: <YYYY-MM-DD>
- authored_via: tune | placeholder
```

| Key | Grammar | Notes |
| --- | --- | --- |
| `daily_cost_ceiling` | free text | the literal `not observable` is a valid, honest value |
| `sessions_per_day` | single integer | |
| `hard_stop_hour` | `HH:MM`, 24-hour, local time | **contains a colon** |
| `focus_blocks` | comma-separated `HH:MM-HH:MM` ranges | **contains colons and spaces** |
| `notification_policy_after_stop` | one of `digest`, `none` | |
| `authored_at` | `YYYY-MM-DD` | |
| `authored_via` | one of `tune`, `placeholder` | |

The grammar column is not decoration. Three of these values contain colons and
two contain spaces, which is precisely what the inherited parser destroys —
see §3.7.

The block template carries a **mandatory literal clause** in its prose body:

> Unspent budget is not a debt.

The clause is part of the block, not a comment on it. A `Budgets` block whose
prose has lost the clause is **malformed** — a distinct state from absent,
defined in §3.6.

`authored_at` and `authored_via` exist for S3's clear-weather rule: budgets
that hold are budgets their keeper authored deliberately, so the block records
*how* it came to hold its values. `authored_via: placeholder` is the honest
value for a block that was scaffolded rather than authored.

Consumed by the Mast (S3), which owns the only sanctioned editing path.

### 3.4 `## Sync cadence`

```text
- interrupt_mode: streaming | coalesced
- sync_points: <HH:MM>, <HH:MM> | on-demand
```

| Key | Grammar |
| --- | --- |
| `interrupt_mode` | one of `streaming`, `coalesced` |
| `sync_points` | comma-separated `HH:MM` times, or the literal `on-demand` |

Declared here; no S1–S7 sentinel consumes it yet. It ships now because the
three blocks form one vocabulary and splitting their introduction across slices
would leave the template internally inconsistent. Its consumer is future work,
on the record.

### 3.5 Activation in this repo

All three blocks are additionally **activated** (uncommented, with values) in
this repo's own root `HARNESS.md`, exactly as `## Cognitive reservoir` is. The
repo dogfoods its own harness; a sentinel written in S2–S5 against a block that
exists nowhere real is a sentinel tested only against its own fixtures.

Committing a `Budgets` block to public history is permitted by the boundary
drawn in §2: these are pacts the keeper declared, not claims an agent made.

`Budgets` is activated with provisional values and `authored_via: placeholder`.
It is **not** authored in this slice — authoring it here would produce exactly
the imposed-default budget the clear-weather rule says does not hold. S3's Tune
dialogue is where the real pact gets made, and it will overwrite these values
and set `authored_via: tune`.

### 3.6 Three block states

A block is in exactly one of three states, and consumers must distinguish them.

| State | Test | Consumer behaviour |
| --- | --- | --- |
| **Absent** | no uncommented heading of that name | emit the observe-only note, continue |
| **Malformed** | heading present, but a mandatory clause or required key is missing | emit the observe-only note **plus** a one-line note naming what is missing, continue |
| **Declared** | heading present and well-formed | read it |

The observe-only note is a fixed sentence, emitted by the library so every
consumer says the same thing:

> no `<block name>` block declared — running in observe-only mode

**Malformed degrades to observe-only, never to a gate.** This is the reachable
case: someone uncomments the template, deletes prose they read as boilerplate,
and now holds a block that is present, active, parseable, and missing its
not-a-debt clause. Treating that as declared would let S3 hold them to a pact
whose governing clause they deleted. Absence is never an error, never a
warning, and never a gate; malformed is a note, and also never a gate.

### 3.7 Shared block reader

`ai-literacy-superpowers/hooks/scripts/lib/harness-blocks.sh` owns block
parsing, so the three near-identical parsers named in §1 never get written.
It exposes:

- `block_state <block-heading>` — `absent` | `malformed` | `declared`,
  testing for an **uncommented** level-2..6 heading, mirroring
  `reservoir-check.sh:30`'s active-heading test so a commented template block
  never reads as declared
- `block_key <block-heading> <key> <default>` — the value, scoped to that
  block's span
- `block_absent_note <block-heading>` — the fixed sentence from §3.6

**The value-extraction rule.** `block_key` splits on the **first** delimiter
and trims whitespace **at the ends only**. It does not reuse `read_key`'s
extraction.

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
that justifies a second parser at all, and §7 scenario 11 tests it with two
active blocks declaring the same key — a single-block fixture cannot
distinguish block-scoped lookup from whole-file lookup.

This library is the *only* thing in S1 that reads a block. It is plumbing, not
a sentinel: it has no opinion, no threshold, and no output of its own beyond
the value it was asked for.

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

**Scope: machine-global, not per-repo.** Thrash-switching is a property of the
human, not of a repository. Three sessions in three repos is exactly the case
the WIP Warden exists to catch, and a per-repo registry reports `1` for each of
them. The registry is therefore machine-global; the *limit* stays declared
per-repo in `HARNESS.md` (this repo's opinion about your WIP), and the count it
is compared against is global. This is what makes the `repo` field
load-bearing rather than vestigial: it is how a consumer lists the other live
sessions and where they are.

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

**Collision rule.** Because sanitisation maps every hostile id to the single
fallback `unknown`, at most one `unknown.json` can exist. A count that includes
an `unknown` entry is flagged `inferred`, since that one file may stand for
more than one session. A registry with no `unknown` entry is unaffected.

### 4.2 Lifecycle — heartbeat, not delete

- **`SessionStart` hook** writes the entry if absent, and refreshes
  `heartbeat` if present. It does **not** reset `started_at` — `SessionStart`
  fires on startup, resume, clear, and compact, and a reset `started_at` would
  mean a genuinely long-running session never ages out.
- **`Stop` hook** refreshes `heartbeat`. It does **not** delete.
- **Retirement** is by staleness alone: an entry whose `heartbeat` is older
  than `SESSION_STALE_HOURS` (default 12) is retired by the pruner.

**Why heartbeat rather than delete-on-Stop.** The `Stop` hook fires when the
main agent finishes responding — many times per session, not once at session
end. Every one of the nine existing `Stop` scripts declares "runs at session
end" in its header comment and none carries a once-per-session guard; that is
harmless for all nine, because each is an idempotent advisory whose worst
failure is a duplicate nudge. The registry would be the first *destructive*
consumer of that rail, and a destructive operation does not inherit an
idempotent one's tolerance for unverified firing semantics. A delete-on-`Stop`
registry would empty itself after each session's first response, and the WIP
Warden would report `1` while four sessions ran.

The heartbeat design makes correctness independent of how often `Stop` fires.
Firing once per session, once per turn, or fifty times per turn all produce the
same result: a live session stays fresh, a dead one goes stale.

### 4.3 Staleness and the honesty flag

The flag is a property of the count, not of the reader. It is derived from
durable state — the presence of a retirement marker written by the pruner,
and the presence of an `unknown` entry — never from whether *this particular
read* happened to prune something.

| Situation | Flag |
| --- | --- |
| No entry retired within the staleness window; no `unknown` entry | `observed` |
| One or more entries retired within the window | `inferred` |
| An `unknown` entry present (see §4.1 collision rule) | `inferred` |
| No registry directory at all | `observed`, count 0 |

A count that followed a retirement is `inferred` because the pruner cannot
distinguish a crashed session from a long-running healthy one — it only knows
the entry aged out. That uncertainty persists for every subsequent read, so
the flag must persist with it. A flag that survived only the first read after
a prune would disclose the uncertainty to whichever consumer happened to be
first and hide it from all the others.

### 4.4 Two libraries, split on the trust boundary

`sentinel-integrity-check.sh` enforces the read-only boundary by rejecting
`Write`/`Edit` in an agent's `tools:` list, and explicitly permits `Bash`. Its
own header names the limit: an agent reaching a write capability through an
undeclared channel is out of scope. A single shared library exposing mutation
functions to every sentinel would manufacture exactly that case, and CI would
stay green while a `role: sentinel` agent deleted files.

So the implementation splits:

| File | Exposes | Who may source it |
| --- | --- | --- |
| `hooks/scripts/lib/session-registry-read.sh` | `registry_count` (count + flag), `registry_list` | hook scripts **and** sentinels |
| `hooks/scripts/lib/session-registry-write.sh` | `registry_touch`, `registry_prune` | hook scripts **only** |

The read library performs no mutation on any path. This generalises the same
reasoning that keeps the Coda read-only (§8, Note D): the boundary is preserved
by what the agent *can* reach, not by what it is trusted not to call.

`hooks/scripts/lib/` does not exist yet; `scripts/lib/` does, so the pattern is
established in the repo and this follows it.

## 5. Component 3 — Record Directories and Schemas

Two directories, each with a `README.md` carrying the schema below. Both
schemas are declared here, in full, because a substrate that defers its
schemas to its consumers is the half-feature §1 exists to prevent.

Both records are **append-only** (constraint 7): a superseded entry gains
`status: superseded` and a `superseded_by` pointer, and is never edited in
place or deleted.

### 5.1 Parking record — `docs/superpowers/parked/<YYYY-MM-DD>-<slug>.md`

```yaml
---
session: <sanitised session id>
repo: <absolute path to project root>
created: <YYYY-MM-DD>
status: parked | resumed | superseded
superseded_by: <filename> | null
next_action_flag: asked
---
```

Body: a `## Context` section (one paragraph) and a `## Next action` section
(one concrete resume step).

`next_action_flag` is always `asked` — the next action is supplied by the
human at the ritual, never inferred by the agent. Recording the flag keeps
constraint 3 satisfied without implying the Coda observed anything.

Resuming appends `status: resumed`; it never deletes the record. Consumed by
S2.

### 5.2 Consultation record — `docs/superpowers/consultations/<YYYY-MM-DD>-<slug>.md`

```yaml
---
spec: <path to the spec under approval>
date: <YYYY-MM-DD>
status: open | resolved | superseded
superseded_by: <filename> | null
voices:
  - voice: <role or group>
    source_flag: observed | inferred | asked
    question: <the concrete question worth asking them>
    disposition: pending | consulted | deliberately-not-consulted
    outcome: <one line> | null
---
```

`source_flag` records how the voice was identified: `observed` when a declared
stakeholder map named it, `inferred` when it was derived from the change
itself, `asked` when the human named it. Every voice carries a disposition;
`deliberately-not-consulted` requires an `outcome` giving the because.

Consumed by S5.

## 6. Non-Goals

- **No gating.** Nothing in this slice blocks, warns, or requires a
  disposition.
- **No sentinel agents, skills, or commands.** S1 ships no `role: sentinel`
  agent. The shared block reader (§3.7) is a parsing library, not a consumer:
  it answers "what does the block say", never "what should be done about it".
- **No changes to the Reservoir Warden**, its block, its hook, or its skill.
- **No `Sync cadence` consumer.**
- **No fix to the template's inline-comment trap** (§8, Note A). It is
  pre-existing, it affects a different block, and folding it in would widen a
  plumbing slice into a bug fix. Raised as a follow-up.

## 7. Acceptance Scenarios (TDAD)

Scenarios carry stable prefixed ids so later slices can cite them: **B** for
block behaviour, **R** for the registry, **C** for the record schemas.

### 7.1 Blocks — `tdad_tests/layer0_deterministic/test-cadence-blocks.sh`

- **B1 — Template blocks present and commented.** Given
  `templates/HARNESS.md`, then all three block headings exist inside comment
  fences, and no value line in any of the three carries a trailing `#`
  comment.
- **B2 — Not-a-debt clause present.** Given the `Budgets` template block, then
  its prose contains the literal string `Unspent budget is not a debt.`
- **B3 — Live activation.** Given this repo's root `HARNESS.md`, then all
  three blocks are active, and `Budgets` declares `authored_via: placeholder`.
- **B4 — Absent block, each of three.** Given a `HARNESS.md` with no such
  heading, when `block_state` runs, then it reports `absent` and
  `block_absent_note` emits the §3.6 sentence, exit 0.
- **B5 — Commented block does not read as declared.** Given a `HARNESS.md`
  carrying the three blocks still inside their comment fences, when
  `block_state` runs for each, then each reports `absent` — a template a
  project has not opted into is not a declaration.
- **B6 — Malformed block.** Given an active `Budgets` block whose prose is
  missing the not-a-debt clause, when `block_state` runs, then it reports
  `malformed`, the consumer degrades to observe-only, and a note names the
  missing clause. No gate fires.
- **B7 — Colon- and space-bearing values survive.** Given an active `Budgets`
  block, when `block_key` reads each key, then `hard_stop_hour` returns
  `18:30` (not `30`), `focus_blocks` returns the full comma-separated ranges
  (not `00`), and `daily_cost_ceiling` returns `not observable` with its
  interior space intact.
- **B8 — Block-scoped key isolation.** Given a `HARNESS.md` with **two**
  active blocks that both declare a key of the same name with different
  values, when `block_key` runs against each block, then each returns its own
  block's value. A whole-file parser fails this scenario.

### 7.2 Registry — `tdad_tests/layer0_deterministic/test-session-registry.sh`

- **R1 — Write on start.** Given no entry for session X, when the
  `SessionStart` hook runs, then `~/.claude/sessions/X.json` exists with `id`,
  `repo`, `started_at`, and `heartbeat`.
- **R2 — `SessionStart` re-fire preserves `started_at`.** Given an existing
  entry for X, when `SessionStart` fires again, then `heartbeat` advances and
  `started_at` is unchanged.
- **R3 — `Stop` refreshes, never deletes.** Given an entry for X, when the
  `Stop` hook runs three times, then the entry still exists and `heartbeat`
  has advanced. This is the scenario that would have caught the
  delete-on-`Stop` design.
- **R4 — Two overlapping sessions counted.** Given entries for X and Y, both
  fresh, when `registry_count` runs, then it reports `2` flagged `observed`.
- **R5 — Stale entry retired, count flagged inferred.** Given an entry whose
  `heartbeat` is older than `SESSION_STALE_HOURS`, when the pruner runs and
  `registry_count` follows, then the stale entry is gone and the count is
  flagged `inferred`.
- **R6 — Flag survives repeated reads.** Given the state after R5, when
  `registry_count` runs a second and third time, then every read still reports
  `inferred`. The flag is a property of the count, not of the reader.
- **R7 — `registry_count` mutates nothing.** Given any registry state, when
  `registry_count` runs, then the directory's contents are byte-identical
  before and after.
- **R8 — Read library exposes no mutation.** Given
  `lib/session-registry-read.sh`, then it defines no function that writes,
  deletes, or moves a file, and `registry_touch` / `registry_prune` are
  undefined after sourcing it alone.
- **R9 — Hostile session id sanitised.** Given a hook input whose `session_id`
  contains `/` or `..`, when the `SessionStart` hook runs, then the written
  path is `~/.claude/sessions/unknown.json` and no file is created outside
  that directory.
- **R10 — `unknown` entry flags the count inferred.** Given a registry
  containing an `unknown.json` entry, when `registry_count` runs, then the
  count is flagged `inferred`.
- **R11 — No registry directory.** Given `~/.claude/sessions/` does not exist,
  when `registry_count` runs, then it reports `0` flagged `observed`, exit 0.
- **R12 — Registry lives outside every work tree.** Given a written registry
  entry, when `git status --porcelain` runs in this repo, then no session path
  appears.

### 7.3 Record schemas — same block test file

- **C1 — READMEs carry the declared schemas.** Given
  `docs/superpowers/parked/README.md` and
  `docs/superpowers/consultations/README.md`, then each contains every field
  named in §5.1 and §5.2 respectively, and each states the append-only rule.

## 8. Notes and Divergences from the Build Spec

**Note A — template inline-comment trap (pre-existing, out of scope).** The
shipped `## Cognitive reservoir` template block carries inline `#` comments on
its value lines (`templates/HARNESS.md:614–621`). A downstream project that
uncomments the block and tunes a value gets a silent degrade to the built-in
default, because `read_key` does not strip trailing comments. The live
`HARNESS.md` block documents the rule correctly; the template does not follow
it. Raised as a follow-up issue, not fixed here.

**Note B — registry location.** `~/.claude/sessions/`, machine-global. The
build spec proposed `.superpowers/sessions/`; the first revision of this spec
proposed `.claude/sessions/` (per-repo). The diaboli gate established that
per-repo scope cannot see the concurrency the WIP Warden exists to catch, and
machine-global scope moots the `.gitignore` question entirely. See §4.1.

**Note C — heartbeat, not delete-on-`Stop`.** See §4.2.

**Note D — the sentinel category is already load-bearing.** Build-spec
constraint 9 anticipates a repo that has not yet adopted the sentinel category
and asks for a docs-only introduction. The category shipped in v0.66.0 with a
spec, the `sentinel-design` skill, a README section, `role: sentinel`
frontmatter, and `scripts/sentinel-integrity-check.sh` gating both PRs and the
weekly GC sweep. Consequences for later slices, recorded here because they were
discovered in this slice's exploration:

- Every new sentinel must satisfy S1–S3 and carry `role: sentinel`.
- The Coda cannot hold `Write`. Its agent returns record content; the `/coda`
  command persists it after a human disposes — the `cost-estimator` precedent.
  Disposed by Russ, 2026-08-08.
- The same reasoning generalises to shared libraries, which is why §4.4 splits
  read from write rather than trusting sentinels not to call a mutator.
- S7's "create a sentinel category page" becomes "extend the existing one",
  roster 5 → 9.
- The rename open note in constraint 9 is moot.

**Note E — deriving the count from the invocation log was considered and
rejected.** `observability/affordance-invocations.json` already records
`{"session": ..., "ts": ...}` per tool call, sanitised and size-bounded, and a
live-session count is derivable from it with no new hooks. It was rejected
because the recorder's `PostToolUse` matcher is `Bash|mcp__.*`: a session that
only reads and edits files never appears in the log, so the derived count would
silently undercount exactly the long-running sessions the WIP Warden exists to
notice. The `asked` fallback — a sentinel simply asking how many sessions are
open — remains available to S4 as an honesty option when observation fails.

## 9. Migration & Rollout

Minor version bump, 0.66.2 → 0.67.0 — the slice adds hooks and template
content, which the repo's semver rule scopes as minor.

Version locations (five CI-checked, plus one human-facing):

- `ai-literacy-superpowers/.claude-plugin/plugin.json`
- `README.md` shields.io badge
- `CHANGELOG.md` top heading
- `.claude-plugin/marketplace.json` — `plugin_version`
- `.claude-plugin/marketplace.json` — this plugin's `plugins[].version`
- `README.md` plugin-table row cell (not CI-checked)

Reference pages updated in the same PR, per the `Docs Site Review` convention:

- `docs/plugins/ai-literacy-superpowers/reference/harness-md-format.md` — the
  three new blocks, including the value grammar from §3.2–§3.4, which is the
  part adopters most need
- `docs/plugins/ai-literacy-superpowers/reference/hooks.md` — the
  `SessionStart` and `Stop` registry entries

No breaking changes. All three blocks are additive and optional; the registry
is machine-local state outside every work tree that no existing hook reads; the
record directories are new and empty but for their READMEs.
`/harness-upgrade` surfaces the three new template blocks to downstream
projects as optional adoptable content.
