---
title: Compound Learning
---
# Compound Learning

This page explains how AI development environments improve over time through captured learnings. For the detailed mechanics of self-improvement, see [The Self-Improving Harness](self-improving-harness.md).
{: .note }

---

## The Groundhog Day Problem

You fixed this already.

Last Thursday. The AI generated a service class that swallowed exceptions silently — caught them, logged nothing, returned null. You caught it in review. You explained the pattern. You showed it your team's error handling convention. It produced correct code for the rest of the session.

Monday morning. New session. The AI generates a service class that swallows exceptions silently.

Not irritation. Something worse: resignation.

You have been here before. Not just with error handling. With naming conventions. With test structure. With that one architectural boundary the AI keeps crossing. Every session, you teach the same lessons. Every session, the AI has forgotten them. You are Bill Murray in *Groundhog Day*, except the alarm clock is a code review full of the same mistakes you corrected yesterday.

This is the Groundhog Day problem. Without a learning mechanism, every AI session starts from scratch. The context files, constraints, and garbage collection rules described elsewhere in this documentation are powerful — but they are static. They contain what you knew when you wrote them. The system is exactly as smart as you were on the day you configured it.

That is the ceiling. Unless you build the mechanism that raises it.

---

## The Raw Material: Reflections

Think about what happens during an AI coding session. Not the code it produces — the corrections you make. Every time you say "no, not like that, like this," you generate a signal. Every AI surprise — good or bad — is data. Every edge case you discover is knowledge that did not exist before the session started.

Without a learning loop, all of that evaporates. Session ends. Corrections disappear. Edge cases live only in your memory.

**Reflections** change this. A reflection is a brief note captured after a piece of work — three sentences, not an essay:

- **What was surprising?** Edge cases you did not anticipate. Assumptions that broke.
- **What should future sessions know?** A gotcha, a "don't do it this way because..." warning.
- **What could improve?** A missing convention, a constraint that is too loose, a gap in context.

Two minutes at the end of a session. Maybe less.

{: .note }
> **Try this:** Think about your last AI coding session. What did you correct? What would you tell a colleague who was about to start the same task? Write that down in two sentences. You have just written your first reflection.

These reflections are not documentation. They are raw material — ore, not steel. The valuable step comes next.

---

## The Curation Step

Raw reflections are noisy. Sometimes the AI got confused because you wrote a bad prompt, not because there is a missing convention. Sometimes the edge case was genuinely rare. Sometimes you were just having a bad day.

So you do not promote everything. You **curate**.

Weekly — fortnightly if you are busy — scan your reflections and ask one question: *does this keep happening?*

A gotcha that showed up once is an anecdote. A gotcha that showed up three times is a **convention waiting to be written**. A violation the AI keeps repeating despite clear instructions is a **constraint that needs promotion** — from declared to agent-backed, or from agent-backed to deterministic.

This is where human judgement meets AI volume. The AI generates code at a pace you cannot match. You generate *insight* at a pace it cannot match. The learning loop combines both.

{: .warning }
> Skipping curation is the most common failure mode. Without it, reflections accumulate as noise and the learning loop stalls. The human review step is not optional — it is the mechanism that separates signal from noise.

---

## A Fireside Chat About Promotion

> **Reflection:** I have been sitting in this log file for two weeks. The developer noticed that the AI keeps putting database queries directly in the route handlers instead of using the repository pattern. She wrote me down: "AI ignores repository layer, puts queries in handlers. Third time this sprint."
>
> **Convention:** I remember when I was like you. Just a frustrated note in a log. Then one day, the developer read through her reflections and noticed that three of them were basically saying the same thing. She promoted me. Wrote me up properly: "All database access MUST go through the repository layer. Route handlers call repository methods, never query builders or ORMs directly." Gave me examples. Put me in the context file where the AI reads me at the start of every session.
>
> **Reflection:** And the AI stopped doing it?
>
> **Convention:** Not overnight. But within a couple of sessions, the violations dropped from every PR to maybe one a week. Then she promoted me again — turned me into an agent-backed constraint. Now an AI reviewer checks every PR for direct database access in handlers. Last month? Zero violations.
>
> **Reflection:** So I could become... you?
>
> **Convention:** If you earn it. If the pattern you have spotted is real, is recurring, and is worth codifying. Not every reflection deserves promotion. Some of you are noise. That is OK. That is what curation is for.

---

## How Compound Learning Works

Each promoted reflection makes the environment better. A new convention means the AI gets something right that it used to get wrong. A tighter constraint catches a class of violation before it reaches a PR. An improved garbage collection rule cleans up entropy that used to accumulate silently.

Better environment, better output, fewer corrections. But the part most people miss: the *nature* of your reflections changes. You stop writing "the AI got the basics wrong again" and start writing "discovered a subtle interaction between the caching layer and the event system that neither of us had considered."

**The quality of the learnings improves as the baseline improves.**

The flywheel is hard to push at first. You are writing reflections, curating, promoting conventions — it feels like overhead for modest gains. Then the gains compound. You spend less time on basic corrections and more time on genuine discoveries.

This is the same mechanism that makes experienced teams fast: accumulated decisions, conventions, institutional knowledge. The learning loop makes it explicit and transferable instead of locked in people's heads.

> **The Veteran:** "We did this. After three months, new hires were productive in two weeks instead of two months. Not because we wrote better docs — because the docs were written by the problems we actually hit, not the problems we imagined we might hit."

---

## The Self-Improving Harness

The harness described in [Harness Engineering](harness-engineering.md) was presented as something you build. It is not. It is something that grows.

