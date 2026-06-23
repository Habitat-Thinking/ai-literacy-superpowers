---
title: Maintain Your Affordance Inventory
---
# Maintain Your Affordance Inventory

Declaring an affordance is not a one-off act. A tool grant is a governance
claim — *this tool runs under that identity, and a record of what it did
lives there* — and claims rot. Credentials rotate, audit endpoints are
decommissioned, permissions are removed, and tools fall out of use. This
guide walks the **complete loop** an affordance travels through, from first
discovery to eventual retirement, and the commands and checks that move it
between stages.

If you only want to produce a first draft inventory, see
[Discover Affordances](discover-affordances.md). If you want the concept and
the *why*, see [Harness Affordances](../explanation/harness-affordances.md).
This page is about what happens **after** an entry is in `HARNESS.md`.

## When to use this

- **You have run `discover` and now need to promote drafts** into the
  `## Affordances` section as governed entries.
- **An affordance has aged** and the `Affordance review staleness` check is
  flagging it.
- **You are wiring the affordance constraints into CI** and want to
  understand what they will and will not block.
- **You suspect a declared tool is no longer used** and want to retire it
  cleanly rather than carry an ungoverned grant.

## The loop at a glance

| Stage | What moves it | Where it lives |
| --- | --- | --- |
| 1. Discover | `/harness-affordance discover` | draft scratch file |
| 2. Add | `/harness-affordance add <name>` | `## Affordances` in `HARNESS.md` |
| 3. Live | the two affordance constraints | every PR |
| 4. Re-validate | `/harness-affordance review <name>` | `Last reviewed` date |
| 5. Staleness | `Affordance review staleness` GC rule | weekly sweep |
| 6. Retire | `Affordance dead inventory` GC rule + a human | removed entry + permission |

The loop is not a straight line: stages 3–5 cycle for as long as the tool is
in use. An affordance leaves the loop only when a human retires it at stage 6.

## 1. Discover the tools already in play

Run the scanner to turn your existing config into a draft inventory:

```text
/harness-affordance discover
```

It reads `.claude/settings.json`, `.claude/settings.local.json`, and
`.mcp.json` and writes one draft entry per permission, hook, and MCP server
to a gitignored scratch file. It fills the machine-derivable fields and
leaves the governance fields as `TODO`. This is the backfill path — run it
once on an existing project and you have a starting point for every grant.
Full walkthrough: [Discover Affordances](discover-affordances.md).

## 2. Add an affordance with its governance fields

Promote a draft (or declare a brand-new tool) into `HARNESS.md`:

```text
/harness-affordance add <name>
```

`add` seeds from the matching discovery draft, then prompts only for the
fields a human must decide:

- **Identity** — whose credentials authorise the action: one of `user-sso`,
  `service-account`, `current-user`, `runtime-resolved`, or `none`. This is
  the load-bearing field; for `runtime-resolved`, record the resolution
  chain in Notes.
- **Audit trail** — where a record of the action would be found. `none` is a
  valid and useful answer: it tells reviewers exactly where the gap is.
- **Constraint references** and **Notes** — optional.

It sets `Last reviewed` to today (an `add` *is* a genuine first review), and
**warns without blocking** if the permission pattern is not present in any
readable settings allowlist — a tool you have declared but not yet granted.
Idempotency keys on the permission pattern, so re-running `add` for the same
pattern edits the entry in place rather than duplicating it. The field
definitions live in the
[affordance schema reference](../reference/affordance-schema.md).

## 3. Live: the two constraints gate every PR

Once the `## Affordances` section is populated and the constraints are
uncommented, two deterministic checks run on every pull request:

- **Affordances have matching permissions** (*blocking*) — every
  non-example, non-hook affordance must have a `Permission` pattern that
  appears verbatim in a settings allowlist. An affordance with no matching
  grant is a declared-but-unusable tool — the PR fails.
- **Permissions have declared affordances** (*advisory*) — every allowlist
  entry should have a matching affordance. An ungoverned permission is
  paperwork debt, not a safety hole, so this one flags without blocking.

Both self-gate to `unverified` (a passing no-op) until the project has at
least one real, non-example affordance and a readable allowlist, so they are
safe to enable early. The matching rule is string equality on the permission
pattern — see the
[matching algorithm](../reference/affordance-schema.md#matching-algorithm).

## 4. Re-validate with `review`

A governance claim is only as trustworthy as its last check. Re-validate an
entry with:

```text
/harness-affordance review <name>
```

`review` walks the **three checks** — Identity, Audit trail, and Permission
— each with an explicit `yes / no / needs-edit` prompt; there is no implicit
"looks fine" pass. The disposition is deliberate:

- **All three `yes`** → `Last reviewed` is bumped to today, and any stale
  `[review-gap: <check>]` Notes lines are cleared.
- **A `needs-edit`** → you dictate the new value; an edit alone does **not**
  bump the date — a bump requires re-answering all three checks `yes`.
- **An unresolved `no`** → the date is left unchanged and a single
  `[review-gap: <check>]` Notes line records the gap, so the staleness rule
  keeps firing until it is genuinely resolved.

Because the date is bumped *only* by a passing `review` — never by editing
another field, never by a `git` mtime — `Last reviewed` is a real
attestation rather than a timestamp.

## 5. Respond to staleness

The `Affordance review staleness` GC rule sweeps weekly and flags any entry
whose `Last reviewed` has aged past the threshold (default 180 days, tunable
via the `affordance-review-threshold-days` marker in the `## Affordances`
header) or has no valid date. It reads committed content, so it runs the same
on any machine and in CI. It is report-only — the fix it reports is running
`review` on the named entry, which loops you back to stage 4. See the
[Garbage Collection](../explanation/garbage-collection.md#affordance-gc-rules)
explanation for how these rules fit the wider entropy-fighting model.

## 6. Retire dead affordances

Two **local, per-machine** GC rules watch for tools that have fallen out of
use, reading the gitignored `observability/affordance-invocations.json`
written by a `PostToolUse` recorder hook:

- **Affordance recorder freshness** — a meta-check that the recorder is still
  running, so the next rule's data can be trusted.
- **Affordance dead inventory** — surfaces each declared affordance with no
  observed invocation in the last 30 days.

A dead affordance is a grant and a governance burden carried for nothing. When
one is surfaced, decide deliberately: keep it (the recorder may simply have
missed it — matching is conservative), narrow it, or remove the entry **and**
its permission together. Removing the entry without removing the permission
re-creates the advisory finding from stage 3; removing the permission without
the entry re-creates the blocking one. Retire both, and the affordance leaves
the loop.

## The loop, restated

`discover` produces candidates; `add` turns a candidate into a governed
claim; the constraints keep the claim honest on every PR; `review` refreshes
the claim before it goes stale; the staleness rule makes sure `review`
actually happens; and the dead-inventory rule asks, periodically, whether the
claim is still worth carrying at all. Nothing in the loop writes a governance
judgment for you — every stage either transcribes a decision you made or
surfaces a question for you to answer.

## Related

- [Discover Affordances](discover-affordances.md) — produce the first draft.
- [Harness Affordances](../explanation/harness-affordances.md) — the concept
  and the contractor scenario.
- [Affordance schema reference](../reference/affordance-schema.md) — every
  field, value by value.
- [Garbage Collection](../explanation/garbage-collection.md#affordance-gc-rules)
  — the affordance GC rules in context.
- The command itself: `ai-literacy-superpowers/commands/harness-affordance.md`.
