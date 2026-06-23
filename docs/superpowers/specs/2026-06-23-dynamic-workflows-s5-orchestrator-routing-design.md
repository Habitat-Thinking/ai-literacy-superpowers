# Specification — Dynamic Workflows S5: Orchestrator Classify-and-Act Routing

**Plugin:** `ai-literacy-superpowers` (Habitat-Thinking)
**Slice:** S5 of the Dynamic Workflows Alignment epic (D4 — the largest behavioural change)
**Umbrella spec:** `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
**Slicing record:** `docs/superpowers/slices/dynamic-workflows-alignment.md` (§ S5)
**Issue:** <https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/442>
**Depends on:** S1 (#438, merged) — the `dynamic-workflows` skill + election rubric; S2 (#439, merged) — the workflow templates + the INV-1/INV-2 firewall; S3 (#440, merged) and S4 (#441, merged) — the proven workflow-mode pattern and the deterministic structural-test shape S5 reuses
**Spec status:** Draft for implementation
**Spec version:** 0.1.0
**Owner:** Russ Miles / Habitat Thinking
**Branch:** `dynamic-workflows-s5-orchestrator-routing`

> **Implementer note (read first).** This slice adds a **classification step before the
> existing pipeline** in the `orchestrator` agent and surfaces the selected route in the
> `superpowers-status` dashboard. It ships **no new component** — it modifies one agent file
> and one command file (plus version/docs surfaces). It does **not** rewrite any
> `*.workflow.js` template; where a non-static route spawns a workflow, the orchestrator
> **ADAPTs** the relevant S2-shipped template per run. The *exact* runtime function names for
> spawning subagents and coordinating panels are **not authoritative in this spec** — consult
> <https://code.claude.com/docs/en/workflows> as the source of truth and treat any call shape
> here as ADAPTABLE pseudocode, not a frozen API.
>
> **Runtime scope — Claude Code only.** Dynamic workflows are a Claude Code runtime
> capability, **not transferable** to GitHub Copilot CLI or any other coding agent — those
> trees have no workflow runtime. The plugin ships to both trees, so the **non-static routes**
> this slice adds are **Claude-Code-gated**: where the runtime exists and the opt-in flag is
> set, the orchestrator may route to a workflow; where it does not (Copilot CLI, other
> agents), or where the flag is off, the classifier **selects the existing static pipeline and
> never errors or pretends to route** — there is no degraded behaviour because the static path
> is the universal fallback. The classification step must restate this boundary explicitly
> (umbrella §5.5 / slicing-record runtime-scope note). The precise Copilot degradation
> *contract* (guidance-only vs omit) is open-question 4, resolved in S7, and is **not** decided
> here.

---

## 1. Context and motivation

The `orchestrator` runs a **fixed static pipeline** for every task:
`carpaccio → GATE → spec-writer → diaboli → cartographer → Plan Approval GATE → tdd-agent →
implementer(s) → code-reviewer → MAX_REVIEW_CYCLES=3 GUARDRAIL → diaboli (code) → Integration
Approval GATE → integration-agent`. Umbrella **D4** observes that not every task needs this
chain, and that some task *types* are better served by a dynamic workflow shape:

| Task type | Better-fit route | Why |
| --- | --- | --- |
| ordinary coding | **the existing static pipeline** | The default; works for all edge cases; nothing about it changes |
| design / naming (taste-based) | **tournament** (rubric-bearing judge) | Taste questions resolve by comparing candidates against an explicit rubric, not by a single linear pass |
| debugging / flaky-test / incident | **root-cause investigation** | ≥3 independent hypotheses from **disjoint evidence** + a panel of verifiers/refuters defeats premature single-hypothesis fixation |
| large backlog | **triage-at-scale under quarantine (INV-2)** | Untrusted external content (issues, third-party PRs) is read by low-privilege agents; only trusted agents act |

**The load-bearing decision (resolved, open-question 2).** For the first release the
tournament / root-cause / triage routes are **opt-in behind an explicit flag**, and the
**static pipeline is the SOLE default**. A routine task — *and ANY task when the flag is not
set* — takes the existing static path with **zero extra compute and zero behaviour change**.
The §7 over-orchestration risk names drift toward "everything is a workflow" as a **regression**
to guard against. With the flag off, the classifier is a **no-op that selects static**: it
costs nothing, decides nothing, and the pipeline runs exactly as it does today. This
conservatism is the whole point of S5 — it introduces a *route* without changing the *default*.

The slicing record records the `independence` lens: S5 is the largest behavioural change but
lands without blocking S6 or S7, and is deliberately sequenced *after* S3/S4 proved the
workflow-mode pattern so the blast radius is contained.

S5 wires the orchestrator to ADAPT the relevant S2 templates where a non-static route spawns a
workflow; it invents no new template and edits no template (per the AGENTS.md "a consumer never
mutates the contract it consumes" decision). On every route — static or otherwise — the
**Plan Approval GATE and the `MAX_REVIEW_CYCLES=3` GUARDRAIL remain in force** (umbrella D4
acceptance), as do INV-1 (routes propose; never write durable artefacts) and INV-2 (triage
quarantine).

---

## 2. Scope

### 2.1 In scope (this slice)

1. **`orchestrator.agent.md` gains a "Task classification" step** placed **before** the
   existing pipeline dispatches, integrating cleanly with **"Your first action on every task"**
   and the carpaccio step 0 (it runs as a pre-pipeline classification that *selects which
   pipeline runs*, not a new agent dispatch in the chain). The step declares:
   - **The explicit opt-in flag / mechanism** (see §6 decision 1) — how routing is enabled.
     **When the flag is absent or off, routing is a no-op: the classifier selects the static
     pipeline.**
   - **The four route types and their triggers**:
     - **ordinary coding → the existing static pipeline (the DEFAULT branch — unchanged
       behaviour).**
     - **design / naming (taste-based) → a tournament with a rubric-bearing judge.**
     - **debugging / flaky-test / incident → root-cause investigation** (≥3 independent
       hypotheses from **disjoint evidence** + a panel of verifiers/refuters).
     - **large backlog → triage-at-scale under quarantine (INV-2)** (untrusted external content
       read by low-privilege agents; trusted agents act).
   - **The static-default supremacy rule, stated three ways**: the **default**, the **flag-off**
     case, and the **ambiguous-classification** case **all select the static pipeline**. There
     is no route a routine task can fall into by accident.
   - **The GATE/GUARDRAIL invariant** — the **Plan Approval GATE** and the
     **`MAX_REVIEW_CYCLES=3` GUARDRAIL** remain in force **on every route** (umbrella D4
     acceptance). No route may bypass, weaken, or multiply them.
   - **The Claude-Code-only runtime scope + the non-erroring fallback** — the non-static routes
     require the Claude Code runtime; on a tree without it (or with the flag off) the classifier
     **selects the static pipeline and never errors**. The static path is the universal
     fallback.
   - **INV-1** — every route is **propose-only**: a workflow a route spawns **never writes a
     durable curated artefact** (`HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `MODEL_ROUTING.md`);
     keep-worthy discovery flows through the existing human-curation gate. **INV-2** — the
     triage route reads untrusted/public content only with **low-privilege agents**, and only
     **separate trusted agents act** on it.
