---
component: harness-registrar
component_type: agent
tier: structural
---

# Scenario: the Registrar writes governance but never authors it

## Given

Every read-only advisory agent in this plugin carries `role: sentinel`, and
`sentinel-integrity-check.sh` fails CI on a sentinel granted `Write` or `Edit`.

The Registrar holds both. It is therefore not a sentinel, and the danger is not
that someone tags it — CI would catch that — but that its instructions drift
toward doing by hand what the mechanism does by construction. The rule text is
copied verbatim by a script precisely because a model asked to copy usually
copies and occasionally improves, and every improvement is a silent edit to a
rule a human is about to approve as somebody else's words.

An agent that both diagnoses failures and writes the rules can rationalise its
own findings into rules that make its next diagnosis easier. The separation is
the design.

## When

`ai-literacy-superpowers/agents/harness-registrar.agent.md` is read from the
filesystem.

## Then

**Frontmatter:** `name: harness-registrar`, a non-empty description, `tools`
including `Write` and `Edit`, and **no `role:` key at all**.

**Body:**

- States explicitly that it is not a sentinel and must never be tagged as one,
  and gives the reason — it holds write authority and cannot claim a read-only
  trust boundary.
- Names the separation it exists to preserve: the Assayer diagnoses, the
  Registrar legislates.
- Carries the guarantee table: verbatim copy by script, refusals by validator,
  all-or-nothing by staged transaction, cost authored by the approver.
- Instructs the agent **not** to reimplement any of that in prose, and to stop
  if it finds itself about to write rule text, evidence, or a cost by hand.
- Forbids: authoring rule text, editing a `## Rule` block, writing the cost,
  editing an accepted HDR, committing or pushing, and touching any control
  surface.
- States that a refusal is the mechanism working, not a task to be unblocked,
  and that the failure mode to resist is helpfulness.
