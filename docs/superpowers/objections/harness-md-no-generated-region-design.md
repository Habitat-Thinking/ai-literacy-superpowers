---
spec: docs/superpowers/specs/2026-08-25-harness-md-no-generated-region-design.md
date: 2026-08-25
mode: spec
diaboli_model: claude-opus-5
objections:
  - id: O1
    category: premise
    severity: critical
    claim: "The spec's central dichotomy — one model, two kinds of artifact — has no second kind; the compiler has never written a generated region into any of the three control surfaces the spec names as the model's correct home."
    evidence: "§1.1: 'The region model is correct for the artifacts it was designed for — `.cursor/rules/`, `.windsurf/rules/`, `.github/copilot-instructions.md`.' Contradicted by `commands/harness-accept.md:161-164` ('It does not write into `.github/copilot-instructions.md`, `.cursor/rules/` or `.windsurf/rules/`') and `harness/surfaces.yaml:30-35` ('Compilation does not write into these files')."
    disposition: pending
    disposition_rationale: null
  - id: O2
    category: scope
    severity: high
    claim: "The carve-out is drawn per-file around the one target where the defect has never occurred, and leaves it in place in the one target where it already has."
    evidence: "§Scope: 'whether `HARNESS.md` carries a generated region'. `skills/advocatus-diaboli/SKILL.md:376-399` already carries an appended region sitting inside `## Output Format`, after `### Closing Section`. `harness/surfaces.yaml:24` routes `turn-instructions: AGENTS.md`, whose sections (`## STYLE`, `## GOTCHAS`, `## ARCH_DECISIONS`) carry meaning identically."
    disposition: pending
    disposition_rationale: null
  - id: O3
    category: risk
    severity: high
    claim: "A declined placement creates an accepted-but-unplaced record, a state the index, the enforcement report and the timeline feed all report as a rule in force."
    evidence: "§3.1: 'A declined placement leaves the record `accepted` and `HARNESS.md` untouched.' `harness-registrar.py:1386-1405` builds the enforcement report from `status == accepted` and never reads the target artifact; `render_index` (`:973`) derives 'in force' from `status == accepted`; `cmd_timeline` (`:1772`) emits it as an intervention."
    disposition: pending
    disposition_rationale: null
  - id: O4
    category: risk
    severity: high
    claim: "§1's 'This is not a failure state' is false, and the failure it misses is not removed by the fix: a rule placed in `## Garbage Collection` reaches no control surface, while the enforcement report claims advisory achievement on cursor, copilot and windsurf."
    evidence: "§1: 'This is not a failure state.' `commands/convention-sync.md:24-32` parses only `## Context > Conventions` and `## Constraints`. §3.1 routes rules declaring `**Frequency**` and `**Auto-fix**` to `## Garbage Collection`. `harness-registrar.py:1328-1342` computes achieved enforcement from `surfaces.yaml` supports and validator presence only."
    disposition: pending
    disposition_rationale: null
  - id: O5
    category: implementation
    severity: high
    claim: "The substring presence check passes on text that is inert or actively disavowed, so its green result does not mean what a reader will take it to mean."
    evidence: "§3.3: 'whether the record's rule text is present in the file at all — a substring presence check.' `HARNESS.md:625-652` contains two `<!-- Uncomment if ... -->` blocks; text pasted there, into a fenced block, or under a heading reading 'Withdrawn:' satisfies the check."
    disposition: pending
    disposition_rationale: null
  - id: O6
    category: implementation
    severity: high
    claim: "Nothing removes a superseded or withdrawn rule's text from `HARNESS.md`, and nothing detects that it is still there — a property the region model provides automatically and §2.1 does not list as given up."
    evidence: "§2.1 lists two checks and calls the account 'precisely'. `harness-registrar.py:1466-1489`: 'Withdrawing the last rule from a file has to actually remove it' — that path regenerates any target that still carries a region, with an empty region. §3.3's check only asserts presence for accepted records; it never asserts absence."
    disposition: pending
    disposition_rationale: null
  - id: O7
    category: specification quality
    severity: high
    claim: "The spec never says whether an absent rule fails the build, and it removes the repair command the existing 'unapplied' vocabulary is paired with, leaving two defensible implementations with opposite consequences."
    evidence: "§3.3: 'reported as **unapplied**, which is the existing vocabulary'. `harness-registrar.py:1814-1819` appends unapplied to `problems`, which exits 1. `commands/harness-check.md:61` gives the remedy as '**Never applied** — `/harness-compile`'. §3.4: 'Compilation skips `HARNESS.md`.' Criterion 6 specifies what is reported and is silent on exit status."
    disposition: pending
    disposition_rationale: null
  - id: O8
    category: alternatives
    severity: high
    claim: "The per-rule marker is rejected on a cost that does not exist, while the chosen design imposes a larger and invisible one; and the condition for reopening it has no owner, no expiry and no mechanism."
    evidence: "§6: 'Not taken because it buys byte-verification of placement at the cost of another marker idiom in the file this spec is trying to keep human-editable' and '**The strongest alternative, and the one to reopen on** if PR review turns out not to catch a mis-placed or reworded rule.' An HTML comment does not render. §3.3's check requires the placed text to stay byte-exact in a file headed 'Edit freely — this is your document.'"
    disposition: pending
    disposition_rationale: null
  - id: O9
    category: specification quality
    severity: medium
    claim: "The spec introduces a third approval gate and abandons the all-or-nothing acceptance transaction without citing or engaging either documented position it reverses."
    evidence: "§3.1: 'Writes only on confirmation.' Against `commands/harness-accept.md:150-157` ('Applying and compiling are deliberately **not** separate approval gates... a gate with no decision behind it is the exact shape of approval theatre') and `harness-registrar.py:831-838`, which refuses the whole acceptance 'rather than leaving a record accepted and unapplied'."
    disposition: pending
    disposition_rationale: null
  - id: O10
    category: alternatives
    severity: medium
    claim: "Section choice is inferred from the shape of the rule's markdown when the repository already has an established mechanism for exactly this decision — a field the Assayer may declare and the approver binds at the gate."
    evidence: "§3.1: 'for a rule whose text declares `**Enforcement**` and `**Scope**`, `## Constraints`; for one declaring `**Frequency**` and `**Auto-fix**`, `## Garbage Collection`.' `harness-registrar.py:751-765` (`apply_target_override`): '`target` binds at ACCEPTANCE ... That is the human's decision, made at the gate beside the cost.' `HARNESS.md:661-668` shows a GC entry declaring `**Enforcement**` as well as `**Frequency**` and `**Auto-fix**`."
    disposition: pending
    disposition_rationale: null
  - id: O11
    category: scope
    severity: medium
    claim: "The design models only the insertion of a new block, but the single `harness-loop` rule text the corpus has ever held was written to be spliced into an existing constraint's body."
    evidence: "§3.1: 'Proposes a section and a position within it'. `harness/decisions/HDR-2026-08-25-an-epic-s-authority-cited-to-a-document-nobody-else-can-open.md:62-64`: 'The rule below extends that constraint's scope rather than adding a second heading, and the proposed text is written to sit inside it.'"
    disposition: pending
    disposition_rationale: null
  - id: O12
    category: specification quality
    severity: medium
    claim: "Acceptance criterion 8 is either vacuous or falsified by the change's own intent, so it cannot function as the assurance it appears to give."
    evidence: "Criterion 8: 'The control surfaces are byte-identical to their output before this change, given the same corpus.' The compiler never writes them (`commands/harness-accept.md:161-164`); `/convention-sync` does, from `## Constraints` (`commands/convention-sync.md:24-32`) — so a rule correctly placed under `## Constraints` will change them."
    disposition: pending
    disposition_rationale: null
