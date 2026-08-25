# The target binds at the gate — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #557
**Provenance:** deferred deliberately in the #551 spec (§4). The evidence below
was gathered before this spec was written and changes the conclusion that ticket
reached.
**Scope:** where `target` is set, and by whom.
**Out of scope:** #558.

## 1. Problem statement

`harness-decision-records.md` says:

> **`target`** … binds at **acceptance** rather than at proposal because the
> Assayer frequently identifies a behaviour without knowing which of four agent
> files should own it. That is the human's decision, made at the gate beside the
> cost.

The code fixes `target` at proposal, copied verbatim from an append-only assay,
and `/harness-accept` has no way to set one.

**The documented workflow is therefore impossible**, not merely inconvenient.
Observed: an `agent-instruction` finding that names no target proposes cleanly,
and then

```text
FAIL: <record>: classification 'agent-instruction' has no route and the HDR
      names no 'target'.
FAIL: acceptance refused; nothing was written and the HDR is still proposed.
```

with no flag that can supply one. The record is permanently unacceptable. The
only exits are a new assay finding that guesses a target, or supersession.

This is broader than the mis-targeting #551 exposed. #551 made a *wrong* target
refuse; this is a *missing* target that the reference says is the normal case.

### Why the ticket's preferred option was wrong

#557 leaned toward `--target` on `/harness-propose`, on the reasoning that a
correction before approval is cleaner than a change at the gate.

That contradicts the documented rationale and does not solve the case. If the
Assayer cannot know which of four agent files owns a behaviour, neither can
whoever drafts the record thirty seconds later; the person who can decide is the
one reading the rule at the gate, next to its cost. Moving the choice earlier
moves it away from the moment the decision is actually being made.

## 2. Decision — `/harness-accept --target`

The approver may supply the target at the acceptance gate. This implements the
documented contract rather than changing it.

Three refusals keep it narrow:

- **A routed classification refuses `--target`.** `target_of` prefers the route,
  so a target would be silently ignored — and silently discarding what someone
  wrote is what #551 was about. It refuses rather than accepting a value it will
  not use.
- **The target must be able to host the rule** — the `.md` check from #551,
  reused rather than duplicated.
- **The artifact must exist.** Unchanged; the Registrar writes records, not
  governance documents.

### Provenance is recorded

Where the approver sets a target that differs from the one the assay named, the
Assayer's is preserved as `proposed_target` and the approver's goes in `target`.

This is the `proposed_cost` / `cost` pattern, applied a third time, and for the
same reason: two people contributed to one record and a reader should be able to
tell which part came from whom. Where the assay named no target, there is nothing
to preserve and no `proposed_target` is written.

### The objection, recorded rather than dismissed

Letting the approver retarget at the gate lets a rule be moved to wherever it
applies cleanly, which is a cousin of reclassifying to clear a threshold.

It is a weaker cousin. Reclassification changes the *evidentiary bar* a rule must
clear — that is what the two-assay threshold turns on. Retargeting changes which
prose document hosts the text, and since #551 that document must be markdown, so
the range of "somewhere it applies cleanly" is small and every option is a
governance artifact. The provenance field makes the move visible either way.

## 3. Acceptance criteria

- **A1** — a record with no `target` and an unrouted classification can be
  accepted with `--target`, and the rule is applied there.
- **A2** — without `--target`, that record still refuses, with the existing
  message. Unchanged.
- **A3** — `--target` on a record whose classification is **routed** refuses, and
  says the route decides.
- **A4** — `--target` naming a non-markdown artifact refuses, reusing #551's
  message.
- **A5** — `--target` naming an artifact that does not exist refuses.
- **A6** — where the assay named a target and the approver overrides it, the
  record carries `proposed_target` with the assay's value and `target` with the
  approver's.
- **A7** — where the assay named no target, no `proposed_target` is written.
- **A8** — a refusal writes nothing: the record stays `proposed` and the corpus is
  byte-identical.
- **A9** — accepting without `--target` is unaffected in every other respect.
- **A10** — the existing corpus passes `/harness-check`.

## 4. Version

Behaviour change to plugin files: minor bump, `0.85.0` → `0.86.0`.
