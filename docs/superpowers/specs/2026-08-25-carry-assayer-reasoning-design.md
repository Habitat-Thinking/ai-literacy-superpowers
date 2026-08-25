# Carry the Assayer's reasoning into the decision record — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #554
**Provenance:** raised as O9 in
`docs/superpowers/objections/harness-provenance-citation.md` during the first
end-to-end loop run (#548, PR #550), and confirmed in use while accepting
`HDR-2026-08-25-the-periodic-check-suite-stops-at-its-first-failure-and-reports-the-rest-as-nothing`.
**Scope:** what `/harness-propose` extracts from a finding, and what
`render_hdr` writes.
**Out of scope:** the four remaining defects from the same run — #553, #555,
#556, #557, #558 — and the routes trap #559.

## 1. Problem statement

`_parse_finding` takes the observation as everything before the first fence:

```python
observation = preamble.split("```", 1)[0].strip()
```

The Assayer's `**Why this layer**`, `**Overfitting risk**` and
`**Validation plan**` paragraphs conventionally sit *after* the YAML metadata
block, so none reaches the record. They are not `####` subsections either, so
`subsections` does not hold them. `overfitting_risk` is dropped from the
metadata as well: it is not in `FINDING_REQUIRED_KEYS` and `render_hdr` never
reads it.

`render_hdr` then emits four `_TODO —` placeholders, and a human writes the
argument from scratch beside a file that already contains a better one.

### Observed cost

In `harness/assay/2026-08-25T08-08Z-assay.md`, finding-2's metadata fence opens
at line 31 of the finding; the three paragraphs are at 44, 56 and 60. All were
discarded, including the sharpest sentence in the finding:

> a fix that makes the job green by tolerating failures is worse than the defect

Reconstructing the four sections by hand introduced an error: the `Enforcement`
section asserted "no enforcement gap" while the generated report said
`ci | validated | none | gap`. That record is accepted and frozen with the error
in it.

## 2. Decision — mirror `proposed_cost`

The corpus has already solved this problem once. The Assayer's cost estimate is
preserved verbatim in `proposed_cost`; the human writes `cost`; the two are
structurally distinct, so nothing downstream can mistake one for the other.

**Apply the same split to the reasoning.**

A new `## Assayer's reasoning` section carries the finding's post-metadata prose
verbatim, explicitly attributed. The four tier-2 sections stay `_TODO`
placeholders that a human writes.

```text
## Finding               observation, verbatim
## Assayer's reasoning   post-metadata prose, verbatim, attributed   <- new
## Rule                  verbatim
## Cost                  human
## Why this layer        human, _TODO
## Enforcement           human, _TODO
## Validation            human, _TODO
## Rejected alternatives human, _TODO
```

### Why not pre-fill the tier-2 sections

Because that is the cost-rule failure one section over. The build spec is
deliberate that the assay carries a validation plan and an overfitting
assessment while the HDR's tier-2 sections are human-authored; the gap between
them is the point. Pre-filled reasoning reads exactly like considered reasoning,
and nothing downstream could tell them apart — the same sentence the build spec
uses about cost.

### Why not move the convention instead

Requiring the Assayer to place its reasoning *above* the metadata block would
let existing extraction reach it with no format change. Rejected: it lands the
argument inside `## Finding`, whose contract is "what was observed, with evidence
references". Conflating an observation with an argument about it makes the
Finding section a worse record of what was seen, and the assay format reference
would have to be rewritten against a convention that exists only to work around
a parser.

### What counts as the reasoning

The prose between the end of the metadata block and the first `####` subsection.
That is a positional rule, not a semantic one: it captures whatever the Assayer
wrote there and makes no judgement about which paragraphs are load-bearing.

A finding with nothing there is normal — most `no-change` findings will have
none — so the section is **omitted entirely** rather than emitted empty. An
empty section invites someone to fill it, and this one is not theirs to fill.

## 3. Decision — `overfitting_risk` reaches the frontmatter

It is a claim the Assayer made about its own finding, and it is exactly what a
reviewer at the acceptance gate should weigh. It is carried when present and
omitted when absent. It is **not** added to `FINDING_REQUIRED_KEYS`: making it
mandatory would change the assay contract, which is a separate decision with its
own evidence.

## 4. Acceptance criteria

- **A1** — a finding with post-metadata prose produces an HDR with an
  `## Assayer's reasoning` section whose content is byte-identical to that prose.
- **A2** — the section is attributed, so a reader cannot mistake it for the
  approver's words.
- **A3** — a finding with no post-metadata prose produces an HDR with no such
  section, and no empty heading.
- **A4** — the four tier-2 sections are still `_TODO` placeholders, and
  acceptance is still refused while they are unfilled.
- **A5** — `overfitting_risk` reaches the HDR frontmatter when present, and is
  absent when not.
- **A6** — `## Finding` is unchanged: still the observation only, still ending at
  the first fence.
- **A7** — `## Rule` is unchanged and still byte-identical to the assay's
  four-backtick block. This is the guarantee that must survive the change.
- **A8** — Layer 0 coverage using finding-2 of `2026-08-25T08-08Z-assay.md` as
  the fixture, since that is the finding this defect was found on.
- **A9** — the existing corpus still validates, and `/harness-check` passes.

## 5. Version

Behaviour change to plugin files: minor bump, `0.80.0` → `0.81.0`, across the
five CI-checked locations named in `CLAUDE.md`.
