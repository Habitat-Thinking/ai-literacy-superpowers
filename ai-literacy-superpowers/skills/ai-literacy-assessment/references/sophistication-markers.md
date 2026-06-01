# Sophistication markers

Reference for distinguishing sophisticated capabilities from simple
ones when scanning hooks, scripts, agents, and commands. Consumed by
the `assessor` agent's Phase 3 scoring.

Surface counts mislead. A project with *one* sophisticated state-based
orchestration script and *zero* simple bash hooks is not at the same
maturity as a project with *ten* simple bash hooks and *no*
orchestration. The assessor's level determination must reflect the
difference.

This reference defines the sophistication markers per artefact type
and how they feed level determination.

## Principle

Surface counts (script count, hook count, agent count, command count)
remain useful as a *first cut* but are insufficient for the level
determination. The level determination factors in **content shape** —
what the artefact actually does — alongside surface presence.

The assessor is conservative on level shifts. New sophistication
markers are surfaced explicitly in the assessment document so a
reader can audit why a level was assigned. The markers are never
silent; the assessor cites which patterns it found and where.

## Hooks

### Simple-hook markers

A simple hook:

- Single shell command or short script (≤ 30 lines)
- No state files referenced
- No conditional dispatch on event type
- No error recovery beyond exit-on-error
- Hardcoded paths and tools

Most projects start here. There's nothing wrong with simple hooks —
they're often the right shape. They just don't signal Level-4-grade
sophistication.

### Sophisticated-hook markers

A sophisticated hook is identified by **two or more** of:

- **State references**: reads from or writes to state files
  (`.state/`, `state.json`, `/tmp/state-*`, project-local state
  directory)
- **Conditional dispatch**: branches on event type, tool name, file
  pattern, or argument shape (`case`, `switch`, `if-then-else` with
  three or more arms)
- **Lifecycle awareness**: handles multiple lifecycle stages
  (PreToolUse + PostToolUse + Stop, or equivalent), with transitions
  between them
- **Error recovery**: `set -euo pipefail`, `trap` for cleanup,
  retry logic, fallback paths
- **Configurability**: reads config from environment, project file,
  or command-line argument; behaviour changes with config without
  editing the script
- **Observability**: emits structured logs, metrics, or status to a
  dashboard surface

Three or more markers is strong sophistication signal. Two markers
is moderate signal — worth surfacing in the assessment but not
necessarily moving the level by itself.

## Scripts

### Simple-script markers

- Single entry point
- Linear top-to-bottom flow
- Hardcoded paths and tools
- No argument parsing beyond positional
- No state, no coordination

### Sophisticated-script markers

A sophisticated script is identified by **two or more** of:

- **Argument parsing**: `getopts`, `argparse`, `click`, `cobra`,
  flag handling that supports subcommands or named options
- **Multiple entry points** or subcommand dispatch
- **State persistence**: writes durable state for other scripts or
  later runs to read
- **Coordination**: invokes other scripts with structured handoff
  (env vars, state files, exit codes interpreted by callers)
- **Error recovery**: explicit error handling beyond exit-on-error;
  rollback or compensating actions
- **Configurability**: reads project-level configuration

## Agents

### Simple-agent markers

- Single-purpose, no guardrails
- Reads inputs, produces output, exits
- No memory references (no `REFLECTION_LOG.md` reads, no `AGENTS.md`
  reads)
- No subagent dispatch
- Trust boundary not declared in frontmatter

### Sophisticated-agent markers

A sophisticated agent is identified by **two or more** of:

- **Guardrails declared**: `MAX_REVIEW_CYCLES`, `MAX_ITERATIONS`,
  cycle escalation paths, or similar bounded-loop discipline
- **State-based orchestration**: explicit state machine, stage
  transitions, or pipeline coordination
- **Memory awareness**: reads `REFLECTION_LOG.md`, `AGENTS.md`,
  recent snapshots, or session-history files before acting
- **Subagent dispatch**: invokes other agents with structured
  context handoff
- **Trust boundary**: explicit `tools:` declaration in frontmatter
  with rationale; non-default tool restrictions
- **Reasoning protocol**: numbered, deliberate steps the agent
  follows, not free-form generation

## Commands

### Simple-command markers

- Single-step invocation
- No validation checkpoint
- No skill cross-reference
- Hardcoded paths

### Sophisticated-command markers

A sophisticated command is identified by **two or more** of:

- **Multi-step orchestration**: numbered process with explicit
  ordering and pre/post conditions per step
- **Validation checkpoint**: read-back-and-verify pattern after
  generation, with fix-in-place semantics
- **Skill cross-reference**: explicitly reads a skill before
  acting, with the skill carrying the methodology
- **Error recovery**: explicit failure handling, rollback, or
  user-confirmation gates
- **Observability**: produces structured output that downstream
  tooling parses

## How sophistication feeds level determination

The ALCI level determination uses the following adjustments based on
sophistication markers:

| Evidence shape | Level signal |
| --- | --- |
| 0–2 hooks/scripts/agents/commands, all simple | L2 maximum (verification-discipline only) |
| 3+ artefacts, all simple | L3 minimum (habitat-discipline emerging) |
| Any artefact with sophisticated markers | +1 level on the discipline that matches the artefact (orchestration sophistication → guardrail-design discipline; state-based hook sophistication → architectural-constraint discipline) |
| Multiple sophisticated artefacts coordinating | L4 evidence (specification architecture) |
| Sophisticated artefacts with telemetry, cost tracking, sovereignty | L5 evidence (sovereign tooling) |

The adjustments are evidence-based and additive — they raise the
floor on a discipline rather than capping it. The weakest discipline
is still the ceiling for the overall level (per the ALCI rule), so
sophistication on one discipline does not raise the overall level
unless the other disciplines also have evidence.

## Surfacing in the assessment document

Every sophistication marker found is cited explicitly in the
"Observable Evidence" section of the assessment document. Format:

```markdown
- **<artefact-name>** (`<path>`): <surface counts> + sophistication
  markers — <list of markers found, with line citations where
  available>
- Example: **post-commit hook** (`.husky/post-commit`): 1 hook +
  state-based orchestration markers — state file at line 12,
  conditional dispatch at lines 25–40, lifecycle awareness across
  PreCommit/PostCommit/PostMerge.
```

The assessment reader can audit the level determination by reading
the cited markers. No silent level shifts.

## Where this reference is consumed

- `agents/assessor.agent.md` Phase 3 (Assess the level) — applies
  these markers to the artefacts found in Phase 1
- `skills/ai-literacy-assessment/SKILL.md` Phase 2 scoring heuristic
  — references this file for the sophistication adjustments

Inline duplication of markers or adjustments across the consumers is
forbidden. Edits live in this file.

## Conservative-stance note

This reference is being introduced incrementally. The assessor uses
sophistication markers to *surface* additional evidence in the
assessment document immediately. The level-adjustment table above is
the target shape; adjustments are applied conservatively at first to
keep assessment deltas explainable across the v0.30.0 → v0.31.0
boundary. As the framework accumulates assessments using these
markers, the adjustments may be tuned or refined.

A reflection capturing observed level shifts after the first few
assessments using this reference is the right next step for tuning.

## Operational axes (ALCI Part D)

The four operational axes — Composition, Testing, Observability,
Governance — and their evidence map live in
`references/operational-axes.md` (the single, self-contained source).
The sophistication markers above feed the axis placements: agent /
orchestration sophistication evidences **Composition**; hook and
script sophistication evidences **Observability** and **Governance**;
test-infrastructure sophistication evidences **Testing**. Cite the same
markers under the axis they evidence in the Operational Axes table.