2. **`commands/superpowers-status.md` surfaces the route taken** in the dashboard (see §6
   decision 3) — a new sub-section reporting which route the most-recent orchestrator run
   selected, or that routing is **off by default** when no opt-in signal is present.
3. **The INV-1 boundary preserved.** The orchestrator's `tools` list is **unchanged**; the
   classification step adds no write capability. Any workflow a non-static route spawns is
   propose-only, exactly as S3/S4 established for their workflow modes.
4. **Supporting CI / version / docs surfaces** (see §7): the minor bump **`0.61.0 → 0.62.0`**
   across the five CI-enforced locations + the README table cell, and reference/how-to
   touch-ups now that the orchestrator carries a routing step.

### 2.2 Out of scope (explicitly deferred — do not blur)

| Deferred concern | Owning slice | Why not here |
| --- | --- | --- |
| `harness-enforcer` / `code-reviewer` / `assessor` / `harness-auditor` workflow modes | **S3 (#440)**, **S4 (#441)**, both merged | S5 reuses their proven pattern; it does not re-touch those agents |
| `reflect --mine` mode + staging artefact | **S6 (#443)** | Riding open-question 3 |
| README "Dynamic Workflows" prose section, advisory Stop hook, **Copilot degradation contract** | **S7 (#444)** | Per umbrella D9; open-question 4. S5 restates the Claude-Code-only boundary for its own behaviour but does **not** fix the degradation contract |
| Skill-count / component-count badges | **unchanged** | S5 adds **no** new skill, agent, or command — only modifies two existing files. The component-count badges do not move |
| Editing/rewriting any `*.workflow.js` template | **S2 (#439, merged)** | S5 *adapts and points at* templates where a non-static route spawns one; per the AGENTS.md "consumer never mutates the contract it consumes" decision, S5 edits no template |
| Building the tournament / root-cause / triage routes *on by default* | **out of scope by disposition** | Open-question 2 is resolved **opt-in, static-default**. Default-on is explicitly the regression S5 guards against |

**Boundary rule.** S5 modifies exactly **two files** —
`ai-literacy-superpowers/agents/orchestrator.agent.md` and
`ai-literacy-superpowers/commands/superpowers-status.md` — plus the version/docs surfaces in
§7. It ships **no new component**, **no new CI workflow** (it *wires a new test file into the
existing* `tdad-tests-fast.yml`), and **no edit to any S2 template**.

---

## 3. User story

> **As an** engineer dispatching the orchestrator on a task that is **not** ordinary coding —
> a taste-based naming decision, a flaky-test investigation, or a large untrusted backlog — **I
> want** the orchestrator, **when I have explicitly opted in**, to route the task to the
> workflow shape that fits it (tournament / root-cause / triage), **so that** the work gets the
> structure it needs; **and as the same engineer on a routine task, or with the flag off, I
> want** the orchestrator to run the existing static pipeline with **zero extra compute and
> zero behaviour change**, **so that** introducing routing never makes my everyday work slower
> or more expensive — the static pipeline stays the sole default and the GATE and
> `MAX_REVIEW_CYCLES=3` GUARDRAIL hold on every route.

This is the umbrella's **over-orchestration risk** held at bay by design: routing is a
deliberately conservative, opt-in v1, and the static path is the universal fallback that any
task lands on by default, by flag-off, or by ambiguity.

---

## 4. Acceptance scenarios (Given / When / Then)

Each scenario carries its **verification-slot** tag from the umbrella taxonomy:
*deterministic* (CI-checkable / Layer-0–1 structural), *agent-backed* (a runtime / Layer-2–3
behavioural property), or *unverified* (declared intent). Scenarios trace to umbrella **D4**
acceptance. The tdd-agent turns the deterministic and structurally-assertable agent-backed
scenarios into failing checks first.

### From D4 — the live routing behaviour (agent-backed)

**AC-1 *(agent-backed; structural shadow AC-5/AC-6)* — routine coding task selects the static pipeline.**
**Given** a routine single-file coding task (and any flag state),
**When** the orchestrator classifies it,
**Then** it **selects the existing static pipeline** — **no workflow is spawned, no extra
compute is spent**, and the pipeline runs exactly as today.
*(Slot note: live classification of a given task is a runtime/behavioural property — not
assertable from a static file read. Its structural shadow is AC-5 (the static-default rule is
declared) and AC-6 (the four routes + triggers are declared). The behavioural assertion stands
as a Layer-2/3 scenario the tdd-agent may add.)*

**AC-2 *(agent-backed; structural shadow AC-6)* — taste-based task routes to a tournament.**
**Given** the opt-in flag is set, the Claude Code runtime is present, and a **taste-based task**
(naming / design),
**When** the orchestrator classifies it,
**Then** it routes to a **tournament with a rubric-bearing judge** agent.
*(Slot note: runtime/behavioural; structural shadow is AC-6 declaring the tournament route and
its trigger.)*

**AC-3 *(agent-backed; structural shadow AC-6)* — flaky-test / incident task routes to root-cause investigation.**
**Given** the opt-in flag is set, the runtime is present, and a **flaky-test or incident** task,
**When** the orchestrator classifies it,
**Then** it routes to **root-cause investigation** with **≥3 independent hypotheses from
disjoint evidence** and a panel of verifiers/refuters.
*(Slot note: runtime/behavioural; structural shadow is AC-6 declaring the root-cause route, its
trigger, and the ≥3-disjoint-evidence-hypotheses + verifier/refuter-panel shape.)*

**AC-4 *(unverified, declared)* — the Plan Approval GATE and MAX_REVIEW_CYCLES=3 GUARDRAIL hold on every route.**
**Given** any route the orchestrator selects (static, tournament, root-cause, triage),
**When** the route runs,
**Then** the **Plan Approval GATE** and the **`MAX_REVIEW_CYCLES=3` GUARDRAIL** remain in force
— no route bypasses, weakens, or multiplies them.
*(Slot note: declared intent — the live enforcement of the gate/guardrail across a real
non-static route is a pipeline-level behavioural property, not provable from the agent doc
alone. Its structural shadow is AC-7 declaring that every route holds the GATE and GUARDRAIL.
Must **not** be over-promised as deterministic.)*

### Structural declarations on the orchestrator doc (the deterministic shadows of D4)

**AC-5 *(deterministic, structural)* — the classification step exists, opt-in flag declared, static-is-default declared.**
**Given** `orchestrator.agent.md`,
**When** it is read,
**Then** it contains a **task-classification step placed before the pipeline dispatches** that
declares the **explicit opt-in flag mechanism** (the §6 decision-1 mechanism, named explicitly
— not "somehow enabled") and states that the **static pipeline is the sole default**, selected
when the **flag is absent/off**, when the task is **ordinary coding**, and when **classification
is ambiguous**.

**AC-6 *(deterministic, structural)* — the four routes and their triggers are declared.**
**Given** the classification step,
**When** it is read,
**Then** it declares **all four** routes and their triggers: ordinary coding → **static
pipeline (default)**; taste-based (naming/design) → **tournament with a rubric-bearing judge**;
debugging/flaky-test/incident → **root-cause investigation (≥3 independent hypotheses from
disjoint evidence + a verifier/refuter panel)**; large backlog → **triage-at-scale under INV-2
quarantine**, and that any non-static route **adapts the relevant `*.workflow.js` template by
relative path** (ADAPT, not run verbatim).

**AC-7 *(deterministic, structural)* — the GATE/GUARDRAIL-hold invariant is declared on every route.**
**Given** the classification step,
**When** it is read,
**Then** it states explicitly that the **Plan Approval GATE** and the **`MAX_REVIEW_CYCLES=3`
GUARDRAIL** remain in force **on every route** (static and non-static alike) — no route bypasses
or weakens them (umbrella D4 acceptance).

**AC-8 *(deterministic, structural)* — the Claude-Code-only scope + non-erroring static fallback are declared.**
**Given** the classification step,
**When** it is read,
**Then** it states that the **non-static routes require the Claude Code runtime** and that on a
tree without it — **or whenever the opt-in flag is off** — the classifier **selects the static
pipeline and never errors** (the static path is the universal fallback; umbrella §5.5 /
runtime-scope note).

### Cross-cutting — INV-1 and INV-2

**AC-9 *(deterministic, structural)* — every route is propose-only; the orchestrator's tool set is unchanged; triage quarantines untrusted content.**
**Given** `orchestrator.agent.md` frontmatter and the classification step,
**When** they are read,
**Then**:
- the orchestrator's **`tools` list is unchanged** (the classification step adds no new write
  capability) and the step states every route is **propose-only** — any workflow a route spawns
  **never writes a durable curated artefact** (`HARNESS.md`, `AGENTS.md`, `CLAUDE.md`,
  `MODEL_ROUTING.md`); keep-worthy discovery flows through the human-curation gate (**INV-1**);
- the **triage-at-scale route** states that untrusted/public content is read **only by
  low-privilege agents** and that **only separate trusted agents act** on it (**INV-2**
  quarantine).

### From D4 — the status surface

**AC-10 *(deterministic, structural)* — superpowers-status surfaces the route taken (or that routing is off by default).**
**Given** `commands/superpowers-status.md`,
**When** it is read,
**Then** it documents a section/check that surfaces **which route the most-recent orchestrator
run selected** (static / tournament / root-cause / triage), or reports that **routing is opt-in
and off by default** when no opt-in signal is present (the §6 decision-3 shape).

---

## 5. Functional requirements

Numbered and testable; each maps to one or more acceptance scenarios in §8.

- **FR-1.** `orchestrator.agent.md` contains a **task-classification step placed before the
  pipeline dispatches**, integrating with "Your first action on every task" / the carpaccio
  step 0. *(AC-5)*
- **FR-2.** The step declares the **explicit opt-in flag mechanism** (§6 decision 1, named) and
  states that with the **flag absent/off the classifier is a no-op selecting the static
  pipeline**. *(AC-5, AC-8)*
- **FR-3.** The step states the **static pipeline is the sole default**, selected for **ordinary
  coding**, **flag-off**, and **ambiguous classification** alike. *(AC-5; structural shadow of
  AC-1)*
- **FR-4.** The step declares the **four routes and triggers** — static (default) / tournament
  (rubric-bearing judge) / root-cause (≥3 independent hypotheses from disjoint evidence + a
  verifier/refuter panel) / triage-at-scale under INV-2 — and that any non-static route
  **adapts the relevant `*.workflow.js` template by relative path** (ADAPT, not verbatim).
  *(AC-6; structural shadow of AC-2, AC-3)*
- **FR-5.** The step states the **Plan Approval GATE** and the **`MAX_REVIEW_CYCLES=3`
  GUARDRAIL** remain in force **on every route** (umbrella D4 acceptance). *(AC-7; structural
  shadow of AC-4)*
- **FR-6.** The step states the **Claude-Code-only runtime scope** and the **non-erroring static
  fallback** (runtime absent or flag off → static, never error). *(AC-8)*
- **FR-7.** The orchestrator's `tools` list is **unchanged** and the step states every route is
  **propose-only** — no workflow writes a durable curated artefact (INV-1). *(AC-9)*
- **FR-8.** The **triage route** declares **INV-2 quarantine** — untrusted content read by
  low-privilege agents, trusted agents act. *(AC-9)*
- **FR-9.** `commands/superpowers-status.md` documents a section/check that **surfaces the route
  the most-recent orchestrator run selected**, or reports **routing off by default** when no
  opt-in signal is present (§6 decision 3). *(AC-10)*
- **FR-10.** The plugin version is bumped **`0.61.0 → 0.62.0`** across all five CI-enforced
  locations (§7.1), and the human-facing README plugin-table cell is updated. *(CI: Version
  Check)*
- **FR-11.** The how-to guide(s) and the agents/commands reference entries for the orchestrator
  and `superpowers-status` are checked and updated for the new routing step (§7.3).
  *(docs-impact)*

---

## 6. Decisions surfaced at the GATE

Per the AGENTS.md STYLE note, a recommendation is a **hypothesis for the spec-mode diaboli to
stress**, not a default to confirm — most acutely where the slice touches a **closed contract**
(here: the static-default supremacy rule and the GATE/GUARDRAIL invariant the orchestrator must
not weaken). The three decisions below are surfaced for the human; the spec-writer recommends
but does not silently choose.

**Pre-listed contract surfaces a recommendation could break** (so the diaboli's scrutiny is
scoped): (1) the orchestrator's existing GATE/GUARDRAIL steps (Slice Adjudication, Plan
Approval, Integration Approval, `MAX_REVIEW_CYCLES=3`) — no route may bypass them; (2) the
`superpowers-status` Section/summary-line contract (Sections 1–8 + the `[OK/WARNING/MISSING]`
output block) — a new surface must not collide with the existing disposition-counting algorithm;
(3) the INV-1 four-artefact denylist and the INV-2 quarantine rule — a route must not relax
either; (4) the static-default supremacy rule — the flag-off and ambiguous cases must both fall
to static.

### Decision 1 — The explicit opt-in flag mechanism

The disposition is settled: routing is **opt-in behind an explicit flag**, static is the sole
default. What is **not** yet decided is **how the flag is expressed**. Mirroring the resolved
S3/S4 pattern (the threshold knobs both chose an optional `HARNESS.md` field), three options:

- **Option M1 — a documented optional `HARNESS.md` field the orchestrator reads (RECOMMENDED),
  e.g. `orchestrator-routing: enabled`** in a `Workflow mode` block (or the existing
  Constraints/Status preamble), defaulting to **off** (static-only) when absent.
  *Strength:* this is the **established epic precedent** — S3's `Workflow fan-out threshold` and
  S4's `Deep-research threshold` both chose an optional `HARNESS.md` field read by the agent,
  matching how every per-project knob in this plugin works (cf. the `fan-out-threshold`
  precedent). `HARNESS.md` is **durable and human-curated**, so opting in is a curated act
  consistent with INV-1 (the human sets it; the orchestrator only reads it). A missing/garbled
  field **safe-defaults to off** — the conservative static path — rather than erroring, which is
  exactly the v1 conservatism the disposition demands. No new file, no new schema, one
  consistent knob style across the whole epic. *Diaboli should stress:* is a missing/garbled
  field guaranteed to read as off (it must — default-off is the conservative direction)? Does
  the orchestrator's read of `HARNESS.md` risk the firewall (no — the orchestrator *reads* a
  durable artefact; it is not a *workflow* spelling a durable filename in executable code, so
  the INV-1 firewall does not apply to the agent's own read).
- **Option M2 — a value in `MODEL_ROUTING.md`'s workflow-election section.** S1 placed token
  budgets and tiering there, so "is routing on?" is arguably workflow-election policy too.
  *Weakness:* it diverges from the S3/S4 `HARNESS.md`-field precedent the epic has now set twice,
  splitting the orchestrator's opt-in across a different durable file from where S3/S4 put their
  knobs. *Tenable* if the human prefers **all** workflow-election policy (budgets, tiers,
  routing-on) in one place — but that is a cross-epic consolidation, larger than S5.
- **Option M3 — a command flag / env var (e.g. `--route` on the dispatch).** *Weakness:* an
  ephemeral per-invocation flag is **not curated** and leaves no durable record of the project's
  stance; it also has no natural home in this plugin's agent-dispatch model (the orchestrator is
  dispatched by description, not a CLI with flags). Inconsistent with every other per-project
  knob. *Rejected as the resolution* unless the human wants per-run rather than per-project
  opt-in (then state it honestly as a per-invocation toggle with no persisted default).

**Recommendation: M1** — a documented optional `HARNESS.md` field (e.g.
`orchestrator-routing: enabled`), **default off** when absent. It matches the S3/S4 epic
precedent exactly, keeps the opt-in curated and durable, and safe-defaults to the conservative
static-only path. The diaboli should confirm the missing-field default is **off**, that this
does not smuggle the flag into the firewall's scope, and that the field name does not collide
with the existing S3/S4 `HARNESS.md` workflow-mode fields.

### Decision 2 — The verification split (deterministic structural vs agent-backed behavioural)

Mirroring S3 decision 2 / S4 decision 2: this repo's deterministic layer **reads files and
matches structure**; it does **not** dispatch the orchestrator or classify a live task. So:

- **Deterministically assertable (structural, Layer-0/1) — the declarations.** That the
  orchestrator doc **declares**: the classification step exists before the pipeline (AC-5); the
  opt-in flag mechanism + static-is-default (flag-off / ordinary / ambiguous) (AC-5); the four
  routes + triggers + adapt-by-relative-path (AC-6); the GATE/GUARDRAIL-hold-on-every-route
  invariant (AC-7); the Claude-Code-only scope + non-erroring static fallback (AC-8); the
  propose-only/INV-1 boundary + tools-unchanged + INV-2 triage quarantine (AC-9); and that
  `superpowers-status` **documents** the route surface (AC-10). These are file-read assertions a
  structural test checks mechanically — the **honest deterministic shadow** of D4.
- **Agent-backed / behavioural only (not deterministic) — the live classification.** That a real
  run **classifies a routine task to static** (AC-1), a **taste task to a tournament** (AC-2),
  and a **flaky-test/incident task to root-cause** (AC-3) are runtime properties of an actual
  orchestrator dispatch. They are **agent-backed**, observed at runtime, and must **not** be
  promised as deterministic.
- **Unverified / declared (AC-4)** — the **GATE/GUARDRAIL holding across a real non-static
  route** is a pipeline-level guarantee declared in the agent doc; its structural shadow is AC-7
  (the section *states* it holds), but the live enforcement itself is pipeline-level behaviour,
  not provable from the doc alone.

**Recommendation:** the tdad-scenario set is **predominantly structural** (AC-5, AC-6, AC-7,
AC-8, AC-9, AC-10 as Layer-0/1 file-read assertions), with AC-1, AC-2, AC-3 standing as
**declared agent-backed** behavioural scenarios and AC-4 as **unverified/declared**. This is the
same realistic split S3 and S4 landed. The diaboli should stress whether any property currently
tagged structural actually requires a live dispatch (it should not — each is a file-read), and
whether AC-1's "selects the static pipeline" risks being over-promised as deterministic (it must
not — the *declaration* of static-default is structural; the *live selection* is agent-backed).

