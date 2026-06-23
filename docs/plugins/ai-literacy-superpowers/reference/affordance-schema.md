---
title: Affordance Schema
---
# Affordance Schema

Field-by-field reference for entries in the `## Affordances` section of
`HARNESS.md`. Each entry is one affordance — one tool the agent can invoke —
under a `### <name>` heading, where `<name>` is a human-chosen label.

## Granularity: one affordance per permission pattern

The unit of an affordance is one entry in the permissions allowlist.
`Bash(gh *)` is one affordance; `Bash(gh pr *)` is a separate, narrower
affordance. An MCP server with twenty methods exposed under
`mcp__server__*` is one affordance, not twenty. The same CLI used under two
different identities in different sessions is one entry with the runtime
ambiguity flagged in `Notes` (or declared `Identity: runtime-resolved`).

This makes affordance identity a stable string — the `Permission` pattern —
which is what `/harness-affordance add` keys idempotency on (not the heading
name, which you may rename freely). It follows that each entry carries
**exactly one permission pattern** in its `Permission` field: a tool that
needs two patterns (e.g. `Bash(echo *)` *and* `Bash(touch *)`) is two
affordances, not one entry with a comma-joined value — otherwise the
string-equality idempotency match would never fire and `add` would append
duplicates.

## Fields

| Field | Required | Source | Values |
| --- | --- | --- | --- |
| `Mode` | yes | machine-derivable | `local-mcp` / `central-mcp` / `cli` / `hook` |
| `Trigger` | yes for `Mode: hook`; absent otherwise | machine-derivable | a Claude Code hook event (see below) |
| `Identity` | yes | human-owned | `user-sso` / `service-account` / `current-user` / `runtime-resolved` / `none` |
| `Audit trail` | yes | human-owned | named log with retention + access scope, or `none` |
| `Permission` | yes | machine-derivable | the allowlist pattern that authorises this affordance |
| `Last reviewed` | yes | procedure-controlled | `YYYY-MM-DD` |
| `Constraint references` | optional | human-owned | constraints that depend on this affordance |
| `Notes` | optional | human-owned | freeform context the schema does not capture |

### `Mode`

- `local-mcp` — MCP server running on the user's machine (may call out to
  remote APIs).
- `central-mcp` — MCP server hosted remotely (e.g. by the tool provider).
- `cli` — a shell command the agent invokes (`gh`, `git`, `npx`, custom
  scripts).
- `hook` — a Claude Code hook script registered in settings. Each hook is
  its own affordance; if a hook invokes a CLI internally, that CLI is *also*
  an affordance — the hook is the surface the agent triggers, the CLI is the
  underlying capability.

### `Trigger`

Present **if and only if** `Mode: hook`. One of the Claude Code hook events:
`PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `SessionStart`,
`SessionEnd`, `UserPromptSubmit`, `PreCompact`, `Notification`. Disambiguates
a script wired to multiple events.

### `Identity` — the load-bearing field

*Whose credentials authorise the action?*

- `user-sso` — the human's external SSO credentials (GitHub PAT, Slack
  token, cloud SSO). Actions appear in remote audit logs as if the user did
  them. **Highest-attribution failure mode.**
- `service-account` — dedicated bot credentials shared across the team or
  pinned to the project. Per-user attribution is lost.
- `current-user` — the human running the session, no special credentials,
  no boundary crossed (filesystem, local network, `git status`). Still
  attributable to a real principal even with no remote audit trail —
  distinct from `none`.
- `runtime-resolved` — identity depends on session configuration (env vars,
  profile, IAM role). **`Notes` must document the resolution chain.** Chained
  constraints treat this as a known unknown and may flag it for human review.
- `none` — no authentication boundary crossed at all (pure local
  computation, no filesystem effects, no network).

### `Audit trail`

Free-text, ideally `<source>: <retention>, <access scope>` (e.g.
`github-audit (org audit log, 90-day retention, admin-only access)`). The
honest answer `none` is encouraged and is itself governance signal.

### `Permission`

Links the affordance to the entry in Claude Code's `permissions` allowlist
that authorises it. This pairing makes the governance loop explicit:
affordances declare what tools the agent *should* have; permissions enforce
what it *actually* has. `/harness-affordance add` warns (without blocking) if
the pattern is absent from `.claude/settings.json`,
`.claude/settings.local.json`, and `~/.claude/settings.json` — an affordance
may legitimately precede its grant.

### `Last reviewed`

`YYYY-MM-DD`. Set to today automatically on `add` (a genuine first review)
and bumped thereafter only by `/harness-affordance review <name>` after its
three re-validation checks — Identity, Audit trail, and Permission — all
pass. A failing check leaves the date and records a single
`[review-gap: <check>]` Notes line instead. Editing other fields does **not**
bump the date, so the **`Affordance review staleness`** GC rule
(`scripts/harness-affordance-staleness.sh`) stays meaningful: it flags any
affordance whose `Last reviewed` is older than the configured threshold
(default 180 days; tune it via the `affordance-review-threshold-days` marker
in the `## Affordances` section header) or has no valid date. Hook entries
are included (their Identity/Audit trail can go stale too); example entries
are skipped. The rule is report-only — the fix is running `review`.

### `Constraint references`

*Optional.* The constraint heading(s) that depend on this affordance — for
example a chained constraint that consumes the grant. Human-owned and
free-form: `add` and `review` only transcribe what you dictate, never infer
it. Omit the field entirely when no constraint references the entry.

## Matching algorithm

When a chained constraint compares affordances against permissions,
"matching" is **string equality** on the `Permission` pattern. A permission
`Bash(gh pr *)` matches the affordance whose `Permission` is exactly
`Bash(gh pr *)` and no other. Broader patterns subsume narrower invocations
rather than producing separate entries — `gh pr merge` authorised by
`Bash(gh *)` is recorded against the single broader-pattern affordance.

## Related

- [Harness Affordances](../explanation/harness-affordances.md) — why the
  section exists.
- [Discover affordances](../how-to/discover-affordances.md) — produce and
  promote entries.
