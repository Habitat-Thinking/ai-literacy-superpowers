# Spec: Affordances section + `/harness-affordance add` (sequencing step 3)

**Date**: 2026-06-16
**Author**: Russ Miles + assistant
**Parent design**: `docs/superpowers/specs/2026-04-26-harness-affordances-design.md`
**Driving issue**: #200 (sequencing step 3 of the harness-affordances epic)
**Status**: design — spec-mode `/diaboli` reviewed, all 12 dispositions
adjudicated 2026-06-16 (see Adjudication section); ready for implementation

## Problem

Step 2 (PR #199) shipped the discovery scanner: `/harness-affordance
discover` reads project config and emits a draft affordance inventory to
a gitignored scratch file. But the inventory has no first-class home — no
`## Affordances` section in the harness, and no guided way to promote a
draft entry into it. A scanned draft is a dead end: the human must
hand-copy entries into a section that does not yet exist in the template,
filling governance fields with no guidance.

This step makes the inventory a first-class part of the harness.

## Scope (this spec)

Sequencing step 3 only. Ships:

1. **`templates/HARNESS.md` — new `## Affordances` section.** A top-level
   section, sibling to `## Constraints` and `## Garbage Collection`,
   carrying the schema in HTML comments, a reference to
   `observability/affordance-invocations.json`, and four example entries
   (cli, central-mcp, cli-under-current-user, hook) — exactly the block
   defined in the parent spec (§ "The Affordance Block in HARNESS.md").
2. **`commands/harness-affordance.md` — implement `add <name>`.** Replace
   the "not yet implemented" stub with the guided-annotation flow from the
   parent spec (§ "The `/harness-affordance` command").
3. **`commands/harness-init.md`** — surface the affordances section as a
   selectable feature during init and re-run.
4. **`commands/harness-status.md`** — count affordances in the summary.
5. **Docs** — an explanation page (why the section exists) and a reference
   page (field-by-field schema); update the existing
   `how-to/discover-affordances.md` to cover `add`.
6. Minor version bump (0.53.3 → 0.54.0).

**Out of scope** (later steps, per the parent spec's sequencing): the two
chained constraints (steps 4-5), `/harness-affordance review` + the
staleness GC rule (step 6), the runtime tuple recorder (step 7), and CI
discovery automation (step 8).

## Schema is locked against real scanner output

The parent spec's field schema is reused verbatim — this spec does not
re-derive it. The issue's "waiting for" gate (validate the schema against
what the scanner actually produces) was discharged here: running the step-2
scanner against a synthetic `.claude/settings.local.json` + `.mcp.json`
emits entries with exactly `Mode`, `Identity` (TODO), `Audit trail` (TODO),
`Permission`, and `Last reviewed` (TODO) — the machine-derivable subset of
the schema, with the human-owned governance fields left as placeholders.
The template's example entries therefore match the shape a real `discover`
draft is promoted from.

One known gap, already tracked as **#205** (O8 deferral): the scanner does
not yet emit `hook`-mode entries for shell-wrapper hook commands. The
template still carries a hand-authored hook example so the schema is
documented even where the scanner cannot yet derive it; the `add` flow
supports `Mode: hook` + `Trigger` regardless.

## `add` — resolved open question

The issue asked what `add` should do with no draft from `discover`. The
parent spec already answers it (§ command, `add` step 1): **prompt for
everything from scratch** (Mode, Trigger if `Mode: hook`, Permission) — do
not refuse. A draft, when present in the discovery scratch file, is used as
the starting point. This spec adopts that behaviour; no refuse-and-require-
discover path.

## `add <name>` behaviour

Guided annotation mirroring `/harness-constrain`. Given a name:

1. **Seed.** If the discovery scratch file
   (`.claude/affordance-discovery-<date>.md`) contains an entry whose
   derived name matches `<name>`, use its `Mode` / `Trigger` / `Permission`
   as the starting point. Otherwise prompt for `Mode` (cli / local-mcp /
   central-mcp / hook), `Trigger` (only if `Mode: hook`), and `Permission`.
2. **Identity.** Prompt with the five-value definitions and the
   load-bearing-question framing (`user-sso` / `service-account` /
   `current-user` / `runtime-resolved` / `none`). For `runtime-resolved`,
   require a resolution-chain narrative in Notes.
3. **Audit trail.** Prompt with explicit "`none` is fine and is itself
   governance signal" guidance.
4. **Last reviewed.** Set to today's date automatically (this is a genuine
   first review).
5. **Optional.** Constraint references, Notes.
6. **Validate** before writing:
   - required fields present (`Mode`, `Identity`, `Audit trail`,
     `Permission`, `Last reviewed`);
   - `Trigger` present iff `Mode: hook`;
   - `Permission` pattern actually appears in some settings file (warn, do
     not hard-block, if absent — the affordance may precede the grant);
   - **idempotency:** if an entry with `### <name>` already exists under
     `## Affordances`, edit it in place rather than appending a duplicate.
7. **Write.** Append (or replace) the entry under `## Affordances`,
   creating the section if it is absent.
8. **Suggest** a follow-up `/harness-constrain` pre-filled with the
   affordance name (chained-constraint hook for steps 4-5).

## Validation checkpoint

Per the project's output-validation convention, `add` re-reads the entry it
wrote and checks it against the field schema (required fields, mode/trigger
pairing, date format), fixing deviations in place.

## Acceptance scenarios