---

## O1 — premise — critical

### Claim

The spec's whole case rests on a dichotomy: "one model has been applied to two kinds of artifact, and it fits only one of them." The kind it is said to fit is named explicitly — `.cursor/rules/`, `.windsurf/rules/`, `.github/copilot-instructions.md`. The harness compiler has never written a generated region into any of those files and is documented as never doing so. The second kind does not exist in this repository, which means the carve-out is justified by a distinction the artefacts do not support.

### Evidence

§1.1:

> The region model is correct for the artifacts it was designed for — `.cursor/rules/`, `.windsurf/rules/`, `.github/copilot-instructions.md` — which are generated, are reflected *from* `HARNESS.md`, and where a block of rules at the end is exactly right.

`ai-literacy-superpowers/commands/harness-accept.md:161-164`:

> It does not write into `.github/copilot-instructions.md`, `.cursor/rules/` or `.windsurf/rules/`. `/convention-sync` generates those from `HARNESS.md`, and two generators on one file produce the same rule twice in two voices.

`harness/surfaces.yaml:30-35` says the same thing at the source of truth:

> Compilation does not write into these files: `.github/copilot-instructions.md`, `.cursor/rules/` and `.windsurf/rules/` are already generated from HARNESS.md by /convention-sync.

The three files do contain the string `BEGIN GENERATED: harness-registrar`, which is how this claim survives a grep — but it is prose reflected out of `HARNESS.md:603` by `/convention-sync`, not a region.