### Decision 3 — How superpowers-status surfaces the route

D4 says "surface which route was taken in the dashboard" but fixes neither the data nor the
shape. The dashboard is a **read-only health snapshot** of files on disk — it does not have a
live event stream of orchestrator dispatches — so the surface must be realistic about what it
can actually read. Options:

- **Option S1 — "routing posture" line + last-route, read from durable signals (RECOMMENDED).**
  A short sub-section (folded into Section 3 *Agent team*, or a new compact "Workflow routing"
  line in the output block) that reports two things: (a) the **routing posture** — read from the
  `orchestrator-routing` `HARNESS.md` field (decision 1): **`opt-in, off by default`** when
  absent/off, **`enabled`** when set; and (b) **the most-recent route taken**, *if* a durable
  trace exists (e.g. the latest entry in a routing-trace the orchestrator already writes, or the
  most recent spec/objection record's context) — otherwise **`last route: unavailable (no
  recent run)`**. *Strength:* honest about the dashboard's read-only nature; degrades gracefully
  to "off by default / unavailable" with no fabrication; reuses the same `HARNESS.md` field
  decision 1 introduces, so no new state surface. *Diaboli should stress:* does a durable
  last-route trace actually exist for the dashboard to read, or is "most-recent route" a value
  no file carries (in which case the surface honestly reports posture only, not last-route)?
- **Option S2 — a per-route counter (tournament: N, root-cause: N, triage: N, static: N).**
  *Weakness:* requires a **persisted per-route tally** the orchestrator must maintain — new
  durable state with its own GC/staleness surface, and the §289 disposition-counting machinery
  shows how a naive count drifts. **Premature** for a deliberately conservative v1 where the
  routes are opt-in and may rarely fire; no data yet exists on what a healthy distribution looks
  like (cf. the AGENTS.md "no threshold before data" diaboli decision). *Tenable later* once
  routing has run enough to make counts meaningful.
- **Option S3 — "routing: opt-in, off by default" posture line only (no last-route).**
  *Acceptable minimal form* — just report the posture from the `HARNESS.md` field with no
  attempt at last-route. *Weakness:* it answers "is routing on?" but not D4's "which route was
  taken", so it under-delivers the deliverable unless decision-1's field is the only honest
  durable signal available (in which case S3 *is* S1 minus the last-route half).

**Recommendation: S1** — a compact "Workflow routing" surface reporting **posture** (read from
the decision-1 `HARNESS.md` field: `opt-in, off by default` vs `enabled`) **plus** the
**most-recent route taken when a durable trace exists**, degrading to `unavailable (no recent
run)` otherwise. It honours D4's "surface which route was taken" without inventing a persisted
counter, and reuses decision-1's field rather than adding state. The diaboli should stress
whether a last-route trace genuinely exists for the dashboard to read — and if it does not,
whether S5 should **fall back to S3** (posture-only) honestly rather than promise a last-route
the snapshot cannot compute. **Keep this surface descriptive — no threshold, no
`WARNING` state** (consistent with the AGENTS.md "no threshold before data" decision and the
Diaboli-panel precedent).

### 6.1 Decision summary for the GATE

| Decision | Options | Recommendation |
| --- | --- | --- |
| Opt-in flag mechanism | M1 optional `HARNESS.md` field `orchestrator-routing: enabled` (default off) / M2 `MODEL_ROUTING.md` workflow-election value / M3 command flag / env var | **M1** — optional `HARNESS.md` field, **default off** — matches the S3/S4 epic precedent and safe-defaults to static |
| Verification split | all-deterministic / **structural declarations + agent-backed live classification + unverified GATE/GUARDRAIL-hold** | **structural declarations are the deterministic shadow; live route selection stays agent-backed; GATE/GUARDRAIL-hold stays unverified/declared** |
| superpowers-status route surface | **S1 posture + last-route-when-traceable** / S2 per-route counter / S3 posture-only | **S1** — posture (from the decision-1 field) + most-recent route when a durable trace exists, else `unavailable`; descriptive, no threshold/WARNING; fall back to S3 honestly if no last-route trace exists |

---

## 7. CI, version, and docs checklist

### 7.1 Version bump — a behavioural change to an existing agent + command (minor)

Adding a classification/routing step to the `orchestrator` and a route surface to
`superpowers-status` is a **behavioural addition to existing components** → **minor bump
`0.61.0 → 0.62.0`** (current version confirmed **`0.61.0`** in `plugin.json`, the `README.md`
badge + table cell, the `CHANGELOG.md` top heading, and both `marketplace.json` `plugin_version`
and the `ai-literacy-superpowers` `plugins[].version` entry). The `Version Check` CI enforces
**five** locations (per CLAUDE.md / the live `version-check.yml`). Update **every** one:

1. `ai-literacy-superpowers/.claude-plugin/plugin.json` — `"version"` (canonical; `0.61.0` →
   `0.62.0`)
2. `README.md` — shields.io **badge** `ai--literacy--superpowers-v0.62.0` (line 6; currently
   `v0.61.0`)
3. `CHANGELOG.md` — new top heading `## 0.62.0 — 2026-06-23`
4. `.claude-plugin/marketplace.json` — top-level `plugin_version` (currently `0.61.0`; owned by
   ai-literacy-superpowers PRs)
