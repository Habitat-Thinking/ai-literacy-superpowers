---
assay: harness/assay/2026-08-21T16-02Z-assay.md
date: 2026-08-21
agent: harness-assayer
model: claude-opus-5
---

# Assay 2026-08-21T16-02Z

## Executive summary

The harness is doing the part it declared and not the part it assumed. The
`Tests pass before merge` constraint is deterministic and names a tool; the
working agreement in `AGENTS.md` asks for a completion report and says nothing
about what a report must contain.

The single most important opportunity is the gap between those two: phase
completion is claimed in the build log with no observed result behind it, and
nothing in the harness asks for one.

## What worked

- The Phase 4 entry records the command it ran, its output, and states plainly
  that the integration suite was **not** run that phase. `observed`. That is the
  behaviour the proposed rule generalises; it already happens, unprompted, at
  least once.
- `HARNESS.md`'s single constraint declares its enforcement and its tool rather
  than leaving them implicit. `observed`.

## What created friction

**Problem.** Two of three phase boundaries claim the integration suite is
passing. `observed`

**Impact.** A reader of the build log cannot distinguish a suite that passed
from one that was going to be run. Neither can a later assay, which is how an
unverified claim becomes accepted history.

**Evidence.** `harness/build-log.md#2026-08-04T09:12Z` and
`#2026-08-11T14:30Z` each contain a fenced `pytest tests/integration -q` under
the heading `Planned verification:` followed by `Integration suite passing.`
No output block appears in either. `observed`

## Findings

### finding-1 — Phase completion claimed without observed output

Two of three phase boundaries in `harness/build-log.md` state the integration
suite is passing. Both record the command under `Planned verification:` and
neither records any output. The third boundary records a command, its output,
and an explicit note that the integration suite was not run — so the repository
already contains the shape the rule would require.

```yaml
classification: turn-instructions
enforcement: validated
surfaces: [claude-code, copilot]
priority: P1
evidence:
  - harness/build-log.md#2026-08-04T09:12Z
  - harness/build-log.md#2026-08-11T14:30Z
overfitting_risk: low
```

#### Proposed rule

````markdown
- **Rule**: A phase may not be reported complete on the strength of a command
  that was planned. A completion claim about a check, test, or integration must
  quote the observed output, or state plainly that the check was not run.
````

#### Cost estimate

One extra paste per phase boundary, perhaps two minutes. The real cost is that
it can be satisfied by pasting output without reading it, which converts an
unverified claim into a verified-looking one — so the rule buys legibility, not
correctness, and should be described that way rather than as proof the suite
passed.

#### Validation plan

The next two assays should find no completion claim without either quoted
output or an explicit not-run note. A recurrence on a surface that only advises
would confirm the enforcement gap rather than refute the rule.

## Rejected candidates

- **"Add a constraint requiring the integration suite to run every phase."**
  Rejected: the Phase 4 entry deliberately did not run it and said so, which is
  a legitimate choice about scope. The finding is about unevidenced claims, not
  about test frequency, and conflating them would make the harness enforce a
  cadence nobody asked for.
- **"HARNESS.md declares a constraint with no CI workflow behind it."** Rejected
  — this is `/harness-audit`'s question, not an assay's. Declared-versus-actual
  enforcement is the harness auditor's owner boundary, and duplicating it here
  would produce two agents reporting the same drift in two vocabularies.
- **"The build log has no consistent format."** Rejected as immaterial under the
  materiality test: it changes no scope, interface, acceptance criterion or
  verification, and no evidence shows anyone misread it.

## Unresolved questions

- Whether the two unevidenced boundaries reflect a suite that ran and went
  unrecorded, or one that never ran. The build log cannot distinguish these and
  no CI record is present in the repository, so the finding is stated as
  "claimed without observed output" rather than "claimed falsely". A human who
  was there can resolve it; the assay cannot, and should not guess.