The artefacts the region model has actually been applied to are: `HARNESS.md` (`harness-loop`, `script-validator`), `AGENTS.md` (`turn-instructions`), and per-record targets, of which the live example is `skills/advocatus-diaboli/SKILL.md`. Every one of them is a human-editable markdown document with meaningful sections. `PROSE_SUFFIXES = (".md",)` at `harness-registrar.py:1211` guarantees this by construction.

### Why this matters

§2's scope — `HARNESS.md` and nothing else — is derived from the claim that the region model has a correct home elsewhere. It does not. Either the region model is wrong for every artefact it touches (in which case the carve-out is drawn far too narrowly, see O2), or "a block of rules at the end" is acceptable for a human-editable markdown document (in which case the case against it for `HARNESS.md` needs an argument that is not the one given).

## O2 — scope — high

### Claim

The property the spec identifies — a human-readable master where section placement carries meaning — is not a property of `HARNESS.md`. It is a property of every markdown target the compiler can reach. Carving out one file fixes the instance that has never occurred and leaves the instance that is on disk today.

### Evidence

`ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md:376-399` carries an appended region right now. It sits after `### Closing Section` and its `### HDR-2026-08-25-four-mechanisms-...` heading is a sibling of that one — so a governance rule about status reporting currently reads as the last subsection of the skill's `## Output Format`. That is §1.1's defect, verbatim, in a file the spec leaves alone.

`harness/surfaces.yaml:24` routes `turn-instructions: AGENTS.md`, whose sections are `## STYLE`, `## GOTCHAS`, `## ARCH_DECISIONS`, `## TEST_STRATEGY`, `## DESIGN_DECISIONS`. No `turn-instructions` record has been accepted either, so §5's "cheapest moment" argument applies to it with equal force and is not made.

### Why this matters

If O1 is accepted, this is where the boundary should have been drawn: per kind of artifact, not per filename.

## O3 — risk — high

### Claim

§3.1 introduces a state the corpus has no way to represent: a record that is `accepted` but reached no artifact. Three separate outputs will report that record as a rule in force, because all three derive that from `status` and none of them reads the target.

### Evidence

`harness-registrar.py:1386-1388` selects report rows on status alone; `render_index` (`:973`) derives `"in force" if record.status == "accepted"`; `cmd_timeline` (`:1772-1792`) emits it as an intervention with an `approved_at` date and `"state": "in force"`.

The decision record in force until 2026-11-23, which §3.3 invokes by name: *"A reachable code path that reaches a passing value without reading the thing it reports on is a defect, not a default."*

### Why this matters

Under the region model this state is unreachable: `cmd_accept` refuses the entire acceptance if the rule cannot be applied. §3.1 makes it reachable by design and adds a report line in one command, while three durable artefacts continue to say the opposite.

