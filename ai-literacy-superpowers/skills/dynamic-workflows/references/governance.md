# Governance for Dynamic Workflows

Dynamic workflows are a new execution substrate, but they do not get new
authority. Two invariants bind every workflow this plugin authors. They
are non-negotiable: every template, and every agent operating in workflow
mode, must preserve them. Both are restated here in full so an agent
reasoning about a workflow can cite them directly.

## INV-1 — Ephemeral proposes, durable curates

> Dynamic workflows are **ephemeral and generated**. The project's
> durable artefacts are **curated**. A workflow may **propose** changes to
> a durable artefact but may **never write one directly**.

The four durable, human-curated artefacts a workflow must never write are:

- **`HARNESS.md`** — the declared constraints, verification slots, and GC
  rules.
- **`AGENTS.md`** — the curated, compounding rules the team has chosen to
  keep.
- **`CLAUDE.md`** — the project conventions and instructions.
- **`MODEL_ROUTING.md`** — the model-tier and token-budget routing policy.

Anything a workflow discovers that is worth keeping flows through the
existing human-curation gate:

```text
REFLECTION_LOG.md  →  human curates  →  AGENTS.md
```

A workflow appends to `REFLECTION_LOG.md` (or to a dedicated staging
artefact) and surfaces a vetted shortlist; a **human** decides what is
promoted into the durable rule set. This is "agents propose; humans
curate" applied at the harness layer rather than the rule layer. It is the
load-bearing principle of the whole dynamic-workflows alignment: it
protects the team's curated theory of the system (Naur) from ephemeral
churn.

**Why it is load-bearing.** If an ephemeral, per-task program could
rewrite the durable artefacts, the curated theory of the system would
erode one disposable workflow at a time, with no human in the loop. The
firewall keeps the durable layer authoritative.

> The deterministic *teeth* for INV-1 — a CI rule that greps workflow
> templates for direct writes to these four paths and fails the build if
> it finds one — is mechanised in a later slice (S2). This file states the
> invariant as knowledge; the CI rule enforces it.

## INV-2 — Quarantine

> Any workflow agent that reads **untrusted or public content** — web
> pages, external issues, third-party PRs, arbitrary fetched text — must
> **not** be granted high-privilege actions.

A subagent that ingests untrusted input is a potential carrier for
injected instructions. Quarantine confines the blast radius: the agent
that *reads* untrusted content is withheld high-privilege tools (no
writes, no shell, no merge, no network mutation), and any action implied
by that content is performed only by a **separate, trusted agent** in the
same workflow that did not ingest the untrusted text. Reading and acting
are split across the trust boundary so a prompt-injection in fetched
content cannot reach into a privileged capability.

> As with INV-1, the lint that enforces INV-2 on templates (verifying an
> untrusted-content reader declares no high-privilege tools) lands with the
> template library in S2. This file states the invariant for agents to
> cite and design against now.

## How the invariants compose

A well-formed workflow that touches untrusted input *and* discovers
something worth keeping does both: the untrusted reader stays low-privilege
(INV-2), and whatever the workflow concludes is written only as a proposal
to `REFLECTION_LOG.md` or a staging file for a human to curate (INV-1) —
never straight into `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, or
`MODEL_ROUTING.md`.
