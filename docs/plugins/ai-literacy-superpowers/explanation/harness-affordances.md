---
title: Harness Affordances
---
# Harness Affordances

An **affordance** is one tool the agent can invoke — a CLI command, an MCP
server, or a hook — declared in `HARNESS.md` together with the two questions
that matter for governance: *whose credentials does it run under?* and
*where would you find a record of what it did?* The `## Affordances` section
makes the agent's tool inventory a first-class, review-facing artefact,
sibling to Context, Constraints, and Garbage Collection.

## Why the section exists: the contractor scenario

Imagine a contractor brought in for a two-week engagement to review a
project's AI governance posture. Their first task is to answer, for every
tool the agent can use: what is it, under whose authority does it run, and
what audit trail does it leave?

Without an affordances section they must reconstruct that inventory by hand:
read `~/.claude/settings.json` and `.claude/settings.local.json` for
permission patterns (which say *what is allowed* but not *under whose
authority*), open and read every hook script referenced by path, consult
each MCP server's documentation to learn whether it runs locally or hits a
remote API under what credential, and read every `agents/*.agent.md`
frontmatter to map agents to tools. A diligent reviewer can do this in two
to four hours; a less-diligent one produces a wrong inventory or skips it.
Either way the project's governance pace is gated on how thorough someone
was on day one, because **the inventory does not exist as a review-facing
artefact**.

The deeper failure this enables: *agents executing under shared or escalated
identity without that fact being visible at review time*. A constraint like
"all production-affecting actions require human review" is unenforceable if
no one knows which actions are production-affecting — which depends on which
identity executes them.

## Identity is the load-bearing question

The section deliberately surfaces **Identity**, not transport, as the
primary field. Whether a tool is a CLI or an MCP server matters less than
whose credentials it borrows:

- `user-sso` actions appear in remote audit logs *as if the human did
  them* — the highest-attribution failure mode.
- `service-account` actions are attributable only to a shared bot, so
  per-user attribution is lost.
- `current-user` actions cross no authentication boundary but are still
  attributable to a real principal.
- `runtime-resolved` identity depends on session configuration (env vars,
  profile selection, IAM role) — a known unknown the reviewer must trace.
- `none` crosses no boundary at all.

**Audit Trail** is the second first-class field, and its honest answer
`none` is itself governance signal: it tells reviewers where the gaps are
without forcing anyone to fabricate a log that does not exist.

## The source-of-truth split

The section preserves the harness invariant that **`HARNESS.md` is 100%
human-authored**. Three layers stay distinct:

- **Config files** (`settings.json`, `.mcp.json`, hook registrations) are
  the machine-derivable substrate — what is *granted*.
- **`observability/affordance-invocations.json`** holds runtime data — which
  agent invoked which tool, when, how often. It is *referenced* from the
  section header, never inlined.
- **`HARNESS.md ## Affordances`** is the review-facing prose layer humans
  own — what is *declared*, with the governance judgments (Identity, Audit
  Trail) that no scanner can infer.

The discovery scanner reads the first layer to produce a draft; the human
promotes entries (via `/harness-affordance add`, which only transcribes the
governance fields they dictate) into the third. Nothing automated authors
the prose layer.

## Capability-based security, made legible

Permissions enforce *what tools the agent actually has*; affordances declare
*what tools it should have, and under what authority*. Pairing the two makes
the governance loop explicit through an **asymmetric pair of chained
constraints** (`scripts/harness-affordance-check.sh`) that reason across the
inventory:

- **Affordances have matching permissions** — *blocking*. Every non-example,
  non-hook affordance's `Permission` pattern must appear verbatim in the
  permissions allowlist. A declared tool the agent cannot actually invoke is
  a real safety gap.
- **Permissions have declared affordances** — *advisory*. Every allowlist
  entry should have a governing affordance. An ungoverned grant is paperwork
  debt, flagged not blocked.

Matching is string equality on the permission pattern (one affordance per
pattern). Both directions **self-gate to `unverified`** until the project has
a real affordance *and* a readable allowlist, so they never fire on a project
that has not adopted affordances yet, and they skip the example entries
(marked with `<!-- affordance-example -->`) and hook-mode affordances (whose
`Permission` is a hook registration, not an allowlist pattern). The
constraints ship commented in the HARNESS.md template's `## Constraints`
section; uncomment them to activate. The affordance section is the
declarative half of a capability model that was previously implicit in
scattered config.

## Related

- [Discover affordances](../how-to/discover-affordances.md) — produce a
  draft inventory and promote entries with `add`.
- [Maintain your affordance inventory](../how-to/maintain-affordance-inventory.md)
  — the complete loop: add, review, respond to staleness, retire.
- [Affordance schema](../reference/affordance-schema.md) — field-by-field
  reference.
- [Harness Affordances — Design Spec](../../../superpowers/specs/2026-04-26-harness-affordances-design.md)
