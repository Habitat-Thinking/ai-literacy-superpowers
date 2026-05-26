# Carpaccio Agent Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the `carpaccio` agent — a cadence governor that slices the raw task description before `spec-writer` runs, completing the decision-discipline triad alongside `advocatus-diaboli` and `choice-cartographer`.

**Architecture:** Read-only agent (Read/Glob/Grep) that produces a structured slicing record at `docs/superpowers/slices/<task-slug>.md`. The orchestrator (or `/carpaccio` command) writes the file; humans fill `disposition` and `file_as_issue` fields; the orchestrator drives `gh issue create` for accepted-but-not-progressed slices. Pipeline step 0 hard-gates on dispositions.

**Tech Stack:** Markdown + YAML frontmatter (agents, skills, commands, TDAD scenarios). Bash + `gh` CLI for orchestrator side effects. No runtime dependencies added.

**Spec reference:** `docs/superpowers/specs/2026-05-26-carpaccio-cadence-governor-design.md`

---

## File structure

```
ai-literacy-superpowers/
├── agents/
│   ├── carpaccio.agent.md                                # NEW
│   └── orchestrator.agent.md                             # MODIFIED (add Step 0)
├── commands/
│   └── carpaccio.md                                      # NEW
├── skills/
│   └── carpaccio/                                        # NEW
│       ├── SKILL.md
│       └── references/
│           ├── slicing-lenses.md
│           └── validation-checks.md
└── .claude-plugin/
    └── plugin.json                                       # MODIFIED (0.38.0 → 0.39.0)

tdad_tests/scenarios/agents/carpaccio/                    # NEW directory
├── multi-decision-task.md
├── atomic-task.md
├── mixed-independence.md
├── vague-task-falls-back.md
├── revise-redispatch.md
└── selectivity-respected.md

docs/
├── superpowers/
│   └── slices/                                           # NEW directory (with .gitkeep)
└── plugins/ai-literacy-superpowers/
    ├── explanation/
    │   └── decision-discipline-triad.md                  # NEW
    └── how-to/
        └── slicing-a-task.md                             # NEW

.claude-plugin/marketplace.json                           # MODIFIED (plugin_version)
CHANGELOG.md                                              # MODIFIED (new entry)
README.md                                                 # MODIFIED (version badge)
```

---

## Phase 1 — TDAD scenarios (RED)

These scenarios are authored *before* the agent exists, per the discipline introduced by spec `2026-05-09-orchestrator-tdad-discipline-design.md`. Frontmatter requires `component`, `component_type`, `tier`, `fixture`. Tier must be one of `structural`, `trigger`, `behavioural`. Anchor format: `tdad_tests/scenarios/agents/spec-writer/creates-spec-with-acceptance-scenarios.md`.

### Task 1: Multi-decision-task scenario

**Files:**
- Create: `tdad_tests/scenarios/agents/carpaccio/multi-decision-task.md`

- [ ] **Step 1: Create the directory**

```bash
mkdir -p tdad_tests/scenarios/agents/carpaccio
```

- [ ] **Step 2: Write the scenario file**

```markdown
---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio slices a multi-decision task

## Given

An empty repository with:

- No `docs/superpowers/slices/` directory
- A minimal `CLAUDE.md`
- A minimal `AGENTS.md`

The agent is invoked with a task description that contains three
clearly distinct decision points:

> *"Add a search feature to the docs site. It needs to (1) index
> the existing pages, (2) expose a search UI in the top nav, and
> (3) ship a relevance ranking that handles synonyms."*

## When

The carpaccio agent runs to completion.

## Then

The agent returns slicing-record content (the orchestrator writes
the file). The returned content must:

- Have frontmatter with `inseparable: false`
- Have `slices` array length ≥ 2 and ≤ 9
- Have at least one slice with `lens_used: decision-boundary`
- Have every slice's `disposition: pending`
- Have every slice's `disposition_rationale: null`
- Have every slice's `file_as_issue: pending`
- Have every slice's `issue_url: null`
- Contain a `## Explicitly not slicing on` prose section with
  ≥ 3 entries

## Rubric

For LLM-as-judge on the assertions that resist exact matching:

- *Do the slices each address a distinguishable decision?* Each
  slice's `decision_focus` should be a concrete decision the
  human will engage with, not a paraphrase of the task.
- *Is each slice's `scope` end-to-end?* The scope should
  describe something a user (or downstream consumer) could
  observe, not an internal step.
- *Is the slicing defensible?* The `## Explicitly not slicing
  on` section should name dimensions actually considered.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

The runner that fulfils this scenario should:

1. Copy the empty-repo fixture to a temp directory
2. Use `claude_agent_sdk.ClaudeSDKClient` to run a
   single-agent session with the carpaccio agent's
   frontmatter as the system prompt and tools list
3. Send the task description above as the user message
4. After the run, parse the returned content as YAML +
   markdown and apply the assertions above
5. For rubric assertions, dispatch a separate "judge"
   model call with the slicing record and the rubric
   criteria
```

- [ ] **Step 3: Commit**

```bash
git add tdad_tests/scenarios/agents/carpaccio/multi-decision-task.md
git commit -m "TDAD scenario — carpaccio slices a multi-decision task"
```

### Task 2: Atomic-task scenario

**Files:**
- Create: `tdad_tests/scenarios/agents/carpaccio/atomic-task.md`

- [ ] **Step 1: Write the scenario file**

```markdown
---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio produces a defended single-slice record for an atomic task

## Given

The agent is invoked with a task description that names an
atomic operation:

> *"Rotate the leaked Honeycomb API token: revoke the existing
> token, generate a replacement, update the secret in the
> deployment pipeline, and audit access logs from the past 24h
> for unauthorised use. All four steps must land together."*

## When

The carpaccio agent runs to completion.

## Then

The returned content must:

- Have frontmatter with `inseparable: true`
- Have `slices` array length exactly `1`
- The single slice has `lens_used: inseparability`
- The prose body contains an `## Inseparability rationale`
  section
- The rationale section is at least three sentences long
- Has every slice's `disposition: pending`
- Contains a `## Explicitly not slicing on` section with
  ≥ 3 entries

## Rubric

- *Does the rationale defend inseparability rather than
  assert it?* The agent must explain *why* slicing would
  harm correctness (e.g., a partially-rotated credential is
  worse than an unrotated one), not just claim it cannot be
  sliced.
- *Did the agent consider alternatives before declaring
  atomicity?* The "Explicitly not slicing on" section should
  reveal what slicing dimensions were considered.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Same runner shape as `multi-decision-task.md`.
```

- [ ] **Step 2: Commit**

```bash
git add tdad_tests/scenarios/agents/carpaccio/atomic-task.md
git commit -m "TDAD scenario — carpaccio produces defended single-slice for atomic task"
```

### Task 3: Mixed-independence scenario

**Files:**
- Create: `tdad_tests/scenarios/agents/carpaccio/mixed-independence.md`

- [ ] **Step 1: Write the scenario file**

```markdown
---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio sequences mixed-independence work

## Given

The agent is invoked with a task description containing both
independent and sequential sub-work:

> *"Add observability to the checkout flow. Three pieces:
> (a) emit a span per checkout step (requires nothing); (b) add
> a Honeycomb board (requires the spans to exist); (c) write a
> runbook explaining the new spans (requires both the spans
> and the board)."*

## When

The carpaccio agent runs to completion.

## Then

The returned content must:

- Have frontmatter with `inseparable: false`
- Have `slices` array length between 2 and 9
- Have at least one slice with `lens_used: independence`
- The `## Sequencing recommendation` section describes a
  concrete order, not "any order"
- Each slice's `sequencing_note` is consistent with the
  recommendation

## Rubric

- *Does the sequencing match the dependency graph?* Slice
  emitting spans should precede the board; the runbook
  should be last.
