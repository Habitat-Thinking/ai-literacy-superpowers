# Diagnostic Legibility — S4 — On-demand `/diagnose` command — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-06-01 |
| Status | Diaboli-adjudicated (10 accepted, 1 deferred) |
| Author | claude-opus-4-8[1m] (interactive session with russmiles) |
| Slice | S4 of the parent slicing record at `docs/superpowers/slices/diagnostic-legibility-plugin.md` (lines 74–94, 157–173) |
| Parent issue | [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) (Diagnostic Legibility — S4: Surfacing interface — on-demand human legibility command) |
| Closes | #333. Parent [#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327) closes when S4 ships — S4 is the last slice in the chain. |
| Plugin version target | `diagnostic-legibility` v0.4.0 → v0.5.0 |
| Marketplace listing | Per-plugin `diagnostic-legibility` entry bumps 0.4.0 → 0.5.0 and its `description` is rewritten (O9); top-level `version` stays 0.4.0; `plugin_version` per §9 |
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
issue #327 closes. One thread named in S4's `decision_focus` —
*whether the results are cacheable* (slicing record lines 86–88) — is
**deliberately deferred, not decided**: stateless re-run is the v0.5.0
default and a content-hash cache is future work (§8). The parent closes
with that one sub-decision left open rather than resolved.

## 2. The two interface decisions (fixed inputs)

The decision focus this slice owns — *how the corrected models are
surfaced to a human on demand* — was resolved by the human before
this spec was written. The two decisions are **fixed inputs**, not
open for re-litigation in this spec or its diaboli gate:

### 2.1 Output format — structured markdown report (not interactive session)

`/diagnose <scope>` dispatches the agent in `mode: full`, receives the
`LegibilityModel` YAML, and renders a human-readable report:

- A compact **two-column cross-check summary table** near the top — the
  genuine at-a-glance **side-by-side** of the two collections.
- The model bodies presented as two **stacked** subsections
  (`### Architectural model` then `### Domain model`), one element block
  per element.
- Each element showing its `Q<N>` self-challenge findings and its
  `CC<N>` cross-check findings, grouped by prefix in canonical order.
- The wrapper `cross_check_status` surfaced explicitly.
- A **cross-check summary** section counting the corrections by
  direction (A→D and D→A).

"Side-by-side" names the summary table only; the report body is stacked
(see §5.3). This pins the geometry so the contract word matches the
artefact rather than admitting two divergent legal renderings.

The command is **one-shot, stateless, and cacheable**. It runs the
pipeline once, renders one report, writes it, prints a summary, and
exits. It does **not** open an interactive query session against the
model. (An interactive session was the rejected alternative in the
slice's decision-boundary framing — lines 82–88 of the slicing record.
The single-report contract is simpler to test, simpler to cache, and
matches the `model-card` command precedent.)

### 2.2 Persistence — write file + print summary

The command **prints a summary to the conversation, asks the human to
accept or abort, and on accept writes the full report to a file**. This
mirrors the `model-card` command's confirm-before-write pattern (its
"Ask for disposition" gate at step 7, write "On accept" at step 9): the
human disposes of the rendered report before it lands on disk. It is
**not** a print-only command (the report is durable and re-readable) and
**not** a silent write-only command (the human gets immediate feedback
and a write gate). See §4.8 for the confirm-before-write step.

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
string; the command persists it **only after a human accept/abort
disposition** (§4.8), so the human's disposition gates the write rather
than following it.

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
- **Extension** — `.md`. The report is markdown, not YAML. (The model
  is rendered into human-readable markdown; the raw YAML is **not**
  embedded — see §5.4.)

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

### 4.8 Print the summary and confirm before write

Before any file is written, the command:

1. Prints the conversation summary (§5.6): the **resolved target path**,
   the element counts per collection, the `cross_check_status`, and the
   cross-check correction counts (A→D and D→A). This is the "print a
   summary" half of the persistence decision (§2.2).
2. **Flags an overwrite.** If a file already exists at the resolved
   path, the summary states explicitly that writing will overwrite it
   (named path shown), so a slug-collision or same-day re-run cannot
   silently destroy an earlier report.
3. **Prompts the human to accept or abort.** The report is a
   human-facing artefact; the human sees the rendered result (via the
   summary) and disposes of it before it lands on disk. This is the
   load-bearing accept/abort step the `model-card` precedent makes
   explicit (step 7), and it — not the validation checkpoint (§5.5) — is
   the genuine last line of defence before write.

