---
title: Context Engineering
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 2
redirect_from:
  - /explanation/context-engineering/
  - /explanation/context-engineering.html
---

# Context Engineering

This page expands on the context engineering component introduced in [Harness Engineering](harness-engineering.md).
{: .fs-5 }

Context engineering is the discipline of taking the tacit knowledge trapped in your team's heads and making it explicit, precise, and machine-readable. It is the difference between an AI that generates plausible code and an AI that generates *your team's* code.

---

## Why context determines output quality

Imagine you have just hired the best developer you have ever interviewed. Perfect scores on the system design round. Encyclopaedic knowledge of your entire tech stack. Writes code that compiles on the first try.

On their first day, you hand them a laptop and say: "The repo's on GitHub. Good luck."

No onboarding. No architecture overview. No "here's why we do it this way." No pairing with someone who knows the codebase.

You know what happens next. They write beautiful code that is completely wrong for your project. They use the patterns they learned at their last job. They name things differently from everyone else. They handle errors in a way that makes your on-call engineer twitch.

They are brilliant. And they are useless. Not because they lack skill, but because they lack *context*.

**This is what you are doing to your AI. Every single session.**

Your team's senior developers carry an enormous amount of knowledge that exists nowhere in writing. They know that the payments service uses a particular error-handling pattern because of an incident two years ago. They know that function names follow a specific convention because the Python and Go codebases share types across a boundary. They know which abstractions are load-bearing and which are accidental.

When a new human joins, they absorb this through osmosis -- code reviews, pairing sessions, overheard arguments in standups. It takes months, and it is deeply inefficient, but it works.

Your AI gets none of it. Every session starts from absolute zero. No memory of yesterday's review comments. No awareness of the architectural decision records. It is not a new joiner who is slowly getting up to speed. It is a new joiner whose memory gets wiped every morning.

{: .note }
> **Try this:** Pick one convention from your current project -- something "everyone knows" but that is not written down anywhere. Now try to write it down in a single sentence, precisely enough that someone who has never seen your codebase could follow it. Harder than you expected, isn't it?

---

## The five layers of context

When people hear "context," they think "give the AI more information." That is too vague to be useful. Context has specific layers, and they are not equally important.

### Stack declaration

Languages, frameworks, build system, test runner. Pure facts, no judgement -- and yet most teams never make it explicit. They assume the AI will figure it out from the code. Sometimes it does. Sometimes it generates Jest tests for a project that uses Vitest, and you spend fifteen minutes wondering why the test suite exploded.

### Conventions

This is where things get interesting. Naming patterns, file structure, error handling, import ordering. These are the things that make your codebase feel like *yours*. Richard Gabriel called this quality "habitability" -- the property that makes a codebase feel like a place you can live and work in, rather than a museum you are afraid to touch.

### Architectural decisions

The load-bearing layer -- and the one most teams skip. Not just "we use event sourcing" but "we use event sourcing because we need a complete audit trail for regulatory compliance and we tried CRUD with audit tables first and it didn't scale past 10,000 events per second." The *why* matters because it tells the AI what it cannot change, even if it sees a "better" pattern. Skip this layer and the AI will cheerfully refactor away your most important constraints.

### Rationale

What turns arbitrary-looking rules into defensible ones. Not just "use snake_case" but "we use snake_case because our Python and Go codebases share type definitions across a code generation boundary, and snake_case is the only casing that round-trips cleanly through our protobuf pipeline." Without rationale, the AI treats conventions as suggestions. With rationale, it treats them as constraints.

### Threat model

What data is sensitive? Where are the trust boundaries? Your senior developers instinctively validate user input at the API boundary and never log authentication tokens -- not because someone told them to last week, but because they remember the incident that taught the team. Your AI does not remember that incident. You need to encode the lesson.

Of these five layers, most teams start with stack declaration because it is easy. That is fine as a starting point. But the leverage is in conventions and architectural decisions. Stack declarations prevent trivial mistakes. Conventions and decisions prevent the expensive ones -- the kind where the code compiles, the tests pass, and the production incident happens three weeks later.

### FAQ

**Isn't this just documentation?**

No. Documentation is written for humans who will read it once and mostly remember it. Context documents are written for a reader that starts fresh every session, has no background knowledge, and will interpret ambiguity however it pleases. That changes what you write and how you write it.

**Can't the AI just read our code and figure out the conventions?**

It can infer some patterns. But it cannot distinguish between a deliberate convention and an accident that nobody has gotten around to fixing. It cannot tell whether a pattern appears everywhere because the team chose it or because it was copy-pasted from a Stack Overflow answer three years ago. Explicit context removes the guessing.

---

## The precision problem

Vague conventions produce vague output. This is not a minor annoyance. It is the single biggest reason AI-generated code requires extensive rework.

Look at these two convention statements:

| Vague convention | Precise convention |
| --- | --- |
| "Write clean code" | Not enforceable -- decompose further |
| "Keep functions short" | "Functions must not exceed 40 lines excluding blank lines and comments" |
| "Use meaningful names" | "Variable names must be at least 3 characters except for loop indices (`i`, `j`, `k`) and error values (`err`)" |
| "Handle errors properly" | "Every returned error must be wrapped with `fmt.Errorf` adding context. Bare `return err` is not permitted" |
| "Use dependency injection" | "No function constructs its own dependencies. All external dependencies are received as parameters or struct fields" |

