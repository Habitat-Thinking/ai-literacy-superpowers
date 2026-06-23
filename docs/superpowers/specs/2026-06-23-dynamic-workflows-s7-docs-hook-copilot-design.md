# Specification — Dynamic Workflows S7: Documentation, Advisory Hook, Copilot Degradation Contract (epic finalisation)

**Plugin:** `ai-literacy-superpowers` (Habitat-Thinking)
**Slice:** S7 of the Dynamic Workflows Alignment epic — the **FINAL** slice (D9 — documentation, the optional advisory Stop hook, the CLAUDE.md pointer, and the Copilot CLI degradation contract that the whole epic has carried toward)
**Umbrella spec:** `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
**Slicing record:** `docs/superpowers/slices/dynamic-workflows-alignment.md` (§ S7; Runtime scope — Claude Code only)
**Issue:** <https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/444>
**Depends on:** S1 (#438, merged) — the `dynamic-workflows` skill + election rubric + MODEL_ROUTING workflow-election section; S2 (#439, merged) — the four `*.workflow.js` templates + INV-1/INV-2 firewall; S3 (#440, merged) — enforcer fan-out; S4 (#441, merged) — adversarial review + deep-research assessor/auditor; S5 (#442, merged) — orchestrator classify-and-act routing; S6 (#443, merged) — `/reflect --mine`. S7 documents the now-complete substrate and depends on every prior slice for accurate counts and prose.
**Spec status:** Draft for implementation
**Spec version:** 0.1.0
**Owner:** Russ Miles / Habitat Thinking
**Branch:** `dynamic-workflows-s7-docs-hook-copilot`

> **Implementer note (read first).** This slice is **documentation + one optional advisory hook**. It
> ships **no new skill, agent, or command** and **no new behaviour inside any existing agent**. It
> adds: (1) a new **"Dynamic Workflows" prose section to `README.md`** describing the substrate the
> epic shipped; (2) — *if the GATE accepts it* — **one optional advisory `Stop` hook** in
> `ai-literacy-superpowers/hooks/hooks.json` (warn, **never** block) backed by a new POSIX-portable
> script under `ai-literacy-superpowers/hooks/scripts/`; (3) **one pointer line** to the
> `dynamic-workflows` skill in `CLAUDE.md` (repo root) **and** `ai-literacy-superpowers/templates/CLAUDE.md`;
> (4) a `CHANGELOG.md` entry under the new version. The **headline decision** this slice resolves is
> umbrella **open-question 4** — the **Copilot CLI degradation contract** (guidance-only fallback vs
> omit the skill on the Copilot tree). That contract is **documentation only**: it requires **no code
> change beyond words**, because every S1–S6 slice already declares the guidance-only non-erroring
> fallback as how the agents behave.
>
> **Runtime scope — Claude Code only.** Dynamic workflows are a Claude Code runtime capability,
> **not transferable** to GitHub Copilot CLI or any other coding agent — those trees have no workflow
> runtime. The plugin ships to **both** trees. Where the runtime exists (Claude Code) the workflow
> modes and templates execute; where it does not (Copilot CLI, other agents) the `dynamic-workflows`
> skill and every workflow-mode section **degrade to guidance only** — the knowledge stays readable,
> no workflow is spawned, and workflow-mode agents fall back to their existing static behaviour and
> never error. S7 is the slice that **fixes the precise contract** behind this settled boundary
> (umbrella §5.5 / open-question 4) and **documents it** in the README and the skill/governance
> reference. The skill-count badge is **already 36** (reconciled in S1) — S7 does **not** re-bump it.

---

## 1. Context and motivation

The Dynamic Workflows Alignment epic introduced dynamic workflows as a new **ephemeral execution
substrate** beneath the plugin's static agents, governed by **INV-1** (ephemeral proposes, durable
curates) and **INV-2** (quarantine untrusted-content readers). Six slices shipped it:

- **S1** — the `dynamic-workflows` skill (six patterns, election rubric, INV-1/INV-2) + the
  MODEL_ROUTING workflow-election + token-budget section; the skill-count badge was reconciled to **36** here.
- **S2** — four `*.workflow.js` templates (enforcer-fanout, adversarial-review, reflection-mining,
  deep-assessment) + the deterministic INV-1/INV-2 firewall (`inv-firewall.sh`).
- **S3** — `harness-enforcer` fan-out (one verifier subagent per HARNESS rule + skeptic; threshold **8**).
- **S4** — adversarial verification for `code-reviewer` + `Advocatus Diaboli`, and deep-research mode
  for `assessor` + `harness-auditor`.
- **S5** — `orchestrator` classify-and-act routing (static default; tournament / root-cause /
  triage-at-scale **opt-in behind a flag**).
- **S6** — `/reflect --mine` (cluster → adversarially filter → shortlist into `REFLECTION_STAGING.md`).

What remains is **D9 — finalisation**: tell users the substrate exists (README), point agents at the
skill (CLAUDE.md), optionally add the advisory nudge (Stop hook), and — the load-bearing decision —
**settle the Copilot CLI degradation contract** that every prior slice declared but none has yet fixed
as the plugin's stated cross-CLI policy. The slicing record records the `independence` lens: S7 blocks
nothing and is blocked only by the completeness of the surfaces it documents. The Copilot degradation
decision folds into S7 rather than its own slice because it has **no implementation substrate of its
own** — it is a documentation-and-fallback contract that lives where the docs live.

**Why this is the slice the epic carried toward.** Every S1–S6 spec restated "Claude-Code-gated;
degrades to guidance only; never errors" and explicitly deferred the *precise* cross-CLI contract
(guidance-only vs omit) to S7. S7 is where that promise is honoured: a single, authoritative
statement of the contract, placed in the README and the skill/governance reference, with confirmation
that it needs **no code change** because the degradation is already how the agents behave.

---

## 2. Scope

### 2.1 In scope (this slice)

1. **`README.md` — a new "Dynamic Workflows" prose section.** A section (sibling of the existing
   `### Skills (36)` / `### Hooks (11)` material under `## ai-literacy-superpowers — what it ships`,
   or a top-level `## Dynamic Workflows` under that umbrella) documenting:
   - **What dynamic workflows are** — self-authored, ephemeral, per-task multi-agent harnesses; the
     new execution substrate beneath the static pipeline.
   - **The six patterns / election discipline at a glance** — classify-and-act, fan-out-and-synthesize,
     adversarial verification, generate-and-filter, tournament, loop-until-done; elected via the
     when-not-to-use rubric (long-running / massively parallel / highly structured / adversarial), not
     reflexive — the static pipeline stays the default.
   - **INV-1** (ephemeral proposes, durable curates) and **INV-2** (quarantine untrusted-content readers).
   - **Claude-Code-only runtime scope** with the **§5.5-style degradation statement** — the contract
     resolved in §5 of this spec (guidance-only fallback on Copilot CLI / other agents).
   - **Cross-links** to the `dynamic-workflows` skill (`ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md`)
     and the how-to guide (`docs/plugins/ai-literacy-superpowers/how-to/dynamic-workflows.md`).
   - **The skill-count badge is NOT re-bumped** — it already reads **36** (reconciled in S1). S7 adds
     prose only; it does not touch the `Skills-36` badge or the plugin-table "36 skills" cell.
