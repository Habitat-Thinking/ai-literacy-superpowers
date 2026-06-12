---
title: Estimate a Task's Cost Before It Runs
---
# Estimate a Task's Cost Before It Runs

Get a prospective estimate of a target's **tokens**, **agent-compute
time**, and (when a cost snapshot grounds it) **cost** before you commit
to running the work — the prospective counterpart to `/cost-capture`,
which records what *was* spent.

`/cost-estimate` dispatches the read-only `cost-estimator` agent, which
reads your grounding sources and emits an estimate-record string. The
command validates that record, summarises it, and — only after you
dispose — writes it to disk. The agent never writes; the command owns
the single write, and **your disposition precedes it**.

---

## Prerequisites

- A `MODEL_ROUTING.md` file with its Token Budget Guidance and Agent
  Routing tables (run `/harness-init` or copy from
  `templates/MODEL_ROUTING.md` if you don't have one). Without it the
  agent refuses — there is no honest token grounding to estimate from.
- Optionally, a cost snapshot under `observability/costs/` (produced by
  `/cost-capture`). With **no** snapshot you still get a valid
  **cost-omitted** record — a grounded token + time estimate plus an
  honest "cost not yet knowable", which is the default on most repos.

---

## 1. Run the command against a target

```text
/cost-estimate <target> [--kind <target-kind>] [--out <dir>]
```

`<target>` is **one** target per invocation. Pass either:

- a **path** to a spec file, a slicing record, or a file holding a
  single slice, or
- a quoted string of **pasted task text**.

The command decides which by resolving the argument as a filesystem
path: a readable file is treated as a path; anything else is treated as
inline task text.

```text
/cost-estimate docs/superpowers/specs/2026-06-11-my-feature-design.md
/cost-estimate "Add a rate limiter to the public API with a config flag"
```

---

## 2. Disambiguate the kind (optional)

If a path might be mis-classified — for example a slice fragment that
superficially reads as a full spec — assert the kind explicitly:

```text
/cost-estimate path/to/slice-fragment.md --kind slice
```

`--kind` accepts `task-text` | `slicing-record` | `slice` | `spec`.
An asserted kind raises the tokens/time confidence **ceiling** and
suppresses the agent's inference-basis line, so the review summary
**flags it as human-asserted** and asks you to re-confirm the ceiling
you raised. When you omit `--kind`, the agent infers the kind and
discloses what it classified on.

---

## 3. Choose where the record lands (optional)

By default the record is written to:

```text
cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md
```

`cost-estimates/` is a top-level directory **outside** `observability/`
(an estimate is a prediction, not telemetry) and is **gitignored** as a
derived, regenerable artefact. Pass `--out <dir>` to override the
directory — the derived filename still applies beneath it, so you can
drop an estimate next to a spec under review:

```text
/cost-estimate docs/superpowers/specs/2026-06-11-my-feature-design.md --out docs/superpowers/specs/
```

The command never silently overwrites a same-day estimate for the same
target — under either the default directory or `--out` it appends a
short disambiguator and notes it in the confirm-before-write summary.

---

## 4. Review and dispose

Before anything is written, the command shows a review summary of the
**validated** record: the target and classified kind (with the
human-asserted flag when you used `--kind`), the token range and
confidence, the agent-compute-time range and the `human_gate_time`
caveat, whether cost is present or omitted, the `failure_direction`, the
resolved output path, and — when the validation checkpoint changed
anything — a change-list of exactly what it altered versus the agent's
emitted record.

Then it asks for a disposition:

- **`accept`** — write the record to the resolved path and confirm it.
- **`edit`** — open the draft in `$EDITOR`; on return the command
  validates and reports any remaining deviation but never silently
  reverts your edit (you are the final author on the edit path).
- **`re-run`** — re-dispatch the agent on the same target as a fresh
  read of the grounding sources. Use this after adding a cost snapshot
  to `observability/costs/` so the re-run can ground a cost figure.
- **`abort`** — discard the draft; nothing is written.

Nothing is persisted until you respond `accept`.

---

## What the validation checkpoint does (and does not) do

The command checks the returned record against every line of
`skills/cost-estimation/references/estimate-record-format.md`'s
validation checklist — including the #377 per-stage cost coupling and
split-tier strict-spread checks. It **fixes only structural-only
deviations** in place (in practice, just deleting a stray
`recommendation`/`verdict`/`proceed` field) and records the change. It
**aborts — never authors** — on any deviation that would create or
alter a derived value: a missing `cost_basis`, a `low > high` range, a
missing disclosure section, a confidence axis above the ceiling, or
imperative go/no-go prose. The honest move on a derived-value defect is
to surface it and let you `re-run` or `abort`, not to silently complete
the agent's judgment.

---

## A REFUSED target writes nothing

If the agent cannot honestly ground an estimate — an unreadable target,
or a `MODEL_ROUTING.md` whose tables are absent or unparseable — it
returns a `REFUSED:` string. The command surfaces the refusal reason
verbatim, runs no checkpoint, and writes no file. An empty
`observability/costs/` is **not** a refusal: you get a valid
cost-omitted record instead.

---

## Related

- [Track AI Costs](track-ai-costs.md) — the retrospective sibling,
  `/cost-capture`.
- [Commands reference](../reference/commands.md) — full signature and
  flow for `/cost-estimate`.
