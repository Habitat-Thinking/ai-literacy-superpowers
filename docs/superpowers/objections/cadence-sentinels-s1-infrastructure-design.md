---
spec: docs/superpowers/specs/2026-08-08-cadence-sentinels-s1-infrastructure-design.md
date: 2026-08-08
mode: spec
diaboli_model: claude-opus-5[1m]
objections:
  - id: O1
    category: implementation
    severity: critical
    claim: "The registry lifecycle assumes the Stop hook fires once per session, but Stop fires at the end of every assistant turn; a session removes its own entry after its first response and reads as not-live for the rest of its life."
    evidence: "Spec 4.2: 'Stop hook removes this session entry and prunes stale ones... Stop is used rather than SessionEnd because hooks.json already runs nine Stop hooks... gives the pruner the same firing guarantees the reservoir check already relies on.'"
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: implementation
    severity: high
    claim: "The registry is project-local, so it counts sessions per repo, not per human; the concurrency the WIP Warden exists to see is cross-repo, and the entry repo field is vestigial under this location."
    evidence: "Spec 4.1: '.claude/sessions/<session-id>.json' with '\"repo\": \"<absolute path to project root>\"', justified by gitignored per-project precedents, and scenario 12 asserting 'git status --porcelain' sees nothing."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: alternatives
    severity: high
    claim: "A per-session, timestamped, sanitised session log already exists in this repo (observability/affordance-invocations.json); the spec never weighs deriving the live-session count from it against building a new hook-driven mutable registry."
    evidence: "affordance-invocation-recorder.sh:68 emits '{\"tool\":...,\"session\":\"%s\",\"ts\":\"%s\"}'; spec 4 introduces a new registry, two new hook scripts, a staleness constant, and a pruner without mentioning this existing data source."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: risk
    severity: high
    claim: "registry_count mutates shared state as a side effect of a read, which makes the observed/inferred flag a property of who read first rather than of the count, and leaves concurrent pruning unspecified."
    evidence: "Spec 4.3 table plus scenario 7: 'when registry_count runs, then the stale entry is removed and the count is flagged inferred.'"
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: implementation
    severity: high
    claim: "block_key is specified as read_key plus block scoping, but read_key greedy-matches the last colon and strips all whitespace, so every HH:MM and multi-token value the new vocabulary mandates parses to garbage."
    evidence: "reservoir-check.sh:37-41 uses 's/.*[:=][[:space:]]*//' then 'tr -d [:space:]'; spec 3.3 mandates 'hard_stop_hour: <HH:MM local>' and 'focus_blocks: <HH:MM-HH:MM, HH:MM-HH:MM>'; spec 3.7 describes block_key as differing from read_key only in scope."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: specification quality
    severity: high
    claim: "Component 3 claims its schemas are declared in this slice to make S1 a complete reviewable unit, but no schema is given and no acceptance scenario covers it."
    evidence: "Spec 5: 'Declaring the schemas here rather than in S2 and S5 is deliberate... the substrate is fully specified before anything consumes it'; the only field named anywhere is 'status: resumed', and scenarios 1-12 cover only blocks and the registry."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: premise
    severity: high
    claim: "Constraint 4 (persist nothing about the person) is scoped only to the registry, while 3.5 commits the person's working day into permanent git history via the activated Budgets block."
    evidence: "Spec 2: 'The registry records that a session exists... It records nothing about who is in it'; spec 3.5: 'All three blocks are additionally activated (uncommented, with values) in this repo own root HARNESS.md', where Budgets carries hard_stop_hour, focus_blocks, and sessions_per_day."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: risk
    severity: high
    claim: "Every consuming sentinel is told to source a library whose read path deletes files, which breaches the read-only trust boundary through the exact Bash channel the CI check names as its known limit."
    evidence: "Spec 4.4: 'The SessionStart and Stop scripts and every consuming sentinel source this one file' exposing registry_write, registry_remove, registry_prune; sentinel-integrity-check.sh:21-22 'Bash is permitted' and :30-33 'an agent that reaches a write capability through an undeclared channel is out of scope here.'"
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: risk
    severity: medium
    claim: "The session id becomes a filesystem path component with no stated source and no sanitisation rule, in a repo that has already adjudicated hostile session ids once."
    evidence: "Spec 4.1: '.claude/sessions/<session-id>.json'; affordance-invocation-recorder.sh:55 'grep -qE ^[A-Za-z0-9._-]+$ || session=unknown' and tdad_tests/layer0_deterministic/test-affordance-recorder.sh:83-86 'Hostile session_id carrying JSON metacharacters: must be sanitised to unknown.'"
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: scope
    severity: medium
    claim: "The slice adds three HARNESS.md block schemas and two hook entries but does not update the reference pages that document exactly those two surfaces, which are stale the day it ships."
    evidence: "Spec 9 enumerates 'Five CI-checked version locations plus the README plugin-table cell' and nothing else; docs/plugins/ai-literacy-superpowers/reference/harness-md-format.md and reference/hooks.md exist and go unmentioned; CLAUDE.md requires docs changes in the same PR."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: specification quality
    severity: medium
    claim: "The vocabulary introduces enforcement tokens with no semantics and no override path, in a slice that claims to gate nothing, which pre-authorises hard enforcement in S4 without the on-the-record override constraint 6 requires."
    evidence: "Spec 3.2: 'enforcement: advisory | strict' with only the advisory default defined; spec 3.3: 'hard_stop_hour', 'notification_policy_after_stop: digest | none'; spec 6: 'No gating. Nothing in this slice blocks, warns, or requires a disposition.'"
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: specification quality
    severity: medium
    claim: "The acceptance scenarios omit the one behaviour that justifies building a second parser (block-scoped key isolation) and leave present-but-malformed block behaviour undefined."
    evidence: "Spec 3.7 justifies block_key because read_key 'searches the entire document, which is safe for its unique keys but not for a vocabulary of three blocks that may share key names'; scenario 11 tests only a single active Budgets block; spec 3.6 defines absent-block behaviour only, while 3.3 asserts 'A Budgets block whose prose has lost the clause is a malformed block.'"
    disposition: pending
    disposition_rationale: null
