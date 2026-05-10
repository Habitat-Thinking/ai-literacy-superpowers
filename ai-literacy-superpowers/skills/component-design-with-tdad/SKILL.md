---
name: component-design-with-tdad
description: Use when designing a new plugin component (skill, agent, command, or backing script) for the ai-literacy-superpowers plugin or a sister plugin in this marketplace. Surfaces the design questions that the four-layer TDAD architecture implies — component type, tier targeting, scenario shape, FINDING-vs-scenario judgement, modification-vs-refactor heuristic. Loadable by spec-writer, tdd-agent, or directly during human brainstorming. Not a gate; a methodology guide that names the questions to ask before authoring.
---

# Component design with TDAD

When designing a new plugin component — a skill, an agent, a command,
or a backing script — the four-layer TDAD architecture has implications
for the component's *shape* that are easy to miss if the design is
done before the testing discipline is considered. This skill names
the questions to ask at design time so the component ships
test-friendly rather than acquiring (or never acquiring) its scenario
afterwards.

The skill is loadable by:

- The `spec-writer` agent when authoring a spec that adds a new plugin
  component
- The `tdd-agent` when operating in its agent-artefact branch (a
  scenario file is the RED-phase deliverable)
- Human brainstorming directly, before any agent dispatch

It is **not a gate**. The forcing functions live in HARNESS.md (the
deterministic CI workflows shipped in v0.36.0). This skill packages
the design intelligence those gates assume.

---

## Before reading this skill

The skill assumes familiarity with:

- The four-layer TDAD architecture — see
  [the TDAD docs page](../../../docs/tdad/index.md) and
  [`tdad_tests/README.md`](../../../tdad_tests/README.md) for the
  full architecture and cost-cadence trade-offs
- The plugin's component conventions — see HARNESS.md Context
  (Naming and File structure) and CLAUDE.md
- The orchestrator pipeline — see
  [`agents/orchestrator.agent.md`](../../agents/orchestrator.agent.md)
  for the spec-first ordering and the agent-artefact-scope detection
  step (1c)

## When to invoke

Invoke this skill when:

- A spec you are authoring will add a new file under
  `ai-literacy-superpowers/skills/<name>/SKILL.md`,
  `ai-literacy-superpowers/agents/<name>.agent.md`, or
  `ai-literacy-superpowers/commands/<name>.md`
- A spec will add a new bash script under
  `ai-literacy-superpowers/scripts/` or a new helper that the
  plugin's components depend on
- You are brainstorming whether something *should be* a skill, an
  agent, or a command — and the answer informs how the work is
  scoped
- A modification to an existing component changes its behavioural
  contract and you need to decide whether the existing scenario(s)
  should be updated

Do **not** invoke when:

- The change is to docs, CHANGELOG, marketplace metadata, or other
  artefacts outside the canonical component paths
- The change is a non-behavioural refactor of an existing component
- The work is gated by a `chore` exemption that explicitly defers
  TDAD-discipline application

---

## The five design questions

### 1. What component type is this?

The plugin has four canonical component types, each with different
authoring conventions and TDAD implications:

| Type | Path | What it is | TDAD applies? |
| --- | --- | --- | --- |
| Skill | `skills/<name>/SKILL.md` | Methodology guidance loaded into context | Yes — Layer 1 (structural) + Layer 2 (trigger) by default; Layer 3 case-by-case |
| Agent | `agents/<name>.agent.md` | Charter, tools, behaviour for a dispatchable agent | Yes — Layer 1 (structural); Layer 3 only when the agent has a clear assertable side-effect |
| Command | `commands/<name>.md` | Slash-command pipeline | Yes per the per-category strategy in [`command-tdad-testing-design.md`](../../../docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md) — procedural, orchestration, or model-mediated each have their own approach |
| Backing script | `scripts/<name>.sh` or `hooks/scripts/<name>.sh` | Bash plumbing — parsers, helpers, hook scripts | Yes — Layer 0 (deterministic plumbing), invoked by `tdad_tests/layer0_deterministic/` |