2. **The Copilot CLI degradation contract (the headline GATE decision — open-question 4).** A single
   authoritative statement of **Option A — guidance-only fallback** (recommended; see §5), placed:
   - as the **§5.5-style statement in the README** Dynamic Workflows section, and
   - as a **note in the skill/governance reference** —
     `ai-literacy-superpowers/skills/dynamic-workflows/references/governance.md` (and/or the SKILL.md
     "Runtime scope — Claude Code only" section, which already carries the boundary prose).
   The contract is **documentation only** — it requires **no code change** beyond words, because every
   S1–S6 workflow-mode already degrades to its static/guidance fallback and never errors.
3. **`hooks/hooks.json` + a backing script — an OPTIONAL advisory `Stop` hook (D9 "optional"; GATE
   decides whether it ships).** If shipped: a `Stop`-array entry mirroring the existing entries
   (`matcher: "*"`, a `type: "command"` invoking
   `bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh`, a short timeout), backed by a new
   POSIX-portable script that, when a session tackled a long / massively-parallel / adversarial task
   **without** electing a workflow, prints a **low-confidence, low-noise** advisory nudging
   consideration of one. **Advisory only — warns via `systemMessage`, NEVER blocks; exits 0 always.**
   The new `.sh` honours the Layer-0 macOS+Linux portability constraint that applies to every hook script.
4. **`CLAUDE.md` (repo root) and `ai-literacy-superpowers/templates/CLAUDE.md` — one pointer line.** A
   single line directing agents to the `dynamic-workflows` skill: *when a task looks long-running /
   massively parallel / highly structured / adversarial, consult the `dynamic-workflows` skill before
   reaching for a workflow.*
5. **`CHANGELOG.md` — an entry under the new version** (§7), themed for the epic finalisation.
6. **Supporting CI / version surfaces** (§7) and the **docs-impact** touch-ups (§7.3).
7. **An "epic complete" confirmation** (§9) — D1–D9 delivered across S1–S7; §7 open questions Q1–Q4
   all resolved.

### 2.2 Out of scope (explicitly deferred — do not blur)

| Deferred / forbidden concern | Why not here |
| --- | --- |
| Any new behaviour inside a workflow-mode agent, or any new workflow template | The substrate is complete (S1–S6); S7 documents it and adds at most an advisory nudge. No `*.agent.md` behaviour change, no `*.workflow.js` edit. |
| Re-bumping the **skill-count** badge (36) or component-count badges | S1 already reconciled the skill count to 36. S7 adds **no** new skill/agent/command — only prose, one pointer line, and (optionally) one hook. |
| A **blocking** hook, or any hook that exits non-zero / persists state | Forbidden by the AGENTS.md "hook scripts never block, only warn" decision. The new hook (if shipped) is advisory-only, `exit 0` always, no disk writes about the human's state. |
| Making the Stop hook *truly* detect task shape (parsing transcripts, model calls) | A Stop hook cannot reliably know whether a session was long/parallel/adversarial. The hook (if shipped) is a **low-confidence heuristic nudge** by design — see §6 decision 2. Over-claiming detection is a non-goal. |
| Auto-omitting the skill on the Copilot tree (Option B) | Recommended **against** (§5) — it would contradict shipped S1–S6 behaviour, which already declares a guidance-only non-erroring fallback. Surfaced for the human, not chosen. |
| Changing the listing `version` (`0.4.0`) | S7 alters no listing contract (no description/keyword/permission/source change, no plugin entry added/removed). The listing `version` stays `0.4.0`; only `plugin_version` + the per-plugin entry version move with the bump. |

**Boundary rule.** S7 modifies, at most: `README.md`, `CLAUDE.md`, `ai-literacy-superpowers/templates/CLAUDE.md`,
`CHANGELOG.md`, the skill/governance reference (`.../skills/dynamic-workflows/references/governance.md`
and/or `SKILL.md`), the five CI-enforced version locations, and — *if the GATE ships the hook* —
`ai-literacy-superpowers/hooks/hooks.json` plus one new
`ai-literacy-superpowers/hooks/scripts/<name>.sh`. It ships **no new component** and **no new CI
workflow** (the tdd-agent wires any new test into the existing `tdad-tests-fast.yml`).

---

## 3. User story

> **As a** developer or new contributor browsing the `ai-literacy-superpowers` README, **I want** a
> clear "Dynamic Workflows" section that explains what the new ephemeral multi-agent substrate is, the
> six patterns and the election discipline at a glance, the two governance invariants, and that it is
> **Claude-Code-only — degrading to readable guidance everywhere else** — **so that** I understand
> what the plugin now ships, know when (and when not) to reach for a workflow, and know exactly what
> to expect on the Copilot CLI tree (the knowledge is readable; no workflow is spawned; nothing errors).

Supporting story (advisory nudge, if the hook ships):

> **As an** agent finishing a session that tackled a long / massively-parallel / adversarial task
> **without** electing a workflow, **I want** a gentle, low-noise end-of-session nudge to consider
> whether a dynamic workflow would have fit, **so that** the substrate is reached for deliberately —
> **without** ever being blocked, and without false-positive noise on ordinary coding sessions.

This honours **INV-1** at the documentation layer: the README and reference state the durable/ephemeral
boundary; the advisory hook (if shipped) only *nudges* — it never writes a durable artefact, never
blocks, and never claims certainty it does not have.