On **abort**, the command writes nothing, performs no `mkdir`, and
exits. On **accept**, the command proceeds to §4.9.

### 4.9 Write the file (on accept only)

1. `mkdir -p` the resolved output directory.
2. Write the rendered report to the resolved path.

This step runs only after the human accepts at §4.8. The
*agent-emit + dispatcher-persist + human-disposes* architecture
(§3.4) is satisfied by a real pre-write disposition, not a post-hoc
read of an already-written file.

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
- **Correction counts by direction.** A direction's count is the
  **number of elements in that collection carrying at least one `CC<N>`
  entry** ("elements revised") — *not* the raw number of `CC<N>`
  entries. An element that fired two cross-check questions (e.g. `CC1`
  and `CC3`) counts **once**. This single definition is load-bearing:
  it matches the human-facing label ("elements revised") and is what the
  validation checkpoint (§5.5) asserts against the parsed YAML.
  - **A→D corrections** — **architectural** elements carrying ≥1 `CC<N>`
    entry (the architectural element was the subject, challenged by the
    domain collection).
  - **D→A corrections** — **domain** elements carrying ≥1 `CC<N>` entry.
  - The command derives the direction from which collection the
    `CC<N>`-carrying element lives in, per the agent's subject-only
    audit-trail contract (S3 §3.5: `CC<N>` entries are written on the
    subject element only). Side-effect revisions named in a subject's
    prose body are **not** double-counted (there is no `CC<N>` entry on
    the side-effect target).
  - The CC-applied sentinel (`Cross-check applied; no questions
    surfaced changes`) is **not** a `CC<N>` entry and does **not** make
    an element count as revised — it records a clean run, not a change.

Rendered shape:

```markdown
## Cross-check summary

Cross-check ran on both collections.

- A→D corrections (architectural elements revised by the domain frame): <count>
- D→A corrections (domain elements revised by the architectural frame): <count>
```

### 5.3 Cross-check summary table and stacked model bodies

The report's geometry is **pinned** (not left to implementer choice):

1. **A compact two-column cross-check summary table** near the top — the
   genuine at-a-glance **side-by-side**. One column per collection
   (Architectural | Domain), summarising the shape of each side
   (element count, elements revised by cross-check) so a human sees the
   two collections side by side in one place. This table is the only
   part of the report the word "side-by-side" refers to.
2. **The model bodies as two stacked subsections** under a `## Models`
   section: `### Architectural model` first, then `### Domain model`,
   each containing its element blocks. The bodies are **stacked, not
   side-by-side** — wide free-text element blocks render poorly in a
   two-column table, so the side-by-side affordance is carried by the
   summary table (item 1) and the bodies are read top-to-bottom.

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

The geometry above is the contract, not a latitude: a compact
two-column **summary table** (the side-by-side) plus **stacked**
`### Architectural model` / `### Domain model` bodies with Q/CC grouping
in canonical order under each element. The structural tests (§6) assert
the summary table is present (both columns), both model subsections are
present, and the Q/CC grouping and ordering are present. (Resolved from
the prior open question via the spec-mode diaboli gate, O7 accepted: the
contract word "side-by-side" is reserved for the summary table so it
matches the artefact, and the body geometry is pinned rather than left
to implementer choice.)

### 5.4 No embedded raw-YAML appendix

The report does **not** embed the raw `LegibilityModel` YAML. The only
purpose such an appendix would serve is a `mode: cross-check-only`
round-trip, and S4 names no consumer for that round-trip
(`cross-check-only` stays off `/diagnose`, §3.3; the `--from` re-render
mode is explicitly future work, §8). Embedding a second copy of the
model only invites prose/YAML drift for no current benefit. (Resolved
from the prior open question via the spec-mode diaboli gate, O8
accepted: the appendix defaults **off** / omitted. If a `--from` /
re-render consumer is ever added, embedding the YAML can be revisited
then.)

### 5.5 Validation checkpoint checks

