# Spec: Harness Evolution S1 — the Harness Registrar, record-keeping only

**Status:** Approved
**Date:** 2026-08-23
**Issue:** #535
**Epic:** Harness Evolution — the Harness Assayer and the Harness Registrar (#533)
**Depends on:** S0 (0.74.0) — the HDR schema and the validator that holds every
refusal.
**Scope:** `ai-literacy-superpowers` plugin — one agent, two commands, one
script, one record contract, one generated index.
**Explicitly out of scope:** applying rule text to any governance artifact,
compiling control surfaces, `/harness-check`, `/harness-review`,
`/harness-timeline`, and importing legacy `HARNESS.md` constraints. All of those
are S2 or later.

**Provenance:** the Harness Assayer / Harness Registrar build spec, supplied in
conversation 2026-08-23. Epic-level decisions recorded on #533.

---

## 1. Problem Statement

S0 built the thing that says *no*. Nothing yet says *yes*.

An HDR has no way to come into existence, no way to travel from `proposed` to
`accepted`, and no index anyone can read. This phase adds exactly that, and
nothing else: the Registrar keeps records. It does not yet touch `HARNESS.md`.

Splitting record-keeping from application is not ceremony. The two failure modes
are different — a malformed record is caught by a validator, whereas a rule
written into the wrong section of `HARNESS.md` is caught by a human reading a
diff — and building them together would mean debugging both at once.

## 2. The sequencing problem, and who owns the assay contract

`/harness-propose <assay> <finding>` consumes an assay. Assays are S3.

The precedent in this repository is the Cadence Sentinels S1 slice, which owned
the record contracts that S2–S5 consumed. **S1 owns the assay-finding
contract**; S3's Assayer writes to it.

The contract is deliberately narrow. It covers only what `/harness-propose`
needs to read: the finding's identifier, its classification, enforcement,
surfaces and evidence, its proposed rule text, and its cost estimate. Everything
else in an assay report — the executive summary, what worked, what created
friction, rejected candidates, unresolved questions — is prose for a human, and
the Registrar never parses it.

Narrowing it this way keeps S3 free to design the report it wants around a small
fixed core, and keeps S1 from inventing an interface for a document it has never
seen.

## 3. The decision that shapes this phase: the copy is deterministic

The build spec says `/harness-propose` "copies evidence references and proposed
rule text verbatim". The epic made the Registrar a **plugin agent**, so the
obvious implementation is: the agent reads the assay and writes the HDR.

That implementation cannot deliver what the sentence promises. A model asked to
copy text usually copies it, and occasionally improves it — fixes a typo, tidies
an inconsistent bullet, rewraps a line. Every one of those is a silent edit to
a rule that a human is about to approve on the understanding that it is the
Assayer's words.

So `/harness-propose` extracts with a script. The rule block and the evidence
list are read out of the assay file and written into the HDR byte for byte, and
the agent never has them in its output at all.

> Verbatim by construction, not verbatim by instruction.

This is the same move S0 made with the refusals, for the same reason, and it
answers the same objection: the Registrar holds write authority, so wherever a
guarantee can be made mechanical rather than instructed, it must be.

**What the agent does instead.** It locates the assay, presents the findings,
confirms which one the human wants, runs the script, reads any refusal back in
plain language, and prompts for the cost. It is the interface, not the
mechanism. Stating this now matters because S2 is where the agent acquires real
judgement — deciding where in `HARNESS.md` a rule belongs — and the boundary
needs to exist before the judgement arrives.

## 4. The assay-finding contract

An assay is a markdown file at `harness/assay/<ISO8601>-assay.md` with
frontmatter and a `## Findings` section.

### 4.1 Frontmatter

```yaml
---
assay: harness/assay/2026-08-21T16-02Z-assay.md
date: 2026-08-21
agent: harness-assayer
model: claude-opus-5
---
```

`agent` and `model` are required, and become the HDR's `proposer` block. An HDR
records which model proposed it because a rule proposed by a model that has
since been replaced is a rule whose evidence deserves re-reading.

### 4.2 A finding

````markdown
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

`````markdown
- **Rule**: A phase may not be reported complete on the strength of a planned
  command. Cite observed output.
`````

#### Cost estimate

One extra check per phase boundary; roughly two minutes.
````

- The heading is `### <finding-id> <sep> <Title>`, where `<sep>` is an em dash,
  en dash, or hyphen, and `<finding-id>` matches `[a-z0-9]+(-[a-z0-9]+)*`.
- The text between the heading and the metadata block is the finding's
  **observation** — what was actually seen — and becomes the HDR's `## Finding`
  section. It is required. A finding with no observation is not a finding but a
  rule with a citation attached, and the HDR it produced would have nothing to
  say about what went wrong.
- The YAML block requires `classification`, `enforcement`, `surfaces`,
  `evidence` and `priority`. `priority` is required not because
  `/harness-propose` needs it but because a finding nobody can triage is a
  finding that will be triaged by whichever one is listed first.
- `#### Proposed rule` holds exactly one four-backtick block — the same
  delimiter and the same reason as the HDR's Rule block (S0 §4.6).
- `#### Cost estimate` must be non-empty. It becomes the HDR's `proposed_cost`,
  which is what the S0 cost rule compares the human's words against.
- For a `no-change` finding, `#### Proposed rule` says `No change.` with no
  fenced block, `enforcement` is `advisory`, and `surfaces` may be empty.

### 4.3 The evidence rule

The HDR's `evidence` list is the finding's `evidence` list, **plus the source
assay anchor** `harness/assay/<file>#<finding-id>`, appended if not already
present.

This guarantees every HDR cites at least the assay that proposed it, and it
makes the S0 two-assay promotion threshold behave exactly as the build spec's
worked cycle describes. A first-time `harness-loop` finding cites one assay and
is refused at acceptance. A finding corroborated by a prior assay cites that
assay in its own evidence, reaches two, and passes.

Without the appended anchor, a finding whose evidence happened to name only
build-log entries would produce an HDR with zero assays — refused for a reason
that would read as a bug rather than as the threshold doing its job.

## 5. `/harness-propose <assay> <finding>`

Writes `harness/decisions/HDR-<today>-<slug>.md` at `status: proposed`.

| HDR field | Source |
| --- | --- |
| `id`, filename | `HDR-<today>-<slug>`; slug from the finding title, or `--slug` |
| `title` | the finding's heading title |
| `## Finding` | the finding's observation prose, verbatim |
| `status` | `proposed` |
| `classification`, `enforcement`, `surfaces` | the finding's YAML block |
| `evidence` | the finding's evidence **plus** the source assay anchor (§4.3) |
| `proposed_cost` | the finding's `#### Cost estimate`, verbatim |
| `cost` | **empty** |
| `proposer` | `{agent, model}` from the assay frontmatter, `assay` = its path |
| `approver`, `approved_at` | absent |
| `provisional` | `true`, with `expires` = today + 90 days |
| `## Rule` block | the finding's proposed-rule block, byte for byte |

For `classification: no-change`, `provisional` is `false`, no `expires` is
written, and the Rule section says `No change.` — matching S0 §4.7.

Tier-2 classifications (`harness-loop`, `script-validator`, `new-agent`) require
four further body sections that a finding does not carry. `/harness-propose`
writes them as **explicitly empty placeholders** naming what each must answer,
and the S0 validator refuses the HDR at acceptance until they are filled.

That is the correct behaviour rather than a gap: a loop-layer change must argue
why it belongs at that layer, and neither the Assayer nor the Registrar is
entitled to write that argument. The human does, or the rule does not land.

**Refusals.** `/harness-propose` refuses on: an assay that does not exist or does
not parse; a finding id that is not in it; a malformed finding; and a target
filename that already exists — it never overwrites, and `--slug` is how a
collision is resolved.

## 6. `/harness-accept <HDR>`

The single write transaction of this phase. Record-only: it sets `status:
accepted` and regenerates the index. It does not touch `HARNESS.md` — that is
S2, folded into this same command.

### 6.1 Refusals run before the cost prompt

Every refusal that does not depend on the cost runs first, against the HDR as it
stands. Only if they all pass is the human asked to write the cost.

The build spec's worked cycle shows this order, and the reason is the point of
the whole design: making someone compose a considered cost for a rule that is
about to be refused for citing a single assay spends exactly the human attention
this mechanism exists to protect. Refuse first, then ask.

### 6.2 The cost prompt

```text
Cost of this rule, in your own words. What will it demand of whoever
works here next, and how might it be gamed?
>
```

The answer is captured to a file and passed as `--cost-file`. Two reasons: a
cost is multi-line prose, and a `--cost "..."` argument would put the human's
words into shell history and into the agent's transcript, one copy-paste away
from being reused verbatim on the next HDR.

The S0 validator then refuses an empty cost, or one identical to
`proposed_cost`.

### 6.3 The transaction

Acceptance is all-or-nothing, and the corpus-level rules make that harder than
it looks: the three-per-cycle cap cannot be evaluated by looking at the
candidate alone.

So:

1. Build the accepted HDR text in memory.
2. Copy the entire `harness/` corpus to a temporary root, with the candidate
   substituted for its `proposed` predecessor.
3. Run the S0 validator against that temporary root.
4. Only on exit 0, write the real file and regenerate the index.

Corpus-level refusals therefore fire **before** anything is written, rather than
being discovered by CI after the fact. "Nothing is written and the HDR stays
`proposed`" becomes a property of the mechanism instead of a promise in a
document.

### 6.4 What acceptance writes

`status: accepted`, `approver`, `approved_at`, and the human's `cost`. The
`## Cost` body section is set to the same text, so the record reads correctly on
its own. Nothing else in the HDR is touched — in particular the `## Rule` block
is never rewritten, because from acceptance onward it is the byte-for-byte
source that S2's compiler applies.

## 7. `harness/decisions/index.md`

Generated wholly, inside the markers S2 will also use:

```markdown
<!-- BEGIN GENERATED: harness-registrar — do not edit by hand -->
<!-- END GENERATED: harness-registrar -->
```

One row per HDR, sorted by `id`, listing status, classification, enforcement,
surfaces, provisional and expiry. A pure function of the corpus: re-running it
on an unchanged corpus produces byte-identical output, which is what lets S2's
`/harness-check` treat any difference as drift.

The index is **linted** — unlike the HDRs themselves — because it is a generated
document rather than a record, and a generator that emits markdown nobody would
accept by hand is a generator that will be quietly hand-edited.

## 8. The agent

`harness-registrar.agent.md` — `tools: [Read, Write, Edit, Glob, Grep, Bash]`,
and **no `role:` tag**.

The absence is deliberate and load-bearing. `role: sentinel` is checked by
`sentinel-integrity-check.sh`, which fails CI on a sentinel granted `Write`. The
Registrar has write authority over governance artifacts and must not claim the
read-only trust boundary. Tagging it would be a lie that CI would catch; leaving
it untagged is the honest declaration that this agent is not a sentinel.

## 9. Acceptance criteria

| ID | Criterion |
| --- | --- |
| R1 | `propose` writes a valid `proposed` HDR that the S0 validator accepts |
| R2 | The Rule block in the HDR is **byte-identical** to the finding's proposed-rule block |
| R3 | The HDR's evidence is the finding's evidence plus the assay anchor, deduplicated |
| R4 | `proposed_cost` is the finding's cost estimate verbatim; `cost` is empty |
| R5 | `propose` refuses a missing assay, an unknown finding id, and a malformed finding, writing nothing |
| R6 | `propose` refuses to overwrite an existing HDR |
| R7 | A tier-2 finding produces placeholder sections, and the resulting HDR is refused at acceptance until they are filled |
| R8 | `propose` of a `no-change` finding writes `provisional: false`, no expiry, and `No change.` |
| R9 | `accept` moves `proposed → accepted`, writing `approver`, `approved_at` and the cost |
| R10 | `accept` refuses an empty cost and a cost identical to `proposed_cost` |
| R11 | `accept` refuses a single-evidence `harness-loop` HDR, **leaving the file unchanged** |
| R12 | `accept` refuses a fourth HDR from one assay, leaving the file unchanged |
| R13 | Every refusal leaves the corpus byte-identical to its prior state |
| R14 | `accept` refuses an HDR that is not `status: proposed` |
| R15 | `index` output is byte-identical on re-run and lists every HDR sorted by id |
| R16 | The pre-cost check reports refusals without a cost being supplied |

Tests live at `tdad_tests/layer0_deterministic/test-harness-registrar.sh`.

## 10. Deferred, deliberately

- **Importing legacy `HARNESS.md` constraints.** Grandfathering (`imported:
  true`) is validated by S0 but has no writer yet. It is adoption work, and
  adoption is `/harness-compile`'s one-time setup in S2.
- **`superseded` and `expired` transitions.** S4 owns demotion; writing a
  supersession here would mean designing the review flow twice.
- **Anything touching a control surface.** S2.

## 11. Rejected alternatives

**The agent copies the rule text.** Rejected per §3 — the one thing this phase
must guarantee is exactly the thing a model cannot be relied upon to do.

**Cost as a command-line argument.** Rejected per §6.2. Convenience, at the cost
of putting the human's own words somewhere they can be harvested for the next
HDR.

**Validating the candidate in isolation and writing immediately.** Rejected per
§6.3 — the cycle cap is corpus-level, so isolation cannot see it, and the
failure would surface in CI after the write rather than at the gate.

**Deferring the assay contract to S3.** Rejected per §2: `/harness-propose` has
no input without it, and a contract designed by the consumer that never has to
parse it is a contract that will not parse.