5. `.claude-plugin/marketplace.json` — the `ai-literacy-superpowers` `plugins[].version` entry
   (currently `0.61.0`)

Also update, for human-facing consistency (**not** CI-enforced): the `README.md` plugin-table
row cell (`| v0.61.0 |` → `| v0.62.0 |`, line 31).

> The marketplace listing `version` (`0.4.0`) does **not** change — S5 alters no listing
> contract (no description/keyword/permission/plugins-array/source change). The component-count
> badges (`Skills-36`, `Agents-16`, `Commands-28`) do **not** change — S5 adds no new component,
> only modifies two existing files.

If a rebase surfaces a `plugin_version` conflict from a non-`ai-literacy-superpowers` PR, take
main's value verbatim (CLAUDE.md Marketplace-versioning rule) — this PR owns the top-level
pointer only because it bumps this plugin.

Before committing, grep for the **old** version to surface every spot at once:

```text
grep -rn 'v0\.61\.0\|0\.61\.0' README.md .claude-plugin/marketplace.json \
  ai-literacy-superpowers/.claude-plugin/plugin.json CHANGELOG.md
```

### 7.2 CI gates

- **`spec-first-check`** — satisfied by **this spec being the first commit** on branch
  `dynamic-workflows-s5-orchestrator-routing`. No exemption label; this is feature work.