---

# Objection record — Cadence Sentinels S1: Shared Infrastructure

Spec-mode adversarial review. Twelve objections: one critical, seven high,
four medium. The spec is unusually well-argued — its divergence notes, its
disposed open decisions, and its explicit non-goals all raise the review
floor. The objections below concentrate where that quality does not reach:
the runtime semantics of the hook rail it borrows, the parser it inherits,
and the constitutional constraints it interprets narrowly.

**Dispatcher verification note (2026-08-08).** Three claims were verified
independently before this record was written. O5 was confirmed empirically:
piping `hard_stop_hour: 18:30` through `read_key`'s extraction yields `30`,
and `focus_blocks: 09:00-12:00, 14:00-17:00` yields `00`. O3 was confirmed
by reading `affordance-invocation-recorder.sh:68`. O1 was confirmed by
absence: `reflection-prompt.sh`, `curation-nudge.sh`, `gc-rotate.sh`, and
`snapshot-staleness-check.sh` each declare "runs at session end (Stop hook)"
and carry no dedup, marker, or once-per-session guard — the belief is
repo-wide, asserted, and nowhere verified.

## O1 — implementation — critical

### Claim

The session registry's lifecycle rests on the assumption that the `Stop`
hook fires once, at the end of a session. `Stop` fires when the main agent
finishes responding — many times per session. Under that semantics, a
session writes its entry at `SessionStart`, deletes it at the end of its
first response turn, and is invisible to every count taken thereafter. The
WIP Warden — the sentinel this component exists to serve — would
systematically undercount exactly the concurrent long-running sessions it
was built to notice.

### Evidence

> **`Stop` hook** removes this session's entry and prunes stale ones.
>
> `Stop` is used rather than `SessionEnd` because `hooks.json` already runs
> nine `Stop` hooks and none on `SessionEnd`; adding to the existing rail
> keeps the hook surface honest and gives the pruner the same firing
> guarantees the reservoir check already relies on. — §4.2

