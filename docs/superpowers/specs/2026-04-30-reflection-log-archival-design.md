# Spec: Reflection log archival

**Date**: 2026-04-30
**Author**: Russ Miles + assistant (via brainstorming skill)
**Driving signal**: User concern that `REFLECTION_LOG.md` will grow over time, costing tokens at every read by the seven plugin agents and several commands that consume it; and that signal-to-noise will degrade as old/promoted entries accumulate alongside fresh ones. Cost compounds across the plugin's adopter base.
**Status**: design — awaiting spec-mode `/diaboli` and user review

## Problem

`REFLECTION_LOG.md` is the append-only output of the plugin's
compound-learning loop. The integration-agent appends a structured
reflection after each task; the human curator periodically reviews
entries and promotes worthy ones to `AGENTS.md` (or to a HARNESS.md
constraint). Promoted content then reaches every agent at session
start via `AGENTS.md`.

The log itself is **not** loaded at session start (no `SessionStart`
hook reads it; no priming convention requires it), but it **is** read
on-demand by:

- 7 agents (orchestrator, harness-enforcer, harness-gc,
  harness-auditor, assessor, choice-cartographer, integration-agent)
- 2 Stop hooks (`reflection-prompt`, `curation-nudge`)
- Several commands (`/reflect`, `/assess`, `/harness-health`,
  `/harness-audit`, `/superpowers-status`, `/governance-audit`)

At the time of writing the log is **457 lines / ~29 entries**.
Annualised growth at current cadence is roughly 100–200 entries / year.
Three failure modes follow, ranked by user emphasis:

1. **Signal-to-noise degradation (primary).** When an agent or
   command reads the log to look for recent learnings or recurring
   patterns, stale entries — particularly entries whose learning has
   already been promoted to `AGENTS.md` and is reaching agents that
   way already — drown out fresh signal. The reader's attention is
   the bottleneck, not the tokens themselves.

2. **Per-read cost grows linearly per project (secondary).** Inside
   any single project, every on-demand read pays a cost proportional
   to log size. As the log grows, every reader call (governance
   audits, harness audits, assessor evidence-extraction, regression
   detection) gets more expensive. The cost is per-project and
   reader-activity-driven, not adopter-count-amplified — but it is
   still a cost that compounds with use, and it is paid by every
   adopter who exercises the relevant readers.

3. **Per-project growth is unbounded over years (tertiary).** Inside
   any one long-lived project, the log grows linearly forever absent
   intervention.

## Goals

1. **Reduce signal-to-noise** in the active reflection log.
2. **Bound per-read token cost** across the adopter base.
3. **Bound per-project growth** over years.

## Non-goals

- Don't lose history. **Archive ≠ delete.** Every reflection ever
  appended remains queryable.
- Don't break existing readers. They should still find historical
  context when they need it (via the archive).
- Don't burden the curator beyond what fits in the existing monthly
  review cadence.
- Don't change `AGENTS.md` semantics. That file remains pure human
  curation; this spec touches only `REFLECTION_LOG.md` and
  introduces `reflections/archive/`.
- Don't change the append path. `/reflect` continues to write to the
  active log via PR per the existing `Reflections via PR workflow`
  constraint.

## Approach overview

A **three-mechanism design** that matches the safety profile of each
signal:

- **Read-side filtering (immediate cost cap).** Agents and commands
  that read `REFLECTION_LOG.md` bound their default intake to recent
  entries (last 50 entries OR last 90 days, whichever is more
  inclusive), with explicit opt-in for full-history reads when
  historical patterns are needed (e.g., `Reflection-driven regression
  detection` GC rule, governance pattern analysis). This addresses
  the per-read cost trajectory immediately, with no schema change,
  no migration, and reversible at any time. It is **complementary to
  archival, not a replacement** — archival serves durable
  signal-to-noise reduction; read-side filtering serves immediate
  cost containment.

- **Path 1 — explicit promotion signal → auto-archive.** When a
  curator promotes a reflection to `AGENTS.md` or `HARNESS.md`, they
  add a one-line `Promoted` field to the source entry. A weekly,
  deterministic GC rule moves any entry with that field into the
  appropriate annual archive file. Before archiving, a
  pre-verification step checks that the Promoted line's right-hand
  side resolves to actual content in `AGENTS.md` / `HARNESS.md` (or
  matches a closure variant), so accidentally-applied Promoted lines
  are caught before silent archival. Auto-fix is safe because the
  signal is explicit AND verified.