- **`tdad-scenario-check`** — S5 **modifies** an existing agent and command rather than adding
  new components. The gate fires on *added* components, so it does **not strictly force** new
  scenarios for a modification. **However**, this is a behavioural addition and warrants
  scenarios. The `orchestrator` has **no scenario directory yet** —
  `tdad_tests/scenarios/agents/orchestrator/` **does not exist** (confirmed; the agent file
  carries an explicit comment recording the §A2.6 exemption). The **tdd-agent will create it**
  and author the structural scenarios (AC-5 through AC-10), mirroring the S3/S4 scenario sets
  under `tdad_tests/scenarios/agents/<agent>/`. Spec-writer **names** this so the tdd-agent has
  an unambiguous home and assertion set; spec-writer does **not** create the directory or any
  test file (spec-first discipline — no test files in this commit).
- **The deterministic content test** — the tdd-agent authors a new
  `tdad_tests/tests/test_s5_orchestrator_routing_structural.py`, mirroring
  `test_s3_enforcer_fanout_structural.py` and `test_s4_adversarial_deepresearch_structural.py`
  (a section-slicing helper that isolates the classification step in `orchestrator.agent.md`
  and the route surface in `superpowers-status.md`; phrase assertions per AC), and **wires it
  into the existing `.github/workflows/tdad-tests-fast.yml`** as a new step (a sibling of the
  existing `Run Layer 1 (dynamic-workflows S4 adversarial review + deep research)` step at
  lines 68–70). Spec-writer **notes** this; the tdd-agent authors and wires it. **Do not author
  tests in this commit.**
  - **Line-wrap caution (bit S3 twice and S4 twice).** Several assertions are **two-word
    phrases** the structural test will match literally — e.g. `static pipeline`, `rubric-bearing
    judge`, `disjoint evidence`, `Plan Approval`, `MAX_REVIEW_CYCLES`, `opt-in`,
    `Claude Code`, `low-privilege`. When the tdd-agent and implementer author the agent-doc
    prose, **keep these phrases unwrapped** (not split across a line break), or the literal
    match fails. This is a tdd/impl concern, not a spec-writer one — noted here so it is not
    rediscovered a fifth time.
