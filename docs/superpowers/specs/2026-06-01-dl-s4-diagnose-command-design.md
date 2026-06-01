# Diagnostic Legibility — S4 — On-demand `/diagnose` command — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-01 |
| Status | Draft (pre-diaboli) |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Slice | S4 of the parent slicing record at `docs/superpowers/slices/diagnostic-legibility-plugin.md` (lines 74–94, 157–173) |
| Parent issue | [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) (Diagnostic Legibility — S4: Surfacing interface — on-demand human legibility command) |
| Closes | #333. Parent [#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327) closes when S4 ships — S4 is the last slice in the chain. |
| Plugin version target | `diagnostic-legibility` v0.4.0 → v0.5.0 |
| Marketplace listing | Per-plugin `diagnostic-legibility` entry bumps 0.4.0 → 0.5.0; top-level `version` and `plugin_version` per §9 |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Related work | S1 (scaffold v0.1.0), sub-S2a (schema v0.2.0), sub-S2b (working agent v0.3.0), S3 (cross-check v0.4.0) all shipped. S4 ships the human-facing `/diagnose` command that exercises the full S2+S3 pipeline end-to-end and renders the corrected models as a human-readable report. |

---

## 1. Premise

S3 shipped the cross-check at v0.4.0
([spec](2026-05-29-dl-s3-cross-check-mechanism-design.md)). The
`diagnostic-legibility` agent now takes a codebase scope, builds an
architectural collection and a domain collection of
`LegibilityElement`s, runs the five-question self-challenge (Phase B,
`Q<N>` notes), and cross-checks the two collections against each other
(Phase C, `CC<N>` notes), emitting a `LegibilityModel` YAML block with
a model-level `cross_check_status` wrapper field
(`completed | skipped_asymmetric | not_run`).

Every slice up to and including S3 has deliberately deferred the
**human-facing surface**. At v0.4.0 the agent is dispatched by a bare
`Task`-tool invocation: a human or an orchestrator writes the prompt,
reads the raw YAML back, and is responsible for substituting the
`<DISPATCHER: ...>` placeholders and persisting the file. The
`LegibilityModel` is machine-shaped; reading one as a human means
parsing YAML by eye, grouping `challenge_notes[]` entries by `Q<N>` /
`CC<N>` prefix mentally, and cross-referencing the two collections
against each other manually.

The parent task's stated purpose is *to aid human understanding* — the
corrected models are "surfaced on demand to a human". S4 is the slice
where that surfacing actually happens. The deliverable is the
**`/diagnose` slash-command**: a human types `/diagnose <scope>`, the
command drives the full pipeline (the agent in `mode: full`), and the
human receives a readable report instead of raw YAML.

S4 is the **last slice** in the chain. When it ships, the parent task
("build the agent, then surface it on demand") is complete, and parent
issue #327 closes.

## 2. The two interface decisions (fixed inputs)

The decision focus this slice owns — *how the corrected models are
surfaced to a human on demand* — was resolved by the human before
this spec was written. The two decisions are **fixed inputs**, not
open for re-litigation in this spec or its diaboli gate:

### 2.1 Output format — structured markdown report (not interactive session)

`/diagnose <scope>` dispatches the agent in `mode: full`, receives the
`LegibilityModel` YAML, and renders a human-readable **side-by-side**
report:

- The architectural model and the domain model presented side by side.
- Each element showing its `Q<N>` self-challenge findings and its
  `CC<N>` cross-check findings, grouped by prefix.
- The wrapper `cross_check_status` surfaced explicitly.
- A **cross-check summary** section counting the corrections by
  direction (A→D and D→A).

The command is **one-shot, stateless, and cacheable**. It runs the
pipeline once, renders one report, writes it, prints a summary, and
exits. It does **not** open an interactive query session against the
model. (An interactive session was the rejected alternative in the
slice's decision-boundary framing — lines 82–88 of the slicing record.
The single-report contract is simpler to test, simpler to cache, and
matches the `model-card` command precedent.)

### 2.2 Persistence — write file + print summary

The command **writes the full report to a file AND prints a summary to
the conversation**. This mirrors the `model-card` command's
write-then-confirm pattern. It is **not** a print-only command (the
report is durable and re-readable) and **not** a write-only command
(the human gets immediate feedback without opening the file).

An `--out <dir>` override follows the `model-card` `--out` precedent
(model-cards/commands/model-card.md, step 2). See §4.3 for the default
path and filename convention.

These two decisions are the slice's resolved decision-boundary. The
rest of this spec defines the command contract that implements them.

## 3. The command's contract

### 3.1 Command file location and form

Commands in this repo are markdown files under
`<plugin>/commands/<name>.md` with frontmatter (`name`,
`description`), a Usage block, and a numbered Flow. The structural
precedent is `model-cards/commands/model-card.md`.