## O4 — risk — high

### Claim

§1's "This is not a failure state" is wrong — and the specific falsehood it misses is not removed by the fix. A rule placed in `## Garbage Collection`, which §3.1 proposes as one of its two destinations, reaches no control surface at all, while `enforcement-report.md` reports it as advisory on cursor, copilot and windsurf.

### Evidence

`commands/convention-sync.md:24-32` parses exactly two things: `## Context > Conventions` and `## Constraints`. `## Garbage Collection` is not among them.

`harness-registrar.py:1328-1342` never consults the target artifact when computing achieved enforcement.

### Why this matters

Placement in this repository is load-bearing in a second way the spec never notices: which section a rule lands in determines whether it reaches four of the six declared surfaces. The design hands that determination to a human and adds no check that the chosen section propagates.

## O5 — implementation — high

### Claim

A substring-presence check over the whole file establishes that the bytes exist somewhere, which is not the property anyone reading the result will infer. It passes on text that is commented out, fenced, or explicitly disavowed by the prose around it.

### Evidence

`HARNESS.md:625-652` contains two HTML-commented template blocks. Rule text placed inside either is inert and passes. So is rule text inside a fenced example, or under `## Status`, or preceded by a line reading "Superseded, retained for reference:".

§3.3's mitigation is prose: it "names the check as weaker than region drift in its output". CI green is not prose.

### Why this matters

§3.3 justifies itself by citing the decision record about mechanisms that report the reassuring answer. That record's test is whether a passing value is reachable without establishing the thing being reported on. This check reports "present" — literally true — where the only reason to run it is to learn whether the approved rule is in force.

## O6 — implementation — high

### Claim

The region model automatically removes a rule's text from an artifact when the rule is superseded or withdrawn. The proposed design has no equivalent, and the presence check is one-directional. §2.1 calls its account of what is lost "precise" and does not contain this.

### Evidence

`harness-registrar.py:1466-1471`: *"A target whose last live record was superseded drops out of `by_target` entirely — and its region would then never be regenerated, leaving the retired rule sitting in the artifact as though it were still in force. … Withdrawing the last rule from a file has to actually remove it."* A file with no region is invisible to that path.

`cmd_review` (`:1692-1695`): `demote` produces a superseding record whose `## Rule` says "Withdrawn." — with no rule text of its own, so the presence check has nothing to search for.

### Why this matters

The design removes the only mechanism that automatically retracts a withdrawn rule from `HARNESS.md`, and does not say so. A rule the loop has formally withdrawn stays legible in the governing document indefinitely, with CI green.

## O7 — specification quality — high

### Claim

The spec does not say whether an absent rule fails the build. Today "unapplied" is a build failure paired with a repair command; §3.4 removes the repair command while §3.3 keeps the vocabulary.

### Evidence

`harness-registrar.py:1814-1819` puts unapplied targets into `problems`, and `cmd_check` exits 1 on any problem. `commands/harness-check.md:61` gives the remedy as `/harness-compile`. §3.4: "Compilation skips `HARNESS.md`." Criterion 6 is silent on exit status.

### Why this matters

Read one way, a declined placement turns the build red with no command that can repair it. Read the other way, `HARNESS.md` acquires a check that cannot fail, in a repository whose own position is that "a governance check that can be ignored is a governance check that will be".

## O8 — alternatives — high

### Claim

The per-rule marker is rejected for imposing a cost — impeding free editing — that an HTML comment does not impose, while the chosen design imposes a larger version of that same cost invisibly. The condition for revisiting it is a trigger with no owner, no expiry, and no mechanism.

### Evidence

An HTML comment does not render. §3.3's check requires the placed text to remain byte-exact — a constraint invisible in the file, unannounced to the editor, and enforced only by a red build with no repair command (O7).

`HDR-2026-08-25-an-epic-s-authority-cited-to-a-document-nobody-else-can-open.md:44-45` records what an ownerless trigger produces here: *"It produced no rule. Ten days later the next epic reproduced the defect at the same scale."*

### Why this matters

