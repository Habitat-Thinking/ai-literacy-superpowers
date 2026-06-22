# Specification — Dynamic Workflows S2: Template Library + INV-1/INV-2 Firewall

**Plugin:** `ai-literacy-superpowers` (Habitat-Thinking)
**Slice:** S2 of the Dynamic Workflows Alignment epic (D2 + §5.1 + §5.2 clustered)
**Umbrella spec:** `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
**Slicing record:** `docs/superpowers/slices/dynamic-workflows-alignment.md` (§ S2)
**Issue:** <https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/439>
**Depends on:** S1 (#438, merged) — the `dynamic-workflows` skill is the vehicle
**Spec status:** Draft for implementation
**Spec version:** 0.1.0
**Owner:** Russ Miles / Habitat Thinking
**Branch:** `dynamic-workflows-s2-templates`

> **Implementer note (read first).** This slice ships **four illustrative
> JavaScript workflow templates** plus the **deterministic firewall** that guards
> them. The templates are *templates an agent ADAPTs*, never verbatim scripts.
> The *exact* runtime function names for spawning subagents, selecting per-agent
> models, and electing worktree isolation are **not authoritative in this spec** —
> consult <https://code.claude.com/docs/en/workflows> as the source of truth and
> defer every function name to it. Where this spec or a template shows a call
> shape, treat it as ADAPTABLE pseudocode, not a frozen API. The firewall must
> match *write-shaped behaviour*, not specific runtime function names, precisely
> so it survives API drift.
>
> **Runtime scope — Claude Code only.** Dynamic workflows are a Claude Code
> runtime capability, **not transferable** to Copilot CLI or any other coding
> agent — those trees have no workflow runtime. The plugin ships to both trees,
> so the templates this slice adds are **Claude-Code-gated**: where the runtime
> exists they are adaptable, runnable substrate; where it does not (Copilot CLI,
> other agents) they are **inert reference material** — readable JavaScript with a
> literate preamble, but nothing spawns. Each template's preamble must state this
> boundary explicitly. See the umbrella spec's runtime-scope note and §5.5; the
> precise Copilot degradation *contract* (guidance-only vs omit) is open-question
> 4, resolved in S7, and is **not** decided here.

---

## 1. Context and motivation

S1 (#438, merged) shipped the `dynamic-workflows` skill as **knowledge agents
read** — the six patterns, the election rubric, INV-1/INV-2 — and forward-
referenced a workflow template library as *forthcoming (S2)*. S2 makes that
library concrete and, in the same slice, builds the **firewall that gives INV-1
its teeth**.

Per umbrella §6 the build order places **D2** (the template substrate) third,
immediately after the foundation, and §5.1 attaches the deterministic firewall
that "is INV-1's teeth — do not ship without it" (umbrella §7, governance-erosion
risk). The slicing record keeps the two **atomic**: a template library without
the firewall is the exact regression the spec warns against (a template could
land that writes a durable artefact, eroding the curated theory of the system —
Naur). So S2 ships:

- the **four workflow templates** (`enforcer-fanout`, `adversarial-review`,
  `reflection-mining`, `deep-assessment`), each with a Knuth-discipline literate
  preamble, a declared token budget, and a default model tier per agent role;
- `SKILL.md` **flipped** from "forthcoming (S2)" to "shipped", referencing the
  four templates **by relative path** and prompting agents to ADAPT, not run
  verbatim;
- the **INV-1 CI firewall** — a deterministic check that fails CI if any template
  *writes directly* to a durable artefact (`HARNESS.md`, `AGENTS.md`,
  `CLAUDE.md`, `MODEL_ROUTING.md`);
- the **INV-2 lint** — a deterministic check that any template spawning an
  untrusted-content reader withholds high-privilege tools from it;
- a **parse/reference check** that each `*.workflow.js` is valid JavaScript and
  that `SKILL.md`'s template references resolve.

The central, GATE-bound decision is **how the INV-1 firewall is mechanised
deterministically** (§7). Everything else in S2 is substrate that the firewall
guards.

---

## 2. Scope

### 2.1 In scope (this slice)

1. **Four workflow templates** under
   `ai-literacy-superpowers/skills/dynamic-workflows/workflows/`:
   - `enforcer-fanout.workflow.js` — fan-out-and-synthesize + adversarial
     verification; one verifier subagent per HARNESS.md constraint, a skeptic
     persona, a synthesis barrier. (Substrate the S3 enforcer adapts.)
   - `adversarial-review.workflow.js` — adversarial verification; review in a
     **separate context window** from the producing context, per-rubric-property
     verifiers. (Substrate the S4 code-reviewer adapts.)
   - `reflection-mining.workflow.js` — generate-and-filter + adversarial
     verification; clusters `REFLECTION_LOG.md`, adversarially pre-filters, emits
     a vetted shortlist. **Never writes `AGENTS.md`.** (Substrate the S6 `--mine`
     mode adapts.)
   - `deep-assessment.workflow.js` — fan-out-by-area + adversarial verification;
     the deep-research shape. (Substrate the S4 assessor/auditor adapts.)
   Each template carries a **literate preamble** (Knuth discipline) stating: its
   **intent**; the **pattern** it composes; the **model-tier + token-budget
   rationale**; the **INV-1 boundary** it respects (which durable artefacts it
   may only *propose* to); and the **Claude-Code-only runtime-scope** note (inert
   reference material where the runtime is absent). Each **declares a token
   budget and a default model tier per agent role** (umbrella D8 acceptance).
2. **`SKILL.md` flipped to "shipped".** The "## The workflow template library
   (forthcoming — S2)" section becomes a "shipped" section that references the
   four templates **by relative path** (`workflows/<name>.workflow.js`) and
   prompts agents to treat them as **templates to ADAPT, not run verbatim**. No
   other S1 content changes except this section.
3. **INV-1 CI firewall** — a new deterministic gate (mechanism per §7, decided at
   the GATE) that greps the templates and **fails CI** if any template writes
   directly to a durable artefact.
4. **INV-2 lint** — a deterministic gate that any template spawning an
   untrusted-content reader withholds high-privilege tools from it, made
   matchable by a **declared in-template convention** (marker shape per §7,
   decided at the GATE).
5. **Parse + reference-resolution check** — each `*.workflow.js` is valid
   JavaScript (parses without syntax error) and each template path referenced
   from `SKILL.md` resolves to an existing file.
6. **Reconciliation of the S1 TDAD scenario** that asserts SKILL.md contains *no*
   hard-link to a `.workflow.js` file (see §6). The tdd-agent revises/replaces
   `tdad_tests/scenarios/skills/dynamic-workflows/markdownlint-clean.md`.
7. **Supporting CI / version / docs surfaces** (see §8): the minor version bump
   `0.58.1 → 0.59.0` across the five CI-enforced locations + the README table
   cell, and a how-to update now that runnable templates exist.

### 2.2 Out of scope (explicitly deferred — do not blur)

| Deferred concern | Owning slice | Why not here |
| --- | --- | --- |
| `harness-enforcer` workflow mode + fan-out **threshold (= 8)** | **S3 (#440)** | S2 ships the template; the enforcer *adapts* it later. The threshold rides open-question 1 |
| `code-reviewer` / `assessor` / `harness-auditor` workflow modes | **S4 (#441)** | S2 ships `adversarial-review`/`deep-assessment` templates; the agents adopt them later |
| `orchestrator` classify-and-act routing + routing default | **S5 (#442)** | Riding open-question 2 |
| `reflect --mine` mode + **staging-artefact location** (`REFLECTION_STAGING.md`) | **S6 (#443)** | S2 ships `reflection-mining.workflow.js`; the command wires it later. Riding open-question 3 |
| README "Dynamic Workflows" section, advisory Stop hook, **Copilot degradation contract** | **S7 (#444)** | Per umbrella D9; open-question 4 |
| Skill-count badge | **already correct (S1 landed `Skills-36`)** | S2 adds **no new skill** — only files inside an existing skill; the badge does not move |

**Boundary rule.** S2 ships the templates as **reference substrate the later
agent slices ADAPT** — it does **not** wire any agent or command to a template.
No `agents/*.agent.md` or `commands/*.md` file is modified in S2. The only
behavioural surface S2 touches is the skill (flip to shipped) and the new CI
gates.

---

## 3. User story

> **As an** agent (or engineer) operating inside the ai-literacy-superpowers
> harness, **I want** a small library of habitat-aligned workflow templates I can
> ADAPT — each one literate about its intent, pattern, budget, and the
> durable-artefact boundary it respects — together with a deterministic firewall
> that fails CI if any template would write a durable artefact, **so that** I can
> reach for a proven workflow shape per task without re-deriving it, and so that
> the curated theory of the system (INV-1) is protected by a machine, not by good
> intentions.

This is INV-1 ("ephemeral proposes, durable curates") given **teeth**: the
firewall is the deterministic enforcement that makes the invariant load-bearing
rather than aspirational.

---

## 4. Acceptance scenarios (Given / When / Then)

Each scenario carries its **verification-slot** tag from the umbrella taxonomy:
*deterministic* (CI-checkable), *agent-backed* (checked by an agent / Layer-2-3
TDAD), or *unverified* (declared intent). The tdd-agent should turn the
deterministic and agent-backed scenarios into failing checks first. Scenarios
trace to umbrella **D2 acceptance**, **§5.1** (INV-1 firewall) and **§5.2**
(INV-2 lint).

### From D2 — the template substrate

**AC-1 *(deterministic)* — four templates exist with literate preambles.**
**Given** the `dynamic-workflows` skill,
**When** `skills/dynamic-workflows/workflows/` is read,
**Then** exactly the four files `enforcer-fanout.workflow.js`,
`adversarial-review.workflow.js`, `reflection-mining.workflow.js`, and
`deep-assessment.workflow.js` exist, and each opens with a literate preamble (a
top-of-file comment block) naming its **intent**, its **pattern**, its
**model-tier + token-budget rationale**, the **INV-1 boundary** it respects, and
the **Claude-Code-only runtime scope** (inert where the runtime is absent).

**AC-2 *(deterministic)* — each template parses as valid JavaScript.**
**Given** each `*.workflow.js` file,
**When** it is parsed (Node `--check` / an equivalent syntax parse),
**Then** it parses with no syntax error.

**AC-3 *(deterministic)* — SKILL.md references each template by resolving relative path.**
**Given** `SKILL.md` flipped to its "shipped" framing,
**When** it is read,
**Then** it references **all four** templates by relative path
(`workflows/<name>.workflow.js`), every referenced path **resolves to an existing
file**, and the framing is "shipped — ADAPT, do not run verbatim" (the
"forthcoming (S2)" wording is gone).

**AC-4 *(deterministic)* — each template declares a token budget and per-role model tier.**
**Given** each `*.workflow.js` file,
**When** it is read,
**Then** it declares an explicit **token budget** (a per-workflow cap) and a
**default model tier per agent role** (umbrella D8 acceptance). *(Slot note: the
machine-checkable form is a declared marker the parse check greps; see §7.2.)*

**AC-5 *(agent-backed)* — an agent ADAPTs rather than runs verbatim.**
**Given** a task that matches one of the four patterns,
**When** an agent loads the corresponding template,
**Then** it ADAPTs the template to the task (parameterises agents, budget, tiers)
rather than executing it verbatim, and cites the pattern from
`references/patterns.md`.

### From §5.1 — the INV-1 firewall (the central decision, §7)

**AC-6 *(deterministic)* — no template writes a durable artefact.**
**Given** every `*.workflow.js` under `skills/dynamic-workflows/workflows/`,
**When** the INV-1 firewall runs,
**Then** it **passes** because no template contains a **direct write** to
`HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, or `MODEL_ROUTING.md`.

**AC-7 *(deterministic)* — a planted direct write fails CI (true positive).**
**Given** a template that writes one of the four durable artefacts directly (the
firewall's failing fixture),
**When** the firewall runs,
**Then** it **fails CI** with a message naming the offending file, the durable
artefact, and the INV-1 rule. *(This is the firewall's red-bar test; the
tdd-agent authors it as a fixture, not in a shipped template.)*

**AC-8 *(deterministic)* — a literate preamble that merely mentions a durable artefact does NOT trip the firewall (no false positive).**
**Given** a template whose **literate preamble** names `AGENTS.md` (e.g.
"this workflow only *proposes* entries; it never writes `AGENTS.md`"),
**When** the firewall runs,
**Then** it **passes** — the rule matches **write-shaped patterns**, not bare
filename mentions. *(This guards the false-positive failure mode the slice
decision_focus calls out: a bare mention in a Knuth preamble must not redden CI.)*

**AC-9 *(deterministic)* — `reflection-mining` is firewall-clean specifically on AGENTS.md.**
**Given** `reflection-mining.workflow.js` (the template most tempted to write
`AGENTS.md`),
**When** the firewall runs,
**Then** it passes: the template emits a shortlist to a **non-durable** sink and
contains no direct write to `AGENTS.md`. *(Names the highest-risk template
explicitly; the staging-artefact *destination* is an S6 decision and is not fixed
here — the template's preamble states only that it never writes `AGENTS.md`.)*

### From §5.2 — the INV-2 lint

**AC-10 *(deterministic)* — untrusted-content readers withhold high-privilege tools.**
**Given** any template that spawns an agent **declared** (by the in-template
convention, §7.3) as an untrusted-content reader,
**When** the INV-2 lint runs,
**Then** it confirms that agent's declared tool set **excludes** every
high-privilege tool, and **fails CI** if such an agent is granted one.

**AC-11 *(deterministic)* — a template with no untrusted reader passes the INV-2 lint vacuously.**
**Given** a template that declares no untrusted-content reader,
**When** the INV-2 lint runs,
**Then** it passes (the lint is scoped to declared untrusted readers, not all
agents).

### Cross-cutting — runtime scope

**AC-12 *(deterministic)* — every template preamble states the Claude-Code-only scope.**
**Given** each `*.workflow.js`,
**When** its preamble is read,
**Then** it states that the template is Claude-Code-gated and is **inert
reference material** on a tree without the workflow runtime.

**AC-13 *(unverified, declared)* — S2 wires no agent or command to a template.**
S2 ships templates as reference substrate only; no `agents/*.agent.md` or
`commands/*.md` is modified. Adoption is S3–S6 work. (Recorded so the absence of
behavioural wiring is not mistaken for an oversight.)

---

## 5. Functional requirements

Numbered and testable; each maps to one or more acceptance scenarios in §9.

- **FR-1.** Four templates exist at
  `ai-literacy-superpowers/skills/dynamic-workflows/workflows/{enforcer-fanout,adversarial-review,reflection-mining,deep-assessment}.workflow.js`.
- **FR-2.** Each template opens with a literate preamble naming intent, pattern,
  model-tier + token-budget rationale, the INV-1 boundary it respects, and the
  Claude-Code-only runtime scope.
- **FR-3.** Each template declares an explicit token budget and a default model
  tier per agent role, in a form the parse/marker check can confirm.
- **FR-4.** Each `*.workflow.js` is valid JavaScript (parses with no syntax
  error).
- **FR-5.** `SKILL.md`'s template-library section is flipped from "forthcoming
  (S2)" to "shipped", references all four templates by relative path, every
  referenced path resolves, and the framing instructs agents to ADAPT, not run
  verbatim.
- **FR-6.** A deterministic **INV-1 firewall** gate (mechanism per §7) fails CI
  if any template contains a **direct write** to `HARNESS.md`, `AGENTS.md`,
  `CLAUDE.md`, or `MODEL_ROUTING.md`, and does **not** fire on bare filename
  mentions in a preamble.
- **FR-7.** A deterministic **INV-2 lint** gate confirms that any template-
  declared untrusted-content reader is withheld every high-privilege tool, using
  an in-template convention (marker shape per §7.3) the lint matches.
- **FR-8.** A deterministic **parse + reference-resolution** check confirms each
  template parses and each `SKILL.md` template reference resolves.
- **FR-9.** The S1 TDAD scenario asserting "no hard-link to a `.workflow.js`"
  (`tdad_tests/scenarios/skills/dynamic-workflows/markdownlint-clean.md`) is
  revised/replaced so that S2's *shipped* references are correct, not a
  violation (see §6).
- **FR-10.** The plugin version is bumped `0.58.1 → 0.59.0` across all five
  CI-enforced locations (§8.1), and the human-facing README plugin-table cell is
  updated.
- **FR-11.** The how-to guide
  `docs/plugins/ai-literacy-superpowers/how-to/dynamic-workflows.md` (shipped in
  S1 as an orientation guide) is updated to reflect that runnable templates now
  exist and how to ADAPT them.

---

## 6. Reconciliation of the S1 TDAD scenario (do not miss)

S1 shipped, at
`tdad_tests/scenarios/skills/dynamic-workflows/markdownlint-clean.md`, a
**structural** scenario whose `Then` asserts:

> None of the files contain a runnable dependency on any `.workflow.js` file (the
> S2 template library); any mention of the template library is an explicit
> "forthcoming (S2)" forward-reference, not a link to a file that must exist.

S2 **flips this**: the four templates now exist and `SKILL.md` links them by
relative path. The S1 scenario's load-bearing clause becomes **false** under S2 —
it was correct *for S1's standalone-validity property* and is now superseded.

**Action for the tdd-agent.** Revise/replace that scenario so that:

- the markdownlint-clean assertion for `SKILL.md` + the three references is
  **retained** (still true and still valuable);
- the "no hard-link / forthcoming forward-reference" clause is **replaced** by an
  assertion matching S2 reality: `SKILL.md` references the four templates by
  relative path and **every referenced path resolves to an existing file** (the
  AC-3 property).

This is a **modification** of an existing scenario, not a new component, so the
`tdad-scenario-check` CI gate does not block it (that gate fires only on *added*
components, per Amendment 2 §A2.6 of the TDAD-discipline spec) — but the change
is mandatory for correctness and the markdownlint scenario must not assert a now-
false property. The tdd-agent owns the rewrite.

> **Why spec-writer flags this rather than editing the scenario.** Per the
> spec-first discipline, this spec does not modify test files. It *names* the
> superseded scenario and the required new assertion so the tdd-agent translates
> it without ambiguity.

---

## 7. The central decision — how the INV-1 firewall is mechanised (GATE)

This is the slice's load-bearing decision (carpaccio `decision_focus`). The human
decides at the plan-approval GATE. The spec lays out the options and a
recommendation; per the AGENTS.md STYLE note, the recommendation is a **hypothesis
for the diaboli to stress**, not a default to confirm — and this slice touches a
**closed contract** (a deterministic CI gate's match rule and a four-filename
denylist), exactly the kind of surface the diaboli should hammer for false
negatives and false positives.

### 7.1 What the grep rule matches as a "direct write to a durable artefact"

Two failure directions bound the design:

- **False negative** — a write expressed in a shape the grep misses (the durable
  artefact is silently mutated, INV-1 breached, CI green). This is the dangerous
  direction: it defeats the firewall's purpose.
- **False positive** — a literate preamble that merely *mentions* `AGENTS.md`
  trips the rule (CI reddens on honest documentation). This is the annoying
  direction: it punishes the Knuth discipline the slice mandates.

**Option A — Path-denylist of the four filenames (bare-mention match).** Grep for
any occurrence of `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `MODEL_ROUTING.md`.
*Rejected as the sole rule:* it false-positives on every literate preamble that
names a durable artefact to explain the INV-1 boundary it respects — i.e. it
punishes exactly the documentation the slice requires (AC-8 would fail). The four
filenames *must* appear in good templates' prose.

**Option B — Write-API pattern match.** Grep for write-shaped call patterns
(file-write / append / `writeFile`-family / `>>` redirection / fs-write idioms)
**co-occurring** with one of the four durable filenames on the same logical
statement. *Strength:* targets behaviour, not mention — AC-8 passes. *Weakness:* a
write expressed via an indirection the pattern does not enumerate (a filename held
in a variable, a path built by concatenation, a runtime helper not in the
enumerated set) is a **false negative**. The runtime API is authoritative and may
evolve (implementer note), so any frozen function-name list rots.

**Option C — Both, layered (RECOMMENDED).** Combine a **write-shaped pattern
match** (Option B — the precision layer that avoids false positives) with a
**defence-in-depth path-proximity rule**: any of the four durable filenames
appearing **outside a comment/preamble block** (i.e. in executable code, not in
the literate preamble or a string that is demonstrably documentation) is treated
as suspicious and must co-occur with a write-shaped token to fail — OR, more
strictly, flagged for the firewall to fail unless the line is a comment. The rule
therefore:

1. **strips comment/preamble lines** (the literate preamble is comments — a bare
   `AGENTS.md` mention there never trips the rule → AC-8 passes);
2. on the **remaining executable lines**, fails if a durable filename co-occurs
   with a write-shaped token (`write`, `append`, `writeFile`, `>>`, `fs.` write
   idioms, or the runtime's persist/write helpers) — catching Option B's target;
3. additionally fails if a durable filename appears in executable (non-comment)
   code **at all** without a recognised *read-only / propose-only* annotation —
   closing Option B's false-negative gap, because a template has **no legitimate
   reason to name a durable artefact in executable code** except to touch it
   (templates *propose* via a non-durable sink, they do not reference the durable
   file by name in code).

   This third clause is the key insight: in a *template*, a durable filename in
   **executable code** (not preamble prose) is itself the smell, regardless of
   whether the grep recognises the specific write call. It converts the
   open-ended "did we enumerate every write API?" problem into a closed "does
   executable code name a durable artefact at all?" check — robust to runtime API
   drift (the implementer-note concern).

**Recommendation: Option C.** Comment-stripping kills the false positive (AC-8);
the "no durable filename in executable code" clause kills the false negative
(AC-6/AC-7/AC-9) without depending on a frozen write-API enumeration. The diaboli
should stress: (a) can a template legitimately need a durable filename in
executable code? (if yes, Option C over-blocks and needs an escape hatch); (b)
does comment-stripping correctly classify a durable filename inside a
**multi-line string literal** that is documentation, not a comment? (decide
whether such strings count as preamble or code).

### 7.2 Where the firewall runs

**Option W1 — A dedicated new `.github/workflows/` check** mirroring
`spec-redaction-marker-check.yml` (line-anchored grep, `paths:` scoped to
`skills/dynamic-workflows/workflows/**` + the workflow file itself, `::error::`
annotations, non-zero exit). *Strength:* PR-time gate, blocks the merge, mirrors a
proven house style, runs on exactly the touched paths. *Recommended primary
home.*

**Option W2 — A Layer-0 deterministic test under `tdad_tests/`** (a
`layer0_deterministic/test-inv1-firewall.sh` registered in
`BASH_TEST_SCRIPTS`, run by `tdad-tests-fast.yml`). *Strength:* lives with the
other deterministic plumbing, runs in the existing fast suite, testable in
isolation with red/green fixtures (AC-7/AC-8 as fixtures the script asserts
against). *Recommended companion* — the firewall logic as a bash script with its
own fixtures, dispatched both by the fast suite and (optionally) by the dedicated
workflow.

**Option W3 — A HARNESS.md GC rule in `gc.yml`.** *Rejected as primary:* `gc.yml`
runs weekly on cron, not at PR time — a breaching template could sit on `main` for
up to a week. The firewall is a **gate**, and gates run at PR time. A GC echo is
acceptable as defence-in-depth but must not be the only home.

**Recommendation: W1 + W2 layered.** Author the firewall as a **single bash
script** (the matching logic of §7.1 Option C) and invoke it from **both** (a) a
dedicated PR-time GitHub workflow (W1, the blocking gate) and (b) a Layer-0
deterministic test (W2, where the red/green fixtures of AC-7/AC-8 live and prove
the matcher's precision). One implementation, two dispatch points — the matcher's
correctness is proven by fixtures in W2 and enforced at the merge by W1. This
mirrors the existing pattern where one bash script (e.g. the affordance scanners)
is exercised by a Layer-0 test and surfaced in CI. **Do not** put it solely in
`gc.yml` (W3).

> **Verification-table note.** The INV-1 firewall is itself a new deterministic
> gate and must be listed in §8.2 as a new CI surface.

### 7.3 How INV-2 is made lint-checkable on templates

For a deterministic lint to confirm "an untrusted-content reader is withheld
high-privilege tools", **both** concepts must be expressed in the template in a
shape the lint can match. The decision is the **convention a template must
follow**.

**Option I1 — A declared in-template marker convention (RECOMMENDED).** Each
agent a template spawns declares its trust posture and tool set in a structured,
greppable form — e.g. a comment-annotation or a structured field the template
author writes:

```text
// @workflow-agent: issue-triager
// @untrusted-reader: true        // reads external issue bodies
// @tools: [read, grep]           // NO write, NO bash, NO web-fetch-then-act
```

The lint then: finds every agent block marked `@untrusted-reader: true`; confirms
its `@tools` list contains **none** of a declared **high-privilege set**
(`write`, `edit`, `bash`, `commit`, `push`, or any durable-artefact write). A
template with no `@untrusted-reader: true` block passes vacuously (AC-11).
*Strength:* both halves (untrusted reader; high-privilege tool) are explicit and
machine-detectable; the convention doubles as literate documentation of the
quarantine. *Weakness:* relies on the author honestly marking a reader as
untrusted — a reader left unmarked escapes the lint. Mitigation: the firewall is
defence-in-depth, not the sole guard; the convention is documented in the skill's
`references/governance.md` (S1, INV-2) and the template preamble.

**Option I2 — Infer untrusted-reader from web/fetch tool presence.** No marker;
the lint infers "untrusted reader" from the presence of a web-fetch/external-read
tool, then checks no high-privilege tool co-occurs. *Rejected as primary:*
inference is brittle (an untrusted reader might read a third-party PR via a
non-web tool), and it conflates "reads external content" with a specific tool. The
marker (I1) is explicit and survives tool-name drift.

**Recommendation: I1**, the declared marker convention, documented in the
template preamble and cross-referenced to `references/governance.md` (INV-2). The
**high-privilege set** is enumerated in the lint (and mirrored in
`governance.md`): `write`, `edit`, `bash`/shell, `commit`, `push`, plus any write
to a durable artefact. The diaboli should stress whether the enumerated set is
complete and whether the vacuous-pass (AC-11) is the right default (it is — INV-2
is scoped to untrusted readers, not all agents).

### 7.4 Decision summary for the GATE

| Decision | Options | Recommendation |
| --- | --- | --- |
| INV-1 grep match rule | A path-denylist / B write-API / **C both layered** | **C** — strip comments, fail on write-shaped tokens AND on any durable filename in executable code (drift-robust) |
| INV-1 firewall home | W1 dedicated workflow / W2 Layer-0 test / W3 GC rule | **W1 + W2** — one bash matcher, dispatched by a PR-time gate and a fixtured Layer-0 test; not W3-only |
| INV-2 lint convention | I1 declared marker / I2 infer from tools | **I1** — `@untrusted-reader` + `@tools` markers, with an enumerated high-privilege set |

All three are surfaced for the human; the spec-writer recommends but does not
silently choose.

---

## 8. CI, version, and docs checklist

### 8.1 Version bump — adding templates is behavioural (minor)

Adding the workflow template library and two new CI gates is a **behavioural
addition** → **minor bump `0.58.1 → 0.59.0`** (current version confirmed
`0.58.1` in `plugin.json`). The `Version Check` CI enforces **five** locations
(per CLAUDE.md / the live `version-check.yml`). Update **every** one:

1. `ai-literacy-superpowers/.claude-plugin/plugin.json` — `"version"` (canonical;
   currently `0.58.1`)
2. `README.md` — shields.io **badge** `ai--literacy--superpowers-v0.59.0`
   (line 6; currently `v0.58.1`)
3. `CHANGELOG.md` — new top heading `## 0.59.0 — 2026-06-22`
4. `.claude-plugin/marketplace.json` — top-level `plugin_version` (currently
   `0.58.1`; owned by ai-literacy-superpowers PRs)
5. `.claude-plugin/marketplace.json` — the `ai-literacy-superpowers`
   `plugins[].version` entry (currently `0.58.1`)

Also update, for human-facing consistency (**not** CI-enforced): the `README.md`
plugin-table row cell (`| v0.58.1 |` → `| v0.59.0 |`, line 31).

> The marketplace listing `version` (`0.4.0`) does **not** change — S2 alters no
> listing contract (no description/keyword/permission/plugins-array change). The
> skill-count badge (`Skills-36`, line 9) and the "**36 skills**" table cell do
> **not** change — S2 adds no new skill, only files inside the existing
> `dynamic-workflows` skill.

Before committing, grep for the **old** version to surface every spot at once:

```text
grep -rn 'v0\.58\.1\|0\.58\.1' README.md .claude-plugin/marketplace.json \
  ai-literacy-superpowers/.claude-plugin/plugin.json CHANGELOG.md
```

### 8.2 CI gates

- **`INV-1 firewall` (NEW, deterministic gate).** The new gate from §7 — a
  dedicated GitHub workflow (W1) invoking the bash matcher, plus a Layer-0 test
  (W2) carrying its red/green fixtures. This is a **new** PR-time gate added to
  `.github/workflows/`. Listed here as a new CI surface per the umbrella's
  governance-erosion risk.
- **`INV-2 lint` (NEW, deterministic gate).** The marker-convention lint from
  §7.3, authored alongside the INV-1 matcher (same bash + Layer-0 home is
  natural). New CI surface.
- **`*.workflow.js` parse + reference-resolution (NEW, deterministic check).**
  Node `--check` (or equivalent) on each template + a path-resolution check for
  `SKILL.md`'s references. Naturally co-located with the Layer-0 firewall test.
- **`tdad-scenario-check`** — **not triggered** for S2's component changes:
  flipping `SKILL.md` is a *modification* of an existing component, and the gate
  fires only on *added* components. The four `*.workflow.js` files are not
  `SKILL.md`/`agent.md`/`command.md` component files, so they are not gated
  either. The S1 markdownlint scenario rewrite (§6) is a modification, not an
  addition.
- **`lint-markdown`** — the flipped `SKILL.md` section and the updated how-to must
  pass markdownlint (PreToolUse hook + CI). The `*.workflow.js` files are
  JavaScript, not markdown, and are not linted by this gate.
- **`spec-first-check`** — satisfied by this spec being the first commit on the
  branch `dynamic-workflows-s2-templates`. No exemption label; this is feature
  work.

### 8.3 Docs-impact note (CLAUDE.md "Docs Site Review")

- **Reference (already satisfied).** The `### dynamic-workflows` entry in
  `docs/plugins/ai-literacy-superpowers/reference/skills.md` already exists
  (shipped in S1). S2 adds **no new skill**, so the docs-reference-parity gate is
  satisfied with no new heading. A reference update describing the four templates
  is *optional* and may be folded into the how-to instead.
- **How-to (required update).** The orientation guide
  `docs/plugins/ai-literacy-superpowers/how-to/dynamic-workflows.md` (shipped in
  S1, which explicitly noted "runnable workflow templates arrive in S2") must be
  updated now that the templates exist: name the four templates, point at their
  relative paths, and show the ADAPT-not-run-verbatim discipline. This is the
  "feature adds runnable artefacts → update the how-to" obligation from CLAUDE.md.
- **Explanation / tutorials.** None required for S2 — no existing explanation page
  references behaviour S2 changes; the INV-1/INV-2 concepts already live in the
  skill's `references/governance.md` (S1).

---

## 9. FR → acceptance-scenario mapping

| FR | Covered by | Slot |
| --- | --- | --- |
| FR-1 | AC-1 | deterministic |
| FR-2 | AC-1, AC-12 | deterministic |
| FR-3 | AC-4 | deterministic |
| FR-4 | AC-2 | deterministic |
| FR-5 | AC-3 | deterministic |
| FR-6 | AC-6, AC-7, AC-8, AC-9 | deterministic |
| FR-7 | AC-10, AC-11 | deterministic |
| FR-8 | AC-2, AC-3 | deterministic |
| FR-9 | (§6 reconciliation; tdd-agent rewrites the S1 scenario) | deterministic |
| FR-10 | (CI: Version Check) | deterministic |
| FR-11 | (docs-impact; how-to update) | deterministic (presence) |

Agent-backed AC-5 (an agent ADAPTs rather than runs verbatim) maps to FR-5/FR-2
and is verified by a Layer-2/3 TDAD behavioural scenario if the tdd-agent elects
to add one; otherwise it stands as declared intent. AC-13 is unverified-declared
(no behavioural wiring in S2).

---

## 10. Risks and open questions

**Risks.**

- *Firewall false negative (the dangerous direction).* A durable-artefact write
  expressed in a shape the matcher misses passes CI and breaches INV-1.
  Mitigation: §7.1 Option C's "no durable filename in executable code" clause
  converts the open-ended write-API problem into a closed naming check robust to
  runtime API drift; the AC-7 fixture proves a planted write is caught.
- *Firewall false positive (the annoying direction).* A literate preamble naming
  `AGENTS.md` reddens CI, punishing the Knuth discipline S2 mandates. Mitigation:
  §7.1's comment-stripping + the AC-8 fixture proving a bare mention passes.
- *INV-2 unmarked-reader escape.* An untrusted reader left unmarked escapes the
  lint (§7.3 I1's weakness). Mitigation: documented convention in
  `references/governance.md` + template preamble; the lint is defence-in-depth,
  not the sole quarantine guard.
- *Template-API rot.* The shipped templates show ADAPTABLE call shapes that may
  drift from the authoritative runtime doc. Mitigation: the implementer note and
  every preamble defer function names to
  <https://code.claude.com/docs/en/workflows>; the firewall matches
  write-behaviour, not function names.
- *S1-scenario staleness.* The S1 markdownlint scenario asserts a now-false "no
  hard-link" property. Mitigation: §6's explicit reconciliation instruction to the
  tdd-agent.

**Open questions.** None block S2. The umbrella open questions all ride later
slices (Q1 threshold → S3, Q2 routing → S5, Q3 staging → S6, Q4 Copilot → S7) and
are out of scope here (§2.2). The one S2-internal decision — the firewall
mechanism (§7) — is **surfaced for the GATE, not left open**: the spec recommends
(7.1 C, 7.2 W1+W2, 7.3 I1) and the human disposes.

---

## 11. References

- Umbrella spec:
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-alignment-design.md`
  (read-first runtime-scope note; §2 INV-1/INV-2; D2; §5.1; §5.2; §6).
- Slicing record: `docs/superpowers/slices/dynamic-workflows-alignment.md`
  (Runtime-scope section; S2 entry).
- S1 spec (merged):
  `docs/superpowers/specs/2026-06-22-dynamic-workflows-s1-skill-design.md`.
- Shipped S1 skill:
  `ai-literacy-superpowers/skills/dynamic-workflows/SKILL.md` (the "## The
  workflow template library (forthcoming — S2)" section S2 flips; the "## Runtime
  scope — Claude Code only" section S2 preserves).
- Runtime API (authoritative): <https://code.claude.com/docs/en/workflows>.
- House-style firewall precedent: `.github/workflows/spec-redaction-marker-check.yml`
  (line-anchored grep, `::error::` annotations, scoped `paths:`).
- Layer-0 test precedent: `tdad_tests/tests/test_layer0_deterministic.py` +
  `tdad_tests/layer0_deterministic/test-*.sh` (bash matcher dispatched as a fast
  deterministic test).
- Knuth, "Literate Programming" (1984) — the preamble discipline on every
  template.