- **`INV-1 firewall` (S2, existing)** — S5 modifies **no `*.workflow.js` template**, so the
  firewall is **not triggered by new template content**. The orchestrator's own *read* of
  `HARNESS.md` (the opt-in flag) is an agent behaviour, not a workflow spelling a durable
  filename in executable code, so it is outside the firewall's scope. (If the tdd-agent adds any
  fixture that is a `.workflow.js`, it must itself pass the firewall — but the recommended
  fixtures are structural scenarios, not workflows.)
- **`lint-markdown`** — the modified `orchestrator.agent.md`, `superpowers-status.md`, this spec,
  and any touched docs page must pass markdownlint (PreToolUse hook + CI).
- **`Choice cartographer` / objection gates** — this feature PR proceeds through the plugin's
  own pipeline (spec → diaboli → adjudicate → plan → implement → diaboli code-mode → adjudicate).
  Dispositions on any objection record must be resolved before the plan-approval GATE.

### 7.3 Docs-impact note (CLAUDE.md "Docs Site Review")

- **Reference (`docs-reference-parity-check`) — no NEW component, so no new entry forced.** S5
  adds no new skill/agent/command, so the parity gate is satisfied with no new heading. **But**
  the existing `### orchestrator` entry in
  `docs/plugins/ai-literacy-superpowers/reference/agents.md` should be **updated** to mention the
  new **task-classification / routing step** (opt-in, static-default), and the
  `### superpowers-status` entry in
  `docs/plugins/ai-literacy-superpowers/reference/commands.md` should be **updated** to mention
  the new **workflow-routing surface**, so the reference does not describe only the pre-routing
  behaviour. These are *consistency* updates, not parity requirements. (Per the S3/S4 lesson:
  do the declared touch-ups in the same PR.)
