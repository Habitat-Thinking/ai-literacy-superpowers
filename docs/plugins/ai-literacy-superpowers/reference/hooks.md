---
title: Hooks
---
# Hooks

All hooks are registered in `hooks/hooks.json` and active in every
session. Hooks are advisory only — they warn but never block.

---

## PreToolUse Hooks

These hooks fire **before** Claude's `Write` or `Edit` tool call runs, and can
stop it. A `command` hook warns by printing and exiting 0, or blocks by exiting
2. A **`prompt`** hook has no such distinction: returning nothing allows the
call and returning any text denies it. That is why the constraint gate is not
here — see PostToolUse, below.

### Markdownlint check (command)

- **Event**: PreToolUse
- **Matcher**: `Write|Edit`
- **Type**: command
- **Script**: `hooks/scripts/markdownlint-check.sh`
- **Timeout**: 15s

Extracts the file path from the tool input JSON. If the file is a
`.md` file and `markdownlint-cli2` is available via `npx`, runs the
linter and returns any violations as a warning. Exits silently for
non-markdown files, files that do not yet exist on disk (new files
via Write), or when the tool is not installed.

Complements the prompt-based constraint gate with deterministic
checking — the prompt hook catches constraint intent, while this
hook catches formatting that machines are better at detecting.

---

## PostToolUse Hooks

These fire **after** a tool call has run. Output is advisory by construction:
the work has happened, so a hook here informs rather than prevents.

### Constraint gate (prompt)

- **Event**: PostToolUse
- **Matcher**: `Write|Edit`
- **Type**: prompt
- **Timeout**: 30s

Reads the Constraints section of `HARNESS.md`, identifies constraints scoped to
`commit`, and reports any the file just written breaks.

**It reports only what it can quote.** A violation requires the constraint's
heading verbatim from `HARNESS.md` *and* the offending line from the
file. Without both, it returns nothing — and returning nothing is the correct
and common outcome. A document that discusses a rule is not a document that
breaks one.

**Why it is not a `PreToolUse` hook.** It used to be, and it could not do what
its own prompt asked. A `PreToolUse` prompt hook has exactly two channels —
return nothing (allow) or return text (deny) — so "warn, only warn" was
addressed to a model with no mechanism to comply, and the text it returned *was*
the block. It denied two legitimate writes, each citing a constraint that does
not exist in `HARNESS.md`. Moved in #510; the file is on disk and uncommitted
when the hook runs, so the warning stays actionable.

### Affordance invocation recorder (command)

- **Event**: PostToolUse
- **Matcher**: `Bash|mcp__.*`
- **Type**: command
- **Timeout**: 10s

Logs `Bash` and MCP tool calls to gitignored observability, so the affordance
inventory can be checked against what is actually invoked rather than what was
declared. Exits 0 unconditionally.

## Stop Hooks

These hooks fire when a Claude session ends. All produce JSON
`systemMessage` output so that Claude surfaces the message without
interrupting session flow.

### Drift check

- **Script**: `hooks/scripts/drift-check.sh`
- **Timeout**: 10s

Examines the most recent commit for changes to CI workflows, linter
configs, hook configs, or dependency manifests. If any of these
changed, `HARNESS.md` may need updating. Outputs a nudge to run
`/harness-audit`.

**Signals detected**: `.github/workflows/`, `.gitlab-ci.yml`,
`Jenkinsfile`, `.eslintrc`, `.prettierrc`, `.golangci`,
`.editorconfig`, `.pylintrc`, `.husky/`, `.pre-commit-config`,
`hooks.json`, `go.mod`, `package.json`, `pom.xml`,
`requirements.txt`, `*.csproj`.

### Snapshot staleness check

- **Script**: `hooks/scripts/snapshot-staleness-check.sh`
- **Timeout**: 10s

Finds the most recent health snapshot in `observability/snapshots/`
by filename date. If the snapshot is older than 30 days, suggests
running `/harness-health`. Works with both GNU and macOS date
implementations.

### Reflection prompt

- **Script**: `hooks/scripts/reflection-prompt.sh`
- **Timeout**: 10s

Counts commits made in the last four hours (approximate session
length). If commits were made, nudges you to run `/reflect` to
capture learnings before they evaporate. Only fires when
`REFLECTION_LOG.md` exists.

### Framework change prompt

