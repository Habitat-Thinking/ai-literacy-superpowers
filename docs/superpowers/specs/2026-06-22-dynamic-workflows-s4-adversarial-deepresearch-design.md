# Specification — Dynamic Workflows S4: Adversarial Review + Deep-Research Assessment/Audit

**Plugin:** `ai-literacy-superpowers` (Habitat-Thinking)
**Slice:** S4 of the Dynamic Workflows Alignment epic (D5 + D7 — clustered)
**Umbrella spec:** `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
**Slicing record:** `docs/superpowers/slices/dynamic-workflows-alignment.md` (§ S4)
**Issue:** <https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/441>
**Depends on:** S1 (#438, merged) — the `dynamic-workflows` skill + election rubric; S2 (#439, merged) — the `adversarial-review.workflow.js` + `deep-assessment.workflow.js` templates + the INV-1/INV-2 firewall; S3 (#440, merged) — the proven adversarial-verification *pattern* and the structural-content test shape S4 reuses
**Spec status:** Draft for implementation
**Spec version:** 0.1.0
**Owner:** Russ Miles / Habitat Thinking
**Branch:** `dynamic-workflows-s4-adversarial-deepresearch`

> **Implementer note (read first).** This slice gives **four existing agents** a
> **workflow mode** and documents the workflow path in **two commands**. It ships **no new
> component** — it modifies four agent files and two command files (plus version/docs
> surfaces). It does **not** rewrite the S2-shipped templates
> (`adversarial-review.workflow.js`, `deep-assessment.workflow.js`); it **points the agents
> at them** and describes how each agent ADAPTs the template per run. The *exact* runtime
> function names for spawning subagents, parallel fan-out, and synthesis barriers are **not
> authoritative in this spec** — consult <https://code.claude.com/docs/en/workflows> as the
> source of truth and treat any call shape here or in the templates as ADAPTABLE pseudocode,
> not a frozen API.
>
> **Runtime scope — Claude Code only.** Dynamic workflows are a Claude Code runtime
> capability, **not transferable** to GitHub Copilot CLI or any other coding agent — those
> trees have no workflow runtime. The plugin ships to both trees, so **every** workflow mode
> this slice adds is **Claude-Code-gated**: where the runtime exists the agents can fan out
> into separate contexts; where it does not (Copilot CLI, other agents) each workflow-mode
> section is **guidance only** and the agent **falls back to its existing single-context
> behaviour — it must never error or pretend to fan out**. Each of the four agents' workflow-
> mode sections must restate this boundary explicitly (umbrella §5.5 / slicing-record runtime-
> scope note). The precise Copilot degradation *contract* (guidance-only vs omit) is
> open-question 4, resolved in S7, and is **not** decided here.

---

## 1. Context and motivation

S3 proved the **adversarial-verification + fan-out-and-synthesize** pattern on the
`harness-enforcer`: one verifier subagent per item, in its own clean context, behind a
synthesis barrier that waits for all of them. S4 takes that proven shape and applies it
**uniformly** (the slicing-record disposition: *"apply the adversarial-verification shape
uniformly across the self-preference-exposed agents; specialise only where an agent demands
it"*) to the four agents the umbrella names as most exposed to **self-preferential bias** and
**agentic laziness**:

| Agent | Failure mode it is exposed to | What S4 adds |
| --- | --- | --- |
| `code-reviewer` | self-preferential bias (judging output from the same context that produced it) | D5: a **separate-context** review mode — one dedicated verifier per CUPID + literate property, synthesised |
| `advocatus-diaboli` | (the adversary) | D5: declares its role as the **rubric-bearing adversary** in that workflow, without breaking its read-only trust boundary |
| `assessor` | agentic laziness (long repo scans, the "35 of 50" lazy stop) | D7: above a repo-size threshold, **fan out by area**, adversarially verify each finding, synthesise a **cited report** |
| `harness-auditor` | agentic laziness **+ self-audit bias** (grading its own framework) | D7: the deep-research shape **plus** at least one verifier **adversarial to the framework's own assumptions** |

The two D-clusters share **one acceptance shape** — *a verifier operates in a context window
distinct from the producing context; each rubric property or repo area is checked by a
dedicated verifier; findings are synthesised, not collapsed*. That shared shape is why the
slicing record clusters them into one slice (acceptance-criterion lens) rather than emitting
three near-identical slices.

S4 wires each agent to its S2 template; it invents no new template and edits no template (per
the AGENTS.md "a consumer never mutates the contract it consumes" decision). Below their
trigger, all four agents keep their **current behaviour, unchanged** — the default path is
untouched, honouring umbrella §6/§7 compute discipline (over-orchestration is a regression).

---

## 2. Scope

### 2.1 In scope (this slice)

**D5 — `code-reviewer` + `advocatus-diaboli`:**

1. **`code-reviewer.agent.md` gains a "Workflow mode" section** stating:
   - **The trigger** — a **non-trivial** review (see §6 decision 3): workflow mode engages
     only for a review above a size signal; trivial diffs keep the existing single-context
     review. Respects `MAX_REVIEW_CYCLES=3`.
   - **The separate-context property** — the reviewing agent operates in a **context window
     distinct from the implementer's**, so it is not judging output from the context that
     produced it (defeats self-preferential bias).
   - **The per-property fan-out** — each **CUPID** property (Composable, Unix-philosophy,
     Predictable, Idiomatic, Domain-based) and each **literate-programming** property is
     checked by a **dedicated verifier**, and the findings are **synthesised, not collapsed**
     into a single thumbs-up.
   - **How it adapts `adversarial-review.workflow.js`** — references the S2 template **by
     relative path**, hands the diff in as input (never spelling a durable filename in
     workflow code — INV-1 / the firewall), and ADAPTs prompts, per-role model tiers, and the
     token budget per run rather than running it verbatim.
   - **The Claude-Code-only runtime scope + non-erroring fallback** — on a tree without the
     runtime, the reviewer **falls back to its existing single-context review and never
     errors**.
   - **The INV-1 boundary** — the reviewer's tool set stays unchanged (`Read, Glob, Grep,
     Bash` — no `Write`/`Edit`); workflow mode **only proposes findings**; it never writes a
     durable artefact.
2. **`advocatus-diaboli.agent.md` declares its workflow role** — a short addition stating
   that, in the `adversarial-review` workflow, the diaboli is the **rubric-bearing
   adversary** (the agent that evaluates the diff against the CUPID + literate rubric), and
   that this role **does not relax its existing read-only trust boundary** (`Read, Glob, Grep`
   only; no Write/Bash; dispositions remain the human's job). The existing spec-mode/code-mode
   charter is unchanged.

**D7 — `assessor` + `harness-auditor`:**

3. **`assessor.agent.md` gains a "Workflow mode" section** stating:
   - **The trigger** — a repo **above a size threshold** (see §6 decision 1): workflow mode
     engages only for large repos; small repos keep the existing single-context scan.
   - **The deep-research shape** — **fan out by area**, **adversarially verify each finding**
     in a **separate agent** before synthesis, produce a **cited report** (file:line
     citations preserved through synthesis; a completeness pass guards the tail of findings).
   - **How it adapts `deep-assessment.workflow.js`** — by relative path, ADAPT not verbatim,
     diff/area inventory handed in as input.
   - **The Claude-Code-only runtime scope + non-erroring fallback** — falls back to the
     existing single-context Phase 1–6 scan and never errors where the runtime is absent.
   - **The output-location/format invariant** — the assessment output **remains a timestamped
     artefact in the existing location** (`assessments/YYYY-MM-DD-assessment.md`) **with the
     existing template format**. Workflow mode changes *how* the report is produced (fan-out +
     verify), not *what* it is or *where* it lands.
   - **The INV-1 boundary, stated precisely** — the assessor **legitimately writes its own
     assessment report artefact** to the existing location (its tool set already includes
     `Write`/`Edit`, and the assessment doc is **not** one of the four durable curated
     artefacts INV-1 protects). What workflow mode must **not** do is write the **durable
     curated artefacts** — `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `MODEL_ROUTING.md` — except
     through the existing curation/adjustment gates the agent already runs. The *workflow* (the
     `*.workflow.js` fan-out) proposes findings only; the **agent** then writes its own report.
