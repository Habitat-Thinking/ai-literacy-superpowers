# Objection record format

An **objection record** is what the `advocatus-diaboli` produced when it
attacked a spec or an implementation, and what a human decided about each
objection it raised.

Records live in `docs/superpowers/objections/`. They are written by the
orchestrator or the `/diaboli` command from content the agent returns; the
agent is read-only and cannot write them.

**The dispositions are the point.** The agent cannot fill them in — not by
policy but by tool boundary — so every disposition in every record was written
by a person reading the objection. That constraint *is* the
cognitive-engagement gate.

`skills/advocatus-diaboli/SKILL.md` owns the agent's emission rules — the
categories, the severity definitions, the evidence requirements, and the
per-mode weighting. This page is the reader-facing contract and does not
restate them.

## Filename

```text
docs/superpowers/objections/<spec-slug>.md          # spec mode
docs/superpowers/objections/<spec-slug>-code.md     # code mode
```

`<spec-slug>` is the spec's filename with its date prefix and `.md` extension
stripped — the same convention the choice-story and consultation records use,
so one spec resolves to one record of each kind.

```text
docs/superpowers/specs/2026-08-13-retry-semantics-design.md
  → docs/superpowers/objections/retry-semantics-design.md
```

Nothing else belongs in this directory. Two shipped consumers glob
`objections/*.md` as *the complete set of records* — the taxonomy checker,
and the harness snapshot, which counts anything without a `-code` suffix as a
spec-mode record. A stray file lands in four published metrics as a record
with zero objections.

## Frontmatter

```yaml
---
spec: <path to the spec under review>
date: <YYYY-MM-DD>
mode: spec | code
diaboli_model: <model id used>
objections:
  - id: O1
    category: premise
    severity: critical
    claim: <one sentence>
    evidence: <a direct quote or citation from the artefact>
    disposition: pending
    disposition_rationale: null
---
```

| Field | Meaning |
| --- | --- |
| `spec` | The spec under review, in both modes. |
| `date` | The date the record was written. |
| `mode` | `spec` before plan approval, `code` before integration. |
| `diaboli_model` | Which model raised these. Recorded because objection quality is model-dependent. |
| `objections` | One entry per objection. |

### Per-objection fields

| Field | Meaning |
| --- | --- |
| `id` | `O1`, `O2`, … Referenced by choice stories and by later records. |
| `category` | One of six. See below. |
| `severity` | `critical`, `high`, `medium`, `low`. |
| `claim` | One sentence. What is wrong. |
| `evidence` | A direct quote or citation. An objection without evidence is rhetoric. |
| `disposition` | `pending` until a human decides, then `accepted`, `deferred`, or `rejected`. |
| `disposition_rationale` | Why. `null` until disposed. |

## The six categories

| Category | Surfaces |
| --- | --- |
| `premise` | The spec solves the wrong problem, or assumes one that may not exist |
| `scope` | Work included that is unnecessary, or excluded that is necessary |
| `implementation` | A structural flaw independent of whether the problem is real |
| `risk` | A trust, safety, operational, or failure risk created or ignored |
| `alternatives` | A materially better approach exists and is unacknowledged |
| `specification quality` | Ambiguity that would produce divergent implementations |

**These six are canonical and deterministically enforced.**
`scripts/check-objection-taxonomy.py` fails CI on any other value, and on the
retired `design | threat | failure | operational | cost` and `major | minor`
vocabulary that the 2026-04-19 migration replaced. Records dated on or before
that migration are grandfathered.

The same six apply in both modes; only the weighting differs. Spec time
emphasises `premise`, `scope`, `alternatives` and `specification quality`;
code time emphasises `risk` and `implementation`.

### Embedded assumptions

Assumptions an implementation encodes without stating — that the user can see,
that the list is short, that the locale is the author's — are **`risk`
objections raised at code time**, not a seventh category. The skill carries the
hunt-list: usability and accessibility, performance context, requirements
enshrined in tests, and environmental.

An objection here quotes the **artefact line** that encodes the assumption. One
that quotes the spec is a `premise` or `specification quality` objection
instead, because an assumption the spec *states* is not embedded.

Its body ends by offering the four ways it can be answered —
`accept-as-stated`, `revise-spec`, `add-test`, `consciously-carry` — as prose
for the human writing the disposition. **These are framings, not fields.**
Nothing checks them, and `disposition` keeps its three values.

`consciously-carry` is a complete answer. An assumption carried knowingly is
strictly better than the same assumption carried invisibly.

## The prose body

One `## O<N> — <category> — <severity>` section per frontmatter entry, each
with **Claim**, **Evidence**, and **Why this matters**.

A record also ends with an **Explicitly not objecting to** section. That is
not politeness — it is the disclosure of what was *not* challenged, which is
what stops a silent omission reading as a clean bill of health.

## Records are not append-only

Unlike parking and consultation records, an objection record is **regenerated**
when its spec is substantively revised, and prior dispositions are lost. That
is intentional: a disposition adjudicates an objection against a specific
version of a spec, and carrying it forward would assert a judgement nobody
made about text they never read.

`/diaboli` warns before overwriting.

## The gates

**At plan approval — hard.** The orchestrator refuses to proceed while any
disposition is `pending`. No agent may write one.

**At merge — the `PRs have adjudicated objections` constraint.** Every
objection resolved, or an exemption label claimed.

## See also

- [`/diaboli` reference](commands.md)
- [Consultation record format](consultation-record-format.md) — the Convener's
- [Sentinels](../explanation/sentinels.md)
