# Spec: Cadence Sentinels S1 — Shared Infrastructure

**Status:** Approved
**Date:** 2026-08-08
**Issue:** #491
**Epic:** The Cadence Sentinels (S1–S7, issues #491–#497)
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

Every constitutional constraint from the build spec binds this slice. Three
bind it concretely:

- **Honesty flags (constraint 3).** Every count this infrastructure yields
  carries `observed` / `inferred` / `asked`. A session count derived from a
  registry with no pruned entries is `observed`; the same count after stale
  entries were pruned is `inferred`, and the consumer must be able to tell
  which.
- **Persist nothing about the person (constraint 4).** The registry records
  that a session exists, when it started, and against which repo. It records
  nothing about who is in it or how they are doing.
- **Progressive hardening (constraint 6).** Nothing here enforces anything.
  All three blocks are optional; every consumer degrades to observe-only.

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
- max_switches_per_hour: <int>       (optional)
- enforcement: advisory | strict
```

Consumed by the WIP Warden (S4). `enforcement` defaults to `advisory` when the
block is present but the key is absent.

### 3.3 `## Budgets`

```text
- daily_cost_ceiling: <amount, or "not observable">
- sessions_per_day: <int>
- hard_stop_hour: <HH:MM local>
- focus_blocks: <HH:MM-HH:MM, HH:MM-HH:MM>
- notification_policy_after_stop: digest | none
- authored_at: <YYYY-MM-DD>
- authored_via: tune | placeholder
```

The block template carries a **mandatory literal clause** in its prose body:

> Unspent budget is not a debt.

The clause is part of the block, not a comment on it. A `Budgets` block whose
prose has lost the clause is a malformed block, and S3's critic check will say
so.

`authored_at` and `authored_via` exist for S3's clear-weather rule: budgets
that hold are budgets their keeper authored deliberately, so the block records
*how* it came to hold its values. `authored_via: placeholder` is the honest
value for a block that was scaffolded rather than authored.

Consumed by the Mast (S3), which owns the only sanctioned editing path.

### 3.4 `## Sync cadence`

```text
- interrupt_mode: streaming | coalesced
- sync_points: <HH:MM, HH:MM | on-demand>
```

Declared here; no S1–S7 sentinel consumes it yet. It ships now because the
three blocks form one vocabulary and splitting their introduction across slices
would leave the template internally inconsistent. Its consumer is future work,
on the record.

### 3.5 Activation in this repo

All three blocks are additionally **activated** (uncommented, with values) in
this repo's own root `HARNESS.md`, exactly as `## Cognitive reservoir` is. The
repo dogfoods its own harness; a sentinel written in S2–S5 against a block that
exists nowhere real is a sentinel tested only against its own fixtures.

`Budgets` is activated with provisional values and `authored_via: placeholder`.
It is **not** authored in this slice — authoring it here would produce exactly
the imposed-default budget the clear-weather rule says does not hold. S3's Tune
dialogue is where the real pact gets made, and it will overwrite these values
and set `authored_via: tune`.

### 3.6 Absent-block behaviour

Every block is optional. A consumer that finds its block absent reports:

> no `<block name>` block declared — running in observe-only mode

and continues. Absence is never an error, never a warning, and never a gate.

### 3.7 Shared block reader

`ai-literacy-superpowers/hooks/scripts/lib/harness-blocks.sh` owns block
parsing, so the three near-identical parsers named in §1 never get written.
It exposes:

- `block_active <block-heading>` — true when an **uncommented** level-2..6
  heading of that name exists, mirroring `reservoir-check.sh:30`'s
  active-heading test so a commented template block never reads as declared
- `block_key <block-heading> <key> <default>` — the value, scoped to that
  block's span rather than the whole file (the reservoir `read_key` searches
  the entire document, which is safe for its unique keys but not for a
  vocabulary of three blocks that may share key names in future)
- `block_absent_note <block-heading>` — the observe-only line from §3.6, so
  every consumer emits the same sentence

This library is the *only* thing in S1 that reads a block. It is plumbing, not
a sentinel: it has no opinion, no threshold, and no output of its own beyond
the value it was asked for.

## 4. Component 2 — Session Registry

### 4.1 Location and format

`.claude/sessions/<session-id>.json`, one file per live session:

```json
{
  "id": "<session id>",
  "repo": "<absolute path to project root>",
  "started_at": "<ISO-8601 UTC>"
}
```

**Location disposition (open decision 1, disposed 2026-08-08):** the build spec
proposed `.superpowers/sessions/`. This repo has no `.superpowers/` directory
and no precedent for one. Per-machine local session state already lives in
`.claude/` — `.claude/.harness-upgrade-dismissed` and
`.claude/affordance-discovery-*.md` are both there and both gitignored.
`.claude/sessions/` matches that practice. Append-only *logs* live in
`observability/`; the registry is ephemeral live state, not a log, so that
directory is the weaker fit.

The registry is gitignored. It is operational state, not a record. Nothing in
it is ever committed, and nothing downstream may treat it as history.

### 4.2 Lifecycle

- **`SessionStart` hook** writes the entry.
- **`Stop` hook** removes this session's entry and prunes stale ones.

`Stop` is used rather than `SessionEnd` because `hooks.json` already runs nine
`Stop` hooks and none on `SessionEnd`; adding to the existing rail keeps the
hook surface honest and gives the pruner the same firing guarantees the
reservoir check already relies on.

