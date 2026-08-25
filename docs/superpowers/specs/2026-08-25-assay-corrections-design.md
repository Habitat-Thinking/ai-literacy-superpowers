# Assay corrections — design

**Status:** proposed
**Date:** 2026-08-25
**Issue:** #556
**Provenance:** two confirmed factual errors in
`harness/assay/2026-08-25T08-08Z-assay.md`, both in load-bearing positions, both
uncorrectable. Recorded in #556 and in
`docs/superpowers/harness-evolution-build-spec-claims.md`.
**Scope:** an errata record beside an assay, and the two places a corrected
finding currently propagates.
**Out of scope:** #557, #558, #559.

## 1. Problem statement

Assays are append-only and never edited — correctly, because they record what an
agent observed at a moment. But there is no channel for a correction, so an
error is permanent, uncited, and propagates.

Two confirmed errors in the first assay:

1. **finding-1's headline.** "Six specs … carry the line `**Provenance:**`". Four
   do. `s4` and `s5` carry none, and they are the source of two of the four
   deviations the finding cites as harm. Its `build spec` count is 19, not 13.
2. **finding-2's opening.** "`gc.yml` runs nineteen declared GC rules as
   sequential steps." `HARNESS.md` declares 19 active GC rules; `gc.yml` carries
   11 rule steps covering **5** of them.

`lint-assay` is deliberately not a CI gate, and `/harness-check` does not read
assays, so nothing revalidates one after it is written.

### The propagation is the harm

`/harness-propose` copies rule text and evidence **byte for byte** by design, so
no model can silently improve them. The same property copies a *wrong* finding
faithfully into a frozen record.

finding-2's flawed premise reached
`HDR-2026-08-25-the-periodic-check-suite-...` unchanged, and its frozen rule text
turns on "every rule it declares" — a phrase whose scope the assay got wrong by
nearly four times. The approver had to resolve that ambiguity at the gate against
a `proposed_cost` that was wrong by an order of magnitude for the reading chosen.

There is a second path. The two-assay promotion threshold counts distinct assay
files in an HDR's `evidence`:

```python
assays = {str(item).split("#", 1)[0] for item in evidence
          if str(item).startswith(ASSAY_DIR + ...)}
if len(assays) < 2:
```

A corrected finding can therefore **corroborate** a loop-layer rule.
Corroboration by a falsified observation is not corroboration, and this is the
one threshold the corpus relies on to keep a single incident out of `HARNESS.md`.

## 2. What is deliberately not achieved

The ticket asks that "a reader who opens an assay can discover that a finding in
it was later corrected". **That cannot be done without editing the assay**, which
is the one thing the append-only rule forbids, and a mechanism that pressures
someone to edit a record is worse than the gap it closes.

So the in-file pointer is traded away, knowingly. Discovery is met two other
ways: a sibling file with a predictable name, visible to anyone listing
`harness/assay/`; and refusals at the two points where a correction actually
changes what someone should do.

Stating the trade rather than quietly redefining the requirement.

## 3. Decision — an errata record beside the assay

```text
harness/assay/<ISO8601>-assay.md          the assay, never edited
harness/assay/<ISO8601>-assay.errata.md   corrections, append-only
```

Frontmatter naming the assay it corrects; one `## finding-<n>` section per
corrected finding, each carrying what the assay said, what is actually true, and
evidence.

Append-only in the same sense: a correction is itself an observation at a moment,
and a later correction is appended rather than an edit. Nothing in the mechanism
edits either file.

Written by `harness-registrar.py correct --assay <path> --finding <id>
--correction-file <path>`. A file rather than an argument, for the same reason
`--cost-file` and `--reason-file` are: it is prose, and shell history is one
copy-paste from the next correction.

## 4. Decision — refuse where the error would propagate

**At `/harness-propose`.** Proposing from a corrected finding refuses, quoting the
correction, and proceeds only with `--acknowledge-correction`.

Not a warning. A warning printed by a command that just succeeded is a warning
nobody reads, and the record it produced is frozen. The refusal is a
human-cognition gate of the same shape as the cost: you cannot proceed without
having been shown the thing you need to have read.

The override exists because a correction is not automatically fatal. finding-2's
count was wrong and its underlying observation — masking — was verified and
still stands. Refusing permanently would make an assay's smallest error
un-actionable, and would give someone a reason not to record corrections at all.

**At the two-assay threshold.** An assay carrying a correction for the finding an
HDR cites no longer counts toward the two-assay minimum for `harness-loop`.

This is deliberately narrow: it excludes the *corrected finding*, not the whole
assay. An assay may hold six findings and be wrong about one.

## 5. Acceptance criteria

- **A1** — `correct` writes `<assay>.errata.md` naming the assay, the finding and
  the correction; a second correction appends rather than replaces.
- **A2** — it refuses when the assay or the finding id does not exist, and when
  the correction is empty. No file is written on refusal.
- **A3** — the assay itself is byte-identical before and after. Asserted by hash.
- **A4** — `propose` on a corrected finding refuses, names the finding, and quotes
  the correction. Nothing is written.
- **A5** — `propose --acknowledge-correction` succeeds, and the resulting record
  records that a correction was acknowledged.
- **A6** — `propose` on an *uncorrected* finding in the same assay is unaffected.
- **A7** — an HDR citing a corrected finding does not reach the two-assay minimum
  on that assay; citing an uncorrected finding in the same assay still does.
- **A8** — `/harness-check` fails on a malformed errata file: unknown assay,
  unknown finding id, or an empty correction.
- **A9** — the existing corpus is unaffected; `/harness-check` passes.
- **A10** — Layer 0 coverage using the two real errors from
  `2026-08-25T08-08Z-assay.md` as fixtures.

## 6. Version

Behaviour change to plugin files: minor bump, `0.83.1` → `0.84.0`.