**The test for any convention: could two independent reviewers, looking at the same code, agree on whether it follows the convention -- without discussing it?**

"Write clean code" fails this test catastrophically. "Functions must not exceed 40 lines" passes it trivially. The distance between those two statements is the distance between useful context and noise.

> **The Sceptic:** "This feels like a lot of overhead. Can't we just tell the AI to follow best practices?"
>
> **The Veteran:** "We tried that. The AI's 'best practices' included patterns we explicitly abandoned two years ago after they caused a production outage. Best practices are not your practices."
>
> **The Pragmatist:** "OK, but I'm not writing a hundred rules on day one. Where do I start?"
>
> **The Veteran:** "Start with the things you correct most often. Every time you change something the AI generated, ask yourself: could I have prevented this with a one-sentence rule? Write that sentence down. You'll have ten conventions within a week without any special effort."

---

## The extraction problem

Walk up to a senior developer on your team and ask: "What are our coding conventions?"

They will give you five or six things off the top of their head. Naming. Test structure. Maybe error handling.

Now watch them do a code review. They will flag twenty things that violate conventions they did not mention -- because they did not know they knew them. This is **tacit knowledge**: expertise so deeply absorbed that it feels like instinct rather than a rule.

You cannot extract tacit knowledge by asking "what are the rules?" You extract it by triggering the knowledge indirectly:

- "What would you correct in a new teammate's first PR?"
- "What triggers an immediate rejection in code review?"
- "What's the thing that's obvious to everyone but nowhere in writing?"
- "Which conventions does the AI violate most often?"

That last question is particularly revealing. It turns every AI interaction into a convention-discovery tool. Every correction you make is a convention you have not encoded yet.

Ask three senior developers "what separates a clean refactoring from an over-engineered one?" and you will get three different answers. Those disagreements are conventions that have not been resolved yet. Surfacing them is one of the most valuable side effects of context engineering: it forces your team to confront things they assumed they already agreed about.

{: .note }
> **Try this:** Think of a project you work on. What triggers an immediate rejection in review? Write down your answer. Now imagine asking two other people on your team the same question. Would they give the same answer? If you are not sure, that is a convention that needs extracting and encoding.

---

## Living documents, not dead wikis

Context rots.

Your conventions reference functions that get renamed. Your stack declaration lists framework versions that get upgraded. Your architectural decisions describe constraints that get relaxed. If your context documents do not evolve with the code, they become actively harmful -- the AI follows outdated rules that produce code that *used to be* correct.

{: .warning }
> Context documents must be versioned alongside the code they describe. They live in the repository, not in a wiki. They get reviewed in pull requests. When someone changes a convention, the context document changes in the same commit. The moment your context files live in a wiki, they are dead. They will be accurate for about two sprints. After that, they will be worse than having no context at all, because the AI will follow them confidently in the wrong direction.

This is what separates context engineering from documentation. Documentation lives adjacent to the workflow. Context lives *inside* the workflow. It is checked in, reviewed, and maintained with the same rigour as the code itself.

> **The Pragmatist:** "What do I actually do on Monday?"
>
> Create a single file in the root of your repository. Give it three sections: stack (what you use), conventions (how you use it), and decisions (why you use it that way). Start with five conventions -- the five things you correct most often. Commit it. Review it as a team.
>
> That is it. That is the whole first step.

---

## The compound effect

A single well-written convention saves you maybe two minutes per AI session. You correct the output, sigh, and move on.

But you are running ten AI sessions a day. That is twenty minutes. Across a five-person team, that is over an hour and a half of daily rework -- and that is just one missing convention. Most teams have dozens.

The maths matters less than the dynamic it creates. Each convention you encode is a correction you never make again. Each architectural decision you document is a structural mistake the AI never attempts.

As the AI produces code that increasingly matches your team's style, *trust increases*. And trust changes behaviour. A developer who trusts the AI's output stops re-reading every generated function line by line. They delegate larger tasks. They use AI for work they previously would not have attempted -- the boring migration, the tedious test scaffolding, the refactoring they never had time for. The team's capacity expands not because the AI got smarter, but because the environment got richer.

Bad context is a tax you pay forever. Same corrections, every session, no compounding.

---

## Key takeaways

- **Context is layered:** stack, conventions, architectural decisions, rationale, and threat model. The leverage is in the middle layers, not the easy ones.
- **Precision is everything:** A convention that two reviewers cannot independently agree on is not a convention. It is a wish.
- **Tacit knowledge is the bottleneck:** Your team knows far more than they can articulate. Structured extraction questions surface what direct questions miss.
- **Context documents are living artefacts:** Versioned with the code, reviewed in PRs. The moment they live in a wiki, they start dying.
- **Compounding works in both directions:** Encoded conventions build trust that expands capability. Missing conventions create rework that erodes it.

---

## Further reading

- [Harness Engineering](harness-engineering.md) -- how context fits into the harness
- [Constraints and Enforcement](constraints-and-enforcement.md) -- enforcing what context declares
- [The Environment Hypothesis](the-environment-hypothesis.md) -- why environment determines output quality
