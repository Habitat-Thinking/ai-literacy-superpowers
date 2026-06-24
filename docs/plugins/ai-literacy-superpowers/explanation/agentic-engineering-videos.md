# A curated video library for exploring agentic engineering

A "watch this to understand X" companion to the plugin. Every entry
maps onto a capability or intellectual foundation this repo actually
ships — harness engineering, dynamic workflows, agent orchestration,
spec-first development, literate programming and CUPID, governance and
systems thinking, and OODA-style decision discipline. It is not a
generic AI link dump; it is the framework's lineage in the authors'
own words.

It complements [`ONBOARDING.md`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/blob/main/ONBOARDING.md),
the rest of this docs site, and the
[`harness-engineering`](understand-harness-engineering.md) and
[dynamic-workflows](../how-to/dynamic-workflows.md) material.

## How to read this page

- Entries are **grouped by the repo's own themes**, not listed
  undifferentiated.
- Each entry cites a **concrete repo capability or named framework
  foundation** it illuminates.
- Each carries a **sequence hint** — `start-here`, `intermediate`, or
  `deeper`.
- **Every link was verified live on 2026-06-24** (the access date).
  YouTube entries were confirmed via the YouTube oEmbed metadata
  endpoint, which returns a title and channel only for videos that
  still exist and are public; conference-host pages (InfoQ, PBS) were
  confirmed by fetching the page and observing a live player. Links
  rot — if one is dead when you reach it, search the title and channel
  given here.