1. **Section validates schema.** The template's four example entries each
   carry every required field; the hook example carries `Trigger`; no
   non-hook example carries `Trigger`.
2. **`add` from a draft.** With a matching discovery draft entry, `add
   <name>` seeds Mode/Permission from it, prompts only for the governance
   fields, and writes a complete entry.
3. **`add` from scratch.** With no draft, `add <name>` prompts for
   everything and writes a complete entry.
4. **Idempotent.** Re-running `add <name>` edits the existing entry in
   place; the section never holds two `### <name>` headings.
5. **init re-run.** On an existing project, init offers to add the
   `## Affordances` section without overwriting other sections.
6. **status counts.** `/harness-status` reports the affordance count.

## Functional requirements

- **FR1** `templates/HARNESS.md` carries a `## Affordances` section with
  the schema comments, the invocation-data reference, and the four example
  entries from the parent spec.
- **FR2** `/harness-affordance add <name>` implements the guided flow
  above: seed-or-prompt, governance prompts, auto-dated `Last reviewed`,
  field validation, idempotent write, constraint-chaining suggestion.
- **FR3** `harness-init` treats the affordances section as a selectable
  feature, additive on re-run.
- **FR4** `harness-status` counts affordance entries.
- **FR5** Docs: explanation + reference pages, and the existing how-to
  updated for `add`.

## Adjudication (post-diaboli, 2026-06-16)

Spec-mode `/diaboli` raised twelve objections (record:
`docs/superpowers/objections/affordances-section-and-add-design.md`). All
adjudicated; the binding refinements below supersede the looser wording
above where they conflict, and drive implementation.

- **A1 (O1) — idempotency keys on the Permission pattern, not the heading
  name.** `add` matches/edits the existing `## Affordances` entry whose
  `Permission` field string-equals the new entry's pattern (the parent
  spec's "one affordance per permission pattern" identity). The `### <name>`
  heading is the human's label and may be renamed freely without creating a
  duplicate. This dissolves the scanner-suffix instability (`gh-cli-2` vs
  `gh-cli-3`) and the wrapper-hook rename burden (A10).
- **A2/A6 (O2/O6) — `add` checks three settings files for the permission:**
  `.claude/settings.json`, `.claude/settings.local.json`, and user-level
  `~/.claude/settings.json`. Reading the user layer (where MCP grants
  commonly live) is what keeps warn-not-block honest — it removes the
  false-positive warnings that would otherwise erode the safety signal the
  step-4 blocking constraint depends on. Behaviour stays **warn, not block**
  (an affordance may legitimately precede its grant; this step does not own
  the blocking constraint).
- **A3 (O3) — `harness-init` integration is concrete:** add a sixth
  selectable feature row, **Affordances (default off / opt-in)**, additive on
  re-run; it carries its own placeholder marker like every other section; and
  step-8 validation treats `## Affordances` as **optional** (validated only
  when selected), so existing four-section projects still pass.
- **A4 (O4) — `harness-status` live-counts** `### ` headings under
  `## Affordances` at status time (no new persisted Status field) and adds an
  `Affordances: N declared` line, omitted when the section is absent.
- **A5 (O5) — the Layer 0 test covers the template only.** It validates the
  static example block's field schema and Mode/Trigger pairing. It does
  **not** test `add`'s write logic (model-mediated) — that is covered by the
  `add` validation checkpoint and the manual acceptance scenarios. The Risks
  section's earlier wording is corrected accordingly.
- **A7 (O7) — drop the forward `/harness-constrain` suggestion.** `add` ends
  after the write + validation checkpoint. The constraint-chaining suggestion
  returns in step 4, when the constraints that consume it exist.
- **A8 (O8) — seed from the newest draft.** `add` seeds from the lexically
  last `.claude/affordance-discovery-*.md` (names are date-stamped), matching
  a draft entry by Permission; if none exists or none matches, prompt for
  everything.
- **A9 (O9) — schema-lock claim narrowed.** The scanner output matches only
  the machine-derivable subset (`Mode`/`Permission`); `Identity`/`Audit
  trail`/`Last reviewed` arrive as `TODO` placeholders the human fills. The
  `add` validation checkpoint guards that the placeholder→filled transform
  leaves no residual `TODO` in a required field.
- **A11 (O11) — direct write, human-authored in spirit (user-confirmed).**
  `add` writes the entry into `HARNESS.md` directly. This is consistent with
  the parent's "100% human-authored" invariant *in spirit*: the human invokes
  `add` and dictates every governance field; the command only transcribes
  their answers — no autonomous agent authorship. The emit-for-paste
  alternative (as `discover` uses) was considered and declined for UX parity
  with `/harness-constrain`.
- **A12 (O12) — insertion point fixed.** When `## Affordances` is absent,
  `add` inserts it **after `## Garbage Collection`, before `## Status`**,
  matching the template's section order so init's heading-to-heading boundary
  logic stays stable.

## Risks and mitigations

- **Schema drift between scanner and template.** Mitigated by validating
  the template schema against live scanner output (above) and by an
  acceptance scenario asserting the example entries carry every field.
- **`add` is model-mediated (a command spec, not a script), so it is not
  directly unit-testable.** Mitigated by a Layer 0 test over the *template*
  Affordances block (deterministic: parse the example entries, assert the
  field schema and the mode/trigger pairing) — the static artefact the
  command produces entries against.
- **Permission-existence check too strict.** Mitigated by warning rather
  than hard-blocking when the pattern is absent (an affordance may be
  declared before its permission is granted).