Before the confirm-before-write gate (§4.8), the command reads the
rendered report back and checks its structure against §5 (per CLAUDE.md
"Output Validation Checkpoints"). The checkpoint's scope is deliberately
**narrow**: it verifies only what it can genuinely check against the
parsed agent YAML. It is **not** an independent oracle for renderer
correctness — a self-consistent renderer that mis-buckets a note would
mis-bucket it identically on re-read, so the checkpoint cannot catch
renderer mis-bucketing. The genuine last line of defence is the human
**accept gate** (§4.8), not this checkpoint. The checkpoint verifies:

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
   values, and reports both A→D and D→A correction counts, with each
   count **consistent with the parsed YAML under §5.2's
   elements-revised definition** (number of elements in that collection
   carrying ≥1 `CC<N>` entry).
4. **Both collections rendered** — every element in `architectural[]`
   and `domain[]` from the parsed YAML appears in the report (matched
   by `name`); element count in the report equals element count in the
   YAML for each collection.
5. **Q/CC ordering present** — for every element, any `CC<N>` entries
   render after the `Q<N>` entries (the canonical Self-challenge-then-
   Cross-check order). This asserts the ordering is present; it does
   **not** claim to detect a mis-bucketed entry the renderer placed
   wrongly (see the scope caveat above).
6. **Counts consistent** — the Architectural/Domain element counts in
   the header match the rendered element blocks and the parsed YAML.

Deviations are fixed in place; the agent is **not** re-dispatched
(matching `model-card` step 8). If the YAML cannot be parsed at all
(not a refusal, but malformed YAML), the command surfaces the parse
failure to the human and aborts without writing a partial report.

### 5.6 Conversation summary

At the confirm-before-write gate (§4.8), **before** any write, the
command prints the summary naming the **resolved target path** (and
flagging an overwrite when one would occur), then asks the human to
accept or abort:

```text
Diagnose report ready to write: <resolved target path>
  (this path already exists and will be overwritten)   # only if it exists
Scope: <scope>
Architectural elements: <N>   Domain elements: <M>
Cross-check status: <status>
Corrections: <A→D count> A→D, <D→A count> D→A
Write this report? (accept / abort)
```

On accept, the command writes the file (§4.9) and confirms the written
path. On abort, nothing is written.

## 6. User story and acceptance scenarios

### 6.1 Story — surface the corrected models as a readable report

**As** a developer who wants to understand a codebase scope
**I want** to run `/diagnose <scope>` and receive a readable report —
a side-by-side cross-check summary table over the architectural and
domain models, followed by the two model bodies with their
self-challenge and cross-check findings — and to accept or abort it
before it is written
**So that** I can read the mutually-corrected models without parsing
raw `LegibilityModel` YAML by eye, and dispose of the report before it
lands on disk.

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
Then it documents a two-column cross-check summary table (the side-by-side)
    near the top of the report
