---
component: harness-assay
component_type: skill
tier: structural
---

# Scenario: the harness-assay skill carries the methodology, not the agent

## Given

Model-mediated components derive their substantive behaviour from a driving
skill; the agent's prose is the shell that loads it at the right time. If the
methodology lives in the agent file, a second consumer — a command's validation
checkpoint, a reviewer, a later slice — has nowhere to read it from.

The methodology here has three parts that are easy to lose: the materiality test
that separates a finding from an observation, the evidence pool with its honesty
flags, and the anti-patterns that turn an assay into a productivity display.

## When

`ai-literacy-superpowers/skills/harness-assay/SKILL.md` is read from the
filesystem.

## Then

**Frontmatter:** `name: harness-assay`, and a description that triggers on
running or reviewing an assay.

**Body:**

- **The evidence pool** as a table, source by source, with the flag each source
  typically carries — durable artifacts plus the cadence sentinels' records, and
  explicitly **no new telemetry**.
- **An absent source is absent, not empty**, with the per-machine Mast store as
  the worked example.
- **The honesty flags** and the rule they exist for, stated as a blockquote.
- **The materiality test**, as the six-item list, with an example of something
  immaterial.
- **Classification**, noting that it carries real downstream cost — tier-2
  classifications need four extra sections and `harness-loop` needs two distinct
  assays — so it is chosen at the layer that owns the behaviour rather than the
  layer that feels most decisive.
- **The anti-proliferation rule** as a table of existing owners and their
  questions, with the distinction that they audit rules that already exist while
  the assay governs the act of changing one.
- **The report's six sections**, and why the cost estimate is load-bearing: it
  becomes `proposed_cost`, the exact text the validator refuses a copy of.
- **`no-change` as a first-class outcome**, with the Findings section still
  required to be non-empty.
- **Anti-patterns**: proposing to look comprehensive, collapsing intended and
  actual, carrying findings forward, resolving a conflict, and writing.
