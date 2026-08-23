---
component: harness-accept
component_type: command
tier: structural
---

# Scenario: /harness-accept refuses before it asks for a cost

## Given

The cost is the anti-theatre requirement of the whole design: the approver
writes, in their own words, what the rule will demand of whoever works here next
and how it might be gamed. A copy-pasted cost reads exactly like a considered
one, so nothing downstream can tell them apart — which is why the validator
refuses a cost identical to the Assayer's proposal.

Asking someone to compose that for a rule which is about to be refused for
citing a single assay spends precisely the human attention the mechanism exists
to protect. The order is therefore load-bearing, not stylistic.

Acceptance is also the only write transaction in the phase, and two of the
refusals are corpus-level — the cycle cap and the promotion threshold compare
HDRs against each other, so neither can be seen from the candidate alone.

## When

`ai-literacy-superpowers/commands/harness-accept.md` is read from the
filesystem.

## Then

**Frontmatter:** `name: harness-accept`, a description stating that it is
transactional and that a refusal leaves the record proposed.

**Process, in this order:**

1. Refuses an HDR whose status is not `proposed`, on the ground that an accepted
   record is frozen and superseded rather than edited.
2. Shows the human the **full** `## Rule` block, not a summary — that text is
   what goes into force.
3. Runs `harness-registrar.py precheck` and **stops without prompting** when it
   exits non-zero, reporting each refusal with its real options in a table.
4. Only then asks the cost question, verbatim.
5. Passes the cost as `--cost-file`, never as an argument, and says why: shell
   history, one copy-paste from the next HDR.
6. Runs `accept`, then deletes the scratch cost file.

**It must also:**

- Instruct the agent to decline when asked to write the cost, explain that the
  reason is not procedural, and offer discussion rather than words.
- Forbid resolving a refusal by editing the HDR to satisfy it — reclassifying
  after a threshold refusal is the human's decision, not the agent's repair.

**Validation checkpoint:** checks A1–A6, including that the `## Rule` block is
**unchanged** by acceptance (A4, escalated as a defect) and that the `## Cost`
section no longer carries the Assayer's proposal label (A3).

**Boundaries:** states that it writes to no control surface, and that it does
not commit, push, or open a pull request — three gates, none implied by another.