### 4.3 Staleness and the honesty flag

A crashed session leaves an orphan entry. The pruner removes entries whose
`started_at` is older than `SESSION_STALE_HOURS` (default 12).

The flag rule is the point of this component:

| Situation | Flag |
| --- | --- |
| Count read, no entries pruned this read | `observed` |
| Count read, one or more stale entries pruned | `inferred` |
| No registry directory at all | `observed` (count 0) |

A consumer that reports a count must report its flag alongside. A count that
followed a prune is `inferred` because the pruner cannot distinguish a crashed
session from a long-running healthy one — it only knows the entry aged out.

### 4.4 Shared library

`ai-literacy-superpowers/hooks/scripts/lib/session-registry.sh` owns the
implementation: `registry_write`, `registry_remove`, `registry_prune`,
`registry_count` (emitting count and flag). The `SessionStart` and `Stop`
scripts and every consuming sentinel source this one file. Three sentinels
reading three parsers is the failure this component exists to prevent.

`hooks/scripts/lib/` does not exist yet; `scripts/lib/` does, so the pattern is
established in the repo and this follows it.

## 5. Component 3 — Record Directories

Two directories, each with a `README.md` that carries its schema:

- `docs/superpowers/parked/` — parking records (schema consumed by S2)
- `docs/superpowers/consultations/` — consultation dispositions (schema
  consumed by S5)

Both READMEs state the append-only rule (constraint 7): superseded entries are
marked superseded, never edited; a resumed parking record gains
`status: resumed`, and is never deleted.

Declaring the schemas here rather than in S2 and S5 is deliberate. It makes S1
a complete, reviewable unit — the substrate is fully specified before anything
consumes it — rather than half a feature waiting for its other half.

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

1. **Template blocks present and commented.** Given `templates/HARNESS.md`,
   then all three block headings exist inside comment fences, and no value line
   in any of the three carries a trailing `#` comment.
2. **Not-a-debt clause present.** Given the `Budgets` template block, then its
   prose contains the literal string `Unspent budget is not a debt.`
3. **Live activation.** Given this repo's root `HARNESS.md`, then all three
   blocks are active (uncommented), and `Budgets` declares
   `authored_via: placeholder`.
4. **Registry write on start.** Given no registry entry for session X, when the
   `SessionStart` hook runs, then `.claude/sessions/X.json` exists with `id`,
   `repo`, and `started_at`.
5. **Two overlapping sessions counted.** Given entries for sessions X and Y,
   when `registry_count` runs, then it reports `2` flagged `observed`.
6. **Prune on stop.** Given entries for X and Y, when the `Stop` hook runs in
   session X, then X's entry is gone and Y's remains.
7. **Stale entry pruned, count flagged inferred.** Given an entry older than
   `SESSION_STALE_HOURS`, when `registry_count` runs, then the stale entry is
   removed and the count is flagged `inferred`.
8. **No registry directory.** Given `.claude/sessions/` does not exist, when
   `registry_count` runs, then it reports `0` flagged `observed` and exits
   cleanly.
9. **Absent block, each of three.** Given a `HARNESS.md` with no
    `Session WIP` / `Budgets` / `Sync cadence` heading, when
    `block_absent_note` runs for it, then it emits the §3.6 observe-only line
    and exits 0.
10. **Commented block does not read as declared.** Given a `HARNESS.md`
    carrying the three blocks still inside their comment fences, when
    `block_active` runs for each, then each reports inactive — a template a
    project has not opted into is not a declaration.
11. **Block-scoped key read.** Given an active `Budgets` block, when
    `block_key Budgets hard_stop_hour` runs, then it returns the declared
    value, and a key absent from the block returns the supplied default.
12. **Registry is gitignored.** Given a written registry entry, when
    `git status --porcelain` runs, then no `.claude/sessions/` path appears.

Scenarios 1–12 are deterministic and land in
`tdad_tests/layer0_deterministic/test-session-registry.sh` (4–8, 12) and
`test-cadence-blocks.sh` (1–3, 9–11).

## 8. Notes and Divergences from the Build Spec

**Note A — template inline-comment trap (pre-existing, out of scope).** The
shipped `## Cognitive reservoir` template block carries inline `#` comments on
its value lines (`templates/HARNESS.md:614–621`). A downstream project that
uncomments the block and tunes a value gets a silent degrade to the built-in
default, because `read_key` does not strip trailing comments. The live
`HARNESS.md` block documents the rule correctly; the template does not follow
it. Raised as a follow-up issue, not fixed here.

**Note B — registry path.** `.claude/sessions/`, not `.superpowers/sessions/`.
See §4.1.

**Note C — `Stop`, not `SessionEnd`.** See §4.2.

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
- S7's "create a sentinel category page" becomes "extend the existing one",
  roster 5 → 9.
- The rename open note in constraint 9 is moot.

## 9. Migration & Rollout

Minor version bump, 0.66.2 → 0.67.0 — the slice adds hooks and template
content, which the repo's semver rule scopes as minor. Five CI-checked version
locations plus the README plugin-table cell.

No breaking changes. All three blocks are additive and optional; the registry
is local, gitignored state that no existing hook reads; the record directories
are new and empty but for their READMEs. `/harness-upgrade` surfaces the three
new template blocks to downstream projects as optional adoptable content.