The nine existing scripts each open with `# ... — runs at session end (Stop
hook).` That comment is a repo-wide assumption, not a verified fact, and it
is harmless for all nine because every one of them is idempotent and
advisory: firing five times per session produces at most a duplicate
nudge. The guarantee the reservoir check "relies on" is precisely *no*
guarantee — it needs only to fire often enough. That property does not
transfer to a destructive mutation.

Acceptance scenario 6 encodes the assumption rather than testing it:

> **Prune on stop.** Given entries for X and Y, when the `Stop` hook runs
> in session X, then X's entry is gone and Y's remains.

The scenario passes whether or not session X is still alive.

The mirror-image gap is `SessionStart`, which fires on startup, resume,
clear, and compact under the existing `matcher: "*"` in `hooks.json`. The
spec says only "`SessionStart` hook writes the entry" (§4.2) and does not
say whether a re-fire resurrects a removed entry or resets `started_at` —
and a reset `started_at` means a genuinely long-running session never ages
out of the staleness window in §4.3.

### Why this matters

This is the load-bearing claim of Component 2. If `Stop` is per-turn, the
registry is not a live-session registry — it is a record of sessions that
have not yet answered once. Three later slices consume it. Because the
component gates nothing in S1, the defect ships green, and the first
symptom is a WIP Warden in S4 that reports `1` while four sessions run.
The spec should either cite the firing semantics it depends on, or make
removal idempotent under repeated firing (for example, refresh a heartbeat
on `Stop` and let staleness alone retire entries) so correctness does not
depend on which reading is true.

## O2 — implementation — high

### Claim

`.claude/sessions/` is inside the project directory, so the registry counts
sessions *per repository*. The concurrency problem a WIP Warden addresses
is one human running several sessions across several repos. Under this
location, three sessions in three repos each read a count of `1`. The
`repo` field in the entry schema is the tell: it is invariant within any
registry that can observe it, and only becomes meaningful in a registry
this spec does not build.

### Evidence

> `.claude/sessions/<session-id>.json`, one file per live session:
> `{ "id": ..., "repo": "<absolute path to project root>", "started_at": ... }` — §4.1

The location argument is explicitly per-project:

> Per-machine local session state already lives in `.claude/` —
> `.claude/.harness-upgrade-dismissed` and `.claude/affordance-discovery-*.md`
> are both there and both gitignored. — §4.1

Both cited precedents are repo-relative (they appear in this repo's
`.gitignore` as project paths), and scenario 12 confirms the reading by
testing with `git status --porcelain`, which only sees paths inside the
work tree.

Meanwhile §1 states the need in person-scoped terms — "how many sessions
are live" — and §3.2 names the consumed key `max_concurrent_sessions`, not
`max_concurrent_sessions_per_repo`.

### Why this matters

The scope of "live" is the substrate's most consequential design decision
and the spec never states it in one sentence. If per-repo is intended, the
`repo` field is dead weight and S4's threshold semantics need renaming so a
human does not read a cross-repo promise into a per-repo number. If
cross-repo is intended, the location is wrong and `.gitignore` is
irrelevant, because a machine-global registry (for example under
`~/.claude/`) is never in a work tree at all. Deciding this after S4 starts
means changing the on-disk contract while three consumers hold it.

## O3 — alternatives — high

### Claim

This repo already writes a per-session, timestamped, sanitised, gitignored,
size-bounded record of session activity on every tool call. A live-session
count with an honest confidence flag is derivable from it — distinct
`session` values with a `ts` inside a recency window — with no new hooks,
no lifecycle assumption, no pruner, no staleness constant, and no race. The
spec does not mention this option, so the reader cannot tell whether it was
rejected or unseen.

### Evidence

`ai-literacy-superpowers/hooks/scripts/affordance-invocation-recorder.sh:68`:

```text
printf '{"tool":"%s","program":%s,"invoker":"%s","session":"%s","ts":"%s"}\n' \
  "$tool" "$prog" "$invoker" "$session" "$ts" >> "$file"
```

The session id is already sanitised (`:55`), the file is already gitignored
(`.gitignore:11`), and the recorder already bounds it at ~2 MB (`:76`).

The spec's justification for building instead is stated only in terms of
duplication, not in terms of alternatives:

> Built per-sentinel, that becomes three near-identical `HARNESS.md`
> parsers, three incompatible notions of "a live session"... — §1

