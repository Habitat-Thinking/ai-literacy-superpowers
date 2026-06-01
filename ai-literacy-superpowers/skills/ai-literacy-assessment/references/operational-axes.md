# Operational Axes (ALCI Part D)

The single, self-contained source for the **four operational axes** and
the **Habitat Build Gap** diagnostic. `/assess`, the `ai-literacy-assessment`
SKILL, and the `assessor` agent all read this file — none of them read
any external repository at runtime.

> **Provenance.** The axis definitions, the L1–L5 marker statements, the
> Habitat Build Gap formula, and the interpretation regimes are copied
> verbatim from the AI Literacy framework's ALCI Part D (Appendix M) and
> Appendix U ("The Cognitive–Operational Gap"). Upstream source:
> `ai-literacy-for-software-engineers`, commits `f13d388` (#327, "Adopt
> Habitat Maturity Model into framework — per-level rubric + ALCI Part D")
> and `542f325` (#330, "unified cognitive+operational dimensions matrix").
> This is an attribution and re-sync pointer only — the content below is
> embedded in full so the plugin works standalone. If the framework's
> markers or regimes change upstream, re-sync by copying the new text
> into this file; never make `/assess` read the upstream repo.

## What Part D measures

Parts A–C of the ALCI measure where a team sits in the **cognitive**
literacy progression — what its members can think and do. Part D
measures what the team's **habitat actually delivers**, across four
operational axes. Part D is **additive**: it does not change the
cognitive level placement. The cognitive position (the assessed level)
and the operational position (the mean of the four axes) together
produce the **Habitat Build Gap**.

Each axis is placed L1–L5. In **evidence-first** mode (the `/assess`
default) the assessor places each axis from observable repository
evidence (the evidence map below), citing evidence per axis exactly as
it cites evidence for the cognitive level. In **survey** mode (opt-in)
the assessor administers the marker statements as a questionnaire on the
Strongly-Disagree (1) → Strongly-Agree (5) scale, two statements per
level, taking the higher-scoring level per axis (if two adjacent levels
tie, take the higher).

## The four axes

### Composition

*How structurally sophisticated is the team's agent topology?*

- **L1:** "I work with a single agent through ad-hoc prompts." / "I rarely save prompts or patterns between sessions."
- **L2:** "I have a personal library of saved prompts and commands I reuse." / "I sometimes set up a critic agent alongside my primary."
- **L3:** "My setup runs a primary agent with read-only critic agents that review its work." / "Agent composition is documented and consistent across the team."
- **L4:** "I orchestrate bounded ensembles of agents composed by a harness." / "Multi-agent workflows are first-class in our process."
- **L5:** "Agents self-orchestrate into constellations; I supervise outcomes, not orchestration." / "Composition is defined by specs and evolves through agent-led refinement."

### Testing

*How rigorously does the team verify what the collaboration produces?*

- **L1:** "We rely on manual inspection of agent output." / "We have ad-hoc unit tests; coverage is uneven."
- **L2:** "We write unit tests for everything agents produce, with disciplined review." / "We use mutation testing to verify our tests."
- **L3:** "Our tests verify both code behaviour and basic business outcomes; agent-generated code includes tests before merge." / "We have automated functional tests covering critical workflows."
- **L4:** "We have comprehensive test automation from both business and technical perspectives, including system-level regression tests." / "Manual exploratory plans complement automation; agents extend the test suite as work progresses."
- **L5:** "Our testing covers risk from multiple perspectives, including post-deployment health and business outcomes in a prod-like test environment." / "Agents author and run test plans autonomously; certification is the human's role, not authoring."

### Observability

*How visible is agent activity, and how tight is the feedback loop back
into agent behaviour?*

- **L1:** "We inspect agent activity by eye when something feels off." / "We have no systematic capture of agent metrics."
- **L2:** "We log agent activity in a place we can search." / "We track basic metrics: token spend, latency, request counts."
- **L3:** "Agent activity is instrumented and visible in dashboards we check at known cadences." / "We track per-PR acceptance trends, mutation kill rates, and AI code acceptance rates."
- **L4:** "We aggregate observability across teams and projects, with dashboards that surface cross-cutting AI collaboration health." / "Perception-reality calibration is tracked with measurement data, not just self-report."
- **L5:** "Observability is closed-loop: outputs feed back into agent behaviour automatically (post-deployment metrics inform spec evolution)." / "Customer-observable metrics are part of the agent's input; the agent can detect and respond to production reality."

### Governance

*How formal and enforceable is the team's governance over AI use?*

- **L1:** "Our governance for AI use is implicit and trust-based; we do not have written policies." / "Different team members use AI differently; there are no agreed norms."
- **L2:** "We have conventional governance norms (informal team agreements about how to use AI)." / "We discuss AI usage in standups or retros but do not codify it."
- **L3:** "We have a written constitution (CLAUDE.md / HARNESS.md) that constrains how agents operate, and we enforce it." / "Constraints are categorised and promoted through unverified → agent-backed → deterministic."
- **L4:** "Governance is policy-as-code: machine-enforced constraints in CI, with explicit blocking rules." / "Governance constraints map to falsifiable behaviour, not aspirational language."
- **L5:** "Governance is continuous certification: every change carries evidence of compliance with verifiable controls." / "The institutional reference frame is explicitly modelled alongside human and AI reference frames in our governance design."

> The **Governance axis** is the one-line *operational* placement of the
> team's governance. The `/assess` document also carries a standalone
> **Governance Dimension** section (the governance deep-dive with the
> `/governance-constrain` improvement ladder). The two are
> cross-referenced and must report a **consistent** governance level —
> the axis is the summary, the Dimension is the deep-dive.

## Evidence map (evidence-first placement)

Observable repository signals the assessor maps to an axis placement.
These extend `sophistication-markers.md` and `tool-config-evidence.md`.

| Axis | Signals that raise the placement |
| --- | --- |
| **Composition** | count and shape of custom agents; read-only critic/reviewer agents; orchestrator with safety gates; agent-team docs in AGENTS.md; multi-agent workflow scripts; specs that define composition |
| **Testing** | test suites present; coverage enforcement; mutation testing config + cadence; tests-before-merge CI gates; system/regression suites; agent-authored test scenarios (e.g. a `tdad_tests/`-style layer); prod-like test environments |
| **Observability** | agent-activity logging; metrics capture (token/latency/cost); dashboards; observability snapshots at a cadence; per-PR acceptance / mutation-kill / AI-acceptance tracking; perception-reality calibration; OTel config; closed-loop signals feeding agent behaviour |
| **Governance** | HARNESS.md constraint count + enforcement ratio; policy-as-code CI checks; falsifiable (not aspirational) constraints; the unverified → agent → deterministic promotion ladder; governance audit cadence; institutional-frame modelling. (Reuses the Governance Dimension evidence.) |

Where repo evidence is ambiguous for an axis, ask **one or two**
clarifying questions for that axis (within the command's 3–5 question
budget) rather than guessing.

## The Habitat Build Gap

The **Habitat Build Gap** combines the cognitive view (the assessed
level) with the operational view (the axes mean):

```text
Habitat Build Gap = level_placement − operational_axes_mean
```

`operational_axes_mean` is the arithmetic mean of the four axis scores
(each 1–5). Both values are on the same 0–5 scale, so the gap is signed.

### Output format

```text
Level placement (from cognitive assessment): L3
Operational axes mean (Part D):              L2.0
  Composition:    L2
  Testing:        L2
  Observability:  L1
  Governance:     L3
Habitat Build Gap:                           +1.0
Interpretation:                              Ambition outpaces enablement
```

### Interpretation regimes

Framework working defaults (recalibrate after the first quarter of use):

| Gap | Name | Interpretation |
| --- | --- | --- |
| `abs(gap) < 0.5` | **Coherent** | Team and habitat are at the same level. Collaboration is well-supported by the environment. |
| `gap ≥ +0.5` | **Ambition outpaces enablement** | Team thinks at a higher level than the habitat supports. Build the habitat the team's thinking already implies. |
| `gap ≤ −0.5` | **Inherited habitat** | Habitat is more mature than the team's current practice. Literacy uplift before further harness extension. |

The headline signal is **coherence**, not the size of the level
placement. A coherent low-level team (L2 cognitive / L2 operational) is
healthier than an incoherent high-level team (L4 cognitive / L1
operational). A positive gap points at habitat investment; a negative
gap points at literacy uplift.