- **Script**: `hooks/scripts/framework-change-prompt.sh`
- **Timeout**: 10s

Checks whether `framework/framework.md` was modified in recent
commits. If so, nudges three actions: run `/reflect`, run
`/sync-repos` to propagate changes to downstream repos, and check
whether downstream READMEs need updating.

### Secrets check

- **Script**: `hooks/scripts/secrets-check.sh`
- **Timeout**: 15s

If gitleaks is installed and `HARNESS.md` has a deterministic "No
secrets in source" constraint, scans the working directory for
committed secrets. Exits silently if gitleaks is not installed or
the constraint is not active.

### Rotating GC check

- **Script**: `hooks/scripts/gc-rotate.sh`
- **Timeout**: 10s

Picks one deterministic GC rule per session, rotating by
day-of-year modulo 4:

| Day mod | Rule checked |
| --- | --- |
| 0 | Secret scanner operational |
| 1 | Snapshot staleness |
| 2 | Shell scripts syntax |
| 3 | Shell scripts strict mode |

This ensures entropy is caught between weekly scheduled CI runs.
Agent-scoped rules (documentation freshness, command-prompt sync,
plugin manifest currency) are not included — they require LLM
judgement and are triggered via `/harness-gc` or
`/harness-health --deep`.

The two shell-script rules scope their scan to project-owned scripts
via `git ls-files` (falling back to a filesystem walk outside a git
repo), so vendored `node_modules` scripts, nested worktrees, and
`CLAUDE_CONFIG_DIR` shell snapshots do not trigger false positives.

### Curation nudge

- **Script**: `hooks/scripts/curation-nudge.sh`
- **Timeout**: 10s

Compares the number of reflection entries in `REFLECTION_LOG.md`
against the curated entries in `AGENTS.md`. If reflections
significantly outnumber promoted entries (by more than 2), nudges
you to review and curate learnings. This closes the gap in the
compound learning lifecycle where reflections are captured but never
promoted to team memory.

### Governance drift check (command)

- **Event**: Stop
- **Matcher**: `*`
- **Type**: command
- **Script**: `hooks/scripts/governance-drift-check.sh`
- **Timeout**: 10s

Checks whether governance-related files were modified during the
session and whether the last governance audit is stale (> 90 days).
Detects three signals: HARNESS.md changes involving governance
language, compliance or policy document modifications, and audit
staleness. Also flags when governance constraints exist in
HARNESS.md but no audit has ever been run. Nudges
`/governance-audit` or `/governance-health`.

### Mast boundary check (command)

- **Event**: Stop
- **Matcher**: `*`
- **Script**: `hooks/scripts/mast-boundary-check.sh`
- **Timeout**: 10s

Two notices against your declared `hard_stop_hour`: **approaching**, by default
30 minutes before (tune with `approaching_lead_minutes`), and **reached**, at
the line. Each fires **once per session**. At the line it recommends exactly
one thing — `/coda` — and says plainly that it does not stop you.

**What the store holds, and for how long.** One small file per repository under
`~/.claude/mast/`, recording only what *fired*: `reached hard_stop_hour=20:00`.
It holds **no record of what you decided** — nothing observes a choice, and
continuing is simply the absence of stopping. If you want your decision on the
record, `/coda` asks at close and writes your words.

The file is refreshed while the repo has a live session and pruned after
`stale_after_hours` without one. **The prune runs unconditionally**, before the
opt-in check — so removing your `Budgets` block cleans up rather than stranding
files forever.

**To switch it off**, remove the `mast-boundary-check.sh` entry from
`hooks/hooks.json`. `$CLAUDE_MAST_DIR` relocates the store and is test-only, as is `$CLAUDE_MAST_NOW`, which pins the clock to an `HH:MM` so a test can build a stop hour deterministically instead of racing `date`. A malformed value falls through to the real clock — a boundary notice must never break a `Stop` hook.

### Reservoir check (command)

- **Event**: Stop
- **Matcher**: `*`
- **Type**: command
- **Script**: `hooks/scripts/reservoir-check.sh`
- **Timeout**: 10s

