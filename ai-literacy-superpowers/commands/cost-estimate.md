---
name: cost-estimate
description: Estimate a target's tokens, agent-compute time, and (when grounded) cost before it runs — the prospective sibling of /cost-capture. Dispatches the read-only cost-estimator agent, validates the returned record, and writes it after you dispose.
---

# /cost-estimate \<target\> [--kind \<target-kind\>] [--out \<dir\>]

The human-facing manual dispatcher for the read-only `cost-estimator` agent —
the **prospective** counterpart to the retrospective `/cost-capture`. Point it at
a slice, a spec, a slicing record, or pasted task text and it estimates the
target's **tokens**, **agent-compute time**, and (only when a cost snapshot
grounds it) **cost**, then writes the estimate record to disk.

The command **owns the single Write**; the agent stays read-only and only emits a
string. The human disposition **precedes** the write — nothing is persisted until
you return `accept` (the AGENTS.md **agent-emit + dispatcher-persist +
human-disposes** decision and its **dispose-then-write ordering invariant**).

## Signature

```text
/cost-estimate <target> [--kind <target-kind>] [--out <dir>]
```

- **`<target>`** (required, positional) — **one** target per invocation, matching
  the `cost-estimator` agent's one-target-per-dispatch contract. It is **either**
  a path (to a slicing-record file, a spec file, or a file holding a single slice)
  **or** a quoted string of pasted task text. The command classifies which by
  resolving the positional argument as a filesystem path first: if it resolves to
  a **readable file**, it is a **path** target; otherwise it is **inline task
  text**.
- **`--kind <target-kind>`** (optional) — an explicit `target_kind` hint, one of
  `task-text` | `slicing-record` | `slice` | `spec`. When supplied, the command
  forwards it to the agent as the **explicit dispatch-stated kind** (the agent's
  rule-1 path — no inference-basis line is then required). When absent, the agent
  infers the kind and discloses its inference basis. This is the single flag that
  lets you disambiguate a path the agent might otherwise infer wrongly (e.g. a
  slice fragment that superficially reads as a spec).
- **`--out <dir>`** (optional) — an output-**directory** override; the derived
  `<YYYY-MM-DD>-<target-slug>-estimate.md` filename still applies beneath it
  (§ Output path). The `--near` flag from the slice sketch is **dropped**: the
  agent accepts exactly one target per dispatch, so there is no
  primary-target-plus-neighbour shape; `--kind` replaces it as the disambiguation
  affordance.

The command does **not** itself classify the `target_kind` (that is the agent's
job) and does **not** re-implement the estimation methodology (that is the S1
`cost-estimation` skill, applied by the agent). It only distinguishes **path vs
inline text** so it knows *how to pass* the target to the agent, and forwards any
`--kind` hint as the explicit kind.

## When to use

- A human deciding **whether to run a piece of work through the pipeline at all** —
  the pre-pipeline question the orchestrator gates cannot answer, because they only
  fire once a branch and slicing already exist.
- The cleanest end-to-end exercise of the `cost-estimation` skill + `cost-estimator`
  agent without a full orchestrator run.
- The prospective half of the `/cost-capture` ↔ `/cost-estimate` pair: one records
  what *was* spent (`observability/costs/`); this predicts what *will be* spent.

## Process

The flow, in order. **The human disposition (step 6) precedes the single Write
(step 7).**

### 1. Parse args and resolve the target

Distinguish **path vs inline text** by resolving the positional `<target>` as a
filesystem path:

- Resolves to a **readable file** → a **path** target (passed to the agent as a
  path to read).
- Does **not** resolve → **inline task text** (passed to the agent as an inline
  string).

Capture any `--kind` (the explicit kind) and any `--out` (the directory
override).

### 2. Dispatch the `cost-estimator` agent