- **Path 2 — absence of promotion signal → agent-augmented review.**
  Entries older than the configured age threshold (default 6 months,
  HARNESS.md-tunable) without a `Promoted` field are surfaced
  monthly by the `harness-gc` agent. The agent emits **evidence**
  (recurrence counts, AGENTS.md/HARNESS.md text-overlap matches,
  single-instance signal) per candidate — **not** pre-classified
  labels. The curator interprets the evidence and decides on a
  disposition. Auto-fix is not safe here because the absence of a
  promotion line is ambiguous; human judgement gates the move.
  Path 2 is **opt-in via the HARNESS.md GC-rule declaration** —
  if an adopter does not declare it, no monthly report is generated
  and the system reverts to today's behaviour for them.

The three mechanisms are deliberately ordered: read-side filtering
takes the immediate cost off the table; Path 1 absorbs the explicit
curation signal cleanly; Path 2 augments human judgement on the
ambiguous middle ground. Adopters who engage with curation get the
full benefit of all three; adopters who don't engage still benefit
from read-side filtering (with no change to the active log).

## Schema change

Each reflection entry gains an **optional** `Promoted` field, added by
the curator at promotion time:

```markdown
- **Promoted**: 2026-05-15 → AGENTS.md STYLE: "Multi-repo scheduled agents"
```

Other valid right-hand sides:

- `→ HARNESS.md: <constraint name>` (when the learning became a
  constraint)
- `→ no promotion (single-instance learning)` (when the curator
  judges the entry not promotable but acknowledges its lifecycle is
  closed)
- `→ aged-out, no promotion warranted` (when Path 2 surfaces an
  aged-out entry the curator chooses to close)
- `→ superseded by <reflection-date>` (when a newer reflection
  carries the learning forward)

The `Promoted` line is **append-only** — once added, it is not
modified except to extend it (e.g., adding a second destination).
The curator adds it in the same commit as the AGENTS.md / HARNESS.md
edit, so the two changes are atomic.

The schema change is **backwards-compatible**: existing 29 entries
without a `Promoted` field continue to be valid; they're simply
ineligible for Path 1 auto-archive until tagged.

### Formal grammar for the Promoted field

```text
PROMOTED_LINE := "- **Promoted**: " DATE " " "→" " " RHS
DATE          := YYYY "-" MM "-" DD
RHS           := AGENTS_FORM | CLAUDE_FORM | HARNESS_FORM
               | CLOSURE_FORM | SUPERSEDE_FORM
AGENTS_FORM   := "AGENTS.md " SECTION ": " QUOTED_STRING
CLAUDE_FORM   := [ PATH "/" ] "CLAUDE.md " QUOTED_STRING
HARNESS_FORM  := [ ".claude/" ] "HARNESS.md: " CONSTRAINT_NAME
CLOSURE_FORM  := "no promotion (" RATIONALE ")"
                | "aged-out, no promotion warranted"
SUPERSEDE_FORM := "superseded by " DATE
SECTION       := "STYLE" | "GOTCHA" | "ARCH_DECISION"
PATH          := relative directory of a per-component CLAUDE.md
```