And it documents the model bodies as two stacked subsections
    (### Architectural model and ### Domain model)
And it documents grouping each element's challenge_notes by Q<N> then CC<N>
    in that canonical order
And it documents surfacing the cross_check_status (completed,
    skipped_asymmetric, not_run)
And it documents a cross-check summary counting A→D and D→A corrections as
    the number of elements carrying at least one CC<N> entry (elements revised)
```

#### Scenario 5 — the command documents a validation checkpoint

```gherkin
Given the diagnose.md command file
When I read its body
Then it documents an output validation checkpoint that reads the report
    back before the confirm-before-write gate
And the checkpoint verifies no unsubstituted "<DISPATCHER:" placeholder
    remains in the report
And the checkpoint verifies both collections are rendered and the
    Q/CC ordering is present
And the checkpoint fixes deviations in place rather than re-dispatching
    the agent
And the body states the human accept gate (not the checkpoint) is the
    last line of defence before write
```

#### Scenario 5b — the command documents the confirm-before-write gate

```gherkin
Given the diagnose.md command file
When I read its body
Then it documents printing a summary that names the resolved target path
    before any file is written
And it documents flagging when the resolved path already exists and would
    be overwritten
And it documents prompting the human to accept or abort
And it documents that on abort no file is written and no directory is created
And it documents that the write happens only on accept
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
And the marketplace top-level `version` is unchanged (per §9: a per-plugin
    entry's description is part of that plugin's own contract, tracked by
    the entry version, not the top-level listing contract — so rewriting it
    does not bump the top-level version; CI checks only plugin.json ==
    entry version, never the top-level version)
And the diagnostic-legibility entry `description` no longer contains the
    sentence "Human-facing `/diagnose` command lands in a later slice."
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

> **On what the structural layer can and cannot guarantee** (code-mode
> diaboli O1). The structural tests assert that the command file
> *documents* the right tokens, and — where an offline test genuinely
> can — their relative *order* (e.g. the Architectural model section
> precedes the Domain model section; the A→D definition binds to
> "architectural"). They do **not** verify that a live render produces a
> correct artefact — token presence plus documented ordering is the
> ceiling of a Layer 0/1 check. Genuine verification of the rendered
> report's behaviour belongs to the Scenario 9 acceptance contract below
> and to a future Layer 3 behavioural test.

#### Scenario 9 — behavioural acceptance (documentation only, not executed)

These describe what a live `/diagnose` invocation produces. They are
**not** structural tests (they require running the agent). They are the
acceptance contract a future Layer 3 behavioural test or a human
reviewer checks against:

```gherkin
Given a non-trivial scope with both collections populated
When I run /diagnose <scope>
Then a summary naming the resolved target path is printed and I am asked
    to accept or abort before any write
And on accept a report file is written at
    diagnostic-legibility/output/<scope-slug>-legibility-<today>.md
And the report header names the scope, the resolved generated_at, and
    cross_check_status: completed
And the report opens with a two-column cross-check summary table and then
    stacks the architectural and domain model bodies
And each element's Q<N> notes appear before its CC<N> notes
    (self-challenge first, cross-check second)
And the cross-check summary reports the A→D and D→A correction counts as
    elements revised (elements carrying at least one CC<N> entry)
And no "<DISPATCHER:" string appears anywhere in the report

Given a scope where only one collection is populated (asymmetric)
When I run /diagnose <scope>
Then the report header shows cross_check_status: skipped_asymmetric
And the cross-check summary states the cross-check was skipped because
    only one collection was populated
And the populated collection's model subsection still renders with its
    Q<N> self-challenge notes
And the empty collection's model subsection renders as an explicit empty
    section, not an error

Given a scope that yields nothing (empty directory or unresolvable)
When I run /diagnose <scope>
Then the agent emits the (empty scope) sentinel element into architectural[]
    with domain[] empty, which Phase C reads as one populated collection
And the agent therefore emits cross_check_status: skipped_asymmetric
    (the honest asymmetric label for the both-empty case; agent both-empty
    branch is explicit about this value)
And the report renders the single (empty scope) element with its
    description explaining the empty result
And the report header shows cross_check_status: skipped_asymmetric
And on accept a report file is still written

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
| `.gitignore` (repo root) | **Add** `diagnostic-legibility/output/` (O3 accepted). The repo-local default output directory is kept for predictability, but generated reports must never be committed to the repo nor rsynced into the plugin cache (`sync-to-global-cache.sh` sweeps plugin content on every `Stop`). Ignoring the directory closes that operational risk while keeping the convenient repo-relative default. |
| `diagnostic-legibility/agents/diagnostic-legibility.agent.md` | **Add one surgical clause** to the Phase A both-empty branch (O2 accepted): state that the both-empty case emits `cross_check_status: skipped_asymmetric` — the `(empty scope)` sentinel is the one nominally-populated collection, so Phase C reads the one-populated/one-empty shape and emits the honest asymmetric status. This is a behavioural clarification to a v0.4.0 contract already on `main`; it rides along in this S4 PR under the 0.5.0 bump. No other S3 behaviour is touched. **Call out in the CHANGELOG.** |
| `diagnostic-legibility/.claude-plugin/plugin.json` | Bump `version` `0.4.0` → `0.5.0`. Description MAY be tightened to name the `/diagnose` command as the human-facing surface (it currently says "surfaces the mutually-corrected models on demand" — now literally true). |
| `diagnostic-legibility/CHANGELOG.md` | New `## 0.5.0 — 2026-06-01` heading naming the `/diagnose` command, the report format, the write-file-and-print-summary persistence, the `--out` override, and the validation checkpoint. Notes that S4 closes #333 and that parent #327 closes when S4 ships. |
| `.claude-plugin/marketplace.json` | Bump the `diagnostic-legibility` entry in `plugins[]` from `version: "0.4.0"` to `"0.5.0"` **and rewrite that entry's `description`** (O9 accepted, precedent-backed — every prior slice rewrote it; S3 commit `b7c19ea` rewrote the description and bumped the entry version with the top-level version staying 0.4.0). Remove the now-false trailing sentence "Human-facing `/diagnose` command lands in a later slice." and replace it with one terse clause matching the existing style: "The `/diagnose` command surfaces the mutually-corrected models on demand as a readable report." The per-plugin entry `description` is part of **that plugin's own contract** (tracked by the entry `version`), **not** the top-level listing contract — so this rewrite does **not** bump the top-level listing `version`. Top-level `version` therefore stays **0.4.0** (CI checks only `plugin.json` version == entry `version`, never the top-level `version`); `plugin_version` updates to 0.5.0 per §9. |
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
8b. The command body documents the confirm-before-write gate: a summary
    naming the resolved path, an overwrite flag, an accept/abort prompt,
    and "write only on accept / abort writes nothing".
9. The command body names the two-column cross-check summary table
   (side-by-side), the stacked `### Architectural model` /
   `### Domain model` bodies, the Q/CC grouping and ordering,
   `cross_check_status` (all three values), and the A→D/D→A correction
   counts defined as elements carrying ≥1 `CC<N>` entry.
10. Version triplet at 0.5.0: plugin.json, marketplace entry, CHANGELOG
    `## 0.5.0 — 2026-06-01` heading. The marketplace top-level `version`
    is **unchanged** (still 0.4.0). The `diagnostic-legibility` entry
    `description` no longer contains the literal sentence "Human-facing
    `/diagnose` command lands in a later slice." (the entry description was
    rewritten per O9).
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

