# Specification — Dynamic Workflows S3: harness-enforcer Fan-out Upgrade

**Plugin:** `ai-literacy-superpowers` (Habitat-Thinking)
**Slice:** S3 of the Dynamic Workflows Alignment epic (D3 — flagged *highest leverage*)
**Umbrella spec:** `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
**Slicing record:** `docs/superpowers/slices/dynamic-workflows-alignment.md` (§ S3)
**Issue:** <https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/440>
**Depends on:** S1 (#438, merged) — the `dynamic-workflows` skill + election rubric; S2 (#439, merged) — the `enforcer-fanout.workflow.js` template + the INV-1/INV-2 firewall
**Spec status:** Draft for implementation
**Spec version:** 0.1.0
**Owner:** Russ Miles / Habitat Thinking
**Branch:** `dynamic-workflows-s3-enforcer-fanout`

> **Implementer note (read first).** This slice gives the existing `harness-enforcer`
> agent a **workflow mode** and documents the **fan-out slot** as a first-class
> verification slot. It ships **no new component** — it modifies one agent file and one
> SKILL.md. It does **not** rewrite the `enforcer-fanout.workflow.js` template (S2 shipped
> it); it **points the agent at it** and describes how the agent ADAPTs it per run. The
> *exact* runtime function names for spawning subagents and coordinating a synthesis
> barrier are **not authoritative in this spec** — consult
> <https://code.claude.com/docs/en/workflows> as the source of truth and treat any call
> shape here or in the template as ADAPTABLE pseudocode, not a frozen API.
>
> **Runtime scope — Claude Code only.** Dynamic workflows are a Claude Code runtime
> capability, **not transferable** to GitHub Copilot CLI or any other coding agent — those
> trees have no workflow runtime. The plugin ships to both trees, so the workflow mode this
> slice adds is **Claude-Code-gated**: where the runtime exists the enforcer can fan out;
> where it does not (Copilot CLI, other agents) the workflow-mode section is **guidance
> only** and the enforcer **falls back to its existing single-context behaviour — it must
> never error or pretend to fan out**. The agent's workflow-mode section must restate this
> boundary explicitly (umbrella §5.5 / slicing-record runtime-scope note). The precise
> Copilot degradation *contract* (guidance-only vs omit) is open-question 4, resolved in
> S7, and is **not** decided here.

---

## 1. Context and motivation

The `harness-enforcer` is the plugin's unified verification engine: given the constraints
in `HARNESS.md`, it runs each one (deterministic tool or agent-based review) in a **single
context window** and reports pass/fail with `file:line` findings. That single-context shape
is exactly the surface the umbrella spec names as **most exposed to agentic laziness** —
the enforcer's signature failure is the *"35 of 50 constraints checked"* lazy stop: it
tires, declares the job done after partial progress, and silently drops the rest.

D3 is flagged the **highest-leverage, smallest-blast-radius** deliverable in both umbrella
§4 and §6, and the slicing record records the `independence` lens: it is the
pattern-proving ground S4 reuses, yet it ships standalone and delivers value before any
other agent gains workflow mode.

S3 gives the enforcer a **workflow mode**. When the count of commit-scoped enforceable
constraints exceeds a **threshold (default 8, configurable per project — the resolved
open-question 1)**, the enforcer authors/adapts the S2-shipped
`enforcer-fanout.workflow.js` to:

- **fan out** one verifier subagent **per HARNESS.md rule**, each in its own clean context
  window (defeats the lazy stop — no single context carries all N checks);
- run a **skeptic persona** that adversarially reviews each *candidate* violation to
  suppress false positives;
- hold a **synthesis barrier** that waits for **all N** verifier results before any report
  can form — there is no "good enough" early stop.

Below the threshold, the enforcer keeps its **current single-context behaviour, unchanged**
— the default path for small `HARNESS.md` files is untouched, so no extra compute is spent
where it is not warranted (umbrella §6, compute discipline; over-orchestration is a
regression).

The pattern is **fan-out-and-synthesize + adversarial verification** — the same shape the
S2 `enforcer-fanout.workflow.js` template already encodes (its `Verify → Skeptic →
Synthesize` phases, its load-bearing synthesis barrier, and its `checked == confirmed-after-
skeptic` accounting). S3 wires the enforcer to that template; it does not invent a new one.

---

## 2. Scope

### 2.1 In scope (this slice)

1. **`harness-enforcer.agent.md` gains a "Workflow mode" section** stating:
   - **The threshold** — default **8** commit-scoped enforceable constraints; **configurable
     per project** (mechanism per §6, decided at the GATE).
   - **The trigger** — workflow mode engages **only** when the count of commit-scoped
     *enforceable* constraints (enforcement is `deterministic`, `agent`, or
     `deterministic + agent`; **`unverified` constraints are excluded** from the count, as
     they are skipped, not checked) **exceeds** the threshold.
   - **The fan-out + skeptic + synthesis-barrier shape** — one verifier subagent **per
     rule**; a skeptic persona that reviews each candidate violation; a synthesis barrier
     that waits for **all N** before reporting.
   - **The deterministic count-equality guarantee** — when the enforcer reports "all
     constraints checked", the count of verifier **results** equals the count of
     **enforceable** constraints. **No silent drop.** The guarantee is declared as an
     explicit, checkable statement in the agent doc (see §5, the verification split).
   - **How it adapts `enforcer-fanout.workflow.js`** — references the S2 template **by
     relative path**, hands the enforceable-constraint inventory to it as input (never by
     spelling a durable filename in workflow code — INV-1 / the firewall), and ADAPTs
     prompts, per-role model tiers, and the token budget per run rather than running it
     verbatim.
   - **The Claude-Code-only runtime scope + the fallback** — workflow mode requires the
     Claude Code runtime; on a tree without it the enforcer **falls back to its existing
     single-context behaviour and never errors**.
2. **`skills/verification-slots/SKILL.md` documents the fan-out slot** as a first-class,
   **agent-backed** verification slot — one verifier per rule + a skeptic — taking its
   place alongside the existing deterministic / agent / deterministic+agent / unverified
   rows. The slot's contract output (pass/fail + `{file, line, message}` findings) is
   **identical** to the existing slots — the synthesis barrier reconciles N verifier
   results into the one uniform result shape, so hooks/CI/commands consume it unchanged.
3. **The INV-1 boundary preserved.** Workflow mode is read-and-report only: the enforcer
   stays read-only (its tool set is unchanged — `Read, Glob, Grep, Bash`, no `Write`/
   `Edit`), the workflow only *reports*, and any keep-worthy discovery flows through the
   human-curation gate. The §D3 false-positive-reduction observation is captured in a
   `REFLECTION_LOG.md` entry on first run (a human-curated artefact), **not** written by the
   workflow.
4. **Supporting CI / version / docs surfaces** (see §7): the minor bump **`0.59.0 →
   0.60.0`** across the five CI-enforced locations + the README table cell, and a how-to
   touch-up now that the enforcer adopts a template.

### 2.2 Out of scope (explicitly deferred — do not blur)

| Deferred concern | Owning slice | Why not here |
| --- | --- | --- |
| `code-reviewer` / `assessor` / `harness-auditor` workflow modes | **S4 (#441)** | S3 proves the adversarial-verification pattern; S4 reuses it. S3 touches only `harness-enforcer` |
| `orchestrator` classify-and-act routing | **S5 (#442)** | Riding open-question 2 |
| `reflect --mine` mode + staging artefact | **S6 (#443)** | Riding open-question 3 |
| README "Dynamic Workflows" prose section, advisory Stop hook, **Copilot degradation contract** | **S7 (#444)** | Per umbrella D9; open-question 4. S3 restates the Claude-Code-only boundary for its own behaviour but does **not** fix the degradation contract |
| Skill-count badge | **unchanged** | S3 adds **no** new skill, agent, or command — only modifies two existing files. The component-count badges do not move |
| Editing/rewriting `enforcer-fanout.workflow.js` | **S2 (#439, merged)** | S3 *adapts and points at* the template; per the AGENTS.md "consumer never mutates the contract it consumes" decision, S3 does not edit the shipped template |

**Boundary rule.** S3 modifies exactly **two files** —
`ai-literacy-superpowers/agents/harness-enforcer.agent.md` and
`ai-literacy-superpowers/skills/verification-slots/SKILL.md` — plus the version/docs
surfaces in §7. It ships **no new component**, **no new CI workflow**, and **no edit to the
S2 template**.

---

## 3. User story

> **As an** engineer relying on the `harness-enforcer` to verify a large `HARNESS.md`,
> **I want** the enforcer to fan out one verifier subagent per rule (with a skeptic pass)
> whenever the enforceable-constraint count exceeds a per-project threshold, **so that** the
> enforcer can no longer declare "all constraints checked" after silently dropping some —
> the synthesis barrier forces every rule to be accounted for, while small harnesses keep
> the cheap single-context path.

This is the umbrella's **agentic-laziness** failure mode given teeth at the enforcer: the
"35 of 50" lazy stop is structurally impossible once each rule has its own context and the
report cannot form until all N return.

---

## 4. Acceptance scenarios (Given / When / Then)

Each scenario carries its **verification-slot** tag from the umbrella taxonomy:
*deterministic* (CI-checkable / Layer-0–1 structural), *agent-backed* (a runtime / Layer-2–3
behavioural property, checked by an agent), or *unverified* (declared intent). The tdd-agent
should turn the deterministic and the structurally-assertable agent-backed scenarios into
failing checks first. Scenarios trace to umbrella **D3 acceptance**.

### From D3 — the fan-out behaviour

**AC-1 *(agent-backed)* — N>8 enforceable constraints spawn exactly N verifiers behind a synthesis barrier.**
**Given** a `HARNESS.md` with **N > 8** commit-scoped **enforceable** constraints and the
Claude Code runtime present,
**When** the enforcer runs in workflow mode,
**Then** exactly **N** verifier subagents are spawned, **one per rule**, and the **synthesis
barrier waits for all N** results before any report is produced.
*(Slot note: this is a runtime/behavioural property — not deterministically assertable from a
static file read. Its **structural shadow** is AC-5/AC-6, which assert the agent doc declares
the per-rule fan-out and the all-N synthesis barrier. The behavioural assertion stands as a
Layer-2/3 scenario the tdd-agent may add; the declared shape is the structural guarantee.)*

**AC-2 *(agent-backed)* — the skeptic persona reduces false positives, recorded once.**
**Given** a candidate violation flagged by a verifier,
**When** the skeptic persona reviews it,
**Then** a **false-positive reduction versus single-context enforcement is observable**, and
**the first time workflow mode runs**, the observation is captured in a **`REFLECTION_LOG.md`
entry** (a human-curated artefact — not written by the workflow).
*(Slot note: inherently **observational / agent-backed** — false-positive reduction cannot be
proven deterministically from a file read; see §6 decision 3. It must **not** be over-promised
as a deterministic guarantee. Its structural shadow is AC-6, which asserts the agent doc
declares the skeptic pass and the first-run REFLECTION_LOG obligation.)*

**AC-3 *(deterministic, structural)* — the count-equality guarantee is declared, no silent drop.**
**Given** `harness-enforcer.agent.md`,
**When** the workflow-mode section is read,
**Then** it **declares the count-equality guarantee in checkable language**: when the
enforcer reports "all constraints checked", the count of **verifier results equals the count
of enforceable constraints** — explicitly stating that an `unverified` constraint is *excluded
from the enforceable count* (skipped, not checked) and that **no enforceable constraint is
silently dropped**.
*(Slot note: per §6 decision 2, the *runtime* count-equality is agent-backed/behavioural; what
is **deterministically assertable in this repo's TDAD layers** is that the **guarantee is
declared** — a structural assertion on the agent doc. The tdd-agent may also author a
**fixture** — a small synthetic enforceable-constraint inventory — the behavioural scenario
asserts `len(results) == len(enforceable)` against. Be realistic: the fixture exercises the
*counting rule*, not a live fan-out.)*

**AC-4 *(deterministic, structural)* — below-threshold keeps the static single-context path.**
**Given** `harness-enforcer.agent.md`,
**When** the workflow-mode section is read,
**Then** it states that with **≤ 8** enforceable constraints (at or below the threshold) the
enforcer keeps its **existing single-context behaviour** — **no workflow is authored, no
verifier subagents are spawned, no extra compute is spent**. *(The default path is unchanged;
the threshold is a strict `>` — exactly 8 stays single-context.)*

### Structural declarations on the agent doc (the deterministic shadows of D3)

**AC-5 *(deterministic, structural)* — workflow-mode section exists and declares the threshold + configurability.**
**Given** `harness-enforcer.agent.md`,
**When** it is read,
**Then** it contains a **"Workflow mode"** section that declares the **default threshold of
8** commit-scoped enforceable constraints and states the threshold is **configurable per
project** via the §6-decided mechanism (named explicitly, not left as "somehow configurable").

**AC-6 *(deterministic, structural)* — the fan-out + skeptic + synthesis-barrier + template adaptation are declared.**
**Given** the workflow-mode section,
**When** it is read,
**Then** it declares **all** of: one verifier **per rule** (fan-out); a **skeptic persona**
reviewing candidate violations to suppress false positives; a **synthesis barrier** that waits
for **all N** before reporting; that it **adapts** `enforcer-fanout.workflow.js` **by relative
path** (ADAPT, not run verbatim); and the **first-run REFLECTION_LOG** obligation for the
false-positive-reduction observation.

**AC-7 *(deterministic, structural)* — the Claude-Code-only scope + non-erroring fallback are declared.**
**Given** the workflow-mode section,
**When** it is read,
**Then** it states that workflow mode **requires the Claude Code runtime** and that on a tree
without it the enforcer **falls back to single-context behaviour and never errors** (umbrella
§5.5 / runtime-scope note).

### From D3 — the verification-slots documentation

**AC-8 *(deterministic, structural)* — the fan-out slot is documented as a first-class agent-backed slot.**
**Given** `skills/verification-slots/SKILL.md`,
**When** it is read,
**Then** it documents the **fan-out slot** as a first-class, **agent-backed** verification slot
(one verifier per rule + a skeptic), placed alongside the existing
deterministic / agent / deterministic+agent / unverified rows, and states that its output
**conforms to the same pass/fail + `{file, line, message}` contract** — the synthesis barrier
reconciles N verifier results into the one uniform result shape, so downstream
hooks/CI/commands consume it unchanged.

### Cross-cutting — INV-1

**AC-9 *(deterministic, structural)* — workflow mode is propose-only; the enforcer stays read-only.**
**Given** `harness-enforcer.agent.md`,
**When** its frontmatter and workflow-mode section are read,
**Then** the agent's `tools` list is **unchanged** (`Read, Glob, Grep, Bash` — no `Write`,
no `Edit`), and the section states workflow mode **only reports**: any keep-worthy discovery
flows through `REFLECTION_LOG.md → human curates` (INV-1), and the workflow **never writes a
durable artefact**.

---

## 5. Functional requirements

Numbered and testable; each maps to one or more acceptance scenarios in §8.

- **FR-1.** `harness-enforcer.agent.md` contains a **"Workflow mode"** section. *(AC-5)*
- **FR-2.** The section declares a **default threshold of 8** commit-scoped enforceable
  constraints and states it is **configurable per project** via the §6-decided mechanism.
  *(AC-5)*
- **FR-3.** The section defines the **enforceable-constraint count** as constraints whose
  enforcement is `deterministic`, `agent`, or `deterministic + agent`, **excluding**
  `unverified`, and engages workflow mode only when that count is **strictly greater than**
  the threshold. *(AC-3, AC-4)*
- **FR-4.** The section declares the **fan-out (one verifier per rule)**, the **skeptic
  persona**, and the **synthesis barrier that waits for all N** before reporting. *(AC-6;
  structural shadow of AC-1)*
- **FR-5.** The section declares the **count-equality guarantee** — verifier results ==
  enforceable-constraint count, `unverified` excluded, **no silent drop** — in checkable
  language. *(AC-3)*
- **FR-6.** The section states that **≤ threshold** keeps the **existing single-context
  behaviour** (no workflow, no extra compute). *(AC-4)*
- **FR-7.** The section states it **adapts `enforcer-fanout.workflow.js` by relative path**
  (ADAPT, not run verbatim) and hands the constraint inventory as input without spelling a
  durable filename in workflow code (INV-1 / firewall). *(AC-6, AC-9)*
- **FR-8.** The section states the **first-run REFLECTION_LOG obligation** for the
  false-positive-reduction observation. *(AC-2 structural shadow, AC-6)*
- **FR-9.** The section states the **Claude-Code-only runtime scope** and the **non-erroring
  fallback** to single-context behaviour. *(AC-7)*
- **FR-10.** The enforcer's `tools` list is **unchanged** (`Read, Glob, Grep, Bash`) and the
  section states workflow mode is **propose-only / read-only** (INV-1). *(AC-9)*
- **FR-11.** `skills/verification-slots/SKILL.md` documents the **fan-out slot** as a
  first-class **agent-backed** slot whose output conforms to the existing pass/fail +
  `{file, line, message}` contract. *(AC-8)*
- **FR-12.** The plugin version is bumped **`0.59.0 → 0.60.0`** across all five CI-enforced
  locations (§7.1), and the human-facing README plugin-table cell is updated. *(CI:
  Version Check)*
- **FR-13.** The how-to guide
  `docs/plugins/ai-literacy-superpowers/how-to/dynamic-workflows.md` and the agents reference
  entry are checked and updated for the new workflow mode (§7.3). *(docs-impact)*

---

## 6. Decisions surfaced at the GATE

Per the AGENTS.md STYLE note, a recommendation is a **hypothesis for the spec-mode diaboli to
stress**, not a default to confirm — most acutely where the slice touches a **closed contract**
(here: a deterministic count-equality rule and a structural assertion on the agent doc). The
three decisions below are surfaced for the human; the spec-writer recommends but does not
silently choose.

### Decision 1 — How is "configurable per project" expressed? (resolved open-question 1 mechanism)

The threshold *value* is resolved at **8**. What is **not** yet decided is **how a project
overrides it**. Three mechanisms:

- **Option M1 — a documented `HARNESS.md` convention the agent reads (RECOMMENDED).** The
  enforcer reads an optional, named field from `HARNESS.md` — e.g. a
  `Workflow fan-out threshold: <N>` line in a `Workflow mode` block (or the existing
  Constraints/Status preamble) — and falls back to **8** when absent. *Strength:* `HARNESS.md`
  is already the enforcer's single source of truth (it reads constraints from there), it is a
  **durable, human-curated** artefact (so the override is curated, consistent with INV-1 —
  the human sets it, the workflow only reads it), and "the agent reads a documented field"
  matches how every other per-project knob in this plugin works. No new file, no new schema.
  *Weakness:* adds one optional convention to `HARNESS.md` that must be documented where
  constraints are documented. *Diaboli should stress:* is a missing/garbled field handled by a
  safe default (8) rather than an error? Does reading it risk the firewall (no — the enforcer
  *reads* `HARNESS.md`; it is not a *workflow* spelling a durable filename in executable code,
  so the INV-1 firewall does not apply to the agent's own read)?
- **Option M2 — a value in `MODEL_ROUTING.md`'s workflow-election section.** S1 placed token
  budgets and tiering there; the threshold is arguably "workflow-election policy" too.
  *Weakness:* splits the enforcer's configuration across two durable files (constraints in
  `HARNESS.md`, threshold in `MODEL_ROUTING.md`), and the threshold is about *this constraint
  inventory*, which lives in `HARNESS.md`. Coupling it to the inventory's home is more
  cohesive. *Tenable as a secondary home* if the human prefers all workflow-election policy in
  one place.
- **Option M3 — prose default in the agent doc only (no per-project override).** Ship **8** as
  a hardcoded default with no override mechanism. *Rejected as the resolution:* the slicing
  record's resolved disposition is explicitly "threshold = 8, **configurable per project**" —
  M3 drops the configurability the human already dispositioned. Acceptable only if the human
  *re-opens* and decides configurability is not worth a mechanism yet (then the agent doc
  states "8, not yet configurable" honestly rather than implying a knob that does not exist).

**Recommendation: M1** — a documented optional `HARNESS.md` field the agent reads, defaulting
to 8 when absent. It keeps the enforcer's configuration in one curated place and honours the
resolved disposition's configurability. The diaboli should confirm the missing-field default
and that this does not smuggle the threshold into the firewall's scope.

### Decision 2 — What is deterministically assertable vs agent-backed (the verification split)?

The umbrella's D3 count-equality scenario is tagged *(deterministic)*, but **what is
deterministically checkable in this repo's TDAD layers** needs care. This repo's deterministic
layer reads files and matches structure; it does **not** spawn a live fan-out. So:

- **Deterministically assertable (structural, Layer-0/1) — the declarations.** That the agent
  doc **declares** the count-equality guarantee (AC-3), the threshold + configurability
  (AC-5), the fan-out/skeptic/synthesis-barrier/template-adaptation (AC-6), the
  Claude-Code-only scope + fallback (AC-7), and the read-only/propose-only boundary (AC-9);
  and that `verification-slots/SKILL.md` documents the fan-out slot (AC-8). These are
  file-read assertions a structural scenario checks mechanically — the **honest deterministic
  shadow** of D3.
- **Optionally assertable (behavioural fixture, Layer-2/3) — the counting rule.** The tdd-agent
  *may* author a small **fixture** — a synthetic enforceable-constraint inventory (a mix of
  `deterministic`/`agent`/`unverified`) — and assert that the *counting rule* yields
  `enforceable count == N` with `unverified` excluded, exercising the no-silent-drop logic
  against fixed input. This tests the **rule**, not a live fan-out.
- **Agent-backed / behavioural only (not deterministic) — the live properties.** That a real
  run spawns **exactly N** verifiers (AC-1) and that the skeptic **reduces false positives**
  (AC-2) are runtime properties of an actual workflow on the Claude Code runtime. They are
  **agent-backed**, observed at runtime, and (for AC-2) recorded once in `REFLECTION_LOG.md`.
  They must **not** be promised as deterministic.

**Recommendation:** the tdad-scenario set is **predominantly structural** (AC-3 through AC-9
as Layer-0/1 file-read assertions), **optionally** carrying one behavioural fixture for the
counting rule (AC-3's fixture form), with AC-1 and AC-2 standing as **declared agent-backed**
behavioural scenarios. This is the realistic split: the repo deterministically checks *what
the agent doc promises*, and the runtime delivers *the promise*. The diaboli should stress
whether any property currently tagged structural actually requires a live run (it should not —
each is a file-read), and whether the counting-rule fixture is worth the surface or whether the
structural declaration of AC-3 suffices alone.

### Decision 3 — The skeptic false-positive-reduction claim is agent-backed, not deterministic (confirm)

The skeptic-persona claim — *"a documented false-positive reduction versus single-context
enforcement is observable"* — is **inherently observational**. There is no deterministic file
read that proves a *rate reduction*; it requires comparing real runs and is captured, the first
time it runs, in a **`REFLECTION_LOG.md` entry** (a human-curated artefact, consistent with
INV-1). **Confirm it is NOT over-promised as deterministic.** The deterministic surface is only
AC-6's structural assertion that the agent doc *declares* the skeptic pass and the first-run
REFLECTION_LOG obligation — the *effect* itself stays agent-backed/observational. The diaboli
should reject any wording (in the agent doc or the scenarios) that implies the false-positive
reduction is CI-checkable.

### 6.1 Decision summary for the GATE

| Decision | Options | Recommendation |
| --- | --- | --- |
| Threshold configurability mechanism | M1 `HARNESS.md` field / M2 `MODEL_ROUTING.md` / M3 prose-only no-override | **M1** — documented optional `HARNESS.md` field, default 8 when absent |
| Count-equality verification split | all-deterministic / **structural-declaration + optional counting-rule fixture + agent-backed runtime** | **structural declarations are the deterministic shadow; live fan-out + skeptic stay agent-backed** |
| Skeptic false-positive-reduction claim | deterministic / **agent-backed observational (REFLECTION_LOG, first run)** | **agent-backed only — must NOT be promised as deterministic** |

---

## 7. CI, version, and docs checklist

### 7.1 Version bump — a behavioural change to an existing agent (minor)

Adding workflow mode to `harness-enforcer` is a **behavioural addition to an existing agent**
→ **minor bump `0.59.0 → 0.60.0`** (current version confirmed **`0.59.0`** in `plugin.json`,
`README.md` badge + table cell, `CHANGELOG.md` top heading, and both `marketplace.json`
`plugin_version` and the `ai-literacy-superpowers` `plugins[].version` entry). The
`Version Check` CI enforces **five** locations (per CLAUDE.md / the live `version-check.yml`).
Update **every** one:

1. `ai-literacy-superpowers/.claude-plugin/plugin.json` — `"version"` (canonical; `0.59.0` →
   `0.60.0`)
2. `README.md` — shields.io **badge** `ai--literacy--superpowers-v0.60.0` (line 6; currently
   `v0.59.0`)
3. `CHANGELOG.md` — new top heading `## 0.60.0 — 2026-06-22`
4. `.claude-plugin/marketplace.json` — top-level `plugin_version` (currently `0.59.0`; owned
   by ai-literacy-superpowers PRs)