That argument justifies *one* implementation. It does not justify a *new*
one.

A second unweighed alternative sits inside the epic's own vocabulary:
constraint 3 blesses `asked` as a first-class honesty flag. A WIP Warden
that asks "how many sessions do you have open?" is strictly more accurate
than any proxy, needs no substrate at all, and is the honest answer when
the machine cannot observe cross-repo state (O2).

### Why this matters

Spec time is the only moment where this question is cheap. The registry
carries a permanent cost — two hook entries on a rail that already runs
nine, a staleness heuristic, a pruning race, and a flag rule whose
correctness is contested in O4. If a derived read of an existing log gets
80% of the value at 10% of the surface, the whole of Component 2 is scope
that could be cut, and S1 shrinks to blocks plus record directories.
Recording the rejection would also satisfy the spec's own standard — it
disposed the `.superpowers/` path question on the record (§4.1) but not
this larger one.

## O4 — risk — high

### Claim

`registry_count` is specified as a read that deletes files. Two
consequences follow. First, the `observed`/`inferred` flag becomes a
property of *read ordering* rather than of the count: whichever consumer
reads first absorbs the prune and reports `inferred`, and every consumer
after it reports `observed` for the identical underlying uncertainty.
Second, concurrent sessions prune the same directory with no stated
serialisation.

### Evidence

> `registry_count` (emitting count and flag) — §4.4

The acceptance scenario makes the side effect explicit:

> **Stale entry pruned, count flagged inferred.** Given an entry older than
> `SESSION_STALE_HOURS`, when `registry_count` runs, then the stale entry is
> removed and the count is flagged `inferred`. — scenario 7

And the rule the flag is meant to express:

> A count that followed a prune is `inferred` because the pruner cannot
> distinguish a crashed session from a long-running healthy one — it only
> knows the entry aged out. — §4.3

That reasoning is right, and it is exactly what the mechanism cannot
deliver. The epistemic damage — a possibly-live session removed from the
count — persists for every subsequent read, but the flag that discloses it
survives only the first. Constraint 3 asks the flag to travel with the
observation; here it travels with the reader.

The repo's own CUPID lens (`templates/CLAUDE.md`, "Predictable — does it
behave as its name suggests, with no hidden side effects?") names the
shape: `registry_count` does not behave as its name suggests.

### Why this matters