---

## 4. Acceptance scenarios (Given / When / Then)

Each scenario carries its **verification-slot** tag from the umbrella taxonomy: *deterministic*
(CI-checkable / Layer-0–1 structural) or *unverified / observational* (declared intent). Scenarios
trace to umbrella **D9** acceptance and to §5.5 (Copilot degradation). The tdd-agent turns the
deterministic scenarios into failing checks first.

> **Slot tags** are shown as `[deterministic]`, `[deterministic — conditional on hook GATE]`, and
> `[observational]`. Scenarios AC-6 and AC-7 are **conditional on the hook-ship GATE decision** (§6
> decision 1): they apply **only if** the advisory Stop hook ships.

### The README Dynamic Workflows section (deterministic, structural)

**AC-1 `[deterministic]` — the README has a Dynamic Workflows section.**
**Given** `README.md`,
**When** it is read,
**Then** it contains a **"Dynamic Workflows" section** (a heading whose text contains
`Dynamic Workflows`) describing dynamic workflows as the ephemeral, self-authored, per-task
multi-agent substrate beneath the static pipeline.

**AC-2 `[deterministic]` — the section names the six patterns and the election discipline.**
**Given** the Dynamic Workflows section,
**When** it is read,
**Then** it names the **six patterns** (classify-and-act, fan-out-and-synthesize, adversarial
verification, generate-and-filter, tournament, loop-until-done) and states the **election discipline**
— workflows are elected via the when-not-to-use rubric, not reflexive; the static pipeline stays the
default.

**AC-3 `[deterministic]` — the section states INV-1 and INV-2.**
**Given** the Dynamic Workflows section,
**When** it is read,
**Then** it states **INV-1** (ephemeral proposes, durable curates — a workflow may propose but never
write `HARNESS.md`/`AGENTS.md`/`CLAUDE.md`/`MODEL_ROUTING.md`) and **INV-2** (quarantine — an
untrusted-content reader is withheld high-privilege tools).

**AC-4 `[deterministic]` — the section states the Claude-Code-only scope + the guidance-only Copilot contract, and cross-links the skill + how-to.**
**Given** the Dynamic Workflows section,
**When** it is read,
**Then** it states that dynamic workflows are **Claude-Code-only** and that on Copilot CLI / other
agents the skill and workflow modes **degrade to guidance only** (knowledge readable, no workflow
spawned, no error) — the **Option A** contract of §5 — and it **cross-links** the `dynamic-workflows`
skill and the how-to guide.

**AC-5 `[deterministic]` — the skill-count badge is unchanged at 36.**
**Given** `README.md`,
**When** the `Skills-` shields badge and the plugin-table "skills" cell are read,
**Then** they **still read 36** — S7 does **not** re-bump the skill count (reconciled in S1).

### The Copilot degradation contract in the skill/governance reference (deterministic, structural)

**AC-6c `[deterministic]` — the skill/governance reference states the guidance-only contract.**
**Given** `ai-literacy-superpowers/skills/dynamic-workflows/references/governance.md` (and/or the
SKILL.md "Runtime scope" section),
**When** it is read,
**Then** it states the resolved Copilot CLI degradation contract: the skill **ships to both trees**;
on a tree without the workflow runtime it is **guidance only** — readable knowledge, **no workflow
spawned, never errors** — i.e. **Option A** (guidance-only fallback), **not** omission.
*(Slot note: this is a file-read structural assertion. The contract being "no code change beyond
documentation" is itself witnessed by the absence of any `*.agent.md` / `*.workflow.js` edit in this
slice — the degradation is already how the agents behave from S1–S6.)*

### The CLAUDE.md skill pointer (deterministic, structural)

**AC-7p `[deterministic]` — both CLAUDE.md surfaces point to the skill.**
**Given** `CLAUDE.md` (repo root) **and** `ai-literacy-superpowers/templates/CLAUDE.md`,
**When** each is read,
**Then** each contains a line directing agents to the **`dynamic-workflows`** skill when a task looks
**long-running / massively parallel / highly structured / adversarial**, to consult the skill before
reaching for a workflow.

### The advisory Stop hook — CONDITIONAL on the hook-ship GATE (§6 decision 1)

**AC-6 `[deterministic — conditional on hook GATE]` — if shipped, the hook is registered under `Stop` and invokes a script.**
**Given** the GATE decides the advisory hook ships, and `ai-literacy-superpowers/hooks/hooks.json`,
**When** the `Stop` hook array is read,
**Then** it contains a new entry invoking
`bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh` (mirroring the existing Stop-hook entries — a
`type: "command"` hook with a short timeout, under a `matcher: "*"` block), and the named script
**exists** under `ai-literacy-superpowers/hooks/scripts/`.

**AC-7 `[deterministic — conditional on hook GATE]` — if shipped, the script is non-blocking and exits 0.**
**Given** the GATE ships the hook, and the new
`ai-literacy-superpowers/hooks/scripts/<name>.sh`,
**When** it runs (with or without a matching session signal, on macOS or Linux),
**Then** it **exits 0 always**, **never blocks** (emits at most a `systemMessage` advisory, like every
other hook script), and persists **no** state to disk — a Layer-0 plumbing assertion mirroring the
existing advisory-hook scripts.

### Observational — the nudge actually helps / does not add noise (if the hook ships)

**AC-8 `[observational]` — if shipped, the nudge is low-noise (no false positives on ordinary sessions).**
**Given** an ordinary single-file coding session that did **not** warrant a workflow,
**When** the session ends and the advisory hook runs,
**Then** it **stays silent** (no nudge) — the nudge fires only on a low-confidence heuristic signal of
a long/parallel/adversarial session with no workflow elected.
*(Slot note: a Stop hook cannot truly know the task shape, so whether the heuristic fires
**appropriately** is an **observation to record in a first-run note / snapshot**, not a deterministic
assertion. The deterministic guarantees are AC-6/AC-7 — registered, non-blocking, exits 0; the
*quality* of the heuristic is observational. If the GATE defers the hook, AC-8 does not apply.)*

### Epic-complete confirmation (deterministic, structural — this spec)

