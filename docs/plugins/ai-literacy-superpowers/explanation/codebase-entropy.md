---
title: Codebase Entropy
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 4
redirect_from:
  - /explanation/codebase-entropy/
  - /explanation/codebase-entropy.html
---

# Codebase Entropy

This page explains why codebases degrade and how AI accelerates the problem. For the mechanical details of fighting entropy, see [Garbage Collection](garbage-collection.md).
{: .note }

---

## The problem at a glance

Look at this snippet and count how many things have gone wrong:

```python
# api/handlers/users.py

import requests  # v2.28.0 - pinned for compatibility
from legacy_auth import validate_token  # TODO: migrate to new auth before Q3 release

def get_user(user_id):
    """Fetches user by ID from the UserService.

    Returns:
        UserResponse with fields: name, email, role, department
    """
    # Using old connection pool - switch to new one after perf testing
    conn = get_legacy_pool().connect()
    user = conn.execute("SELECT name, email FROM users WHERE id = ?", user_id)
    return {"name": user.name, "email": user.email}
```

There are at least five problems embedded in this code. The TODO references a Q3 that has almost certainly passed. The docstring promises four fields but the function returns two. The `requests` import is unused. The version pin comment is drifting from whatever version is actually installed. And the "temporary" legacy connection pool has become permanent.

None of this is dramatic. Nobody pushed bad code on purpose. Nobody made a mistake, exactly. The code aged. That is entropy, and in AI-assisted codebases it is about to become your biggest problem.

---

## The second law of codebases

In thermodynamics, the second law says that closed systems tend toward disorder. Energy disperses. Structure degrades.

Your codebase follows the same pattern. Not literally -- the metaphor is borrowed, not the physics -- but the dynamic is real: without continuous energy input, systems drift from their intended state. Documentation stops matching reality. Dead code accumulates like sediment. Dependencies go stale. Security scanners get disabled "just for this sprint" and never come back.

This is not a failure of discipline. It is a force. You can fight it, but you cannot ignore it. And if you think you are ignoring it successfully, you are not measuring.

{: .note }
> **Try this:** How many TODOs are in your current project right now? Not a rough guess -- actually run a search. Now: how many of those TODOs are older than six months? How many reference a deadline that has already passed? The gap between what you guessed and what you found is the entropy you cannot see.

---

## AI accelerates entropy

Context engineering and constraints genuinely improve the quality of AI-generated code. But there is a side effect: **AI accelerates entropy.**

The core problem is volume. An AI coding assistant produces code faster than any human, which means more code to maintain, more docstrings that can drift, more dependencies pulled in on a whim. Every line of code is a liability. AI produces liabilities at unprecedented speed.

But volume is not the worst part. The worst part is **staleness propagation.**

Monday's AI session uses one approach. Thursday's session -- with slightly different context loaded -- uses a different one. Both work. Neither is wrong. Now you have two patterns where you used to have one. If the AI learned from stale context -- outdated docs, deprecated patterns still in the codebase -- it does not just *use* the stale material. It *creates more of it.* Entropy does not just persist. It reproduces.

Your AI is not just failing to clean up old messes. It is using old messes as templates for new ones.

> **The Sceptic:** "You spent three articles telling me to use AI more effectively, and now you're saying it makes my codebase worse?"
>
> **The Pragmatist:** "I'm saying it makes your codebase *bigger*, faster. Bigger is worse only if you don't maintain it. A car that goes faster isn't more dangerous -- but it does need better brakes."
>
> **The Sceptic:** "So what are the brakes?"
>
> **The Pragmatist:** "Garbage collection."

---

## Garbage collection for codebases

If you have spent time in languages with managed memory, you know garbage collection: the runtime periodically scans for objects that are no longer referenced and reclaims the memory. Without it, your program leaks memory until it crashes. With it, you barely think about memory at all.

Your codebase needs the same thing. Not for memory -- for *coherence.*

