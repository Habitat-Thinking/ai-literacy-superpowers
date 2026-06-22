---
component: advocatus-diaboli
component_type: agent
tier: structural
---

# Scenario: the diaboli declares its rubric-bearing-adversary role in the adversarial-review workflow without relaxing its trust boundary (AC-5 / FR-6)

## Given

The file
`ai-literacy-superpowers/agents/advocatus-diaboli.agent.md` — its body text
and its frontmatter `tools`.

## When

The agent doc is read.

## Then

- It states that in the **`adversarial-review`** workflow the diaboli is the
  **rubric-bearing adversary** — the agent that evaluates the diff against
  the CUPID + literate rubric. The token `adversarial-review` and the phrase
  "rubric-bearing adversary" both appear. Keep "rubric-bearing adversary"
  **on one line** (the content test asserts it as one substring).
- It states this role **does not relax its existing read-only trust
  boundary** — dispositions remain the human's job.
- The frontmatter `tools` remains **read-only**: `Read, Glob, Grep` only —
  **no `Write`, no `Edit`, no `Bash`**. This is already true today and must
  **stay** true.

## Rubric

Deterministic structural assertion (AC-5, umbrella D5). The diaboli is the
adversary in the adversarial-review workflow, and S4's only addition is the
*declaration* of that role. The load-bearing guarantee is that the
declaration does **not** widen the diaboli's tool boundary: the read-only
trust boundary is what makes the human-cognition gate on dispositions real.
The existing spec-mode/code-mode charter is unchanged.

The tool-set check is GREEN today and must STAY green — asserting it here
guards against a workflow-mode edit accidentally granting Write/Bash.

## Evaluation

Evaluated deterministically by
`tests/test_s4_adversarial_deepresearch_structural.py`
(`TestS4AdvocatusDiaboliWorkflowRole`). The rubric-bearing-adversary
declaration is RED now (the agent doc does not yet mention the
`adversarial-review` workflow or the rubric-bearing-adversary role); the
read-only tool assertion is GREEN now and stays green.