Dispatch the read-only `cost-estimator` agent (`agents/cost-estimator.agent.md`),
passing the **one** target, the explicit `--kind` if supplied, and — if the
command knows it — the resolved model id for the agent's `generated_by` branch
(a). **Note:** a slash-command executor has **no** resolved model id to pass, so in
practice **branch (b) is the live path** (the agent reads its routing tier from
`MODEL_ROUTING.md` and records honest `tier:` provenance); branch (a) is reserved
for an **orchestrator dispatcher** that supplies a concrete id. The agent reads its
grounding sources (`MODEL_ROUTING.md`, the latest
`observability/costs/` snapshot if one exists), applies the S1 methodology, and
returns **either** the estimate-record content as a string **or** a `REFUSED:`
string. The agent **does not write** anything.

### 3. Handle `REFUSED:` (no write, no checkpoint)

REFUSED detection uses an **exact, anchored** test, applied **before any
reformatting** of the agent's output: the **untrimmed first line** of the agent's
final message **starts with** the literal `REFUSED:` prefix (leading whitespace
makes the test fail — a real refusal is emitted with no leading whitespace; the
match is first-line-only, never a substring found anywhere in the body). If that
test passes, the command:

- surfaces the refusal reason, the target, and the grounding-read line to the user
  **verbatim**;
- runs **no** validation checkpoint (there is nothing conforming to validate);
- writes **no** file;
- aborts the flow.

This is the dispatcher half of the agent's refusal convention: an
authoritative-looking estimate record is never written for a target the agent
could not honestly ground. **An empty `observability/costs/` is NOT a refusal** —
the agent returns a valid, complete **cost-omitted** record (see step 5), which
the command treats as a normal emit, not a failure.

### 4. Output Validation Checkpoint

**The checkpoint takes an explicit `mode` input on every invocation** — it is a
structural parameter, never carried by executor memory of authorship:

- **`mode: fix-in-place`** — the content is the **agent's fresh output** (this
  step, on the dispatch and `re-run` paths). Structural-only deviations are
  repaired in place per the boundary below.
- **`mode: validate-and-report`** — the content is **human-edited** (the `edit`
  path, step 6). The checkpoint **validates and reports** remaining deviations but
  applies **no** fix-in-place — a human edit is never reverted unseen.

This step runs in **`fix-in-place`** mode. The `edit` path (step 6) invokes the
checkpoint in **`validate-and-report`** mode explicitly.

Per the CLAUDE.md **Output Validation Checkpoints** convention, **read the
returned record back** and check its structure against the validation checklist in
the format reference, **referenced by path** (do not inline or mutate its
definitions):

```text
ai-literacy-superpowers/skills/cost-estimation/references/estimate-record-format.md
```

Run **every** line of that file's "Validation checklist", including the #377
additions:

1. **Ranges well-formed** — every **present** range (`tokens`, each
   `tokens_by_stage[].tokens`, each `tokens_by_stage[].cost_usd` when present,
   `cost_usd` when present, `agent_compute_time`) has `low ≤ high`.