**AC-9 `[deterministic]` — this spec confirms the epic complete.**
**Given** this S7 spec,
**When** §9 is read,
**Then** it confirms **D1–D9 delivered** across S1–S7 and the **four umbrella open questions resolved**
(Q1 threshold=8 → S3; Q2 routing opt-in → S5; Q3 staging=`REFLECTION_STAGING.md` → S6; Q4 Copilot
degradation → resolved here as Option A).

---

## 5. The headline GATE decision — open-question 4: the Copilot CLI degradation contract

The plugin ships to **both** the Claude Code and Copilot CLI trees. Dynamic workflows are a Claude
Code runtime capability with **no** equivalent on the Copilot tree. Umbrella §5.5 settled that the
boundary is **Claude-Code-gated with a guidance-only degradation**; what S7 must **fix** is the
*precise contract* — does the skill **ship to Copilot and degrade to guidance**, or is it **omitted
entirely** on the Copilot tree?

**Pre-listed contract surfaces a recommendation could break** (so the spec-mode diaboli's scrutiny is
scoped, per the AGENTS.md STYLE note): (1) the **already-shipped S1–S6 declarations** — every slice
states a guidance-only non-erroring fallback; a contract that contradicts them is a regression, not a
decision; (2) the **plugin's cross-tree shipping model** — the plugin is distributed identically to
both trees via the marketplace, so "omit on Copilot" implies a build-time or load-time gating
mechanism the plugin does not have; (3) the **skill's own SKILL.md "Runtime scope" prose** (S1) which
already tells a Copilot reader the skill is "guidance only" there.

### Option A — guidance-only fallback (RECOMMENDED)

The skill **ships to the Copilot tree too**. Without the workflow runtime it is **readable knowledge
only**: every workflow-mode degrades to its static/guidance fallback, no workflow is spawned, and
nothing errors. This is **exactly what every S1–S6 slice already declared** and what the shipped
SKILL.md "Runtime scope — Claude Code only" section already tells the reader.

- **Strength:** it is the **consistent** resolution — it matches shipped behaviour across all six prior
  slices and the shipped SKILL.md prose. It requires **no code change beyond documentation**: the
  degradation is already how the agents behave (a workflow-mode agent on a tree without the runtime
  falls back to its static behaviour; this slice changes no agent). The knowledge (patterns, election
  rubric, INV-1/INV-2) stays valuable to a Copilot reader as a way of *thinking* about delegation even
  where they cannot spawn a workflow.
- **Where it is documented:** a **§5.5-style statement in the README** Dynamic Workflows section
  (AC-4) **and** a **note in the skill/governance reference** —
  `skills/dynamic-workflows/references/governance.md` and/or the SKILL.md "Runtime scope" section
  (AC-6c). One authoritative statement, two surfaces (user-facing README + agent-facing reference).
- **Diaboli should stress:** does "guidance only" overclaim usefulness on Copilot (no — it explicitly
  says no workflow can be spawned; the value is conceptual, and the static pipeline behaviour is
  unchanged)? Does it require any code (no — confirm by the absence of any `*.agent.md` /
  `*.workflow.js` edit in this slice)?

### Option B — omit the skill entirely on the Copilot tree

The `dynamic-workflows` skill is **not shipped** to the Copilot CLI tree at all.

- **Weakness — this contradicts shipped behaviour.** Every merged slice (S1–S6) already declares a
  guidance-only non-erroring fallback, and the shipped SKILL.md "Runtime scope" section already tells
  a Copilot reader the skill is guidance-only *there*. Choosing B would make six shipped slices and a
  shipped skill file **wrong retroactively**, and would require a tree-conditional packaging mechanism
  the plugin does not have (it ships identically to both trees via the marketplace). It also discards
  the conceptual value of the knowledge to a Copilot reader. B is tenable only if the team decides the
  knowledge is *actively misleading* without the runtime — which the explicit "no workflow can be
  spawned here" framing already prevents.

### Recommendation

**Option A — guidance-only fallback.** It is the consistent, already-shipped resolution; it needs **no
code change beyond documentation**; and it is the contract the SKILL.md already implies. Document it
once, authoritatively, in the README §5.5-style statement (AC-4) and the skill/governance reference
(AC-6c). **Surfaced as the human's decision at the GATE** — the spec recommends A and the human
disposes; B is presented honestly as the alternative and its cost (contradicting shipped behaviour)
named.

**Confirmation of "no code change":** Option A is satisfiable entirely in prose. There is **no**
`*.agent.md`, `*.workflow.js`, or command edit required — the degradation is already the agents'
behaviour from S1–S6. The only files A touches are the README and the skill/governance reference.

---

## 6. Other GATE decisions to surface

### Decision 1 — does the advisory Stop hook ship at all? (D9 "optional")

D9 marks the Stop hook **optional**. The honest tension: a Stop hook **cannot reliably know** whether
a session was long-running, massively parallel, or adversarial — it runs at session end with access to
cheap, coarse signals (git activity, wall-clock span, file counts), not the task's semantic shape. So
the choice is between a **low-confidence, low-noise nudge** and **deferring the hook** to avoid noise.

- **Option H1 — ship a low-confidence, low-noise advisory hook (RECOMMENDED, with the low-noise
  default).** A new `Stop`-array entry mirroring the existing entries (`matcher: "*"`,
  `type: "command"`, short timeout), backed by a POSIX-portable script that:
  - fires **only** on a deliberately conservative heuristic — e.g. a session with a **large** number
    of commits / touched files over a long wall-clock span (a coarse proxy for "long/parallel work")
    **and** no sign a workflow was elected — tuned to **stay silent on ordinary sessions** (favour
    false negatives over false positives; a missed nudge is cheap, a noisy one erodes trust);
  - prints, when it fires, a single short `systemMessage` advisory: *this session looked
    long/parallel/structured — consider whether a `dynamic-workflows` workflow would fit next time*;
  - **never blocks, exits 0 always, persists no state** (the AGENTS.md advisory-hook decision);
  - is **macOS+Linux portable** (the Layer-0 BSD/GNU constraint — POSIX-only constructs, no GNU-only
    flags).
  *Strength:* it makes the substrate **reachable** at the moment of reflection without adding a CI
  surface; it is the same advisory-loop pattern as `reflection-prompt.sh` / `curation-nudge.sh`.
  *Diaboli should stress:* will the heuristic false-positive on ordinary multi-commit sessions (it
  must not — tune to the conservative end; AC-8 is the observational guard)? Does it duplicate an
  existing Stop nudge (no — none of the eleven existing Stop hooks nudges about workflow election)?
