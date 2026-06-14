---
component: reservoir-check
component_type: hook
tier: behavioural
fixture: opted-in-long-session
---

# Scenario: reservoir-check fires a single honest advisory on a long session

## Given

A project whose `HARNESS.md` contains an **active** `## Cognitive reservoir`
heading (the opt-in marker), inside a git repository whose recent history
shows activity that crosses at least one configured threshold within the
window. The hook is `ai-literacy-superpowers/hooks/scripts/reservoir-check.sh`
(spec `docs/superpowers/specs/2026-06-14-reservoir-warden-design.md`, Scenario
A; FR-004, FR-005, FR-008, FR-009).

The fixture seeds enough commits across more than one top-level directory that
the disjunctive thresholds (defaults: span 180 min, decision volume 8, context
switches 4) — or values tuned lower in the block — are crossed.

## When

The Stop hook runs at session end with `CLAUDE_PROJECT_DIR` pointed at the
fixture:

```bash
CLAUDE_PROJECT_DIR="$FIXTURE" bash ai-literacy-superpowers/hooks/scripts/reservoir-check.sh
```

## Then

- The script exits **0** (advisory-only — never non-zero, FR-005).
- It emits **exactly one** line of output, and that line is a valid JSON object
  with a single `systemMessage` key (FR-004, FR-005). Parsing it with a strict
  JSON parser succeeds.
- The `systemMessage` value:
  - (a) states the crossed threshold(s) as **observed** counts (e.g.
    `continuous span N min (threshold ...)`, `decision volume N (threshold ...)`);
  - (b) frames the risk as **inferred** / defeasible and a **precaution under
    uncertainty**, not a diagnosis;
  - (c) names the **robust basis** — time-on-task / vigilance decrement and/or
    task-switching cost — and does **not** contain the strings "ego depletion"
    asserted as fact nor any "hungry judges" figure (FR-009);
  - (d) restates the decide-your-stop-before-the-next-session principle and that
    **the choice to continue is the human's**.
- The output contains **no** combined fatigue score (no single number claiming
  to summarise cognitive state).

## Rubric

Deterministic behavioural scenario (no LLM). Run the script in the fixture and
assert on exit code and the parsed JSON `systemMessage` string. The honesty
assertions (c) are checkable as substring presence/absence.

## Cleanup

Remove the temporary fixture repository.
