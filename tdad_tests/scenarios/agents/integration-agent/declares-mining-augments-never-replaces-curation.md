---
component: integration-agent
component_type: agent
tier: structural
---

# Scenario: the integration-agent declares reflection mining augments, never replaces, human curation (AC-8 / FR-6)

## Given

The file
`ai-literacy-superpowers/agents/integration-agent.agent.md`.

## When

The agent doc is read.

## Then

- The doc states that **reflection mining** **augments**, **never replaces**,
  **human curation** — mining produces a staging shortlist; the human
  `Promoted:`-line curation gate into `AGENTS.md`/`HARNESS.md` is the **only**
  path and is **unchanged**. Keep the words "augments", "replaces", "human",
  and "curation" each **unwrapped**; the content test asserts "mining"
  co-occurring with "augment"/"augments", "replace"/"replaces", and
  "human" + "curation" as independent tokens (NOT a joined "human curation"
  substring). The token `Promoted:` (matched as "promoted") is wrap-safe.
- The note states the human `Promoted:`-line gate is the path into the
  durable curated artefacts and is **unchanged**; the content test asserts
  "promoted" co-occurring with "unchanged"/"only".

## Rubric

Deterministic structural shadow of AC-8 / FR-6. Mining is a *better
proposal*, not a curator. The integration-agent's existing reflection-capture
flow (step 8) and its "Do NOT modify AGENTS.md — only propose" stance are
unchanged; this scenario asserts only that the doc *declares* the
augments-never-replaces note (folded into the Promoted-field convention or as
a sibling note), not that any live curation behaviour is exercised.

The load-bearing specifics:

- mining **augments**, never **replaces** — the human `Promoted:` flow is the
  only path into `AGENTS.md`/`HARNESS.md`, and is unchanged by S6;
- the note participates in the AC-2 immutability triad (the two doc
  declarations plus the already-passing `inv-firewall.sh` over the S2
  template) — the deterministic shadow of "AGENTS.md byte-for-byte unchanged".

## Evaluation

Evaluated deterministically by
`tests/test_s6_reflection_mining_structural.py`
(`TestS6IntegrationAgentAugmentsNotReplaces`). RED now because
`integration-agent.agent.md` contains no augments-never-replaces / reflection
mining note (`grep -in "augment\|mining" agents/integration-agent.agent.md`
returns nothing), so the phrases are absent.
