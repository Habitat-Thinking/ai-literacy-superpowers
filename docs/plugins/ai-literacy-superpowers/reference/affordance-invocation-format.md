---
title: Affordance Invocation Format
---
# Affordance Invocation Format

The PostToolUse recorder hook
(`hooks/scripts/affordance-invocation-recorder.sh`) appends one tuple per
affordance-relevant tool call to `observability/affordance-invocations.json`.
This page is the **stable contract** downstream linters and dashboards consume.

## Storage

- **Path**: `observability/affordance-invocations.json`
- **Content**: **NDJSON** — one JSON object per line (the `.json` extension is
  kept for continuity with the affordance section's runtime-data reference;
  the content is line-delimited, not a single array).
- **Gitignored, per-machine.** The file is append-only and not committed, so
  there is no cross-machine merge. It answers "did *my* sessions invoke this?".
- **Bounded**: the recorder self-trims to the last 5000 lines.
- **Append-only**: the recorder never rewrites existing lines, so the only
  corruption mode is a partial final line; consumers skip any unparseable
  line.

## What is recorded

Only **`Bash` and `mcp__*`** tool calls (the tools that map to affordances).
Built-in file tools (`Read`, `Edit`, `Write`, `Grep`, …) are **not** recorded.

## Tuple schema

```json
{"tool": "<string>", "program": "<string|null>", "invoker": "<string>", "session": "<string>", "ts": "<UTC ISO-8601>"}
```

| Field | Type | Meaning |
| --- | --- | --- |
| `tool` | string | The Claude Code tool name as received (`Bash`, `mcp__honeycomb__query`, …). The affordance identity for MCP and named tools. |
| `program` | string or `null` | For `Bash` only, the command's **program name** — env-var prefixes stripped, path `basename`'d, and accepted only if it matches `^[A-Za-z0-9._-]+$`. `null` for non-Bash tools or any command whose first token is not a clean program name. |
| `invoker` | string | The invoking agent/command if the payload exposes it, else `"unknown"` (best-effort; the dead-inventory question does not depend on it). |
| `session` | string | The opaque session id, or `"unknown"`. |
| `ts` | string | UTC ISO-8601 timestamp the hook stamps (`YYYY-MM-DDTHH:MM:SSZ`). |

## Privacy guarantees

The recorder records **no tool arguments, no file contents, no paths, and no
user identity**. The `program` field is the program *name* only:

- `GH_TOKEN=ghp_secret gh pr list` → `"program": "gh"` (the env-var prefix,
  including the secret, is stripped).
- `/Users/alice/private/deploy.sh --env prod` → `"program": "deploy.sh"` (the
  path is reduced to its basename; the arguments are dropped).
- `( echo hi ) | tee x` → `"program": null` (shell syntax is not a program
  name).

**Accuracy note (fail-safe):** because the recorder extracts the program with
grep/sed (no jq, to avoid a silent-no-op dependency), a command whose first
token is preceded by a quoted segment (`"my tool" run`) or a quoted env value
with a space (`FOO="a b" gh …`) records `"program": null` rather than the
program. This **never leaks** (it errs to `null`), but it can cause the
dead-inventory check to mark a genuinely-used Bash affordance as `DEAD`. Real
programs are bare tokens (`gh`, `git`, `npx`), so this is uncommon; combined
with the conservative, program-coarse Bash matching it means dead-inventory is
a *report-only local advisory*, not an authoritative signal, for Bash.

## Consuming the file

The analyzer `scripts/harness-affordance-invocations.sh` reads it:

- `--check=freshness` — is the newest `ts` within `--max-age-days` (default 7)?
- `--check=dead-inventory` — does each declared, non-example, **non-hook**
  affordance have a matching invocation within `--max-age-days` (default 30)?

**Matching**: exact `tool` equality (or `mcp__server__*` prefix) for MCP/named
tools; **program-coarse and conservative** for Bash — a `Bash(<prog> *)`
affordance matches a tuple whose `program` equals `<prog>`, and an observed
program marks every Bash affordance sharing it as observed (a false-alive,
never a false-dead). Hook affordances are excluded (a PostToolUse recorder
cannot observe hook firings).

Both checks are **report-only** and, because the data file is gitignored, are
**local per-machine observability** — they run via `/harness-gc` on your
machine, not the CI cron.

A downstream consumer should: read the file line by line, `JSON.parse` each
line, **skip** lines that fail to parse, and treat field absence as `null` /
`"unknown"`.