- **Reflections suggest new conventions** — context improves
- **Repeated violations suggest new constraints** — enforcement improves
- **Recurring drift suggests new GC rules** — entropy-fighting improves

The harness improves the harness. The gap between "what the AI knows" and "what the team knows" shrinks session by session.

---

## Three Loops, One System

The entire framework operates as one system with three concentric loops running at three timescales.

**The inner loop — edit time.** The AI reads conventions at session start. It follows the guidelines. Not perfectly, but far better than without them. When it drifts, you correct it in real time.

**The middle loop — merge time.** Agent reviewers enforce constraints. Specialised agents verify architecture, security, testing. Human gates make the final call. Nothing merges that has not passed the gauntlet.

**The outer loop — periodic.** Garbage collection sweeps for entropy. Audits check for drift. Reflections get curated and promoted. The outer loop is where the one-off correction becomes the permanent convention. Where the recurring violation becomes the automated constraint.

The loops feed each other. Inner loop corrections become reflections that feed the outer loop. Outer loop constraints improve middle loop enforcement. Middle loop catches become tomorrow's inner loop context.

For a detailed breakdown of the three loops, see [The Three Enforcement Loops](three-enforcement-loops.md).

---

## Relationship to the Feedback Flywheel

Birgitta Boeckeler's [Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html) describes the same compound improvement mechanism using different vocabulary. The article is part of her [series on reducing friction with AI](https://martinfowler.com/articles/reduce-friction-ai/) on martinfowler.com — the same body of work that introduced harness engineering.

The mapping between the article's terms and this plugin's implementation:

| Feedback Flywheel term | Plugin equivalent |
| --- | --- |
| Feedback flywheel | The three-loop system (inner / middle / outer) |
| Priming document | HARNESS.md Context section + CLAUDE.md |
| Shared commands | Skills and slash commands |
| Team playbooks | AGENTS.md (STYLE, GOTCHAS, ARCH_DECISIONS) |
| Guardrails | Constraints + enforcement loops |
| Learning log | REFLECTION_LOG.md |
| Four signals (context, instruction, workflow, failure) | The `Signal` field on reflections |
| Four cadences (session, daily, retro, quarterly) | Stop hooks (session), snapshots (monthly), audit/assess (quarterly) |

The article's core insight — that every AI interaction generates exploitable signal, and that teams plateau when they lack mechanisms to convert individual learning into collective practice — is exactly what the three-loop system implements. The signal classification on reflections (the `Signal` field) adopts the article's four-signal taxonomy directly, giving each reflection an explicit routing destination during curation.

Where the article describes four cadences, this plugin automates the session-level cadence through Stop hooks and provides commands for the periodic cadences. The daily and sprint-level cadences are team process rather than plugin infrastructure — they require a conversation at standup, not a tool invocation.

---

### FAQ

**Isn't this just writing documentation?**

No. Documentation describes what the system does. Reflections capture what went wrong and what the AI needs to know next time. The distinction matters: documentation is written from understanding, reflections are written from surprise. They have different triggers, different audiences, and different update rhythms.

**How much time does this actually take?**

Two minutes per reflection. Fifteen minutes per curation session (weekly or fortnightly). The time investment drops as the baseline improves because you make fewer corrections worth recording.

**What if I promote the wrong thing?**

Conventions are not permanent. If a promoted convention turns out to be wrong or too restrictive, you revise or remove it. The learning loop is self-correcting over time — bad conventions generate their own reflections.

**Does this scale across a team?**

Yes. When reflections are captured in a shared location and conventions live in version-controlled files, every team member benefits from every other member's discoveries. A new developer joining the team inherits the accumulated learning from hundreds of sessions.

---

## Key Takeaways

- **The Groundhog Day problem:** without a learning mechanism, every AI session starts from scratch
- **Reflections:** brief post-session notes — what surprised you, what future sessions need, what could improve
- **Curation:** the human step — promoting recurring patterns into conventions, constraints, or GC rules
- **Compound learning:** each improvement raises the baseline, which raises the quality of future learnings
- **The harness is alive:** it evolves through the learning loop — the harness improves the harness
- **Three loops** (edit time, merge time, periodic) feed learnings into each other

---

{: .note }
> **Try this:** What is the one thing your AI keeps getting wrong? The correction you have made so many times you could type it in your sleep? Write it down. Be specific — not "better error handling" but "catch exceptions in service methods, wrap them in AppError with a code and message, and let the controller handle the HTTP response." Now put it where your AI can read it. A `CONVENTIONS.md` file. A `CLAUDE.md` file. A system prompt. Whatever your tool uses. That is your first reflection promoted to a convention. Your first learning loop, running.

One convention. One fewer correction tomorrow. Then another. The flywheel does not ask permission to start turning.

---

## Further reading

- [The Self-Improving Harness](self-improving-harness.md) — detailed mechanics of harness self-improvement
- [Harness Engineering](harness-engineering.md) — the full harness framework including context, constraints, and garbage collection
- [The Three Enforcement Loops](three-enforcement-loops.md) — the edit-time, merge-time, and periodic loops in detail
- [Progressive Hardening](progressive-hardening.md) — how constraints mature from declared to deterministic
- [Garbage Collection](garbage-collection.md) — fighting entropy with periodic checks
- [The Feedback Flywheel](https://martinfowler.com/articles/reduce-friction-ai/feedback-flywheel.html) — Birgitta Boeckeler's framework for converting session-level learning into shared infrastructure, part of her series on [reducing friction with AI](https://martinfowler.com/articles/reduce-friction-ai/)