An advisory watch on the human verifier the harness cannot verify.
Self-gates: silent exit 0 unless `HARNESS.md` contains an **active**
`## Cognitive reservoir` heading (the opt-in marker — the commented
template block stays inert) and the directory is a git repo. When opted
in, it counts observable proxies over the recent git window — continuous
session span, decision volume, context switches, and wall-clock hour —
and emits at most one `{"systemMessage": ...}` advisory if a disjunctive
threshold is crossed. Advisory-only: never blocks, never exits non-zero,
records no claim about the human's state. Every trigger is framed as a
precaution under uncertainty; it does not assert ego depletion or the
hungry-judges figure. See the `cognitive-reservoir` skill and the
[Watching the Verifier](../explanation/watching-the-verifier.md)
concept page.

It now carries one coordination line: it defers when a once-only advisory has
claimed the turn. This is a coordination change and not a behavioural one — its
proxies, thresholds, flags, recommendation text and advisory-forever standing
are unchanged, and it still fires whenever it would have fired, except on the
at most one turn per session when the Mast's boundary notice has spoken.

### Session registry sweep (command)

- **Event**: Stop
- **Matcher**: `*`
- **Type**: command
- **Script**: `hooks/scripts/session-registry-sweep.sh`
- **Timeout**: 10s

Renews this session's registry lease, then retires any lease that has
expired. It **renews — it never deletes this session's entry.** That is
the load-bearing detail: `Stop` fires each time the main agent finishes
responding, so a hook that deleted its own entry here would empty the
registry after the session's first answer, and the WIP Warden would
report one live session while four ran. Retirement happens only by lease
expiry, whose length is `stale_after_hours` in the pact file (default
12). Pruning lives on this rail rather than in any read path, which is
what keeps `registry_count` a pure read and the honesty flag a property
of the count rather than of whoever read first. Exits 0 unconditionally.
See [Pact file format](pacts-format.md).

---

## SessionStart Hooks

These hooks fire when a Claude Code session begins — **and also on
resume, clear, and compact**, so a `SessionStart` hook runs more than
once in the life of a session and must be idempotent.

### Session registry start

- **Script**: `hooks/scripts/session-registry-start.sh`
- **Timeout**: 10s

Writes this session's entry in the machine-global session registry
(`~/.claude/sessions/`), or renews its heartbeat if one already exists.
Idempotent by construction, because `SessionStart` re-fires on resume,
clear, and compact: it never resets `started_at`, since doing so would
mean a genuinely long-running session never ages out. The session id is
sanitised before it is used as a path component; a hostile id collapses
to `unknown`, which is one reason a registry containing `unknown.json`
reports its count as `inferred`. The registry is local, per-machine,
outside every work tree, and never committed. Exits 0 unconditionally —
a registry failure must never surface to a session.

**What it stores, and for how long.** One small JSON file per session,
under `~/.claude/sessions/`, holding four fields: the sanitised session
id, the project directory, when the session started, and when it last
completed a turn. Nothing else — no prompts, no file contents, no
assessment of any kind. An entry is retired once it goes
`stale_after_hours` without a heartbeat (12 by default, declared in your
pact file), so the registry is bounded rather than an accumulating
archive.

Under the `sentinel-design` skill's persistence rules this is
**hook-authored operational state**, a narrow third category alongside
records a human authored and claims an agent made about them. It is
permitted only because it is local, bounded, judges nothing, and is
disclosed here.

**To switch it off**, remove the `session-registry-start.sh` and
`session-registry-sweep.sh` entries from `hooks/hooks.json`. Everything
else in the plugin continues to work; the cadence sentinels that read
the registry will report `no Session WIP block declared — running in
observe-only mode`.

**`$CLAUDE_SESSIONS_DIR`** overrides the registry location. It exists so
the deterministic tests need no home directory and is **not intended for
production use** — pointing it inside a work tree defeats the guarantee
that nothing can be committed by accident.

### Parked resume check

- **Script**: `hooks/scripts/parked-resume-check.sh`
- **Timeout**: 10s

Surfaces parking records left open by an earlier session — id and next
action, nothing more — so a thread you parked with a concrete resume step
comes back to you. A record nobody ever sees again is a diary, not a
handoff.

**Fires on `startup` only.** `SessionStart` also fires on resume, clear
and compact, and an unguarded hook would re-inject the parked list into
the middle of an unrelated working session for the rest of the day. That
is not merely noisy: a parking record exists to release a thread's pull
so you can stop holding it, and printing it back at you mid-session hands
it straight back. An **absent** `source` also stays quiet — unknown
provenance is exactly where re-injection is possible, so silence is the
safe reading.