- **How-to (touch-up).** `docs/plugins/ai-literacy-superpowers/how-to/dynamic-workflows.md` (the
  orientation guide) should gain a short note that the `orchestrator` now elects a **routing
  step** above its opt-in flag (tournament / root-cause / triage), extending the S3/S4
  dogfooding line ("templates the plugin's own agents already adapt"). If a how-to for running
  the pipeline / orchestrator exists, add a short "routing is opt-in and off by default; the
  static pipeline is the default" note. Consistency touch-ups, not new pages.
- **Explanation / tutorials.** None required — no existing explanation page describes the
  orchestrator's pipeline as having *no* classification front-end in a way S5 would contradict;
  the classify-and-act concept already lives in the skill's `references/patterns.md` (S1). If an
  explanation page asserts "the orchestrator always runs the full static pipeline" as a fixed
  property, soften it to "the static pipeline is the default; routing is an opt-in front-end."

---

## 8. FR → acceptance-scenario mapping

| FR | Covered by | Slot |
| --- | --- | --- |
| FR-1 | AC-5 | deterministic (structural) |
| FR-2 | AC-5, AC-8 | deterministic (structural) |
| FR-3 | AC-5 (structural shadow of AC-1) | deterministic (structural) / agent-backed (AC-1) |
| FR-4 | AC-6 (structural shadow of AC-2, AC-3) | deterministic (structural) / agent-backed (AC-2, AC-3) |
| FR-5 | AC-7 (structural shadow of AC-4) | deterministic (structural) / unverified (AC-4) |
| FR-6 | AC-8 | deterministic (structural) |
| FR-7 | AC-9 | deterministic (structural) |
| FR-8 | AC-9 | deterministic (structural) |
| FR-9 | AC-10 | deterministic (structural) |
| FR-10 | (CI: Version Check) | deterministic |
| FR-11 | (docs-impact; reference + how-to touch-up) | deterministic (presence) |

**Agent-backed runtime scenarios** (not deterministic; see §6 decision 2):

- **AC-1** — routine task selects the static pipeline — runtime/behavioural; structural shadow
  is AC-5/AC-6 (FR-3/FR-4).
- **AC-2** — taste task routes to a tournament — runtime/behavioural; structural shadow is AC-6
  (FR-4).
- **AC-3** — flaky-test/incident task routes to root-cause — runtime/behavioural; structural
  shadow is AC-6 (FR-4).