- *Are dependencies explicit?* Each slice's "Dependencies"
  prose subsection should name what must land first.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Same runner shape as `multi-decision-task.md`.
```

- [ ] **Step 2: Commit**

```bash
git add tdad_tests/scenarios/agents/carpaccio/mixed-independence.md
git commit -m "TDAD scenario — carpaccio sequences mixed-independence work"
```

### Task 4: Vague-task-falls-back scenario

**Files:**
- Create: `tdad_tests/scenarios/agents/carpaccio/vague-task-falls-back.md`

- [ ] **Step 1: Write the scenario file**

```markdown
---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio falls back to acceptance-criterion when decisions are weak

## Given

The agent is invoked with a deliberately vague task description:

> *"Improve the docs page for the install instructions."*

The task has no clear decision boundaries. There is no enumeration,
no choice surface, no obviously material decision.

## When

The carpaccio agent runs to completion.

## Then

The returned content must:

- Have frontmatter with `inseparable: false`
- Have `slices` array length ≥ 1 and ≤ 9
- At least one slice's `lens_used` is `acceptance-criterion`
- No slice has `lens_used: decision-boundary` (or, if any
  do, the prose makes clear why those count as material
  decisions)

## Rubric

- *Does the agent fall back cleanly rather than fabricating
  decision boundaries?* The slices should describe
  acceptance criteria the engineer could test (e.g., "the
  page renders correctly on mobile", "the install command
  is copyable").
- *Did the agent avoid the trap of slicing on file
  boundaries?* "Slicing on files" should appear in
  `## Explicitly not slicing on`.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Same runner shape as `multi-decision-task.md`.
```

- [ ] **Step 2: Commit**

```bash
git add tdad_tests/scenarios/agents/carpaccio/vague-task-falls-back.md
git commit -m "TDAD scenario — carpaccio falls back to acceptance-criterion lens"
```

### Task 5: Revise-redispatch scenario

**Files:**
- Create: `tdad_tests/scenarios/agents/carpaccio/revise-redispatch.md`

- [ ] **Step 1: Write the scenario file**

```markdown
---
component: carpaccio
component_type: agent
tier: behavioural
fixture: empty-repo
---

# Scenario: carpaccio re-dispatch on revised disposition

## Given

The agent is invoked with:

- A task description identical to `multi-decision-task.md`
- A prior slicing record in which two slices were marked
  `disposition: revised` with rationale strings:
  - *"The two indexing slices should be one — they cover
    the same code path."*
  - *"The relevance ranking is a separate concern that
    should land later, not in this iteration."*

## When

The carpaccio agent runs to completion (re-dispatch).

## Then

The returned content must:

- Be a fresh slicing record (the prior one is overwritten
  by the orchestrator, not the agent — the agent just
  returns new content)
- Show evidence the rationale was applied:
  - Fewer slices than the prior record (the two
    indexing slices have been merged or one is renamed
    to cover both)
  - The relevance-ranking work has been deferred (no
    slice covers it, OR it appears as a separate
    deferred slice that the orchestrator could file as
    a follow-up issue)
- Every slice ships with `disposition: pending` (the
  agent never preserves prior dispositions across
  dispatches — this matches the diaboli/cartographer
  pattern)

## Rubric

- *Did the agent treat the rationale as instruction or
  just noise?* The new slicing should observably reflect
  the rationale, not just regenerate from scratch.
- *Did the agent over-correct?* It is acceptable for the
  agent to push back in its slicing decisions (e.g.,
  argue the two indexing slices really are distinct) by
  emitting the same shape — but the prose must
  acknowledge the rationale, not silently ignore it.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

Same runner shape as `multi-decision-task.md`, except the
user message includes both the original task and a
serialised representation of the prior slicing record
with the two `revised` rationale strings.
```

- [ ] **Step 2: Commit**

```bash
git add tdad_tests/scenarios/agents/carpaccio/revise-redispatch.md
git commit -m "TDAD scenario — carpaccio re-dispatch on revised disposition"
```

### Task 6: Selectivity-respected scenario

**Files:**
- Create: `tdad_tests/scenarios/agents/carpaccio/selectivity-respected.md`

- [ ] **Step 1: Write the scenario file**

```markdown
---
component: carpaccio
component_type: agent
tier: structural
fixture: empty-repo
---

# Scenario: carpaccio respects the 9-slice cap

## Given

The agent is invoked with a deliberately sprawling task
description containing ≥ 20 candidate decision boundaries:

> *"Build a new analytics dashboard. Requirements: (1) ingest
> events from Kafka; (2) parse the event schema; (3) validate
> payloads against the schema; (4) write valid events to
> ClickHouse; (5) emit a dead-letter queue for invalid
> payloads; (6) expose a REST API for query; (7) implement
> auth on the REST API; (8) implement rate limiting on the
> REST API; (9) build a React front-end for the dashboard;
> (10) add a date-range picker; (11) add filter controls per
> event type; (12) cache query results; (13) implement
> WebSocket push for real-time updates; (14) build an
> embeddable widget version; (15) write OpenAPI docs;
> (16) build the deployment Helm chart; (17) add OpenTelemetry
> tracing; (18) add Prometheus metrics; (19) emit a
> Honeycomb-compatible event stream; (20) write the runbook."*

## When

The carpaccio agent runs to completion.

## Then

The returned content must:

- Have `slices` array length ≤ 9
- The `## Explicitly not slicing on` section documents
  what was considered and discarded
- The prose for each surviving slice covers a meaningful
  cluster of the 20 listed items (not just one bullet
  per slice)

## Rubric

- *Did the agent compress thoughtfully?* The 9 surviving
  slices should each cover a coherent grouping of the
  20 input bullets — not "one slice per bullet" truncated
  at 9.
- *Did the agent document the compression?* The reasoning
  for grouping should be visible either in slice
  rationales or in the "Explicitly not slicing on" section.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

This is a `tier: structural` scenario — it tests an
invariant (the cap) rather than fine-grained behaviour.
Same runner shape as `multi-decision-task.md`.
```

- [ ] **Step 2: Commit**

```bash
git add tdad_tests/scenarios/agents/carpaccio/selectivity-respected.md
git commit -m "TDAD scenario — carpaccio respects 9-slice cap"
```

---

## Phase 2 — Skill, lenses, validation contract

### Task 7: Write the slicing-lenses reference

**Files:**
- Create: `ai-literacy-superpowers/skills/carpaccio/references/slicing-lenses.md`

Anchor: this file is referenced from SKILL.md. Mirror the format of `ai-literacy-superpowers/skills/choice-cartographer/references/validation-checks.md` (top-level header, one `## <lens-name>` per lens, prose-first).

- [ ] **Step 1: Create the directory**

```bash
mkdir -p ai-literacy-superpowers/skills/carpaccio/references
```

- [ ] **Step 2: Write the file**

```markdown
# Carpaccio slicing lenses

Reference for the lenses the carpaccio agent applies. SKILL.md cites
this file; the agent reads both at dispatch time. Lenses are applied
in priority order: each candidate slice is tested against the lenses
top-down, and the first lens that legitimately fits is recorded as
`lens_used`.

When no lens fits, the candidate is dropped. Padding to meet a count
is forbidden — selectivity is the value, per the SKILL.md non-goals.

## decision-boundary (primary)

A slice falls under this lens when it contains exactly one material
*decision* the human will need to engage with. A decision is material
when an alternative would produce visibly different downstream work —
not a choice between equivalent implementations.

Apply this lens first. If the task surfaces three decisions, three
slices typically result.

*Example:* a task describing "add OAuth login" surfaces decisions about
(a) provider (Google? GitHub? both?), (b) account-linking semantics,
(c) session storage. Three slices under decision-boundary.

## acceptance-criterion (fallback)

A slice falls under this lens when the task does not surface clear
decisions but does surface testable behaviours. One slice per
testable Given/When/Then equivalent.

Fall back to this lens only when decision-boundary cannot legitimately
fit. The agent records the fallback in its reasoning, not via a hidden
flag.

*Example:* a task to "improve the install instructions" has no decision
content but has acceptance criteria (the page renders on mobile, the
install command is copyable, the prerequisites are listed). Each
becomes a slice.

## end-to-end

A modifier lens applied to candidates that have already passed the
primary or fallback test: does this slice ship something observable?
End-to-end here means *from the system's edge to the system's edge for
this slice's scope* — not necessarily user-visible in production.

Reject candidates that are only internal milestones with no observable
output. This is the lens Cockburn's original exercise emphasises.

## independence

A modifier lens applied when multiple slices are present: can any
slice land without blocking any other? When the answer is yes, record
`lens_used: independence` on the slice that exemplifies the property
and surface ordering in `## Sequencing recommendation`.

When slices have dependencies, the `sequencing_note` field captures
ordering and the recommendation section explains it.

## inseparability

The terminal lens. A slice falls under this when slicing further would
harm correctness — atomic migrations, security patches, single-
coherent refactors. When this lens fits, the agent emits exactly one
slice and writes a defended `## Inseparability rationale` section.

The inseparability claim must be argued, not asserted. A rationale of
"this is atomic" is a contract break — the agent must explain *why*
slicing would harm correctness.

## Application order

1. Try **decision-boundary** for each candidate.
2. For candidates that don't fit decision-boundary, try **acceptance-criterion**.
3. Apply **end-to-end** as a filter — drop candidates that are not
   observably complete.
4. Apply **independence** to surface ordering when slices are mixed.
5. If the whole task fails every other lens, apply **inseparability**
   with a defended rationale.

## Anti-patterns

- **Slicing on files.** "One slice per file" is a code-organisation
  cut, not a decision cut.
- **Slicing on layers.** "One slice for the backend, one for the
  frontend" leaves the human with a slice that ships nothing observable.
- **Slicing on commits.** A commit boundary is an implementation
  artefact, not a decision boundary.
- **Slicing on PR reviewability.** "Each slice ≤ 200 LOC" is a
  reviewer-budget heuristic, not a cognitive-budget one.

Record these (and any task-specific anti-patterns) in `## Explicitly
not slicing on`.
```

- [ ] **Step 3: Commit**

```bash
git add ai-literacy-superpowers/skills/carpaccio/references/slicing-lenses.md
git commit -m "Carpaccio reference — slicing lenses"
```

### Task 8: Write the validation-checks reference

**Files:**
- Create: `ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md`

Anchor: closely mirror `ai-literacy-superpowers/skills/choice-cartographer/references/validation-checks.md`.

- [ ] **Step 1: Write the file**

```markdown
# Slicing-record validation checks

Reference for the validation checkpoint applied to slicing records at
`docs/superpowers/slices/<task-slug>.md`. Both `/carpaccio` and the
orchestrator's step 0 import this list as the single source of truth —
do not inline these checks into the command or the orchestrator.
Reference the file by path.

When a check fails, apply the **fix-recipe** in place. Do not
re-dispatch the agent. The 9-slice cap is enforced inside the agent's
reasoning protocol; the validator never receives a cap-overshoot in
normal operation, but F4 catches it if it ever does.

## Frontmatter checks

### F1. YAML frontmatter parseable

The file must open with `---`, contain valid YAML up to a closing
`---`, and the closing line must be reachable.

**Fix-recipe:** none. If the frontmatter is unparseable, fail loudly
with the YAML error message.

### F2. Required top-level fields present

The frontmatter must have all of: `task`, `task_slug`, `date`,
`carpaccio_model`, `inseparable`, `progressed_slice`, `slices`.

**Fix-recipe:** if any scalar field is missing, fail loudly. If
`slices` is missing or empty, fail loudly.

### F3. Top-level field types

- `inseparable` must be a boolean.
- `progressed_slice` must be `null` or a string matching one of the
  slice ids in `slices[].id`.

**Fix-recipe:** if `inseparable` is missing or non-boolean, fail
loudly. If `progressed_slice` does not match an id, fail loudly.

### F4. Slice count

`slices` must have at least 1 entry and at most 9.

**Fix-recipe:** if count > 9, surface a warning and truncate to the
first 9 slices by lens priority (decision-boundary first, then
acceptance-criterion, then end-to-end, then independence, then
inseparability). Document the truncation in the prose body's
`## Explicitly not slicing on` section.

### F5. Each slice has required fields

Every entry must have: `id`, `title`, `scope`, `decision_focus`,
`lens_used`, `disposition`, `disposition_rationale`, `file_as_issue`,
`issue_url`, `merged_into`.

**Fix-recipe:** insert missing scalar fields with default values
(`disposition: pending`, `disposition_rationale: null`,
`file_as_issue: pending`, `issue_url: null`, `merged_into: null`).
Do not invent `id`, `title`, `scope`, or `decision_focus` — fail
loudly if missing.

### F6. lens_used vocabulary

`lens_used` must be one of: `decision-boundary`,
`acceptance-criterion`, `end-to-end`, `independence`,
`inseparability`.

**Fix-recipe:** if an unknown lens is present, fail loudly. The
vocabulary is closed.

### F7. Initial-state contract

Every slice must ship with `disposition: pending`,
`disposition_rationale: null`, `file_as_issue: pending`,
`issue_url: null`, `merged_into: null`. The agent never pre-fills
these. The orchestrator sets `issue_url` *after* the gate clears.

**Fix-recipe:** if any of these is non-default on agent output,
reset to default and surface a warning. The agent should never
pre-fill, but the validator self-heals.

### F8. Inseparability shape

When `inseparable: true`, `slices` must have exactly 1 entry, and
that slice's `lens_used` must be `inseparability`.

**Fix-recipe:** if `inseparable: true` and slice count ≠ 1, fail
loudly. If `inseparable: true` and the single slice's `lens_used`
is not `inseparability`, fail loudly.

## Prose-body checks

### P1. One ## S<N> heading per frontmatter slice

Each frontmatter slice must have a matching `## S<N> — <title> — <lens>`
heading in the prose body. The id, title, and lens must match.

**Fix-recipe:** if a frontmatter slice has no matching heading, fail
loudly. If a heading exists but title or lens disagrees with the
frontmatter, fail loudly.

### P2. Required subsections per slice

Each `## S<N>` section must contain four subsections: **Context**,
**Decision content**, **Dependencies**, **Rationale**. They may use
any heading depth (e.g., `### Context` or `**Context**` bold-emphasis
prose lead).

**Fix-recipe:** if any subsection is missing, fail loudly. Do not
invent content.

### P3. Sequencing recommendation present

A `## Sequencing recommendation` section must be present, even if its
body is just "Any order — slices are independent."

**Fix-recipe:** if missing, append the section with body "Any order
— slices are independent." and surface a warning.

### P4. Explicitly not slicing on present with ≥ 3 entries

A `## Explicitly not slicing on` section must be present and contain
at least three discrete entries (bullets or short paragraphs).

**Fix-recipe:** if the section is missing or has < 3 entries, fail
loudly. This forces the agent to surface what it considered.

### P5. Inseparability rationale when applicable

When frontmatter has `inseparable: true`, the prose body must
contain a `## Inseparability rationale` section with substantive
content (≥ 3 sentences).

**Fix-recipe:** if missing or insubstantial when `inseparable: true`,
fail loudly.
```

- [ ] **Step 2: Commit**

```bash
git add ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md
git commit -m "Carpaccio reference — validation contract"
```

### Task 9: Write SKILL.md

**Files:**
- Create: `ai-literacy-superpowers/skills/carpaccio/SKILL.md`

Anchor: structure mirrors `ai-literacy-superpowers/skills/choice-cartographer/SKILL.md` (Intellectual Foundations, Non-Goals, Routing Rule, Lenses-by-reference, Selectivity Protocol, Output Format, Reasoning Protocol).

- [ ] **Step 1: Write the file**

```markdown
---
name: carpaccio
description: Use when acting as the cadence governor — slices a raw task description into thin, end-to-end-complete pieces before any spec is written; produces a structured slicing record for human disposition; runs at orchestrator step 0
---

# Carpaccio

You are the cadence governor in the decision-discipline triad. Your
charter is to thin the stream of proposals arriving at the human: take
a raw task description and slice it into pieces small enough that the
human can engage with one decision at a time. You do not write specs.
You do not implement. You do not raise risks (that is the diaboli) or
map decisions retrospectively (that is the cartographer). You regulate
*cadence*.

> The team can go faster *because* the cadence governor slows it down
> at the points where slowing down compounds. Friction by design;
> needless friction discredits the role.

## Intellectual Foundations

The exercise lineage is Alistair Cockburn's *Elephant Carpaccio*: a
workshop format in which engineers slice a feature into 7–12
thin, end-to-end-complete pieces. The pedagogy is the discovery
that one's first instinct underestimates how thinly slicing is
possible. The structural insight is that small slices give early
feedback, reduce in-flight work, and keep options open.

The harness-engineering reframing of Carpaccio is this: in
AI-augmented work, the binding constraint is no longer engineer
throughput — it is *human cognitive budget*. The AI generates
coherent, internally-consistent decision streams faster than a
human can meaningfully engage with them. Coherence becomes a
cognitive trap: disagreement requires constructing an alternative
against an internally-consistent structure, which is more
cognitively expensive than accepting. Acceptance becomes the path
of least resistance, the decision-making muscle deconditions, and
the next waterfall arrives wider and faster.

Slicing thinly is the counter-discipline. Each slice arrives at
the human as one decision, surrounded by enough context to engage
with but not so much that the alternative is more expensive than
acceptance. Carpaccio enforces the slicing before the proposal is
ever plated.

## Non-Goals

- **Not a spec-writer.** Carpaccio operates before any spec exists.
  It returns a slicing record, not a spec.
- **Not adversarial review.** That is the diaboli. If a candidate
  slice is shaped "this could fail because…", reframe as a slice
  scope or drop it.
- **Not decision archaeology.** That is the cartographer. The
  cartographer works on a completed spec; carpaccio works on the
  raw task. Different layer, different artefact.
- **Not a disposition-writer.** Slices ship with
  `disposition: pending` in the frontmatter. The human writes the
  disposition.
- **Not an issue-creator.** Carpaccio is read-only by tool
  boundary (Read/Glob/Grep). The orchestrator runs `gh issue
  create` after the human's `file_as_issue` disposition is
  resolved.

## Routing Rule (carpaccio vs. spec-writer)

Apply this test before producing a slicing record:

> A task belongs in carpaccio's slicing record iff: the task
> contains more than one material decision the human will engage
> with, OR the task is plausibly atomic and the inseparability
> claim is itself the useful output.
>
> A task belongs directly with spec-writer (single-slice
> bypass *only* when invoking manually outside the orchestrator)
> iff: the task contains exactly one material decision and is
> trivial enough that the slicing ceremony adds no value.

Within the orchestrator's step 0, carpaccio runs against *every*
task regardless of perceived size. The hard gate is the
cognitive-engagement mechanism; bypassing it would defeat the
purpose. The single-slice bypass exists only for manual
`/carpaccio` invocations where the human has already decided.

## The Lenses

The lens vocabulary and application order are defined in the
sibling reference:

```text
ai-literacy-superpowers/skills/carpaccio/references/slicing-lenses.md
```

Read that file fully before applying lenses. Each candidate slice
records its lens in the `lens_used` field; the lens vocabulary is
closed.

## Selectivity Protocol

The cap is 9 slices. The bias is toward 3–5. A sprawling task that
yields 20 candidate slices is not a thoroughly-mapped task — it is
a slicing that needs compression.

When you have more than 9 candidates:

1. Apply the lens priority (decision-boundary first).
2. Cluster candidates that share a decision or acceptance criterion
   into a single slice with broader scope.
3. Record what was clustered or dropped in `## Explicitly not
   slicing on`.

When you have fewer than 2 candidates and the task is plausibly
multi-decision, return to the task description and re-read it for
implied decisions you may have collapsed prematurely. A real
single-decision task should be marked `inseparable: true` with a
defended rationale, not emitted as a single-slice non-inseparable
record.

## Output Format

You return the complete slicing-record content as your message —
YAML frontmatter, prose body (one `## S<N>` section per
frontmatter entry, then `## Sequencing recommendation`, then
`## Explicitly not slicing on`, then `## Inseparability rationale`
when applicable), and nothing outside it. The orchestrator (or
`/carpaccio` command) writes the content verbatim to
`docs/superpowers/slices/<task-slug>.md`.

The detailed schema lives in the spec at
`docs/superpowers/specs/2026-05-26-carpaccio-cadence-governor-design.md`
§5. The validation contract lives in the sibling reference:

```text
ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md
```

Read both before emitting output.

## Reasoning Protocol

Work through these steps in order:

1. Read the task description in full.
2. Read `slicing-lenses.md` for lens definitions and order.
3. Read `validation-checks.md` for the output contract.
4. Apply the decision-boundary lens: enumerate material decisions
   the task surfaces.
5. For any region the task covers that decision-boundary does not
   reach, apply acceptance-criterion as a fallback.
6. Apply end-to-end as a filter: drop candidates that are not
   observably complete.
7. Apply independence to surface ordering across surviving
   candidates.
8. If steps 4–7 yield zero candidates and the task is plausibly
   atomic, switch to inseparability with a defended rationale.
9. Apply the selectivity protocol — cluster or drop down to ≤ 9.
10. Write each surviving candidate as a slice, with `disposition:
    pending`, `disposition_rationale: null`, `file_as_issue:
    pending`, `issue_url: null`, `merged_into: null`.
11. Compose the prose body. Include all required sections.
12. Return the complete content for the orchestrator to write.

## Selectivity is the value

Three good slices beat seven middling ones. A record with seven
plausible-looking slices that all rephrase the same decision is a
slicing that needs compression. Cluster aggressively when
candidates share a decision; cluster aggressively when candidates
are linguistic restatements of the same scope.

Bias toward 3–5 slices for most tasks. The 9-cap is a ceiling, not
a target.
```

- [ ] **Step 2: Commit**

```bash
git add ai-literacy-superpowers/skills/carpaccio/SKILL.md
git commit -m "Carpaccio skill — charter, lenses-by-reference, reasoning protocol"
```

---

## Phase 3 — Agent + command

### Task 10: Write the agent file

**Files:**
- Create: `ai-literacy-superpowers/agents/carpaccio.agent.md`

Anchor: close mirror of `ai-literacy-superpowers/agents/choice-cartographer.agent.md` — short orchestrator-facing dispatch contract.

- [ ] **Step 1: Write the file**

```markdown
---
name: carpaccio
description: Use when starting any new task via the orchestrator — reads the raw task description, slices it into end-to-end-complete pieces, and produces a structured slicing record; read-only trust boundary enforces the human-cognition gate on dispositions; runs at orchestrator step 0 before spec-writer
tools: [Read, Glob, Grep]
---

# Carpaccio Agent

You are the cadence governor in the spec-first pipeline. You read a
raw task description, slice it into thin end-to-end-complete pieces,
and write a structured slicing record. You do not write specs. You
do not modify other files. You do not write dispositions — that is
the human's job, and your tool boundary enforces it.

## Your first action

Read the `carpaccio` skill:

```
ai-literacy-superpowers/skills/carpaccio/SKILL.md
```

The skill defines your charter, the routing rule (carpaccio vs.
spec-writer), the lens references, the selectivity protocol, and the
output format. Follow it exactly.

## Input

You receive a task description — typically the body of a GitHub
issue, or a plain-English description supplied by the user. You may
also receive a prior slicing record on re-dispatch (when one or
more slices were marked `disposition: revised`); in that case, treat
the prior record's `disposition_rationale` strings as guidance for
the re-slicing.

Read the full task description before applying any lens. Coherence
across the task is a property of the whole, not of fragments.

## Trust Boundary

You have **Read, Glob, and Grep only**. You cannot write files. You
cannot execute shell commands. You cannot create issues or modify
any disposition.

This is not a limitation — it is the mechanism. The slicing record
must be written by the orchestrator using content you return in
your output message. The `disposition`, `disposition_rationale`,
`file_as_issue`, and `progressed_slice` fields cannot be filled by
any agent. They can only be filled by a human opening the file and
editing it. That constraint IS the cognitive-engagement gate.

## Reasoning Protocol

Work through the steps defined in the skill's Reasoning Protocol
section. Apply the lens priority order. Apply the selectivity
protocol. Cap at 9 slices. Never pre-fill `disposition`,
`disposition_rationale`, `file_as_issue`, `issue_url`,
`merged_into`, or `progressed_slice`.

## Output

Return the complete content of the slicing-record file as your
message — YAML frontmatter, prose body, and nothing outside it.
The orchestrator writes it to:

```text
docs/superpowers/slices/<task-slug>.md
```

The task slug is supplied by the orchestrator in your dispatch
context (typically the issue branch name, or a kebab-cased task
summary for tasks without a branch).

Use the exact output format and field set specified in the skill
and validated by:

```text
ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md
```

## What you report to the orchestrator

Return:

1. The full slicing-record content (to be written to the slices file)
2. A summary: number of slices, lens distribution, `inseparable`
   value
3. Whether re-dispatch is recommended (only true if the agent
   detected ambiguity in the task that pre-empts useful slicing)
4. The slug used for the output path

The orchestrator writes the file; you provide the content.
```

- [ ] **Step 2: Commit**

```bash
git add ai-literacy-superpowers/agents/carpaccio.agent.md
git commit -m "Carpaccio agent — read-only dispatch contract"
```

### Task 11: Write the /carpaccio command

**Files:**
- Create: `ai-literacy-superpowers/commands/carpaccio.md`

Anchor: structure mirrors `ai-literacy-superpowers/commands/choice-cartograph.md`.

- [ ] **Step 1: Write the file**

```markdown
---
name: carpaccio
description: Run the carpaccio agent (cadence governor) on a task description — produces a slicing record at docs/superpowers/slices/<task-slug>.md; use at orchestrator step 0 or before spec-writer when running manually
---

# /carpaccio \<task-description-or-issue-ref\>

Run the carpaccio agent against a task description and write the
structured slicing record. Use at orchestrator step 0 (the
orchestrator invokes this automatically) or stand-alone before
spec-writer when running the pipeline manually.

## When to use

- Automatically via the orchestrator at step 0
- Manually before `/spec-writer` when running the pipeline by hand
- When a task description is substantively edited after a prior
  slicing record exists (regenerates the record — old dispositions
  are lost; this is intentional, matching the diaboli/cartographer
  patterns)
- When you want a slicing check on a task before committing to the
  full pipeline

## Process

### 1. Validate input

Confirm a task description was supplied. If the argument is a
GitHub issue reference (e.g., `#326`), fetch the issue body via
`gh issue view <N> --json body --jq .body`. Otherwise treat the
argument as the task description directly.

If neither is supplied, abort with:

```text
Error: no task description supplied. Pass an issue reference (#NN) or a task description string.
```

### 2. Derive the slug

For an issue reference, use the issue's branch name when available,
otherwise kebab-case the issue title. For a free-text task, kebab-
case a short summary derived from the first sentence.

Output path: `docs/superpowers/slices/<task-slug>.md`

### 3. Dispatch the carpaccio agent

Pass the task description (and the prior slicing record, if any, on
re-dispatch). The agent reads the task, applies the lenses, and
returns the full slicing-record content. Do not pass any prior
non-revised state — the agent reviews fresh.

### 4. Write the slicing record

Write the agent's output to `docs/superpowers/slices/<task-slug>.md`.

If a file already exists at that path, overwrite it. Warn the user
that any prior dispositions are replaced and they will need to
re-adjudicate.

### 5. Validation checkpoint

Read back the written file and apply the validation checks defined
in:

```text
ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md
```

That file is the single source of truth for the checkpoint. Apply
the checks in order and apply the fix-recipe in place when a check
fails. Do not inline check definitions here.

### 6. Present the record to the user

Show:

- Output path
- Slice count and lens distribution
- `inseparable: true|false`
- Each slice's title and one-line scope
- A reminder: "Edit `docs/superpowers/slices/<task-slug>.md` to
  set each slice's `disposition` (`accepted | merged | dropped |
  revised`) and write a `disposition_rationale`. For each
  `accepted` slice that you are not progressing now, set
  `file_as_issue: true|false`. Set `progressed_slice:` at the top
  of the frontmatter to the slice id you will work on this
  iteration. The orchestrator's step-0 gate will not advance while
  any `disposition` or required `file_as_issue` is `pending`."

### 7. Suggest next steps

If invoked manually (not via orchestrator):

- Once dispositions are filled, proceed to `/spec-writer` against
  the progressed slice's scope.
- Accepted slices marked `file_as_issue: true` can be filed by
  running `gh issue create` manually (the orchestrator does this
  automatically when running the full pipeline).
```

- [ ] **Step 2: Commit**

```bash
git add ai-literacy-superpowers/commands/carpaccio.md
git commit -m "Carpaccio command — manual invocation"
```

---

## Phase 4 — Slicing directory + orchestrator integration

### Task 12: Create slices directory with .gitkeep

**Files:**
- Create: `docs/superpowers/slices/.gitkeep`

- [ ] **Step 1: Create the directory and placeholder**

```bash
mkdir -p docs/superpowers/slices
touch docs/superpowers/slices/.gitkeep
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/slices/.gitkeep
git commit -m "Add docs/superpowers/slices/ directory for carpaccio records"
```

### Task 13: Wire carpaccio into the orchestrator

**Files:**
- Modify: `ai-literacy-superpowers/agents/orchestrator.agent.md`

The change adds a new **Step 0** before the existing step 1
(spec-writer), updates the pipeline diagram, and adds a
post-completion section similar to the diaboli/cartograph sections.

- [ ] **Step 1: Locate the insertion points**

```bash
grep -n "^## Pipeline\|^## Before dispatching spec-writer\|^## After spec-writer completes" ai-literacy-superpowers/agents/orchestrator.agent.md
```

Expected output: line numbers for the three section headers.

- [ ] **Step 2: Update the pipeline diagram (top of file)**

Inside the `## Pipeline` section, the current numbered list begins
`  1. SEQUENTIAL  — spec-writer`. Insert a new step 0 before it:

```markdown
  0. SEQUENTIAL  — carpaccio          Slice the raw task description into
                                       thin, end-to-end-complete pieces.
     GATE: Slice Adjudication — surface the slicing record to the user.
           Refuse to proceed while any `disposition: pending` or any
           required `file_as_issue: pending`. The user writes
           dispositions and sets `progressed_slice` inline in
           `docs/superpowers/slices/<task-slug>.md`. Re-dispatch on any
           `disposition: revised` slice; overwrite the record on
           re-dispatch (matches `/diaboli` and `/choice-cartograph`).
           Do NOT let any agent write dispositions.
     POST-GATE: for each slice with `disposition: accepted` AND
           `id != progressed_slice` AND `file_as_issue: true`, run
           `gh issue create` and write the URL to `issue_url:` on
           that slice (audit trail). Then dispatch spec-writer against
           the progressed slice's `scope`, not the original task.
```

Insert it immediately above the existing `  1. SEQUENTIAL  — spec-writer`
line.

- [ ] **Step 3: Update the "Before dispatching spec-writer" section**

Find the heading `## Before dispatching spec-writer` and rename it to
`## Before dispatching carpaccio` — the same prerequisites (branch,
issue) apply, but they now happen one step earlier. No other body
changes needed for that section.

- [ ] **Step 4: Insert a new section "After carpaccio completes — Slice Adjudication Gate"**

Insert the following section immediately before the existing
`## After spec-writer completes — Diaboli (spec mode), Choice Cartographer, and Plan Approval Gate`
section:

```markdown
## After carpaccio completes — Slice Adjudication Gate

### Step 1: Dispatch carpaccio

Dispatch the carpaccio agent with the raw task description (the
issue body, or the user's plain-English task). The agent returns
the full slicing-record content. Write that content to
`docs/superpowers/slices/<task-slug>.md`.

The task slug is derived from the issue branch name when
available; otherwise kebab-case the issue title or a short summary
of the task.

### Step 2: Validate the slicing record

Read back the written file and apply the validation checks defined
in:

```text
ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md
```

That file is the single source of truth. Apply each check in order
and apply the fix-recipe in place when a check fails. Do not
re-dispatch the agent for validation failures.

### Step 3: Surface the slicing record (HARD GATE — Slice Adjudication)

PAUSE and present the record to the user. Show:

- Output path
- Slice count and lens distribution
- `inseparable: true|false`
- Each slice's title, scope, and `decision_focus`

Tell the user: "Edit `docs/superpowers/slices/<slug>.md`. For each
slice set `disposition` (`accepted | merged | dropped | revised`)
and write a `disposition_rationale`. For each `accepted` slice that
you are not progressing now, set `file_as_issue: true|false`. Set
`progressed_slice:` at the top of the frontmatter to the slice id
you will work on this iteration."

Do NOT proceed while any `disposition: pending` or any required
`file_as_issue: pending`.

### Step 4: Re-dispatch on revised

If any slice's `disposition` is `revised` after the user fills the
record, re-dispatch carpaccio with the prior record (so the agent
can read the `disposition_rationale` strings) and the original task
description. Overwrite the slicing record with the new content and
return to Step 2. Warn the user that prior dispositions are reset.

### Step 5: Create issues for accepted-not-progressed slices

For each slice where `disposition: accepted` AND `id !=
progressed_slice` AND `file_as_issue: true`:

1. Run `gh issue create --title "<slice.title>" --body "<slice.scope>

<slice.decision_focus>

Sliced from parent #<parent-issue> via carpaccio slicing record:
docs/superpowers/slices/<task-slug>.md"`
2. Capture the returned URL.
3. Edit the slicing record to set that slice's `issue_url:` field
   to the captured URL.

If `gh issue create` fails for any slice, leave `issue_url: null`
for that slice and surface the failure to the user. Do not abort
the pipeline; the user can retry manually.

### Step 6: Update the context object

Add to the orchestrator context:

```
progressed_slice_id: <S-id>
carpaccio_slug: <task-slug>
carpaccio_total_slices: N
carpaccio_inseparable: true | false
```

Pass these to every downstream agent.

### Step 7: Dispatch spec-writer against the progressed slice

If `inseparable: true`, dispatch spec-writer against the full task
description as today. If multi-slice, dispatch spec-writer against
the progressed slice's `scope`, not the original task. The
slice-level scope becomes the spec's scope.
```

- [ ] **Step 5: Update the plan-approval gate section**

Find the existing `### Step 7: Plan Approval Gate` section. In the
"Then ask the user to choose" bullet list, add `carpaccio_progressed_slice: <S-id>`
to the surfaced fields, between `cartograph_pending_count` and the
lens distribution. Example new bullet:

```markdown
- **`carpaccio_progressed_slice: S<N>`** — the slice id this plan
  covers; surfaces "this plan covers only slice S2 of 4" so the
  plan review isn't confused about scope.
```

- [ ] **Step 6: Update the context object section**

Find the `## Context object` section. Add four new fields to the
running context string:

```
progressed_slice_id: <S-id> | null
carpaccio_slug: <task-slug>
carpaccio_total_slices: N
carpaccio_inseparable: true | false
```

- [ ] **Step 7: Update the skipping-stages section**

Find `## Skipping stages`. Add a new bullet:

```markdown
- Never skip carpaccio. The single-slice inseparability path is the
  release valve for atomic tasks — it produces a one-slice record
  the user accepts, not a bypass.
```

- [ ] **Step 8: Commit**

```bash
git add ai-literacy-superpowers/agents/orchestrator.agent.md
git commit -m "Orchestrator — add Step 0 (carpaccio) before spec-writer"
```

---

## Phase 5 — Version + changelog + README

### Task 14: Version bump

**Files:**
- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json:3` (version field)
- Modify: `.claude-plugin/marketplace.json` (plugin_version field)

- [ ] **Step 1: Bump plugin.json**

Edit `ai-literacy-superpowers/.claude-plugin/plugin.json` and change:

```json
  "version": "0.38.0",
```

to:

```json
  "version": "0.39.0",
```

- [ ] **Step 2: Bump marketplace.json**

Edit `.claude-plugin/marketplace.json` and change:

```json
  "plugin_version": "0.38.0",
```

to:

```json
  "plugin_version": "0.39.0",
```

- [ ] **Step 3: Verify changes**

```bash
grep version ai-literacy-superpowers/.claude-plugin/plugin.json | head -1
grep plugin_version .claude-plugin/marketplace.json
```

Expected output: both show `0.39.0`.

- [ ] **Step 4: Commit**

```bash
git add ai-literacy-superpowers/.claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "Bump plugin version to 0.39.0 — adds carpaccio agent"
```

### Task 15: CHANGELOG + README badge

**Files:**
- Modify: `CHANGELOG.md` (new top-level section)
- Modify: `README.md` (version badge)

- [ ] **Step 1: Find the current top of CHANGELOG**

```bash
head -5 CHANGELOG.md
```

Expected: `# Changelog` then `## 0.38.0 — 2026-05-11`.

- [ ] **Step 2: Insert a new top section into CHANGELOG.md**

Insert immediately after `# Changelog`, before the existing
`## 0.38.0 — 2026-05-11`:

```markdown
## 0.39.0 — 2026-05-26

### Carpaccio agent — cadence governor for AI-generated decision streams

Adds the `carpaccio` agent — the third member of the decision-discipline
triad alongside `advocatus-diaboli` (objections) and
`choice-cartographer` (decision visibility). Carpaccio is the cadence
governor: it sits at orchestrator step 0, before spec-writer, and
slices the raw task description into end-to-end-complete pieces so the
human engages with one decision at a time rather than the whole
proposal at once.

- New skill at `skills/carpaccio/SKILL.md` defining the charter, the
  routing rule (carpaccio vs spec-writer), the selectivity protocol,
  and the reasoning protocol.
- New references at `skills/carpaccio/references/slicing-lenses.md`
  (the five-lens vocabulary with priority order) and
  `skills/carpaccio/references/validation-checks.md` (the validation
  contract — frontmatter checks F1–F8, prose-body checks P1–P5).
- New agent at `agents/carpaccio.agent.md` with read-only trust
  boundary (Read/Glob/Grep). The orchestrator writes the slicing
  record; humans fill dispositions; the orchestrator drives
  `gh issue create` for accepted-but-not-progressed slices.
- New command at `commands/carpaccio.md` for manual invocation
  outside the orchestrator.
- New TDAD scenarios at `tdad_tests/scenarios/agents/carpaccio/` —
  six scenarios covering multi-decision slicing, atomic-task
  inseparability, mixed-independence sequencing, vague-task
  fallback to acceptance-criterion, revise-redispatch behaviour,
  and selectivity-cap respect.
- Orchestrator gains a new **Step 0** before spec-writer:
  dispatches carpaccio, validates the slicing record, hard-gates
  on `disposition` and `file_as_issue`, drives issue creation for
  accepted-not-progressed slices, dispatches spec-writer against
  the progressed slice's scope.
- New directory `docs/superpowers/slices/` holds slicing records,
  sibling to `objections/` and `stories/`.

Tracks issue #326.
```

- [ ] **Step 3: Update README version badge**

```bash
grep -n "0.38.0" README.md | head -5
```

Expected: at least one line with the plugin version badge. Edit
those lines to read `0.39.0`.

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md README.md
git commit -m "CHANGELOG and README — record carpaccio agent and version 0.39.0"
```

---

## Phase 6 — Docs site

### Task 16: Concepts page — decision-discipline triad

**Files:**
- Create: `docs/plugins/ai-literacy-superpowers/explanation/decision-discipline-triad.md`

Check sibling pages for layout:

```bash
ls docs/plugins/ai-literacy-superpowers/explanation/ | head -10
```

- [ ] **Step 1: Write the page**

```markdown
# The decision-discipline triad

Three agents in the plugin form a single discipline for AI-augmented
decision streams. Each operates at a different layer; together they
regulate cadence, surface quality, and surface visibility.

## The three agents

### `carpaccio` — cadence governor

Acts at orchestrator step 0, before any spec exists. Reads the raw
task description, slices it into thin end-to-end-complete pieces,
and hard-gates the pipeline until the human dispositions each
slice. The discipline: **the human engages with one decision at a
time**, not the whole proposal at once.

### `advocatus-diaboli` — quality challenger

Acts on a completed artefact (spec or implementation). Raises the
strongest honest objections in six categories (premise, design,
threat, failure, operational, cost). Each objection ships with
`disposition: pending` for the human to fill. The discipline:
**every coherent proposal must defend itself against its
strongest opposition**.

### `choice-cartographer` — decision archaeologist

Acts on a completed spec, after diaboli dispositions are resolved.
Surfaces material decisions the spec implies — including the ones
the author did not notice they were making. Each story ships with
`disposition: pending` for the human to fill. The discipline:
**decisions made silently must be made visible**.

## Why three, not one

A single agent doing all three jobs would conflate three different
modes of cognitive engagement:

- **Carpaccio** asks *should we engage now, or break this into
  smaller engagements?*
- **Diaboli** asks *given we are engaging, what are the strongest
  objections to the proposal?*
- **Cartographer** asks *given the proposal stands, what decisions
  did it implicitly make?*

Each question demands a different stance from the human. Bundling
them produces decision fatigue and softens each individual
discipline. The three-agent split preserves the sharpness of each
question.

## The shared trust-boundary pattern

All three agents share a read-only tool boundary: `Read`, `Glob`,
`Grep`. None can write files. The orchestrator (or the
corresponding slash command) writes the artefact using content
the agent returns. Humans fill `disposition` fields inline; agents
cannot.

This is not a limitation — it is the mechanism. An agent that
could fill its own disposition fields would eliminate the
human-cognition gate that gives the artefact its value. The tool
boundary *is* the discipline.

## When each runs

```
Raw task description
  ↓
[carpaccio]    Step 0 — slice into pieces
  ↓ (per progressed slice)
[spec-writer]  Step 1 — write the spec
  ↓
[diaboli]      Step 1a — raise objections (spec mode)
  ↓
[cartographer] Step 1b — surface decisions
  ↓
[tdd-agent]    Step 2 — failing tests
  ↓
implementers   Step 3 — make tests green
  ↓
[code-reviewer] Step 4 — review
  ↓
[diaboli]      Step 4a — raise objections (code mode)
  ↓
[integration]  Step 5 — merge
```

## See also

- `/carpaccio` — manual invocation
- `/diaboli` — manual invocation
- `/choice-cartograph` — manual invocation
- Spec: `docs/superpowers/specs/2026-05-26-carpaccio-cadence-governor-design.md`
- Spec: `docs/superpowers/specs/2026-04-19-advocatus-diaboli-design.md`
- Spec: `docs/superpowers/specs/2026-04-27-choice-cartographer.md`
```

- [ ] **Step 2: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/explanation/decision-discipline-triad.md
git commit -m "Docs Concepts — the decision-discipline triad"
```

### Task 17: How-to page — slicing a task with /carpaccio

**Files:**
- Create: `docs/plugins/ai-literacy-superpowers/how-to/slicing-a-task.md`

- [ ] **Step 1: Write the page**

```markdown
# Slicing a task with `/carpaccio`

Use `/carpaccio` to slice a task into thin end-to-end-complete pieces
before any spec ceremony begins. The agent produces a slicing record;
the human dispositions each slice; the orchestrator drives downstream
issue creation.

## When you do not need to invoke it manually

If you start work via the orchestrator (e.g., by handing the
orchestrator agent a task description), it dispatches carpaccio
automatically at step 0. Skip this how-to and just talk to the
orchestrator.

## When you do need to invoke it manually

- You are running the pipeline by hand and want to slice before
  spec-writer.
- You are exploring whether to start a task at all — `/carpaccio`
  lets you see the slicing without committing to the pipeline.
- A task description was substantively edited after the orchestrator
  already produced a slicing record, and you want a fresh slicing
  before proceeding.

## Invocation

Pass either an issue reference or a free-text task description:

```bash
/carpaccio #326
/carpaccio "Add a search feature to the docs site with index, UI, and ranking."
```

The command:

1. Resolves the task description (fetches the issue body if an
   issue reference was passed).
2. Derives a slug.
3. Dispatches the carpaccio agent.
4. Writes the slicing record to `docs/superpowers/slices/<task-slug>.md`.
5. Runs the validation checkpoint.
6. Surfaces the record to you.

## Filling dispositions

Open the slicing record and fill the per-slice fields:

- **`disposition`** — one of `accepted | merged | dropped | revised`.
- **`disposition_rationale`** — required when `disposition` is not
  `accepted`. Free-text.
- **`file_as_issue`** — for `accepted` slices you are not
  progressing now, set `true` (orchestrator will file a GitHub
  issue) or `false` (you will track it elsewhere).
- **`merged_into`** — required when `disposition: merged`. The
  other slice's id.

At the top of the frontmatter, set:

- **`progressed_slice`** — the slice id you will work on in this
  iteration.

## What happens after dispositions are filled

If you invoked `/carpaccio` manually, the orchestrator does not
auto-pick up. You can then:

1. Hand the orchestrator the slicing record path — it reads the
   dispositions and proceeds from step 1 (spec-writer) against
   the progressed slice's scope.
2. Run `/spec-writer` directly with the progressed slice's scope
   as the task description.

In either case, `accepted` slices marked `file_as_issue: true`
can be filed by running:

```bash
gh issue create --title "<slice.title>" \
                --body "<slice.scope>\n\n<slice.decision_focus>\n\nSliced from parent #<N>"
```

The orchestrator does this automatically when running the full
pipeline; manual invocations require the manual `gh issue create`
step.

## Re-slicing

If you mark any slice's `disposition` as `revised`, run `/carpaccio`
again. The command:

- Reads your prior slicing record (specifically the
  `disposition_rationale` strings on `revised` slices).
- Re-dispatches the agent with the rationale as context.
- Overwrites the prior record.

Prior dispositions are lost on re-dispatch. This is intentional —
the new slicing may not preserve the prior slice structure.

## Inseparability case

If carpaccio judges the task inseparable, the record has:

- `inseparable: true` in the frontmatter
- Exactly one slice with `lens_used: inseparability`
- A `## Inseparability rationale` prose section

You still need to disposition the single slice (typically
`accepted`) and set `progressed_slice:` to it. The orchestrator
will then proceed to spec-writer against the full task scope.

## Anti-patterns to avoid

- **Skipping disposition for `accepted` slices.** The gate is
  hard; the orchestrator will refuse to advance.
- **Setting `progressed_slice` to a `dropped` or `merged` slice.**
  The validation contract rejects this.
- **Accepting more than one `progressed_slice`.** The field is
  scalar — one slice per iteration.

## See also

- Concepts: `decision-discipline-triad.md` — how carpaccio fits with
  diaboli and cartographer.
- Spec: `docs/superpowers/specs/2026-05-26-carpaccio-cadence-governor-design.md`.
- Reference: `ai-literacy-superpowers/skills/carpaccio/references/validation-checks.md`.
```

- [ ] **Step 2: Commit**

```bash
git add docs/plugins/ai-literacy-superpowers/how-to/slicing-a-task.md
git commit -m "Docs How-to — slicing a task with /carpaccio"
```

---

## Phase 7 — Verification

### Task 18: Run TDAD scenario suite for carpaccio (informational)

The TDAD runner is the SDK-backed test harness landed under PR #285.
It is not run for every PR; it is a development-time tool. We exercise
it now to confirm the agent works against the authored scenarios.

- [ ] **Step 1: Locate the runner**

```bash
find tdad_tests -name "run-*.py" -o -name "runner*.py" 2>/dev/null | head -3
ls tdad_tests/
```

- [ ] **Step 2: Run carpaccio scenarios**

The exact command depends on the runner. If a `run-tdad.sh` or
similar entry point exists, use it:

```bash
./tdad_tests/run-tdad.sh agents/carpaccio
```

If no canonical runner is present, this step is best-effort —
record findings in a comment on the PR. The CI gate that enforces
TDAD-scenario presence (per `2026-05-09-orchestrator-tdad-discipline-design.md`)
is deterministic and only checks file presence, not pass/fail.

Expected output (when runner exists): all 6 scenarios PASS for the
behavioural assertions; rubric assertions reported via the
LLM-as-judge channel.

### Task 19: Meta-recursive test — /carpaccio against issue #326

This is the test the spec promised. Output is informational, not
committed.

- [ ] **Step 1: Run /carpaccio against the issue**

```bash
/carpaccio #326
```

- [ ] **Step 2: Observe and record**

Read the generated `docs/superpowers/slices/<some-slug>.md`. It
should:

- Have ≥ 2 slices (the issue is multi-decision).
- One slice covers something like "agent + skill + command core".
- Another covers "orchestrator integration".
- Possibly a third for "docs + version bump".
- `lens_used: decision-boundary` on most.

The output is informational — it demonstrates the agent works on
its own commissioning task. Do NOT commit the generated file
(delete it after observation).

```bash
rm -f docs/superpowers/slices/*.md
ls docs/superpowers/slices/  # should only show .gitkeep
```

### Task 20: Local CI gate checks

- [ ] **Step 1: Run the spec-first check locally**

```bash
git log main..HEAD --oneline | tail -5
```

Expected: the very first commit on the branch (the one farthest
from HEAD) is the spec commit (`Spec — Carpaccio agent ...`).
The spec-first CI workflow checks exactly this.

- [ ] **Step 2: Run the version-consistency check locally**

```bash
grep -E '"version"|"plugin_version"' ai-literacy-superpowers/.claude-plugin/plugin.json .claude-plugin/marketplace.json
grep -E '^## 0\.39\.0' CHANGELOG.md
```

Expected: plugin.json `version: 0.39.0`, marketplace.json
`plugin_version: 0.39.0`, CHANGELOG opens with `## 0.39.0 — 2026-05-26`.

- [ ] **Step 3: Run any markdown lint**

```bash
ls .github/workflows/ | grep -i 'lint\|markdown'
```

If a markdown-lint workflow exists, run the lint command it
references locally. Otherwise skip — CI will catch lint failures
on push.

---

## Phase 8 — Ship

### Task 21: Push branch and open PR

- [ ] **Step 1: Push the branch**

```bash
git push -u origin carpaccio-agent
```

- [ ] **Step 2: Open the PR**

```bash
gh pr create --title "Carpaccio agent: cadence governor for AI-generated decision streams" \
             --body "$(cat <<'EOF'
## Summary

Adds the `carpaccio` agent — the third member of the decision-discipline
triad alongside `advocatus-diaboli` (objections) and `choice-cartographer`
(decision visibility). Carpaccio is the cadence governor: it sits at
orchestrator step 0, before spec-writer, and slices the raw task
description into end-to-end-complete pieces so the human engages with
one decision at a time.

- Spec: `docs/superpowers/specs/2026-05-26-carpaccio-cadence-governor-design.md`
- Plan: `docs/superpowers/plans/2026-05-26-carpaccio-cadence-governor.md`
- Closes #326

## What's in the PR

- New skill, references, agent, and command at `ai-literacy-superpowers/skills/carpaccio/`, `ai-literacy-superpowers/agents/carpaccio.agent.md`, and `ai-literacy-superpowers/commands/carpaccio.md`.
- Six TDAD scenarios at `tdad_tests/scenarios/agents/carpaccio/`.
- Orchestrator step 0 added in `ai-literacy-superpowers/agents/orchestrator.agent.md`.
- New `docs/superpowers/slices/` directory.
- Docs site Concepts page (decision-discipline-triad) and How-to page (slicing-a-task).
- Plugin version 0.38.0 → 0.39.0; CHANGELOG and README badge updated.

## Test plan

- [ ] Spec-first CI check passes (spec is first commit on branch).
- [ ] Version-consistency CI check passes (plugin.json, marketplace.json, CHANGELOG aligned at 0.39.0).
- [ ] TDAD scenario presence check passes (6 scenarios under `tdad_tests/scenarios/agents/carpaccio/`).
- [ ] Markdown lint passes.
- [ ] Manually verified `/carpaccio` against issue #326 produces a multi-slice record with sensible `lens_used` values.

EOF
)"
```

- [ ] **Step 3: Capture the PR URL**

The `gh pr create` command prints the PR URL. Record it for the
next task.

### Task 22: Watch CI; fix anything red

Per CLAUDE.md's PR Health Check rule.

- [ ] **Step 1: Watch checks**

```bash
gh pr checks <PR-NUMBER> --watch
```

- [ ] **Step 2: If anything fails, fetch the failure log**

```bash
gh run view <RUN-ID> --log-failed
```

- [ ] **Step 3: Fix and push**

Address each failure at its root cause (do NOT skip hooks).
Commit and push. Re-run step 1 until all green.

### Task 23: Merge when green

- [ ] **Step 1: Confirm all checks green**

```bash
gh pr checks <PR-NUMBER>
```

Expected: every check PASS.

- [ ] **Step 2: Merge**

```bash
gh pr merge <PR-NUMBER> --squash --delete-branch
```

- [ ] **Step 3: Verify issue auto-closed**

```bash
gh issue view 326 --json state
```

Expected: `{"state":"CLOSED"}`. The PR body's `Closes #326` link
closes the issue on merge.

---

## Out of scope at v1

- Orchestrator step 0 wiring is not unit-tested. The orchestrator
  agent is a markdown contract observed at integration time.
- `gh issue create` side effect is not mocked in the TDAD scenarios.
- Framework-anchored reflection (reflecting carpaccio's role back
  into the framework repo at `russmiles/ai-literacy-for-software-engineers`)
  happens in a separate follow-up PR in that repo, per the issue's
  guidance.