Codebase garbage collection is the practice of systematically finding and fixing things that have drifted from their intended state. Not spring cleaning. Not a quarterly "tech debt" sprint that everyone agrees to and nobody protects. A structured, recurring defence against disorder.

Your environment has a half-life. Context engineering and constraints are not "set and forget." They are living artefacts that decay. Every convention you document, every constraint you enforce, begins rotting the moment you ship it.

---

## The five types of codebase entropy

Not all rot is the same. Different things decay at different rates. Understanding the taxonomy helps you fight each type on its own terms.

### 1. Documentation staleness

The docs say one thing. The code does another. This is the most common form of entropy and the most dangerous, because stale docs are worse than no docs. No docs force you to read the code. Stale docs give you confidence in a lie.

Documentation goes stale because updating docs is a separate action from updating code, and separate actions get separated.

### 2. Convention drift

Your team agreed on a pattern six months ago. Since then, forty pull requests have landed. Thirty-eight follow the convention. Two don't. Nobody caught them in review because the PR was big and the violation was subtle.

Now you have two files that do it differently. The next AI session that loads those files as context sees both patterns as valid. It follows either one. Convention drift is contagious -- and AI is the vector.

### 3. Dead code

Functions nobody calls. Feature flags that were never cleaned up. Dependencies listed in your package manifest that nothing uses.

Dead code is not inert. It confuses anyone reading the codebase -- human or AI. It expands the search space for every tool. It creates false positives in security scans. And it sends a signal: *we don't clean up after ourselves here.*

### 4. Dependency rot

Every external dependency is a bet on someone else's maintenance habits. Libraries get abandoned. CVEs get published. APIs change. Your code, which worked fine when you wrote it, is now running on a foundation that is quietly crumbling.

### 5. Constraint decay

This is the meta-entropy -- the entropy of your entropy defences.

You set up a linting rule. Someone disables it for one file with a comment that says "temporary." You add a CI check. It starts flaking, so someone adds `continue-on-error: true`. You write a pre-commit hook. Someone documents how to bypass it in the team wiki "for emergencies."

A disabled check does not announce itself. It just stops catching things. And you will not notice until the thing it was catching gets through.

{: .note }
> **Try this:** Think about the last three bugs your team encountered. For each one, ask: which type of entropy caused it? Was it stale docs that led someone astray? A convention that was not followed? Dead code that obscured the real logic? A dependency that aged badly? A constraint that was not enforced? Most teams have never asked this question. The answer tells you where your entropy rate is highest.

---

## The GC pattern

The defence against entropy follows a pattern borrowed directly from garbage collectors: **detect, schedule, remediate, own.**

For each type of entropy, you need four things:

**A detection rule** -- how do you find it? A script that checks docstrings against function signatures. A tool that identifies unused exports. A dependency scanner that flags known vulnerabilities. You cannot fix what you cannot see.

**A cadence** -- how often do you look? This is where most teams go wrong. Different types of entropy operate at different speeds, and your inspection frequency must match. See cadence matching below.

**A remediation** -- what do you do when you find it? Not "file a ticket." That is how things end up in a backlog that nobody reads. Update the doc. Remove the dead code. Bump the dependency. Re-enable the constraint.

**An owner** -- who is responsible? "The team" is not an owner. "Everyone" is not an owner. Entropy thrives in shared responsibility because shared responsibility is a polite way of saying no responsibility.

---

## Cadence matching

Your first instinct might be to check everything all the time. Resist that instinct.

Continuous checking sounds rigorous. In practice, it is noise. When everything is checked on every commit, alerts become wallpaper. The build is always yellow. "Oh, that warning? Yeah, that's been there for months. It's fine."

Different types of entropy operate at different speeds. Match your garbage collection cadence to the entropy rate:

- **Every PR** -- convention checks, linting, type checking. Fast entropy, fast detection.
- **Weekly** -- documentation coherence scans. Do the docs still match the code?
- **Monthly** -- dependency audits. Are you current? Are you vulnerable? Are you using things you don't need?
- **Quarterly** -- constraint audits. Are your enforcement rules still active? Has anyone disabled something "temporarily"?