5. `.claude-plugin/marketplace.json` — the `ai-literacy-superpowers` `plugins[].version` entry
   (currently `0.59.0`)

Also update, for human-facing consistency (**not** CI-enforced): the `README.md` plugin-table
row cell (`| v0.59.0 |` → `| v0.60.0 |`, line 31).

> The marketplace listing `version` (`0.4.0`) does **not** change — S3 alters no listing
> contract (no description/keyword/permission/plugins-array/source change). The component-count
> badges (`Skills-36`, `Agents-16`, `Commands-28`) do **not** change — S3 adds no new component,
> only modifies two existing files.

Before committing, grep for the **old** version to surface every spot at once:

```text
grep -rn 'v0\.59\.0\|0\.59\.0' README.md .claude-plugin/marketplace.json \
  ai-literacy-superpowers/.claude-plugin/plugin.json CHANGELOG.md
```

### 7.2 CI gates

- **`spec-first-check`** — satisfied by **this spec being the first commit** on branch
  `dynamic-workflows-s3-enforcer-fanout`. No exemption label; this is feature work.
- **`tdad-scenario-check`** — S3 **modifies** an existing agent rather than adding a new
  component. The gate fires on *added* components (per the TDAD-discipline spec), so it does
  **not strictly force** a new scenario for a modification. **However**, this is a
  **behavioural addition** and warrants a scenario. The `harness-enforcer` has **no scenario
  directory yet** — `tdad_tests/scenarios/agents/harness-enforcer/` **does not exist**. The
  **tdd-agent will create it** and author the structural scenarios (AC-3 through AC-9) and any
  optional behavioural fixture (AC-3 counting-rule). Spec-writer **names** this so the tdd-agent
  has an unambiguous home and assertion set; spec-writer does **not** create the directory or
  any test file (spec-first discipline — no test files in this commit).
