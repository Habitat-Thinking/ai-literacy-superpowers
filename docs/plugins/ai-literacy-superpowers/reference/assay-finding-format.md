# Assay finding format

An **assay** is a read-only postmortem written by the `harness-assayer` at a
phase boundary. It reads evidence from completed work, classifies what it finds
by ownership, proposes a bounded change set, and stops.

Most of an assay is prose for a human: an executive summary, what worked, what
created friction, rejected candidates, unresolved questions. This page documents
only the part a machine reads — the **finding block** that `/harness-propose`
extracts an HDR from.

Assays live in `harness/assay/<ISO8601>-assay.md` and are append-only. They are
never edited after they are written.

## Who owns this contract

The contract is owned by the Registrar slice and consumed by the Assayer. That
ordering is deliberate: `/harness-propose` has no input without it, and a format
designed by the component that never has to parse it is a format that will not
parse.

Keep it narrow. Everything `/harness-propose` does not read is free prose, and
the Assayer should use that freedom rather than expanding this contract.

## Frontmatter

```yaml
---
assay: harness/assay/2026-08-21T16-02Z-assay.md
date: 2026-08-21
agent: harness-assayer
model: claude-opus-5
---
```

`agent` and `model` are **required** and become the HDR's `proposer` block. An
HDR records which model proposed it because a rule proposed by a model that has
since been replaced is a rule whose evidence deserves re-reading.

## A finding

`````markdown
### finding-3 — Unevidenced completion claims

Claude Code reported the integration suite passing on 2026-08-04 and again on
2026-08-12. The build log records the command being planned on both dates and
never records it running.

```yaml
classification: agent-instruction
enforcement: validated
surfaces: [claude-code, copilot]
priority: P1
evidence:
  - harness/build-log.md#2026-08-04T09-12Z
overfitting_risk: low
```

#### Proposed rule

````markdown
- **Rule**: A phase may not be reported complete on the strength of a planned
  command. Cite observed output.
````

#### Cost estimate

One extra check per phase boundary; roughly two minutes.
`````

### The heading

`### <finding-id> <sep> <Title>`, where `<sep>` is an em dash, en dash or
hyphen, and `<finding-id>` matches `[a-z0-9]+(-[a-z0-9]+)*`.

The id is what `/harness-propose` is given and what the HDR's evidence anchor
points at, so it must be stable within the file.

### The observation

The text between the heading and the metadata block. It becomes the HDR's
`## Finding` section verbatim, and it is **required**.

A finding with no observation is not a finding but a rule with a citation
attached, and the HDR it produced would have nothing to say about what actually
went wrong — which is the entire reason a governance change is asked to cite
evidence.

### The metadata block

A ```` ```yaml ```` block requiring `classification`, `enforcement`, `surfaces`,
`evidence` and `priority`.

`priority` is required even though `/harness-propose` never reads it. A finding
nobody can triage is a finding that will be triaged by whichever one happens to
be listed first.

`target` is **optional**. Include it when the finding already knows which
artifact should own the rule; `/harness-propose` copies it through. Leave it out
when it does not — an Assayer can see that a behaviour belongs to an agent
without knowing which of four agent files owns it, and that decision belongs to
the human at the acceptance gate. It is required there, not here.

### The proposed rule

`#### Proposed rule` holds **exactly one four-backtick block** — the same
delimiter, and the same reason, as the HDR's Rule block. Rule text is markdown
that routinely contains a three-backtick fence of its own, and a three-backtick
delimiter would terminate on the first nested fence and silently truncate the
rule.

This block is copied into the HDR **byte for byte** by
`scripts/harness-registrar.py`, never retyped by an agent.

### The cost estimate

`#### Cost estimate` must be non-empty. It becomes the HDR's `proposed_cost` —
which is precisely what the validator compares the approver's own words against,
and refuses when they match.

So this field has a second job beyond informing the reader: it is the thing a
copy-pasted cost gets caught by. An Assayer that leaves it vague weakens that
check.

### A `no-change` finding

`#### Proposed rule` says `No change.` with no fenced block, `enforcement` is
`advisory`, and `surfaces` may be empty.

An assay in which every finding resolves to `no-change` is a **successful**
assay. Recording that nothing needed to change is itself evidence.

## What `/harness-propose` does with a finding

| HDR field | Source |
| --- | --- |
| `title` | the heading title |
| `## Finding` | the observation, verbatim |
| `classification`, `enforcement`, `surfaces` | the metadata block |
| `target` | the metadata block, when present |
| `evidence` | the metadata `evidence` **plus** `<assay-path>#<finding-id>` |
| `proposed_cost` | the cost estimate, verbatim |
| `## Rule` block | the proposed-rule block, byte for byte |
| `cost` | **empty** — the approver writes it at the gate |

### Why the assay anchor is appended

Every HDR ends up citing at least the assay that proposed it. That makes the
two-assay promotion threshold behave the way it should: a first-time
`harness-loop` finding cites one assay and is refused at acceptance, while a
finding corroborated by a prior assay names that assay in its own `evidence`,
reaches two, and passes.

Without the appended anchor, a finding whose evidence happened to name only
build-log entries would produce an HDR citing zero assays — refused for a reason
that reads like a bug rather than like the threshold doing its job.

## Refusals

`/harness-propose` refuses, writing nothing, when: the assay does not exist or
has no frontmatter `agent`/`model`; there is no `## Findings` section; the
requested finding id is absent; or the finding is missing its metadata block,
its observation, its proposed rule, or its cost estimate.

Findings are parsed **lazily**, one at a time. One malformed finding costs one
finding, not the whole report — an assay is written by an agent under a
materiality test, not by a compiler.

## See also

- Spec: `docs/superpowers/specs/2026-08-23-harness-evolution-s1-registrar-design.md`
- HDR format: `harness-decision-records.md`
- Tests: `tdad_tests/layer0_deterministic/test-harness-registrar.sh`