**Question to surface:** *Could this work be done by an existing
component instead of adding a new one?* The plugin already has 71+
components; the cost of adding one more is non-zero (every component
ships with maintenance overhead). Reuse-or-extend before add-new.

For the design heuristics on each type, see the existing
`plugin-dev` skills (`agent-development`, `skill-development`,
`command-development`, `hook-development`) — they cover the
*shape* of each type. This skill names the *TDAD-aware* layer.

### 2. Which TDAD layers does this component warrant?

The four-layer architecture is a cost gradient:

- **Layer 0 (deterministic plumbing)** — bash scripts and parser
  libraries the agents depend on. $0, every PR. Applies to every
  shell script in `scripts/` or `hooks/scripts/`.
- **Layer 1 (structural)** — frontmatter well-formed, required
  sections present, cross-references resolve. $0, every PR.
  **Applies to every plugin component by default.**
- **Layer 2 (trigger)** — does the skill description match the
  queries it should fire on? ~$0.03/run, nightly + label-gated.
  **Applies to skills only** — agents and commands don't have a
  description-vs-query match to verify.
- **Layer 3 (behavioural)** — full SDK invocation against fixtures,
  rubric judge. $0.05–$0.20/run, nightly + label-gated.
  **Case-by-case** — applies when the component has a clear
  assertable side-effect that's worth the API spend.

**Default layer targeting** (in the absence of a per-component
decision):

- Skills: `[structural, trigger]` — Layer 1 always, Layer 2 by
  default
- Agents: `[structural]` — Layer 1 always, Layer 3 only when the
  agent has a clear assertable side-effect (e.g.,
  `harness-discoverer`'s scan output, `spec-writer`'s spec.md)
- Commands: per the per-category strategy in
  [`command-tdad-testing-design.md`](../../../docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md)
  — procedural commands use Option C-direct test-stage helpers;
  orchestration commands inherit from agents; model-mediated
  commands defer Layer 3 case-by-case
- Backing scripts: `[deterministic]` (Layer 0) only

**Precedence note:** when an implementation spec contains explicit
per-layer guidance (especially for commands, where
`command-tdad-testing-design.md` Amendment 1 makes Layer 3
case-by-case), the spec's per-component judgement governs. The
defaults above are what the agent emits when the spec is silent.

### 3. What does the scenario's `Then` clause look like?

This is the test-quality question. A scenario whose `## Then` section
is empty or trivially satisfied passes Layer 1 (structural — the
section exists) but provides no substantive coverage. Bad scenarios
are worse than no scenarios because they create the appearance of
coverage.

Ask:

- **What falsifiable assertion does the scenario make?** Each `Then`
  bullet should be checkable mechanically (Layer 1: file exists,
  frontmatter has key X) or against a rubric (Layer 3: output
  contains Y, satisfies pattern Z).
- **What's the smallest fixture that exercises the assertion?**
  Layer 3 fixtures live in `tdad_tests/fixtures/` and `tdad_tests/scenarios/<type>/<name>/fixtures/`.
  A fixture that's larger than necessary slows the test and
  obscures the assertion.
- **Does the Rubric describe the acceptance criterion in plain
  prose?** The Rubric is read by humans (during scenario review)
  and by Layer 3 LLM judges. Both audiences need to know what
  "acceptable" means in ambiguous cases.

If you cannot articulate a falsifiable assertion, the artefact may
be a **finding**, not a scenario — see question 5.

### 4. New file or modification of an existing component?

The HARNESS constraint `New plugin components must ship with a TDAD
scenario` scopes only to *new* file additions matching the canonical
component paths. Modifications are NOT gated by the constraint.

For modifications, the heuristic (per
[`docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md`](../../../docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md)
§5):

- **Update or replace** the relevant scenario(s) when the spec
  changes the component's behavioural contract.
- **Leave existing scenarios unchanged** when the spec is a
  non-behavioural refactor.
- This is a judgement call. There is no automated check.

If the modification crosses any of these boundaries, treat it as a
contract change and update the scenario:

- The component's frontmatter `description` field changes
- The component's tool boundary changes (agents only)
- A `Given / When / Then` section in the existing scenario no
  longer reflects how the component behaves