S4 adds `diagnostic-legibility/commands/diagnose.md` and removes the
`diagnostic-legibility/commands/.gitkeep` placeholder that has stood
since the v0.1.0 scaffold.

### 3.2 Signature

```text
/diagnose <scope> [--out <dir>]
```

| Arg | Required | Meaning |
| --- | --- | --- |
| `<scope>` | **yes** (positional) | What to model. The same notion of scope the agent already accepts (agent file, Inputs section): a directory path (`./src/auth/`), a file list (`src/checkout/cart.py, src/checkout/order.py`), or a free-text description (`"the checkout flow across services A and B"`). The command does not enforce the form; it passes `<scope>` through to the agent's `scope:` line verbatim. |
| `--out <dir>` | no (optional) | Output **directory** override. The report filename (§4.3) still applies beneath whatever directory is resolved. Mirrors the `model-card --out` precedent: `--out` overrides the directory, not the filename. |

There are no subcommands. `/diagnose` is a single verb, unlike
`/model-card create | seed`. (If a future slice wants a re-render mode
or a list mode, it can add a subcommand without breaking this
signature — but that is out of scope for S4; see §8.)

### 3.3 Mode — always `mode: full`

`/diagnose` always dispatches the agent in `mode: full` (Phase A
construction + Phase B self-challenge + Phase C cross-check). The
`mode: cross-check-only` surface (S3 §2.4) is a round-trip affordance
for a dispatcher that already holds a persisted `LegibilityModel`; it
is **not** exposed through `/diagnose` at v0.5.0. A human invoking
`/diagnose <scope>` wants the full pipeline from scope to report; the
command chooses `mode: full` on their behalf. (This is the "command
chooses for the human" contract the S3 spec §2.4 anticipated.)

### 3.4 Trust boundary

The agent's trust boundary is unchanged (`Read`, `Glob`, `Grep`; no
`Write`/`Edit`/`Bash`). The **command** is the dispatcher and is the
component that performs the single `Write` (the report file) and the
`mkdir -p` for the output directory. This preserves the project's
*agent-emit + dispatcher-persist + human-disposes* architecture
(AGENTS.md ARCH_DECISIONS): the agent stays read-only and emits a
string; the command persists it.

### 3.5 Dispatcher responsibilities the command inherits

Because the command is the dispatcher, it owns the responsibilities
the agent file (§`generated_at` and `generated_by` are
dispatcher-filled) explicitly delegates:

- **Substitute the `<DISPATCHER: ...>` placeholders.** The agent emits
  `generated_at: "<DISPATCHER: ISO 8601 timestamp>"` and
  `generated_by: "diagnostic-legibility / <DISPATCHER: active model
  identifier>"`. The command substitutes both before rendering and
  persisting: the current ISO 8601 timestamp and the active model
  identifier. This same resolved date also supplies the report
  filename's date stamp (§4.3), so the timestamp in the report body
  and the date in the filename are consistent.
- **Persist the report.** The agent does not write files; the command
  does the single `Write`.

This mirrors the `<DISPATCHER: ...>` placeholder discipline the agent
file names: the command is the named dispatcher that the agent's
"future `/diagnose` command" comment (agent file, §`generated_at`)
was written for.

## 4. End-to-end flow

The command's Flow, in the numbered style of
`model-cards/commands/model-card.md`:

### 4.1 Parse args

1. **`<scope>`** — required positional. If absent, the command
   surfaces a usage error (`/diagnose requires a <scope> argument`)
   and aborts with no agent dispatch and no file written.
2. **`--out <dir>`** — optional directory override.

### 4.2 Resolve scope

The command does not resolve or validate the scope itself — it passes
`<scope>` through to the agent's `scope:` line. The agent inspects the
scope with `Glob`/`Grep`/`Read` and decides what is in it. An
unresolvable scope is **not** a command-level error: the agent handles
it by emitting the `(empty scope)` sentinel (§6, edge case 4). The
command therefore does no filesystem stat on `<scope>` before
dispatch. (Rationale: the agent already owns the three scope forms and
the empty-scope contract; duplicating scope validation in the command
would split the contract.)

### 4.3 Resolve output path

The default output path:

```text
diagnostic-legibility/output/<scope-slug>-legibility-<YYYY-MM-DD>.md
```

- **Directory** — default `diagnostic-legibility/output/`. Overridden
  by `--out <dir>` (highest priority). The directory is created with
  `mkdir -p` at write time (§4.7) if it does not exist; a missing
  `--out` directory is **not** an error (§6, edge case 5).
- **`<scope-slug>`** — a filesystem-safe slug derived from `<scope>`:
  lowercase, non-alphanumeric runs collapsed to single hyphens, leading
  and trailing hyphens trimmed. `./src/auth/` → `src-auth`;
  `"the checkout flow across services A and B"` →
  `the-checkout-flow-across-services-a-and-b`. If the slug is empty
  after trimming (pathological scope), fall back to the literal slug
  `scope`.
