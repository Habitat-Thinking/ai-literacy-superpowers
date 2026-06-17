# Spec: Affordance runtime invocation recorder (sequencing step 7)

**Date**: 2026-06-17
**Author**: Russ Miles + assistant
**Parent design**: `docs/superpowers/specs/2026-04-26-harness-affordances-design.md`
(O3 disposition — runtime data lives in `observability/`, never inlined into
HARNESS.md)
**Builds on**: step 3 (the `## Affordances` section) and the deterministic
analyzer pattern from steps 4-6
**Driving issue**: #203
**Status**: design — spec-mode `/diaboli` reviewed, all 12 dispositions
adjudicated 2026-06-17 (see Adjudication); the three design forks were
user-confirmed before spec; ready for implementation

## Problem

The affordance section declares what tools the agent *can* invoke. Nothing
yet records what it *actually* invoked at runtime. Without that, two
governance questions stay unanswerable: "did this declared affordance ever
fire?" (dead-inventory detection) and "is the recorder even operating?"
(observability health). The parent spec's O3 settled that this runtime data
must **not** be inlined into HARNESS.md (humans own that file) — it lives in
`observability/`, referenced by path from the affordance section.

## Confirmed design decisions (user-adjudicated 2026-06-17)

1. **Hook surface: PostToolUse.** It is the only event that reliably knows
   `tool_name` per invocation (verified against the existing
   `markdownlint-check.sh` PreToolUse hook, which reads the tool payload from
   stdin JSON). `Stop`/`SessionEnd` hooks do not receive the per-tool list and
   would have to parse the transcript — fragile. Per-call cost is a single
   appended line; negligible.
2. **Storage: gitignored, per-machine, append-only NDJSON** at
   `observability/affordance-invocations.ndjson`. Gitignoring it dissolves the
   cross-machine merge problem entirely: each developer's file answers "did MY
   sessions invoke this?". NDJSON (one JSON object per line) is the
   concurrency-safe shape for an append-only hook fired across overlapping
   sessions.
3. **Tuple is minimal (privacy).** Each line records only the tool identity,
   the invoking surface, an opaque session id, and a UTC timestamp — **no tool
   arguments** (they can carry secrets/paths) and **no user identity**.

## The tuple format (the consumable contract)

One NDJSON object per invocation:

```json
{"tool": "<tool_name>", "program": "<bash-program-or-null>", "invoker": "<agent-or-command-or-unknown>", "session": "<opaque-id>", "ts": "<UTC-ISO-8601>"}
```

- **`tool`** — the Claude Code tool name as received (`Bash`, `Edit`,
  `mcp__honeycomb__query`, …). This is the affordance identity for MCP and
  named tools.
- **`program`** — for `Bash` only, the command's **program token** (the first
  whitespace-delimited word, e.g. `gh`, `git`, `npx`); `null` for non-Bash
  tools. This is the granularity an affordance pattern keys on
  (`Bash(gh *)` → program `gh`). It is the program *name*, never the
  arguments — the privacy boundary is "what was run", not "with what".
- **`invoker`** — the invoking agent or command if the payload exposes it,
  else `"unknown"`. Best-effort; the dead-inventory question works without it.
- **`session`** — the opaque session id from the payload (or `"unknown"`).
- **`ts`** — UTC ISO-8601 timestamp the hook stamps.

This shape is the **stable contract** downstream linters/dashboards consume.
The recorder appends; it never rewrites, so a partially-written final line
(crash mid-append) is the only corruption mode, and consumers tolerate a
trailing malformed line.

## Components

### The recorder hook — `hooks/scripts/affordance-invocation-recorder.sh`

A PostToolUse hook (registered in `hooks/hooks.json`). It:

1. Reads the tool payload from stdin.
2. Extracts `tool_name`; derives `program` for Bash (first token of the
   command, never the rest); best-effort `invoker` and `session`.
3. Appends one NDJSON line to
   `observability/affordance-invocations.ndjson` (creating the dir/file).