- **Option H2 — defer the hook; ship docs + the CLAUDE.md pointer only.** If the heuristic cannot be
  made low-noise enough to be worth its place in the Stop array, **do not ship it**. The CLAUDE.md
  pointer (AC-7p) and the README section already make the substrate discoverable; a noisy hook would
  erode the "every Stop hook earns its place" trust the existing eleven have built. Document the
  deferral and why (the Stop hook cannot truly know task shape) so the absence is deliberate, not an
  oversight — and so a future slice with real signal (e.g. an `ultracode`-invocation record) can add
  it on firmer ground.

**Recommendation: H1 with the low-noise default — *but* this is genuinely the human's call**, because
the value/noise trade-off is a judgement the spec cannot settle alone. If the GATE is unsure, **H2
(defer) is the safer default**: the pointer + README already deliver discoverability, and a deferred
hook costs nothing, whereas a noisy hook costs trust across every session. The spec recommends shipping
**only if** the heuristic can be tuned conservatively enough to satisfy AC-8; otherwise defer.

**Version consequence of this decision** (see §7): **shipping the hook** is a behavioural change → a
**minor** bump is unambiguous. **Deferring the hook** leaves a new README section + the behavioural
CLAUDE.md/template pointer — still a **minor** (a new documented substrate surface + a behavioural
agent pointer in plugin files), recommended over patch (§7.1 reasons).

### Decision 2 — the advisory-hook heuristic (if H1): what signal fires the nudge?

*Applies only if Decision 1 ships the hook.* The heuristic must be **coarse, conservative, and
portable**. Candidate signals (the implementer picks, the diaboli stresses for noise):

- **Commit/file volume over a long span** — many commits or touched files in a long wall-clock session
  (proxy for long/parallel work). Conservative thresholds; favour silence.
- **No workflow-election signal** — no evidence the session reached for a workflow (e.g. no
  `ultracode` marker / no workflow artefact). Absence is the trigger condition, not the heuristic by
  itself.