The guard reads the `source` field off the hook's own stdin and **writes
nothing**. A per-session marker file in `~/.claude/sessions/` would have
inherited that store's location guarantees without its retention
contract, and accumulated one file per session for the life of the
machine.

Records superseded by a `.resumed.md` transition are not surfaced. Exits
0 unconditionally. `$CLAUDE_PARKED_DIR` overrides the directory and is
test-only.

### WIP check (command)

- **Event**: SessionStart
- **Matcher**: `*`
- **Type**: command
- **Timeout**: 10s

Counts live registry entries against the `max_concurrent_sessions` limit
declared in the pact file's `Session WIP` block, and reports when the starting
session puts you over it. Lists which sessions are live and how long since each
last took a turn — "park one" is unanswerable if you cannot see which.

**It never invents a limit.** A `Session WIP` block carrying its mandatory
clause and no `max_concurrent_sessions` is a normal product of `/mast tune`, not
a malformed file. Reporting a breach of a line the human never drew is the worst
output this hook could produce, so it says no limit is declared and points at
`/mast tune`.

**It counts sessions and never watches the human.** That boundary is what keeps
the `reservoir-warden` trustworthy, and no script enforces it.

Silent when no block is declared — a `SessionStart` hook announcing itself to
everyone who never asked for this is an imposition. Fires on `source: startup`
**only**: `SessionStart` re-fires on resume, clear and compact, and a breach
report re-injected mid-session is the thrash the sentinel exists to name.

An inferred count is reported as approximate. Exits 0 on every path, including
an unreadable registry, unset `HOME`, and unparseable stdin.

---

## Libraries

Sourced by hooks, never registered in `hooks.json`. They appear here because
hooks are documented in terms of them, but they are **not hooks** and are not
counted as such — a heading count over the event sections above is exact.

### The advisory rail (`lib/advisory-rail.sh`)

`lib/advisory-rail.sh` lets at most one stop-advisory speak per turn, because
two messages about stopping arriving together is accumulated pressure — which
the evidence says works *worse* than a single boundary prompt.

It arbitrates by **precedence, not registration order**. A **once-only**
advisory (the Mast's notices) speaks; a **repeating** one (the reservoir
check, which re-emits every turn while a threshold stays crossed) defers to the
next turn it is going to get anyway. Ordering it the other way would have
permanently spent the message designed to arrive once.

A "turn" has no identifier a hook can read, so a claim holds for a 10-second
window. Two consequences, both bounded and neither hidden: two turns finishing
inside 10 seconds collapse into one, costing a skipped repeating advisory; and
a rail slow enough to straddle it lets both speak, costing one duplicate.

## Configuration

Hooks are configured in `hooks/hooks.json`. The file contains:

- A `description` field summarising the hook set
- A `PreToolUse` array — matcher patterns; fires before the tool call and can
  block it
- A `PostToolUse` array — matcher patterns; fires after, advisory by
  construction
- A `Stop` array — wildcard matcher; fires at the end of every assistant turn
- A `SessionStart` array — wildcard matcher; fires on start **and** on resume,
  clear and compact, so entries must be idempotent

Each hook entry specifies:

- **type**: `"prompt"` (LLM-evaluated) or `"command"` (shell script)
- **command** or **prompt**: the script path or prompt text
- **timeout**: maximum execution time in seconds

Hook scripts use `${CLAUDE_PLUGIN_ROOT}` for path resolution and
`${CLAUDE_PROJECT_DIR}` for the project working directory.

---

## Design Principles

**Advisory, not blocking.** All hooks warn but never prevent the
action. This is deliberate — blocking hooks during creative work
interrupts flow and trains developers to work around the system.
The middle loop (CI gates) provides blocking enforcement.

**JSON systemMessage output.** Stop hooks output
`{"systemMessage": "..."}` so that Claude surfaces the nudge in
the conversation. Plain text output would be ignored.

**Silent on non-applicable.** Every hook checks prerequisites
(file existence, tool availability) and exits silently with
`exit 0` when the check does not apply. This prevents noise in
projects that do not use all features.

**Strict mode.** All hook scripts use `set -euo pipefail` within
the first 15 lines, as required by the harness constraint.
