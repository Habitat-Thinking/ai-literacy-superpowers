---
title: TDAD
---

# Test-Driven Agentic Discipline (TDAD)

Test-Driven Agentic Discipline applies the test-first habit of TDD to
**agentic components** — skills, agents, and commands that ship as
markdown rather than as compilable code. The term is after Antony
Marcano's 2026 Test-Driven Agentic Behaviours (TDAB); the variant
"Discipline" was adopted in this project because the practice is
about the *habit*, not just the artefacts.

This page explains what TDAD means, why this plugin uses it, the
four-layer architecture that scales the discipline across cost and
cadence, and how to add a TDAD scenario when you write a new
plugin component.

For the runnable test suite itself, see
[`tdad_tests/README.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/tdad_tests/README.md).
The methodology is documented here; the suite documents itself there.

---

## What is TDAD?

Classical TDD assumes executable code: write a failing test, watch it
fail for the right reason, then write the minimum implementation that
makes the test pass. Red → Green → Refactor.

Plugin components are not executable code. A skill is markdown that an
LLM reads as context. An agent is markdown that defines a charter,
tools, and behaviour. A command is markdown that the harness executes
as a slash-command pipeline. None of them have a `go test` or `pytest`
that fails when you change their content.

But the *discipline* of "describe the expected behaviour before writing
it" still has value here:

- **Scenarios capture intent** — a small markdown file with
  `Given / When / Then / Rubric` sections forces the author to name
  what the new component is *for* before deciding *how*.
- **Scenarios prevent description drift** — when a skill's description
  changes but the queries it should fire on do not, structural and
  trigger tests catch the mismatch.
- **Scenarios catch frontmatter rot** — required fields can be
  asserted programmatically; missing or invalid frontmatter is a
  deterministic, free check.
- **Scenarios are the unit of behavioural assertion** for the
  expensive Layer 3 SDK runs — when a real run is warranted, the
  scenario's `Then` clauses become the rubric.

TDAD is therefore not "TDD for markdown." It is the *test-first* habit
applied to a different kind of artefact, with a four-layer test
architecture that matches the cost gradient of the assertions
available.

---

## The four-layer architecture

The TDAD suite has four layers, each with its own cost / cadence /
determinism profile:

| Layer | What it tests | Cost | Cadence | Determinism |
| --- | --- | --- | --- | --- |
| **0. Deterministic plumbing** | Bash scripts and parser libraries the agents depend on | $0 | every PR | deterministic |
| **1. Structural** | Frontmatter well-formed, required sections present, cross-references resolve | $0 | every PR | deterministic |
| **2. Trigger** | Skill descriptions match the queries they should fire on | ~$0.03 / run | nightly + label-gated | mostly deterministic |
| **3. Behavioural** | Run an agent or skill in a fixture, assert outputs against a rubric | $0.05–$0.20 / run | nightly + label-gated | probabilistic |

The layers map onto the framework's harness promotion ladder: Layer 0
covers the *deterministic* tier; Layers 1–3 together cover the
*agent-verified* tier (with Layer 1 deterministic in practice but
addressing agent-related artefacts).

**Why four layers and not one?** Pure deterministic checks (Layer 0/1)
cannot verify whether a skill description triggers correctly on the
queries it should — that requires an LLM (Layer 2). And Layer 2 cannot
verify that an agent's full SDK invocation produces the expected
output for a given fixture — that requires a real run (Layer 3). Each
layer adds coverage at higher cost; the discipline is to apply the
cheapest layer that catches the failure mode you care about.

**What runs in CI today** (see the workflows under `.github/workflows/`):

- `tdad-tests-fast.yml` runs **Layers 0 and 1** on every PR that
  touches plugin code, the test suite, `HARNESS.md`, or `AGENTS.md`.
  Both layers are free and complete in under ten seconds.
- `tdad-scenario-check.yml` runs an orthogonal *coverage* check on
  every PR that adds a new plugin component, verifying that the
  component ships with at least one scenario file at the canonical
  path with a non-`finding` tier.
- **Layers 2 and 3** are not in CI yet. They require an
  `ANTHROPIC_API_KEY` secret and per-run cost design (cadence,
  budget ceiling, label-gating). A separate workflow can be added
  if the project decides those parameters.

---

## How TDAD applies to this plugin

The discipline is wired into three surfaces:

### 1. The orchestrator pipeline

The orchestrator's step 1c (added in v0.36.0) inspects the plan's
intended file paths before dispatching the `tdd-agent`. If the plan
adds a new file under
`ai-literacy-superpowers/skills/<name>/SKILL.md`,
`ai-literacy-superpowers/agents/<name>.agent.md`, or
`ai-literacy-superpowers/commands/<name>.md`, the orchestrator marks
the dispatch as **agent-artefact scope** and passes the artefact-type
context (`skill | agent | command`) and slug to the `tdd-agent`.

Detection is path-based. Detection is deliberately scoped to those
three directories — `hooks/`, `templates/`, and `scripts/` are out of
scope (the bash scripts are tested at Layer 0; templates and hooks are
covered by other mechanisms).

For the full pipeline, see the
[Agent Orchestration explanation page](../plugins/ai-literacy-superpowers/explanation/agent-orchestration.md).

### 2. The `tdd-agent`'s agent-artefact branch

The `tdd-agent` has two operating branches:

- **Generic-test branch** — for code work with a runnable test suite.
  RED is the conventional sense: a failing test before
  implementation.
- **Agent-artefact branch** — for new plugin components. RED is the
  structural-layer test reporting missing scenario coverage. The
  deliverable is a TDAD **scenario file**, not a code-level test.

The `tdd-agent` is dispatched by the orchestrator at pipeline step 2
with the artefact-type context from step 1c. When operating in the
agent-artefact branch, it returns the path of the scenario file(s)
authored, the layers targeted, and the structural-layer status.

### 3. The HARNESS constraints

Three deterministic constraints in `HARNESS.md` enforce TDAD discipline
at PR time:

- **`TDAD fast-suite passes (Layers 0 + 1)`** — every PR that touches
  plugin code or the test suite must pass Layer 0 (bash plumbing) and
  Layer 1 (structural) tests. Run by `tdad-tests-fast.yml`.
- **`New plugin components must ship with a TDAD scenario`** — every
  PR that adds a new file matching the canonical component paths must
  include at least one scenario file at
  `tdad_tests/scenarios/<type>/<name>/<aspect>.md` with `tier` in
  `{structural, trigger, behavioural}`. Files with `tier: finding`
  do NOT satisfy the constraint. Run by `tdad-scenario-check.yml`.
- **`Spec redaction markers must be visible`** — when a TDAD-related
  spec is amended, superseded prose must use visible blockquote
  prefixes rather than HTML-comment markers. Surfaced from the spec
  ceremony for the orchestrator-TDAD-discipline change itself; the
  redaction convention is now project-wide. Run by
  `spec-redaction-marker-check.yml`.

### Forward-only application

The discipline applies forward — to PRs that *add* a component on or
after 2026-05-10 (when v0.36.0 shipped). The agent files modified by
v0.36.0 (`orchestrator.agent.md` and `tdd-agent.agent.md`) themselves
do not have scenarios authored for them; the rule's introducer cannot
satisfy the rule because the rule did not yet exist. Both files carry
an in-place forward-pointer comment naming the spec at
`docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md`
and Amendment 2 §A2.6 as the reason.

This is a *self-exemption clause* (per cartograph story #1 of the
introducing spec). Future contributors generalising "the discipline
applies forward" into a maxim should re-read that story; the
exemption was a one-time concession, not an ongoing pattern.

---

## How to add a TDAD scenario

When you ship a new skill, agent, or command, drop a scenario file
alongside it in the test suite.

### Path convention

| Component type | Component file | Scenario directory |
| --- | --- | --- |
| Skill | `ai-literacy-superpowers/skills/<name>/SKILL.md` | `tdad_tests/scenarios/skills/<name>/` |
| Agent | `ai-literacy-superpowers/agents/<name>.agent.md` | `tdad_tests/scenarios/agents/<name>/` |
| Command | `ai-literacy-superpowers/commands/<name>.md` | `tdad_tests/scenarios/commands/<name>/` |

Inside the scenario directory, files are named **descriptively** —
typically a kebab-case verb-phrase like
`creates-spec-with-acceptance-scenarios.md` or
`identifies-violations.md`. Do **not** name files `scenario.md` —
descriptive aspects scale better when a component grows multiple
distinct scenarios.

### Frontmatter

Every scenario file uses the canonical TDAD scenario format:

```markdown
---
component: <slug>
component_type: <skill | agent | command>
tier: structural | trigger | behavioural
fixture: <optional fixture name>
---

## Given
...

## When
...

## Then
- bullet list of falsifiable assertions

## Rubric
prose explaining what makes the implementation acceptable in
ambiguous cases
```

The `tier` field declares which layer(s) the scenario targets. The
HARNESS constraint requires the value to be one of `structural`,
`trigger`, or `behavioural` — `tier: finding` does NOT satisfy the
constraint (see the next subsection).

### `FINDING-` is a separate artefact category

Some files in the scenario directories are **findings**, not
scenarios. A finding is a documentary architectural note rather than
a falsifiable scenario — it captures something the team learned about
the component that does not (yet) translate into a testable
assertion.

Findings live under the same component directory but use the prefix
`FINDING-` and `tier: finding`. Example:
`tdad_tests/scenarios/commands/harness-init/FINDING-command-tdab-gap.md`.

Findings:

- **Coexist** with `<aspect>.md` scenarios in the same directory.
- **Do NOT satisfy** the "new plugin components must ship with a TDAD
  scenario" HARNESS constraint — finding-tier files are documentary,
  not falsifiable.
- **Are appropriate when** a component surfaces an architectural
  question that genuinely cannot be expressed as a falsifiable
  scenario today.
- **Should not be authored by the `tdd-agent`** — they are a manual
  decision by the human author when the spec surfaces an unresolvable
  architectural question.

### When you modify an existing component

The HARNESS constraint scopes only to *new* component files. Modifying
an existing skill, agent, or command does NOT block on the constraint.
That said, the orchestrator's step 1c still fires on modifications and
surfaces the question to the `tdd-agent`: should the existing
scenario(s) be updated?

The current heuristic (per the introducing spec):

- **Update or replace** the relevant scenario(s) when the spec changes
  the component's behavioural contract.
- **Leave existing scenarios unchanged** when the spec is a
  non-behavioural refactor.
- This is a judgement call. There is no automated check.

If practice shows legitimate modifications silently skipping scenario
updates, a follow-up spec is queued for revisit at the next quarterly
`/governance-audit` (target 2026-07-19, per cartograph story #5 of the
introducing spec).

---

## Why this discipline matters

The plugin's "code" is markdown. Markdown rots silently — fields drift,
descriptions stop matching behaviour, components reference renamed
artefacts, frontmatter loses required keys. Without a test discipline,
the rot is invisible until the next time someone tries to compose the
component into a pipeline.

TDAD makes the rot visible. Layer 0 catches bash regressions in the
project's plumbing. Layer 1 catches frontmatter and structural drift.
Layer 2 catches description-vs-trigger drift. Layer 3 catches
behavioural drift in the components that warrant the cost.

The matched discipline at *authoring* time — the orchestrator's
step 1c, the `tdd-agent`'s agent-artefact branch, the HARNESS
constraints — ensures new components ship with their scenario rather
than acquiring it later (or never).

The result is compounding coverage: every new component adds a
scenario to the corpus; every scenario hardens the component against
silent drift. The four-layer cost gradient lets the project run the
free layers on every PR while reserving the costly layers for the
cases that warrant them.

---

## Where to learn more

- [`component-design-with-tdad` skill](../plugins/ai-literacy-superpowers/reference/skills.md#component-design-with-tdad)
  — design-time methodology naming the five design questions implied
  by the four-layer architecture; loadable by `spec-writer`,
  `tdd-agent`, or human brainstorming. Pairs with this docs page —
  the page explains *what TDAD is*; the skill packages the design
  intelligence the methodology assumes
- [`tdad_tests/README.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/tdad_tests/README.md)
  — the runnable test suite, layer-by-layer status table, scenario
  format, and cost expectations
- [Orchestrator-TDAD-discipline design spec](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md)
  — the spec that introduced the orchestrator's step 1c, the
  `tdd-agent`'s agent-artefact branch, and the
  `New plugin components must ship with a TDAD scenario` HARNESS
  constraint (with two amendments, three diaboli passes, and a
  cartograph that named the self-exemption-clause pattern)
- [Command-TDAD-testing design spec](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md)
  — the per-category strategy for testing the plugin's 25 commands,
  including the Option I amendment that keeps helpers test-stage
  (not shipping in the plugin)
- [`HARNESS.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/HARNESS.md)
  — the three TDAD-related constraints and their enforcement
  workflows
- [Agent Orchestration explanation page](../plugins/ai-literacy-superpowers/explanation/agent-orchestration.md)
  — the broader orchestrator pipeline that step 1c integrates into
- [Contributing guide](../contributing/index.md) — the day-to-day
  contributor view, including a brief mention of the TDAD scenario
  authoring step
