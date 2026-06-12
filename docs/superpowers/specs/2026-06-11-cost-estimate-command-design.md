# Cost Estimation — S3 — `/cost-estimate` command — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-11 (revised 2026-06-12 after spec-mode diaboli round 1, 9 objections accepted; further revised 2026-06-12 after round-2 diaboli — O1/O3/O4 fixed, O5/O6 flagged, O2 no-change) |
| Status | Draft — revised (round-2 request-changes pass complete) |
| Author | spec-writer (interactive session with russmiles) |
| Slice | S3 of the slicing record at `docs/superpowers/slices/cost-estimator-pipeline.md` |
| Progressed slice | S3 (this spec) |
| Tracking issue | #370 |
| Upstream (merged on main) | S1 (skill + `estimate-record-format.md`, incl. the #377 per-stage `cost_usd` additions); S2 (#369, the read-only `cost-estimator` agent) |
| Downstream slices | S4 (#371), S5 (#372), S6 (#373) — all out of scope here |
| Plugin version target | `ai-literacy-superpowers` v0.43.0 → v0.44.0 (new command — minor bump) |
| Marketplace listing | Top-level `version` unchanged at v0.4.0; `plugin_version` 0.43.0 → 0.44.0 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Governing decisions | AGENTS.md **"agent-emit + dispatcher-persist + human-disposes"** trust architecture (with its **dispose-then-write ordering invariant**); AGENTS.md **"disclosure-of-derived-judgment"** decision; CLAUDE.md **Output Validation Checkpoints** convention. |

---

## 1. Premise

S1 defined what an estimate record **is** (the `cost-estimation` skill +
`estimate-record-format.md` reference). S2 (#369) shipped the **emitter** —
the read-only `cost-estimator` agent that, given one target, reads its
grounding sources, applies the S1 methodology, and **returns the estimate-record
content as a string**. The agent holds `Read`, `Glob`, `Grep` only: it cannot
write, cannot validate its own output, and returns a stable `REFUSED:` string
rather than fabricating an ungroundable estimate.

S2 deliberately left three things to a **dispatcher**: who **writes** the record
to disk, **where** it lands, and the **Output Validation Checkpoint** that reads
it back and checks it against the format reference. S3 is the first such
dispatcher: the human-facing **`/cost-estimate` command**.

This slice's load-bearing decision is the one the slicing record's
`decision_focus` names: *should there be a standalone manual surface at all, and
what does it accept?* A command usable only inside the orchestrator gates is a
different product from one a human invokes ad hoc against any slice or spec. S3
commits to the standalone surface — the prospective counterpart to the existing
retrospective `/cost-capture` command — and locks four things:

1. **The command signature and accepted target types** — exactly what a human
   can point `/cost-estimate` at, reconciled with the S2 agent's
   one-target-per-dispatch contract (§4).
2. **The dispatch → checkpoint → dispose → write flow** — and specifically that
   the **human disposition PRECEDES the write** (the dispose-then-write ordering
   invariant), since the command owns the single `Write` the agent cannot
   perform (§5).
3. **Where the record is written** — the on-disk output-path convention, with a
   `--out` override and a confirm-before-write gate. The default home is a new
   top-level **`cost-estimates/`** directory — deliberately **outside**
   `observability/`, the telemetry/actuals tree, so a forward-looking *prediction*
   is never co-located with captured *actuals* where a future scan could read it as
   fact (§6).
4. **That the manual path carries its own Output Validation Checkpoint** against
   the format reference's validation checklist — including the #377 per-stage
   coupling and split-tier strict-spread checks — rather than relying on
   orchestrator-only validation, and that the checkpoint operates under a **strict
   transparency-at-the-disposition-seat discipline**: it may fix *structural-only*
   deviations in place but **never authors derived judgment**, and it **surfaces
   exactly what it changed** so the human disposes over a transparent
   agent-vs-command composite (§7).

S3 honours both governing AGENTS.md decisions and the CLAUDE.md checkpoint
convention. It is the **fifth production instance** of the
agent-emit/dispatcher-persist/human-disposes pattern (after `advocatus-diaboli`,
`choice-cartographer`, `model-card-researcher`, and `/diagnose`) — and the first
to honour the **dispose-then-write ordering invariant** on a *cost* record.

## 2. Scope and non-goals

### 2.1 In scope (S3)

- A new command at `ai-literacy-superpowers/commands/cost-estimate.md` — the
  human-facing manual dispatcher for the S2 `cost-estimator` agent, mirroring the
  `/cost-capture` retrospective sibling and the `model-card create`
  dispose-then-write flow.
- The **command signature** and the **accepted target types** (§4), reconciled
  with the S2 agent's one-target-per-dispatch contract.
- The **dispatch → REFUSED-handling → checkpoint → review summary → disposition →
  write** flow (§5), with the human disposition placed **before** the single
  `Write`.
- The **output-path convention**: a default location at top-level
  `cost-estimates/` (outside `observability/`), a `--out <dir>` override, the
  filename derivation, and same-day collision disambiguation **under both** the
  default and `--out` (§6).
- The **Output Validation Checkpoint** against
  `skills/cost-estimation/references/estimate-record-format.md`'s validation
  checklist — implementing each checklist line, **including** the #377 per-stage
  cost coupling and split-tier strict-spread checks — under the **structural-fix
  boundary** (fix structural-only deviations in place; abort, never author, on any
  deviation that would create or alter a derived value) and the **change-disclosure
  rule** (the review summary surfaces exactly what the checkpoint altered vs the
  agent's emitted record) — plus an **explicit decision** on the #377-deferred
  absolute-rate check and the grounding-path trailing-slash consumer special-case
  (§7, §8).
- The **`--kind` human-assertion flag** in the review summary: when `target_kind`
  is human-asserted (suppressing the agent's inference-basis line and raising the
  confidence ceiling), the summary **flags it as asserted-not-inferred** so the
  human re-confirms the ceiling they raised (§4.1, §5).
- A TDAD scenario set covering the command (structural + behavioural layers)
  under `tdad_tests/scenarios/commands/cost-estimate/` (§9).
- The plugin version bump (0.43.0 → 0.44.0), CHANGELOG entry, marketplace
  `plugin_version` pointer, README badge, the command's entry in the CLAUDE.md
  Output Validation Checkpoints list, and a docs touch (a how-to guide — the
  command is runnable now — plus a reference entry) (§10).

### 2.2 Out of scope (filed as separate issues)

Only S3 ships here. The following are explicitly **not** in this PR:

- **S4 — orchestrator fold-in at T1/T2** (#371). `/cost-estimate` is a
  **standalone manual surface**; it does **not** wire into the orchestrator
  pipeline, add or move a gate, or surface estimate fields inside the Slice
  Adjudication or Plan Approval gates. The command dispatches the agent directly
  and persists the result; the orchestrator dispatching the same agent at T1/T2
  is a separate dispatcher with its own spec. (The command and the orchestrator
  share the S2 agent and the S1 format; they do not share a dispatch surface.)
- **S5 — T0 pre-carpaccio ballpark** (#372). No pre-step-0 touchpoint. The
  command **accepts** raw task text as a target (so S5 can reuse the same agent
  for a coarse whole-task ballpark), but the firing position and the bonus-step
  wiring are S5's.
- **S6 — calibration loop** (#373). No per-PR actuals capture, no
  integration-agent change. The agent reads a `kind: calibration` grounding
  source **if one exists** (the S1 seam); the command neither produces nor
  requires one.
- **Any change to the S2 agent or the S1 format reference.** S3 is a **pure
  consumer** of both — it dispatches the agent as-merged and validates against the
  format reference as-merged. If a reviewer finds this spec adding a field,
  changing a charter, or widening the format, that is a defect to cut. (A genuine
  contract-change need would be carved into its own owning slice per the AGENTS.md
  consumer-never-mutates-the-contract decision — it would **not** be folded into
  S3, a consumer.)
- **A standalone runtime validator shipped as a separate artefact.** The Output
  Validation Checkpoint is a **step in the command's process**, not a new file or
  reusable component.

### 2.3 What S3 consumes (do not redefine)

S3 is a **pure consumer** of two merged contracts:

- The **S2 agent** at `ai-literacy-superpowers/agents/cost-estimator.agent.md` —
  its input contract (one target per dispatch; the `target_kind` classification;
  the `REFUSED:` convention; that it **emits a string and never writes**). S3
  dispatches it and reads its output. S3 does not redefine the agent's contract
  and does not duplicate the agent's methodology.
- The **S1 format reference** at
  `ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md`
  — the field set, range rules, time split, per-axis confidence, binding table,
  three grounding states, the `generated_by` `tier:` grammar, the grounding-path
  sentinel, the per-stage `cost_usd` coupling, and the **validation checklist**.
  The command's checkpoint references this file **by path** (per the file's own
  "A downstream command's Output Validation Checkpoint references this file by
  path" note) and implements its checklist. S3 adds no field and changes no
  validation rule in the reference.

## 3. Premise of a standalone manual surface (the in/out decision)

**Decision: ship the standalone manual surface.** The decision-focus question is
whether `/cost-estimate` should exist independently of the orchestrator at all.
It should, for the same reasons `/cost-capture` exists independently of any
pipeline:

- **Ad hoc reach.** A human wants a cost/token/time estimate on a slice, a spec,
  or a pasted task *before deciding to run the pipeline at all* — exactly the
  pre-pipeline question the orchestrator gates cannot answer because they only
  fire once a branch and slicing already exist.
- **End-to-end proof of S1+S2.** The command is the cleanest surface that
  exercises the skill + agent end-to-end without an orchestrator run: dispatch →
  validate → record on disk. It proves the emitter works before S4 folds it into
  gates where a bug would be costlier to find.
- **Discoverable symmetry.** `/cost-capture` (retrospective, writes
  `observability/costs/…`) and `/cost-estimate` (prospective, writes an estimate
  record) become a discoverable pair — a reader who finds one finds the other,
  mirroring the S1 SKILL's own sibling framing.

The alternative — *no manual surface, orchestrator-only* — was rejected: it ties
the capability's only entry point to a full pipeline run, removes the
pre-pipeline use case entirely, and breaks the `/cost-capture` symmetry. The
manual surface is cheap (it dispatches an agent that already exists) and is the
canonical first consumer.

## 4. The command signature and accepted targets

### 4.1 Signature

```text
/cost-estimate <target> [--kind <target-kind>] [--out <dir>]
```

- **`<target>`** (required, positional) — **one** target per invocation, matching
  the S2 agent's one-target-per-dispatch contract. It is **either** a path (to a
  slicing-record file, a spec file, or a file holding a single slice) **or** a
  quoted string of pasted task text. The command classifies which by resolving
  the positional argument as a filesystem path first; if it resolves to a
  readable file, it is treated as a path target, otherwise as inline task text.
- **`--kind <target-kind>`** (optional) — an explicit `target_kind` hint, one of
  `task-text` | `slicing-record` | `slice` | `spec`. When supplied, the command
  passes it to the agent as the **explicit dispatch-stated kind** (the agent's
  rule-1 path — no inference-basis line is then required). When absent, the agent
  infers the kind from the target's content and discloses the inference basis
  (the agent's rules 2–3). This is the single flag that lets a human disambiguate
  a path the agent might otherwise infer wrongly (e.g. a slice fragment that
  superficially reads as a spec).

  **The asserted kind must not silently buy a higher ceiling (O4).** An explicit
  `--kind` suppresses the agent's inference-basis disclosure line *and* raises the
  `tokens`/`time` confidence **ceiling** (`task-text`→`low`,
  `slicing-record`/`slice`→`medium`, `spec`→`high`). A human who asserts
  `--kind spec` on a file that is really a slice fragment thereby obtains a
  `high`-ceiling estimate with **no disclosed inference basis** — exactly the
  silent over-claim the agent's inference-disclosure contract exists to prevent.
  The command is a pure consumer of the agent's classification (it does not
  re-classify), but it **owns the review summary**, so it carries the disclosure
  the suppressed inference-basis line would otherwise have carried: when
  `target_kind` was **human-asserted via `--kind`**, the review summary (§5 step 5)
  **flags it prominently as asserted-not-inferred** and states that an asserted
  kind raised the confidence ceiling with no agent inference basis, so the human
  **re-confirms the ceiling they raised** before disposing. When the kind was
  agent-inferred, the summary instead carries the agent's inference-basis line as
  emitted. This keeps the asserted-vs-inferred distinction visible at the
  disposition seat.
- **`--out <dir>`** (optional) — an output-directory override; see §6.

The slice's loose sketch was
`/cost-estimate "<task>" [--near <path>] [--out <dir>]`. The `--near` flag is
**dropped**: the S2 agent accepts **exactly one target per dispatch**, with no
"primary target plus a nearby grounding hint" shape. Honouring the agent's
contract means one target, not a target-plus-neighbour. The `--out` flag is
kept; the `--kind` flag replaces `--near` as the disambiguation affordance and
maps cleanly onto the agent's explicit-kind rule.

### 4.2 Accepted target types (reconciled with the S2 agent)

The command accepts exactly the four target types the S2 agent accepts, supplied
as follows:

| Target | What it is | Supplied as |
| --- | --- | --- |
| Raw task text | Pasted prose description of work, before slicing or spec | A quoted string `<target>` that does not resolve to a readable file |
| A slicing record | A carpaccio slicing-record file (the whole multi-slice record) | A path `<target>` |
| A single slice | One slice extracted from a slicing record | A path `<target>` (optionally `--kind slice`) |
| A spec | A design spec enumerating scenarios and files to touch | A path `<target>` |

The command does **not** itself classify the `target_kind` (that is the agent's
job, §4.2 of the S2 spec). It only distinguishes **path vs inline text** to know
*how to pass* the target to the agent (a path to read vs an inline string), and
forwards any `--kind` hint as the explicit kind. Classification semantics —
inference, the confidence ceiling, the inference-basis disclosure — remain the
agent's.

## 5. The dispatch → checkpoint → dispose → write flow

This is the load-bearing structural commitment of S3: the command owns the single
`Write`, and the **human disposition PRECEDES it**. The flow, in order:

1. **Parse args and resolve the target** — distinguish path vs inline text (§4),
   capture any `--kind` and `--out`.
2. **Dispatch the S2 `cost-estimator` agent** — passing the one target, the
   explicit `--kind` if supplied, and (if the command knows it) the resolved
   model id for the agent's `generated_by` branch (a). The agent returns **either**
   the estimate-record content as a string **or** a `REFUSED:` string.
3. **Handle `REFUSED:` (no write).** If the agent's output begins with the stable
   `REFUSED:` prefix, the command **surfaces the refusal reason to the user
   verbatim and aborts with no file written** (§5.1). A malformed or partial
   record is never persisted on a refusal.
4. **Output Validation Checkpoint** — read the returned record back, check it
   against the format reference's validation checklist, and **fix only
   structural-only deviations in place**, **recording every change it makes**
   (never re-dispatch the agent) (§7). The checkpoint **never authors derived
   judgment**: any deviation that would create or alter a derived value
   (`cost_usd`, `cost_basis`, a range, a confidence tier, a `failure_direction`)
   is **not** fixed — the command **aborts without writing** (§7.1a). The
   checkpoint runs **before** the human disposes, so the human reviews a
   *validated* record. If a deviation cannot be fixed within the structural-only
   boundary (a structurally unrecoverable record, or a derived-value defect), the
   command surfaces the failure and aborts without writing (§7.1a, §7.3).
5. **Show the review summary** — a structured, human-readable summary of the
   validated record: target + classified `target_kind` **and, when the kind was
   human-asserted via `--kind`, a prominent asserted-not-inferred flag noting the
   raised ceiling has no agent inference basis** (§4.1, O4); the token range and
   per-axis confidence; the agent-compute-time range and the `human_gate_time`
   caveat; whether `cost_usd` is present or omitted (and, when omitted, the
   disclosed cause, **reporting a trailing-slash `cost-snapshot` grounding entry
   as "no snapshot — directory inspected, no snapshot found", not a grounding** —
   §7.3); the `failure_direction` with its driver; **the resolved output path**;
   and — **when the checkpoint changed anything at step 4 — an explicit
   change-list (a diff or itemised list) of exactly what the command altered vs
   the agent's emitted record** (O1). The summary is what the human disposes over;
   the change-list makes the agent-content-vs-command-content provenance
   transparent, so the human's `accept` ratifies a composite it can see the seams
   of. When the checkpoint changed nothing, the summary says so ("no checkpoint
   changes — record as emitted by the agent").
6. **Ask for disposition** — the **full** named vocabulary from the
   agent-emit/dispatcher-persist architecture (not a narrowed accept/abort):
   - **`accept`** — proceed to the write (step 7).
   - **`edit`** — open the validated draft in `$EDITOR` (or `vi` if unset). On
     return, run the checkpoint in **validate-and-report mode**: it **validates**
     the human-edited content and **reports** any remaining deviation, but does
     **NOT** silently fix human-edited content. **A human edit is never reverted
     without the human seeing and re-confirming it** (O3). If the edited record
     still deviates, the command surfaces the remaining deviation in the
     re-prompt and lets the human decide (re-edit, accept-as-is where structurally
     valid, or abort) — the human is the final author on the edit path. (The
     fix-in-place of step 4 applies to the **agent's fresh output**; the edit path
     is **validate-and-report**, because the content is now the human's.)
   - **`re-run`** — **re-dispatch the agent** on the same target. The re-dispatch
     **re-reads the grounding sources afresh** — including the (now-populated)
     `observability/costs/` directory — so a human who adds a cost snapshot and
     then chooses `re-run` gets a record grounded in the newly-added snapshot
     (the add-a-snapshot-then-re-run use case works because re-run is a full fresh
     dispatch, not a reuse of cached grounding) (O8). The command then re-validates
     (step 4) and re-summarises (step 5).
   - **`abort`** — discard the draft; **no file written**.
7. **On `accept` (post-disposition): write once.** The command performs its
   single `Write` to the resolved output path (§6), creating the directory if
   needed, then confirms the full path to the user.

**The ordering invariant, stated plainly:** nothing is persisted until the human
returns `accept` at step 6. Steps 2–5 produce and validate a *returned string*
and a *review summary*; the `Write` at step 7 is the only persistence and it is
**downstream of** the human disposition. This is the AGENTS.md dispose-then-write
invariant honoured as ordering, not merely as the agent/command tool split — and
it deliberately ships the **full** accept/edit/re-run/abort vocabulary rather
than the narrowed accept/abort `/diagnose` shipped (the AGENTS.md watch item flags
that narrowing as a divergence to avoid recurring).

### 5.1 REFUSED handling (no malformed record)

The S2 agent returns a stable `REFUSED:` string when it cannot ground an estimate
(an unreadable/unclassifiable target, an absent or tableless `MODEL_ROUTING.md`).
The command detects the prefix at step 3 and:

- surfaces the refusal reason, the target, and the grounding-read line to the
  user **verbatim**;
- **writes no file** and runs **no** validation checkpoint (there is nothing
  conforming to validate);
- aborts the flow.

This is the dispatcher half of the S2 refusal convention: the *convention* is
the agent's, the *check-and-decline-to-persist* is the command's. An
authoritative-looking estimate record is never written for a target the agent
could not honestly ground.

### 5.2 The empty-snapshot case is NOT a refusal

Per the S1 three grounding states and the S2 agent's contract, an empty
`observability/costs/` yields a **valid, complete cost-omitted record**, not a
`REFUSED:` string. The command treats that record as a normal emit: it validates
it (the checkpoint's cost-pairing and grounding-path checks confirm the omission
is well-formed), summarises it (showing `cost_usd: omitted` with the disclosed
cause), and — on `accept` — writes it. The command must **not** treat a
cost-omitted record as a failure; doing so would make the command unusable on
today's repo, contradicting the S1 "no-cost case is honest, not a failure"
decision.

## 6. Where the record is written

### 6.1 Default output path — top-level `cost-estimates/`, OUTSIDE `observability/`

The command's single `Write` targets, by default:

```text
cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md
```

- **`cost-estimates/`** — a **new top-level directory**, deliberately **outside**
  the `observability/` tree. The command creates it if it does not exist
  (`mkdir -p`).
- **`<YYYY-MM-DD>`** — the date the estimate was produced.
- **`<target-slug>`** — derived from the target: for a path target, the source
  filename with its date prefix and `.md` extension stripped (e.g.
  `cost-estimator-pipeline`); for inline task text, a short kebab-case slug of the
  first few words. When a slug collision would overwrite an existing same-day
  estimate, the command appends a short disambiguator and notes it in the
  confirm-before-write summary. **This collision disambiguation applies under both
  the default directory and `--out`** — see §6.2.

#### Why outside `observability/` (the O5 output-home decision)

The earlier draft filed estimates under `observability/estimates/`, a sibling to
`observability/costs/`, "for symmetry". That conflates two **different kinds of
data**: `observability/` is the project's **telemetry / actuals** tree — captured
snapshots, cost actuals, audit outputs that downstream tools scan **as ground
truth**. An estimate record is a forward-looking **prediction (a guess)**. Filing
predictions under the actuals root risks a future scan reading an estimate as an
observed fact — the precise confusion the estimate-record format works to prevent
(no list-price fallback; omit-when-ungrounded).

**What was checked.** Every current consumer of the `observability/` tree was
read for how it globs:

- `commands/harness-health.md` (lines 22–24, 60–64) reads **two named
  subdirectories** by specific patterns — `observability/costs/*-costs.md` (latest
  cost snapshot) and `observability/snapshots/*-snapshot.md` (trend comparison).
  It does **not** glob `observability/**` tree-wide.
- `commands/cost-capture.md` (step 1) globs `observability/costs/*-costs.md` only.
- `commands/observatory-verify.md` (step 2) and its checklist
  `skills/harness-observability/references/observatory-signals.md` read **named
  subdirectories** — `observability/snapshots/`, `observability/governance/` — by
  specific filename patterns; there is **no** tree-wide glob and **no** signal
  source for an `estimates/` sibling.
- The hook scripts (`snapshot-staleness-check.sh`, `governance-drift-check.sh`,
  `gc-rotate.sh`) and `update-health-badge.sh` likewise key on named
  subdirectories with specific filename patterns.

So **no current consumer would aggregate an `observability/estimates/` sibling as
actuals today.** But "no consumer mis-reads it *today*" is a weaker guarantee than
"the data lives where its kind belongs." A marker/guard inside
`observability/estimates/` would depend on every *future* tree-wide scan honouring
the marker — a standing obligation a new consumer could silently miss.

**Decision: move the default home OUTSIDE `observability/`** to a top-level
`cost-estimates/` directory. This removes the conflation at the source rather than
guarding against it: predictions are not telemetry, so they do not live under the
telemetry root, and no future `observability/` scan can read an estimate as an
actual because no estimate is under `observability/` at all. The
`/cost-capture` ↔ `/cost-estimate` discoverable pairing (a retrospective-cost and
a prospective-cost command) is preserved by **naming** — `observability/costs/`
(actuals) and `cost-estimates/` (predictions) read as siblings-by-name — without
co-locating the two data kinds under one scanned root.

**Decision: `cost-estimates/` is gitignored by default (O3).** An estimate record
is a **derived, regenerable** prediction — its `target` may reference an unmerged
spec, a since-renamed slice, or a task description that changes after the estimate
is produced. This is the exact shape the repo's existing convention treats as
not-committed: `.gitignore` already excludes the `/diagnose` output
(`diagnostic-legibility/output/`) because it is "derived, regenerable artefacts …
Never committed." An estimate is the same kind of artefact, so it inherits the
same default. **This slice adds the `cost-estimates/` line to `.gitignore`** with a
comment matching the `/diagnose` entry's "derived, regenerable" rationale (Task 5a,
FR-10a). The staleness/rotation concern O3 raised is thereby moot: estimates are
regenerable artefacts re-produced on demand, not a committed corpus of stale
guesses that drifts from moving targets. A human who wants to retain a specific
estimate can still commit it explicitly or write it elsewhere via `--out`.

### 6.2 `--out <dir>` override (collision disambiguation applies here too)

`--out <dir>` overrides the **directory** only; the
`<YYYY-MM-DD>-<target-slug>-estimate.md` filename still applies beneath it
(mirroring `model-card create`'s `--out` semantics — directory override, derived
filename preserved). This lets a human drop an estimate next to a spec under
review, or into a scratch directory, without losing the canonical filename shape.

**Same-day collision disambiguation applies under `--out` exactly as under the
default (O9).** A human deliberately co-locating estimates in one `--out`
directory is the *most* likely place to hit a same-day same-slug collision, and a
silent overwrite there is real data loss. So when the derived filename beneath
`--out` would overwrite an existing same-day estimate, the command appends the
same short disambiguator and notes it in the confirm-before-write summary. **The
command never silently overwrites an existing estimate, under the default
directory or under `--out`.**

### 6.3 Confirm-before-write

The resolved output path is shown in the **review summary** (step 5) and the
write happens only on `accept` (step 6 → 7). The human therefore confirms both
the *content* (the validated record) and the *destination* (the resolved path)
**before** any persistence. This is the confirm-before-write gate the slice asks
for, realised as part of the single dispose-then-write disposition rather than a
second separate prompt.

## 7. The Output Validation Checkpoint

Per the CLAUDE.md Output Validation Checkpoints convention, the command **reads
the returned record back, checks its structure against the format reference's
validation checklist, and fixes deviations in place** (it does **not** re-dispatch
the agent). The checkpoint references
`skills/cost-estimation/references/estimate-record-format.md` by path and
implements **every** line of that file's "Validation checklist", including the
#377 additions.

### 7.1 The checklist lines the checkpoint implements

The command's checkpoint runs each of the format reference's checklist lines:

1. **Ranges well-formed** — every present range (`tokens`, each
   `tokens_by_stage[].tokens`, each `tokens_by_stage[].cost_usd` *when present*,
   `cost_usd` *when present*, `agent_compute_time`) has `low ≤ high`.
2. **Per-stage cost coupling (#377)** — if **any** `tokens_by_stage[].cost_usd`
   is present, the top-level `cost_usd` must also be present (a per-stage band
   never appears on a cost-omitted record). A record with no per-stage bands
   passes vacuously; the check forbids only the incoherent inverse.
3. **Split-tier strict-spread (#377)** — for **every present**
   `tokens_by_stage[].cost_usd` whose `model_tier` **contains a `/`** (the
   closed split-tier trigger, after join-key whitespace normalisation), the band
   must have a strictly-positive ordered spread (`low < high`, strict). A
   collapsed band on a split-tier stage fails; single-tier stages are exempt; a
   record with no per-stage bands passes vacuously.
4. **All four disclosure sections present** — Included, Excluded, Confidence
   rationale, Failure direction.
5. **Per-axis confidence within cap** — each present `tokens`/`time` axis is
   within the `target_kind` ceiling (`task-text`→`low`,
   `slicing-record`/`slice`→`medium`, `spec`→`high`); the `cost` axis is present
   **iff** `cost_usd` is present and is **not** capped by `target_kind`.
6. **Cost pairing** — `cost_usd` and `cost_basis` are both present or both
   absent; when absent, `Excluded` carries the cost-omission disclosure.
7. **Time split** — both time fields present and separate: `agent_compute_time`
   a `{ low, high }` range, `human_gate_time` a qualitative caveat string (not a
   range).
8. **No-verdict, field-absence layer** — no `recommendation`, `verdict`, or
   `proceed` field in the frontmatter.
9. **No-verdict, positive-content layer** — the disclosure prose contains no
   imperative recommendation or go/no-go language (the tripwire pattern list).

When a check finds a deviation, whether the command fixes it in place or aborts is
governed by the **structural-fix boundary** in §7.1a — not a vague
"mechanically-recoverable" predicate. The checkpoint **never re-dispatches the
agent**, and **never authors derived judgment**.

### 7.1a The fix-in-place boundary — structural-only, never authoring derived judgment (O1, O2)

"Fix in place" is bounded precisely so the checkpoint can never silently alter
what the human disposes over. The boundary is drawn at **structural-only vs
derived-value**:

- **STRUCTURALLY-RECOVERABLE → fix in place, and record the change.** The
  checkpoint MAY repair a deviation that is purely *structural* and *unambiguous* —
  one whose correction invents **no** value the agent did not emit. Examples:
  - **delete a stray `recommendation`/`verdict`/`proceed` field** (checklist line
    8) — removal of a forbidden field, authoring nothing;
  - **normalise a malformed-but-unambiguous structural field** where the intended
    value is unarguable from the surrounding emitted content (e.g. a join-key
    whitespace normalisation already defined by the format reference; a YAML
    shape-only fix that does not change a number, a tier, or a confidence label).

  Every such fix is **recorded** and surfaced in the review summary's change-list
  (§5 step 5), so the human sees exactly what the command altered.

- **DERIVED-VALUE or AMBIGUOUS → ABORT, never author.** The checkpoint MUST
  **abort without writing** — it does **not** invent or alter — for any deviation
  whose correction would **create or change a derived judgment value**. The
  checkpoint never authors a `cost_usd` band, a `cost_basis`, a `tokens`/`time`
  range, a per-axis confidence tier, or a `failure_direction`; it never edits
  disclosure prose to supply a missing rationale; it never resolves an ambiguous
  structural defect by guessing the intended value. Concretely:
  - a **cost-present record missing `cost_basis`** (checklist line 6, "Cost
    pairing") **ABORTS** — inserting `cost_basis: snapshot-actuals` would assert a
    provenance the agent did not state, which is *authoring derived provenance*,
    exactly what is forbidden. (This **removes** the earlier draft's "insert a
    missing `cost_basis`" fix-in-place example, which inverted the rule.)
  - a **`low > high` range** (line 1) ABORTS — re-ordering or clamping a band
    changes a derived number;
  - a **missing disclosure section** (line 4) ABORTS — the checkpoint cannot
    author the Included/Excluded/Confidence/Failure-direction prose the agent owns;
  - a **per-stage-coupling violation** (line 2: a per-stage band on a cost-omitted
    record) ABORTS — the resolution (drop the band, or supply a top-level cost)
    each alters a derived value;
  - a **collapsed split-tier band** (line 3) ABORTS — widening it would author a
    spread the agent did not emit;
  - a **confidence axis above the ceiling** (line 5) ABORTS — lowering it is a
    derived-judgment change;
  - an **imperative-recommendation tripwire hit** (line 9) ABORTS — the checkpoint
    cannot rewrite the agent's prose to remove a verdict without authoring prose.

  On any abort, the command surfaces the failing checklist line and the reason
  ("derived-value defect — the checkpoint does not author the agent's judgment")
  and writes **no file**. The honest move on a derived-value defect is to surface
  it and let the human re-run or abort, **not** to silently complete the agent's
  record.

**Per-checklist-line disposition.** The table below states, for each of the nine
checklist lines (§7.1), whether a failure is structurally-recoverable (fix +
record) or abort:

| # | Checklist line | On failure |
| --- | --- | --- |
| 1 | Ranges well-formed (`low ≤ high`) | **ABORT** — re-ordering/clamping changes a derived number |
| 2 | Per-stage cost coupling | **ABORT** — resolution alters a derived value |
| 3 | Split-tier strict-spread | **ABORT** — widening authors a spread |
| 4 | Four disclosure sections present | **ABORT** — checkpoint cannot author prose |
| 5 | Per-axis confidence within cap | **ABORT** — lowering is a derived-judgment change |
| 6 | Cost pairing (`cost_usd`/`cost_basis` together) | **ABORT** — supplying `cost_basis` authors provenance |
| 7 | Time split (separate fields, right shapes) | **ABORT** — any time-field defect alters or omits a derived value (`agent_compute_time` is a `{low, high}` range; `human_gate_time` a qualitative string); no no-value-change mistyping is constructible |
| 8 | No-verdict field-absence (stray `recommendation`/`verdict`/`proceed`) | **FIX** — delete the forbidden field; record it |
| 9 | No-verdict positive-content (imperative/go-no-go prose) | **ABORT** — checkpoint cannot rewrite the agent's prose |

In practice the only routinely-fixed line is **#8 (delete a stray verdict
field)** — a pure removal that authors nothing. Every line that would require the
checkpoint to *supply* a derived value aborts. This is the structural-fix boundary
the disclosure-of-derived-judgment contract demands: a *second* actor (the
command) never silently mutates the agent's judgment, and on the one class it does
touch (forbidden-field removal) it records the change for the human.

**Live-surface note (O5).** Against today's cost-omitted-only records (§7.2: no
record the command can emit today carries `cost_usd` or a per-stage `cost_usd`
band), the LIVE checklist surface is lines **4 / 8 / 9** only. The cost-band rows
— lines 1–3 and the cost halves of lines 5–6 — are **dormant** until a snapshot
lands: their ABORT branches pass vacuously on a cost-omitted record and are
unreachable until `/cost-estimate` can emit a cost-present record. The table is
stated in full so it is correct once cost-present records exist; two-thirds of it
does not fire on today's producible records.

### 7.1b The edit path is validate-and-report, not fix-in-place (O3)

The fix-in-place boundary of §7.1a governs the checkpoint run at **step 4 on the
agent's fresh output**. On the **`edit` disposition** (§5 step 6) the content is
the **human's**, and the human is the **final author**. The post-edit checkpoint
runs in **validate-and-report mode**: it validates the edited record and
**reports** any remaining deviation in the re-prompt, but it does **NOT** apply
fix-in-place to human-edited content — **a human edit is never reverted without
the human seeing and re-confirming it.** If the edited record still deviates, the
human decides (re-edit, accept where the record is structurally valid, or abort);
the command does not silently un-edit the human. This reconciles step 4's
fix-in-place (agent output) with the edit path (human authorship): the two are
different runs with different authorship and therefore different rules.

### 7.2 The #377-deferred absolute-rate check — DECISION: defer further, with a recorded reason

The #377 format reference states (in "Per-stage cost — what the validator CAN and
CANNOT assert") that the **absolute-rate falsification** — asserting a split-tier
band's bounds actually **equal** the `claude-sonnet-4`/`claude-opus-4` rates, or
that the band genuinely **spans two tiers** rather than merely being non-collapsed
— is *"a runtime, snapshot-grounded check … deferred to S3's Output Validation
Checkpoint (which can read both the record and the snapshot)"*.

**Decision: S3 does NOT build the absolute-rate check in this slice; it is
deferred further, with a recorded reason and a re-filed tracking home.** The
reasoning:

- **The check is only meaningful on a cost-present record, which today's repo
  cannot produce.** `observability/costs/` is empty, so every record S3 writes
  today is **cost-omitted** — it carries no `cost_usd` and no per-stage
  `cost_usd` band, so there is nothing for an absolute-rate check to falsify. The
  check would be dead code against every record the command can currently emit.
- **It is a materially different kind of check** from the structural-conformance
  checklist S3 ships: it requires the checkpoint to **re-read the snapshot**,
  recompute per-model `$/token` from the Model Breakdown, and compare against the
  record's bands within a tolerance. That is the same rate-derivation arithmetic
  the agent performs — duplicating it in the validator re-introduces the
  derivation surface the read-only/dispatcher split exists to keep in one place,
  and it needs its own adversarial pass on the tolerance and the
  re-derivation (a snapshot whose mix differs from emit time, rounding, the
  blended-rate skew).
- **Building it speculatively now is YAGNI against a closed-world record set.**
  The honest first-version checkpoint is the structural-conformance one; the
  absolute-rate check earns its place once a real snapshot exists and a real
  cost-present record can be validated against it.

**Recorded reason + re-filing with a COMMITTED home and a blocking acceptance
criterion (O6, per the AGENTS.md natural-home-hand-off decision).** Because #377
named "S3's Output Validation Checkpoint" as the absolute-rate check's natural
home, and S3 declines it, the concern must **not** be left implicit in a closed
slice — and re-filing it to a fresh issue that no slice is bound to build would be
a second consecutive buck-pass (the objection O6 names) that risks permanent
orphaning. So S3 does two things, not one:

1. **Re-file with its own lifecycle.** S3 **re-files the absolute-rate check as a
   standalone tracking issue** ("estimate-record absolute-rate validation —
   snapshot-grounded per-stage cost falsification"), so it has a tracking home
   regardless of which slice eventually picks it up.
2. **Bind it to a concrete slice NUMBER, not to an unscheduled precondition
   (O4).** The re-filed issue is **not** a soft "most naturally S6" suggestion, and
   — critically — it is **not** keyed on an event the roadmap never schedules. The
   earlier revision bound the trigger to "the first slice that produces a
   cost-present record", but **no scheduled slice produces that event**: landing
   the first usable `observability/costs/` snapshot is not a deliverable of any
   slice as previously written (S6 was framed as *consuming* actuals, not capturing
   the first snapshot), so the trigger was unreachable and the check could stay
   orphaned exactly as O6 feared. The fix is to **make snapshot-capture an explicit
   S6 deliverable and bind the check directly to S6/#373**:

   > **S6 (#373, the calibration loop) owns first-snapshot capture.** S6's
   > deliverables are extended to include **capturing the first usable
   > `observability/costs/` snapshot** (the actuals it calibrates against must
   > first exist for the loop to close), and — as a **required deliverable of the
   > same slice** — **building the absolute-rate check**. The absolute-rate check
   > is therefore a **BLOCKING required deliverable of S6/#373**, bound to a
   > concrete slice number, not to a precondition the roadmap does not cause.

   This makes the home **reachable**: S6 is the slice that both first makes
   cost-present records possible (by capturing the snapshot) and consumes them (the
   calibration loop), so binding the check to S6 is binding it to the exact slice
   under which the first record it could falsify comes into existence. If a future
   roadmap re-assigns first-snapshot capture to an earlier slice, the check travels
   with snapshot-capture to *that* slice; but the binding is to a **named slice**,
   not to an event no slice is committed to produce. **S6/#373 now owns the
   absolute-rate check.**

### 7.3 The grounding-path trailing-slash consumer special-case — DECISION: not enforced as a checklist line; honoured where S3 itself consumes the field

The #377 reference adds a **consumer special-case**: an aggregator that counts
"how many records were grounded in a cost snapshot" must **not** count a
`cost-snapshot` grounding entry whose `path` ends in `/` (the directory sentinel
for *looked-and-found-nothing*) as a real grounding. The reference explicitly
flags this special-case as **advisory/unenforced** — *"no validation-checklist
line keys on `grounding_sources[].path` shape"* — and names the residual
silent-miscount risk it externalises onto every downstream counter.

**Decision: S3 does NOT add a new validation-checklist line that keys on the
`grounding_sources[].path` shape** — it follows the reference's as-merged
checklist, which deliberately carries no such line, and it does **not** invent
one (inventing one would be a consumer mutating the contract, which the AGENTS.md
consumer-never-mutates decision forbids). **But S3 honours the special-case at
the one point where the command *itself* consumes the field**: in the review
summary (step 5), when the command reports whether the record is "grounded in a
cost snapshot", it tests the trailing slash and reports a trailing-slash
`cost-snapshot` entry as **"no snapshot — cost omitted (directory inspected, no
snapshot found)"**, *not* as a snapshot grounding. The command is itself a
downstream consumer of `grounding_sources`, so it must not be the consumer that
miscounts; honouring the special-case in its own summary logic is the dispatcher
half of the residual the reference named, even though no checklist line enforces
it on the record. (S3 does not add the missing checklist line because that is a
format change the format-owning slice would have to own; S3 simply does not
*itself* fall into the trap.)

#### Recorded residual: S3 ships the FIRST records carrying the unguarded sentinel (O7)

Not mutating the contract is correct (the own-the-contract rule — adding the
checklist line is the format-owning slice's job, not a consumer's). But the
consequence must be **recorded in this spec as a known failure the records
carry**, not left only to later cartographer archaeology: **S3 is the slice that
ships the first body of estimate records persisted to disk, and every such record
that is cost-omitted carries the `cost-snapshot` grounding entry with the
**unguarded** trailing-slash directory sentinel** — unguarded because no
validation-checklist line keys on `grounding_sources[].path` shape (the #377
reference names this residual explicitly:
`estimate-record-format.md` "Noted residual", lines ~296–301). The concrete,
named consequence for downstream consumers:

- **Every other consumer of these records** — S4's orchestrator fold-in, and any
  future aggregator that counts "how many estimates were grounded in a real cost
  snapshot" — **will silently miscount** a trailing-slash directory entry as a
  real grounding **unless it applies the same trailing-slash test S3 applies in
  its own summary.** The records do not carry a machine-enforced guard; the
  protection is per-consumer and easy to omit.
- **S3 makes this risk concrete** rather than hypothetical: before S3 there were
  no persisted estimate records; after S3 there is a growing corpus of them, every
  cost-omitted one bearing the unguarded sentinel.

This is recorded here so S4 and any aggregator inherit the failure **named in the
spec**: a downstream consumer that does not replicate the trailing-slash test
miscounts, and the records themselves will not stop it. The structural fix (a
checklist line keying on `grounding_sources[].path` shape) remains the
format-owning slice's deliverable; S3 records the residual and declines to mutate
the contract from a consumer seat.

### 7.4 Why the checkpoint is mandatory on the manual path

The slice's decision-focus asks whether the manual path carries its **own**
validation checkpoint or relies on orchestrator-only validation. It carries its
own: `/cost-estimate` writes structured markdown that downstream tools (and S4's
fold-in) may parse, so the CLAUDE.md convention applies to it directly — and the
manual path is precisely the one the orchestrator never sees. The command joins
the CLAUDE.md Output Validation Checkpoints list (§10).

## 8. The decisions the slice asked S3 to fix, summarised

| Question (from the slice / constraints) | S3 decision |
| --- | --- |
| Standalone manual surface at all? | **Yes** — ship it; prospective sibling of `/cost-capture` (§3) |
| Command signature | `/cost-estimate <target> [--kind <target-kind>] [--out <dir>]`; `--near` dropped, `--kind` added (§4.1) |
| Accepted target types | task text / slicing-record path / spec path / slice — one per invocation, matching the agent (§4.2) |
| Where the record is written | Default top-level `cost-estimates/<date>-<slug>-estimate.md`, **outside `observability/`** (O5-home); **gitignored by default** as a derived, regenerable artefact (O3); `--out` overrides the directory; collision disambiguation under both (§6) |
| `--kind` raised ceiling | Review summary **flags a human-asserted kind** as asserted-not-inferred with a raised ceiling and no agent inference basis (O4) (§4.1, §5) |
| Dispose-then-write ordering | Human disposition (accept/edit/re-run/abort) PRECEDES the single Write; confirm-before-write realised in the disposition (§5, §6.3) |
| Checkpoint transparency | Fix **structural-only** in place + **record every change** in the review summary; **abort, never author** any derived-value defect (O1, O2) (§5, §7.1a) |
| Edit path | **Validate-and-report**, not fix-in-place — a human edit is never silently reverted (O3) (§5, §7.1b) |
| `re-run` re-reads snapshot | `re-run` is a full fresh dispatch that **re-reads `observability/costs/`**, so add-a-snapshot-then-re-run works (O8) (§5) |
| REFUSED handling | Surface verbatim, write nothing, no checkpoint (§5.1) |
| Own validation checkpoint | **Yes** — implements the full format checklist incl. #377 per-stage coupling + split-tier strict-spread (§7.1) |
| #377-deferred absolute-rate check | **Deferred further** with a recorded reason; re-filed as a **BLOCKING required deliverable of S6/#373** — bound to a concrete slice number, with S6 extended to own first-snapshot capture so the trigger is reachable (O6, O4) (§7.2) |
| Grounding-path trailing-slash special-case | **Not** a new checklist line; honoured in the command's own summary consumption; **residual recorded** — S3 ships the first records carrying the unguarded sentinel (O7) (§7.3) |

## 9. Component design (per component-design-with-tdad)

- **Type**: command — the deliverable is a human-invokable slash command that
  dispatches an agent and persists its output. Not a skill (the methodology is
  the S1 skill) and not an agent (the read-only emitter is S2).
- **Justification**: S2 shipped the emitter that returns a string; S3 is the
  dispatcher that writes and validates it. A command file is the canonical home
  for a human-facing dispatch surface, and the `/cost-capture` /
  `model-card create` precedents establish the shape.
- **TDAD layers targeted**: `[structural, behavioural]`. Layer 1 (structural)
  always — frontmatter well-formed; the process documents the dispatch →
  REFUSED-handling → checkpoint → review-summary → disposition → write order with
  the disposition **before** the write; the checkpoint section references the
  format reference by path and enumerates the checklist lines incl. the #377
  ones; the disposition vocabulary is accept/edit/re-run/abort. Layer 3
  (behavioural) **applies** — a dispatch against a real target produces a written
  record at the resolved path (or, on REFUSED, no file), validatable by
  deterministic oracles. Layer 2 (trigger) does not apply — commands have no
  description-vs-query match.
- **Behavioural grading strategy.** Like the S2 agent, the command's behaviour
  rides a non-deterministic `model: inherit` dispatch, so the behavioural
  scenarios grade **deterministically-checkable properties of the on-disk
  outcome**, not exact wording:
  - **File-existence + path oracle.** Assert a file exists at the resolved output
    path on `accept`, and that **no** file is written on `abort` or on a
    `REFUSED:` fixture.
  - **Conformance oracle.** Parse the written record's frontmatter and assert the
    S1 field-set structural properties (required fields present, enums in range,
    every present range `low ≤ high`, the four disclosure sections present, no
    `recommendation`/`verdict`/`proceed` field).
  - **#377-check oracle.** On a fixture that pins a cost-present record with a
    split-tier per-stage band, assert the checkpoint's per-stage-coupling and
    split-tier strict-spread checks hold (band `low < high` on the `/`-tier
    stage); on a cost-omitted fixture, assert both checks pass vacuously and the
    `cost-snapshot` grounding entry's trailing-slash path is reported as "no
    snapshot" in the summary, not a grounding.
  - **Structural-fix-boundary oracle (O1/O2).** On a fixture pinning a record with
    a **stray `verdict` field** (a structural-only defect), assert the field is
    removed AND the review summary's change-list names the removal (fix + record).
    On a fixture pinning a **cost-present record missing `cost_basis`** (a
    derived-value defect), assert the command **aborts without writing** and does
    **not** insert a `cost_basis` (abort, never author). On a fixture where the
    checkpoint changes nothing, assert the summary says "no checkpoint changes".
  - **Edit-validate-and-report oracle (O3).** On the `edit` path with a fixture
    where the human edit introduces a tolerated structural change, assert the
    post-edit checkpoint **reports** rather than silently reverts — the edited
    value is preserved and any remaining deviation is surfaced in the re-prompt,
    not auto-fixed.
  - **`--kind` assertion-flag oracle (O4).** On a fixture invoking
    `--kind spec` on a slice-fragment target, assert the review summary contains a
    human-asserted (asserted-not-inferred) flag naming the raised ceiling; on a
    fixture with no `--kind` (agent-inferred), assert the summary instead carries
    the agent's inference-basis line.
  - **REFUSED oracle.** On an ungroundable fixture, assert the agent's `REFUSED:`
    prefix is surfaced and **no** file is written.
  - **Fixture-driven grounding.** Each behavioural scenario pins its inputs (a
    fixture target, a fixture `MODEL_ROUTING.md`, an empty or populated
    `observability/costs/`) so the input is deterministic even though the model
    is not. A scenario no oracle can grade is descoped, not rubber-stamped.
- **Modification or new?** new — `commands/cost-estimate.md`. No modification of
  the S2 agent or the S1 format reference.
- **Scenario vs finding**: scenario only — every assertion is falsifiable by one
  of the deterministic oracles above.

## 10. User stories and acceptance scenarios

**Runnable-today vs synthetic-fixture flag (O6).** Most scenarios below are
exercised by a real grounding read on today's repo (an empty `observability/costs/`
yields a cost-omitted record): §10.1, §10.3 (REFUSED), §10.4 (cost-omitted paths),
§10.5, §10.6 are **runnable-today**. Two scenarios pin a **synthetic cost-present
world** the command's real grounding cannot produce until a snapshot lands —
**§10.4b** (the cost-present abort path) and **§10.6b** (re-run yielding a
cost-present record). These two **hand-author the split-tier cost bands** that the
deferred absolute-rate check (§7.2) would otherwise validate; they exist to pin
future behaviour, not to be exercised by a grounded emit on today's repo.

### 10.1 Story — a human can ask for a cost estimate ad hoc, end to end

**As** a human deciding whether to run a piece of work through the pipeline
**I want** a standalone `/cost-estimate` command that estimates a target's
tokens, agent-compute time, and (when grounded) cost, and writes the record to
disk
**So that** I get a prospective estimate without a full orchestrator run — the
prospective counterpart to `/cost-capture`.

```gherkin
Given the /cost-estimate command dispatched against a real spec-file target
And MODEL_ROUTING.md is readable and observability/costs/ is empty (today's default)
When the command runs the agent, validates the returned record, summarises it,
    and I respond "accept"
Then a cost-omitted estimate record is written to
    cost-estimates/<date>-<slug>-estimate.md (a top-level directory, outside observability/)
And the written file conforms to the S1 estimate-record field set (parsed, not read loosely)
And cost_usd and cost_basis are omitted, the omission disclosed in Excluded
And the command confirms the full written path to me
```

### 10.2 Story — the human disposition precedes the write (the ordering invariant)

**As** a human who must stay in the disposition seat
**I want** the command to surface and let me dispose over the validated record
*before* it writes anything
**So that** no estimate is persisted without my disposition, honouring the
dispose-then-write ordering invariant.

```gherkin
Given the /cost-estimate command has dispatched the agent and validated the returned record
When the command reaches the disposition step
Then it shows me a review summary of the validated record (target, target_kind,
    token range + confidence, agent-compute-time range + human_gate_time caveat,
    cost present/omitted, failure_direction) and the resolved output path
And it offers the disposition vocabulary accept / edit / re-run / abort
And NO file has been written yet

When I respond "abort"
Then no file is written

When I respond "accept" instead
Then exactly one Write occurs, to the resolved output path, after my disposition
```

### 10.3 Story — a REFUSED estimate is surfaced, never persisted

**As** a human running the command on an ungroundable target
**I want** the agent's refusal surfaced and no record written
**So that** an authoritative-looking estimate is never produced for a target the
agent could not honestly ground.

```gherkin
Given the /cost-estimate command dispatched against an unreadable target path
    (or one where MODEL_ROUTING.md cannot be read, or reads but its tables are
    missing/unparseable)
When the agent returns a string beginning with "REFUSED:"
Then the command surfaces the refusal reason, target, and grounding-read line to me verbatim
And no validation checkpoint runs
And no file is written
And the flow aborts
```

### 10.4 Story — the manual path carries its own Output Validation Checkpoint, transparently

**As** a downstream consumer (a human, or S4's fold-in) of the written record
**I want** the command to validate the record against the format checklist before
I dispose, fixing only structural-only deviations and surfacing exactly what it
changed
**So that** the manual path does not rely on orchestrator-only validation, the
checkpoint never silently authors the agent's derived judgment, and I dispose over
a transparent agent-vs-command composite.

```gherkin
Given the /cost-estimate command has received a record from the agent
When it runs the Output Validation Checkpoint
Then it checks the record against every line of the format reference's validation
    checklist, including the #377 per-stage cost coupling and split-tier
    strict-spread checks
And it fixes only STRUCTURAL-ONLY deviations in place, without re-dispatching the agent
And it presents the validated record (not the raw agent output) in the review summary

Given a returned record carrying a cost-present split-tier per-stage cost band
When the checkpoint runs the split-tier strict-spread check
Then a split-tier (model_tier contains "/") per-stage band with low == high fails the check
And a non-collapsed split-tier band (low < high) passes
```

#### 10.4a Scenario — the checkpoint surfaces exactly what it changed (O1)

```gherkin
Given a returned record carrying a stray "verdict" field (a structural-only defect)
When the checkpoint fixes it in place by deleting the forbidden field
Then the review summary includes a change-list naming the deletion (agent-content vs command-content)
And I dispose over the validated record knowing exactly what the command altered

Given a returned record the checkpoint did not need to change
When it presents the review summary
Then the summary states "no checkpoint changes — record as emitted by the agent"
```

#### 10.4b Scenario — the checkpoint aborts, never authors, on a derived-value defect (O2)

```gherkin
Given a returned cost-present record that is MISSING cost_basis (a derived-value defect)
When the checkpoint runs the Cost-pairing check
Then it does NOT insert a cost_basis (inventing provenance the agent did not state)
And the command surfaces the failing checklist line and aborts without writing

Given a returned record with a low > high range (a derived-number defect)
When the checkpoint runs the Ranges-well-formed check
Then it does NOT re-order or clamp the band
And the command surfaces the failure and aborts without writing
```

### 10.5 Story — an empty cost snapshot produces a written cost-omitted record, not a refusal

**As** a human running the command on today's repo (empty `observability/costs/`)
**I want** a valid cost-omitted record written, not a refusal
**So that** I get a grounded token + time estimate plus an honest "cost not yet
knowable".

```gherkin
Given the /cost-estimate command dispatched against a valid spec target
And MODEL_ROUTING.md is readable but observability/costs/ is empty
When the agent returns a valid cost-omitted record (NOT a REFUSED string) and I accept
Then a cost-omitted record is written to cost-estimates/<date>-<slug>-estimate.md
And the cost-snapshot grounding entry's path is the directory "observability/costs/"
    (trailing slash), and the review summary reports it as "no snapshot — cost
    omitted (directory inspected, no snapshot found)", not as a snapshot grounding
And the written record carries the UNGUARDED trailing-slash sentinel (no checklist
    line keys on grounding_sources[].path shape) — a residual any other consumer
    must apply the same trailing-slash test to avoid miscounting (recorded, O7)
And cost_usd and cost_basis are omitted, the omission disclosed in Excluded
And tokens and agent_compute_time are present as ranges and human_gate_time is the
    qualitative caveat string
```

### 10.6 Story — the signature accepts one target, with an optional kind hint and out override

**As** a human estimating different kinds of target
**I want** `/cost-estimate <target> [--kind <kind>] [--out <dir>]` to accept a
path or pasted task text, an explicit kind hint, and an output-directory override
**So that** I can point it at a slice, a spec, a slicing record, or pasted text,
disambiguate an ambiguous path, and choose where the record lands.

```gherkin
Given the /cost-estimate command
When I pass a positional target that resolves to a readable file
Then the command treats it as a path target and passes it to the agent as a path

When I pass a positional target that does not resolve to a readable file
Then the command treats it as inline task text and passes it to the agent as inline text

When I pass --kind spec
Then the command forwards "spec" to the agent as the explicit dispatch-stated kind
And the agent uses it directly (no inference-basis line required)

When I pass --out <dir>
Then the record is written beneath <dir> with the derived
    <date>-<slug>-estimate.md filename

When I pass --out <dir> while the agent returns a cost-omitted record and I accept
Then exactly one file is written, beneath <dir>, and the command confirms the full path
```

#### 10.6a Scenario — an asserted --kind is flagged in the review summary, not silently trusted (O4)

```gherkin
Given the /cost-estimate command invoked with --kind spec on a target that is really a slice fragment
When the command summarises the validated record for disposition
Then the review summary flags target_kind as HUMAN-ASSERTED (not agent-inferred)
And it states that the asserted kind raised the tokens/time confidence ceiling to "high"
    with no agent inference basis
And it asks me to re-confirm the ceiling I raised before I dispose

Given the /cost-estimate command invoked with NO --kind (the agent infers the kind)
When the command summarises the validated record
Then the summary carries the agent's inference-basis line as emitted (classified as <kind> by <signal>)
And it does NOT show a human-asserted flag
```

#### 10.6b Scenario — re-run re-reads a newly-added snapshot (O8)

```gherkin
Given the /cost-estimate command has produced a cost-omitted record (observability/costs/ was empty)
And I add a usable cost snapshot to observability/costs/ before disposing
When I respond "re-run"
Then the command re-dispatches the agent on the same target
And the re-dispatch re-reads grounding afresh, including the now-populated observability/costs/
And the re-validated, re-summarised record can now carry cost_usd grounded in the added snapshot
```

#### 10.6c Scenario — --out never silently overwrites an existing same-day estimate (O9)

```gherkin
Given a same-day estimate for the same target already exists beneath <dir>
When I run /cost-estimate <same-target> --out <dir> on the same day and accept
Then the command appends a short disambiguator to the derived filename
And it notes the disambiguation in the confirm-before-write summary
And the existing estimate is NOT overwritten
```

### 10.6d Story — a human edit is never silently reverted (O3)

**As** a human who edits the draft on the `edit` disposition
**I want** the post-edit checkpoint to validate and report, not silently fix my
edit
**So that** I remain the final author of the content I edited and no edit is
reverted without my seeing and re-confirming it.

```gherkin
Given I chose "edit" and changed the validated draft in $EDITOR
When the command runs the post-edit checkpoint in validate-and-report mode
Then it does NOT apply fix-in-place to my edited content
And if my edited record still deviates, it surfaces the remaining deviation in the re-prompt
And it lets me decide (re-edit, accept where structurally valid, or abort)
And no edit of mine is reverted without my seeing and re-confirming it
```

### 10.7 Story — the command joins the Output Validation Checkpoints discipline

**As** a maintainer
**I want** `/cost-estimate` listed in the CLAUDE.md Output Validation Checkpoints
list and documented as a runnable command
**So that** the checkpoint discipline is discoverable and the new command has a
how-to guide and a reference entry.

```gherkin
Given the S3 change set
When I read the CLAUDE.md Output Validation Checkpoints convention
Then /cost-estimate appears in the list of commands with checkpoints

And a how-to guide exists for /cost-estimate under
    docs/plugins/ai-literacy-superpowers/how-to/
And a reference entry documents the command signature, accepted targets, output
    path, and validation checkpoint
```

## 11. Functional requirements

| FR | Requirement |
| --- | --- |
| FR-1 | A new command file `ai-literacy-superpowers/commands/cost-estimate.md` exists with well-formed frontmatter (`name: cost-estimate`, a description) (§2.1, §9). |
| FR-2 | The command signature is `/cost-estimate <target> [--kind <target-kind>] [--out <dir>]`; `--near` is not present; `--kind` accepts the four `target_kind` values (§4.1). |
| FR-3 | The command accepts exactly one target per invocation, distinguishing path vs inline task text by filesystem resolution, matching the S2 agent's one-target-per-dispatch contract (§4.2). |
| FR-4 | The command dispatches the S2 `cost-estimator` agent (it does not re-implement the methodology or re-classify the `target_kind`), forwarding any `--kind` as the explicit kind (§4.2, §5 step 2). |
| FR-5 | On a `REFUSED:` agent output, the command surfaces the refusal verbatim, runs no checkpoint, writes no file, and aborts (§5.1). |
| FR-6 | The command runs an Output Validation Checkpoint that checks the returned record against every line of the format reference's validation checklist — including the #377 per-stage cost coupling and split-tier strict-spread checks — fixing **only structural-only deviations** in place and **aborting (never authoring)** on any deviation that would create or alter a derived value (`cost_usd`, `cost_basis`, a range, a confidence tier, a `failure_direction`); it never re-dispatches the agent. The per-checklist-line disposition (fix vs abort) of §7.1a governs (§7.1, §7.1a). |
| FR-6a | When the checkpoint changes anything at step 4, the review summary surfaces an explicit change-list (diff or itemised list) of exactly what the command altered vs the agent's emitted record; when it changes nothing, the summary says so. The human disposes over a transparent agent-content-vs-command-content composite (§5 step 5, §7.1a; O1). |
| FR-6b | On the `edit` disposition the post-edit checkpoint runs in **validate-and-report** mode: it validates and reports remaining deviations but does NOT apply fix-in-place to human-edited content; a human edit is never reverted without the human seeing and re-confirming it (§5 step 6, §7.1b; O3). |
| FR-7 | The checkpoint references `skills/cost-estimation/references/estimate-record-format.md` by path and does not inline or mutate its field/checklist definitions (§2.3, §7). |
| FR-8 | The command shows a review summary of the validated record and asks for a disposition from the full vocabulary accept / edit / re-run / abort **before** any write (§5 steps 5–6). |
| FR-8a | When `target_kind` was human-asserted via `--kind`, the review summary flags it prominently as asserted-not-inferred and states that the asserted kind raised the confidence ceiling with no agent inference basis, so the human re-confirms the ceiling raised; when the kind was agent-inferred, the summary carries the agent's inference-basis line as emitted (§4.1, §5 step 5; O4). |
| FR-8b | The `re-run` disposition re-dispatches the agent as a full fresh dispatch that re-reads the grounding sources, including the now-populated `observability/costs/`, so the add-a-snapshot-then-re-run use case works (§5 step 6; O8). |
| FR-9 | The command owns the single `Write`, performed only on `accept`, downstream of the human disposition (the dispose-then-write ordering invariant) (§5 step 7). |
| FR-10 | The default output path is `cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md` — a top-level directory **outside `observability/`** (the telemetry/actuals tree); the command creates the directory if absent. No current `observability/` consumer would read it as an actual; the home is outside the telemetry root by design (§6.1; O5-home). |
| FR-10a | `cost-estimates/` is gitignored by default: this slice adds a `cost-estimates/` line to `.gitignore` with a "derived, regenerable artefacts … Never committed" comment matching the existing `/diagnose` (`diagnostic-legibility/output/`) entry. Estimate records are derived, regenerable predictions, not a committed corpus (§6.1; O3). |
| FR-11 | `--out <dir>` overrides the directory only; the derived filename still applies beneath it (§6.2). |
| FR-11a | Same-day slug-collision disambiguation applies under both the default directory and `--out`; the command never silently overwrites an existing estimate (§6.1, §6.2; O9). |
| FR-12 | The resolved output path is shown in the review summary so the human confirms content and destination before the write (§6.3). |
| FR-13 | An empty `observability/costs/` produces a written cost-omitted record (not a refusal); the command never treats a cost-omitted record as a failure (§5.2, §10.5). |
| FR-14 | The command honours the grounding-path trailing-slash consumer special-case in its OWN summary consumption (reporting a trailing-slash `cost-snapshot` entry as "no snapshot", not a grounding) without adding a new validation-checklist line to the format (§7.3). |
| FR-14a | The spec records, as a named residual, that S3 ships the first persisted estimate records and that every cost-omitted one carries the **unguarded** trailing-slash sentinel — a known failure for any other consumer (S4/aggregators) that does not apply the same trailing-slash test (§7.3; O7). |
| FR-15 | The #377-deferred absolute-rate check is **deferred further** with a recorded reason and re-filed as a standalone tracking issue **bound to a concrete slice number**: it is a **BLOCKING required deliverable of S6/#373**, which is extended to also own **first-snapshot capture** so the trigger is reachable (not keyed on an unscheduled "first cost-present record" event). S6 both captures the first `observability/costs/` snapshot and consumes it in the calibration loop, so it is the slice under which the first falsifiable cost-present record comes into existence (§7.2; O6, O4). |
| FR-16 | `/cost-estimate` is added to the CLAUDE.md Output Validation Checkpoints command list (§7.4, §10.7). |
| FR-17 | TDAD structural + behavioural scenarios exist under `tdad_tests/scenarios/commands/cost-estimate/`, graded by the deterministic oracles of §9 — including the structural-fix-boundary, edit-validate-and-report, and `--kind` assertion-flag oracles (§9). **Runnable-today vs synthetic-fixture split (O6):** scenarios exercised by a real grounding read on today's repo are the **runnable-today** ones (empty-snapshot cost-omitted §10.5, REFUSED §10.3, and the cost-omitted-record paths of §10.1/§10.4/§10.6); the **synthetic cost-present fixtures** are §10.4b (cost-present abort path) and §10.6b (re-run yielding a cost-present record), which pin a cost-present world the command's real grounding cannot produce until a snapshot lands and therefore **hand-author the very split-tier bands the deferred absolute-rate check (§7.2) would otherwise validate** (§9). |
| FR-18 | The plugin version is bumped 0.43.0 → 0.44.0 across plugin.json, marketplace.json (entry + `plugin_version`), and the README badge, with a CHANGELOG entry; top-level marketplace `version` stays 0.4.0 (§2.1, §10). |
| FR-19 | A how-to guide and a reference entry for `/cost-estimate` ship in the same PR (§10.7). |

## 12. Open questions / ambiguities resolved

- **`--near` vs the one-target contract.** The slice sketched
  `[--near <path>]`, but the S2 agent accepts exactly one target per dispatch.
  Resolved by **dropping `--near`** and adding `--kind` as the disambiguation
  affordance (§4.1) — honouring the agent's contract rather than inventing a
  second-target shape the agent cannot consume.
- **Where checkpoint runs relative to the disposition.** `model-card create`
  validates between `accept` and the write; the format reference says "fix
  deviations in place". Resolved by running the checkpoint **before** the
  disposition (§5 step 4) so the human disposes over a *validated* record, then
  writing on `accept` — keeping the single Write downstream of the disposition.
- **What "fix in place" may and may not do (O1, O2).** The phrase was
  under-bounded. Resolved by the **structural-fix boundary** (§7.1a): the
  checkpoint fixes **structural-only** deviations in place (routinely only the
  removal of a stray verdict field) and **records every change** in the review
  summary; it **aborts, never authors**, on any deviation that would create or
  alter a derived value. The earlier "insert a missing `cost_basis`" example is
  **removed** — inventing provenance is exactly what is forbidden, so a
  cost-present record missing `cost_basis` now **aborts**.
- **The edit path vs fix-in-place (O3).** Resolved by making the post-edit
  checkpoint **validate-and-report** (§7.1b): step-4 fix-in-place applies to the
  agent's fresh output; on the human-authored edit path the checkpoint reports but
  never silently reverts.
- **`--kind` raising the ceiling silently (O4).** Resolved by a review-summary
  **asserted-not-inferred flag** (§4.1, §5) so a human-asserted kind that raised
  the ceiling with no inference basis is surfaced for re-confirmation.
- **The #377-deferred absolute-rate check (O6, O4).** #377 named S3 as its home.
  Resolved by **deferring further with a recorded reason** (the check is dead
  against today's cost-omitted-only records and needs its own adversarial pass on
  re-derivation + tolerance) and **re-filing it bound to a concrete slice
  number — a BLOCKING required deliverable of S6/#373**, per the AGENTS.md
  natural-home-hand-off decision. The earlier revision keyed the trigger on "the
  first slice that produces a cost-present record", but no scheduled slice produces
  that event (O4); resolved by **extending S6 to also own first-snapshot capture**
  so the trigger is reachable — S6 both captures the first `observability/costs/`
  snapshot and consumes it, making it the slice under which the first falsifiable
  cost-present record exists. S6/#373 now owns the absolute-rate check (§7.2).
- **The grounding-path trailing-slash special-case (O7).** The reference flags it
  as advisory/unenforced. Resolved by **not** adding a checklist line (a consumer
  must not mutate the contract) while **honouring it where S3 itself consumes the
  field** (the review summary), and **recording the residual** that S3 ships the
  first records carrying the unguarded sentinel so S4/aggregators inherit a named
  failure (§7.3).
- **`re-run` and a mid-session snapshot (O8).** Resolved by stating that `re-run`
  is a full fresh dispatch that re-reads `observability/costs/`, so adding a
  snapshot and re-running picks it up (§5).
- **Output directory (O5).** The earlier draft chose `observability/estimates/`
  for symmetry with `/cost-capture`. Resolved by moving the default home to a
  top-level **`cost-estimates/` directory, outside `observability/`** — predictions
  do not belong under the telemetry/actuals root where a future scan could read
  them as fact. Every current `observability/` consumer (harness-health,
  cost-capture, observatory-verify + signal checklist, the hook scripts) was
  checked and reads named subdirectories by specific filename patterns, not the
  tree wholesale; moving the home outside `observability/` removes the conflation
  at the source rather than relying on a marker a future scan could miss (§6.1).
- **`--out` collision (O9).** Resolved by applying the same-day disambiguation
  under `--out` too — the command never silently overwrites an existing estimate
  (§6.2).
- **Whether `cost-estimates/` is committed (O3).** The earlier draft left
  gitignoring it a deferred docs-note. Resolved by **deciding it: gitignored by
  default** — an estimate is a derived, regenerable prediction referencing a moving
  target, the same artefact-kind as the `/diagnose` output the repo already
  gitignores. This slice adds the `cost-estimates/` line to `.gitignore` (§6.1,
  FR-10a). The staleness concern is moot once the corpus is regenerable rather than
  committed.