- **`INV-1 firewall` (S2, existing)** — S3 modifies **no `*.workflow.js` template**, so the
  firewall is **not triggered by new template content**. The enforcer's own *read* of
  `HARNESS.md` is an agent behaviour, not a workflow spelling a durable filename in executable
  code, so it is outside the firewall's scope. (If the tdd-agent's optional fixture is a
  `.workflow.js`, it must itself pass the firewall — but the recommended fixture is a synthetic
  constraint inventory, not a workflow.)
- **`lint-markdown`** — the modified `harness-enforcer.agent.md`, `verification-slots/SKILL.md`,
  this spec, and any touched docs page must pass markdownlint (PreToolUse hook + CI).
- **`Choice cartographer` / objection gates** — this feature PR proceeds through the plugin's
  own pipeline (spec → diaboli → adjudicate → plan → implement). Dispositions on any objection
  record must be resolved before the plan-approval GATE, per the spec-first discipline.

### 7.3 Docs-impact note (CLAUDE.md "Docs Site Review")

- **Reference (`docs-reference-parity-check`) — no NEW component, so no new entry forced.**
  S3 adds no new skill/agent/command, so the parity gate is satisfied with no new heading.
  **But** the existing `### harness-enforcer` entry in
  `docs/plugins/ai-literacy-superpowers/reference/agents.md` should be **updated** to mention
  the new **workflow mode** (the threshold-gated fan-out) so the reference does not describe
  only the single-context behaviour. This is a *consistency* update, not a parity requirement.
