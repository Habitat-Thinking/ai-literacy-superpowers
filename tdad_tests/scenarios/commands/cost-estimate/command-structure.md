---
component: cost-estimate
component_type: command
tier: structural
---

# Scenario: /cost-estimate ships as a dispose-then-write dispatcher — structure and flow

## Given

The `/cost-estimate` command is S3 of the cost-estimator capability
(spec `docs/superpowers/specs/2026-06-11-cost-estimate-command-design.md`).
It is the **human-facing manual dispatcher** for the read-only S2 `cost-estimator`
agent: it parses one target, dispatches the agent, handles a `REFUSED:` output
(writes nothing), runs an **Output Validation Checkpoint** against the S1 format
reference, summarises the validated record for a human disposition, and performs
its **single Write** only after the human returns `accept` — downstream of the
disposition (the AGENTS.md dispose-then-write ordering invariant).

This scenario fixes the structural contract the single command file must satisfy
(spec §4, §5, §6, §7; FR-1, FR-2, FR-4, FR-6, FR-7, FR-8, FR-9, FR-10, FR-16).

## When

The command file at `ai-literacy-superpowers/commands/cost-estimate.md` is read
directly from the filesystem.

## Then

**Frontmatter** (`FR-1`):

- **YAML frontmatter present** with `name: cost-estimate` and a non-empty
  `description` — required by the `All frontmatter has name and description`
  HARNESS constraint. The description frames the command as the prospective
  sibling of `/cost-capture` (estimate a target's tokens/time/cost before it
  runs).

**Signature** (`FR-2`):

- The body documents the signature `/cost-estimate <target> [--kind <target-kind>]
  [--out <dir>]` — one required positional `<target>`, an optional `--kind`, an
  optional `--out`.
- `--near` is **absent** — the S2 agent accepts exactly one target per dispatch,
  so the slice's loose `--near` sketch is dropped.
- `--kind` is documented as accepting the four `target_kind` values
  (`task-text` | `slicing-record` | `slice` | `spec`).

**Dispatch → checkpoint → dispose → write flow** (`FR-4`, `FR-8`, `FR-9`):

- The process documents the flow in this order: **parse/resolve target →
  dispatch the `cost-estimator` agent → handle REFUSED (no write) → Output
  Validation Checkpoint → review summary → ask disposition → on accept, write
  once**.
- The body states the command **dispatches the S2 `cost-estimator` agent** and
  does **not** re-implement the methodology or re-classify the `target_kind`
  itself (it only distinguishes path vs inline text, and forwards any `--kind`).
- The disposition vocabulary is the **full** `accept` / `edit` / `re-run` /
  `abort` (not a narrowed accept/abort).
- The body states the **single Write** occurs **only on `accept`** and
  **after** the human disposition — the dispose-then-write ordering invariant,
  with a cross-reference to the AGENTS.md agent-emit/dispatcher-persist decision.

**Output Validation Checkpoint section** (`FR-6`, `FR-7`):

- The checkpoint section **references**
  `skills/cost-estimation/references/estimate-record-format.md` **by path** and
  does **not** inline or mutate its field/checklist definitions.
- It enumerates the format reference's validation checklist lines, **including
  the #377 per-stage cost coupling and split-tier strict-spread checks**.
- It documents the **structural-fix boundary**: the checkpoint fixes only
  **structural-only** deviations in place (routinely only deleting a stray
  `recommendation`/`verdict`/`proceed` field) and **records every change**;
  it **aborts, never authors**, on any deviation that would create or alter a
  derived value, and it **never re-dispatches** the agent.
- It documents the **edit path** as **validate-and-report** (the post-edit
  checkpoint validates the human's edit and reports remaining deviation but does
  not silently revert it).

**Output home** (`FR-10`):

- The body states the default output home is a top-level **`cost-estimates/`**
  directory (`cost-estimates/<YYYY-MM-DD>-<target-slug>-estimate.md`),
  deliberately **outside** `observability/`, with a `--out` directory override.

## Rubric

This is a Layer 1 structural scenario: every assertion is mechanically checkable
by reading the command file and matching against its frontmatter and body
headings. The scenario passes only when the frontmatter carries
`name: cost-estimate` + a description; the signature is documented with `--kind`
and `--out` and **no** `--near`; the flow documents dispatch → REFUSED-handling →
checkpoint → review-summary → disposition (`accept`/`edit`/`re-run`/`abort`) →
write with the write **after** the disposition; the checkpoint references the S1
format reference by path, enumerates the checklist incl. the #377 lines, and
documents the structural-fix boundary; and the default home is top-level
`cost-estimates/` outside `observability/`.

## Notes

Scope is S3 only. This scenario asserts the command's structural shape; it does
**not** assert anything about the S4 orchestrator fold-in, the S5 T0 ballpark,
the S6 calibration loop, the S2 agent's internals, or the S1 format reference's
content. S3 makes no change to the agent or the format reference.
