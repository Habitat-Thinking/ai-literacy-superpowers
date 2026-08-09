---
component: coda
component_type: agent
tier: structural
---

# Scenario: coda returns records and never writes them — tool boundary and charter

## Given

The `coda` agent (spec
`docs/superpowers/specs/2026-08-09-cadence-sentinels-s2-coda-design.md`)
closes a session: it surveys what landed and what is still live, proposes a
thread grouping, and drafts one parking record per thread.

Every one of those outputs is durable content destined for a committed file —
which is exactly why the agent must not be the thing that writes it. The
`/coda` command persists what the agent returns, after the human confirms.
That is the `cost-estimator` precedent, and it is what keeps the Coda inside
the sentinel category rather than merely adjacent to it.

## When

The agent file at `ai-literacy-superpowers/agents/coda.agent.md` is read
directly from the filesystem.

## Then

**Frontmatter:**

- YAML frontmatter with `name: coda` and a non-empty `description`.
- `role: sentinel`.
- `tools` is exactly `Read, Glob, Grep, Bash` — **no `Write`, no `Edit`**.
  `sentinel-integrity-check.sh` enforces this deterministically; the scenario
  states *why* it is load-bearing rather than incidental.

**Charter / body:**

- Instructs the agent to read `skills/coda/SKILL.md` **first** and inherit its
  grounding rather than re-derive it.
- States that it returns parking-record content as a string and that the
  command persists it.
- States that `Bash` is for reading only — `git log`, `git status`,
  `gh pr list`, `date` — never a mutation, a commit, or a `gh pr merge`.
- Carries the per-item honesty table: commits and working-tree state
  `observed`; `gh` reads `observed` on success and `inferred` on failure;
  thread grouping `asked`.
- States that thread grouping is proposed and **default-accepted** — it stands
  unless the human changes it.
- States that the next-action check **asks once more and never refuses**, and
  that whatever the human answers is parked, including the same words again.
- States the four things it never does: write a file, decide the session
  should end, continue the ritual after being asked to stop, and record *why*
  the human stopped.

## Rubric

Layer 1 structural scenario: every assertion is checkable by reading the agent
file. It passes only when the tool list carries no write capability, the skill
is read first, the honesty table is present with grouping flagged `asked`, and
the never-refuse and never-record-why disciplines are both stated.

## Notes

Scope is the agent's structural shape. The anchor grammar's behaviour is
covered deterministically by `tdad_tests/layer0_deterministic/test-next-action.sh`
(N1–N8), and the ritual's step ordering by the command scenario.