The principle: different things decay at different speeds, so inspect them at different frequencies. Your rates will differ from another team's. Adjust accordingly.

### FAQ

**Is entropy really inevitable? Can't I just be more careful?**

Careful people working in large codebases over long time horizons will still produce entropy. It is not about individual discipline. It is about the statistical certainty that, over enough changes, some fraction will introduce drift. The question is not whether entropy happens. It is whether you have a system for catching it.

**This sounds like tech debt. Is it different?**

Tech debt is a decision -- you *choose* to take a shortcut. Entropy is not a decision. Nobody decides "I'm going to let this docstring go stale." It happens as a side effect of other work. Tech debt is a loan. Entropy is erosion. You manage them differently.

**Should I fix all entropy the moment I find it?**

No. A slightly outdated comment is not an emergency. A dependency with a critical CVE is. Detect, assess severity, remediate at the appropriate cadence. Not everything is urgent. But nothing should be invisible.

---

## The optimistic flip

AI is an entropy accelerator. It is also the best garbage collector you have ever had.

Think about what garbage collection requires: scan a large codebase, compare docs against code, cross-reference constraints against actual usage, find functions nothing calls, identify conflicting patterns. These are tedious, exhaustive tasks that humans do badly and AI does well.

A human doing a documentation coherence audit takes days. An AI scans every docstring against every function signature in seconds. The same tool that accelerates entropy can fight it -- but only if you point it at the problem. An AI that only generates new code is an entropy engine. An AI that also audits, scans, and maintains is a garbage collector.

The difference is not the tool. It is the job you give it.

> **The Veteran:** "We started running weekly doc-coherence scans three months ago. The first run was horrifying -- forty percent of our docstrings were meaningfully wrong. Not just outdated. *Wrong.* Describing parameters that no longer existed. Promising return values that hadn't been returned since the rewrite."
>
> **The Pragmatist:** "And now?"
>
> **The Veteran:** "Six percent. And dropping. Not because people got more disciplined about writing docs. Because they know the scan will catch it, so they fix it when it's fresh instead of letting it pile up. The GC changed the culture, not just the code."

---

## The deeper point

We celebrate creation. New features, new architectures, new tools. We do not celebrate the person who spends Friday afternoon updating forty docstrings so the AI does not learn from lies next week.

That person is doing some of the most valuable work on the team.

Your environment is not a thing you build once. It is a thing you maintain forever. The building is the easy part. The maintenance is the work.

{: .warning }
> The teams that treat garbage collection as infrastructure -- not chores -- will have environments that compound in value. Everyone else's will quietly fall apart, and they will blame the AI for producing inconsistent output when the real problem is what they are feeding it.

---

## Key takeaways

- **Entropy is physics, not negligence** -- codebases drift from their intended state not because anyone fails, but because change is constant and maintenance is finite.
- **AI accelerates entropy** -- faster code generation means more code to maintain, more docs to keep current, and stale context that reproduces itself through the AI's own output.
- **Garbage collection is the defence** -- systematic, recurring detection and remediation of drift. Not a "tech debt sprint." A structured practice with owners and cadences.
- **Five types of rot** -- documentation staleness, convention drift, dead code, dependency rot, and constraint decay. Each operates at a different speed and needs a different inspection frequency.
- **Periodic beats continuous** -- match inspection frequency to entropy rate. Continuous checking becomes noise.
- **AI is also the cure** -- the same tool that accelerates entropy is extraordinarily good at detecting it. Point it at the problem.
- **Maintenance is the work** -- building an environment is a one-time cost. Maintaining it is the ongoing investment that determines whether everything else compounds or decays.

---

## Further reading

- [Garbage Collection](garbage-collection.md) -- detailed GC rule mechanics and implementation
- [Constraints and Enforcement](constraints-and-enforcement.md) -- the constraints that entropy erodes
- [Compound Learning](compound-learning.md) -- how the learning loop fights entropy over time