`diagnostic-legibility/commands/.gitkeep`. No other removals. S4 adds a
command and docs and does not change the **schema**; the agent file
receives one surgical behavioural clarification (the both-empty
`cross_check_status` clause, O2 — see §7.2), which does not alter any
other S3 behaviour.

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
- **Caching/memoisation of reports across runs.** Cacheability was
  named in S4's `decision_focus` (slicing record lines 86–88); it is
  **deliberately deferred, not decided** (O10 accepted). The command is
  stateless and re-runs the pipeline each invocation — stateless re-run
  is the v0.5.0 default. The date-stamped filename means two runs on
  different days produce two files; two runs the same day resolve to the
  same path and the confirm-before-write gate (§4.8) flags the
  overwrite before it happens. A content-hash cache is future work, not
  an S4 decision.
- **A runtime validator for `LegibilityElement` / `LegibilityModel`.**
  Deferred since sub-S2a; S4 does not change the deferral. The
  command's validation checkpoint (§5.5) validates the **rendered
  report**, not the agent's YAML against a schema validator — it
  parses the YAML structurally to render it, and surfaces a parse
  failure, but does not run a formal schema check.
- **Substantive changes to the agent file or the schema template.** S4
  is a surfacing slice. The agent's behaviour (`mode: full`, the
  `LegibilityModel` shape, the refusal contract) is consumed as-is, with
  **one exception**: a surgical clause is added to the agent's
  both-empty branch making the `cross_check_status: skipped_asymmetric`
  value explicit for the empty-scope case (O2 — see §7.2). This is a
  clarification of behaviour the agent already exhibited, not a new
  behaviour, and it touches no other part of the agent or the schema.
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

- **Backwards compatibility.** S4 adds a command and adds one
  clarifying clause to the agent's both-empty branch (O2); it changes no
  agent behaviour and no schema. v0.4.0 dispatchers that invoke the
  agent directly via the Task tool keep working — the agent already
  emitted `skipped_asymmetric` for the empty-scope case; the clause only
  makes that explicit. The `/diagnose` command is purely additive.
- **Version bump.** A new command is a behavioural addition →
  **minor** bump 0.4.0 → 0.5.0 (CLAUDE.md Semantic Versioning:
  "0.MINOR.0 — new skills, agents, commands, or behavioural changes").
  The triplet updates in lockstep: `plugin.json`, the README badge, the
  CHANGELOG heading. The marketplace per-plugin entry's `version` bumps
  to match.
