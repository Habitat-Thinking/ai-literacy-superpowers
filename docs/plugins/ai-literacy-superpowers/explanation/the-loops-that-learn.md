---
title: The Loops That Learn
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 7
redirect_from:
  - /explanation/the-loops-that-learn/
  - /explanation/the-loops-that-learn.html
---

# The Loops That Learn

Four practices, four timescales, one compounding system.

This page explains why AI development environments fail when teams stop
operating them — and how four recurring loops (reflection, health,
assessment, cost) interlock to produce compound improvement.

---

## The core claim

**The infrastructure is not the product. The loops are the product.**

Teams that run the loops with mediocre infrastructure outperform teams
with brilliant infrastructure that never operate it.

---

## The Four Loops

| Loop | Command | Cadence | What it captures | What it feeds |
| --- | --- | --- | --- | --- |
| Reflection | `/reflect` | Every session | Surprises, signals, constraints | AGENTS.md, HARNESS.md |
| Health | `/harness-health` | Monthly | Enforcement ratio, GC status, learning velocity | Snapshots, trends, badges |
| Assessment | `/assess` | Quarterly | Level, discipline scores, gaps, executable actions | Assessment docs, improvement plans |
| Cost | `/cost-capture` | Quarterly | Spend, tokens, model mix, budget status | MODEL_ROUTING.md, cost trends |

### Reflection — every session

Two minutes at the end of a coding session. What was surprising? What
should future sessions know? Reflections are classified by signal type
and, if they describe a failure, can be promoted to a constraint
proposal immediately.

**What happens if you skip it:** every session starts from scratch. The
AI forgets what you taught it yesterday. Without reflections, you are
the only memory in the system.

### Health — monthly

`/harness-health` reads your HARNESS.md, reflection log, agents, cost
data, and previous snapshots. It computes enforcement ratio, learning
velocity, and five meta-observability checks. Then it compares to last
month.

**What happens if you skip it:** drift goes unnoticed. Constraints
that broke during a CI upgrade stay broken. Your harness runs at 80%
and you think it's at 100%.

### Assessment — quarterly

`/assess` scans the repo for evidence, scores across three disciplines,
and acts — fixing stale counts, proposing workflow changes, and mapping
every gap to the specific command that closes it.

**What happens if you skip it:** you lose your position. You think
you're Level 3 because you were Level 3 last quarter. Without
assessment, you'll never know.

### Cost — quarterly

`/cost-capture` walks through provider dashboards, records spend, token
volumes, and model mix. Compares to previous quarter. Proposes routing
changes via MODEL_ROUTING.md.

**What happens if you skip it:** you either overspend without knowing
or under-invest because nobody has evidence the spend is worth it.

---

## How they interlock

The four loops are not independent practices. The output of each becomes
the input of another.

- **Reflections surface gaps. Assessment confirms them.** Three
  reflections noting the AI ignores error handling → quarterly
  assessment identifies the gap formally → improvement plan promotes
  the convention to an agent-backed constraint.

- **Health snapshots track whether improvements stuck.** Assessment
  recommends promoting constraints → health snapshots show enforcement
  ratio rising → the next assessment sees stable evidence and scores
  higher.

- **Cost data informs model routing. Routing affects quality. Quality
  affects reflections.** Cost snapshot reveals frontier model spending
  on boilerplate → route to standard model → reflections capture
  whether quality held → next cost snapshot proves the savings.

---

## Literacy level connection

Each literacy level requires different loops to sustain it:

- **Level 2 (Verification):** CI either runs or it doesn't.
  Self-sustaining through automation.
- **Level 3 (Habitat Engineering):** Requires `/reflect` and
  `/harness-health` as ongoing practices. Without them, the habitat
  decays.
- **Level 4 (Specification Architecture):** `/assess` becomes
  critical — are specs driving implementation or written after the fact?
- **Level 5 (Sovereign Engineering):** All four loops plus portfolio
  view. Governance requires data.

---

## The portfolio view

`/portfolio-assess` aggregates across repos. Three things become visible
at portfolio scale:

- **Shared gaps** — when five of eight repos have no reflection
  practice, that's one organisational problem, not eight repo problems.
- **Outliers** — one repo at Level 4 while the rest sit at Level 2.
  What are they doing differently?
- **Stale assessments** — a repo assessed six months ago is a repo
  where you're guessing.

The **portfolio dashboard** turns this into a self-contained HTML file
that makes the loops visible to leadership.

---

## Further reading

The full article is available at
[articles/08-the-loops-that-learn.md](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/articles/08-the-loops-that-learn.md)
in the repository.