4. **Never blocks, never errors loudly, never delays** — if `jq` is absent or
   the payload is unparseable it exits 0 silently (observability is
   best-effort; a recorder must not interfere with the session).

Privacy: it records `tool`, `program` (Bash program name only), `invoker`,
`session`, `ts`. It never writes tool arguments, file contents, or user
identity.

### The analyzer — `scripts/harness-affordance-invocations.sh`

A deterministic, report-only analyzer (testable; takes a project dir and a
`--today` override for hermetic tests). Two checks:

- **`--check=freshness [--max-age-days=N]`** — is the NDJSON file present and
  its newest `ts` within N days (default 7)? A stale or missing file means the
  recorder is probably not operating. Report-only.
- **`--check=dead-inventory [--max-age-days=N]`** — for each **declared**
  non-example affordance, has any invocation in the last N days (default 30)
  matched it? Matching: an MCP/named affordance matches a tuple whose `tool`
  equals (or `mcp__server__*` prefix-matches) the pattern; a `Bash(<prog> *)`
  affordance matches a tuple whose `program` equals `<prog>`. Unmatched
  affordances are flagged as **dead inventory** (declared but never observed).

Both exit 0 always (report-only); findings go to stdout, `LC_ALL=C`-sorted.

### Gitignore + GC wiring

- `.gitignore` (template + this repo): ignore
  `observability/affordance-invocations.ndjson`.
- Two **commented-opt-in** GC rules in `templates/HARNESS.md` (report-only,
  weekly) pointing at the analyzer's two checks. Because the file is
  gitignored, these run meaningfully only on a developer machine / the
  on-demand `harness-gc` agent — **not** the CI cron (which has no file and
  the analyzer self-skips). The GC-rule prose states this honestly.

## Acceptance scenarios

1. **Recorder appends a well-formed tuple** for a Bash `gh ...` call: one
   NDJSON line with `tool:"Bash"`, `program:"gh"`, no arguments present.
2. **Recorder is silent and harmless** when `jq` is absent or the payload is
   unparseable (exit 0, no output, session unaffected).
3. **No arguments leak** — a Bash call `gh pr create --title "secret"` records
   `program:"gh"` and nothing of the title/args.
4. **Freshness** — a file whose newest `ts` is older than the threshold (or a
   missing file) is reported stale; a fresh file reports OK.
5. **Dead inventory** — a declared affordance with no matching invocation in
   the window is flagged; one with a matching invocation is not.
6. **Matching granularity** — `Bash(gh *)` matches a `program:"gh"` tuple;
   `mcp__honeycomb__*` matches a `tool:"mcp__honeycomb__query"` tuple; example
   affordances are skipped.
7. **Hermetic** — `--today` fixes "now"; the analyzer is deterministic.

## Functional requirements

- **FR1** A PostToolUse recorder hook appends a minimal NDJSON tuple per
  invocation to a gitignored `observability/affordance-invocations.ndjson`,
  recording no arguments and no user identity, and never blocking/erroring.
- **FR2** The tuple format is the documented stable contract above.
- **FR3** A deterministic analyzer provides freshness and dead-inventory
  checks (report-only, `--today` hermetic), with the documented matching.
- **FR4** The NDJSON path is gitignored (template + repo); two commented
  opt-in GC rules reference the analyzer with honest "runs locally, not CI"
  prose.
- **FR5** Layer 0 tests cover the recorder's tuple shape + privacy (no args)
  and the analyzer's freshness/dead-inventory/matching scenarios.
- **FR6** Docs: a reference page for the tuple format and an explanation/how-to
  update.

## Adjudication (post-diaboli, 2026-06-17)

Spec-mode `/diaboli` raised twelve objections (6 high; record:
`docs/superpowers/objections/affordance-runtime-recorder-design.md`). All
adjudicated — every objection **amend**. None re-opened the three
user-confirmed forks; they refine robustness/correctness within them. The
binding refinements below supersede the wording above where they conflict.

