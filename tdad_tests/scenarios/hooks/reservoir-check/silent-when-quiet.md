---
component: reservoir-check
component_type: hook
tier: behavioural
fixture: opted-in-quiet-session
---

# Scenario: reservoir-check stays silent on a quiet session

## Given

An opt-in project (its `HARNESS.md` has an active `## Cognitive reservoir`
heading) inside a git repository whose recent activity is **below all
thresholds** — a short span, few commits, a single work stream (spec
`docs/superpowers/specs/2026-06-14-reservoir-warden-design.md`, Scenario B;
FR-005, FR-008).

## When

The Stop hook runs at session end:

```bash
CLAUDE_PROJECT_DIR="$FIXTURE" bash ai-literacy-superpowers/hooks/scripts/reservoir-check.sh
```

## Then

- The script produces **no output** (empty stdout) — no manufactured concern.
- The script exits **0**.

## Rubric

Deterministic behavioural scenario. The thresholds are disjunctive, so the
silence assertion only holds when **none** is crossed; the fixture must keep
span, decision volume, and context switches all under their (default or tuned)
thresholds. Asserts empty stdout and exit 0.

## Cleanup

Remove the temporary fixture repository.