- **`<YYYY-MM-DD>`** — the date the command resolved when substituting
  the `generated_at` placeholder (§3.5). The command supplies it,
  mirroring the `<DISPATCHER: ...>` placeholder discipline; the agent
  never supplies a date. The report body's `generated_at` ISO 8601
  timestamp and the filename's `<YYYY-MM-DD>` are derived from the same
  resolved instant.
- **Extension** — `.md`. The report is markdown, not YAML. (The raw
  YAML is rendered into the report; see §5.4 for whether the YAML is
  also embedded.)

The full filename convention is therefore
`<scope-slug>-legibility-<YYYY-MM-DD>.md`.

### 4.4 Dispatch the agent in `mode: full`

Dispatch the `diagnostic-legibility` agent via the `Task` tool:

- `subagent_type`: `diagnostic-legibility`
- `description`: a short imperative — e.g. `"Diagnose ./src/auth/"`
- `prompt`: first line `mode: full`, second line `scope: <scope>`,
  passing `<scope>` through verbatim.

The agent returns **one of**:

- A markdown response containing a `LegibilityModel` YAML block, OR
- A single structured refusal line of the form
  `diagnostic-legibility refusal: <reason>.` and **no YAML block**.

### 4.5 Handle a refusal

If the agent's response contains a line matching
`diagnostic-legibility refusal:` and **no** YAML code block, the
command:

1. Surfaces the refusal line **verbatim** to the conversation.
2. **Aborts** the flow — no report is rendered, **no file is
   written**, no `mkdir` is performed.

This mirrors the `model-card` command's `REFUSED:` handling (step 5):
surface the reason verbatim, abort with no file change. The detection
rule is the dispatcher contract S3 codified — "absence of a YAML code
block plus presence of `diagnostic-legibility refusal:`" routes to
error handling (S3 §3.6).

> Note: in `mode: full` the agent's documented precondition violations
> (S3 §3.6 classes b/c — missing fields, unrevised input, unrecognised
> mode) are **not reachable** through `/diagnose`, because the command
> always sends a valid `mode: full` prompt with no supplied YAML
> payload. The refusal path is retained as a defensive contract: if the
> agent ever refuses (e.g. a future precondition), the command degrades
> safely rather than writing a malformed report.

### 4.6 Render the side-by-side report

Parse the `LegibilityModel` YAML and render the report per §5. The
command substitutes the `<DISPATCHER: ...>` placeholders (§3.5) before
rendering, so the report body carries concrete `generated_at` and
`generated_by` values.

### 4.7 Validation checkpoint

Per the CLAUDE.md "Output Validation Checkpoints" convention, before
writing the report the command validates the rendered output against
the report format spec (§5). See §5.5 for the checkpoint's concrete
checks. Deviations are fixed in place — **the agent is not
re-dispatched**.

### 4.8 Write the file

1. `mkdir -p` the resolved output directory.
2. Write the rendered report to the resolved path.

### 4.9 Print the summary

Print a short summary to the conversation (§5.6): the written path, the
element counts per collection, the `cross_check_status`, and the
cross-check correction counts (A→D and D→A). This is the "print a
summary" half of the persistence decision (§2.2).

## 5. The report structure

The report is the human-facing contract. Its structure is defined here
precisely enough that the validation checkpoint (§5.5) and the
structural tests (§6) can assert against it.

### 5.1 Header

```markdown
# Diagnostic Legibility report — <scope>

| Field | Value |
| --- | --- |
| Scope | <scope> |
| Generated at | <resolved ISO 8601 timestamp> |
| Generated by | diagnostic-legibility / <resolved model identifier> |
| Cross-check status | <completed | skipped_asymmetric | not_run> |
| Architectural elements | <N> |
| Domain elements | <M> |
```

The `Cross-check status` row surfaces the wrapper `cross_check_status`
field directly. The two count rows give the human the model's shape at
a glance.

### 5.2 Cross-check summary section

A `## Cross-check summary` section immediately after the header,
presenting the model-level outcome and the correction counts:

- A one-line statement of `cross_check_status` in human terms:
  - `completed` → "Cross-check ran on both collections."
  - `skipped_asymmetric` → "Cross-check was skipped: only one
    collection was populated. The populated collection is still
    self-challenged."
  - `not_run` → "Cross-check did not run (v0.3.0-compatible output or
    field absent)."
- **Correction counts by direction**, derived by counting `CC<N>`
  entries across elements:
  - **A→D corrections** — `CC<N>` entries on **architectural**
    elements (the architectural element was the subject, challenged by
    the domain collection).
  - **D→A corrections** — `CC<N>` entries on **domain** elements.
  - The command derives the direction from which collection the
    `CC<N>`-carrying element lives in, per the agent's subject-only
    audit-trail contract (S3 §3.5: `CC<N>` entries are written on the
    subject element only). Side-effect revisions named in a subject's
    prose body are **not** double-counted (there is no `CC<N>` entry on
    the side-effect target).
  - The CC-applied sentinel (`Cross-check applied; no questions
    surfaced changes`) is **not** counted as a correction — it records
    a clean run, not a change.