> **A note on trust (the repo's own INV-2 quarantine principle).**
> These are external sources. They are cited because they are
> authoritative — primary talks by the people who originated the ideas,
> on official conference and author channels. Treat anything you find
> beyond them with the same caution the framework applies to any
> untrusted content: verify before you rely on it.

## Suggested viewing path

For someone new to the framework, watch in this order — one rung per
sitting is plenty:

1. **Böckeler, _State of Play: AI Coding Assistants_** — the harness
   thesis from the primary source. (Harness engineering)
2. **Barry Zhang, _How We Build Effective Agents_** — the
   workflow-vs-agent distinction everything else builds on. (Dynamic
   workflows)
3. **Addy Osmani, _Orchestrating Coding Agents_** — how single agents
   become an orchestra with quality gates. (Agent orchestration)
4. **Dan North, _Introducing BDD_** — where Given/When/Then, the
   shared language of spec-first work, comes from. (Spec-first)
5. **Dan North, _CUPID — For Joyful Coding (7-minute cut)_** — the
   code-quality lens the `code-reviewer` agent applies. (Literate
   programming & CUPID)
6. **George Fairbanks, _Building Theories is Building Value_** — why
   agentic codegen still needs human theory-holders. (Governance &
   systems thinking)
7. **PBS, _John Boyd and his OODA Loop_** — the decision-cadence model
   behind the carpaccio / cartographer lineage. (OODA / decision
   discipline)

Everything below the start-here rung in each section is optional depth.

---

## Harness engineering

Maps to: the [`harness-engineering`](understand-harness-engineering.md)
skill, `HARNESS.md`, and the three harness components — context,
constraints, and garbage collection. The ephemeral fourth layer is
covered under [Dynamic / multi-agent workflows](#dynamic--multi-agent-workflows).

### State of Play: AI Coding Assistants — `start-here`

- **Speaker:** Birgitta Böckeler (Global Lead, AI-assisted Software
  Delivery, Thoughtworks)
- **Source:** InfoQ — QCon London 2026 ·
  <https://www.infoq.com/presentations/ai-coding-assistants/>
- **Year / duration:** 2026 · ~42 min
- **Why watch:** The clearest statement of the harness thesis from the
  primary source — building systematic setup around the agent
  (architectural constraints plus deterministic tools), alongside
  context engineering and subagents. This is essentially the plugin's
  framing in talk form.

### From Autocomplete to Agents: AI Coding State of Play — `intermediate`

- **Speaker:** Birgitta Böckeler (Thoughtworks)
- **Source:** InfoQ — QCon London 2025 ·
  <https://www.infoq.com/presentations/ai-coding-agents/>
- **Year / duration:** 2025 · ~50 min
- **Why watch:** The earlier-stage companion. Establishes why output
  quality is a setup problem — review loops, code churn, supervised
  autonomy — before the harness vocabulary crystallised.

### AI for Software Development: A Reality Check — `start-here`

- **Speaker:** Birgitta Böckeler (Thoughtworks)
- **Source:** Craft Conference 2024 (CraftHub Events) ·
  <https://www.youtube.com/watch?v=-wNSSDC9_O4>
- **Year:** 2024
- **Why watch:** The earliest rung in the arc — sets the mindset that
  AI output is an environment problem, not model magic. Good historical
  grounding for the framework's central claim.

---

## Dynamic / multi-agent workflows

Maps to: the [dynamic-workflows](../how-to/dynamic-workflows.md) skill,
the self-authored ephemeral harness (the fourth layer), fan-out and
adversarial verification, the INV-1 / INV-2 invariants, and the three
failure modes the skill names (agentic laziness, self-preferential
bias, goal drift).

> **Companion read (named in the issue, not a video):** Anthropic's
> _A harness for every task: dynamic workflows in Claude Code_ —
> <https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code>
> — is the primary written source for this theme (self-authored
> ephemeral harness, fan-out, synthesise step, the "35 of 50 items,
> declared done" laziness example). No verified video version exists as
> of the access date; read the post alongside the talks below.

### How We Build Effective Agents — `start-here`

- **Speaker:** Barry Zhang (Anthropic, Applied AI)
- **Source:** AI Engineer Summit 2025 (AI Engineer) ·
  <https://www.youtube.com/watch?v=D7_ipDqhtwk>
- **Year:** 2025
- **Why watch:** The canonical talk version of Anthropic's _Building
  Effective Agents_ — the workflow-vs-agent distinction, and the
  discipline of not reaching for an agent when a workflow will do. This
  is the election rubric the `dynamic-workflows` skill encodes.

### Building more effective AI agents — `intermediate`

- **Speakers:** Alex Albert and Erik Schluntz (Anthropic)
- **Source:** Anthropic (official channel) ·
  <https://www.youtube.com/watch?v=uhJJgc-0iTQ>
- **Year:** 2025
- **Why watch:** Goes deeper into multi-agent design and the trade-offs
  of orchestrator-worker patterns — directly relevant to fan-out and
  to structuring a self-authored harness.

### Don't Build Agents, Build Skills Instead — `deeper`

- **Speakers:** Barry Zhang and Mahesh Murag (Anthropic)
- **Source:** AI Engineer ·
  <https://www.youtube.com/watch?v=CEvIs9y1uog>
- **Year:** 2025
- **Why watch:** Sharpens the _when not to_ side of the rubric — when a
  full multi-agent harness is overkill and progressive-disclosure
  skills do the job. Pairs with the skill's election discipline.

### Prompting for Agents | Code w/ Claude — `deeper`

- **Speakers:** Hannah Moran and Jeremy Hadfield (Anthropic, Applied AI)
- **Source:** Anthropic (official channel), Code w/ Claude 2025 ·
  <https://www.youtube.com/watch?v=XSZP9GhhuAc>
- **Year:** 2025
- **Why watch:** Workshop-grade detail on agent instruction design —
  interleaved thinking, tool-set hygiene, prompting the agent to plan.
  Practical material for authoring the per-agent contracts a workflow
  fans out to.

---

## Agent orchestration & the agent orchestra

Maps to: the [`orchestrator`](agent-orchestration.md) agent and the
agent team (spec-writer, tdd-agent, code-reviewer, integration-agent),
the quality gates between them, and compound learning. See
[Agent Orchestration](agent-orchestration.md).

### Orchestrating Coding Agents ("The Code Agent Orchestra") — `start-here`

- **Speaker:** Addy Osmani (Google)
- **Source:** O'Reilly AI CodeCon 2026. The free canonical resources
  are the talk transcript + slides at
  <https://talks.addy.ie/oreilly-codecon-march-2026/> and the companion
  article at <https://addyosmani.com/blog/code-agent-orchestra/>.
- **Year:** 2026
- **Why watch:** The canonical map of the field — subagents → agent
  teams → orchestration at scale, with the quality gates that keep
  parallel agents trustworthy. The key source for this theme.
- **Note:** The recorded video sits behind the O'Reilly subscription
  paywall; the transcript, slides, and article above are the openly
  accessible form of the same talk.

### What I Learned Building Multi-Agent Systems from Scratch — `intermediate`

- **Speaker:** Paulo Arruda (Staff Engineer, Shopify; creator of Claude
  Swarm)
- **Source:** InfoQ — QCon AI 2025 (New York) ·
  <https://www.infoq.com/presentations/multi-agent-system-lessons/>
- **Year / duration:** 2025 · ~35 min
- **Why watch:** A production war-story on building specialised agent
  microservices and managing context across them — the engineering
  reality behind "the orchestra."

---

## Spec-first / Specification by Example

Maps to: the project's spec-first discipline (`docs/superpowers/specs/`,
the `Spec-First Check` CI gate), the [`spec-writer`](agent-orchestration.md)
agent, and Given/When/Then as the shared language the `tdd-agent`
turns into failing acceptance tests.

### Introducing BDD (Behaviour-Driven Development) — `start-here`

- **Speaker:** Dan North (originator of BDD)
- **Source:** InfoQ — QCon San Francisco ·
  <https://www.infoq.com/presentations/bdd-dan-north/>
- **Year / duration:** 2008 (recorded) · ~64 min
- **Why watch:** The foundational talk from BDD's creator — where
  Given/When/Then and "thinking in behaviour, not tests" come from.
  Roots the whole spec-first theme.

### Specification by Example (Small Talk) — `start-here`

- **Speaker:** Gojko Adzic
- **Source:** Avanscoperta ·
  <https://www.youtube.com/watch?v=0R9g24KQE0w>
- **Why watch:** Adzic himself on the core method — concrete examples
  as a shared language between business, developers, and testers, then
  reused as an executable test suite.

### 10 Years of Doing Behaviour-Driven Development All Wrong — `deeper`

- **Speaker:** Liz Keogh
- **Source:** NorDevCon ·
  [Part 1](https://www.youtube.com/watch?v=2EM4itu7j7I) ·
  [Part 2](https://www.youtube.com/watch?v=AFCdE5KSREI)
- **Year:** 2014
- **Why watch:** The corrective deep-dive — common BDD anti-patterns
  and how to use scenarios for genuine shared understanding rather than
  test theatre. Watch after North and Adzic.

---

## Literate programming & CUPID

Maps to: the [`literate-programming`](../how-to/write-literate-code.md)
and [`cupid-code-review`](../how-to/review-code-with-cupid.md) skills,
and the `code-reviewer` agent, which reviews through both lenses.

### CUPID — For Joyful Coding (7-minute cut) — `start-here`

- **Speaker:** Daniel Terhorst-North
- **Source:** GOTO Conferences (YOW! 2022) ·
  <https://www.youtube.com/watch?v=sV6UptcmSRA>
- **Year / duration:** 2022 · ~7 min
- **Why watch:** The lightest on-ramp — all five CUPID properties
  (Composable, Unix philosophy, Predictable, Idiomatic, Domain-based)
  as joyful-coding _properties_ rather than SOLID-style _principles_.

### CUPID — For Joyful Coding (full talk) — `intermediate`

- **Speaker:** Daniel Terhorst-North
- **Source:** GOTO Conferences (YOW! 2022) ·
  <https://www.youtube.com/watch?v=cyZDLjLuQ9g>
- **Year / duration:** 2022 · ~48 min
- **Why watch:** The definitive full-length statement of CUPID — the
  property-based lens the plugin's code review is built on.

### CUPID — for joyful coding (NDC London 2022) — `intermediate`

- **Speaker:** Daniel Terhorst-North
- **Source:** NDC Conferences ·
  <https://www.youtube.com/watch?v=KRLOCFDw5x4>
- **Year:** 2022
- **Why watch:** An alternative full delivery that also covers the
  SOLID critique motivating CUPID — useful if you want the
  SOLID-versus-CUPID contrast from a major-conference source.

### Donald Knuth on programming and literate programming — `intermediate`

- **Speaker:** Donald Knuth (interviewed by Lex Fridman, #219)
- **Source:** Lex Fridman ·
  <https://www.youtube.com/watch?v=EE1R8FYUJm0>
- **Year / duration:** 2021 · ~2h28m (the literate-programming segment
  begins around 30:00)
- **Why watch:** Knuth in his own words on literate programming — code
  as a work of literature written for a human to read first and the
  machine second. The origin of the `literate-programming` skill's
  premise.
- **Note:** Knuth's 1974 Turing-award lecture _Computer Programming as
  an Art_, which underpins this, survives as authoritative text rather
  than verified video.

---

## Governance, observability & model sovereignty

Maps to: the governance suite ([`/governance-audit`](../how-to/run-a-governance-audit.md),
[`/governance-constrain`](../how-to/write-a-governance-constraint.md),
[Governance as Meaning Alignment](governance-as-meaning-alignment.md)),
the [`model-sovereignty`](../how-to/set-up-model-routing.md) skill, and
the framework's distributed-cognition and leverage-point lineage.

### Building Theories is Building Value — `start-here`

- **Speaker:** George Fairbanks
- **Source:** GOTO Conferences ·
  <https://www.youtube.com/watch?v=Led34f3Pcq4>
- **Year:** 2016
- **Why watch:** The best practitioner explainer of Naur's
  _Programming as Theory Building_ — the durable asset is the shared
  theory in developers' heads, not the source code. Directly unlocks
  why agentic codegen still needs human theory-holders, the premise
  behind [decision archaeology](decision-archaeology.md).
- **Note:** Primary-source video of Naur presenting the paper does not
  appear to exist; this reputable-conference explainer is the
  recommended substitute.

### Sustainable Systems (Donella Meadows, 1999) — `intermediate`

- **Speaker:** Donella (Dana) Meadows
- **Source:** University of Michigan Sustainability Lecture Series.
  Single-video upload: <https://www.youtube.com/watch?v=hhSpzQhvFS8> ·
  provenance and timestamps at
  <https://donellameadows.org/sustainable-systems-videos/>
- **Year / duration:** 1999 · ~90 min
- **Why watch:** Rare primary-source footage of Meadows presenting the
  systems-thinking and leverage-points framework — where to intervene
  in a system for maximum effect (paradigms and goals beat parameters).
  Core to reasoning about governance leverage.
- **Note on distributed cognition:** No authoritative video of Edwin
  Hutchins on _Cognition in the Wild_ could be verified; the framework's
  distributed-cognition lineage rests on the book (MIT Press, 1995) and
  the 2000 HCI paper, both text.

---

## OODA / decision discipline

Maps to: the decision-discipline triad —
[`carpaccio`](cadence-governance.md) (cadence governor),
[`choice-cartographer`](decision-archaeology.md) (decision archaeology),
and [`advocatus-diaboli`](adversarial-review.md) — and the
observe-orient-decide-act tempo behind it. See
[The Decision-Discipline Triad](decision-discipline-triad.md).

### John Boyd and his OODA Loop — `start-here`

- **Source:** PBS _Chronicles_ (S2 E13) ·
  <https://www.pbs.org/video/john-boyd-and-his-ooda-loop-x7cj3o/>
- **Year / duration:** 2024 · ~28 min
- **Why watch:** Accessible documentary intro to Boyd, the
  fighter-pilot origins of the loop, and why cycling it faster than
  your opponent confers advantage — the tempo idea behind cadence
  governance.

### Understanding the OODA Loop and How It Applies to Tech Leadership — `intermediate`

- **Speaker:** Ben Ford
- **Source:** OODA (official channel) ·
  <https://www.youtube.com/watch?v=HF2owPomUp8>
- **Why watch:** Translates OODA from the battlefield to engineering
  leadership — orientation quality and decision-cycle tempo for tech
  teams. The clearest software-context bridge.

### OODA — The Algorithm of Agility — `intermediate`

- **Speaker:** Ben Ford
- **Source:** Future of Work Scotland Meetup ·
  <https://www.youtube.com/watch?v=69xVWTUKRIw>
- **Year:** 2021
- **Why watch:** Ford's fuller talk framing OODA as the algorithm of
  adaptation — how individuals and organisations are shaped by and
  reshape their environment via faster, better-oriented loops.

### Understanding Boyd's Real OODA Loop (with Chet Richards) — `deeper`

- **Speaker:** Chet Richards (Boyd collaborator)
- **Source:** _No Way Out_ podcast (Ep. 112) ·
  <https://www.youtube.com/watch?v=J7koedhXQQw>
- **Why watch:** The rigorous version — Richards, who drew the only
  OODA diagram Boyd approved, corrects the oversimplified four-box loop
  and explains orientation as its true centre.

---

## What this library deliberately omits

In keeping with the "prefer authoritative sources" criterion, a few
named foundations have **no verified primary-source video** and are
represented by text or an explainer instead:

- **_A harness for every task_** (dynamic workflows) — Anthropic blog
  post, no video. Linked as a companion read above.
- **Knuth, _Computer Programming as an Art_** (1974 Turing lecture) —
  authoritative text only.
- **Hutchins, distributed cognition** — book and HCI paper only; no
  authoritative talk found.
- **Naur, _Programming as Theory Building_** — represented by
  Fairbanks's explainer; no video of Naur himself found.

Re-check these on the next review of this page; primary footage may
surface over time.
