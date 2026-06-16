---
name: harness-affordance
description: Manage the project's affordance inventory — declared tools the agent can invoke, the identity each tool runs under, and the audit trail each tool produces. Subcommands - discover (scan config to produce a draft inventory), add (promote a draft into HARNESS.md with governance metadata), review (planned). See docs/superpowers/specs/2026-04-26-harness-affordances-design.md for the design.
---

# /harness-affordance \<subcommand\> [args...]

Manage the project's affordance inventory — the declared tools the
agent can invoke, with their identity, audit trail, and permission
allowlist links.

## Subcommands

### `discover`

Scan the project's config (`.claude/settings.json`,
`.claude/settings.local.json`, `.mcp.json`) and emit a draft
affordance inventory to a scratch file at
`.claude/affordance-discovery-<date>.md`.

The scanner does not touch `HARNESS.md`. After review, the human
copies approved entries into the `## Affordances` section by hand
(or, in a future release, via `/harness-affordance add <name>`),
filling in the human-owned governance fields (Identity, Audit
trail, Notes).

This is the **backfill path** for projects that adopted the harness
before the affordances section shipped — running `discover` once
produces a draft for every existing permission, hook, and MCP
server.

### Process

1. **Verify prerequisites.** `jq` must be installed. If missing,
   the script aborts with a clear install hint. Verify the project
   directory contains at least one of `.claude/settings.json`,
   `.claude/settings.local.json`, or `.mcp.json`. If none exist,
   tell the user: "No project config found to scan — nothing to
   discover."
2. **Invoke the scanner.** Run
   `bash ${CLAUDE_PLUGIN_ROOT}/scripts/harness-affordance-discover.sh`
   from the project root. The script is responsible for reading
   sources, deriving entries, and writing the output file.
3. **Report.** Print to the user:
   - Output file path
   - Count of draft entries by Mode (`cli` / `local-mcp` /
     `central-mcp` / `hook`)
   - Any warnings the scanner emitted (e.g. MCP server declared
     without a matching permission entry)
   - Suggested next step: "Review the draft, then copy approved
     entries to HARNESS.md under `## Affordances`. Each entry needs
     **Identity** and **Audit trail** filled in (the scanner only
     supplies the machine-derivable fields)."

### `add <name>`

Guided annotation that promotes one affordance into the `## Affordances`
section of `HARNESS.md`, mirroring `/harness-constrain`. The human dictates
every governance field; the command only transcribes their answers, so
`HARNESS.md` stays human-authored in spirit. Requires a `<name>` argument
(the heading the entry will carry); if omitted, ask for one.

### Process

1. **Seed from a draft, if any.** Look for the newest discovery scratch
   file — the lexically last `.claude/affordance-discovery-*.md` (filenames
   are date-stamped). If it contains an entry whose `Permission` matches
   what the user is annotating, use that entry's `Mode`, `Trigger` (if
   present), and `Permission` as the starting point. Otherwise prompt for:
   - `Mode` — `cli` / `local-mcp` / `central-mcp` / `hook`
   - `Trigger` — **only if** `Mode: hook`; one of the Claude Code hook
     events (`PreToolUse` / `PostToolUse` / `Stop` / `SubagentStop` /
     `SessionStart` / `SessionEnd` / `UserPromptSubmit` / `PreCompact` /
     `Notification`)
   - `Permission` — the allowlist pattern that authorises this affordance

   A wrapper-hook draft (the scanner's known #205 gap) may seed a
   wrapper-derived name like `bash-stop`; the user is free to pass a clearer
   `<name>` — idempotency keys on `Permission`, not the heading, so renaming
   never creates a duplicate.

2. **Identity** *(load-bearing governance question — whose credentials
   authorise the action)*. Prompt with the five values and their
   definitions:
   - `user-sso` — the human's external SSO credentials (GitHub PAT, Slack
     token, cloud SSO). Highest-attribution failure mode.
   - `service-account` — shared bot credentials; per-user attribution lost.
   - `current-user` — the human running the session, no boundary crossed
     (filesystem, local network); still attributable, may have no remote
     audit trail.
   - `runtime-resolved` — identity depends on session config. **Require a
     resolution-chain narrative in Notes** (e.g. `gh`: `$GITHUB_TOKEN` →
     keychain → fail).
   - `none` — no authentication boundary crossed at all.

3. **Audit trail.** Prompt with the pattern `<source>: <retention>,
   <access scope>`. State explicitly that **`none` is fine and is itself
   governance signal** — it tells reviewers where the gaps are without
   forcing fabrication.

4. **Last reviewed.** Set to today's date automatically — an `add` is a
   genuine first review.

5. **Optional fields.** `Constraint references` (constraints that depend on
   this affordance) and `Notes` (freeform context).

6. **Validate** before writing:
   - required fields present: `Mode`, `Identity`, `Audit trail`,
     `Permission`, `Last reviewed`;
   - `Trigger` present **iff** `Mode: hook`;
   - **permission existence** — check whether the `Permission` pattern
     appears in any of `.claude/settings.json`,
     `.claude/settings.local.json`, or `~/.claude/settings.json`. If a
     settings layer is absent or unreadable in this environment (sandboxed
     sessions, CI), skip it but **say so**, so a clean "absent" is not
     confused with "could not check". If the pattern is found, pass
     silently. If it is not found in any *readable* layer, **warn** (do not
     block), naming which layers were checked: "Permission `<pattern>` not
     found in <layers checked> — the affordance may precede its grant, the
     pattern may be mistyped, or the user layer (`~/.claude/settings.json`)
     was not readable here."

7. **Write into `HARNESS.md` `## Affordances`** (idempotent):
   - If an entry already exists whose `Permission` field string-equals the
     new pattern, **edit that entry in place** (replace its fields), keeping
     its heading unless the user renamed it. Never append a second entry for
     the same permission pattern.
   - Otherwise append a new `### <name>` entry.
   - If the `## Affordances` section does not exist, create it
     **immediately before `## Observability`** (i.e. directly after the
     `## Garbage Collection` section), matching the template's section
     order. Do not place it just above `## Status` — `## Observability` and
     `## Read-side filtering` sit between Affordances and Status in the
     template.

8. **Validation checkpoint.** Re-read the entry just written and verify it
   against the field schema (required fields present, `Trigger`/`Mode`
   pairing, `Last reviewed` is a `YYYY-MM-DD` date with no residual `TODO`
   placeholder). Fix any deviation in place — do not re-prompt the user.

Report the entry written and its location. (Constraint-chaining — suggesting
a `/harness-constrain` that references this affordance — arrives in
sequencing step 4, once the chained constraints that consume it exist.)

### `review` *(not yet implemented)*

Planned for sequencing step 6. Will walk through the three
re-validation checks (Identity, Audit trail, Permission) and bump
`Last reviewed` if all pass.

If invoked today, tell the user: "`/harness-affordance review` is
not yet implemented (sequencing step 6 of the affordances design).
For now, hand-edit `Last reviewed` after manually re-validating
the three checks listed in the design spec."

## Routing

If invoked without a subcommand, print the list of available
subcommands and a one-line summary of each. Do not assume a
default.

If invoked with an unknown subcommand, list the supported
subcommands and exit. Do not silently proceed.