The honesty flag is the stated point of Component 2 ("The flag rule is the
point of this component", §4.3). If the flag is unreliable in exactly the
scenario it was designed for, the component's headline claim is
unsupported, and three consumers inherit a confidence signal that
under-reports uncertainty. Separating prune from count — prune on the hook
rail, count as a pure read, and derive the flag from a durable property
(for example, whether any entry within the window was retired) — preserves
the rule the spec actually wants. Concurrency is the secondary concern:
nine `Stop` hooks already run in parallel-ish across sessions, and the
recorder at `:71-79` shows the repo has met and solved this class of
problem before with unique temp files.

## O5 — implementation — high

### Claim

§3.7 specifies `block_key` as `read_key` with block scoping — "scoped to
that block's span rather than the whole file" is the only stated
difference. `read_key`'s extraction is greedy on `[:=]`. Applied to the
values this spec mandates, `hard_stop_hour: 18:30` yields `30`,
`focus_blocks: 09:00-12:00, 14:00-17:00` yields `00`, and
`sync_points: 09:00, 16:00` yields `00`. The whitespace strip independently
destroys `daily_cost_ceiling: not observable`, which becomes
`notobservable`. An implementer who follows the spec ships a parser that
mangles the majority of the new vocabulary.

### Evidence

`reservoir-check.sh:37-41`:

```bash
val=$(grep -iE "^[[:space:]]*[-*]?[[:space:]]*${key}[[:space:]]*[:=]" "$HARNESS_FILE" 2>/dev/null \
      | head -1 \
      | sed -E "s/.*[:=][[:space:]]*//" \
      | tr -d '[:space:]' \
      | tr -d '`' || true)
```

`.*[:=]` is greedy: it consumes through the *last* colon on the line.
`read_key` is safe today only because every reservoir value is a bare
integer or a single word.

The spec then mandates colon-bearing and space-bearing values:

> `- hard_stop_hour: <HH:MM local>` / `- focus_blocks: <HH:MM-HH:MM, HH:MM-HH:MM>` — §3.3
> `- sync_points: <HH:MM, HH:MM | on-demand>` — §3.4
> `- daily_cost_ceiling: <amount, or "not observable">` — §3.3

§3.1 diagnoses the inherited parser's *other* defect in careful detail:

> The `read_key` helper in `hooks/scripts/reservoir-check.sh` strips
> whitespace from a matched value but does not strip a trailing `# comment`

The spec found the trailing-comment trap and stopped there. The greedy
colon and the space strip are the same class of defect and bite harder,
because they hit values the spec itself requires rather than comments a
human might add.

### Why this matters

Silent degradation is the failure mode the spec is trying to prevent, and
the design as written reproduces it in a worse place: a `hard_stop_hour`
that parses to `30` is not obviously wrong to a reader, and S3's clear-
weather rule would then hold a budget nobody authored. Scenario 11 would
catch this only if the implementer happens not to reuse the greedy `sed`.
The spec should state the value grammar (which keys are single-token,
which are time-valued, which are lists) and state that `block_key` returns
the raw remainder after the *first* delimiter, trimmed at the ends only.

## O6 — specification quality — high

### Claim

§5 asserts that declaring the record schemas in S1 is what makes the slice
a complete reviewable unit, and then declares no schema. One field name
appears in the whole section. There are also zero acceptance scenarios for
Component 3, so nothing in the TDAD set would notice its absence.

### Evidence

> Two directories, each with a `README.md` that carries its schema:
> `docs/superpowers/parked/` ... `docs/superpowers/consultations/` — §5

And the rationale that objection turns on:

> Declaring the schemas here rather than in S2 and S5 is deliberate. It
> makes S1 a complete, reviewable unit — the substrate is fully specified
> before anything consumes it — rather than half a feature waiting for its
> other half. — §5

The only field named anywhere is `status: resumed`. Nothing states the
required keys, the filename convention, the honesty-flag carriage (does a
parking record carry `observed`/`inferred`/`asked` per constraint 3?), or
what "marked superseded" looks like as a field.

§7 lists twelve scenarios; scenarios 1-3 and 9-11 cover blocks, 4-8 and 12
cover the registry. None covers a record directory or its README.

### Why this matters

The section's own stated rationale is the objection: if the schemas are not
here, S1 *is* half a feature, and S2 and S5 will invent the schemas mid-
slice — the precise failure §1 says this slice exists to prevent ("two
record directories invented mid-slice with schemas that drift apart").
Committing two empty directories whose READMEs are written during
implementation without spec review also means the append-only rule
(constraint 7) ships as prose nobody has agreed the shape of, and the first
`status: superseded` entry will discover its own format.

## O7 — premise — high

### Claim

The spec interprets constraint 4 ("persist nothing about the person") as
binding the session registry, and then activates a `Budgets` block in this
repo's committed `HARNESS.md` containing the human's working hours, focus
windows, and daily session capacity. That is durable, permanent,
publicly-distributed state describing the person. The spec never asks
whether a declared pact falls inside or outside constraint 4, so the
constraint's boundary is left undefined at exactly the moment the substrate
fixes it.

### Evidence

The spec's reading of constraint 4 covers one component:

> **Persist nothing about the person (constraint 4).** The registry records
> that a session exists, when it started, and against which repo. It
> records nothing about who is in it or how they are doing. — §2

The activation:

> All three blocks are additionally **activated** (uncommented, with
> values) in this repo's own root `HARNESS.md`, exactly as `## Cognitive
> reservoir` is. — §3.5

And the fields being activated:

> `- hard_stop_hour: <HH:MM local>` / `- focus_blocks: <HH:MM-HH:MM, HH:MM-HH:MM>`
> / `- sessions_per_day: <int>` — §3.3

The `## Cognitive reservoir` precedent it invokes points the other way. That
block's live text says explicitly:

> never records a claim about your cognitive state to disk (you edit this
> block yourself) — `HARNESS.md:1019-1020`

The reservoir block holds `chronotype: intermediate` — one coarse,
self-declared token — and the block's own prose argues that this is
acceptable *because* it is self-authored and not a claim. Nobody has made
that argument for a full daily schedule, and git history is append-only by
nature: constraint 7's append-only rule and constraint 4's persist-nothing
rule meet here, and the spec resolves neither.

### Why this matters

There is a strong steel-man for the spec: a *declared pact* is a statement
by the person, not an observation about them, and constraint 4 plausibly
targets inference and telemetry. If that is the intended reading, it should
be written down, because it is the distinction on which every later slice's
persistence decisions rest — S2's parking records and S5's consultation
dispositions are both records about how the human works. Left undefined,
the constraint provides no guidance to S2-S5 and cannot be enforced by
anything. Left undefined *and* precedent-set by §3.5, the effective rule
becomes "whatever S1 did", which is the weakest possible way to settle a
constitutional question. Note also that S3's Tune will replace placeholders
with real values and commit them; the placeholder framing defers the
question by one slice rather than answering it.

## O8 — risk — high

### Claim

`sentinel-integrity-check.sh` enforces the read-only boundary by rejecting
`Write`/`Edit` in an agent's `tools:` list and explicitly permitting `Bash`.
§4.4 instructs every consuming sentinel to source a shell library that
deletes files — and, per O4, deletes them even on the read path. CI stays
green while a `role: sentinel` agent removes files from disk. S1 does not
merely brush against the check's known limit; it manufactures the case the
limit was disclaimed for.

### Evidence

> `ai-literacy-superpowers/hooks/scripts/lib/session-registry.sh` owns the
> implementation: `registry_write`, `registry_remove`, `registry_prune`,
> `registry_count` (emitting count and flag). The `SessionStart` and `Stop`
> scripts and every consuming sentinel source this one file. — §4.4

`sentinel-integrity-check.sh:21-22`:

> 2\. If `role: sentinel`, the `tools:` list must NOT contain Write or Edit
> (case-insensitive). Bash is permitted — read-only inspection (git log,
> date) is within the boundary.

`sentinel-integrity-check.sh:30-33`:

> Known limit (by design). This is a deterministic backstop to human PR
> review, not a sandbox. It reads the declared `tools:` line; an agent that
> reaches a write capability through an undeclared channel is out of scope
> here...

The spec's own Note D shows the correct pattern was already found for the
sibling case and simply not applied here:

> The Coda cannot hold `Write`. Its agent returns record content; the
> `/coda` command persists it after a human disposes — the `cost-estimator`
> precedent. — §8, Note D

### Why this matters

Constraint 1 is CI-enforced precisely so the category stays load-bearing
rather than decorative. A shared library that hands every sentinel a
mutation primitive through the permitted channel converts a green check
into a false assurance — the exact outcome the check's author warned
about. The Note D reasoning generalises: sentinels should call a
count-only, side-effect-free entry point, with `registry_write`,
`registry_remove`, and `registry_prune` reachable only from the hook
scripts. Splitting the library along the trust boundary (a read surface and
a mutation surface) costs one file and preserves the constraint. Deciding
this in S1 is far cheaper than in S4, when three agents already source it.

## O9 — risk — medium

### Claim

The session id becomes a filesystem path component. The spec never states
where the id comes from, what shape it may take, or what happens when it is
hostile or empty — in a repo that has already found, tested, and fixed this
exact hazard for the same field.

### Evidence

> `.claude/sessions/<session-id>.json`, one file per live session — §4.1

The existing treatment, `affordance-invocation-recorder.sh:53-55`:

```bash
session=$(printf '%s' "$input" | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 ...)
printf '%s' "$session" | grep -qE '^[A-Za-z0-9._-]+$' || session="unknown"
```

And the test that exists because it was raised as a code-time objection on
that feature (`docs/superpowers/objections/affordance-runtime-recorder-design-code.md`,
O-entry naming "a hostile `session_id` carrying JSON metacharacters"),
`tdad_tests/layer0_deterministic/test-affordance-recorder.sh:83-86`:

> `# Hostile session_id carrying JSON metacharacters: must be sanitised to unknown.`

A value containing `/` or `..` in a path context is a strictly worse
outcome than the JSON-injection case already adjudicated, because the write
lands outside the intended directory.

Note also that no existing hook script except the recorder reads stdin at
all; `reservoir-check.sh` does not. The spec's two new scripts must, and
the spec does not say so.

### Why this matters

The mitigation is one `grep -qE` and it is already written down in this
repo — the cost of specifying it is a sentence. The cost of omitting it is
that an implementer copies `reservoir-check.sh` (which reads no stdin) and
invents id extraction from scratch, and the resulting path handling is
reviewed only if a code-time reviewer happens to think of it. Sanitising
to a fixed fallback also needs a stated collision rule: if two sessions
both sanitise to `unknown`, the count is silently wrong.

## O10 — scope — medium

### Claim

The slice adds three `HARNESS.md` block schemas and two hook-rail entries.
Both surfaces have dedicated reference pages in the docs site. §9 lists the
version locations to touch and stops there, so the reference pages are
wrong on the day the slice ships.

### Evidence

> Minor version bump, 0.66.2 → 0.67.0 ... Five CI-checked version locations
> plus the README plugin-table cell. — §9

The affected pages exist:

- `docs/plugins/ai-literacy-superpowers/reference/harness-md-format.md`
- `docs/plugins/ai-literacy-superpowers/reference/hooks.md`

And `CLAUDE.md` makes this non-optional:

> **When a feature changes a format or schema**: check whether reference
> pages are current. ... Include docs changes in the same PR as the
> implementation, not as a follow-up.

### Why this matters

`harness-md-format.md` is the document a downstream project reads to learn
what may appear in `HARNESS.md`. §9 states that `/harness-upgrade` will
surface the three new blocks to downstream projects — so adopters are
actively pushed toward blocks the reference does not document, including
the value-grammar rules from O5 that they most need. This is a checklist
omission rather than a design flaw, but the spec is otherwise meticulous
about rollout mechanics, which makes the gap easy to miss precisely because
§9 reads as complete.

## O11 — specification quality — medium

### Claim

The block vocabulary introduces enforcement-flavoured tokens —
`enforcement: strict`, `hard_stop_hour`, `notification_policy_after_stop`
— and defines the semantics of none of them, in a slice whose non-goals
say it gates nothing. A vocabulary is a commitment; shipping `strict` with
no definition and no override path pre-authorises S4 to interpret it as
blocking, which is the shape constraint 6 exists to prevent.

### Evidence

> `- enforcement: advisory | strict` — §3.2

with only the default defined:

> `enforcement` defaults to `advisory` when the block is present but the
> key is absent. — §3.2

against:

> **No gating.** Nothing in this slice blocks, warns, or requires a
> disposition. — §6

and the epic's constraint 6, which requires new constraints to ship
Unverified or Agent-verified first, "always with an on-the-record human
override, never a bypass". Nothing in §3.2 or §3.3 describes where that
override is recorded, or what a human does at 18:31 when `hard_stop_hour`
is `18:30`.

The `## Cognitive reservoir` precedent the spec models itself on takes the
opposite approach, writing the boundary into the block text:

> Do not promote it into a blocking gate — that would defeat its purpose
> and overclaim a precision the proxies cannot support. — `HARNESS.md:1020-1022`

### Why this matters

S1 fixes the vocabulary; S4 inherits it. A downstream human who declares
`enforcement: strict` in good faith has expressed an intent that no
document defines, and S4 will define it after the declaration exists in the
wild. Either the token needs a one-line semantics and an override location
now, or it should be omitted until S4 defines it — the spec argues in §3.4
that vocabulary should ship whole, which is a reason to define `strict`,
not a reason to leave it undefined. The `Budgets` block already
demonstrates the good pattern with its mandatory "Unspent budget is not a
debt" clause; `Session WIP` has no equivalent guard against being read as a
gate.

## O12 — specification quality — medium

### Claim

The acceptance scenarios do not test the property that justifies building
`block_key` at all — key isolation between blocks — and leave
present-but-malformed block behaviour undefined, even though §3.3 defines a
malformed state.

### Evidence

The justification for a second parser:

> `block_key <block-heading> <key> <default>` — the value, scoped to that
> block's span rather than the whole file (the reservoir `read_key` searches
> the entire document, which is safe for its unique keys but not for a
> vocabulary of three blocks that may share key names in future) — §3.7

The scenario that is supposed to cover it:

> **Block-scoped key read.** Given an active `Budgets` block, when
> `block_key Budgets hard_stop_hour` runs, then it returns the declared
> value, and a key absent from the block returns the supplied default. — scenario 11

A single-block fixture cannot distinguish block-scoped lookup from
whole-file lookup; `read_key` passes scenario 11 unmodified. The scenario
that would falsify it — two active blocks declaring the same key, asserting
each lookup returns its own block's value — is absent.

Separately, §3.6 defines behaviour for an absent block only:

> A consumer that finds its block absent reports: `no <block name> block
> declared — running in observe-only mode` and continues. Absence is never
> an error, never a warning, and never a gate.

while §3.3 creates a distinct third state:

> A `Budgets` block whose prose has lost the clause is a malformed block,
> and S3's critic check will say so.

Nothing states what `block_active` returns for a malformed block, or what a
consumer does with one — degrade to observe-only per §3.6, or something
else.

### Why this matters

Scenario 11 as written is a test that cannot fail for the reason it exists,
which means the library's differentiating property ships unverified — and
per O5 the parser has other defects that a single-block fixture also hides.
The malformed state matters because it is reachable by an ordinary human
action: someone uncomments the template block, deletes prose they read as
boilerplate, and now has a block that is present, active, parseable, and
malformed. Whether that reads as declared or as absent decides whether S3
holds them to a budget or reports observe-only, and the substrate is where
that should be settled.

## Explicitly not objecting to

- **The `.claude/` versus `.superpowers/` location decision (Note B).**
  Disposed on the record in §4.1 with cited precedent; the objection worth
  raising is about registry *scope* (O2), not about which directory name
  won, and a bare "why not `.superpowers/`" is decision archaeology for the
  Choice Cartographer, not a failure class.
- **Shipping `## Sync cadence` with no consumer.** This is real YAGNI, but
  §3.4 discloses it explicitly ("Its consumer is future work, on the
  record"), gives a coherent reason (a vocabulary introduced piecemeal
  leaves the template internally inconsistent), and the failure class is
  small and reversible — a downstream human authors two values nothing yet
  reads.
- **The missing `.gitignore` deliverable.** §4.1 asserts the registry is
  gitignored and §9 does not list the `.gitignore` edit, but scenario 12
  tests it directly (`git status --porcelain` sees no `.claude/sessions/`
  path), so the omission cannot ship silently.
- **The version-bump reasoning in §9.** 0.66.2 → 0.67.0 for added hooks and
  template content is a correct application of the repo's own semver rule
  in `CLAUDE.md`; the five CI-checked locations are enumerated accurately.
- **Deferring Note A's template inline-comment fix.** §6 and §8 give an
  honest boundary argument (pre-existing, different block, would widen a
  plumbing slice into a bug fix) and commit to a follow-up issue; O5
  objects to the *new* blocks' value grammar, not to leaving the reservoir
  block's trap alone.
- **Carrying S2/S7 consequences in Note D.** Recording discoveries that
  constrain later slices inside the slice that found them is good practice,
  not scope creep — the alternative is that S7 rediscovers the roster
  arithmetic.
- **The `authored_via: placeholder` device.** Refusing to author a real
  budget in a plumbing slice, so that the clear-weather rule is not
  undermined by an imposed default, is the strongest single argument in the
  spec; my objection at §3.5 (O7) is about what gets committed, not about
  the placeholder mechanism.
- **The "Unspent budget is not a debt" mandatory clause.** Putting a
  normative sentence inside the block rather than in a skill file is
  unusual, but it is deliberate, testable (scenario 2), and directly serves
  the epic's language discipline; O12 objects only to the undefined
  behaviour when the clause is missing.
- **Language discipline.** The spec uses "compulsive pattern" in its
  provenance line and never uses "addiction", "dopamine", or "reinforcing"
  loosely; constraint 8 is satisfied throughout.