**Unverified / declared:**

- **AC-4** — Plan Approval GATE + `MAX_REVIEW_CYCLES=3` GUARDRAIL hold on every route — declared;
  structural shadow is AC-7's section statement (FR-5). Must **not** be over-promised as
  deterministic.

---

## 9. Risks and open questions

**Risks.**

- *Over-orchestration (umbrella §7 — the critical risk for this slice).* The temptation is to
  let the classifier route routine work into a workflow. Mitigation: the **opt-in flag (default
  off)** makes the static pipeline the **sole default**, and the **static-default supremacy
  rule** routes flag-off, ordinary-coding, and ambiguous cases all to static. With the flag off
  the classifier is a no-op — zero extra compute, zero behaviour change. This is the §6
  decision-1 conservatism made load-bearing. The diaboli should reject any wording that lets a
  routine task fall into a non-static route, or that makes the flag default to on.
- *GATE/GUARDRAIL erosion.* A non-static route could be (mis)written to bypass the Plan Approval
  GATE or multiply `MAX_REVIEW_CYCLES`. Mitigation: AC-7/FR-5 declare the invariant explicitly
  on **every** route; the diaboli should stress any route description that omits or weakens it.
- *Over-promising determinism.* Live classification (AC-1/2/3) and the GATE/GUARDRAIL-hold
  (AC-4) are agent-backed/declared; tagging them deterministic would overclaim. Mitigation: §6
  decision 2 fixes the honest split, as in S3/S4.
- *Status surface promising data it cannot read.* The dashboard is a read-only file snapshot; a
  "last route taken" line risks promising state no file carries. Mitigation: §6 decision 3's S1
  reports **posture** from the decision-1 `HARNESS.md` field and degrades last-route to
  `unavailable` (or falls back to posture-only, S3) when no durable trace exists — no
  fabrication, no premature per-route counter.
- *Firewall scope confusion.* The opt-in mechanism (M1) has the orchestrator **read**
  `HARNESS.md`; a careless reading could think this trips the INV-1 firewall. Mitigation: the
  firewall scopes to **`*.workflow.js` templates spelling a durable filename in executable
  code**, not to an agent reading its own configuration. S5 edits no template.
- *Scenario-home omission.* `orchestrator` has no scenario directory; a behavioural addition
  without one leaves the new step unverified. Mitigation: §7.2 names the directory the tdd-agent
  must create, the structural assertion set, the new content test file, and its
  `tdad-tests-fast.yml` wiring — plus the two-word-phrase line-wrap caution.
- *Field-name collision.* The decision-1 `HARNESS.md` field must not collide with the S3/S4
  workflow-mode fields (`Workflow fan-out threshold`, `Deep-research threshold`). Mitigation: a
  distinct name (`orchestrator-routing`) and the diaboli confirming no collision.

**Open questions.** None block S5. The umbrella open questions ride later slices (Q3 staging →
S6, Q4 Copilot → S7) and are out of scope (§2.2). **Open-question 2 (route default) is resolved
opt-in, static-default**; the only S5-internal decisions are **how** the opt-in flag is
expressed (§6 decision 1), the verification split (§6 decision 2), and the status surface (§6
decision 3) — all **surfaced for the GATE, not left open**: the spec recommends and the human
disposes.

---

## 10. References

- Umbrella spec:
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
  (read-first runtime-scope note; §2 INV-1/INV-2; **D4**; §5; §6; §7 over-orchestration risk +
  open-question 2).
- Slicing record: `docs/superpowers/slices/dynamic-workflows-alignment.md`
  (Runtime-scope section; **S5** entry — routes are opt-in behind an explicit flag, static
  pipeline the sole default).
- Proven precedents (merged):
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-s3-enforcer-fanout-design.md` and
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-s4-adversarial-deepresearch-design.md`
  (the "Workflow mode" / opt-in-knob pattern; the `HARNESS.md`-field threshold precedent);
  `ai-literacy-superpowers/agents/harness-enforcer.agent.md` (the section pattern);
  `tdad_tests/tests/test_s3_enforcer_fanout_structural.py` and
  `tdad_tests/tests/test_s4_adversarial_deepresearch_structural.py` (the deterministic
  structural-content test pattern); `.github/workflows/tdad-tests-fast.yml` (the test-wiring
  pattern, lines 60–70).
- Shipped templates S5 ADAPTs where a non-static route spawns a workflow:
  `ai-literacy-superpowers/skills/dynamic-workflows/workflows/*.workflow.js` (the tournament /
  root-cause / triage shapes; consult `SKILL.md`'s template table for the authoritative names);
  `ai-literacy-superpowers/scripts/inv-firewall.sh` (the INV-1/INV-2 firewall; untouched by S5).
- Target files S5 modifies:
  - `ai-literacy-superpowers/agents/orchestrator.agent.md` (the task-classification step before
    the pipeline; "Your first action on every task" / carpaccio step 0 integration; the existing
    Plan Approval GATE and `MAX_REVIEW_CYCLES=3` GUARDRAIL the invariant must preserve).
  - `ai-literacy-superpowers/commands/superpowers-status.md` (the new workflow-routing surface).
- Runtime API (authoritative): <https://code.claude.com/docs/en/workflows>.
- AGENTS.md decisions consulted: the "recommended option is a hypothesis for the diaboli" STYLE
  note (closed-contract pre-listing, applied in §6); "a consumer never mutates the contract it
  consumes" (S5 adapts but does not edit the S2 templates); "no threshold before data" (the
  status surface stays descriptive, no WARNING state).