Rendered shape:

```markdown
## Cross-check summary

Cross-check ran on both collections.

- A→D corrections (architectural elements revised by the domain frame): <count>
- D→A corrections (domain elements revised by the architectural frame): <count>
```

### 5.3 Side-by-side models

A `## Models` section presenting the two collections side by side. The
canonical rendering is a **two-column layout** — architectural on the
left, domain on the right — with one element per row block. Because
the two collections may differ in length (S3 schema: symmetric size is
not required), the layout pairs by position and leaves the shorter
column blank past its last element.

Each element renders as a sub-block showing:

- `### <name>` (the element name as the block heading)
- `confidence: <low | medium | high>`
- the `description` (free text, multi-paragraph preserved)
- `evidence` — a bullet list of `path` (and `excerpt` when present)
- **`challenge_notes` grouped by prefix**:
  - A **Self-challenge** group — the `Q<N>` entries (and the
    `Challenge applied; no questions surfaced changes` sentinel when
    present).
  - A **Cross-check** group — the `CC<N>` entries (and the
    `Cross-check applied; no questions surfaced changes` sentinel when
    present).
  - The two groups render in that order (self-challenge first,
    cross-check second), matching the agent's canonical-ordering
    invariant (S3 §3.5, §4.3 step 6: `CC<N>` always after `Q<N>`).
  - Empty `challenge_notes[]` renders as an explicit
    "_(challenge not run)_" marker rather than a blank, so the human
    can distinguish "ran cleanly" (sentinel) from "never ran" (empty).

A side-by-side table is the canonical form. A markdown table with wide
free-text cells renders poorly; the implementation MAY instead render
the side-by-side as two adjacent `### Architectural` / `### Domain`
subsections with element blocks under each, provided the report
clearly presents both collections and groups each element's `Q<N>` and
`CC<N>` notes. The structural tests (§6) assert that both collections
appear and that the Q/CC grouping is present, not a specific HTML/table
geometry. (This latitude is deliberate: the load-bearing contract is
"both models visible, notes grouped by prefix", not the exact column
mechanism. The diaboli gate may tighten this; see §10.)

### 5.4 Embedded raw YAML (optional appendix)

The report MAY include a `## Raw model (YAML)` appendix containing the
full `LegibilityModel` YAML block (placeholders substituted), so the
report is a self-contained artefact that a downstream
`mode: cross-check-only` round-trip could consume without re-running
the pipeline. Whether to include it is left to the diaboli gate (§10);
the default proposal is **to include it** as a collapsible appendix,
because it makes the report round-trippable and costs little.

### 5.5 Validation checkpoint checks