2. **Per-stage cost coupling (#377)** — if **any** `tokens_by_stage[].cost_usd` is
   present, the top-level `cost_usd` must also be present. A record with no
   per-stage bands passes **vacuously**; the check forbids only the incoherent
   inverse.
3. **Split-tier strict-spread (#377)** — for **every present**
   `tokens_by_stage[].cost_usd` whose `model_tier` **contains a `/`** (the closed
   split-tier trigger, after join-key whitespace normalisation), the band must
   have a strict ordered spread (`low < high`). A collapsed band on a split-tier
   stage fails; single-tier stages are exempt; a record with no per-stage bands
   passes vacuously.
4. **All four disclosure sections present** — Included, Excluded, Confidence
   rationale, Failure direction.
5. **Per-axis confidence within cap** — each present `tokens`/`time` axis is within
   the `target_kind` ceiling (`task-text`→`low`, `slicing-record`/`slice`→`medium`,
   `spec`→`high`); the `cost` axis is present **iff** `cost_usd` is present and is
   **not** capped by `target_kind`.
6. **Cost pairing** — `cost_usd` and `cost_basis` are **both present or both
   absent**; when absent, `Excluded` carries the cost-omission disclosure.
7. **Time split** — both time fields present and separate: `agent_compute_time` a
   `{ low, high }` range, `human_gate_time` a qualitative caveat string (not a
   range).
8. **No-verdict, field-absence layer** — no `recommendation`, `verdict`, or
   `proceed` field in the frontmatter.
9. **No-verdict, positive-content layer** — the disclosure prose contains no
   imperative recommendation or go/no-go language (the format reference's tripwire
   pattern list).

The checkpoint **never re-dispatches the agent** and runs **before** the human
disposes, so the human reviews a *validated* record.

#### The fix-in-place boundary — structural-only, never authoring derived judgment

"Fix in place" is bounded at **structural-only vs derived-value** so the checkpoint
can never silently alter what the human disposes over:

- **STRUCTURAL-ONLY → fix in place, and record the change.** The checkpoint MAY
  repair a deviation that is purely *structural* and *unambiguous* — one whose
  correction invents **no** value the agent did not emit. **In practice the only
  routinely-fixed line is #8: delete a stray `recommendation`/`verdict`/`proceed`
  field** — a pure removal that authors nothing. (Also permitted: a join-key
  whitespace normalisation already defined by the format reference, or a
  YAML-shape-only fix that does not change a number, a tier, or a confidence
  label.) Every such fix is **recorded** and surfaced in the review summary's
  change-list (step 5).

  **Pre-classification test for the #8 FIX (apply BEFORE choosing FIX vs ABORT).**
  The #8 deletion-fix is licensed **only** when the offender is a **top-level YAML
  key in the frontmatter whose name is literally one of `recommendation`,
  `verdict`, `proceed`** — a *frontmatter field*, not prose. A **verdict phrased
  inside disclosure prose** (e.g. a go/no-go sentence inside `failure_direction`)
  is line **#9**, and **ABORTS** — the checkpoint never edits the agent's prose.
  Run the test explicitly: *"Is the offending verdict a top-level YAML key named
  `recommendation`/`verdict`/`proceed`? If yes → FIX by deleting that key. If it
  is anywhere in prose → ABORT."* This prevents a prose verdict ("…so do not
  proceed") from routing into FIX and being edited away as if it were a stray
  field.

- **DERIVED-VALUE or AMBIGUOUS → ABORT, never author.** The checkpoint MUST
  **abort without writing** for any deviation whose correction would **create or
  change a derived judgment value**. It never authors a `cost_usd` band, a
  `cost_basis`, a `tokens`/`time` range, a per-axis confidence tier, or a
  `failure_direction`; it never edits disclosure prose to supply a missing
  rationale; it never resolves an ambiguous structural defect by guessing.
  Concretely — a **cost-present record missing `cost_basis`** ABORTS (inserting one
  would author provenance the agent did not state); a **`low > high` range** ABORTS
  (re-ordering or clamping changes a derived number); a **missing disclosure
  section** ABORTS (the checkpoint cannot author the prose); a
  **per-stage-coupling violation** ABORTS; a **collapsed split-tier band** ABORTS;
  a **confidence axis above the ceiling** ABORTS; an **imperative-recommendation
  tripwire hit** ABORTS.

Per-checklist-line disposition on failure:

| # | Checklist line | On failure |
| --- | --- | --- |
| 1 | Ranges well-formed (`low ≤ high`) | **ABORT** — re-ordering/clamping changes a derived number |
| 2 | Per-stage cost coupling | **ABORT** — resolution alters a derived value |
| 3 | Split-tier strict-spread | **ABORT** — widening authors a spread |
| 4 | Four disclosure sections present | **ABORT** — checkpoint cannot author prose |
| 5 | Per-axis confidence within cap | **ABORT** — lowering is a derived-judgment change |
| 6 | Cost pairing (`cost_usd`/`cost_basis` together) | **ABORT** — supplying `cost_basis` authors provenance |
| 7 | Time split (separate fields, right shapes) | **ABORT** — any time-field defect alters or omits a derived value |
| 8 | No-verdict field-absence (stray `recommendation`/`verdict`/`proceed`) | **FIX** — *only* when it is a top-level YAML key of that name (apply the pre-classification test above); delete the forbidden field and record it |
| 9 | No-verdict positive-content (imperative/go-no-go prose) | **ABORT** — checkpoint cannot rewrite the agent's prose |

On any abort, surface the failing checklist line and the reason ("derived-value
defect — the checkpoint does not author the agent's judgment") and write **no
file**. The honest move on a derived-value defect is to surface it and let the
human re-run or abort, **not** to silently complete the agent's record.

### 5. Show the review summary

Show a structured, human-readable summary of the **validated** record — what the
human disposes over:

- **Target + classified `target_kind`.** When the kind was **human-asserted via
  `--kind`**, flag it **prominently as asserted-not-inferred** and state that the
  asserted kind **raised the `tokens`/`time` confidence ceiling** (e.g. to `high`
  for `--kind spec`) **with no agent inference basis**, and ask the human to
  **re-confirm the ceiling they raised** before disposing. When the kind was
  **agent-inferred**, carry the agent's inference-basis line as emitted
  (`classified as <kind> by <signal>`) and show **no** human-asserted flag.
- The **token range** and per-axis confidence.
- The **agent-compute-time range** and the `human_gate_time` qualitative caveat.
- Whether **`cost_usd` is present or omitted**, and — when omitted — the disclosed
  cause. When the `cost-snapshot` grounding entry's `path` **ends in a trailing
  slash** (the directory sentinel for *looked-and-found-nothing*), report it as
  **"no snapshot — cost omitted (directory inspected, no snapshot found)"**, **not**
  as a snapshot grounding. (The command is itself a downstream consumer of
  `grounding_sources`, so it honours the trailing-slash special-case in its own
  summary; it does **not** add a validation-checklist line keying on
  `grounding_sources[].path` shape — that would be a consumer mutating the format
  contract.)
- The **`failure_direction`** with its driver.
- **The resolved output path** (§ Output path) — so the human confirms both
  *content* and *destination* before any write.
- **The change-list (a diff, not a narration).** The command **retains the agent's
  original emitted output** before the checkpoint touches it. When the checkpoint
  changed anything at step 4, show a **diff of the retained original vs the altered
  record** — exactly what the command changed, computed from the captured bytes,
  **not** a self-reported summary of what was changed. (A narrated "I deleted the
  verdict field" without the diff is insufficient: the human disposes over an
  *observed* change, not a *claimed* one.) When the checkpoint changed nothing,
  state **"no checkpoint changes — record as emitted by the agent"**.

> **Residual (recorded):** every cost-omitted record this command persists carries
> the `cost-snapshot` grounding entry with the **unguarded** trailing-slash
> directory sentinel — no validation-checklist line keys on
> `grounding_sources[].path` shape. Any **other** consumer (S4's orchestrator
> fold-in, or a future aggregator counting "how many estimates were grounded in a
> real snapshot") **will silently miscount** that entry as a real grounding unless
> it applies the same trailing-slash test this command applies in its summary. The
> structural fix (a checklist line) is the format-owning slice's deliverable; this
> command records the residual and declines to mutate the contract from a consumer
> seat.

### 6. Ask for disposition

Ask for a disposition from the **full** named vocabulary (not a narrowed
accept/abort):

- **`accept`** — proceed to the write (step 7).
- **`edit`** — open the validated draft in `$EDITOR` (or `vi` if unset). On
  return, **re-invoke the step-4 checkpoint with `mode: validate-and-report`**: it
  **validates** the human-edited content and **reports** any remaining deviation in
  the re-prompt, but applies **NO** fix-in-place to human-edited content (the mode
  input — not executor memory — carries this). **A human edit is never reverted
  without the human seeing and re-confirming it.** If the edited record still
  deviates, the human decides (re-edit, accept where structurally valid, or abort)
  — the human is the final author on the edit path. (The `fix-in-place` mode of
  step 4 applies to the **agent's fresh output**; the edit path passes
  `validate-and-report`, because the content is now the human's.)
- **`re-run`** — **re-dispatch the agent** on the same target as a **full fresh
  dispatch** that **re-reads the grounding sources afresh**, including the
  now-populated `observability/costs/`. So a human who adds a cost snapshot and
  then chooses `re-run` gets a record grounded in the newly-added snapshot. The
  command then re-validates (step 4) and re-summarises (step 5).
- **`abort`** — discard the draft; **no file written**.

**Nothing is persisted until the human returns `accept`.** Steps 2–5 produce and
validate a *returned string* and a *review summary*; the Write at step 7 is the
only persistence and it is **downstream of** the human disposition.

### 7. On `accept` (post-disposition): write once

**Re-evaluate the same-day collision at write time** (not only at the step-5
summary): immediately before the Write, re-check whether the resolved target now
exists. If a file appeared after the step-5 summary — a concurrent
`/cost-estimate` for the same target/day, or a manual drop — **re-disambiguate**
(append the short disambiguator) and report the adjusted path. **Never overwrite an
existing estimate**, even one that materialised during the human's deliberation;
this closes the time-of-check/time-of-use gap between the step-5 snapshot and the
Write.

Then perform the command's **single Write** to the (re-checked) resolved output
path (§ Output path), creating the directory if needed (`mkdir -p`), and confirm
the full written path to the user.

## Output path

The default output home is a **new top-level `cost-estimates/` directory**,
deliberately **outside** the `observability/` tree (the telemetry/actuals root) so
a forward-looking *prediction* is never co-located with captured *actuals* where a
future scan could read it as fact:

```text
cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md
```

- **`cost-estimates/`** — created if it does not exist (`mkdir -p`). It is
  **gitignored by default** (an estimate is a derived, regenerable prediction
  referencing a moving target).
- **`<YYYY-MM-DD>`** — the date the estimate was produced.
- **`<target-slug>`** — for a **path** target, the source filename with its date
  prefix and `.md` extension stripped (e.g. `cost-estimator-pipeline`); for
  **inline task text**, a short kebab-case slug of the first few words. **The slug
  is sanitised to a single safe path segment before use**: lowercased, reduced to
  `[a-z0-9-]` (every other character — path separators, `.`, `..`, whitespace —
  collapsed to `-`), leading/trailing/repeated `-` trimmed, and length-capped
  (≤ 50 chars). The slug is **never a path**: it cannot contain `/` or `..` and so
  cannot move the write target out of the resolved output directory. This closes
  the write-target-injection surface for adversarial inline text or path
  basenames.

**`--out <dir>` overrides the directory only** — the derived
`<YYYY-MM-DD>-<target-slug>-estimate.md` filename still applies beneath it
(mirroring `model-card create`'s `--out` semantics).

**Same-day collision disambiguation applies under BOTH the default directory and
`--out`.** When the derived filename would overwrite an existing same-day estimate,
the command appends a short disambiguator and notes it in the confirm-before-write
summary (step 5), **and re-checks at write time (step 7)** to catch a file that
appeared after the summary. **The command never silently overwrites an existing
estimate**, under the default directory or under `--out`.

## Scope

`/cost-estimate` is a **standalone manual surface** and a **pure consumer** of two
merged contracts — it does **not** redefine either:

- the `cost-estimator` agent (`agents/cost-estimator.agent.md`) — dispatched as
  merged; the command does not re-classify the `target_kind` or duplicate the
  methodology;
- the format reference
  (`skills/cost-estimation/references/estimate-record-format.md`) — its checklist is
  referenced by path and implemented; the command adds no field and changes no
  validation rule.

It does **not** wire into the orchestrator pipeline, add or move a gate, or build
the deferred snapshot-grounded absolute-rate check (a BLOCKING required deliverable
of S6/#373, which also owns first-snapshot capture).
