---
name: harness-board
description: Render the harness evolution loop as a queue — every assay, proposal, record and objection in flight, with the concrete next action for each. Read-only. Pass --timeline for interventions over time, or --html for a browser view of the loop as a diagram.
---

# /harness-board

Show what is in flight in the evolution loop, and what unblocks each item.

Read-only. It writes no file and exits non-zero only on its own failure, never on
the state of the corpus. The board reports; it does not gate.

## When to use

- Before `/harness-accept`, to see which proposals are gate-ready and which are refused
- After an assay, to see what the findings became
- When picking up the loop after time away and the question is "where was I"
- Any time the answer to "what is blocked" would otherwise take several commands

## Process

### 1. Run it

```bash
python3 ai-literacy-superpowers/scripts/harness-board.py
```

For interventions over time rather than the queue:

```bash
python3 ai-literacy-superpowers/scripts/harness-board.py --timeline
```

For a browser view — the loop drawn as a circle with live queue depth at each of
its eight stages, above the same queue and timeline:

```bash
python3 ai-literacy-superpowers/scripts/harness-board.py --html
```

That writes a self-contained page to a temporary file, opens it, and prints the
path. `--html <path>` writes where you ask instead.

**It refuses a path inside the working tree** unless git already ignores it:

```text
FAIL: refusing to write BOARD.html inside the working tree.
A page that can be committed is a page that goes stale: this repository already
carries observability/governance/governance-dashboard.html and
assessments/portfolio-dashboard.html, both 106 days old and read by nobody.
```

That refusal is the design, not a guard rail bolted on. "Do not commit this" as a
note is a note; a tool that cannot produce a committable file cannot become the
thing nobody regenerates. The note failed for two dashboards already.

The page carries its own generation timestamp and says it is a snapshot, so
whoever finds it later knows what they are looking at. Failing to open a browser
is not an error — the printed path is the result.

### 2. Read the queue

Five sections, ordered by closeness to a gate:

- **ASSAYS** — each assay, its finding count, how many propose a rule versus
  resolve to `no-change`, and whether it carries an errata record
- **PROPOSALS** — each `proposed` record with its `precheck` result. A refused
  record shows **the exact refusal**, quoted from `precheck` rather than
  recomputed. A clean record shows what remains: the cost, written at the gate
- **IN FORCE** — records actually binding something, with provisional expiry.
  This reads the registrar's derived state rather than `status`, because a
  superseded rule and a retirement are both `accepted` and neither binds
- **ACCEPTED BUT NOT BINDING** — superseded and retired records, so the
  difference is visible rather than inferred
- **OBJECTIONS AWAITING DISPOSITION** — records carrying `pending` dispositions,
  which block the proposals that depend on them

### 3. Act on the arrows

Every blocked item carries a `→` line naming a **concrete next action**, not a
state. "Blocked" is not an action; "a harness-loop change requires evidence from
at least two distinct assays, found 1" is.

## What it does not do

**It does not act.** No proposing, accepting, or disposing. The loop's write path
is gated deliberately, and a board that could act would collapse the gates it
exists to make visible.

**It does not store anything.** There is no `BOARD.md`. A file that must be
regenerated becomes a file that is stale — this repository already carries two
dashboards that went 106 days unread, and a third with a fresher date would be
the same mistake. Run the command when you want the answer.

**It does not reimplement `precheck`.** Where a blocker is computed by the
registrar, the board shells out and quotes it. Two implementations of a refusal
rule diverge, and the divergence favours the board, because the board is what
someone reads.

**It does not hide what it cannot parse.** A record with no `status`, or an
unrecognised one, appears under `UNCLASSIFIED` with its path. A board that
silently drops what it cannot classify reports a smaller world than it checked.

## Note on disposition vocabulary

The corpus contains both plural and singular disposition values — `accepted` and
`accept`, `rejected` and `reject`, plus `amend`. The board normalises for counting
and prints a note listing any non-canonical values it saw. It does not rewrite
records, and it does not treat the divergence as an error:
`check-objection-taxonomy.py` passes on all of them, so the schema permits it.

## See also

- `/harness-assay` — produce the assays this board reads
- `/harness-propose`, `/harness-accept` — the write path the board reports on
- `/harness-timeline` — the raw JSON feed behind `--timeline`
- `/harness-check` — pass/fail over the corpus, which the board deliberately does not duplicate
