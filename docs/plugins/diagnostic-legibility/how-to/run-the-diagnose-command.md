# How to run the `/diagnose` command

`/diagnose` is the human-facing surface for the `diagnostic-legibility`
agent (since **v0.5.0**). You give it a scope; it drives the full
build → self-challenge → cross-check pipeline and hands you a readable
report instead of raw YAML.

For the lower-level bare-Task-tool dispatch (and the only way to reach
`mode: cross-check-only`), see
[invoke the agent](invoke-the-agent.md).

## Run it

```text
/diagnose <scope> [--out <dir>]
```

- `<scope>` — **required**. A directory path (`./src/auth/`), a list of
  files, or a free-text description (`"the checkout flow across services
  A and B"`). It is passed to the agent verbatim — the command does no
  scope validation of its own.
- `--out <dir>` — **optional**. Where to write the report. Defaults to
  `diagnostic-legibility/output/`.

Examples:

```text
/diagnose ./src/auth/
/diagnose ./internal/billing --out ./reports/
/diagnose "the event-sourcing layer"
```

## What happens

1. The command dispatches the `diagnostic-legibility` agent in
   `mode: full`. `cross-check-only` is never used here — `/diagnose`
   always runs the whole pipeline.
2. The agent returns a `LegibilityModel`. The command renders it as a
   report: a header, a `## Cross-check summary`, a two-column
   **side-by-side** summary table, then the architectural and domain
   models as stacked sections.
3. The command runs a validation checkpoint, then **prints a summary and
   asks you to accept or abort** — naming the resolved target path and
   flagging an overwrite if the file already exists.
4. On **accept**, the report is written and the path confirmed. On
   **abort**, nothing is written.

## Reading the report

- **Header** — scope, generation metadata, the `cross_check_status`
  (`completed` / `skipped_asymmetric` / `not_run`), and element counts.
- **Cross-check summary** — a plain-language line plus the **A→D** and
  **D→A** correction counts. A count is the number of *elements revised*
  in that direction (elements carrying at least one `CC<N>` cross-check
  note), not the raw number of notes — an element that fired two
  cross-check questions counts once.
- **Side-by-side summary table** — Architectural | Domain, with each
  side's element count and elements revised, so you see the two
  collections at a glance.
- **Models** — `### Architectural model` then `### Domain model`. Each
  element shows its description, evidence, and its `challenge_notes`
  grouped into **Self-challenge** (`Q<N>`) then **Cross-check** (`CC<N>`)
  entries.

## Where reports go

By default reports land in `diagnostic-legibility/output/` as
`<scope-slug>-legibility-<YYYY-MM-DD>.md`. That directory is
**gitignored** — reports are derived, regenerable artefacts, not tracked
source. Re-running the same scope on the same day will offer to
overwrite the existing report (you see the path and confirm before any
write). Use `--out` to send a report somewhere else.

## When the agent refuses

If the agent returns a `diagnostic-legibility refusal:` line instead of
a model, the command surfaces that line **verbatim** and aborts — no
report is rendered and no file is written.

## Related

- [Invoke the agent directly](invoke-the-agent.md) — the bare-Task-tool
  surface and `mode: cross-check-only`.
- [The cross-check protocol](../explanation/cross-check-protocol.md) —
  what Phase C does and what `CC<N>` / `cross_check_status` mean.
- [`/diagnose` reference](../reference/diagnose-command.md) — the full
  command contract.
