---
id: HDR-2026-08-25-an-epic-s-authority-cited-to-a-document-nobody-else-can-open
title: An epic's authority cited to a document nobody else can open
status: rejected
classification: harness-loop
enforcement: advisory
surfaces: [claude-code, codex, cursor, copilot, windsurf]
provisional: false
evidence:
  - docs/superpowers/specs/2026-08-23-harness-evolution-s0-schema-validator-design.md
  - docs/superpowers/specs/2026-08-23-harness-evolution-s2-compile-check-design.md
  - docs/superpowers/cadence-sentinels-charter.md
  - HARNESS.md
  - harness/assay/2026-08-25T08-08Z-assay.md#finding-1
proposer:
  agent: harness-assayer
  model: claude-opus-5
  assay: harness/assay/2026-08-25T08-08Z-assay.md
supersedes: null
superseded_by: null
---

## Finding

Six specs — `2026-08-23-harness-evolution-s0` through `-s5` — carry the line
`**Provenance:** the Harness Assayer / Harness Registrar build spec, supplied
in conversation 2026-08-23`. No such document exists in the repository. The six
specs then make thirteen separate claims about what that spec says, and four of
them are recorded deviations from it: S0 §7 "This is the fix for an
unimplementable clause in the build spec", S2 §2 "The build spec's compilation
model does not survive contact with this repo", S4 §132 "The build spec
requires `provisional: true` with a mandatory `expires` date", S5 §35 "The
build spec's example line does not say whether 'expired' appears in the feed".
Each deviation is argued, and none can be checked, because the thing deviated
from is not retrievable.

This is a recurrence, not a first occurrence. Commit `1133b9c` (2026-08-13,
#518) is titled "Point the epic's provenance at something retrievable, and
transcribe the charter" and its message reads: "Seven specs cited a deck that
never existed — it was a label for a build spec supplied in conversation…
those specs cite constitutional constraints BY NUMBER, fifteen times across
seven distinct constraints, against a list that was nowhere in the repository."
The fix produced `docs/superpowers/cadence-sentinels-charter.md`, transcribing
all nine constraints verbatim. It produced no rule. Ten days later the next
epic reproduced the defect at the same scale.

The 2026-08-13 reflection entry did promote a sibling constraint — *Specs cite
the source of a claimed convention* — but scoped it to claims about existing
repository conventions, not to the source document a spec names as its
authority. The narrower half was generalised; the wider half was not.

## Assayer's reasoning

_Written by the Assayer, carried verbatim._

**Why this is a tightening, not a new rule.** `HARNESS.md` already carries
*Specs cite the source of a claimed convention*, agent-enforced by the
advocatus-diaboli spec gate, driven by the same class of failure. It cannot
absorb this behaviour as written because its subject is a **claim about the
repository** ("the pattern here is X"), verifiable by opening a file that
exists; this finding's subject is a **source outside the repository**, where
there is no file to open. The rule below extends that constraint's scope rather
than adding a second heading, and the proposed text is written to sit inside
it.

**Overfitting risk: low.** Two independent occurrences, two different epics,
two different authors' sessions, thirteen and fifteen citation instances
respectively. The rule does not encode either epic's specifics.

**Validation plan.** Take the six harness-evolution specs as the negative
fixture: under the rule they must fail the spec gate. Take
`cadence-sentinels-s1` post-`1133b9c` as the positive fixture: it cites
`cadence-sentinels-charter.md` by path and must pass. If the gate cannot
separate those two without reading either spec's content, the rule is not
falsifiable and should be refused.

## Rejection

My feeling was that the rule was pointed at the wrong problem.
