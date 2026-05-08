---
title: Regression Detection
---
# Regression Detection

In harness engineering, regression means something different than it does in software testing. Code regression is a broken feature. Harness regression is a broken habit. When the practices that keep a harness alive stop happening -- when audits are skipped, when reflections dry up, when snapshots go stale -- the harness degrades silently. The constraints still fire. The rules still exist. But the human-in-the-loop activities that evolved and maintained the harness have stopped, and the harness slowly becomes cargo cult: a system that looks correct but is no longer serving the purpose it was designed for.

Regression detection is the harness's immune system. It monitors four key signals about whether the team is still actively engaging with the harness and learning from it. When one signal weakens, the harness notifies the team. When multiple signals weaken together, the harness escalates its alert. This page explains what regression looks like, how it is measured, and how to configure thresholds that match your team's cadence.

---

## What Regression Means Here

Regression in harness practice is distinct from code regression in two ways.

First, it is about practices, not features. A regression does not mean a constraint broke or a rule stopped firing. It means the team has stopped running the practices that keep the harness evolving. An audit that should happen monthly but has not run in three months is a regression. A reflection log that was capturing insights weekly but has been empty for a month is a regression.

Second, regression is slow and silent. Code regressions announce themselves loudly through test failures or user complaints. Harness regression is gradual drift. The harness continues to operate. Constraints still validate. The CI pipeline still runs. But the team's engagement with the harness has quietly atrophied.

This distinction matters because it determines how regression is detected. You cannot catch harness regression with unit tests or CI checks. You have to observe the actual behaviour of the team -- whether they are running audits, updating constraints, capturing reflections, and cleaning up garbage. If those activities stop, the harness stops learning, and it begins to calcify.

---

## The Four Regression Indicators

Every harness health snapshot tracks four indicators that collectively measure whether the team is actively using the harness or letting it decay.

**Snapshot stale.** The most recent snapshot in `observability/snapshots/` is older than the configured cadence threshold, typically 30 days for a monthly audit cadence. If nobody has run `/harness-health` in 30 days, the harness has no telemetry. The team is operating without visibility into the harness's own state. This is the most direct signal that engagement has dropped. (`/harness-sync` surfaces snapshot staleness as an `[auto]` finding in its drift table — running sync regenerates the snapshot via `/harness-health` automatically.)

**Cadence non-compliance.** The `/harness-health` command tracks four key activities: audit (usually monthly), assess (usually quarterly), reflect (ongoing, tracked weekly), and GC (usually monthly). For each activity, the snapshot records when it was last completed and compares it to the declared cadence in `HARNESS.md`. If an activity is overdue relative to its declared cadence, it counts as non-compliant. One non-compliant activity is normal -- schedules slip, urgent work interrupts planned audits. Two or more non-compliant activities signals something systemic has changed. The team is not just behind; they have stopped prioritizing harness maintenance.

**Consecutive weeks without reflections.** Reflections are the compound learning engine of the harness. They capture surprises, adaptations, and decisions. If the reflection log goes silent for four or more consecutive weeks, the team has stopped learning from sessions. This matters because reflections feed garbage collection rules, inform constraint adjustments, and encode institutional knowledge. A drought in reflections means the harness is not evolving in response to new problems. When reflections do recur in patterns, `/harness-sync` surfaces those patterns as `[manual]` candidate-constraint rows in its drift table, with a suggested `/harness-constrain` invocation.

**Regression flag.** A boolean that fires when any of the following conditions are true: snapshot stale, non-compliance is 2 or higher, or consecutive weeks without reflections is 4 or more. This is the aggregate signal. It says: something about your engagement with the harness has changed, and you should pay attention.

---

## Configuring Thresholds

Thresholds are not one-size-fits-all. A team that audits monthly has different tolerance for staleness than a team that audits quarterly. Thresholds are configured in `HARNESS.md` under the Observability section, specifically under `### Regression detection`.

Two thresholds are commonly tuned:

**Cadence non-compliance threshold.** Default is 2. This means the regression flag does not fire unless two or more tracked activities are overdue. Teams that run a tighter schedule (weekly audits, bi-weekly reflections) might lower this to 1, meaning any missed activity triggers attention. Teams that are less frequent (quarterly audits) might raise it to 3.

**Reflection drought threshold.** Default is 4 weeks. This means the regression flag fires if no reflections have been captured in the past four consecutive weeks. Teams that capture reflections in almost every session might lower this to 2 weeks. Teams that reflect less frequently might raise it to 6 or 8 weeks.

When you adjust these thresholds, document why in the `HARNESS.md` comment. The reason matters because the threshold is a claim about your team's rhythm and capacity. If you raise the reflection drought threshold to 8 weeks, you are saying: "Our team reflects less frequently, and that is intentional." If someone later comes back and questions why reflections have been sparse, the documented threshold explains that the threshold itself is already part of the harness.

---

## Connection to Health Status

Regression indicators feed into the Meta section's aggregate health assessment. The harness health snapshot produces an overall status: Healthy, Attention, or Degraded.

If the regression flag is false and other health layers (enforcement drift, silent garbage collection) are nominal, the harness is Healthy. If the regression flag is true, the harness moves toward Attention. If regression is combined with other degraded signals -- say, enforcement has drifted, garbage collection has found multiple stale items, and the team has stopped reflecting -- the harness moves to Degraded.

Attention means the harness is notifying you that engagement has slipped. It is not an emergency. It is a signal to check in: Are we still running audits? Can we carve out time for reflections? Degraded means multiple layers of the harness have weakened together, and you should probably pause feature work to spend a session hardening and re-engaging with the harness.

The regression signal is different from a constraint failure or a garbage collection finding. Those are about specific problems. Regression is about the health of your relationship with the harness itself. Treat it as you would treat a doctor's warning that your fitness is declining: not a diagnosis of disease, but a prompt to pay attention before the decline becomes costly to reverse.

---

## Further reading

- [Harness Engineering](harness-engineering.md) -- the three-component model (context, constraints, observation) that regression detection is part of
- [Garbage Collection](garbage-collection.md) -- how scheduled checks detect codebase entropy over time
- [Compound Learning](compound-learning.md) -- how reflections drive the learning loop and why their absence signals regression
- [Three Enforcement Loops](three-enforcement-loops.md) -- how regression detection fits into the outer (scheduled) enforcement loop