- **How-to (touch-up).** The orientation guide
  `docs/plugins/ai-literacy-superpowers/how-to/dynamic-workflows.md` currently lists
  `enforcer-fanout.workflow.js` as a template to copy. Now that an **agent adopts it as a
  documented mode**, add a short note that the `harness-enforcer` itself elects this template
  above its threshold — turning the how-to from "templates you could adapt" toward "templates
  the plugin's own agents already adapt", the dogfooding the umbrella §6 calls for.
- **Explanation / tutorials.** None required — no existing explanation page describes the
  enforcer's single-context behaviour as a fixed property that S3 would contradict; the
  fan-out concept already lives in the skill's `references/patterns.md` (S1) and the
  `enforcer-fanout` preamble (S2).

---

## 8. FR → acceptance-scenario mapping

| FR | Covered by | Slot |
| --- | --- | --- |
| FR-1 | AC-5 | deterministic (structural) |
| FR-2 | AC-5 | deterministic (structural) |
| FR-3 | AC-3, AC-4 | deterministic (structural) |
| FR-4 | AC-6 (structural shadow of AC-1) | deterministic (structural) / agent-backed (AC-1) |
| FR-5 | AC-3 | deterministic (structural) + optional counting-rule fixture |
| FR-6 | AC-4 | deterministic (structural) |
| FR-7 | AC-6, AC-9 | deterministic (structural) |
| FR-8 | AC-6 (and AC-2 structural shadow) | deterministic (structural) / agent-backed (AC-2 effect) |
| FR-9 | AC-7 | deterministic (structural) |
| FR-10 | AC-9 | deterministic (structural) |
| FR-11 | AC-8 | deterministic (structural) |
| FR-12 | (CI: Version Check) | deterministic |
| FR-13 | (docs-impact; reference + how-to touch-up) | deterministic (presence) |

