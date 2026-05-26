# Carpaccio — cadence governor for AI-generated decision streams — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-26 |
| Status | Draft |
| Author | claude-opus-4-7[1m] (interactive session with russmiles) |
| Plugin version target | v0.39.0 (minor — adds new agent, skill, command) |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Related work | Issue #326 (this spec); pattern siblings: `2026-04-19-advocatus-diaboli.md`, `2026-04-27-choice-cartographer.md`; framework discussion at `russmiles/ai-literacy-for-software-engineers#324` |

---

## 1. Premise

Existing harness agents act *retrospectively* on completed artefacts:

- `advocatus-diaboli` challenges a completed spec or implementation.
- `choice-cartographer` maps the decisions a completed spec implies.

What is missing is a discipline that regulates the **rate** at which
proposals arrive at the human at all. The AI generates coherent,
internally-consistent decision streams faster than a human can
meaningfully engage with them. Coherence is a cognitive trap because
disagreement requires holding an alternative, and constructing an
alternative against an internally-consistent structure is more
cognitively expensive than accepting it. Acceptance becomes the path
of least resistance, the decision-making muscle deconditions, and the
next waterfall arrives wider and faster.

The fix is Cockburn's Elephant Carpaccio exercise applied as a harness
discipline: slice the work so thin that each slice is end-to-end
complete, deliberately, almost absurdly small. Pedagogically about
under-estimating how thinly one can slice. Structurally — in
AI-augmented work — about regulating the cadence at which decisions
arrive at the human, so the cognitive budget (the binding constraint,
not the AI's generation rate) is respected.

## 2. Position in the decision-discipline triad

Three agents form the discipline:

- **`carpaccio`** *(new)* — thins the stream (cadence governor).
- `choice-cartographer` — maps each slice's silent choices (decision visibility).
- `advocatus-diaboli` — challenges the slice's content (decision quality).

The human stays in the decision stream because each slice is small
enough to taste.

## 3. Pipeline placement

Carpaccio is **step 0** in the orchestrator pipeline. It runs before
`spec-writer`, against the *raw task description* (issue body or
plain-English task). No spec exists at this point — the slicing
decision happens before any spec ceremony.

```
0.  carpaccio          NEW — slices the task; hard-gates on dispositions
1.  spec-writer        runs against the chosen slice's scope
1a. advocatus-diaboli  spec mode — unchanged
1b. choice-cartographer unchanged
2.  tdd-agent          unchanged
3.  implementers       unchanged
4.  code-reviewer      unchanged
4a. advocatus-diaboli  code mode — unchanged
5.  integration-agent  unchanged
```

When a multi-slice record is approved, the orchestrator dispatches
`spec-writer` against the **progressed slice's scope** rather than the
original task. Accepted slices that are not progressed in this
iteration can be filed as GitHub issues by the orchestrator (with
human approval per slice).

## 4. Trust boundary

Carpaccio mirrors the read-only trust boundary of its triad siblings:
tools restricted to `Read`, `Glob`, `Grep`. The agent cannot write
files, create issues, or modify code. The orchestrator (or the
`/carpaccio` command) writes the slicing record using content the
agent returns; humans fill `disposition` fields inline.

The same cognitive-engagement gate as the rest of the triad: the
boundary is the mechanism. An agent that could fill its own
disposition fields would eliminate the human-cognition gate that
gives the slice its value.

## 5. Slicing record

### 5.1 Path

`docs/superpowers/slices/<task-slug>.md`

A new sibling directory under `docs/superpowers/`, joining
`objections/`, `stories/`, `specs/`, and `plans/`. The slug derives
from the issue branch name when available, otherwise a kebab-cased
task summary.

### 5.2 Frontmatter schema

```yaml
---
task: "#326 — Carpaccio agent: cadence governor"
task_slug: carpaccio-agent
date: 2026-05-26
carpaccio_model: claude-opus-4-7
inseparable: false
progressed_slice: null
slices:
  - id: S1
    title: short imperative description
    scope: what this slice delivers end-to-end
    decision_focus: the primary decision this slice surfaces
    lens_used: decision-boundary
    sequencing_note: optional ordering hint
    disposition: pending
    disposition_rationale: null
    file_as_issue: pending
    issue_url: null
    merged_into: null
---
```

Field semantics:

| Field | Set by | Notes |
| --- | --- | --- |
| `task`, `task_slug`, `date`, `carpaccio_model` | Agent | Identity. |
| `inseparable` | Agent | `true` when slicing would harm correctness. |
| `progressed_slice` | Human | The slice id worked on in this iteration. |
| `slices[].id` … `lens_used`, `sequencing_note` | Agent | Slice content. |
| `disposition` | Human | `accepted | merged | dropped | revised`. |
| `disposition_rationale` | Human | Required when `disposition` is not `accepted`. |
| `file_as_issue` | Human | `true | false` for `accepted` slices that are not the progressed slice. |
| `issue_url` | Orchestrator | Filled after `gh issue create` succeeds. |
| `merged_into` | Human | Other slice id; only when `disposition: merged`. |

### 5.3 Prose body

For each slice: `## S<N> — <title> — <lens>` containing four
subsections:

- **Context** — what the slice delivers end-to-end.
- **Decision content** — what the human will engage with for this slice.
- **Dependencies** — what must land before or after.
- **Rationale** — why this slice is cohesive at this granularity.

Plus three closing sections:

- `## Sequencing recommendation` — suggested order, or "any order" if
  independent.
- `## Inseparability rationale` — present *only* when `inseparable:
  true`. The defended argument for why slicing would harm correctness.
- `## Explicitly not slicing on` — at least three dimensions
  considered as slice boundaries but rejected. Forces the agent to
  surface what was considered and discarded.

### 5.4 Slice-count constraints

- Min **1** (inseparable case).
- Max **9**. Selectivity matters; three good slices beat seven
  middling ones.
- Bias toward **3–5** slices for most multi-slice records.

### 5.5 Lens vocabulary

The agent applies five lenses, in this priority order:

1. **`decision-boundary`** *(primary)* — one slice per material
   decision the task would surface.
2. **`acceptance-criterion`** *(fallback)* — one slice per testable
   Given/When/Then.
3. **`end-to-end`** — does each slice ship something observable?
4. **`independence`** — can slices land in any order?
5. **`inseparability`** — when slicing would harm correctness.

`lens_used` on each slice records which lens chose that slice. The
detailed lens charter lives in
`ai-literacy-superpowers/skills/carpaccio/references/slicing-lenses.md`.

## 6. Orchestrator integration

### 6.1 Step 0 flow

1. **Dispatch carpaccio** with the task description (issue body or
   user-supplied text).
2. **Receive** the slicing record content.
3. **Write** to `docs/superpowers/slices/<task-slug>.md`.
4. **Validate** against the validation contract (§7).
5. **Surface to human (HARD GATE — Slice Adjudication):**
   - Show slice count, lens distribution, `inseparable`, each slice's
     title + scope + decision focus.
   - Tell the user to fill `disposition`, `disposition_rationale`,
     `file_as_issue` (where applicable), and `progressed_slice`.
   - Refuse to proceed while any `disposition: pending` or any
     required `file_as_issue: pending`.
6. **Re-dispatch loop:** any `disposition: revised` triggers a
   re-dispatch with the rationale string concatenated as context.
   Overwrite the slicing record (mirrors the `/diaboli` and
   `/choice-cartograph` overwrite semantics); warn the user that
   prior dispositions are reset.
7. **Issue creation (after gate clears):** for each slice with
   `disposition: accepted` AND `id != progressed_slice` AND
   `file_as_issue: true`, run `gh issue create`, capture the URL into
   the slice's `issue_url:` field. The slicing record becomes the
   audit trail.
8. **Branch decision:**
   - `inseparable: true` → `spec-writer` runs against the full task,
     as today.
   - Multi-slice → `spec-writer` runs against the **progressed
     slice's `scope`**, not the original task.

### 6.2 Context object additions

```
progressed_slice_id: S<N> | null
carpaccio_slug: <task-slug>
carpaccio_total_slices: N
carpaccio_inseparable: true | false
```

Passed forward to every downstream agent.

### 6.3 Plan-approval surface

The plan-approval gate gains a new structured field
`carpaccio_progressed_slice: S<N>` alongside the existing
`cartograph_pending_count`. Surfaces "this plan covers only slice S2
of 4" so the plan review isn't confused about scope.

### 6.4 What the orchestrator does NOT do

- Does not create issues for `merged` or `dropped` slices.
- Does not auto-pick `progressed_slice`.
- Does not delete the slicing record across iterations.

## 7. Validation contract

Lives in `ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md`
as a single source of truth that both the orchestrator and the
`/carpaccio` command consume.

### 7.1 Frontmatter checks

- `F1` — frontmatter present and parseable.
- `F2` — required top-level fields: `task`, `task_slug`, `date`,
  `carpaccio_model`, `inseparable`, `progressed_slice`, `slices`.
- `F3` — `inseparable` is boolean; `progressed_slice` is `null` or
  matches a slice id.
- `F4` — slice count in `[1, 9]`.
- `F5` — each slice has all required fields (`id`, `title`, `scope`,
  `decision_focus`, `lens_used`, `disposition`, `disposition_rationale`,
  `file_as_issue`, `issue_url`, `merged_into`).
- `F6` — `lens_used` ∈ {`decision-boundary`, `acceptance-criterion`,
  `end-to-end`, `independence`, `inseparability`}.
- `F7` — every slice ships with `disposition: pending`,
  `disposition_rationale: null`, `file_as_issue: pending`,
  `issue_url: null`, `merged_into: null`.
- `F8` — when `inseparable: true`, exactly **1** slice with
  `lens_used: inseparability`.

### 7.2 Prose-body checks

- `P1` — one `## S<N> — <title> — <lens>` heading per frontmatter
  slice, with matching id, title, lens.
- `P2` — each `## S<N>` section contains the four subsections
  (**Context**, **Decision content**, **Dependencies**, **Rationale**).
- `P3` — `## Sequencing recommendation` present.
- `P4` — `## Explicitly not slicing on` present with ≥ 3 entries.
  When `inseparable: true`, `## Inseparability rationale` also
  present.

### 7.3 Error-handling matrix

| Situation | Behaviour |
| --- | --- |
| Validation check fails | Fix in place per the fix-recipe in `validation-checks.md`. Never re-dispatch. |
| Agent returns 0 slices | Treat as `inseparable: true` with a generated default rationale; warn the user. |
| Agent returns > 9 slices | Cap at top 9 by lens priority; warn. |
| `file_as_issue: pending` at gate-check | Refuse to proceed; surface which slice needs it set. |
| `progressed_slice` unset or invalid | Refuse to proceed; tell the user to set it. |
| `gh issue create` fails | Surface error; write partial state with `issue_url: null` for failed ones; do not abort pipeline. |
| Cross-repo task (no GitHub issue available) | Skip `gh` calls; record `issue_url: "skipped (cross-repo)"`. |

## 8. User stories and acceptance scenarios

### 8.1 Story — multi-decision task is sliced before spec-writer runs

**As** a developer kicking off feature work via the orchestrator
**I want** carpaccio to slice the task before any spec is written
**So that** I engage with one decision at a time, not the whole proposal at once.

```gherkin
Given a GitHub issue describing a task with three implied decisions
When the orchestrator dispatches carpaccio in step 0
Then a slicing record is written to docs/superpowers/slices/<task-slug>.md
And the record contains 2 or more slices
And inseparable is false
And every slice has disposition: pending
And the orchestrator refuses to dispatch spec-writer
```

### 8.2 Story — atomic task produces a defended single-slice record

**As** a developer working on an inseparable change (security patch, atomic migration)
**I want** carpaccio to acknowledge inseparability rather than force false slicing
**So that** correctness is preserved and the inseparability claim is recorded.

```gherkin
Given a task description that cannot be safely sliced
When the orchestrator dispatches carpaccio in step 0
Then the slicing record has inseparable: true
And exactly one slice with lens_used: inseparability
And the prose body contains an "## Inseparability rationale" section with substantive content
And the orchestrator still hard-gates on disposition
```

### 8.3 Story — human revises the slicing

**As** a developer who disagrees with carpaccio's proposed slicing
**I want** to push back via a `revised` disposition
**So that** the agent re-slices with my rationale in mind.

```gherkin
Given a slicing record with one or more slices marked disposition: revised
When the orchestrator runs the re-dispatch loop
Then carpaccio is re-dispatched with the revised slices' rationale strings as context
And the prior slicing record is overwritten
And the user is warned that prior dispositions are reset
```

### 8.4 Story — accepted slices become tracked GitHub issues

**As** a developer who accepted four slices and chose S1 to progress now
**I want** the orchestrator to file issues for S2, S3, S4 with my per-slice approval
**So that** the deferred slices are not lost.

```gherkin
Given a slicing record with S1 marked progressed_slice
And S2, S3, S4 with disposition: accepted and file_as_issue: true
When the orchestrator runs step 7 (issue creation)
Then three GitHub issues are created, one per deferred slice
And each slice's issue_url field is updated with the returned URL
And each issue body links back to the parent issue and the slicing record
```

### 8.5 Story — `/carpaccio` invoked manually

**As** a developer not yet ready to start a full orchestrator run
**I want** to invoke `/carpaccio <task-description>` standalone
**So that** I can think about slicing before committing to the pipeline.

```gherkin
Given a task description supplied on the command line
When I run /carpaccio
Then a slicing record is written to docs/superpowers/slices/<task-slug>.md
And the validation checkpoint runs
And I am shown the record and reminded to fill dispositions
And no further pipeline step is invoked
```

## 9. Files to add and modify

### 9.1 New files (inside `ai-literacy-superpowers/`)

| Path | Purpose |
| --- | --- |
| `skills/carpaccio/SKILL.md` | Agent's full charter. |
| `skills/carpaccio/references/validation-checks.md` | Validation contract. |
| `skills/carpaccio/references/slicing-lenses.md` | Detailed lens definitions. |
| `agents/carpaccio.agent.md` | Orchestrator-facing dispatch contract. |
| `commands/carpaccio.md` | `/carpaccio <task>` manual invocation. |
| `tdad_tests/scenarios/agents/carpaccio/*.yaml` | TDAD scenarios (see §10). |

### 9.2 New directory

| Path | Purpose |
| --- | --- |
| `docs/superpowers/slices/` | Slicing records — sibling of `objections/` and `stories/`. |

### 9.3 Modified files

| Path | Change |
| --- | --- |
| `ai-literacy-superpowers/agents/orchestrator.agent.md` | Add **Step 0** before spec-writer. |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | Version `0.38.0` → `0.39.0`. |
| `.claude-plugin/marketplace.json` | Update `plugin_version` to `0.39.0`. |
| `CHANGELOG.md` | New `## 0.39.0 — 2026-05-26` entry. |
| `README.md` | Plugin-version badge update. |
| `docs/plugins/ai-literacy-superpowers/explanation/decision-discipline-triad.md` | New Concepts page — triad and carpaccio's role. |
| `docs/plugins/ai-literacy-superpowers/how-to/slicing-a-task.md` | New How-to page — "Slicing a task with `/carpaccio`". |

## 10. Testing strategy

### 10.1 TDAD scenarios

Authored *before* the agent works, per the discipline introduced by
spec `2026-05-09-orchestrator-tdad-discipline-design.md`. Carpaccio
is a new agent component and qualifies for forward-applicable TDAD.

Minimum scenario set at `tdad_tests/scenarios/agents/carpaccio/`:

| Scenario | What it exercises |
| --- | --- |
| `multi-decision-task.yaml` | Task body with ≥ 3 implied decisions → ≥ 2 slices, `lens_used: decision-boundary`, `inseparable: false`. |
| `atomic-task.yaml` | Task body describing an atomic operation → exactly 1 slice, `inseparable: true`, `lens_used: inseparability`, substantive inseparability rationale. |
| `mixed-independence.yaml` | Task with independent and sequential sub-work → sequencing-recommendation describes ordering; at least one slice with `lens_used: independence`. |
| `vague-task-falls-back.yaml` | Task with no clear decision boundaries → falls back to `acceptance-criterion`. |
| `revise-redispatch.yaml` | Prior slicing record + a `revised` slice → agent regenerates with rationale incorporated. |
| `selectivity-respected.yaml` | Sprawling task that could yield 20+ candidates → caps at ≤ 9; documents what was considered in `## Explicitly not slicing on`. |

### 10.2 Validation-contract self-tests

Fixture slicing records under
`ai-literacy-superpowers/skills/carpaccio/references/test-fixtures/`:

- A fixture that satisfies all checks → passes.
- Fixtures violating each specific check (`F1` through `F8`, `P1`
  through `P4`) → each fails with a clear message pointing at the
  check id.

### 10.3 Verification before completion

Before declaring the work done:

1. Run the full TDAD scenario suite for `carpaccio`.
2. **Meta-recursive test:** invoke `/carpaccio` against the body of
   issue #326 itself; observe the slicing record produced. Output is
   informational, not committed.
3. Standard CI gates (lint, spec-first check, version consistency,
   etc.) green on the PR.

### 10.4 Out of scope at v1

- Orchestrator Step 0 wiring is not unit-tested. The orchestrator
  agent is a markdown contract, observed at integration time.
- `gh issue create` side effect is not mocked.

## 11. Compatibility and rollout

- **Backward compatibility:** existing pipelines that do not go
  through the orchestrator (e.g., manual `/spec-writer` invocation)
  are unaffected. The carpaccio discipline is added to the orchestrator
  flow only; manual flows remain available.
- **Pre-existing slicing records:** none exist. Greenfield directory.
- **Framework reflection:** the framework repo at
  `russmiles/ai-literacy-for-software-engineers` will receive a
  follow-up PR reflecting the agent's existence into Theme #10 or
  #18, per the ticket's guidance. Not in scope for this PR.

## 12. Open questions resolved during brainstorming

| Question | Decision |
| --- | --- |
| Slice heuristic | Decisions primary, scenarios fallback (hybrid). |
| Pipeline position | Step 0, before spec-writer. |
| Atomic-work output | Single-slice record + defended inseparability rationale. |
| Slice execution | Record-only; human drives iteration; orchestrator does issue creation for `file_as_issue: true` slices on human approval. |
| Disposition vocabulary | `accepted | merged | dropped | revised` (four-value). |
| Issue-creation audit trail | Per-slice `file_as_issue` field in the record + `issue_url` filled by orchestrator after creation. |
| Re-dispatch semantics | Overwrite the record on `revised`, matching `/diaboli` and `/choice-cartograph`. |

## 13. References

- Cockburn, A. (2002). *Agile Software Development: The Cooperative Game.* Addison-Wesley.
- Cockburn, A. "Elephant Carpaccio" exercise (Heart of Agile workshop material).
- Issue #326 (this spec).
- `russmiles/ai-literacy-for-software-engineers#324` — framework metaphor-deepening discussion.
- Spec `2026-04-19-advocatus-diaboli-design.md` — pattern sibling.
- Spec `2026-04-27-choice-cartographer.md` — pattern sibling.
- Spec `2026-05-09-orchestrator-tdad-discipline-design.md` — TDAD discipline that applies to this PR.
