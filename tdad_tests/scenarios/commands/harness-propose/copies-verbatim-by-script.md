---
component: harness-propose
component_type: command
tier: structural
---

# Scenario: /harness-propose copies by script, never by hand

## Given

The build spec says `/harness-propose` copies the proposed rule text and
evidence references verbatim. That sentence cannot be delivered by an agent
writing the HDR itself: a model asked to copy text usually copies it and
occasionally tidies it, and a tidied rule is a rule the approver did not
actually read.

The validation checkpoint is required by CLAUDE.md for every command writing
structured markdown a downstream consumer parses. Here the downstream consumers
are a deterministic validator and, later, a compiler that applies the rule block
byte for byte — so a paraphrase is not a cosmetic problem.

## When

`ai-literacy-superpowers/commands/harness-propose.md` is read from the
filesystem.

## Then

**Frontmatter:** `name: harness-propose`, a description stating that the copy is
verbatim and the cost is left for the approver.

**Process:**

- Aborts with a specific message when the assay path does not exist.
- Lists the assay's findings with id, priority, classification and enforcement
  so the human confirms the choice.
- Invokes `harness-registrar.py propose` rather than writing the HDR itself, and
  states in the body that rule text and evidence must **never** be written by
  hand.
- Explains `--slug` as the collision remedy, and that the script never
  overwrites.
- Announces tier-2 placeholders explicitly when the classification is
  `harness-loop`, `script-validator` or `new-agent`, and says that neither the
  Assayer nor the Registrar may write that argument.

**Validation checkpoint:** checks P1–P5, including that `cost` is empty (P2) and
that the `## Rule` block matches the assay's proposed-rule block character for
character (P3), with an instruction to **diff rather than eyeball**.

Crucially, P3 and P4 deviations must be reported as defects and **not fixed in
place** — fixing them in place would be the agent performing exactly the copy
the script exists to prevent.