**Agent-backed runtime scenarios** (not deterministic; see §6 decisions 2 and 3):

- **AC-1** — exactly N verifiers + all-N synthesis barrier — runtime/behavioural; structural
  shadow is AC-6/FR-4.
- **AC-2** — skeptic false-positive reduction, recorded once in `REFLECTION_LOG.md` — agent-
  backed / observational; structural shadow is AC-6/FR-8. **Not** over-promised as
  deterministic (§6 decision 3).

---

## 9. Risks and open questions

**Risks.**

- *Threshold mis-set burns or under-protects compute.* Too low burns compute fanning out on
  small harnesses; too high reinstates the lazy-stop risk. Mitigation: default **8** with a
  documented per-project override (§6 decision 1); the `>` (strict) trigger keeps exactly-8
  on the cheap path.
- *Over-promising determinism.* The temptation is to tag the count-equality and skeptic
  scenarios as fully CI-checkable. Mitigation: §6 decisions 2 and 3 fix the honest split —
  structural *declarations* are deterministic; live fan-out and false-positive reduction are
  agent-backed. The diaboli should reject any wording that overclaims.
- *Firewall scope confusion.* The threshold-config mechanism (M1) has the enforcer **read**
  `HARNESS.md`; a careless reading could think this trips the INV-1 firewall. Mitigation:
  the firewall scopes to **`*.workflow.js` templates spelling a durable filename in executable
  code**, not to an agent reading its own source of truth. S3 edits no template.