4. **`harness-auditor.agent.md` gains a "Workflow mode" section** stating everything in (3)
   **plus the self-preference guard**: at least one verifier must be **adversarial to the
   framework's own assumptions** (the auditor must not grade its own homework). The output-
   location invariant for the auditor is its existing **HARNESS.md Status section** update and
   **README badge** update — workflow mode keeps those exact write targets and formats. INV-1
   precision: the auditor already (and only) writes the **HARNESS.md Status section** and the
   **README badge line** — these are its existing, narrowly-scoped writes, not a full durable-
   artefact rewrite; the workflow itself proposes findings only and the agent performs those
   two scoped writes as today.
5. **`commands/assess.md` and `commands/harness-audit.md` document the workflow path** — a
   short note that, for a large repo (above the §6 threshold) on the Claude Code runtime, the
   dispatched agent elects its deep-research workflow mode (fan-out by area + adversarial
   verification + cited report), with the same output and a non-erroring fallback elsewhere.

6. **Supporting CI / version / docs surfaces** (see §7): the minor bump **`0.60.0 → 0.61.0`**
   across the five CI-enforced locations + the README table cell, and reference/how-to touch-
   ups now that four agents adopt templates.

### 2.2 Out of scope (explicitly deferred — do not blur)

| Deferred concern | Owning slice | Why not here |
| --- | --- | --- |
| `harness-enforcer` workflow mode | **S3 (#440, merged)** | The pattern S4 reuses; S4 does not re-touch the enforcer |
| `orchestrator` classify-and-act routing | **S5 (#442)** | Riding open-question 2 |
| `reflect --mine` mode + staging artefact | **S6 (#443)** | Riding open-question 3 |
| README "Dynamic Workflows" prose section, advisory Stop hook, **Copilot degradation contract** | **S7 (#444)** | Per umbrella D9; open-question 4. S4 restates the Claude-Code-only boundary for its own behaviour but does **not** fix the degradation contract |
| Skill-count / component-count badges | **unchanged** | S4 adds **no** new skill, agent, or command — only modifies six existing files. The component-count badges do not move |
| Editing/rewriting `adversarial-review.workflow.js` or `deep-assessment.workflow.js` | **S2 (#439, merged)** | S4 *adapts and points at* the templates; per the AGENTS.md "consumer never mutates the contract it consumes" decision, S4 does not edit either shipped template |

**Boundary rule.** S4 modifies exactly **six files** —
`agents/code-reviewer.agent.md`, `agents/advocatus-diaboli.agent.md`,
`agents/assessor.agent.md`, `agents/harness-auditor.agent.md`, `commands/assess.md`,
`commands/harness-audit.md` — plus the version/docs surfaces in §7. It ships **no new
component**, **no new CI workflow** (it *wires a new test file into the existing*
`tdad-tests-fast.yml`), and **no edit to either S2 template**.

---

## 3. User stories

> **As an** engineer whose implementation is being reviewed, **I want** the `code-reviewer`
> to review a non-trivial change in a **context window distinct from the one that wrote the
> code**, with each CUPID and literate property checked by its own verifier, **so that** the
> review cannot rubber-stamp its own reasoning — self-preferential bias is defeated
> structurally, while trivial diffs keep the cheap single-context path.

> **As a** team running an AI-literacy assessment or a harness audit on a large repo, **I
> want** the `assessor` / `harness-auditor` to **fan out by area** and **adversarially verify
> each finding in a separate agent** before synthesising a cited report, **so that** a long
> scan can no longer declare itself done after partial progress — and, for the auditor, so
> that the framework cannot grade its own homework — while the report still lands as the same
> timestamped artefact in the same place.

---

## 4. Acceptance scenarios (Given / When / Then)

Each scenario carries its **verification-slot** tag from the umbrella taxonomy:
*deterministic* (CI-checkable / Layer-0–1 structural), *agent-backed* (a runtime / Layer-2–3
behavioural property), or *unverified* (declared intent). Scenarios trace to umbrella **D5**
and **D7** acceptance. The tdd-agent turns the deterministic and structurally-assertable
agent-backed scenarios into failing checks first.

### D5 — code-reviewer adversarial review

**AC-1 *(agent-backed; structural shadow AC-2)* — review runs in a separate context window.**
**Given** an implementation and the Claude Code runtime present,
**When** review runs in workflow mode,
**Then** the reviewing agent operates in a **context window distinct from the implementer's**.
*(Slot note: separate-context is a runtime property — not assertable from a static file read.
Its structural shadow is AC-2/AC-3 declaring the separate-context property and the per-property
fan-out. The behavioural assertion stands as a Layer-2/3 scenario the tdd-agent may add.)*

**AC-2 *(deterministic, structural)* — workflow-mode section exists and declares separate-context + non-trivial trigger.**
**Given** `code-reviewer.agent.md`,
**When** it is read,
**Then** it contains a **"Workflow mode"** section declaring that review runs in a **context
window distinct from the implementer's**, engaged only for a **non-trivial** review (the §6
decision-3 trigger, named explicitly — not "somehow large").

**AC-3 *(deterministic, structural)* — per-property dedicated verifiers, synthesised not collapsed.**
**Given** the workflow-mode section,
**When** it is read,
**Then** it declares that **each CUPID property and each literate-programming property is
checked by a dedicated verifier** and that findings are **synthesised, not collapsed**, and
that it **adapts `adversarial-review.workflow.js` by relative path** (ADAPT, not verbatim).

**AC-4 *(unverified, declared)* — review cycles respect MAX_REVIEW_CYCLES=3.**
**Given** review runs in workflow mode,
**When** findings drive revision cycles,
**Then** the pipeline's **`MAX_REVIEW_CYCLES=3`** GUARDRAIL still holds — workflow mode does
not multiply review cycles.
*(Slot note: declared intent — the guardrail lives in the orchestrator/pipeline, not provable
from the reviewer doc alone. The structural shadow is AC-3's section stating the guardrail
holds.)*

**AC-5 *(deterministic, structural)* — advocatus-diaboli declares its rubric-bearing-adversary role without relaxing its trust boundary.**
**Given** `advocatus-diaboli.agent.md`,
**When** it is read,
**Then** it states that in the `adversarial-review` workflow the diaboli is the **rubric-
bearing adversary** evaluating the diff against the CUPID + literate rubric, and that its
**read-only trust boundary is unchanged** (`tools` remains `Read, Glob, Grep` — no `Write`,
no `Bash`; dispositions remain the human's).

### D7 — deep-research assessment + audit

**AC-6 *(agent-backed; structural shadow AC-7)* — above-threshold repo fans out by area, each finding verified by a separate agent before synthesis.**
**Given** a repo above the size threshold and the Claude Code runtime present,
**When** assessment (or audit) runs in workflow mode,
**Then** findings **fan out by area** and **each finding is verified by a separate agent
before synthesis**.
*(Slot note: runtime/behavioural. Its structural shadow is AC-7/AC-8 declaring the threshold,
the fan-out-by-area, and the per-finding separate-agent verification.)*

**AC-7 *(deterministic, structural)* — assessor workflow-mode section declares the threshold + deep-research shape.**
**Given** `assessor.agent.md`,
**When** it is read,
**Then** it contains a **"Workflow mode"** section declaring the **repo-size threshold** (the
§6 decision-1 metric + default + configurability mechanism, named explicitly), the **fan-out-
by-area** shape, the **per-finding separate-agent adversarial verification**, the **cited
report**, that it **adapts `deep-assessment.workflow.js` by relative path**, and the
**Claude-Code-only scope + non-erroring fallback** to the existing single-context scan.

**AC-8 *(deterministic, structural)* — auditor workflow-mode section declares the same shape PLUS the self-preference guard.**
**Given** `harness-auditor.agent.md`,
**When** it is read,
**Then** it contains a **"Workflow mode"** section declaring everything in AC-7 **plus** that
**at least one verifier is adversarial to the framework's own assumptions** (the self-
preference guard — the auditor must not grade its own homework).

**AC-9 *(deterministic, structural)* — assessment output stays a timestamped artefact in the existing location/format.**
**Given** the assessor (and auditor) workflow-mode sections,
**When** they are read,
**Then** each states that workflow mode's output **remains a timestamped artefact in the
existing location with the existing format** — for the assessor,
`assessments/YYYY-MM-DD-assessment.md` in the existing template; for the auditor, the existing
**HARNESS.md Status section** + **README badge** update — workflow mode changes how the report
is produced, not what it is or where it lands.

**AC-10 *(deterministic, structural)* — commands document the workflow path for large repos.**
**Given** `commands/assess.md` and `commands/harness-audit.md`,
**When** they are read,
**Then** each documents that, **above the threshold** on the **Claude Code runtime**, the
dispatched agent elects its **deep-research workflow mode** (fan-out by area + adversarial
verification + cited report), with the **same output** and a **non-erroring fallback**
elsewhere.

### Cross-cutting — INV-1 (the precise boundary)

**AC-11 *(deterministic, structural)* — read/propose-only agents stay read-only; report-writing agents write only their own report.**
**Given** the four agents' frontmatter and workflow-mode sections,
**When** they are read,
**Then**:
- `code-reviewer` and `advocatus-diaboli` keep **read-only** tool sets (no `Write`/`Edit`/
  `Bash` beyond their existing lists) and their workflow modes **only propose findings**;
- `assessor` and `harness-auditor` retain their existing `Write`/`Edit` tools **for their own
  artefacts only** — the assessment report (assessor) and the HARNESS.md Status section +
  README badge (auditor); and each section states the **`*.workflow.js` workflow itself
  proposes findings only and never writes a durable curated artefact** (`HARNESS.md`,
  `AGENTS.md`, `CLAUDE.md`, `MODEL_ROUTING.md`) — the prohibition is on those four, **not** on
  the assessment report. *(This is the precision the task flags: do not wrongly forbid the
  assessor from writing its assessment.)*

---

## 5. Functional requirements

Numbered and testable; each maps to one or more acceptance scenarios in §8.

- **FR-1.** `code-reviewer.agent.md` contains a **"Workflow mode"** section. *(AC-2)*
- **FR-2.** The section declares the **separate-context** property (reviewer's context window
  distinct from the implementer's) and the **non-trivial trigger** (§6 decision 3, named).
  *(AC-2; structural shadow of AC-1)*
- **FR-3.** The section declares **one dedicated verifier per CUPID + literate property**,
  findings **synthesised not collapsed**, and **adapts `adversarial-review.workflow.js` by
  relative path**. *(AC-3; structural shadow of AC-1)*
- **FR-4.** The section states **`MAX_REVIEW_CYCLES=3`** still holds in workflow mode. *(AC-4)*
- **FR-5.** The section states the **Claude-Code-only scope** and the **non-erroring fallback**
  to single-context review, and that workflow mode is **propose-only / read-only** (INV-1).
  *(AC-2, AC-11)*
- **FR-6.** `advocatus-diaboli.agent.md` declares its **rubric-bearing-adversary** role in the
  `adversarial-review` workflow with its **read-only trust boundary unchanged**. *(AC-5)*
- **FR-7.** `assessor.agent.md` contains a **"Workflow mode"** section declaring the **repo-
  size threshold** (§6 decision-1 metric + default + configurability, named), **fan-out-by-
  area**, **per-finding separate-agent adversarial verification**, the **cited report**, the
  **adapt-by-relative-path** of `deep-assessment.workflow.js`, and the **Claude-Code-only
  scope + non-erroring fallback**. *(AC-7; structural shadow of AC-6)*
- **FR-8.** `harness-auditor.agent.md` contains a **"Workflow mode"** section declaring
  everything in FR-7 **plus** the **self-preference guard** (≥1 verifier adversarial to the
  framework's own assumptions). *(AC-8; structural shadow of AC-6)*
- **FR-9.** Both `assessor` and `harness-auditor` workflow-mode sections state the **output
  stays a timestamped artefact in the existing location/format** (assessor:
  `assessments/YYYY-MM-DD-assessment.md`; auditor: HARNESS.md Status + README badge). *(AC-9)*
- **FR-10.** `commands/assess.md` and `commands/harness-audit.md` document the **workflow path
  for large repos** (above-threshold + Claude Code runtime → deep-research mode; same output;
  non-erroring fallback). *(AC-10)*
- **FR-11.** The **INV-1 precision** is declared: `code-reviewer`/`advocatus-diaboli` stay
  read-only and propose-only; `assessor`/`harness-auditor` write **only their own report
  artefacts**, and the **workflow itself** never writes a durable curated artefact
  (HARNESS.md/AGENTS.md/CLAUDE.md/MODEL_ROUTING.md). *(AC-11)*
- **FR-12.** The plugin version is bumped **`0.60.0 → 0.61.0`** across all five CI-enforced
  locations (§7.1), and the human-facing README plugin-table cell is updated. *(CI: Version
  Check)*
- **FR-13.** The how-to guide(s) and the agents reference entries for the four agents are
  checked and updated for the new workflow modes (§7.3). *(docs-impact)*

---

## 6. Decisions surfaced at the GATE

Per the AGENTS.md STYLE note, a recommendation is a **hypothesis for the spec-mode diaboli to
stress**, not a default to confirm. The three decisions below are surfaced for the human; the
spec-writer recommends but does not silently choose.

### Decision 1 — The D7 repo-size threshold: metric, default value, and configurability mechanism

D7 says "above a size threshold" but fixes neither metric nor value nor override. Mirroring the
S3 M1 pattern (the resolved threshold mechanism for the enforcer), three sub-choices:

**Metric.** Options:

- **(a) file count scanned (RECOMMENDED)** — the assessor/auditor already enumerate files and
  signals across the repo; "number of files in scope" is the most direct proxy for the scan
  length that triggers agentic laziness, and it is cheap to compute before electing the
  workflow.
- (b) constraint count — natural for the *auditor* (it scans HARNESS.md constraints) but a poor
  proxy for the *assessor* (which scans the whole repo, not just constraints). Splitting the
  metric per agent would break the "uniform shape" disposition.
- (c) LOC — noisy (generated files, vendored code inflate it) and not what either agent
  actually iterates over.

**Default value.** **300 files (RECOMMENDED)** — large enough that a single-context scan is the
cheap, correct path for small/medium repos (so we do not over-orchestrate), low enough that a
genuinely large monorepo trips the deep-research mode. The diaboli should stress whether 300 is
evidence-based or arbitrary; it is a **starting default**, explicitly tunable.

**Configurability mechanism.** Options (mirror S3 decision 1):

- **M1 — a documented optional `HARNESS.md` field (RECOMMENDED), e.g.
  `Deep-research threshold: <N>`**, defaulting to 300 when absent. *Strength:* same curated-
  durable home and same "agent reads a documented field" shape S3 chose for the enforcer
  threshold — one consistent knob style across the epic; missing/garbled field safe-defaults
  rather than errors. *Diaboli should stress:* is the assessor's threshold conceptually a
  HARNESS.md concern (HARNESS governs enforcement, not assessment), or would
  `MODEL_ROUTING.md`'s workflow-election section (M2) be a more cohesive home for *all*
  workflow-election policy?
- M2 — a value in `MODEL_ROUTING.md`'s workflow-election section (S1 placed token budgets/
  tiering there). *Tenable* and arguably more cohesive for assessment (which is not a HARNESS
  enforcement concern); the cost is splitting from S3's HARNESS.md precedent.
- M3 — prose default in the agent docs only (no override). *Acceptable only if* the human
  decides per-project configurability is not worth a mechanism yet; then the docs say "300, not
  yet configurable" honestly.

**Recommendation:** metric = **file count**, default = **300**, mechanism = **M1 optional
`HARNESS.md` field**, defaulting to 300 when absent — for cross-epic consistency with S3. The
diaboli should stress the M1-vs-M2 home (HARNESS.md governs enforcement; is assessment-scan
policy a HARNESS concern?) and whether 300 is the right starting value.

### Decision 2 — The verification split (deterministic structural vs agent-backed behavioural)

Mirroring S3 decision 2: this repo's deterministic layer **reads files and matches structure**;
it does **not** spawn a live fan-out or open a second context window. So:

- **Deterministically assertable (structural, Layer-0/1) — the declarations.** That each agent
  doc **declares**: the workflow-mode section exists (AC-2, AC-7, AC-8); the separate-context
  property + non-trivial trigger (AC-2); per-property dedicated verifiers + synthesised-not-
  collapsed + adapt-by-relative-path (AC-3); the diaboli's rubric-bearing-adversary role +
  unchanged trust boundary (AC-5); the repo-size threshold + fan-out-by-area + per-finding
  separate-agent verification + cited report + Claude-Code scope + fallback (AC-7); the self-
  preference guard (AC-8); the existing-location/format invariant (AC-9); the command workflow-
  path note (AC-10); and the INV-1 precision (AC-11). These are file-read assertions a
  structural test checks mechanically — the **honest deterministic shadow** of D5+D7.
- **Agent-backed / behavioural only (not deterministic) — the live properties.** That a real
  run actually opens a **separate context window** (AC-1), and that an above-threshold run
  **fans out by area with per-finding separate-agent verification** (AC-6), are runtime
  properties of an actual workflow on the Claude Code runtime. They are **agent-backed**,
  observed at runtime, and must **not** be promised as deterministic.
- **Unverified / declared (AC-4)** — `MAX_REVIEW_CYCLES=3` holding under workflow mode is a
  pipeline-level guardrail, declared in the reviewer doc; its structural shadow is the section
  stating it holds, but the guarantee itself lives in the orchestrator.

**Recommendation:** the tdad-scenario set is **predominantly structural** (AC-2, AC-3, AC-5,
AC-7, AC-8, AC-9, AC-10, AC-11 as Layer-0/1 file-read assertions), with AC-1 and AC-6 standing
as **declared agent-backed** behavioural scenarios and AC-4 as **unverified/declared**. This is
the same realistic split S3 landed. The diaboli should stress whether any property currently
tagged structural actually requires a live run (it should not — each is a file-read), and
whether the separate-context property of AC-1 risks being over-promised as deterministic (it
must not).

### Decision 3 — The D5 trigger: when does code-reviewer use workflow mode?

D5 must avoid the umbrella §7 over-orchestration risk — spinning up a panel of per-property
verifiers (≈12k tokens per the template preamble) on a one-line diff is exactly the waste the
discipline gate forbids. Options:

- **Option T1 — always use workflow mode.** *Rejected:* multiplies cost on every trivial diff
  and contradicts §6/§7 compute discipline.
- **Option T2 — non-trivial reviews only, by a size signal (RECOMMENDED).** Workflow mode
  engages only when the diff is **non-trivial** — above a small size signal (e.g. files-changed
  or hunks-changed above a low bound, default **> 2 files changed** OR a substantive single-
  file change, named in the agent doc and tunable). Trivial diffs (typo, one-liner, formatting)
  keep the existing single-context review. *Strength:* mirrors the S3 "strict `>` threshold,
  cheap default path below it" shape; keeps the per-property panel for the reviews that warrant
  it. *Diaboli should stress:* the exact size signal and whether "> 2 files" is the right bound
  or should be expressed as a configurable field consistent with decision 1's mechanism.
- Option T3 — the orchestrator decides (defer the trigger to S5's classifier). *Rejected for
  S4:* S5's routing is opt-in and later; S4 must ship a self-contained trigger so the reviewer
  works standalone, exactly as S3's enforcer carries its own threshold.

**Recommendation:** **T2** — non-trivial reviews only, default **> 2 files changed (or a
substantive single-file change)**, named in the agent doc and configurable by the same
mechanism chosen in decision 1 (so the epic carries one consistent knob style). The diaboli
should stress the bound and confirm a trivial diff demonstrably stays on the cheap path.

### 6.1 Decision summary for the GATE

| Decision | Options | Recommendation |
| --- | --- | --- |
| D7 repo-size threshold | metric (file count / constraint count / LOC); default value; mechanism (M1 HARNESS.md / M2 MODEL_ROUTING.md / M3 prose) | **file count; default 300; M1 optional `HARNESS.md` field**, default 300 when absent — consistent with S3 |
| Verification split | all-deterministic / **structural declarations + agent-backed live properties** | **structural declarations are the deterministic shadow; live separate-context + live fan-out stay agent-backed; MAX_REVIEW_CYCLES stays unverified/declared** |
| D5 trigger | T1 always / **T2 non-trivial only** / T3 orchestrator-decides | **T2 — non-trivial only, default `> 2 files changed`, configurable by decision-1's mechanism** |

---

## 7. CI, version, and docs checklist

### 7.1 Version bump — a behavioural change to existing agents/commands (minor)

Adding workflow mode to four existing agents and documenting it in two commands is a
**behavioural addition to existing components** → **minor bump `0.60.0 → 0.61.0`** (current
version confirmed **`0.60.0`** in `plugin.json`). The `Version Check` CI enforces **five**
locations (per CLAUDE.md / the live `version-check.yml`). Update **every** one:

1. `ai-literacy-superpowers/.claude-plugin/plugin.json` — `"version"` (canonical; `0.60.0` →
   `0.61.0`)
2. `README.md` — shields.io **badge** `ai--literacy--superpowers-v0.61.0` (currently `v0.60.0`)
3. `CHANGELOG.md` — new top heading `## 0.61.0 — 2026-06-22`
4. `.claude-plugin/marketplace.json` — top-level `plugin_version` (currently `0.60.0`; owned by
   ai-literacy-superpowers PRs)
5. `.claude-plugin/marketplace.json` — the `ai-literacy-superpowers` `plugins[].version` entry
   (currently `0.60.0`)

Also update, for human-facing consistency (**not** CI-enforced): the `README.md` plugin-table
row cell (`| v0.60.0 |` → `| v0.61.0 |`).

> The marketplace listing `version` does **not** change — S4 alters no listing contract (no
> description/keyword/permission/plugins-array/source change). The component-count badges
> (Skills/Agents/Commands) do **not** change — S4 adds no new component, only modifies six
> existing files.

Before committing, grep for the **old** version to surface every spot at once:

```text
grep -rn 'v0\.60\.0\|0\.60\.0' README.md .claude-plugin/marketplace.json \
  ai-literacy-superpowers/.claude-plugin/plugin.json CHANGELOG.md
```

If a rebase surfaces a `plugin_version` conflict from a non-`ai-literacy-superpowers` PR, take
main's value verbatim (CLAUDE.md Marketplace-versioning rule) — this PR owns the top-level
pointer only because it bumps this plugin.

### 7.2 CI gates

- **`spec-first-check`** — satisfied by **this spec being the first commit** on branch
  `dynamic-workflows-s4-adversarial-deepresearch`. No exemption label; this is feature work.
- **`tdad-scenario-check`** — S4 **modifies** existing agents/commands rather than adding new
  components. The gate fires on *added* components, so it does **not strictly force** new
  scenarios for a modification. **However**, this is a behavioural addition and warrants
  scenarios. `code-reviewer` has **no scenario directory yet**
  (`tdad_tests/scenarios/agents/code-reviewer/` does not exist); `advocatus-diaboli`,
  `assessor`, and `harness-auditor` likewise need directories for the new declarations. The
  **tdd-agent will create these directories** and author the structural scenarios (AC-2, AC-3,
  AC-5, AC-7, AC-8, AC-9, AC-10, AC-11), mirroring the S3 scenario set under
  `tdad_tests/scenarios/agents/harness-enforcer/`. Spec-writer **names** these so the tdd-agent
  has unambiguous homes; spec-writer does **not** create any directory or test file (spec-first
  discipline — no test files in this commit).
- **The deterministic content test** — the tdd-agent authors a new
  `tdad_tests/tests/test_s4_adversarial_deepresearch_structural.py`, mirroring
  `test_s3_enforcer_fanout_structural.py` (a `_workflow_section(...)` helper that slices the
  "Workflow mode" heading per agent file; phrase assertions per AC), and **wires it into the
  existing `.github/workflows/tdad-tests-fast.yml`** as a new step (a sibling of the existing
  `Run Layer 1 (dynamic-workflows S3 enforcer fan-out)` step). Spec-writer **notes** this; the
  tdd-agent authors and wires it. **Do not author tests in this commit.**
- **`INV-1 firewall` (S2, existing)** — S4 modifies **no `*.workflow.js` template**, so the
  firewall is **not triggered by new template content**. The agents' own *reads* and the
  assessor/auditor writing **their own report artefacts** are agent behaviours, not a workflow
  spelling a durable curated filename in executable code, so they are outside the firewall's
  scope. (If the tdd-agent adds any fixture that is a `.workflow.js`, it must itself pass the
  firewall — but the recommended fixtures are structural scenarios, not workflows.)
- **`lint-markdown`** — the four modified agent docs, the two modified command docs, this spec,
  and any touched docs page must pass markdownlint (PreToolUse hook + CI).
- **`Choice cartographer` / objection gates** — this feature PR proceeds through the plugin's
  own pipeline (spec → diaboli → adjudicate → plan → implement). Dispositions on any objection
  record must be resolved before the plan-approval GATE.

### 7.3 Docs-impact note (CLAUDE.md "Docs Site Review")

- **Reference (`docs-reference-parity-check`) — no NEW component, so no new entry forced.** S4
  adds no new skill/agent/command, so the parity gate is satisfied with no new heading. **But**
  the existing `### code-reviewer`, `### advocatus-diaboli`, `### assessor`, and
  `### harness-auditor` entries in `docs/plugins/ai-literacy-superpowers/reference/agents.md`
  should be **updated** to mention the new **workflow mode** so the reference does not describe
  only the single-context behaviour. This is a *consistency* update, not a parity requirement.
- **How-to (touch-up).** `docs/plugins/ai-literacy-superpowers/how-to/dynamic-workflows.md`
  (the orientation guide) should note that `code-reviewer`, `assessor`, and `harness-auditor`
  now elect `adversarial-review.workflow.js` / `deep-assessment.workflow.js` above their
  triggers — extending the S3 dogfooding line ("templates the plugin's own agents already
  adapt"). The existing `how-to/review-code-with-cupid.md` and `how-to/run-an-assessment.md` /
  `how-to/run-a-harness-audit.md` should each gain a short "for large changes/repos, the agent
  elects its workflow mode" note. Consistency touch-ups, not new pages.
- **Explanation / tutorials.** None required — the adversarial-verification and deep-research
  concepts already live in the skill's `references/patterns.md` (S1) and the
  `adversarial-review` / `deep-assessment` preambles (S2). No existing explanation page
  describes these agents' single-context behaviour as a fixed property S4 would contradict.

---

## 8. FR → acceptance-scenario mapping

| FR | Covered by | Slot |
| --- | --- | --- |
| FR-1 | AC-2 | deterministic (structural) |
| FR-2 | AC-2 (structural shadow of AC-1) | deterministic (structural) / agent-backed (AC-1) |
| FR-3 | AC-3 (structural shadow of AC-1) | deterministic (structural) / agent-backed (AC-1) |
| FR-4 | AC-4 | unverified (declared) |
| FR-5 | AC-2, AC-11 | deterministic (structural) |
| FR-6 | AC-5 | deterministic (structural) |
| FR-7 | AC-7 (structural shadow of AC-6) | deterministic (structural) / agent-backed (AC-6) |
| FR-8 | AC-8 (structural shadow of AC-6) | deterministic (structural) / agent-backed (AC-6) |
| FR-9 | AC-9 | deterministic (structural) |
| FR-10 | AC-10 | deterministic (structural) |
| FR-11 | AC-11 | deterministic (structural) |
| FR-12 | (CI: Version Check) | deterministic |
| FR-13 | (docs-impact; reference + how-to touch-up) | deterministic (presence) |

**Agent-backed runtime scenarios** (not deterministic; see §6 decision 2):

- **AC-1** — review runs in a context window distinct from the implementer's — runtime/
  behavioural; structural shadow is AC-2/AC-3 (FR-2/FR-3).
- **AC-6** — above-threshold fan-out-by-area with per-finding separate-agent verification —
  runtime/behavioural; structural shadow is AC-7/AC-8 (FR-7/FR-8).

**Unverified / declared:**

- **AC-4** — `MAX_REVIEW_CYCLES=3` holds under workflow mode — declared; structural shadow is
  AC-3's section statement (FR-4). Must **not** be over-promised as deterministic.

---

## 9. Risks and open questions

**Risks.**

- *Over-orchestration (umbrella §7).* The temptation is to fan out a per-property panel or a
  deep-research scan on every review/assessment. Mitigation: §6 decision 3's non-trivial
  trigger and decision 1's repo-size threshold keep the cheap single-context path the default
  below the bound — exactly the S3 "strict threshold, cheap default" shape.
- *INV-1 mis-application.* The honest hazard here is **over-restricting** the assessor/auditor:
  INV-1 forbids the four durable curated artefacts, **not** the assessment report or the
  auditor's existing HARNESS.md-Status / README-badge writes. Mitigation: §2.1(3–4) and AC-11
  state the precise boundary — the *workflow* proposes findings only; the *agent* writes its
  own report as today. The diaboli should reject any wording that forbids the assessor from
  writing its assessment.
- *Over-promising determinism.* Separate-context (AC-1) and live fan-out (AC-6) are agent-
  backed; tagging them deterministic would overclaim. Mitigation: §6 decision 2 fixes the
  honest split, as in S3.
- *Scenario-home omission.* None of the four agents has a workflow-mode scenario directory; a
  behavioural addition without one leaves the new modes unverified. Mitigation: §7.2 names the
  directories the tdd-agent must create, the structural assertion set, the new content test
  file, and its `tdad-tests-fast.yml` wiring.
- *Template drift.* The agents point at S2 templates whose runtime call shapes may drift from
  the authoritative docs. Mitigation: the agents ADAPT the templates and defer function names to
  <https://code.claude.com/docs/en/workflows>; S4 freezes no call signature and edits no
  template.
- *Uniform-shape over-reach.* The disposition is "uniform shape, specialise only where an agent
  demands it." The auditor's **self-preference guard** (AC-8) is the one demanded
  specialisation; the assessor does not carry it. Mitigation: AC-7 vs AC-8 keep the shared shape
  shared and the one specialisation explicit.

**Open questions.** None block S4. Umbrella open questions ride later slices (Q2 routing → S5,
Q3 staging → S6, Q4 Copilot → S7) and are out of scope (§2.2). The S4-internal decisions (the
repo-size threshold metric/value/mechanism, the verification split, the D5 trigger) are
**surfaced for the GATE in §6, not left open** — the spec recommends and the human disposes.

---

## 10. References

- Umbrella spec:
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
  (read-first runtime-scope note; §2 INV-1/INV-2; **D5**; **D7**; §5; §6; §7).
- Slicing record: `docs/superpowers/slices/dynamic-workflows-alignment.md`
  (Runtime-scope section; **S4** entry — uniform adversarial-verification shape, specialise
  only where demanded).
- Proven precedent (S3, merged):
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-s3-enforcer-fanout-design.md`;
  `ai-literacy-superpowers/agents/harness-enforcer.agent.md` (the "Workflow mode" section
  pattern); `tdad_tests/tests/test_s3_enforcer_fanout_structural.py` (the deterministic
  structural-content test pattern); `tdad_tests/scenarios/agents/harness-enforcer/` (the
  scenario-file shape); `.github/workflows/tdad-tests-fast.yml` (the test-wiring pattern).
- Shipped templates S4 adapts:
  - `ai-literacy-superpowers/skills/dynamic-workflows/workflows/adversarial-review.workflow.js`
    (D5 — separate-context review, per-property verifiers, synthesise-not-collapse).
  - `ai-literacy-superpowers/skills/dynamic-workflows/workflows/deep-assessment.workflow.js`
    (D7 — fan-out-by-area, per-finding adversarial verify, cited report; the auditor variant's
    framework-assumption-challenging verifier).
  - `ai-literacy-superpowers/scripts/inv-firewall.sh` (the INV-1/INV-2 firewall; untouched).
- Target files S4 modifies:
  - `ai-literacy-superpowers/agents/code-reviewer.agent.md`
  - `ai-literacy-superpowers/agents/advocatus-diaboli.agent.md`
  - `ai-literacy-superpowers/agents/assessor.agent.md`
  - `ai-literacy-superpowers/agents/harness-auditor.agent.md`
  - `ai-literacy-superpowers/commands/assess.md`
  - `ai-literacy-superpowers/commands/harness-audit.md`
- Runtime API (authoritative): <https://code.claude.com/docs/en/workflows>.
- AGENTS.md decisions consulted: the "recommended option is a hypothesis for the diaboli"
  STYLE note; "a consumer never mutates the contract it consumes" (S4 adapts but does not edit
  the S2 templates).
