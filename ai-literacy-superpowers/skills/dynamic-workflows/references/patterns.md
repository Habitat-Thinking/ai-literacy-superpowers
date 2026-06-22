# Dynamic Workflow Patterns

The six composable patterns an authored workflow draws on. Each section
names the pattern and works it through a concrete, task-shaped
micro-example — the example is what makes the pattern usable by an agent
reasoning about a real task, not just a definition to recite. Real
workflows compose several of these.

The exact runtime functions for spawning and coordinating subagents are
**not** reproduced here — consult <https://code.claude.com/docs/en/workflows>
as authoritative before authoring a template.

## classify-and-act

**Shape.** Inspect the task, decide its *type*, then dispatch the branch
that fits. The default branch does the ordinary thing; special branches
exist only for the cases that benefit.

**Micro-example.** A request arrives at the orchestrator. A cheap
classifier agent reads it and labels it: *routine single-file edit* →
the existing static pipeline (no extra compute); *naming or design
question* → a `tournament`; *flaky test / incident* → root-cause
investigation. The routine label is the common case and costs nothing
beyond the classification step.

## fan-out-and-synthesize

**Shape.** Split a job into independent units, run one subagent per unit
in parallel (each with a clean context window), then wait at a
*synthesis barrier* until all return before reporting. The barrier is
what defeats agentic laziness — there is no "good enough, stop at 35 of
50" because the report cannot form until all N results are in.

**Micro-example.** Enforcing 24 HARNESS.md constraints. Instead of one
context checking all 24 (and tiring), the workflow spawns 24 verifier
subagents, one per constraint. Each returns pass/fail with evidence. The
synthesis step asserts it received exactly 24 results, then composes the
report. A missing result is a visible error, not a silent drop.

## adversarial verification

**Shape.** After a result is produced, a *separate* agent — in a context
window distinct from the producer's — tries to refute it against a
rubric. Only claims that survive the refutation are accepted. The
separation is what defeats self-preferential bias.

**Micro-example.** An implementation passes its tests. A reviewing agent
that never saw the implementer's reasoning is handed the diff plus the
CUPID + literate-programming rubric and asked, "find where this fails
each property." Each property gets a dedicated verifier; findings are
synthesised, not collapsed into a single thumbs-up.

## generate-and-filter

**Shape.** Deliberately over-produce candidates, then prune to the ones
worth keeping. Cheap breadth first, selective depth second.

**Micro-example.** Mining `REFLECTION_LOG.md` for rules worth promoting.
Parallel agents cluster the log and emit *every* candidate rule they can
justify (generate). A second adversarial pass asks of each, "would this
rule actually have prevented a real past mistake?" and drops the ones
that would not (filter). The survivors become a shortlist a human curates
— the workflow never writes the durable rule file itself (INV-1).

## tournament

**Shape.** Produce several independent attempts from different angles,
score each against a rubric with judge agents, and keep the winner (often
grafting the best ideas from the runners-up).

**Micro-example.** Naming a new public API. Three agents each propose a
naming scheme from a different stance — consistency-with-existing-code,
readability-for-newcomers, future-extensibility. A rubric-bearing judge
scores all three and selects, explaining the trade-off. Beats
one-attempt-iterated when the solution space is wide and taste-based.

## loop-until-done

**Shape.** Repeat a step until a measurable completion test passes (or a
budget is exhausted), rather than stopping after a fixed number of
rounds. For unknown-size discovery, keep going until K consecutive rounds
surface nothing new.

**Micro-example.** A deep repository assessment fans out by area and
accumulates findings; after each round a completeness critic asks "what
area has not been scanned, what claim is unverified?" The loop continues
until a round adds nothing, then synthesises the cited report. A simple
"run three times" would miss the tail.

> **Threshold note.** Some patterns switch on at a count threshold (for
> example, fan-out mode for the enforcer once the constraint count is high
> enough). The *value* of that threshold is a per-project decision made in
> the slice that owns it — this reference deliberately states only that a
> threshold exists, not its number.
