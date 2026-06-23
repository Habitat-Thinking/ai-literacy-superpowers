---
component: orchestrator
component_type: agent
tier: structural
---

# Scenario: the classification step declares Claude-Code-only scope, non-erroring static fallback, INV-1 propose-only + tools-unchanged, and INV-2 triage quarantine (AC-8, AC-9 / FR-6, FR-7, FR-8)

## Given

The task-classification section of
`ai-literacy-superpowers/agents/orchestrator.agent.md` and its frontmatter
`tools`.

## When

The agent doc is read.

## Then

- The section states the **non-static routes require the Claude Code
  runtime**, and that on a tree without it — **or whenever the opt-in flag
  is off** — the classifier **selects the static pipeline and never errors**
  (the static path is the universal fallback). "Claude Code" is two words —
  keep it **unwrapped** on one line; the content test asserts "claude" +
  "code", "fall back"/"falls back"/"fallback", and "never error".
- The section states every route is **propose-only** — any workflow a route
  spawns **never writes a durable curated artefact** (`HARNESS.md`,
  `AGENTS.md`, `CLAUDE.md`, `MODEL_ROUTING.md`); keep-worthy discovery flows
  through the human-curation gate (**INV-1**). Keep "durable artefact"
  **unwrapped**; the content test asserts "durable" + "propose" co-occurring
  with at least two of the four named artefact tokens.
- The **triage route** states untrusted/public content is read **only by
  low-privilege agents** and that **only separate trusted agents act** on it
  (**INV-2** quarantine). Keep "low-privilege" **unwrapped**; the content
  test asserts "low-privilege" + "trusted" co-occurring with "inv-2"/
  "quarantine".
- The frontmatter `tools` list is **unchanged** — it stays
  `[Read, Write, Edit, Glob, Grep, Bash, Agent, WebFetch]`. The
  classification step adds **no new write capability**. The content test
  reads the current set and asserts it is unchanged (it does **not** assert a
  specific new tool).

## Rubric

Deterministic structural assertion (AC-8 runtime scope + AC-9 INV-1/INV-2),
grounded in the umbrella §5.5 runtime-scope note and the slicing-record
"Runtime scope — Claude Code only" section. Dynamic workflows are a Claude
Code runtime capability, not transferable to Copilot CLI or other agents;
the non-static routes are therefore Claude-Code-gated, and the static path
is the universal fallback (runtime absent **or** flag off → static, never
error). S5 restates the Claude-Code-only nature for the orchestrator's *own*
behaviour; it does **not** decide the precise Copilot degradation contract
(open-question 4, owned by S7).

INV-1: the orchestrator *reads* `HARNESS.md` for the flag — that is an agent
read, not a workflow spelling a durable filename in executable code, so the
firewall does not apply to the agent's own read. The propose-only boundary
binds any *workflow* a route spawns: it never writes one of the four durable
curated artefacts. The tool-set check is GREEN today (the list is unchanged)
and must STAY green through S5 — it is the agent-level INV-1 enforcement.

INV-2: the triage route quarantines untrusted-content readers (low-privilege
agents) from the high-privilege agents that act.

## Evaluation

Evaluated deterministically by
`tests/test_s5_orchestrator_routing_structural.py`
(`TestS5OrchestratorClaudeCodeScopeAndInvariants` for the section
declarations; `TestS5OrchestratorToolsUnchanged` for the tool boundary). The
section declarations are RED now (no classification section); the
tools-unchanged assertion is GREEN now and stays green.