**Recommendation:** fire **only** when *both* a strong volume/span signal **and** the no-workflow
condition hold, and **default to silent** otherwise. The thresholds are tuning constants the
implementer sets conservatively; **no threshold is asserted as precise** (cf. AGENTS.md "no threshold
before data"). AC-8 records the heuristic's real-world appropriateness observationally — it is **not**
promised as deterministic.

### Decision 3 — the verification split (deterministic structural vs unverified/observational)

Mirroring S3–S6 decision-N: this repo's deterministic layer **reads files and matches structure**; it
does **not** run a session and judge whether the hook *should* have fired.

- **Deterministically assertable (structural, Layer-0/1) — the declarations + plumbing.**
  - README has a Dynamic Workflows section (AC-1) naming the six patterns + election discipline
    (AC-2), INV-1/INV-2 (AC-3), the Claude-Code-only + guidance-only Copilot contract + skill/how-to
    cross-links (AC-4); the skill-count badge is unchanged at 36 (AC-5).
  - The skill/governance reference states the guidance-only contract (AC-6c).
  - Both CLAUDE.md surfaces carry the skill pointer (AC-7p).
  - **If the hook ships:** `hooks.json` registers it under `Stop` invoking the named script, which
    exists (AC-6); the script **exits 0 / is non-blocking** on macOS+Linux (AC-7) — a **Layer-0
    plumbing** assertion, mirroring how the existing hook scripts are exercised.
- **Unverified / observational — the heuristic quality.** Whether the nudge fires **appropriately**
  (AC-8) is an observation to record in a first-run note / snapshot, **not** a deterministic assertion
  — a Stop hook cannot truly know task shape. It must **not** be over-promised as deterministic.

**Recommendation:** the tdad-scenario set is **predominantly structural** (AC-1–AC-5, AC-6c, AC-7p as
Layer-1 file-read assertions; AC-6/AC-7 as Layer-1 structural + Layer-0 plumbing **if** the hook
ships), with **AC-8** standing as **observational/unverified**. The tdd-agent will author a new
deterministic content test `tdad_tests/tests/test_s7_docs_hook_copilot_structural.py` (mirroring
`test_s6_reflection_mining_structural.py` — a section-slicing helper isolating the README Dynamic
Workflows section, the governance-reference contract statement, and the CLAUDE.md pointer lines; phrase
assertions per AC) and **wire it into the existing `.github/workflows/tdad-tests-fast.yml`** as a new
step (a sibling of the existing `Run Layer 1 (dynamic-workflows S6 reflection mining)` step at lines
76–78). **If the hook ships**, the tdd-agent also adds a **Layer-0** assertion that the new
`<name>.sh` exits 0 / is non-blocking (mirroring the Layer-0 plumbing tests for the existing advisory
scripts). Spec-writer **names** these homes; spec-writer does **not** create the directories or any
test file (spec-first discipline — no test files in this commit).

The diaboli should stress whether any property tagged structural actually needs a live session (it
should not — each is a file read or a `bash`-exit-code check), and whether AC-8 risks being
over-promised as deterministic (it must not — the *registration + exit-0* are structural; the
*heuristic-fires-appropriately* property is observational).

### 6.1 Decision summary for the GATE

| Decision | Options | Recommendation |
| --- | --- | --- |
| **Copilot CLI degradation contract (open-question 4 — the headline)** | **A guidance-only fallback** / B omit the skill on Copilot | **A** — guidance-only; consistent with shipped S1–S6 behaviour and the shipped SKILL.md; **no code change beyond documentation**; documented in the README §5.5-style statement + the skill/governance reference. B contradicts shipped behaviour. |
| Does the advisory Stop hook ship? | **H1 ship low-confidence, low-noise hook** / H2 defer (docs + pointer only) | **H1 *only if* the heuristic tunes conservatively enough to satisfy AC-8; otherwise H2 (defer).** Genuinely the human's call; H2 is the safer default. Either way → **minor** bump (§7.1). |
| The heuristic signal (if H1) | volume/span + no-workflow / other | Fire only on **both** a strong volume/span signal **and** the no-workflow condition; default silent; conservative thresholds (no threshold asserted as precise). |
| Verification split | all-deterministic / **structural declarations + plumbing + observational heuristic** | **structural (AC-1–AC-5, AC-6c, AC-7p; AC-6/AC-7 if hook ships) + observational heuristic quality (AC-8)** — same realistic split as S3–S6. |

---

## 7. CI, version, and docs checklist

### 7.1 Version bump — minor, **`0.63.0 → 0.64.0`**

Current version confirmed **`0.63.0`** (`plugin.json`; the `README.md` badge line 6 + plugin-table
cell line 31; the `CHANGELOG.md` top heading; both `marketplace.json` `plugin_version` and the
`ai-literacy-superpowers` `plugins[].version` entry).

**Bump rationale.** If the hook ships, S7 adds a **new advisory hook → behavioural change → minor**,
unambiguously. **Even if the hook is deferred** (Decision 1 → H2), S7 still adds (a) a **new
documented substrate surface** (the README Dynamic Workflows section) and (b) a **behavioural pointer
in plugin files** (`templates/CLAUDE.md` directs agents to consult the skill). Per CLAUDE.md Semantic
Versioning — *"adds … or changes plugin behaviour → minor"* — the template CLAUDE.md pointer is a
behavioural change to a plugin file, so a **minor** is the honest call in **both** branches. (A
README-only docs change would be a patch, but the `templates/CLAUDE.md` pointer is inside the plugin
directory and changes agent guidance.) **Recommend minor `0.63.0 → 0.64.0` regardless of the hook
decision.**

The `Version Check` CI enforces **five** locations (per CLAUDE.md / the live `version-check.yml`).
Update **every** one:

1. `ai-literacy-superpowers/.claude-plugin/plugin.json` — `"version"` (canonical; `0.63.0` → `0.64.0`)
2. `README.md` — shields.io **badge** `ai--literacy--superpowers-v0.64.0` (line 6; currently `v0.63.0`)
3. `CHANGELOG.md` — new top heading `## 0.64.0 — 2026-06-23`
4. `.claude-plugin/marketplace.json` — top-level `plugin_version` (`0.63.0` → `0.64.0`; owned by
   ai-literacy-superpowers PRs)
5. `.claude-plugin/marketplace.json` — the `ai-literacy-superpowers` `plugins[].version` entry
   (`0.63.0` → `0.64.0`)

Also update, for human-facing consistency (**not** CI-enforced): the `README.md` plugin-table row cell
(`| v0.63.0 |` → `| v0.64.0 |`, line 31).

> The marketplace listing `version` (`0.4.0`) does **not** change — S7 alters no listing contract.
> The **skill-count** badge (`Skills-36`) and the plugin-table "36 skills" cell do **not** change —
> S1 reconciled them; S7 adds no skill. **If the hook ships**, the human-facing `### Hooks (11)`
> README section heading becomes **`### Hooks (12)`** and a twelfth bullet is added — this is a
> human-facing count, **not** a CI-enforced badge (there is no `Hooks-` shields badge). If the hook is
> deferred, the Hooks count stays **11**.

If a rebase surfaces a `plugin_version` conflict from a non-`ai-literacy-superpowers` PR, take **main's
value verbatim** (CLAUDE.md Marketplace-versioning rule) — this PR owns the top-level pointer only
because it bumps this plugin.

Before committing, grep for the **old** version to surface every spot at once:

```text
grep -rn 'v0\.63\.0\|0\.63\.0' README.md .claude-plugin/marketplace.json \
  ai-literacy-superpowers/.claude-plugin/plugin.json CHANGELOG.md
```

### 7.2 CI gates

- **`spec-first-check`** — satisfied by **this spec being the first commit** on branch
  `dynamic-workflows-s7-docs-hook-copilot`. No exemption label; this is feature work.
- **`tdad-scenario-check`** — **if the hook ships**, the new hook script is a new *script*, not a
  skill/agent/command, so the component-scoped scenario gate is not strictly forced; nonetheless the
  tdd-agent authors structural scenarios for the README/reference/CLAUDE.md declarations (AC-1–AC-5,
  AC-6c, AC-7p) and, if the hook ships, the hook-registration + plumbing scenarios (AC-6, AC-7). The
  tdd-agent creates `tdad_tests/scenarios/...` homes mirroring the S6 set; spec-writer **names** the
  homes and assertion set but does **not** create directories or test files (spec-first discipline).
- **The deterministic content test** — the tdd-agent authors
  `tdad_tests/tests/test_s7_docs_hook_copilot_structural.py` (mirroring
  `test_s6_reflection_mining_structural.py`) and **wires it into the existing
  `.github/workflows/tdad-tests-fast.yml`** as a new step (sibling of the S6 step at lines 76–78).
  **If the hook ships**, the tdd-agent adds a **Layer-0** exit-0/non-blocking assertion for the new
  `<name>.sh` alongside the existing advisory-script plumbing tests. Spec-writer **notes** this; the
  tdd-agent authors and wires it. **Do not author tests in this commit.**
  - **Line-wrap caution (bit S3 twice, S4 twice, flagged for S5/S6).** Several assertions are
    **two-word phrases** the structural test may match literally — e.g. `Dynamic Workflows`,
    `Claude Code`, `guidance only`, `dynamic-workflows`, `long-running`, `massively parallel`,
    `highly structured`, `static pipeline`, `ephemeral proposes`, `durable curates`. When the
    tdd-agent and implementer author the prose, **keep these phrases unwrapped** (not split across a
    line break), or assert them as co-occurring tokens per the S5/S6 split convention. Single
    load-bearing tokens (`dynamic-workflows`, `INV-1`, `INV-2`, `36`) are wrap-safe. This is a
    tdd/impl concern — noted so it is not rediscovered a sixth time.
- **`shellcheck` / `bash -n` (if the hook ships)** — the new `<name>.sh` must pass ShellCheck and the
  `bash -n` syntax check (the deterministic shell gates) and the **macOS+Linux portability** constraint
  (no GNU-only flags; POSIX-portable constructs) — the Layer-0 BSD/GNU lesson the epic's reflection
  recorded. Run ShellCheck against the new script before promoting (AGENTS.md GOTCHA — deterministic
  tools catch what review misses).
- **`INV-1 firewall` (S2, existing)** — S7 adds **no `*.workflow.js` template** and edits none, so the
  firewall is not triggered by new template content. The advisory hook (if shipped) writes **no**
  durable artefact — it emits at most a `systemMessage` and exits 0.
- **`lint-markdown`** — the modified `README.md`, `CLAUDE.md`, `templates/CLAUDE.md`, the
  skill/governance reference, this spec, and any touched docs page must pass markdownlint (PreToolUse
  hook + CI).
- **`Choice cartographer` / objection gates** — this feature PR proceeds through the plugin's own
  pipeline (spec → diaboli → adjudicate → plan → implement → diaboli code-mode → adjudicate).
  Dispositions on any objection record must be resolved before the plan-approval GATE.

### 7.3 Docs-impact note (CLAUDE.md "Docs Site Review")

- **Explanation / how-to (touch-up).** The orientation guide
  `docs/plugins/ai-literacy-superpowers/how-to/dynamic-workflows.md` already exists (S1) and already
  carries the "Runtime scope — Claude Code only / guidance only" note. S7 should **confirm it states
  the resolved Option A contract** (guidance-only, never omit) so the how-to and the README §5.5-style
  statement agree, and add a one-line cross-link to the new README Dynamic Workflows section.
  Consistency touch-up, not a new page.
- **Reference.** The skill/governance reference
  (`skills/dynamic-workflows/references/governance.md`) is **edited in-scope** (AC-6c) to state the
  Option A contract. If a docs-site reference page mirrors the skill's governance content, keep it
  current — a one-line note that the Copilot fallback is guidance-only.
- **Hooks reference (if the hook ships).** If a docs-site reference enumerates the hooks, add the new
  advisory hook to that list (and the README `### Hooks (11)` → `(12)` count, §7.1). If the hook is
  deferred, no hooks-reference change.
- **Tutorials.** None required — no tutorial describes the substrate as *undocumented* in a way S7
  would contradict.

---

## 8. FR → acceptance-scenario mapping

### 8.1 Functional requirements

Numbered and testable; each maps to one or more acceptance scenarios.

- **FR-1.** `README.md` contains a **Dynamic Workflows section** describing the ephemeral multi-agent
  substrate. *(AC-1)*
- **FR-2.** The section names the **six patterns** and the **election discipline** (elected, not
  reflexive; static pipeline stays default). *(AC-2)*
- **FR-3.** The section states **INV-1** and **INV-2**. *(AC-3)*
- **FR-4.** The section states the **Claude-Code-only scope** + the **guidance-only Copilot contract**
  (Option A) and **cross-links** the skill + how-to. *(AC-4)*
- **FR-5.** The **skill-count badge + plugin-table cell remain 36** (no re-bump). *(AC-5)*
- **FR-6.** The **skill/governance reference** states the resolved **Option A** guidance-only Copilot
  contract (ship to both trees; guidance-only where no runtime; never omit, never error). *(AC-6c)*
- **FR-7.** **`CLAUDE.md` (root) and `templates/CLAUDE.md`** each carry a **pointer line** to the
  `dynamic-workflows` skill for long-running / massively parallel / highly structured / adversarial
  tasks. *(AC-7p)*
- **FR-8 *(conditional — only if Decision 1 ships the hook)*.** `hooks/hooks.json` registers a **new
  advisory `Stop` hook** invoking a new POSIX-portable `hooks/scripts/<name>.sh` that **exits 0,
  never blocks, persists no state**, and fires a low-noise nudge only on a conservative
  long/parallel/adversarial-without-workflow heuristic. *(AC-6, AC-7; AC-8 observational)*
- **FR-9.** The plugin version is bumped **`0.63.0 → 0.64.0`** across all five CI-enforced locations
  (§7.1), and the human-facing README plugin-table cell (and Hooks count, if the hook ships) is
  updated. *(CI: Version Check)*
- **FR-10.** The how-to / reference docs are checked and updated for the resolved Copilot contract
  (and the new hook, if shipped) (§7.3). *(docs-impact)*
- **FR-11.** This spec **confirms the epic complete** — D1–D9 across S1–S7; Q1–Q4 resolved. *(AC-9)*

### 8.2 Mapping table

| FR | Covered by | Slot |
| --- | --- | --- |
| FR-1 | AC-1 | deterministic (structural) |
| FR-2 | AC-2 | deterministic (structural) |
| FR-3 | AC-3 | deterministic (structural) |
| FR-4 | AC-4 | deterministic (structural) |
| FR-5 | AC-5 | deterministic (structural — no-change assertion) |
| FR-6 | AC-6c | deterministic (structural) |
| FR-7 | AC-7p | deterministic (structural) |
| FR-8 *(conditional)* | AC-6, AC-7 (deterministic); AC-8 (observational) | deterministic (structural + Layer-0 plumbing) / observational |
| FR-9 | (CI: Version Check) | deterministic |
| FR-10 | (docs-impact) | deterministic (presence) |
| FR-11 | AC-9 | deterministic (structural — this spec) |

**Observational / unverified:**

- **AC-8** — the advisory hook's heuristic fires appropriately (low-noise, no false positives on
  ordinary sessions) — recorded in a first-run note / snapshot. Applies only if the hook ships. Must
  **not** be over-promised as deterministic.

