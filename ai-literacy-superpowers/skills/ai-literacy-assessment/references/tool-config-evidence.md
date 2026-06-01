# Tool config as habitat evidence

Reference for reading parallel-tool configuration files as additional
evidence of habitat maturity. Consumed by the `assessor` agent's Phase
1b and the `harness-discoverer` agent.

A project that expresses its conventions through `.cursor/rules/` or
`.github/copilot-instructions.md` is not at "no harness" maturity — it
has expressed harness control through whichever AI tool surface its
team uses. The assessor must read those surfaces as parallel evidence
sources. A project with rich tool configs but no `HARNESS.md` is
*expressing harness elsewhere*, not absent it.

## What's in scope

Four parallel-tool config surfaces, plus common custom-tooling
locations.

| Surface | Path pattern | Signal |
| --- | --- | --- |
| Cursor rules | `.cursor/rules/*.md`, `.cursor/rules/*.mdc` | Cursor-specific convention rules |
| Copilot instructions | `.github/copilot-instructions.md` | GitHub Copilot CLI / Copilot Chat instructions |
| Windsurf rules | `.windsurf/rules/*.md`, `.windsurf/rules.md` | Windsurf-specific convention rules |
| Multi-tool standard | `AGENTS.md` (when used as the primary tool-instruction file) | Cross-tool agent instructions |
| Custom tooling | `.ai/`, `.llm/`, `tools/ai/`, `scripts/ai/` (project-specific) | Bespoke AI configuration the team has built |

The first four are conventional. Custom tooling locations are
project-specific — discovery surfaces them as candidates and the user
confirms.

## Content markers

A path-only match is a *candidate*. Confirm with content markers per
surface.

### Cursor rules content markers

Match if the file contains:

- A `globs:` field in YAML frontmatter (Cursor `.mdc` convention)
- A `description:` field in YAML frontmatter
- Direct rule statements: "Always…", "Never…", "Prefer…", "Use…"
- References to `.cursor/rules/` cross-references between rule files

A `.cursor/rules/` directory with at least one file matching two of
these is real evidence of habitat expression.

### Copilot instructions content markers

Match if `.github/copilot-instructions.md` contains:

- Direct address: "When suggesting", "When reviewing", "Do not suggest"
- Convention statements covering naming, structure, error handling
- References to specific commands the team uses (build, test, lint)

### Windsurf rules content markers

Match if `.windsurf/rules.md` or `.windsurf/rules/*.md` contains:

- Cascade rules, workflow rules, or memories sections
- Direct address to the AI

### AGENTS.md as multi-tool standard

The same content markers as the AGENTS.md entry in
`habitat-discovery.md`. The distinction here is *contextual*: if the
project has both `AGENTS.md` and other tool configs, AGENTS.md may be
serving as the cross-tool standard. The assessor should note both
roles when relevant.

## What this evidence signals

Tool-config evidence is **Level 3 (habitat) signal** in the ALCI
framework. A project with rich `.cursor/rules/` is expressing the
"context engineering" discipline through Cursor's surface — the same
discipline `HARNESS.md` and `CLAUDE.md` express through the Claude
surface. The level-3 indicators in the `ai-literacy-assessment` SKILL
recognise either.

A project with parallel-tool configs and *also* a `HARNESS.md` is at
the same level as one with `HARNESS.md` alone — multiple surfaces
expressing the same discipline don't compound into a higher level.
But a project with parallel-tool configs and *no* `HARNESS.md` is
*not* at "no habitat"; it is at "habitat expressed elsewhere", which
is Level 3 for context engineering.

## What tool-config evidence does NOT signal

- **Architectural constraints** (the L3 architectural-constraints
  discipline). Tool configs typically express conventions, not
  enforced constraints. A `.cursor/rules/` file saying "use camelCase"
  is convention; a CI workflow blocking PRs that use snake_case is a
  constraint. The assessor must distinguish.
- **Compound learning** (the L3 compound-learning discipline). Tool
  configs are usually static; reflection-based learning is not. A
  project with `.cursor/rules/` but no `REFLECTION_LOG.md` is at L3
  context but not L3 compound learning.
- **Sophistication** (orthogonal to surface coverage). Whether a tool
  config expresses sophisticated state-based orchestration or simple
  conventions is a separate question — see
  `sophistication-markers.md`.

## Where this reference is consumed

- `agents/assessor.agent.md` Phase 1b — adds tool-config scanning as
  a new source class
- `skills/ai-literacy-assessment/SKILL.md` Level 3 indicators —
  recognises tool-config evidence as parallel to `HARNESS.md` /
  `CLAUDE.md`
- `agents/harness-discoverer.agent.md` step 5 — surfaces tool-config
  evidence as part of the discovery report

Inline duplication of these paths or markers across the consumers is
forbidden. Edits live in this file.

## Operational axes (ALCI Part D)

For the four operational-axes evidence signals (Composition, Testing,
Observability, Governance), see `references/operational-axes.md` — the
single, self-contained source for the axes, their L1–L5 markers, the
evidence map, and the Habitat Build Gap. Governance-axis evidence
overlaps with the governance constraint/enforcement signals here; cite
each governance signal once, under the Governance axis.