- The component gains, removes, or renames a section that other
  components reference

**The orchestrator's step 1c surfaces the question for
modifications but does not enforce an answer.** When in doubt,
update the scenario.

### 5. Scenario or finding?

The corpus distinguishes two artefact categories under
`tdad_tests/scenarios/<type>/<name>/`:

- **Scenarios** (descriptive `<aspect>.md` filenames, `tier` in
  `{structural, trigger, behavioural}`) — falsifiable assertions
  about expected behaviour. Authored by the `tdd-agent` in its
  agent-artefact branch.
- **Findings** (`FINDING-<aspect>.md` filenames, `tier: finding`) —
  documentary architectural notes. Authored manually by the human
  designer when the component surfaces an architectural question
  that genuinely cannot be expressed as a falsifiable scenario
  today.

A finding **does not satisfy** the HARNESS constraint — it is
documentary, not falsifiable. A new component with only a finding
is not adequately covered.

When the design surfaces a hard question that cannot yet be
falsified, author **both** a scenario (covering what *can* be
asserted) and a finding (capturing what cannot, with rationale).
Findings serve the same purpose as `## Notes` sections in specs:
they preserve the question so future readers see it.

For an example of a finding in production, see
[`tdad_tests/scenarios/commands/harness-init/FINDING-command-tdab-gap.md`](../../../tdad_tests/scenarios/commands/harness-init/FINDING-command-tdab-gap.md).

---

## Output of a TDAD-aware design pass

When this skill is invoked during spec-writing or brainstorming, the
output is a brief **Component design** section that the spec carries
explicitly. The section answers the five questions above:

```markdown
## Component design

- **Type**: skill | agent | command | backing script
- **Justification**: why this type rather than the alternatives
  (one sentence)
- **TDAD layers targeted**: [structural, trigger, behavioural,
  finding] — explicit list, even if the agent's defaults match
- **Scenario shape**: one sentence describing what the `Then` clause
  will assert
- **Modification or new?** new | modification of <component-name>
- **Scenario vs finding**: scenario | scenario + finding | finding-only
  (with rationale if not the default scenario-only)
```

The spec-first pipeline then carries this section into the diaboli
review (which can object to the type-justification or the
layer-targeting), the cartograph review (which can surface
alternatives the section did not consider), and the tdd-agent's
agent-artefact branch (which uses the section as the authoring
guide).

The section is short by design — it names the design choices, it
does not re-justify them. The justification lives in the spec's
prose.

---

## What this skill does NOT cover

- **The mechanics of authoring a skill, agent, or command** — see
  the `plugin-dev` plugin's `agent-development`,
  `skill-development`, `command-development`, and
  `hook-development` skills for those.
- **The mechanics of authoring a TDAD scenario** — see
  [`tdad_tests/README.md`](../../../tdad_tests/README.md) for the
  scenario format, frontmatter fields, and corpus conventions.
- **Test execution** — the skill is design-time guidance; running
  tests is the job of the `tdad-tests-fast.yml` CI workflow and
  the local `pytest` invocations documented in `tdad_tests/README.md`.
- **Validation of design quality** — that's the `/diaboli`
  adversarial review's job. This skill names the questions; the
  diaboli judges whether the answers are good.

---

## Where to learn more

- [TDAD docs page](../../../docs/tdad/index.md) — the methodology
  end-to-end, including how it integrates with the orchestrator
- [`tdad_tests/README.md`](../../../tdad_tests/README.md) — the
  runnable test suite, layer-by-layer status, and scenario format
- [Orchestrator-TDAD-discipline design spec](../../../docs/superpowers/specs/2026-05-09-orchestrator-tdad-discipline-design.md)
  — the spec that introduced the orchestrator's step 1c, the
  `tdd-agent`'s agent-artefact branch, and the constraints
- [Command-TDAD-testing design spec](../../../docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md)
  — the per-category strategy for testing the plugin's commands
- The `plugin-dev` plugin's component-authoring skills (separate
  marketplace plugin, listed in the user-invocable skill catalogue
  as `plugin-dev:agent-development` etc.) — for the *shape* of
  each component type