`CLAUDE_FORM` covers promotions to the root `CLAUDE.md` or a
per-component sub-`CLAUDE.md` (verified by grepping the quoted excerpt
in that file). `HARNESS_FORM` resolves the constraint heading against
whichever `HARNESS.md` the project uses — the repo root or the
`.claude/HARNESS.md` location `/superpowers-init` scaffolds to — and
the `.claude/` prefix may be stated explicitly. (Added per issues
#319 and #320.)

Implementation contract: **all parseable Promoted lines trigger
archival regardless of right-hand side**. The right-hand side is
preserved verbatim in the archive entry as part of the entry's
permanent record. The grammar exists so a deterministic parser can
distinguish well-formed from malformed lines (and reject the latter
per Path 1's failure-mode handling), not so different right-hand
sides take different paths.

### Why this shape, not frontmatter or sidecar

A markdown bullet line was chosen over alternatives:

- **Per-entry YAML frontmatter** would force a structural break with
  the existing 29 entries (each would need a frontmatter block
  added) and would couple the schema more tightly to a parser. The
  current shape adds a single line per promotion and remains
  grep-friendly.
- **Sidecar `reflections/promotions.yaml`** would couple two files
  for every promotion (consistency burden, drift risk). The current
  shape co-locates the disposition with the entry it disposes.
- **Git-trailer-style annotation in commit messages** would only
  surface the disposition at git-log time, not at file-read time —
  agents would need to mine git history rather than read a file.

The trade-off accepted: free-text right-hand sides allow more
variation than a structured form would, mitigated by the formal
grammar above.

## Archive location and format

Annual files at:

```text
reflections/
└── archive/
    ├── 2026.md
    ├── 2027.md
    └── ...
```

**Annual granularity** chosen over quarterly because:

- File count stays manageable for decades (10–20 files in 10 years).
- Date-windowed queries are still trivial (`grep "Multi-repo"
  reflections/archive/*.md`).
- Quarterly would multiply file count by 4 with no commensurate
  benefit at current entry volume.

**Each archived entry preserves:**

- The full original text of the reflection (Date, Agent, Task,
  Surprise, Proposal, Improvement, Signal, Constraint, Session
  metadata).
- The `Promoted` field that triggered the archive.
- An additional `Archived` field added at archive time:
  `- **Archived**: 2026-05-22 (auto, Path 1)` or
  `(curator-confirmed, Path 2)`.

The archive file is itself a markdown document with the same
`---`-separated entry format as the active log, so any reader that
can parse the active log can parse the archive.

**Append order in the archive**: entries are appended in the order
they're archived, NOT re-sorted by original date. Chronological
order by archive timestamp is sufficient for query and avoids
re-write conflicts.

## Read-side filtering — the immediate cost cap

Independent of archival, every reader of `REFLECTION_LOG.md` should
bound its default intake. This is the cheapest, most immediate
mitigation against the per-read cost trajectory and addresses the
concern that any one project read (governance audit, harness audit,
reflection-driven regression detection, assessor evidence-extraction)
shouldn't have to load the entire log just to do recent-pattern
analysis.

### Default bounded read

Readers default to **the more inclusive of**:

- The last **50 entries**
- Entries dated within the last **90 days**

A reader that wants more (or all) entries declares so explicitly.
Wanting all entries is a deliberate signal that historical patterns
matter — the reader pays the larger cost knowingly.

### Per-reader policy

| Reader | Default | Rationale |
|---|---|---|
| `/reflect` (append) | n/a | Append-only; doesn't read entries to write. |
| `curation-nudge.sh` Stop hook | bounded | Counts unpromoted recent entries; doesn't need history. |
| `reflection-prompt.sh` Stop hook | n/a | Operates on the current commit, not the log. |
| `harness-gc` Path 1 (auto-archive) | full active | Must scan every entry for `Promoted` field. |
| `harness-gc` Path 2 (aged-out review) | full active + archive | Cross-reference and pattern detection across history. |
| `harness-gc` Reflection-driven regression detection | full active + archive | Looks for recurring patterns over time. |
| `harness-auditor` agent | bounded by default; full-with-archive on explicit "audit historical claims" | Most auditing is on recent state; historical claims are explicitly scoped. |
| `governance-auditor` agent | full active + archive when looking for governance patterns over time | Pattern analysis is the explicit goal. |
| `assessor` agent | full active + archive when extracting compound-learning evidence | Coverage matters more than recency. |
| `choice-cartographer` agent | bounded by default; full-with-archive when assessing decision continuity across long arcs | Most cartograph work is recent-spec-scoped. |
| `orchestrator` agent | n/a | Doesn't read the log directly. |
| `integration-agent` | n/a | Append-only; doesn't read for content. |
| `/superpowers-status`, `/harness-health` | bounded | Health snapshots are recent-state-focused. |
| `/harness-audit` | bounded by default; full when asked to audit historical claims | Most audits are recent-state. |
| `/assess`, `/governance-audit` | full active + archive | Cross-time pattern analysis. |

The bounded default + explicit-opt-in pattern means the common case
is cheap and the historical case is still possible — the trade-off
is conscious rather than implicit.

### Implementation

Each reader that uses bounded reads gets a small helper utility
(shell or agent prompt language) that reads the active log,
splits on `---`, sorts entries by `Date` field descending, and
returns the first N entries OR entries within M days, whichever is
more inclusive. Defaults are configurable via HARNESS.md (see
Configuration).

Readers that need full active + archive use `cat REFLECTION_LOG.md
reflections/archive/*.md`-style aggregation, then split and process
as one stream. Annual archive granularity keeps the file count low
enough that this is cheap.

---

## Path 1 — Auto-archive of promoted entries

### Specification

| Field | Value |
|---|---|
| GC rule name | `Reflection log archival of promoted entries` |
| Frequency | weekly |
| Enforcement | deterministic |
| Tool | shell script (or `harness-gc` agent in script-mode) |
| Auto-fix | true |
| Scope | `REFLECTION_LOG.md` |

### Algorithm

1. Read `REFLECTION_LOG.md`.
2. Split into entries on `---` separators.
3. For each entry that contains a `Promoted` field:
   a. **Parse the Promoted line** against the formal grammar
      (Schema change → Formal grammar). If the line does not match,
      skip the entry and emit a warning. Do not block the run.
   b. **Pre-archive verification** — verify that the right-hand side
      resolves to actual content in the current tree:
      - `AGENTS_FORM`: grep for the quoted-string content in
        `AGENTS.md`. Skip with warning if no match.
      - `HARNESS_FORM`: grep for the constraint name as a `### `
        heading in `HARNESS.md`. Skip with warning if no match.
      - `CLOSURE_FORM` and `SUPERSEDE_FORM`: accept (no external
        content to verify, but the form is grammar-valid).
   c. Determine the entry's original year from the `Date` field.
   d. Append the entry (with an added `Archived` line) to
      `reflections/archive/<YYYY>.md`, creating the file if missing.
   e. Remove the entry from `REFLECTION_LOG.md`.
4. Write back the trimmed `REFLECTION_LOG.md`.
5. Commit both files in a single commit titled
   `chore: auto-archive N promoted reflections`.

The script runs via the existing weekly GC workflow
(`gc.yml`) on the schedule already established for deterministic GC
rules. It operates only on entries with the explicit `Promoted`
signal AND passing pre-archive verification — never on entries
lacking either.

### Failure modes

- **Concurrent edit during the GC run**: handled via PR-based
  workflow on a branch, with rebase-and-retry on conflict. The
  script must use the `Reflections via PR workflow` constraint's
  branch-and-PR pattern.
- **Malformed `Promoted` line**: skip the entry, log a warning, do
  not block the run.
- **Promoted line is grammar-valid but unverified** (right-hand side
  doesn't resolve to content in `AGENTS.md` / `HARNESS.md`): skip
  with warning. The most likely cause is a curator typo or a
  Promoted line added before the AGENTS.md edit was committed; both
  resolve naturally on the next weekly run once the curator
  reconciles.
- **Archive file write failure**: abort the run before modifying
  the active log. Atomicity matters.

## Path 2 — Agent-augmented aged-out review

### Specification

| Field | Value |
|---|---|
| GC rule name | `Reflection log aged-out review` |
| Frequency | monthly |
| Enforcement | agent |
| Tool | `harness-gc` agent |
| Auto-fix | false |
| Scope | `REFLECTION_LOG.md` |
| Default age threshold | 6 months (configurable per project) |
| Opt-in | yes — adopters declare this GC rule in HARNESS.md to enable it |

### Algorithm

1. Read `REFLECTION_LOG.md`.
2. Filter to entries older than the **configured age threshold**
   (default 6 months, read from the GC-rule declaration in
   `HARNESS.md` — see Configuration below) that lack a `Promoted`
   field.
3. For each candidate, the `harness-gc` agent emits **evidence**,
   not a pre-classified label:
   a. Reads the entry's `Surprise`, `Proposal`, and `Improvement`
      fields.
   b. Cross-references against newer reflection entries:
      - Counts pattern recurrences (same Signal classification AND
        keyword overlap with the entry's Surprise/Proposal).
      - Cites specific newer entry dates as evidence.
   c. Cross-references against current `AGENTS.md` and `HARNESS.md`:
      - Reports text-overlap matches with specific quoted excerpts.
      - Reports any explicit constraint or section that appears to
        capture the entry's learning.
   d. Reports the single-instance signal: "no newer entry shares
      this pattern" if applicable.
4. The agent **does not assign a label**. The curator interprets
   the evidence (recurrence count, overlap matches, single-instance
   signal) and chooses a disposition.
5. Outputs a structured report at
   `observability/reflection-aged-out-<YYYY-MM-DD>.md` containing all
   candidates and their evidence blocks, with the curator's
   interpretation explicitly required per entry.
6. Surfaces the report to the curator via the monthly cadence (same
   surfacing mechanism as other monthly GC outputs).

### Curator workflow (per entry)

For each entry in the report, the curator reads the evidence and
chooses one of:

1. **Promote** — manually edit `AGENTS.md` or `HARNESS.md` (per the
   plugin's existing curation discipline), then add a `Promoted`
   line to the source entry. Path 1 archives the entry on its next
   weekly run.
2. **Mark closed** — add a `Promoted: → aged-out, no promotion
   warranted` line. Path 1 archives the entry on its next weekly
   run.
3. **Mark superseded** — add a `Promoted: → superseded by <newer
   reflection date>` line. Path 1 archives.
4. **Keep** — leave the entry untouched. The next monthly Path 2
   run will surface it again, with potentially different evidence
   as the surrounding context evolves.

### Why evidence, not pre-classified labels

The original design emitted PROMOTE / SUPERSEDE / AGED-OUT labels.
Spec-mode `/diaboli` (O5) flagged this as a training-into-acceptance
risk: a monthly recurring report of pre-classified recommendations
becomes a path of least resistance to reflexive acceptance, even
when the curator is supposed to be the gate. By having the agent
emit evidence rather than labels, the curator must **read and
interpret** before acting — the friction step is structural, not
discretionary.

### Why agent enforcement, not deterministic

Path 2 needs cross-reference work that resists a clean shell-script
expression (text overlap, recurrence pattern detection). The
`harness-gc` agent already does similar pattern-detection work (see
the existing `Reflection-driven regression detection` GC rule,
which is also agent-enforced). Adding this capability there is the
natural fit.

### Failure modes

- **Cross-reference evidence is brittle** (e.g., text overlap flags
  superficially-similar entries that aren't actually the same
  learning): curator catches at review time. Evidence is presented
  with the underlying matches quoted, so the curator can sanity-check
  rather than trusting a label.
- **Curator does not act on the report**: entries remain in the
  active log. Path 2 is opt-in, so an adopter who finds the report
  unhelpful can simply remove the GC-rule declaration from their
  HARNESS.md.
- **Agent emits no evidence for an entry** (no recurrence, no
  overlap): this is a valid signal — the entry is single-instance
  and has not been captured elsewhere. Curator decides whether
  single-instance is enough to keep, close, or promote.

## Configuration

The design exposes three tunable values, all configurable via the
HARNESS.md GC-rule declarations. Defaults are stated; adopters can
override per project.

| Value | Default | Where declared | Effect |
|---|---|---|---|
| Path 2 age threshold | 6 months | `Reflection log aged-out review` GC rule's `threshold` field in HARNESS.md | Entries older than this without a `Promoted` field surface in the monthly Path 2 report |
| Read-side filtering: entry count | 50 | `Read-side filtering` policy in HARNESS.md (or CLAUDE.md if more appropriate) | Default upper bound on number of recent entries readers ingest |
| Read-side filtering: day window | 90 days | Same as above | Default upper bound on age of entries readers ingest |
| Path 2 opt-in | declared | Whether the GC rule is present in HARNESS.md `## Garbage Collection` | If absent, no monthly report is generated; only Path 1 (and read-side filtering) operate |

**Configurability rationale**: the spec deliberately picks defaults
that serve the median project, but adopters' curation cadences vary
(some review weekly, some quarterly). Hardcoding the threshold or
the read window would make the design less reusable. Adopters tune
the values in HARNESS.md and the GC rule + readers honour the
declared values.

**Default selection rationale**: 6 months for Path 2 is the midpoint
of the 3-12 month range that came up in spec-mode `/diaboli` open
questions. 50 entries / 90 days for read-side filtering is generous
enough that for projects with the typical ~15-25 entries/year
cadence, the bounded read covers everything; for higher-cadence
projects, the bound clips to recent state where the active signal
lives.

---

## Reader updates

| Reader | Change required |
|---|---|
| `/reflect` (append) | None. Always appends to active log. |
| `curation-nudge.sh` Stop hook | None. Cleaner signal — archived entries no longer count toward the unpromoted-recent count. |
| `reflection-prompt.sh` Stop hook | None. Operates only on the current commit, not the log. |
| **`harness-gc` agent** | Adds two new GC-rule implementations: `Reflection log archival of promoted entries` (Path 1) and `Reflection log aged-out review` (Path 2). Existing `Reflection-driven regression detection` rule extended to read both `REFLECTION_LOG.md` and `reflections/archive/*.md`. |
| **`harness-auditor` agent** | When auditing reflection-related claims in `HARNESS.md` Status, also consults the archive. |
| **`governance-auditor` agent** | When looking for governance-related patterns over time, reads both active log and archive. |
| **`assessor` agent** | When extracting evidence of compound learning, counts entries across active + archive. |
| **`choice-cartographer` agent** | When assessing decision archaeology continuity, reads both. |
| **`orchestrator` agent** | None directly; downstream agents handle their own reading. |
| **`integration-agent`** | Append path unchanged; documents the `Promoted` field convention in its post-task workflow. |
| **`/superpowers-status`, `/harness-health`, `/harness-audit`** | Report active-log count and archive-entry count separately, plus the count of unpromoted entries older than 6 months as a curation-debt metric. |
| **`/assess`, `/governance-audit`** | Read both active log and archive when extracting historical evidence. |

## Migration

The existing 29 entries in `REFLECTION_LOG.md` do not have `Promoted`
fields. To reduce the migration burden flagged by spec-mode
`/diaboli` (O6) — manually reconstructing each entry's promotion
status by inspection is high cognitive load — the implementation
ships a **migration helper script** that pre-cross-references and
proposes tags for the curator to confirm.

### Migration helper script

`scripts/migrate-reflection-log.sh`

For each entry in `REFLECTION_LOG.md`:

1. Reads the entry's `Surprise`, `Proposal`, `Improvement` fields.
2. Greps `AGENTS.md` for keyword overlap with the entry's
   `Proposal` or `Surprise` text.
3. Greps `HARNESS.md` for any constraint name mentioned in the
   entry's `Constraint` field.
4. Emits a per-entry recommendation in a working file
   (`reflections/migration-proposals.md`):
   - **Likely-promoted to AGENTS.md**: if AGENTS.md grep hits — proposes
     `Promoted: <today's date> → AGENTS.md <section>: "<quoted match>"`
   - **Likely-promoted to HARNESS.md**: if HARNESS.md grep hits — proposes
     `Promoted: <today's date> → HARNESS.md: <constraint>`
   - **Single-instance, aged-out**: if no overlap and entry is older
     than the configured threshold — proposes
     `Promoted: <today's date> → aged-out, no promotion warranted`
   - **Recent, no overlap**: if entry is recent — proposes leaving
     untouched

The script makes **proposals**, not final decisions. The curator
reviews the working file, confirms or edits each proposed tag, then
applies the confirmed tags to `REFLECTION_LOG.md`. After the curator
applies the tags, Path 1 GC archives them on the next weekly run.

Reduces the migration from "scan each of 29 entries and reconstruct
status by inspection" to "review 29 proposals and confirm or edit".
Estimated curator time: 30-60 minutes, vs. multiple hours for
unaided reconstruction.

### Migration steps

1. Curator runs `scripts/migrate-reflection-log.sh` once.
2. Curator reviews `reflections/migration-proposals.md` and applies
   confirmed tags to `REFLECTION_LOG.md` (one PR, the proposals file
   is committed alongside as a record of the migration decisions).
3. Path 1 GC runs on its next weekly schedule and migrates
   everything tagged into `reflections/archive/<YYYY>.md`.
4. The proposals file remains in `reflections/migration-proposals.md`
   as a permanent record of the migration's decisions, then is
   ignored by future runs (the script self-detects and skips if the
   file already exists).

After the migration, Path 1 and Path 2 run continuously without
further manual intervention beyond the monthly aged-out review.

## Steady-state expectation

After one full quarterly cycle following migration:

- **Active log**: 10–20 entries (recent, plus unpromoted-but-warm).
- **`reflections/archive/2026.md`**: every entry triaged and moved.
- **Token cost per active-log read**: roughly 1/3 to 1/4 of today's
  cost (depending on actual triage volume).
- **Curator burden**: one line per promotion (already implicit in
  the existing curation flow), monthly aged-out review (already part
  of the existing monthly cadence).

The active log becomes a **working file** rather than a permanent
record. The permanent record lives in the archive.

## Graceful degradation for the disengaged-curator case

Spec-mode `/diaboli` (O12) flagged that the design implicitly
assumes adopters follow the curation discipline (Promoted lines
added at promotion time; monthly aged-out report acted on). For
adopters who don't engage, the system must degrade to no-worse-than-
status-quo — never to actively-worse.

### How each mechanism degrades

| Mechanism | Engaged-curator state | Disengaged-curator state |
|---|---|---|
| **Read-side filtering** | Active for all bounded readers; readers see recent state by default | Active by default. Readers see recent state. Identical to engaged case. |
| **Path 1 (auto-archive)** | Weekly run archives Promoted entries | No `Promoted` lines exist → script finds nothing to archive → no-op every week. No noise. |
| **Path 2 (aged-out review)** | Monthly report surfaces aged-out candidates | **Opt-in via HARNESS.md GC-rule declaration**. If absent, no monthly report is generated. |
| **Schema change** | Curator adds `Promoted` lines as part of curation | Schema change is backwards-compatible. Existing entries remain valid without `Promoted` fields. |
| **Migration helper** | Curator runs it once, reviews proposals, applies | Never run. No effect. |

### Net effect

For an adopter who never adds a `Promoted` line and never declares
the Path 2 GC rule:

- Read-side filtering still bounds reader cost (immediate benefit).
- No archival happens. The active log keeps growing as before.
- No monthly report is generated.
- The system is **identical to today's behaviour, plus read-side
  filtering** — strictly an improvement, never a regression.

This is the load-bearing property the design needs: archival is
opt-in via curator engagement, and absence of engagement leaves the
adopter no worse off than if archival didn't exist.

---

## What this design does NOT do

- Does not change the append path or the `Reflections via PR
  workflow` constraint.
- Does not introduce a new file format (still markdown, still
  grep-able).
- Does not pre-emptively summarise or compress entries (full
  fidelity preserved in archive).
- Does not touch `AGENTS.md` semantics or content.
- Does not introduce a UI or dashboard for archival; everything is
  file-based and command-driven.
- Does not retroactively re-classify entries that were already
  promoted in the past — those need the one-off curator pass to
  acquire `Promoted` lines.

## Implementation scope

The implementation will touch:

### Agent updates

- `ai-literacy-superpowers/agents/harness-gc.agent.md` — add Path 1
  (deterministic archive) and Path 2 (agent-augmented evidence-emit)
  rule implementations; update existing
  `Reflection-driven regression detection` to read archive too.
- `ai-literacy-superpowers/agents/harness-auditor.agent.md` — adopt
  bounded-read default; declare full-with-archive opt-in for
  historical-claim audits.
- `ai-literacy-superpowers/agents/assessor.agent.md` — read full
  active + archive for compound-learning evidence.
- `ai-literacy-superpowers/agents/choice-cartographer.agent.md` —
  bounded-read default; full-with-archive for long-arc decision
  continuity.
- `ai-literacy-superpowers/agents/integration-agent.agent.md` —
  document `Promoted` convention in post-task workflow.

### Template updates

- `ai-literacy-superpowers/templates/HARNESS.md` — add the two new GC
  rules (Path 1 deterministic auto-archive, Path 2 agent-augmented
  aged-out review) to the template under `## Garbage Collection`,
  with configurable threshold field.
- `ai-literacy-superpowers/templates/CLAUDE.md` — document the
  archival convention, the `Promoted` field schema (with formal
  grammar reference), the read-side filtering policy, and the
  curator workflow.
- `ai-literacy-superpowers/templates/REFLECTION_LOG.md` (if it
  exists) — document the `Promoted` field schema.

### Command updates

- `ai-literacy-superpowers/commands/reflect.md` — mention that
  promotion adds a `Promoted` line.
- `ai-literacy-superpowers/commands/superpowers-status.md` — report
  active-log count, archive-entry count, and unpromoted-aged-out
  count separately.
- `ai-literacy-superpowers/commands/harness-health.md`,
  `harness-audit.md` — report archive counts and aged-out curation
  debt.

### Skill updates

- `ai-literacy-superpowers/skills/garbage-collection/SKILL.md` —
  document the two new GC rules and the safety asymmetry between
  them, plus the read-side filtering policy.

### New scripts and workflows

- `ai-literacy-superpowers/scripts/archive-promoted-reflections.sh`
  — Path 1's deterministic auto-archive script with grammar parsing
  and pre-archive verification.
- `ai-literacy-superpowers/scripts/migrate-reflection-log.sh` — the
  migration helper that pre-cross-references existing reflections
  and proposes tags.
- `ai-literacy-superpowers/.github/workflows/gc.yml` — wire the new
  Path 1 script into the weekly GC workflow.

### Live-repo migration

- This repo's `REFLECTION_LOG.md` — perform the one-off migration
  using `scripts/migrate-reflection-log.sh` and the curator's review.
- This repo's `HARNESS.md` — add the two new GC rules to the live
  harness with default thresholds.
- This repo creates: `reflections/archive/2026.md` (initially empty,
  populated by Path 1 after migration tagging) and
  `reflections/migration-proposals.md` (permanent record of migration
  decisions).
- Plugin version bump: minor (this changes plugin behaviour and adds
  GC rules) — `0.31.1 → 0.32.0`.

## Risks

1. **Migration burden falls on existing curators.** Even with the
   migration helper script reducing the work from "scan and
   reconstruct" to "review proposals", the migration is still a
   one-time curator session. Risk that curators defer it
   indefinitely. Mitigation: the helper script reduces the time
   from hours to ~30-60 minutes; the proposals file is committed
   alongside the migration, so even partial completion preserves
   value.

2. **Archive grows unbounded.** Even if the active log is small,
   the archive grows ~100–200 entries / year, eventually reaching
   thousands. Acceptable per the design (archive is queryable, not
   loaded by default) but worth noting.

3. **Cross-reference evidence in Path 2 is approximate.** Pattern
   recurrence detection by text overlap is brittle; the helper
   script's keyword-overlap heuristic for migration proposals is
   similarly approximate. Mitigation: the design emits **evidence**
   not **labels**, so curator interpretation is the gate. Brittle
   evidence is presented with the underlying matches quoted, so
   the curator can sanity-check rather than trusting a
   classification.

4. **Git history bloat from frequent archival commits.** Path 1
   runs weekly; each run commits if there's anything to archive. At
   steady state this is ~1 commit/week of archival churn.
   Acceptable.

5. **Pre-archive verification false negatives.** Path 1's
   right-hand-side resolution check could fail to find content
   that exists (e.g., the curator paraphrased the AGENTS.md
   addition rather than copying verbatim). Mitigation: skip with
   warning rather than block; entry remains in active log; curator
   reconciles next week. Worse failure mode is "Promoted line
   added but archival never happens", which is recoverable; better
   than the alternative ("Promoted line typo causes wrong entry to
   be archived").

## Open questions resolved by spec-mode `/diaboli`

Spec-mode `/diaboli` raised 12 objections; the dispositions
revised this spec on the following points:

1. **Read-side filtering as a complementary mechanism** (O3
   accepted) — added as a peer to Path 1 and Path 2; addresses
   per-read cost immediately without requiring archival engagement.
2. **6-month threshold made configurable** (O4 accepted) — hoisted
   to a HARNESS.md GC-rule field; default 6 months; documented in
   the new Configuration section.
3. **Path 2 emits evidence, not labels** (O5 accepted) — defuses
   the training-into-acceptance risk by requiring curator
   interpretation rather than offering pre-classified labels.
4. **Migration helper script** (O6 accepted) — pre-cross-references
   existing entries and proposes tags for curator review; reduces
   migration time from hours to 30-60 minutes.
5. **Pre-archive verification step** (O7 accepted) — Path 1
   verifies the Promoted line's right-hand side resolves to actual
   content before archiving, catching curator typos.
6. **Formal grammar for Promoted field** (O9 accepted) — added to
   Schema change section; states explicitly that all parseable
   forms trigger archival.
7. **Cost framing scoped to per-project** (O11 accepted) — dropped
   the "thousands of installs" rhetorical scaling; cost is now
   framed as per-project reader-activity-driven.
8. **Path 2 made opt-in for graceful degradation** (O12 accepted)
   — adopters who don't engage with curation see no monthly report
   and no active-log churn; system reverts to today's behaviour
   plus read-side filtering.

Objections rejected (with rationale captured in the objection
record): O1, O2 (premise — user-driven signal substantiates the
present-tense decision), O8 (scope — 14-file touch is the real
shape of a schema-extending change in this plugin), O10 (alternative
shapes — markdown bullet defended; sidecars / frontmatter / git
trailers each have worse trade-offs).

## Remaining open questions

Not raised by `/diaboli`; left for choice-cartograph or future
iteration:

1. **Should Path 1 run weekly or monthly?** Weekly is more
   responsive; monthly batches more. The design picks weekly.
2. **Should the `Archived` field be added to entries when archived,
   or should the archive file's existence implicitly carry that
   information?** The design picks explicit field for self-documenting
   entries.
3. **Should aged-out entries be auto-archived after a longer
   threshold (e.g., 12 months) even without a `Promoted` field, as
   a final fallback?** The design says no — preserves human
   judgement; the opt-in degradation property removes the risk
   that the active log grows without bound, since adopters who
   don't engage already get read-side filtering as the cost cap.

## Success criteria

This design will be considered successful if, three months after
implementation:

- Active `REFLECTION_LOG.md` has fewer than 25 entries.
- `reflections/archive/2026.md` contains the migrated and
  subsequently archived entries.
- The monthly Path 2 report fits on one screen and surfaces actionable
  recommendations.
- No reader (agent or command) has reported missing context due to
  archival.
- The curator workflow has not added meaningful overhead beyond the
  monthly review that already exists.

If these criteria are met, the next step is to consider whether the
same archival pattern should be applied to other long-lived markdown
artefacts in the plugin (e.g., `CHANGELOG.md`, governance audit
reports). That generalisation is out of scope for this spec.
