# tdad_tests

TDAD test suite for the ai-literacy-superpowers plugin — Test-Driven
Agentic Discipline applied to the plugin's own components. Lives
outside the packaged `ai-literacy-superpowers/` directory so it does
not ship with plugin installs.

The suite started as a spike against three representative components
(one agent, one skill, one command) to validate the three-layer
architecture. The spike landed; this directory now carries the runnable
suite plus the scenario corpus needed to scale to the rest of the
plugin's ~71 components incrementally.

## Why this exists

The plugin's `harness-engineering` skill describes Test-Driven Agentic
Behaviours (TDAB, after Antony Marcano 2026) — TDD applied to skills,
agents, and commands. Today the discipline is described but not applied:
~99% of plugin components are *unverified* by the framework's own
promotion ladder (Theme #10).

This suite promotes components from **unverified** to **agent-verified**.

## The four layers

| Layer | What it tests | Cost | Cadence | Determinism |
| --- | --- | --- | --- | --- |
| **0. Deterministic plumbing** | Bash scripts and parser library the agents depend on (reflection-log archival, migration proposals, helper functions) | $0 / no LLM | every PR | deterministic |
| **1. Structural** | Frontmatter well-formed, required sections present, cross-references resolve | $0 / no LLM | every PR | deterministic |
| **2. Trigger** | Skill descriptions match the queries they should fire on (catches description drift) | ~1 inference / test | every PR | mostly deterministic |
| **3. Behavioural** | Run agent/skill in fixture, assert outputs (TDAB proper) | full SDK invocation / test | nightly + label-gated | probabilistic |

The four layers map directly to the framework's harness promotion
ladder (Theme #10): Layer 0 is the deterministic tier; Layers 1–3
together cover the agent-verified tier (with Layer 1 deterministic in
practice but addressing agent-related artefacts).

Layers 0–1 run offline. Layers 2–3 require an Anthropic API key
(`ANTHROPIC_API_KEY`) and are skipped if absent.

## Layout

```text
tdad_tests/
├── README.md                              this file
├── pyproject.toml                         dependencies
├── conftest.py                            pytest fixtures
├── runner/
│   ├── plugin.py                          plugin component discovery
│   ├── scenario.py                        markdown scenario parser
│   └── sdk.py                             Claude Agent SDK helpers (L2/L3)
├── spike_helpers/                         Phase 2 Option C helpers (test-stage)
│   ├── convention_sync.py                 HARNESS.md → Cursor conventions.mdc
│   └── observatory_verify.py              snapshot signal verification
├── scenarios/                             human-readable scenarios (L1-L3)
│   ├── agents/spec-writer/
│   ├── skills/cupid-code-review/
│   └── commands/harness-init/
├── fixtures/                              L1-L3 test inputs
│   └── cupid-violations/
├── layer0_deterministic/                  bash test scripts + their fixtures
│   ├── test-reflection-log-helpers.sh
│   ├── test-archive-promoted-reflections.sh
│   ├── test-migrate-reflection-log.sh
│   └── fixtures/                          11 reflection-log fixture files
└── tests/
    ├── test_layer0_deterministic.py       pytest dispatcher for the bash tests
    ├── test_layer1_structural.py          offline
    ├── test_layer2_triggers.py            needs API key
    └── test_layer3_behavioural.py         needs API key
```

## Running

```bash
# from the tdad_tests/ directory
pip install -e .

# Layer 1 only (offline, free):
pytest tests/test_layer1_structural.py -v

# All layers (needs ANTHROPIC_API_KEY):
export ANTHROPIC_API_KEY=...
pytest -v
```

## What the suite covers today

The three target components were chosen to exercise different
characteristics:

- **spec-writer (agent)** — has a clear input/output shape (a feature
  description in, a `spec.md` file out with required sections). Layer 3
  is straightforward.
- **cupid-code-review (skill)** — model-mediated loading. Layer 2
  (description match) and Layer 3 (output rubric) both apply.
- **harness-init (command)** — interactive, multi-step, dispatches
  subagents. Layer 3 surfaces an architectural question: how do you
  apply TDAB to a slash command? See issue #284.

The third component is deliberately the awkward case. The spike
validated agents and skills cleanly and surfaced commands as needing
their own design pass.

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

### ai-literacy-superpowers plugin

| Component / area | Layer 0 | Layer 1 | Layer 2 | Layer 3 |
| --- | --- | --- | --- | --- |
| reflection-log plumbing | ✅ 23 bash tests via dispatcher | n/a | n/a | n/a |
| All shipped shell scripts | ✅ `bash -n` syntax check (every `.sh` in scripts/, scripts/lib/, hooks/scripts/) | n/a | n/a | n/a |
| `hooks/hooks.json` | n/a | ✅ structural (manifest schema + every command script resolves) | n/a | n/a |
| spec-writer | n/a | ✅ structural | n/a (agent, not skill) | ✅ implemented (gated on API key) |
| cupid-code-review | n/a | ✅ structural | ✅ trigger tests | ✅ implemented + LLM-as-judge rubric (gated on API key) |
| literate-programming | n/a | ✅ structural | ✅ trigger tests (4 queries) | not yet (case-by-case) |
| secrets-detection | n/a | ✅ structural | ✅ trigger tests (4 queries) | not yet (case-by-case) |
| dependency-vulnerability-audit | n/a | ✅ structural | ✅ trigger tests (4 queries) | not yet (case-by-case) |
| github-actions-supply-chain | n/a | ✅ structural | ✅ trigger tests (4 queries) | not yet (case-by-case) |
| docker-scout-audit | n/a | ✅ structural | ✅ trigger tests (4 queries) | not yet (case-by-case) |
| All 25 commands | n/a | ✅ structural + wiring (Phase 1) | n/a | per-category strategy in spec — see [design](../docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md) |
| 10 of 11 procedural commands | n/a | ✅ structural | n/a | ✅ Option C-direct test-stage helper per command |
| `/worktree` (procedural, deliberate skip) | n/a | ✅ structural | n/a | helper would only wrap git; see `spike_helpers/__init__.py` |
| 6 of 7 orchestration commands (Phase 3 matrix) | n/a | ✅ structural + wiring + per-command dispatch matrix | n/a | inherits from agents (Layer 3 covers each agent) |
| All 7 model-mediated commands (Phase 4) | n/a | ✅ structural + wiring + per-command skill-coverage matrix | n/a | per-skill Layer 3 deferred (case-by-case per design spec) |

### model-cards plugin

| Component / area | Layer 0 | Layer 1 | Layer 2 | Layer 3 |
| --- | --- | --- | --- | --- |
| All components (1 agent, 1 skill, 1 command) | n/a | ✅ structural + wiring | ✅ trigger tests on the model-cards skill (cross-plugin index) | not yet — plugin is small enough that matrices would be overkill |

Layer 1 runs offline and passes against the real plugin. Layer 2 and
Layer 3 are implemented and exercise the Claude Agent SDK. They run
when ``ANTHROPIC_API_KEY`` is exported in the environment; without the
key, they skip with a clear message.

## Cost expectations (when API key is set)

Approximate per-run token cost based on Anthropic's published pricing
(snapshot — see Theme #11 of the framework on vendor velocity):

- Layer 0 bash dispatcher: $0, ~3 seconds wall-clock
- Layer 1 structural: $0, sub-second wall-clock
- Layer 2 trigger tests: ~28 inferences against Haiku across 6 skills, ~$0.03 total
- Layer 3 spec-writer: 1 multi-turn run against Sonnet, ~$0.05–$0.10
- Layer 3 cupid-code-review: 1 review run + 1 judge run, ~$0.05

A full Layer 0+1+2+3 run is around $0.10–$0.20. Tier execution is
recommended for CI: Layers 0–1 on every PR (free, fast), Layer 2+3
nightly or label-gated.

## Coverage gaps and deferrals

The TDAD suite covers **everything below Layer 3** for both plugins.
Layer 3 (full SDK behavioural testing) is deliberately partial — the
design spec at
[`docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md`](../docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md)
flagged it as case-by-case opt-in because per-skill cost varies and
some failure modes don't justify the API spend.

**Documented opt-ins (Layer 3 not yet built):**

- 12 of 13 ai-literacy-superpowers agents — Layer 3 has been built for
  spec-writer; the others inherit through the agent-verified tier of
  the framework's promotion ladder. Add Layer 3 case-by-case when an
  agent has a clear assertable side-effect (e.g., harness-discoverer's
  scan output).
- 30 of 31 ai-literacy-superpowers skills — Layer 3 has been built for
  cupid-code-review (the canonical pattern). Per-skill Layer 3
  decisions belong in their own spec each.
- All 1 of 1 model-cards components — plugin is small; structural
  coverage is sufficient.

**Phase 3 procedural rollout — complete:**

- 10 of 11 procedural commands now have test-stage Option C-direct
  helpers under `spike_helpers/`. The 11th — `/worktree` — is wholly
  git operations and a Python wrapper would test git rather than
  command logic; it is deliberately skipped with rationale in
  `spike_helpers/__init__.py`. Layer 1 wiring still covers it.

**Genuine architectural exclusion:**

- `superpowers-init` orchestrates *other slash commands* rather than
  dispatching agents directly. The Phase 3 dispatch matrix
  deliberately excluded it. A "command-references-other-commands"
  matrix could be added as a Phase 5 if drift in this area becomes a
  real failure mode.

## Issue

Tracked at #281.