---

## 9. Epic-complete confirmation, risks, and open questions

### 9.1 Epic complete — D1–D9 delivered across S1–S7

This is the **final** slice. With S7 merged, the Dynamic Workflows Alignment epic is complete:

| Deliverable | Slice | Status |
| --- | --- | --- |
| **D1** — `dynamic-workflows` skill | S1 (#438) | delivered |
| **D8** — compute-discipline election gate | S1 (#438) | delivered |
| **D2** — four `*.workflow.js` templates | S2 (#439) | delivered |
| **§5.1** — INV-1/INV-2 firewall (`inv-firewall.sh`) | S2 (#439) | delivered |
| **D3** — `harness-enforcer` fan-out | S3 (#440) | delivered |
| **D5** — adversarial `code-reviewer` + `Advocatus Diaboli` | S4 (#441) | delivered |
| **D7** — deep-research `assessor` + `harness-auditor` | S4 (#441) | delivered |
| **D4** — `orchestrator` classify-and-act routing | S5 (#442) | delivered |
| **D6** — reflection-mining (`/reflect --mine` → `REFLECTION_STAGING.md`) | S6 (#443) | delivered |
| **D9** — README section, advisory hook (optional), CLAUDE.md pointer, CHANGELOG, **Copilot contract** | **S7 (#444 — this slice)** | **delivering** |

### 9.2 The four umbrella open questions — all resolved

| Q | Question | Resolution | Slice |
| --- | --- | --- | --- |
| **Q1** | D3 fan-out constraint-count threshold | **8** (spec default, configurable per project) | S3 |
| **Q2** | D4 tournament/root-cause/triage routes default | **opt-in behind an explicit flag**; static pipeline remains the sole default | S5 |
| **Q3** | D6 staging artefact location | **a new `REFLECTION_STAGING.md`** (clean separation from the append-only log) | S6 |
| **Q4** | Copilot CLI degradation contract | **Option A — guidance-only fallback** (ship to both trees; guidance-only where no runtime; never omit, never error); documentation only, no code change | **S7 (this slice)** |

With Q4 resolved, **all four open questions are closed** and the umbrella spec's §7 is fully
dispositioned.

### 9.3 Risks

- *Over-claiming the advisory hook's intelligence.* A Stop hook cannot know task shape; framing the
  nudge as a confident detector would mislead. Mitigation: §6 decision 1/2 frame it as a
  **low-confidence, low-noise** heuristic; AC-8 keeps its real-world quality observational; H2 (defer)
  is the safe default if it cannot be tuned conservatively.
- *Hook noise eroding trust.* A false-positive nudge on ordinary sessions erodes the "every Stop hook
  earns its place" trust the existing eleven have built. Mitigation: fire only on a conservative
  both-signals heuristic; default silent; the diaboli should reject any heuristic that nudges on a
  plain multi-commit session.
- *Contradicting shipped behaviour on the Copilot contract.* Choosing Option B would make six merged
  slices and the shipped SKILL.md retroactively wrong. Mitigation: §5 recommends A (the consistent
  resolution) and names B's cost explicitly; the diaboli should reject any contract that diverges from
  the shipped guidance-only fallback.
- *Re-bumping the skill count.* The skill-count badge is **already 36** (S1). Mitigation: AC-5/FR-5
  assert it stays 36; the diaboli should reject any change to the `Skills-36` badge or the
  plugin-table "36 skills" cell.
- *Version under-bump.* Treating S7 as docs-only (patch) would under-bump — the `templates/CLAUDE.md`
  pointer is a behavioural change to a plugin file. Mitigation: §7.1 recommends **minor** in both hook
  branches.

### 9.4 Open questions

**None block S7.** Q4 — the Copilot CLI degradation contract — is **resolved here** (Option A,
recommended; surfaced for the human at the GATE). The only S7-internal decisions are the
**hook-ship** decision (§6 decision 1), the **heuristic signal** (§6 decision 2, if H1), and the
**verification split** (§6 decision 3) — all **surfaced for the GATE, not left open**: the spec
recommends and the human disposes.

**Flagged, not built (v1 restraint).** If the hook ships, **no threshold for the heuristic is asserted
as precise** — the firing constants are conservative tuning values, not a measured gate (cf. AGENTS.md
"no threshold before data"). A firmer signal (e.g. recording `ultracode` invocations, per the merged
affordances epic's invocation recorder) could sharpen the heuristic in a future slice; flagged here so
the coarseness is deliberate, not an oversight.

---

## 10. References

- Umbrella spec: `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md` (read-first
  runtime-scope note; §2 INV-1/INV-2; **D9**; §5 esp. **§5.5 Copilot degradation**; §6; **§7
  open-question 4** — Copilot CLI degradation, dispositioned here).
- Slicing record: `docs/superpowers/slices/dynamic-workflows-alignment.md` (Runtime scope — Claude
  Code only; the **S7** entry — Copilot degradation contract + whether the advisory Stop hook ships;
  the `independence` lens).
- Merged precedents (S1–S6): `docs/superpowers/specs/2026-06-22-dynamic-workflows-s1-skill-design.md`;
  `…-s2-templates-design.md`; `…-s3-enforcer-fanout-design.md`;
  `…-s4-adversarial-deepresearch-design.md`;
  `docs/superpowers/specs/2026-06-23-dynamic-workflows-s5-orchestrator-routing-design.md`;
  `…-s6-reflection-mining-design.md` (the deterministic-vs-agent-backed/observational verification
  split; the line-wrap caution; the test-wiring pattern).
- Test pattern: `tdad_tests/tests/test_s6_reflection_mining_structural.py` (the section-slicing
  structural-content test + two-word-phrase split convention); `.github/workflows/tdad-tests-fast.yml`
  (the test-wiring pattern, lines 76–78 — the S6 step S7 mirrors).
- Target files S7 modifies: `README.md` (the new Dynamic Workflows section + the version bump, badge,
  table cell; the skill-count badge stays 36); `CLAUDE.md` (root — the skill pointer);
  `ai-literacy-superpowers/templates/CLAUDE.md` (the skill pointer); `CHANGELOG.md` (the new
  `## 0.64.0 — 2026-06-23` entry); `ai-literacy-superpowers/skills/dynamic-workflows/references/governance.md`
  and/or `…/SKILL.md` (the Option A contract statement); `.claude-plugin/marketplace.json` and
  `ai-literacy-superpowers/.claude-plugin/plugin.json` (version locations); **if the hook ships:**
  `ai-literacy-superpowers/hooks/hooks.json` + a new `ai-literacy-superpowers/hooks/scripts/<name>.sh`.
- Existing advisory-hook precedents the new hook mirrors:
  `ai-literacy-superpowers/hooks/scripts/reflection-prompt.sh` and `curation-nudge.sh` (the
  `systemMessage`, `exit 0`, never-block, `set -euo pipefail` shape).
- Shipped skill the contract documents: `ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md`
  (the "Runtime scope — Claude Code only" section already states guidance-only on Copilot — Option A
  is the consistent resolution).
- AGENTS.md decisions consulted: "hook scripts never block, only warn" (the advisory-hook contract);
  the cognitive-reservoir advisory-only generalisation (advisory mechanisms never block / persist
  human-state); "recommended option is a hypothesis for the diaboli to stress" STYLE note
  (closed-contract pre-listing, applied in §5/§6); "no threshold before data" (no precise heuristic
  threshold for the hook in v1); the BSD/GNU shell-portability lesson (the macOS+Linux constraint on
  any new `.sh`).
- Runtime API (authoritative): <https://code.claude.com/docs/en/workflows>.