- *Scenario-home omission.* `harness-enforcer` has no scenario directory; a behavioural
  addition without one leaves the new mode unverified. Mitigation: §7.2 names the directory
  the tdd-agent must create and the structural assertion set it must carry.
- *Template drift.* The agent points at `enforcer-fanout.workflow.js` whose runtime call
  shapes may drift from the authoritative docs. Mitigation: the agent ADAPTs the template and
  defers function names to <https://code.claude.com/docs/en/workflows>; S3 does not freeze a
  call signature.

**Open questions.** None block S3. The umbrella open questions ride later slices (Q2 routing
→ S5, Q3 staging → S6, Q4 Copilot → S7) and are out of scope (§2.2). **Open-question 1 (the
threshold) is resolved at 8**; the only S3-internal decision is **how** "configurable per
project" is expressed (§6 decision 1) — **surfaced for the GATE, not left open**: the spec
recommends M1 and the human disposes.

---

## 10. References

- Umbrella spec:
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
  (read-first runtime-scope note; §2 INV-1/INV-2; **D3**; §5; §6; §7 open-question 1).
- Slicing record: `docs/superpowers/slices/dynamic-workflows-alignment.md`
  (Runtime-scope section; **S3** entry — threshold = 8, configurable per project).
- S1 spec (merged):
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-s1-skill-design.md`.
- S2 spec (merged):
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-s2-templates-design.md`.
- Shipped substrate S3 adapts:
  - `ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md` (the template-library table
    naming `enforcer-fanout.workflow.js`).
  - `ai-literacy-superpowers/skills/dynamic-workflows/workflows/enforcer-fanout.workflow.js`
    (the `Verify → Skeptic → Synthesize` template, its synthesis barrier, and its
    `checked`/`confirmed` accounting — the pattern S3 wires the enforcer to).
  - `ai-literacy-superpowers/scripts/inv-firewall.sh` (the INV-1/INV-2 deterministic firewall;
    untouched by S3).
- Target files S3 modifies:
  - `ai-literacy-superpowers/agents/harness-enforcer.agent.md`.
  - `ai-literacy-superpowers/skills/verification-slots/SKILL.md`.
- Runtime API (authoritative): <https://code.claude.com/docs/en/workflows>.
- AGENTS.md decisions consulted: the "recommended option is a hypothesis for the diaboli"
  STYLE note (closed-contract pre-listing); "a consumer never mutates the contract it
  consumes" (S3 adapts but does not edit `enforcer-fanout.workflow.js`).
