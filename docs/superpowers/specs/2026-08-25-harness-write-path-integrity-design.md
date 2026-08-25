# Harness write-path integrity — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #551
**Provenance:** found by running the harness evolution loop end to end for the
first time (#548, PR #550). Every claim below cites an artifact in this
repository: the assay at `harness/assay/2026-08-25T08-08Z-assay.md`, the
superseded record `HDR-2026-08-25-the-periodic-check-suite-stops-at-its-first-failure-and-reports-the-rest-as-nothing`,
and its retirement `HDR-2026-08-25-retire-periodic-check-suite-runner`.
**Scope:** the write path — `/harness-accept`'s target refusal, the compiler's
routing table, and what `/harness-check` verifies.
**Explicitly out of scope:** the cost rule's blind spot, assay supersession, the
missing record of a declined finding, and the metadata-fence truncation in
`/harness-propose`. Each is real, each is recorded in `CHANGELOG.md` under
0.79.0, and each needs its own evidence.

## 1. Problem statement

Accepting a `script-validator` record whose `target` was
`.github/workflows/gc.yml` applied its rule text to that file and left it
invalid YAML. The compiler appends a markdown region — an HTML comment marker, a
heading and a bullet list — to whatever artifact a record names. GitHub Actions
could no longer load the workflow, so the weekly garbage-collection job would not
have run.

`/harness-check` then reported `OK`.

Four defects, in the order they failed:

- **D1** — `/harness-check` validates the corpus, not the artifacts it writes.
  `cmd_check` runs the record validator, computes the compile plan, and compares
  each generated region byte-for-byte against what it would produce. All of that
  passed against an unparseable file.
- **D2** — `script-validator` corrupts its target by construction. Its targets
  are scripts and workflows; the compiler emits only markdown.
- **D3** — the `/harness-accept` refusal for rule text that "does not apply
  cleanly to the target artifact" is a marker check. `compile_plan` verifies the
  target exists and that its `BEGIN`/`END` markers are unambiguous, and has no
  notion of what syntax the file accepts.
- **D4** — a mis-targeted record cannot be corrected. `target` is copied verbatim
  from an append-only assay and `/harness-accept` has no override, so the only
  remedy is supersession.

### Why the tests did not catch it

The two fixed routes — `harness-loop → HARNESS.md` and
`turn-instructions → AGENTS.md` — are both markdown. Only the free-`target`
classifications can name another file type, and nothing in the Phase 2 acceptance
criteria exercises one. The happy path is markdown all the way down.

### The confusion underneath

The retired record's rule text is `HARNESS.md` constraint syntax — `- **Rule**:`,
`- **Enforcement**:`, `- **Tool**:`, `- **Scope**:`. It was always prose meant for
a prose artifact, and it already carried `gc.yml` in its `**Tool**` field.

The assay's finding metadata conflated **the artifact that hosts a rule** with
**the artifact a rule is about**. Those are different things and the schema
already has a place for each.

## 2. Decision — targets host prose; the Tool names the code

**A governance rule is prose about work, so the artifact that hosts it must be one
that can hold prose.** The artifact the rule *concerns* is named in the rule's
`**Tool**` field, which is where the retired record already named `gc.yml`.

Three consequences:

1. **`script-validator` gains a fixed route to `HARNESS.md`.** It joins
   `harness-loop` and `turn-instructions` in the routes table. A rule about a
   validator is still a rule about how work proceeds here, and `HARNESS.md` is
   where those live.
2. **A target that cannot host a markdown region is refused at
   `/harness-accept`**, before anything is written, and by `/harness-compile`
   before it writes.
3. **The refusal names the remedy.** Not "invalid target" but: this rule's text is
   markdown and `<path>` cannot hold it; name a markdown artifact as the target
   and put `<path>` in the rule's `**Tool**` field.

### What "can host prose" means

A target must have a `.md` extension. That covers every artifact governance
actually reaches: `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, agent files
(`<name>.agent.md`), and skill files (`SKILL.md`).

Deliberately an allowlist rather than a denylist of known-bad types. A denylist
answers "is this one of the file types we thought of?", which is the question that
was never asked about `.yml`.

### The alternative considered and rejected

**Teach the compiler comment syntax** — emit `# ` -prefixed regions into YAML,
shell and Python, `// ` into JavaScript. This makes `script-validator` work as its
name suggests and puts the rule beside the code it governs.

Rejected on three grounds. It breaks the guarantee that applied text is
byte-identical to the four-backtick block, because every line must be re-prefixed.
`/harness-check`'s byte comparison would have to learn the inverse transform, so
the check that failed here acquires more to get wrong. And it puts paragraphs of
governance prose into executable files, which is noise at best.

A middle option — refuse by default, allow a comment syntax declared per
extension in `surfaces.yaml` — was also rejected: it builds both mechanisms, and
the declared map becomes another thing that can drift from reality.

## 3. Decision — `/harness-check` verifies its own targets

With targets constrained to markdown, the corruption class is eliminated at
source. The check is therefore **defence in depth, not the primary fix**, and is
scoped accordingly:

`/harness-check` fails when any record it would compile names a target that is
not a permitted prose artifact.

This catches a record that acquired a bad target another way — hand-edited, or
carried in from a corpus written before this change. It does not attempt to parse
arbitrary file types, because after this change it never governs one.

**Superseded and retirement records are exempt**, because `compile_plan` already
skips them. The corpus in this repository contains exactly one record with a
non-markdown target and it is superseded, so this change must not fail the
existing corpus. That is an acceptance criterion, not an assumption.

## 4. D4 — the missing override

With `script-validator` routed, the free-`target` classifications that remain are
`agent-instruction`, `agent-reference`, `regression-test` and `new-agent`. Three
of those four naturally name markdown; `regression-test` is the one that might
reasonably want to name a test file, and under this design it may not.

No `--target` override is added. The refusal now fires at `/harness-accept` before
anything is written, and it names the remedy, so a mis-targeted record is caught
at the gate rather than after the damage. Adding an override would let a human
retarget a rule at the acceptance gate, which quietly moves authorship of the
target from the assay to the approver — a larger change than this defect
justifies, and one that deserves its own evidence.

`regression-test` naming a markdown target is a known consequence and is recorded
here rather than solved.

## 5. Acceptance criteria

- **A1** — accepting a record whose `target` is not `.md` is refused, nothing is
  written, and the record stays `proposed`.
- **A2** — the refusal message names the target, says the rule text is markdown,
  and directs the author to the `**Tool**` field.
- **A3** — `script-validator` routes to `HARNESS.md`; a `script-validator` record
  with no `target` is accepted and applied there.
- **A4** — `/harness-compile` refuses the same case rather than writing.
- **A5** — `/harness-check` exits non-zero when a compilable record names a
  non-markdown target.
- **A6** — the existing corpus passes unchanged: the superseded record with
  `target: .github/workflows/gc.yml` does not fail `/harness-check`, because
  superseded records are not compiled.
- **A7** — Layer-0 coverage for a non-markdown target, both at accept and at
  check, so this cannot regress. This is the criterion Phase 2 never had.
- **A8** — re-running the retired scenario end to end leaves `gc.yml` valid.

## 6. Version

Behaviour change to plugin files: minor bump, `0.79.0` → `0.80.0`, across the
five CI-checked locations named in `CLAUDE.md`.
