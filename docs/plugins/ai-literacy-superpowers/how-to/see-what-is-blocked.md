# See what is blocked in the evolution loop

`/harness-board` renders every artefact in flight and the concrete next action
for each. Read-only; it writes nothing.

## Run it

```bash
python3 ai-literacy-superpowers/scripts/harness-board.py
```

```text
ASSAYS
  2026-08-25T14-31Z-assay    4 findings   2 proposing · 2 no-change

PROPOSALS
  2026-08-25-command-cli-parity                          precheck: clean
      → gate-ready. Remaining: the cost, written at /harness-accept

IN FORCE
  2026-08-25-four-mechanisms-report-the-reassuring-ans   agent-instruction · provisional until 2026-11-23

ACCEPTED BUT NOT BINDING
  2026-08-25-the-periodic-check-suite-stops-at-its-fir   superseded

OBJECTIONS AWAITING DISPOSITION
  harness-provenance-citation                            12/12 pending
      → dispose them, or record why they stand
```

## Read the arrows, not the states

Every blocked item carries a `→` line naming something you can do. A refused
proposal shows the refusal **quoted from `precheck`**, so the board and the gate
cannot disagree:

```text
  2026-08-25-workflow-step-masking                       precheck: REFUSED
      → a harness-loop change requires evidence from at least two
        distinct assays, found 1
```

That is the difference between knowing a thing is blocked and knowing what to do
about it — and the three proposals in flight on 2026-08-25 were blocked for three
entirely different reasons.

## Interventions over time

```bash
python3 ai-literacy-superpowers/scripts/harness-board.py --timeline
```

Direction, state and expiry per accepted record, from the same feed
`/harness-timeline` emits.

## What it will not do

It does not propose, accept or dispose anything — the loop's write path is gated
deliberately, and a board that could act would collapse the gates it exists to
make visible.

It does not store anything. There is no `BOARD.md`, because a file that must be
regenerated becomes a file that is stale.

It does not hide a record it cannot parse. Anything with a missing or
unrecognised `status` appears under `UNCLASSIFIED` with its path.

## See also

- [Record a governance change](record-a-governance-change.md)
- [Assay a phase](assay-a-phase.md)
- [Harness decision records](../reference/harness-decision-records.md)