The per-rule marker resolves O5, O6 and O7. §6 concedes it "keeps both properties". The stated reason for declining it is an assertion about editability that the artefacts contradict.

## O9 — specification quality — medium

### Claim

§3.1 adds a third approval gate and abandons the all-or-nothing acceptance transaction. Both are documented, argued positions in the artefacts this spec amends, and the spec engages neither.

### Evidence

`commands/harness-accept.md:150-157`: *"Applying and compiling are deliberately **not** separate approval gates. Once a record is accepted there is no decision left in either step, and a gate with no decision behind it is the exact shape of approval theatre."*

`harness-registrar.py:831-838` refuses the whole acceptance "rather than leaving a record accepted and unapplied".

### Why this matters

There is a good argument available: placement *is* a decision, so a gate there is not theatre. The spec does not make it.

## O10 — alternatives — medium

### Claim

Section choice is inferred from the shape of the rule's markdown when the repository already has a mechanism for precisely this class of decision: a field the Assayer may declare, which the approver binds at the acceptance gate.

### Evidence

`harness-registrar.py:751-765`: *"`target` binds at ACCEPTANCE … That is the human's decision, made at the gate beside the cost."*

Tested against real texts the heuristic is weaker than it reads: `HARNESS.md:661-668` shows a Garbage Collection entry declaring `**Enforcement**` as well as `**Frequency**` and `**Auto-fix**`, so branch one only discriminates on `**Scope**`.

### Why this matters

A declared section is a decision on the record, attributable and readable later. A shape-sniffing heuristic is a guess presented as a diff, and a diff presented for confirmation is the format most likely to be confirmed.

## O11 — scope — medium

### Claim

§3.1 and §3.3 model one operation — inserting a new block into a section. The only `harness-loop` rule text this corpus has ever contained was written to be spliced into an existing constraint's body.

### Evidence

`HDR-2026-08-25-an-epic-s-authority-cited-to-a-document-nobody-else-can-open.md:62-64`: *"The rule below extends that constraint's scope rather than adding a second heading, and the proposed text is written to sit inside it."*

### Why this matters

If the human splices approved text into an existing bullet, the record's rule block is no longer a substring of the file, and the presence check reports the record as unapplied forever — with no repair command.

## O12 — specification quality — medium

### Claim

Acceptance criterion 8 does not test the thing it appears to test. Under the compiler it is vacuously true; under `/convention-sync` it is false by the change's own design.

### Evidence

The compiler never writes the control surfaces, so no change to compilation can alter them. They are generated from `## Context > Conventions` and `## Constraints` — so the moment a rule is correctly placed under `## Constraints`, they change, and that is the intended outcome.

### Why this matters

Criterion 8 is one of four the spec calls deterministic, and the only one that appears to protect anything downstream of `HARNESS.md`. It protects nothing.

## Explicitly not objecting to

- **§1's reading of `apply_region`**: traced end to end — `cmd_accept` (`harness-registrar.py:808-850`) → `compile_plan` (`:1429-1514`) → `apply_region` (`:1175-1184`). The spec is right: a first accepted `harness-loop` record produces no error, appends at end of file, and `HARNESS.md:1156`'s `## Status` is the last `##` heading.
- **§2.1's claim that the frozen-record check survives unchanged**: verified against `frozen_violations` (`:1561-1614`), which compares each accepted record against its own git blob and never reads a target artifact. That row of the table is accurate.
- **§2.2's rejection of two regions**: the generalisation argument is sound.
- **§5's migration argument**: verified that no accepted record routes to `HARNESS.md` today. "This is the cheapest moment" is true as stated.
- **§7's disclosure**: I did not treat the two recorded wrong turns as evidence for or against the current position; every objection is grounded in an artefact I read directly.
- **§8's version classification**: matches the semver rule in `CLAUDE.md`.
- **§9's decision to derive the docs list by search rather than by hand**: a process choice with no failure implication.
- **The `script-validator` route being treated identically to `harness-loop` (§3.2)**: correct, since both route to `HARNESS.md`.
