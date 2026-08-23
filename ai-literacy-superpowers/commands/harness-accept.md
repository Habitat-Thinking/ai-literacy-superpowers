---
name: harness-accept
description: The single write transaction of the harness evolution loop — runs every cost-independent refusal first, prompts the approver to write the cost in their own words, then accepts the record, applies its rule text to the artifact that owns it, and recompiles every generated region; transactional, so a refusal leaves the record proposed and nothing else written
---

# /harness-accept \<hdr-path\>

Accept a proposed Harness Decision Record. This is the gate where a human
decides, and the only place the `cost` is ever written.

## When to use

- On a `proposed` HDR you have read and want in force
- Never in a batch. Each acceptance is one decision, and approval for one HDR
  never generalises to another

## The order matters: refuse first, then ask

Every refusal that does not depend on the cost runs **before** the human is
asked to write one.

Making someone compose a considered cost for a rule that is about to be refused
for citing a single assay spends exactly the human attention this whole
mechanism exists to protect. So the sequence is fixed, and you must not reorder
it for convenience.

## Process

### 1. Validate input

Confirm the HDR exists and is `status: proposed`. An accepted HDR is frozen — a
later decision supersedes it rather than editing it. If the status is anything
else, abort and say so.

### 2. Show the human what they are approving

Print the HDR's `title`, `classification`, `enforcement`, `surfaces`, its
`## Finding`, and the **full** `## Rule` block. Not a summary of the rule. The
verbatim text, because that is what is about to be in force.

### 3. Pre-flight — run every cost-independent refusal

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py precheck \
  --hdr <hdr-path>
```

If this exits non-zero, **stop here**. Report each refusal in plain language and
name the real options. Do not prompt for a cost.

The refusals you will actually meet:

| Refusal | What it means | The options |
| --- | --- | --- |
| Tier-2 sections are still placeholders | The argument for this layer was never written | The human writes them, or the HDR waits |
| `harness-loop` citing fewer than two distinct assays | One incident cannot reach the loop layer | Wait for a second assay to corroborate, or reclassify to the layer that owns the behaviour |
| A fourth accepted HDR from one assay | The cycle cap | Leave it `proposed`; it carries forward |
| An undeclared surface | A typo, or a surface missing from `surfaces.yaml` | Fix the name, or declare the surface |
| No route and no `target` | The classification does not have a fixed home, and the record does not say which artifact owns the rule | The human names the target. `agent-instruction` says the behaviour belongs to an agent, not which agent, and nothing in the schema can infer it |
| Target artifact does not exist | The record routes to a file that is not there | Create the artifact, or correct the target. The Registrar writes records, not governance documents |
| Malformed generated markers | The target has an END before a BEGIN, a BEGIN with no END, or two pairs | A human repairs them. Never guess which BEGIN pairs with which END |

**Never resolve a refusal by editing the HDR to satisfy it.** Reclassifying a
rule because the loop-layer threshold refused it is a decision the human makes,
not a repair you apply.

### 4. Prompt for the cost

Only once step 3 is clean. Ask exactly this:

```text
Cost of this rule, in your own words. What will it demand of whoever
works here next, and how might it be gamed?
>
```

Write the answer to a scratch file and pass it as `--cost-file`. Never pass the
cost as a command-line argument: it is multi-line prose, and an argument would
put the approver's own words into shell history one copy-paste away from being
reused verbatim on the next HDR.

If the human asks you to write the cost for them, decline. Explain that the
validator refuses a cost identical to the Assayer's proposal, and that the
reason is not procedural — a copy-pasted cost reads exactly like a considered
one, so nothing downstream can tell the difference. Offer to discuss what the
rule will actually demand; do not offer words.

### 5. Run the transaction

```bash
python3 ai-literacy-superpowers/scripts/harness-registrar.py accept \
  --hdr <hdr-path> --cost-file <scratch-path> \
  --approver <identity> --now <ISO-8601>
```

Acceptance is all-or-nothing, and it now covers three things in one transaction:
the record is accepted, its rule text is applied to the artifact that owns it,
and every generated region is recompiled.

The script validates a staged copy of the whole corpus **and** computes the
compilation plan before writing anything, so a target artifact that does not
exist or a file with ambiguous markers refuses the entire acceptance rather than
leaving a record accepted and unapplied.

Delete the scratch cost file afterwards.

### 6. Validation checkpoint

Read the accepted HDR back and check:

- **A1** — `status: accepted`, with `approver` and `approved_at` present
- **A2** — frontmatter `cost` carries the human's words and differs from
  `proposed_cost`
- **A3** — the `## Cost` section carries the same words, and no longer carries
  the Assayer's proposal or its `_Proposed by the Assayer_` label
- **A4** — the `## Rule` block is **unchanged** from before acceptance. From
  here it is the byte-for-byte source the compiler applies
- **A5** — `harness/decisions/index.md` lists the HDR with its new status
- **A7** — the rule text now appears inside the generated region of the target
  artifact, **byte-identical** to the `## Rule` block, and every hand-written
  line in that file is unchanged
- **A8** — `harness/enforcement-report.md` carries a row per surface, and any
  surface that cannot reach the intended level is marked as a gap rather than
  silently downgraded
- **A6** — `provisional: true` with an `expires` or a `review_trigger`, unless
  the HDR is `no-change` or `imported`

If A4 deviates, that is serious: report it as a defect and do not proceed.
For the rest, report rather than patch — a hand-edit to an accepted record is
the one thing the append-only rule forbids.

### 7. Present the result

```text
Accepted <id>.

  Enforcement intended: <level>
  Surfaces: <list>
  Applied to: <target artifact>
  Provisional until <expires> — permanence is earned at review, not at
  creation. An expired rule still in force will fail CI.

  Enforcement gaps: <n>. See harness/enforcement-report.md — a rule that
  intends more than a surface can deliver is reported, never silently
  downgraded.

Nothing has been committed. Review the diff and commit when you are ready.
```

## Two gates, not four

Applying and compiling are deliberately **not** separate approval gates. Once a
record is accepted there is no decision left in either step, and a gate with no
decision behind it is the exact shape of approval theatre.

The two that remain are the two where a human genuinely decides something:
writing the cost, and reviewing the resulting diff.

## What this command does not do

- It does not write into `.github/copilot-instructions.md`, `.cursor/rules/` or
  `.windsurf/rules/`. `/convention-sync` generates those from `HARNESS.md`, and
  two generators on one file produce the same rule twice in two voices. A rule
  reaches those surfaces once it is in `HARNESS.md`.
- It does not touch anything outside the generated markers.
- It does not commit, push, or open a pull request. Three gates exist —
  drafting, accepting, and committing — and none is implied by another.