Before writing, the command reads the rendered report back and checks
its structure against §5 (per CLAUDE.md "Output Validation
Checkpoints"). The checkpoint verifies:

1. **Header present and complete** — the `# Diagnostic Legibility
   report —` title and the metadata table with all six rows (Scope,
   Generated at, Generated by, Cross-check status, Architectural
   elements, Domain elements).
2. **No unsubstituted placeholders** — the rendered report contains no
   literal `<DISPATCHER:` substring (both placeholders were
   substituted per §3.5). This is the load-bearing check: a report
   that leaks `<DISPATCHER: ...>` to a human has failed the surfacing
   contract.
3. **Cross-check summary present** — the `## Cross-check summary`
   section exists, states one of the three `cross_check_status`
   values, and reports both A→D and D→A correction counts.
4. **Both collections rendered** — every element in `architectural[]`
   and `domain[]` from the parsed YAML appears in the report (matched
   by `name`); element count in the report equals element count in the
   YAML for each collection.
5. **Notes grouped by prefix and ordered** — for every element, any
   `CC<N>` entries render in the Cross-check group, after the
   Self-challenge group; no `Q<N>` entry appears in the Cross-check
   group and vice versa.
6. **Counts consistent** — the Architectural/Domain element counts in
   the header match the rendered element blocks and the parsed YAML.

Deviations are fixed in place; the agent is **not** re-dispatched
(matching `model-card` step 8). If the YAML cannot be parsed at all
(not a refusal, but malformed YAML), the command surfaces the parse
failure to the human and aborts without writing a partial report.

### 5.6 Conversation summary

After writing, the command prints to the conversation:

```text
Diagnose report written: <full path>
Scope: <scope>
Architectural elements: <N>   Domain elements: <M>
Cross-check status: <status>
Corrections: <A→D count> A→D, <D→A count> D→A
```

## 6. User story and acceptance scenarios

### 6.1 Story — surface the corrected models as a readable report

**As** a developer who wants to understand a codebase scope
**I want** to run `/diagnose <scope>` and receive a readable
side-by-side report of the architectural and domain models with their
self-challenge and cross-check findings
**So that** I can read the mutually-corrected models without parsing
raw `LegibilityModel` YAML by eye.

The acceptance scenarios below are written for the project's **TDAD
structural-test layer** (`tdad_tests/tests/
test_diagnostic_legibility_structural.py`). Structural tests are
offline and deterministic (Layer 0/1, no API key) — they assert on the
**existence and shape** of the command file, its frontmatter, the
version-bump triplet, the docs entries, and the documented contract
literals. They do **not** invoke the live agent or execute the
command. Behavioural assertions about a rendered report (that a real
invocation produces the §5 structure) are documented here as
**acceptance documentation**, in the same way S3 documented its agent
behaviour (S3 §6) rather than as executable tests.

#### Scenario 1 — the command file exists with correct frontmatter

```gherkin
Given the merged main on this PR
When I read diagnostic-legibility/commands/diagnose.md
Then the file exists
And its frontmatter parses as strict YAML
And the frontmatter `name` is "diagnose"
And the frontmatter has a non-empty `description`
And the commands/.gitkeep placeholder has been removed
```

#### Scenario 2 — the command documents its signature

```gherkin
Given the diagnose.md command file
When I read its body
Then it documents the signature "/diagnose <scope> [--out <dir>]"
And it names <scope> as required and --out as optional
And it states the default output directory "diagnostic-legibility/output/"
And it states the filename convention "<scope-slug>-legibility-<YYYY-MM-DD>.md"
```

#### Scenario 3 — the command documents the agent dispatch contract

```gherkin
Given the diagnose.md command file
When I read its body
Then it documents dispatching the diagnostic-legibility agent in mode: full
And it documents handling a "diagnostic-legibility refusal:" line by
    surfacing it verbatim and aborting with no file written
And it references the LegibilityModel YAML as the agent's return shape
```

#### Scenario 4 — the command documents the report structure

```gherkin
Given the diagnose.md command file
When I read its body
Then it documents a side-by-side report of architectural vs domain models
And it documents grouping each element's challenge_notes by Q<N> and CC<N>
And it documents surfacing the cross_check_status (completed,
    skipped_asymmetric, not_run)
And it documents a cross-check summary counting A→D and D→A corrections
```

#### Scenario 5 — the command documents a validation checkpoint

```gherkin
Given the diagnose.md command file
When I read its body
Then it documents an output validation checkpoint that reads the report
    back before writing
And the checkpoint verifies no unsubstituted "<DISPATCHER:" placeholder
    remains in the report
And the checkpoint verifies both collections are rendered and the
    Q/CC grouping is present
And the checkpoint fixes deviations in place rather than re-dispatching
    the agent
```

#### Scenario 6 — the command documents the dispatcher placeholder substitution

```gherkin
Given the diagnose.md command file
When I read its body
Then it documents substituting the <DISPATCHER: ISO 8601 timestamp> and
    <DISPATCHER: active model identifier> placeholders before persisting
And it documents that the same resolved date supplies the filename's
    <YYYY-MM-DD> stamp
```

#### Scenario 7 — the plugin version reflects the new command

```gherkin
Given the merged main on this PR
When I read diagnostic-legibility/.claude-plugin/plugin.json
Then the version is "0.5.0"
And the diagnostic-legibility entry in .claude-plugin/marketplace.json
    shows version "0.5.0"
And diagnostic-legibility/CHANGELOG.md has a "## 0.5.0 — 2026-06-01" heading
And the marketplace top-level `version` is unchanged (per §9)
And `plugin_version` tracks the canonical ai-literacy-superpowers
    plugin.json version (per §9)
```

#### Scenario 8 — docs explain and reference the command

```gherkin
Given the merged main on this PR
When I navigate to docs/plugins/diagnostic-legibility/how-to/
Then there is a page documenting how to run /diagnose
And the page documents the signature, the --out flag, the default output
    path, and the report structure
When I navigate to docs/plugins/diagnostic-legibility/reference/
Then there is a reference entry for the /diagnose command and the report
    format
And the existing how-to/invoke-the-agent.md is updated: its forward-link
    note to #333 is replaced with a link to the new /diagnose how-to,
    since the command surface it anticipated now exists
```

#### Scenario 9 — behavioural acceptance (documentation only, not executed)

These describe what a live `/diagnose` invocation produces. They are
**not** structural tests (they require running the agent). They are the
acceptance contract a future Layer 3 behavioural test or a human
reviewer checks against:

```gherkin
Given a non-trivial scope with both collections populated
When I run /diagnose <scope>
Then a report file is written at
    diagnostic-legibility/output/<scope-slug>-legibility-<today>.md
And the report header names the scope, the resolved generated_at, and
    cross_check_status: completed
And the report presents the architectural and domain collections side
    by side
And each element's Q<N> notes appear in a Self-challenge group and its
    CC<N> notes in a Cross-check group, self-challenge first
And the cross-check summary reports the A→D and D→A correction counts
And no "<DISPATCHER:" string appears anywhere in the report
And a summary is printed to the conversation naming the written path

Given a scope where only one collection is populated (asymmetric)
When I run /diagnose <scope>
Then the report header shows cross_check_status: skipped_asymmetric
And the cross-check summary states the cross-check was skipped because
    only one collection was populated
And the populated collection still renders with its Q<N> self-challenge
    notes
And the empty collection renders as an explicit empty section, not an
    error

Given a scope that yields nothing (empty directory or unresolvable)
When I run /diagnose <scope>
Then the agent returns the (empty scope) sentinel element
And the report renders the single (empty scope) element with its
    description explaining the empty result
And cross_check_status is skipped_asymmetric
And a report file is still written

Given the agent returns a "diagnostic-legibility refusal:" line
When I run /diagnose <scope>
Then the refusal line is surfaced to the conversation verbatim
And no report file is written
And no output directory is created
```

## 7. Files to add and modify

### 7.1 New files

| Path | Purpose |
| --- | --- |
| `diagnostic-legibility/commands/diagnose.md` | The `/diagnose` command file. Frontmatter (`name: diagnose`, `description`), Usage, and the numbered Flow per §4. Removes the need for the `.gitkeep` placeholder. |
| `docs/plugins/diagnostic-legibility/how-to/run-the-diagnose-command.md` | How-to guide for `/diagnose`: signature, `--out`, default output path and filename, the report structure, and the asymmetric / empty-scope behaviours. Required by the "new component → how-to guide" convention (CLAUDE.md Docs Site Review). |
| `docs/plugins/diagnostic-legibility/reference/index.md` | Reference quadrant landing page (the first reference-quadrant page for this plugin; the folder is scaffolded now that it has a page). |
| `docs/plugins/diagnostic-legibility/reference/diagnose-command.md` | Reference entry for the `/diagnose` command: the signature, args, defaults, the report format (sections, header rows, grouping rule), and the validation-checkpoint checks. Satisfies the CI "new components have a reference-page entry" expectation. |

### 7.2 Modified files

| Path | Change |
| --- | --- |
| `diagnostic-legibility/commands/.gitkeep` | **Removed.** The placeholder is no longer needed once the command file lands (mirrors the agents/.gitkeep removal at sub-S2b). |
| `diagnostic-legibility/.claude-plugin/plugin.json` | Bump `version` `0.4.0` → `0.5.0`. Description MAY be tightened to name the `/diagnose` command as the human-facing surface (it currently says "surfaces the mutually-corrected models on demand" — now literally true). |
| `diagnostic-legibility/CHANGELOG.md` | New `## 0.5.0 — 2026-06-01` heading naming the `/diagnose` command, the report format, the write-file-and-print-summary persistence, the `--out` override, and the validation checkpoint. Notes that S4 closes #333 and that parent #327 closes when S4 ships. |
| `.claude-plugin/marketplace.json` | Bump the `diagnostic-legibility` entry in `plugins[]` from `version: "0.4.0"` to `"0.5.0"`. Update the entry's `description` to replace "Human-facing `/diagnose` command lands in a later slice." with a statement that the `/diagnose` command now ships. Top-level `version` and `plugin_version` per §9. |
| `README.md` (repo root) | Update the `diagnostic-legibility` badge/table row from `v0.4.0` to `v0.5.0`. |
| `diagnostic-legibility/README.md` | Update the Status section to v0.5.0; mark #333 as shipped and #327 as closed; add `/diagnose` to the Install / usage section; add the command to a new "Available commands" subsection linking the new how-to. |
| `docs/plugins/diagnostic-legibility/index.md` | Update the Status section to v0.5.0; mark #333 shipped and #327 closed; add the `/diagnose` how-to and the reference quadrant to the Quadrant pages list. |
| `docs/plugins/diagnostic-legibility/how-to/invoke-the-agent.md` | Replace the "Note on the invocation surface" forward-link to #333 (lines 8–13) with a link to the new `/diagnose` how-to: the command surface it anticipated now exists. The bare-Task-tool dispatch content stays (it is still the lower-level surface). |
| `tdad_tests/tests/test_diagnostic_legibility_structural.py` | Extend with S4 structural assertions per Scenarios 1–8 (see §7.3). Update the module docstring's "v0.3.0/v0.4.0" framing to include v0.5.0. Update the version-assertion tests from `0.4.0` to `0.5.0` and the CHANGELOG-heading test to `## 0.5.0 — 2026-06-01`. The existing v0.4.0 cross-check string-contract tests stay (the agent file is unchanged by S4). |

### 7.3 New structural tests

A new `TestDiagnosticLegibilityDiagnoseCommand` class (mirroring the
existing `TestDiagnosticLegibilityCrossCheck` class) with offline,
deterministic assertions:

1. `diagnostic-legibility/commands/diagnose.md` exists and
   `commands/.gitkeep` is gone.
2. The command frontmatter parses as strict YAML; `name == "diagnose"`;
   `description` is non-empty.
3. The command body documents the signature
   `/diagnose <scope> [--out <dir>]`.
4. The command body names `mode: full` as the dispatch mode.
5. The command body documents the refusal contract (the literal
   `diagnostic-legibility refusal:` and "surface verbatim / abort / no
   file written").
6. The command body documents the default output path
   `diagnostic-legibility/output/` and the filename convention
   `<scope-slug>-legibility-` … `.md`.
7. The command body documents the `<DISPATCHER:` placeholder
   substitution responsibility.
8. The command body documents an output validation checkpoint and the
   "no unsubstituted `<DISPATCHER:`" check.
9. The command body names the side-by-side report, the Q/CC grouping,
   `cross_check_status` (all three values), and the A→D/D→A correction
   counts.
10. Version triplet at 0.5.0: plugin.json, marketplace entry, CHANGELOG
    `## 0.5.0 — 2026-06-01` heading.
11. The how-to page `run-the-diagnose-command.md` exists; the reference
    page `diagnose-command.md` and the reference `index.md` exist.
12. `invoke-the-agent.md` links to the new `/diagnose` how-to (the #333
    forward-link is resolved).

The existing `test_how_to_links_forward_to_issue_333` assertion (which
requires `#333` to appear as a forward link in invoke-the-agent.md) is
**updated**: #333 is now closed, so the assertion becomes "links to the
diagnose how-to" rather than "links forward to #333". The structural
test file's existing v0.4.0 cross-check assertions are unchanged.

### 7.4 Removed files

`diagnostic-legibility/commands/.gitkeep`. No other removals — S4 adds
a command and docs; it does not change the agent file or the schema.

## 8. Out of scope

- **An interactive `/diagnose` session.** The rejected alternative in
  the slice's decision-boundary (slicing record lines 82–88). S4 ships
  the one-shot report, not a queryable session. Fixed by §2.1.
- **Exposing `mode: cross-check-only` through `/diagnose`.** The
  round-trip affordance stays a bare-Task-tool surface (§3.3). A
  `/diagnose --from <yaml-file>` re-render mode could be added later
  without breaking the §3.2 signature, but no consumer is named for it
  now.
- **Subcommands** (`/diagnose list`, `/diagnose compare`, etc.). The
  `model-card` command has subcommands; `/diagnose` is a single verb at
  v0.5.0. Subcommands can be added later without breaking the
  signature.
- **Caching/memoisation of reports across runs.** The command is
  stateless and re-runs the pipeline each invocation. The date-stamped
  filename means two runs on different days produce two files; two runs
  the same day overwrite. A content-hash cache is a future
  optimisation, not an S4 decision.
- **A runtime validator for `LegibilityElement` / `LegibilityModel`.**
  Deferred since sub-S2a; S4 does not change the deferral. The
  command's validation checkpoint (§5.5) validates the **rendered
  report**, not the agent's YAML against a schema validator — it
  parses the YAML structurally to render it, and surfaces a parse
  failure, but does not run a formal schema check.
- **Changes to the agent file or the schema template.** S4 is purely a
  surfacing slice. The agent (`mode: full`, the `LegibilityModel` shape,
  the refusal contract) is consumed as-is.
- **An orchestrator wrapper.** `/diagnose` is invoked directly by a
  human in Claude Code; no orchestrator agent is built for it.
- **Persisting invocations to a corpus / observability.** The
  observability gap deferred since sub-S2b (the sentinel-only-ratio
  escalation trigger for promoting Phase C to a separate agent) is
  **not** closed by S4. `/diagnose` writes one report per run; it does
  not accumulate a corpus. If that gap is to be closed, it is a
  separate decision after S4. (Noted because S3 §8 named S4 as the
  natural home for invocation persistence — this spec deliberately
  scopes that out to keep S4 a single-report surfacing slice; see §10.)

## 9. Compatibility and rollout

- **Backwards compatibility.** S4 adds a command; it changes nothing in
  the agent or schema. v0.4.0 dispatchers that invoke the agent
  directly via the Task tool keep working. The `/diagnose` command is
  purely additive.
- **Version bump.** A new command is a behavioural addition →
  **minor** bump 0.4.0 → 0.5.0 (CLAUDE.md Semantic Versioning:
  "0.MINOR.0 — new skills, agents, commands, or behavioural changes").
  The triplet updates in lockstep: `plugin.json`, the README badge, the
  CHANGELOG heading. The marketplace per-plugin entry's `version` bumps
  to match.
- **Marketplace listing `version` and `plugin_version`.** The top-level
  marketplace `version` is the listing contract; it bumps only when the
  listing contract itself changes (CLAUDE.md Marketplace Versioning). A
  new command inside a plugin is **not** a listing-contract change, so
  the top-level `version` stays unchanged unless the diaboli gate
  decides the entry's `description` rewrite counts as a metadata change
  warranting a listing bump (§10). The `plugin_version` pointer is
  owned by `ai-literacy-superpowers` PRs, not this one; the
  integration-agent takes `main`'s value verbatim at rebase time,
  mirroring S3 §9 and the pending CLAUDE.md promotion at #339.
- **Cache behaviour.** `sync-marketplace-cache.sh` fires because the
  per-plugin version bump changes `marketplace.json` relative to
  `origin/main`. `sync-to-global-cache.sh` rsyncs the new command file
  into the versioned plugin cache.
- **CI gates.**
  - **Spec-first** — satisfied by this spec being the first commit on
    branch `dl-s4-diagnose-command`.
  - **Version consistency** — `diagnostic-legibility` plugin.json
    (0.5.0) matches its marketplace entry (0.5.0); CHANGELOG heading
    `## 0.5.0 — 2026-06-01` parses to `0.5.0`.
  - **TDAD scenario check** — no-op (workflow scoped to
    `ai-literacy-superpowers/`; the diagnostic-legibility structural
    tests are the deterministic layer, per S3 §8 and #338).
  - **Docs-reference parity** — the new reference page satisfies the
    "new component → reference entry" expectation. Note the workflow's
    plugin scope per #338: if the parity check does not yet cover
    diagnostic-legibility, the reference page is added proactively for
    parity regardless.
  - **Markdown lint / docs-build** — the new how-to and reference pages
    must render cleanly under MkDocs strict build.

## 10. Open questions left for the diaboli / cartographer gates

These are deliberately left open for the spec-mode `/diaboli` and
`/choice-cartograph` gates rather than pre-decided here:

1. **Side-by-side geometry (§5.3).** The spec fixes "both collections
   visible, notes grouped by Q/CC prefix" as load-bearing but leaves
   the exact column mechanism (a markdown table vs adjacent
   subsections) to the implementer. Wide free-text cells render poorly
   in markdown tables; the diaboli gate may decide adjacent
   subsections under `### Architectural` / `### Domain` is the only
   honest "side-by-side" in markdown, or may insist on a true
   two-column table. This is the most likely diaboli target.
2. **Embedded raw YAML appendix (§5.4).** Proposed as a default-on
   collapsible appendix for round-trippability, but left to the gate.
   The objection to weigh: does embedding the YAML duplicate the report
   and invite drift between the rendered prose and the embedded data?
3. **Default output directory (§4.3).** `diagnostic-legibility/output/`
   sits inside the plugin tree. The diaboli gate may prefer a path
   outside the repo (mirroring `model-card`'s
   `~/.claude/model-cards/...` default) so reports are not accidentally
   committed. Counter-argument: a repo-local default makes reports
   reviewable in a PR. Resolve at the gate.
4. **Whether the entry `description` rewrite warrants a listing-version
   bump (§9).** CLAUDE.md says a description change is a
   listing-contract change. The gate decides whether the
   diagnostic-legibility entry's description rewrite is material enough
   to bump the top-level marketplace `version`, or whether it rides
   along with the per-plugin bump as a minor metadata touch.
5. **Invocation persistence / observability (§8).** S3 §8 named S4 as
   the natural home for the persistence that the Phase-C-escalation
   trigger needs. This spec scopes it out to keep S4 a single-report
   surfacing slice. The cartographer may promote "S4 should also
   persist invocations to a corpus" to a follow-up issue rather than
   fold it in.

## 11. References

- Issue [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — this slice.
- Parent issue [#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327) — closes when S4 ships.
- Parent slicing record: `docs/superpowers/slices/diagnostic-legibility-plugin.md` (S4 entry lines 74–94; S4 decision section lines 157–173).
- S3 (cross-check) spec: `docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md`.
- sub-S2b (working agent) spec: `docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md`.
- sub-S2a (schema) spec: `docs/superpowers/specs/2026-05-26-dl-s2a-legibility-element-schema-design.md`.
- Agent contract this command dispatches: `diagnostic-legibility/agents/diagnostic-legibility.agent.md` (`mode: full`, `LegibilityModel` shape, `cross_check_status`, `Q<N>` / `CC<N>` notes, `(empty scope)` sentinel, `diagnostic-legibility refusal:` line).
- Schema: `diagnostic-legibility/templates/legibility-element.md`.
- Command structural precedent: `model-cards/commands/model-card.md` (frontmatter, Usage, Flow, `--out`, REFUSED handling, review summary, validation checkpoint).
- `CLAUDE.md` — Semantic Versioning, Marketplace Versioning, Docs Site Review, Output Validation Checkpoints.
- AGENTS.md ARCH_DECISIONS — *agent-emit + dispatcher-persist + human-disposes*.
- Issue [#338](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/338) — cross-plugin discipline scoping (TDAD-scenario-check, docs-reference-parity scopes).
- Issue [#339](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/339) — `plugin_version` cross-PR coordination rule promotion.