- **A1/A12 (O1/O12) — keep the `.json` filename.** The file stays
  `observability/affordance-invocations.json` (the established O3 reference in
  HARNESS.md, the parent spec, and the docs) with **NDJSON content** (one JSON
  object per line). This spec supersedes the parent's step-7 *hook surface*
  wording (PostToolUse, user-confirmed) while keeping the filename, so the
  human-facing section-header pointer and the freshness exemplar stay valid.
- **A2/A4 (O2/O4) — sanitise the Bash `program` token.** Strip leading
  `KEY=VALUE` env-var prefixes, take the program word, **`basename`** it (a
  path → just the script name), and record it **only if** it matches
  `^[A-Za-z0-9._-]+$`; otherwise record `program:null`. The recorder never
  writes a raw path, an env assignment, or pipeline/subshell syntax — the
  no-secrets guarantee is enforced by this normalisation, with acceptance
  scenarios for the env-prefix and path-form cases.
- **A3 (O3) — conservative, program-coarse Bash matching.** Dead-inventory
  matching is exact for MCP/named tools; for Bash it is program-granular and
  **conservative** — an observed program marks **every** Bash affordance
  sharing that program as observed (a false-alive, never a false-dead). The
  output states that Bash matching does not distinguish narrow from broad
  grants. This is a documented limitation of the minimal-tuple privacy choice.
- **A5 (O5) — honest local-observability framing.** Because the data file is
  gitignored (user-confirmed), the recorder and its checks are **per-machine
  local observability, not a CI governance control**. Stated in the value
  proposition. A `gc.yml` step is deliberately **not** added (it would always
  self-skip with no file); the checks run via the on-demand `harness-gc` agent
  and the commented opt-in GC rules. A future committed-aggregate step could
  add a team/CI view.
- **A6/A9 (O6/O9) — recorder uses grep/sed, no jq.** The recorder extracts
  fields with grep/sed + `printf` (matching `markdownlint-check.sh`), removing
  the jq silent-no-op trap; per-call cost is one extraction + one short append.
  The **analyzer** (a script, not a hook) may use jq but prints a clear
  `jq not installed` line rather than silently flagging everything.
- **A7 (O7) — value is dead-inventory, invoker is a bonus.** The feature's
  value is "did this declared affordance fire?", which does not depend on
  `invoker`. `invoker` is recorded best-effort; the spec no longer presents
  "which agent invoked it" as the headline.
- **A8 (O8) — atomic small tuple + tolerant analyzer.** The tuple is kept well
  under 512 bytes (PIPE_BUF) so a single `O_APPEND` write is atomic on POSIX;
  the analyzer skips **any** unparseable line, not just the trailing one.
- **A10 (O10) — bounded file.** The recorder self-trims: when the file exceeds
  a line cap (5000), it retains the last N lines, bounding size while keeping
  far more than the 30-day dead-inventory window on a normal machine.
- **A11 (O11) — exclude hooks from dead-inventory.** A PostToolUse recorder
  cannot observe hook firings, so `Mode: hook` affordances are **excluded**
  from dead-inventory (never mis-flagged as dead), consistent with
  steps-4+5 excluding hooks from the permission relation.

## Risks and mitigations

- **PostToolUse volume.** One small append per tool call; NDJSON append is
  cheap and the file is gitignored (no commit churn). Acceptable.
- **`invoker` may be unavailable in the payload.** Recorded best-effort as
  `"unknown"`; the dead-inventory question (the primary value) does not depend
  on it.
- **Bash granularity.** Recording the program token (not args) means a
  `Bash(gh pr *)` vs `Bash(gh *)` distinction cannot always be made from the
  program name alone — matching is at program granularity for Bash. Documented
  as a known coarseness; exact matching holds for MCP/named tools.
- **Gitignored ⇒ no CI enforcement.** The two GC rules are local/advisory by
  design (the file is per-machine). Stated honestly; a future committed-
  aggregate step could add a team view.
- **Partial final line on crash.** Consumers tolerate a trailing malformed
  line; the analyzer skips unparseable lines.
