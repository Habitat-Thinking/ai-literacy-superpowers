# tests-external

External test suite for the ai-literacy-superpowers plugin. Lives outside
the packaged `ai-literacy-superpowers/` directory so it does not ship with
plugin installs.

This is a **spike** — minimal scaffolding for a three-layer architecture,
exercised against three representative components. Spike outcomes inform
whether to scale to the full plugin (~71 components).

## Why this exists

The plugin's `harness-engineering` skill describes Test-Driven Agentic
Behaviours (TDAB, after Antony Marcano 2026) — TDD applied to skills,
agents, and commands. Today the discipline is described but not applied:
~99% of plugin components are *unverified* by the framework's own
promotion ladder (Theme #10).

This suite promotes components from **unverified** to **agent-verified**.

## The three layers

| Layer | What it tests | Cost | Cadence | Determinism |
| --- | --- | --- | --- | --- |
| **1. Structural** | Frontmatter well-formed, required sections present, cross-references resolve | $0 / no LLM | every PR | deterministic |
| **2. Trigger** | Skill descriptions match the queries they should fire on (catches description drift) | ~1 inference / test | every PR | mostly deterministic |
| **3. Behavioural** | Run agent/skill in fixture, assert outputs (TDAB proper) | full SDK invocation / test | nightly + label-gated | probabilistic |

Layer 1 runs always. Layers 2–3 require an Anthropic API key
(`ANTHROPIC_API_KEY`) and are skipped if absent.

## Layout

```text
tests-external/
├── README.md                              this file
├── pyproject.toml                         dependencies
├── conftest.py                            pytest fixtures
├── runner/
│   ├── plugin.py                          plugin path discovery
│   └── scenario.py                        markdown scenario parser
├── scenarios/                             human-readable scenarios
│   ├── agents/spec-writer/
│   ├── skills/cupid-code-review/
│   └── commands/harness-init/
├── fixtures/                              test inputs
│   └── cupid-violations/
└── tests/
    ├── test_layer1_structural.py          offline
    ├── test_layer2_triggers.py            needs API key
    └── test_layer3_behavioural.py         needs API key
```

## Running

```bash
# from the tests-external/ directory
pip install -e .

# Layer 1 only (offline, free):
pytest tests/test_layer1_structural.py -v

# All layers (needs ANTHROPIC_API_KEY):
export ANTHROPIC_API_KEY=...
pytest -v
```

## What the spike validates

The three target components are chosen to exercise different
characteristics:

- **spec-writer (agent)** — has a clear input/output shape (a feature
  description in, a `spec.md` file out with required sections). Layer 3
  is straightforward.
- **cupid-code-review (skill)** — model-mediated loading. Layer 2
  (description match) and Layer 3 (output rubric) both apply.
- **harness-init (command)** — interactive, multi-step, dispatches
  subagents. Layer 3 surfaces an architectural question: how do you
  TDAB a slash command?

The third component is deliberately the awkward case. If the spike
demonstrates a clean path for it, the architecture scales. If not, the
spike has done its job by surfacing the gap.

## Scenario format

Layer 2 and Layer 3 tests are driven by markdown scenario files with
structured frontmatter. The format is human-readable by design — the
intent is that anyone proposing a new plugin component writes its
scenario alongside the component itself.

```markdown
---
component: spec-writer
component_type: agent
tier: behavioural
fixture: empty-repo
---

## Given
An empty repository with no specs/ directory.

## When
The spec-writer agent runs with feature description "Add authentication".

## Then
- File `specs/auth/spec.md` exists
- Contains a User Stories section
- Contains acceptance scenarios in Given/When/Then format
- Contains numbered functional requirements (FR-001+)

## Rubric
The acceptance scenarios should be testable in principle —
each Then clause should be checkable mechanically, not an opinion.
```

A small Python runner (`runner/scenario.py`) parses these and
dispatches via the Claude Agent SDK.

## Status

| Component | Layer 1 | Layer 2 | Layer 3 |
| --- | --- | --- | --- |
| spec-writer | ✅ structural | n/a (agent, not skill) | wired (needs API key) |
| cupid-code-review | ✅ structural | wired (needs API key) | wired (needs API key) |
| harness-init | ✅ structural | n/a (command) | **architectural gap — see scenarios/commands/harness-init/FINDING-command-tdab-gap.md** |

Layer 1 has been run and passes against the real plugin. Layer 2 and
Layer 3 wiring has been validated structurally (imports, fixture
loading, scenario parsing) but not yet exercised against a live API —
deferred to follow-up work.

## Issue

Tracked at #281.