- **Marketplace listing `version` and `plugin_version`.** The top-level
  marketplace `version` is the listing contract; it bumps only when the
  listing contract itself changes (CLAUDE.md Marketplace Versioning). A
  new command inside a plugin is **not** a listing-contract change. The
  `diagnostic-legibility` entry `description` **is** rewritten for S4 (O9
  accepted) — the now-false trailing sentence "Human-facing `/diagnose`
  command lands in a later slice." is removed and replaced with one terse
  clause: "The `/diagnose` command surfaces the mutually-corrected models
  on demand as a readable report." This rewrite does **not** bump the
  top-level `version`, by established precedent: the top-level marketplace
  `version` has been `0.4.0` across S1, S2a, S2b, and S3 and has never
  bumped per slice, yet S3 (commit `b7c19ea`) rewrote this same entry
  `description` substantially and bumped the entry `version`
  `0.3.0` → `0.4.0` with the top-level `version` staying `0.4.0`. The
  CI version-consistency job enforces only that each plugin's
  `plugin.json` version equals its `plugins[]` entry `version`; it does
  **not** check the top-level `version`. A per-plugin entry's
  `description` is part of **that plugin's own contract** (tracked by the
  entry `version`), not the top-level listing contract — so rewriting it
  each slice to reflect new capability is the normal pattern and does not
  bump the top-level listing `version`. This is the standing exception to
  CLAUDE.md's "description change → bump listing version" rule: that rule
  governs the **top-level listing** description/metadata, not a per-plugin
  entry's description. Stated explicitly so the next slice does not
  re-litigate it. The top-level `version` therefore stays **`0.4.0`**;
  only the per-plugin entry `version` (0.5.0) and `plugin_version`
  (0.5.0) move. The `plugin_version`
  pointer is owned by `ai-literacy-superpowers` PRs, not this one; the
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

## 10. Diaboli / cartographer gate outcomes

The spec-mode `/diaboli` gate raised eleven objections
(`docs/superpowers/objections/dl-s4-diagnose-command-design.md`). Ten
were accepted and absorbed into this spec; one (`--out` path
containment) was deferred. The questions originally left open here are
now resolved as follows:

1. **Side-by-side geometry (§5.3) — RESOLVED (O7 accepted).** The
   geometry is pinned: a compact two-column **cross-check summary
   table** (the side-by-side) near the top, then the model bodies as
   two **stacked** `### Architectural model` / `### Domain model`
   subsections with Q/CC grouping in canonical order. "Side-by-side"
   now names the summary table only, so the contract word matches the
   artefact. No longer an implementer choice.
2. **Embedded raw YAML appendix (§5.4) — RESOLVED (O8 accepted).**
   Default **off** / omitted. No S4 consumer for the round-trip;
   revisit only if a `--from` / re-render consumer is added.
3. **Default output directory (§4.3) — RESOLVED (O3 accepted).** The
   repo-local default is kept, and `diagnostic-legibility/output/` is
   added to `.gitignore` (§7.2) so reports are never committed nor
   swept into the plugin cache.
4. **Entry `description` rewrite / listing-version (§9) — RESOLVED (O9
   accepted, precedent-backed).** The entry `description` **is** rewritten
   (the false "lands in a later slice" sentence replaced with a terse
   on-demand-report clause) and the entry `version` bumps 0.4.0 → 0.5.0.
   A per-plugin entry's description is part of that plugin's own contract
   (tracked by the entry version), not the top-level listing contract — so
   the top-level marketplace `version` stays **unchanged** at 0.4.0
   (established across S1–S3; S3 commit `b7c19ea` rewrote this entry
   description and bumped the entry version with the top-level staying
   0.4.0). Only the entry `version` and `plugin_version` move to 0.5.0.
5. **Confirm-before-write gate (new, O1/O4 accepted).** A human
   accept/abort gate (§4.8) now sits between the validation checkpoint
   and the write; it surfaces the resolved path and flags overwrites.
   This restores the load-bearing disposition step the `model-card`
   precedent makes explicit and closes the silent-overwrite risk.
6. **Invocation persistence / observability (§8) — still deferred for
   the cartographer.** S3 §8 named S4 as the natural home for the
   persistence the Phase-C-escalation trigger needs; this spec scopes
   it out to keep S4 a single-report surfacing slice. The cartographer
   may promote "S4 should also persist invocations to a corpus" to a
   follow-up issue rather than fold it in.
7. **`--out` path containment (§3.2) — deferred (O11).** An inherited
   `model-card` pattern with low grounding; the operator supplies the
   path and the §4.8 gate now surfaces it before write. Revisit if a
   repo-containment constraint is ever wanted.

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
