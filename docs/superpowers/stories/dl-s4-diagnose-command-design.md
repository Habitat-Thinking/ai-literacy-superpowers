---
spec: docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md
date: 2026-06-01
mode: spec
cartographer_model: claude-opus-4-8[1m]
stories:
  - id: 1
    lens: [patterns, coherence]
    title: Agent-emit + dispatcher-persist + human-disposes, fourth instance
    disposition: promote
    disposition_rationale: "Promoted as a sub-rule sharpening the existing AGENTS.md ARCH_DECISIONS entry: the human disposition must PRECEDE the write — ordering is the invariant, not just the agent/command tool split. The O1 near-miss (a draft that wrote then summarised) proves the tool split alone is insufficient. The existing entry is augmented with this ordering invariant, /diagnose recorded as the fourth instance, and the accept/abort-vs-accept/edit/re-run narrowing noted as a watch item."
  - id: 2
    lens: [defaults, consequences]
    title: Report is a derived artefact, not a tracked one
    disposition: accepted
    disposition_rationale: "Accepted. The build-artefact (gitignored, regenerable) stance is defensible and the O3 remedy is sound. The story's value is making the ontological choice legible so a future tracked-legibility-record feature knows it reverses a decision rather than filling a gap. Pairs with #6 and #7."
  - id: 3
    lens: [alternatives, consequences]
    title: Single verb, no subcommands, against model-card precedent
    disposition: accepted
    disposition_rationale: "Accepted (not promoted). Consistent with the project's established YAGNI-with-escalation-path stance; a third application of the named-consumer YAGNI form rather than a fresh principle. Human declined promotion this slice — if the pattern recurs again it can be promoted alongside S3 Story #2."
  - id: 4
    lens: [forces, alternatives]
    title: mode full chosen for the human, cross-check-only foreclosed
    disposition: accepted
    disposition_rationale: "Accepted. The facade choice (command picks mode: full on the human's behalf) is sound and diaboli-blessed. Recorded residue: S4 confirms cross-check-only still has zero command-surface consumers, sharpening S3 Story #2's 'concrete consumer exists' justification into a question for the next slice."
  - id: 5
    lens: [defaults, coherence]
    title: Scope contract delegated whole to the agent
    disposition: accepted
    disposition_rationale: "Accepted. The single-source-of-truth delegation (command forwards <scope> verbatim; agent owns the whole scope contract) is coherent with the agent-owns-behaviour/command-owns-persistence split and avoids contract duplication. Recorded so a future cost-driven 'add scope pre-validation' change knows it reverses a deliberate choice."
  - id: 6
    lens: [alternatives, consequences]
    title: Stateless re-run as default, cache deferred not decided
    disposition: revisit
    disposition_rationale: "Revisit. Stateless re-run is a defensible v0.5.0 default, but the cache decision is explicitly deferred-not-finalised: reopen when re-run cost or a legibility-trend feature (cf. #2) makes content-hash caching worth its invalidation complexity. Note the stale-by-default presumption (same-day overwrite treats the existing report as stale) a future cache would have to reverse."
  - id: 7
    lens: [consequences, coherence]
    title: Parent closes with one decision_focus thread open
    disposition: accepted
    disposition_rationale: "Accepted. The explicit-deferral-at-closure stance is honest and reusable: a parent slicing-record issue may be closed with a named, recorded carry-forward (cacheability) provided the deferral is documented (§1/§8). Seen from the parent-closure side; #6 is the same deferral seen from the slice-decision side."
  - id: 8
    lens: [forces, defaults]
    title: Observability scoped out where S3 pointed it home
    disposition: promote
    disposition_rationale: "Promoted as a reusable principle: a 'natural home' hand-off in slice N does not bind slice N+1, and a concern handed forward repeatedly accrues deferral debt until no slice owns it. Promoted to AGENTS.md ARCH_DECISIONS. The concrete orphaned concern (invocation-persistence corpus for the Phase-C escalation trigger, deferred S2b -> S3 -> S4) is re-filed as standalone issue #350 so it has a tracking home after parent #327 closes."
---

## Story #1 — Agent-emit + dispatcher-persist + human-disposes, fourth instance

**Source:** `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md` (§3.4, §4.8, §4.9)
**Lens:** patterns, coherence
**Refs:** O1

**Context.** The spec names the project's *agent-emit + dispatcher-persist + human-disposes* architecture (§3.4) and structures the whole flow around it: the read-only agent emits a YAML string, the command is the sole `Write`-capable component, and a human accept/abort gate (§4.8) sits between render and write. The diaboli's O1 had to push the spec to restore the gate — the pre-O1 draft persisted *then* printed a summary, satisfying the pattern's letter (agent read-only, command writes) while dropping the part that makes it load-bearing (the disposition *precedes* the write). The spec is silent on the fact that `/diagnose` is now the *fourth* production instance of a pattern AGENTS.md already promoted to named architecture on its third.

**Forces.** Reuse of a settled shape (the pattern is in AGENTS.md ARCH_DECISIONS as the default for research-and-author agents) versus the temptation to treat "the agent is read-only and the command writes" as sufficient compliance. The unspoken tension O1 exposed: the pattern's *integrity* lives in the ordering (dispose-then-write), not in the tool split alone. A spec can satisfy the trust boundary and still break the human-gate half — which is exactly what the pre-O1 draft did.

**Options not taken.**

- Print-only command (no durable file). Rejected in §2.2 — the report is meant to be re-readable.
- Silent write-only (write then summarise). The pre-O1 draft; satisfies the tool split but not the disposition ordering.
- A separate review-then-write agent pass. Heavier; redundant once the command itself owns the gate.

**Choice as written.** The command renders, runs the checkpoint, prints the summary naming the resolved path, prompts accept/abort, and writes *only on accept* (§4.9). The spec frames this as a real pre-write disposition, not a post-hoc read. The AGENTS.md entry records three instances (`advocatus-diaboli`, `choice-cartographer`, `model-card-researcher`) and cites the Rule of Three; `/diagnose` makes four. The spec inherits the pattern without naming that it is now extending an already-promoted architecture.

**Consequences.** The pattern is now strong enough that O1's near-miss is itself the signal: a spec author reused the *name* of the architecture and got the *ordering* wrong, and only the diaboli caught it. The AGENTS.md entry says "structured human review (accept / edit / re-run / abort)" — `/diagnose` ships only accept/abort (no edit, no re-run-section), a narrower disposition vocabulary than the named architecture and the `model-card` precedent it cites. That narrowing is undocumented as a choice; a future reader comparing `/diagnose` to `model-card` will find the gate shapes differ and not know whether the narrowing was deliberate or an omission.

**Pattern.** The named project architecture *agent-emit + dispatcher-persist + human-disposes* (AGENTS.md ARCH_DECISIONS, citing Hunt/Thomas's Rule of Three). The near-miss is an instance of **honouring a pattern's name while violating its invariant** — the kind of drift the cartographer exists to mark.

**Notes.** Candidate disposition (human to adjudicate): **accept** — the pattern is already promoted; this story records the fourth instance and the accept/abort-vs-accept/edit/re-run narrowing as a watch item, not a fresh promotion. If the narrowed disposition vocabulary recurs on the next command spec, that divergence may itself become a promotion-worthy sub-rule.

---

## Story #2 — Report is a derived artefact, not a tracked one

**Source:** `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md` (§7.2 `.gitignore` row, §4.3)
**Lens:** defaults, consequences
**Refs:** O3

**Context.** The diaboli's O3 was about an operational risk (reports swept into the repo and the synced plugin cache). The disposition kept the repo-local default and added `diagnostic-legibility/output/` to `.gitignore`. The choice that survives O3 — and that O3 did not itself make explicit — is an *ontological* one: gitignoring the output directory encodes a stance that a diagnosis report is a **derived, regenerable artefact**, not a tracked source-of-truth document. That stance was decided by an objection's remedy, not announced as a design position.

**Forces.** Reviewability in the working tree (a repo-local default lets a developer open the report next to the code it describes) versus the artefact's ontological status (source is tracked and reviewed in PRs; build output is regenerated and ignored). The spec resolves toward "convenient repo-relative location *but* untracked" — which is precisely the build-output stance, even though §4.3 still frames repo-locality as a reviewability convenience. The `model-card` precedent took the other branch entirely (default *out* of repo, at `~/.claude/...`).

**Options not taken.**

- Default out-of-repo (`~/.claude/diagnostic-legibility/...`), the full `model-card` stance. Treats reports as user-local artefacts; foreclosed in favour of repo-local-but-ignored.
- Repo-local *and* tracked (committed reports). Would make a diagnosis a reviewable, versioned record of a codebase's legibility over time — a meaningfully different product. Foreclosed silently by the `.gitignore` entry.
- A reports index / manifest tracking which scopes were diagnosed when. Not considered; the artefact is ephemeral by the chosen stance.

**Choice as written.** Repo-local default directory, gitignored. The spec chose "regenerable build output that happens to live in the tree" over both "user-local artefact" and "tracked legibility record." The choice was made *by* the O3 remedy and is visible only in a one-line file-list entry; the spec body (§4.3) still narrates repo-locality as reviewability, which sits in mild tension with ignoring the output.

**Consequences.** Because reports are untracked and date-stamped, there is no durable history of how a scope's legibility changed across runs — each run overwrites or accretes a same-day file with no version trail. If the project ever wants "diagnose this scope every release and watch the corrections trend," that capability is foreclosed by the current stance and would require revisiting both the `.gitignore` decision and the stateless-re-run default (see #6). No failure is undetected here — this is a foreclosed future option, so it routes to the cartographer, not the diaboli.

**Pattern.** **Build artefact vs source artefact** distinction (the `.gitignore`/`dist/` convention). Choosing to gitignore is choosing the artefact's lifecycle: regenerated, not curated. Kin to the **derived data** posture — never the source of truth, always reproducible from inputs.

**Notes.** Candidate disposition (human to adjudicate): **accept** — the build-artefact stance is defensible and the O3 remedy is sound; the value of the story is making the *ontological* choice legible so a future "tracked legibility record" feature knows it is reversing a decision, not filling a gap.

---

## Story #3 — Single verb, no subcommands, against model-card precedent

**Source:** `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md` (§3.2, §8)
**Lens:** alternatives, consequences
**Refs:** —

**Context.** The spec adopts the `model-card` command as its structural precedent for nearly everything — frontmatter, Usage block, numbered Flow, `--out`, refusal handling, validation checkpoint. On one axis it silently diverges: `model-card` is a multi-verb command (`/model-card create | seed`), and `/diagnose` is a single bare verb with no subcommands. The spec notes the difference in passing (§3.2: "There are no subcommands… unlike `/model-card create | seed`") and asserts a future subcommand could be added non-breakingly, but it does not treat "single verb" as a decision with consequences — it presents it as the natural shape.

**Forces.** Surface simplicity (one verb, one job, nothing to disambiguate) versus extensibility-by-namespace (subcommands give a place to hang future modes — `list`, `compare`, `--from` re-render — under one command root). The unspoken force: `model-card` *needed* subcommands because it has two genuinely distinct operations (create from research, seed from template); `/diagnose` has exactly one operation at v0.5.0, so a subcommand layer would be empty scaffolding. The spec resolved toward "don't build the namespace until there's a second verb to put in it" — a YAGNI move it does not name as such.

**Options not taken.**

- Ship `/diagnose run <scope>` with `run` as the sole subcommand, reserving the namespace. Pre-builds extensibility for verbs that do not exist; the dead-scaffolding tax this project has twice declined to pay (S3 Story #2).
- Mirror `model-card` structurally including a two-verb split now (e.g. `/diagnose full | from`). Would require the `--from` re-render consumer §8 explicitly defers.
- A flag-discriminated single verb (`/diagnose --mode ...`) instead of subcommands. Conflates dispatch mode with command surface; §3.3 already keeps `mode` an internal choice the command makes for the human.

**Choice as written.** A single verb `/diagnose <scope> [--out <dir>]`, with the explicit claim that subcommands can be added later without breaking the signature (§8). The spec chose the minimal surface and named the escalation path, the same escalation-path-with-trigger shape S3 used for dropping `construct-only`.

**Consequences.** The signature is now a commitment: any future `list` / `compare` / `--from` mode must fit *under* `/diagnose` as a subcommand or flag without breaking `<scope>` as the leading positional. That is a mild constraint — `<scope>` being positional means a future `/diagnose list` is ambiguous with a scope literally named "list" unless disambiguated. No failure is undetected at v0.5.0; this is a foreclosed-shape consequence, so it routes to the cartographer.

**Pattern.** YAGNI in the "named-consumer" form (Beck), the same posture S3 Story #2 recorded for dropping `construct-only`. Also **single responsibility at the command surface** — one verb, one job. The escalation-path-with-trigger (add a subcommand when a second verb earns its place) is the operational guard against permanent foreclosure.

**Notes.** Candidate disposition (human to adjudicate): **accept** — consistent with the project's established YAGNI-with-escalation-path stance; not a fresh decision so much as a third application of it (cf. S3 Story #2's "twice acted on" framing — this is arguably the third). If the human reads it as the third occurrence of the named-consumer YAGNI form, it may pair with S3 Story #2 toward promotion.

---

## Story #4 — mode full chosen for the human, cross-check-only foreclosed

**Source:** `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md` (§3.3)
**Lens:** forces, alternatives
**Refs:** —

**Context.** S3 shipped two agent modes: `full` and `cross-check-only`. The S4 spec hard-wires `/diagnose` to `mode: full` and keeps `cross-check-only` off the command surface entirely (§3.3). The diaboli explicitly did *not* object to this (it is in the "explicitly not objecting to" list as "the simplest correct choice"). What the diaboli's non-objection leaves unexamined is the *framing* decision underneath: the command **chooses the mode on the human's behalf** rather than exposing it. That is a deliberate ergonomic stance — "a human invoking `/diagnose <scope>` wants the full pipeline; the command decides for them" — that S3 §2.4 anticipated and S4 silently realises.

**Forces.** Ergonomic minimalism (a human typing `/diagnose <scope>` should not have to know what a mode marker is) versus exposing the full agent capability surface (a power user with a persisted `LegibilityModel` might want to re-run only Phase C). The spec resolves entirely toward the human-facing simple path and treats the round-trip affordance as a bare-Task-tool surface that `/diagnose` deliberately does not wrap. This is the "command chooses for the human" contract — a real decision about *who owns the mode choice*, presented as obvious.

**Options not taken.**

- Expose `mode` as a `/diagnose --mode <full|cross-check-only>` flag. Surfaces an agent-internal concept to humans for a round-trip with no named S4 consumer (§8).
- Add a `/diagnose --from <yaml>` re-render that implies `cross-check-only`. Explicitly future work (§8); no consumer named now.
- Leave mode selection to the dispatcher prompt and have `/diagnose` pass it through. Splits the "command decides" contract and re-exposes the marker.

**Choice as written.** `/diagnose` always sends `mode: full`; `cross-check-only` stays a bare-Task-tool surface. The command owns the mode choice and removes it from the human's concern. The spec frames this as the S3-anticipated "command chooses for the human" contract.

**Consequences.** The agent's `cross-check-only` mode now has *zero* command-surface consumers — it is reachable only by hand-writing a Task prompt. This is the round-trip mode S3 Story #2 deliberately kept (over dropping it like `construct-only`) precisely *because* a concrete consumer was anticipated. S4 declines to be that consumer. So `cross-check-only` is a shipped, tested, documented agent surface with no command exercising it — a standing question for a future slice: either a `--from` consumer materialises, or `cross-check-only` is itself a YAGNI-drop candidate the way `construct-only` was. No failure is undetected; this is an alternatives/consequences observation for the cartographer.

**Pattern.** **Convenience method / facade** (GoF Facade applied at the command layer) — `/diagnose` is a simplifying facade over a richer agent contract, deliberately hiding the mode dimension. Also **least-surprise default selection** — the command picks the only mode a human invoking by scope could want.

**Notes.** Candidate disposition (human to adjudicate): **accept** — the facade choice is sound and diaboli-blessed. The genuinely interesting residue is the orphaned `cross-check-only` surface; worth a one-line note that S4 confirms `cross-check-only` still has no consumer, sharpening S3 Story #2's "concrete consumer exists" justification into a question for the next slice.

---

## Story #5 — Scope contract delegated whole to the agent

**Source:** `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md` (§4.2, §3.2)
**Lens:** defaults, coherence
**Refs:** O11

**Context.** The command passes `<scope>` through to the agent's `scope:` line *verbatim* and does no filesystem stat, no form-validation, no resolution before dispatch (§4.2). The three scope forms (directory, file list, free text), the empty-scope sentinel, and the unresolvable-scope handling all live in the agent. The spec's rationale — "the agent already owns the three scope forms and the empty-scope contract; duplicating scope validation in the command would split the contract" — is a one-line architectural decision about *where the scope contract lives* that reads as obvious but is doing real work.

**Forces.** Single source of truth for the scope contract (one component validates, one place to change it) versus fail-fast at the command boundary (catch a malformed scope before paying for an agent dispatch). The spec resolves entirely toward single-source-of-truth: the command is a thin pass-through and the agent is the sole scope authority. This is coherent with the spec's *agent owns behaviour, command owns persistence* split — the command deliberately owns *nothing* about what a scope means.

**Options not taken.**

- Command stats `<scope>` and short-circuits an obviously-empty/missing path before dispatch. Saves an agent round-trip but duplicates (and risks diverging from) the agent's empty-scope contract.
- Command validates scope *form* (directory vs file-list vs free-text) and rejects malformed input. Re-implements the agent's form-detection; the spec explicitly declines this.
- Command applies `--out`-style containment to `<scope>` reads. Out of scope; the agent is read-only with `Glob`/`Grep`/`Read` and owns its own scope inspection.

**Choice as written.** The command does zero scope validation and forwards `<scope>` verbatim. An unresolvable scope is "not a command-level error" — the agent handles it via the `(empty scope)` sentinel, and the command still writes a report. The scope contract is wholly the agent's; the command silently inherits whatever the agent decides a scope is.

**Consequences.** Every future change to scope semantics happens in the agent and the command transparently inherits it — which is the win. The cost: the command pays for a full agent dispatch even on a trivially-empty or typo'd scope (no cheap fail-fast), and a human's malformed-scope mistake surfaces only after the pipeline runs and a `skipped_asymmetric` empty-scope report is rendered (and offered for write). The command's *only* input it actually owns and validates is `--out` (and even that is deferred-unconstrained per O11) and the presence of `<scope>` (§4.1). This is a coherent boundary, but it means the command is a near-pure dispatcher whose own contract surface is almost empty — worth recording so a future "add scope pre-validation for cost" change knows it is reversing a deliberate single-source-of-truth choice.

**Pattern.** **Single source of truth** / **don't-repeat-yourself** applied to a contract boundary, and **Pass-Through / thin client** — the command is a transport, not a validator. Kin to the API-gateway "don't re-validate what the service validates" stance.

**Notes.** Candidate disposition (human to adjudicate): **accept** — the delegation is coherent with the agent/command split and avoids contract duplication. Refs O11 because the one input the command *does* own (`--out`) is the one the diaboli flagged as unconstrained; the two together show the command's input-validation surface is deliberately minimal on both arguments.

---

## Story #6 — Stateless re-run as default, cache deferred not decided

**Source:** `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md` (§1, §8)
**Lens:** alternatives, consequences
**Refs:** O10

**Context.** The slice's `decision_focus` (slicing record lines 86–88) named "whether the results are cacheable" as part of what S4 decides. The spec makes the command "one-shot, stateless, and cacheable" in language (§2.1) but ships *stateless re-run* as the actual v0.5.0 behaviour: every invocation re-runs the full pipeline, and a content-hash cache is future work (§8). O10 pushed the spec to record that cacheability is "deliberately deferred, not decided." The choice the cartographer marks is the **default itself**: statelessness was selected as the path of least resistance for a single-report command, and the word "cacheable" in §2.1 describes a property the artefact *could* have, not one the command *implements*.

**Forces.** Simplicity and testability of a stateless command (no cache invalidation, no staleness reasoning, every run is reproducible from inputs) versus cost/latency of re-running a full multi-phase agent pipeline on every invocation (Phase A+B+C over a scope is not cheap). The spec resolves toward statelessness and names the cost as acceptable for v0.5.0, deferring the optimisation. The unspoken framing: "stateless re-run" is the *default a single-report command falls into*, not an option that was weighed against caching and won on merits.

**Options not taken.**

- Content-hash cache keyed on scope + codebase state, returning a prior report when inputs are unchanged. Named as future work (§8); the cache-invalidation complexity is the reason it is deferred.
- Reuse the date-stamped file as an implicit cache (same-day re-run reads the existing report instead of re-running). The §4.8 overwrite flag treats the existing file as a collision to warn about, *not* as a cache to read — an implicit decision that the existing file is stale-by-default.
- A `--no-cache` / `--refresh` flag pair. Premature without a cache to bypass.

**Choice as written.** Stateless re-run is the v0.5.0 default; the date-stamped filename means different days produce different files and same-day re-runs hit the overwrite gate. The spec's "cacheable" claim (§2.1) is an architectural property of the *artefact* (it is a pure function of its inputs), deliberately not realised as a *caching mechanism*. Cacheability is recorded as deferred-not-decided.

**Consequences.** Every `/diagnose` run pays full pipeline cost even when nothing changed since the last run — the dominant cost in the whole feature, accepted silently as the v0.5.0 default. The same-day-overwrite behaviour (§4.8) encodes "the existing report is presumed stale," which is the *opposite* default a cache would take ("the existing report is presumed valid"). When the cache is eventually built, it will have to reverse that presumption. No failure is undetected (O10 already routed the parent-closure honesty concern); the residue here is the foreclosed-for-now optimisation and the stale-by-default presumption, which route to the cartographer.

**Pattern.** **Stateless service** (REST-style statelessness) chosen over **memoisation** — the command is a pure function of (scope, codebase, clock) with no retained state between invocations. The deferral is the **decide-as-late-as-possible** posture (Poppendieck), the same Lean lever S3 Story #2 cited.

**Notes.** Candidate disposition (human to adjudicate): **revisit** — this is the textbook deferred decision: acknowledged, defensible as a v0.5.0 default, but explicitly to be reopened when re-run cost or a legibility-trend feature (cf. #2) makes caching worth its invalidation complexity. The `revisit` disposition captures "considered and noted, not finalised" without blocking merge. Pairs with #2 (the build-artefact stance) and #7 (parent closure).

---

## Story #7 — Parent closes with one decision_focus thread open

**Source:** `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md` (§1, §8, header "Closes" row)
**Lens:** consequences, coherence
**Refs:** O10, #6

**Context.** S4 is the last slice in the chain; the header records that completing it closes parent #327 ("build the agent, then surface it on demand"). Closing a parent issue is an assertion that its decision_focus is fully resolved. But the parent's S4 decision_focus explicitly named cacheability as in-scope (slicing record lines 86–88), and S4 defers it (#6). O10 made the spec add a sentence acknowledging this. The choice the cartographer marks is what the *parent-closure act itself asserts*: that "surfaced on demand" is satisfied by a one-shot stateless report, and that the open cacheability thread is acceptable to close the parent over.

**Forces.** Closing the parent cleanly when the last slice ships (a tidy completion signal — the chain is done) versus closing it *honestly* when one named sub-thread of the final decision_focus is deferred rather than decided. The spec resolves toward "close the parent, but record the one open thread in the closure language." The deeper coherence question: does closing #327 mean "the surfacing decision is fully made," or "the surfacing *slice* shipped, with one sub-decision rolled forward as separate future work"? S4 chooses the latter and says so — a small but real redefinition of what parent-closure asserts.

**Options not taken.**

- Hold #327 open until cacheability is decided. Keeps the parent honest at the cost of an indefinitely-open issue blocked on a deferred optimisation.
- Close #327 silently and let cacheability vanish from the record. The pre-O10 posture; the parent would close asserting full resolution while a named thread was unaddressed — a gap between scoped-to-decide and decided.
- Re-scope #327 to remove cacheability from S4's decision_focus retroactively. Rewrites history rather than recording the deferral.

**Choice as written.** Close #327 on S4 ship, *and* record in §1 and §8 that cacheability — named in S4's decision_focus — is deliberately deferred, not decided. The closure asserts "the surfacing slice is complete and the chain is done," explicitly *not* "every thread the decision_focus named is resolved." This keeps the completion signal while making the one carried-forward thread visible.

**Consequences.** A future reader who finds #327 closed and then discovers caching is unbuilt has the §1/§8 note to explain it — the gap is documented, not silent. The precedent set: a parent issue may be closed with a named, recorded deferral of one decision_focus thread, provided the deferral is explicit. That is a reusable stance on *what closing a slicing-record parent means* — worth surfacing because the next multi-slice chain will face the same "close cleanly vs close honestly" tension. No failure is undetected; this is a coherence/consequences observation routing to the cartographer (O10 covered the spec-quality angle).

**Pattern.** **Definition of done** applied at the epic/parent level — closure asserts "the deliverable shipped," explicitly decoupled from "every named consideration was resolved." Kin to the **known-deferral** discipline (close with a recorded, traceable carry-forward rather than a silent gap).

**Notes.** Candidate disposition (human to adjudicate): **accept** — the explicit-deferral-at-closure stance is honest and reusable. Refs #6 because the deferred thread *is* the stateless/cache decision; the two stories are the same deferral seen from the slice-decision side (#6) and the parent-closure side (#7).

---

## Story #8 — Observability scoped out where S3 pointed it home

**Source:** `docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md` (§8, §10.6)
**Lens:** forces, defaults
**Refs:** —

**Context.** S3 §8 named S4 as the *natural home* for persisting invocations to a corpus — the data the Phase-C-escalation trigger (the sentinel-only-ratio signal for promoting Phase C to a separate agent) would need. S4 scopes that out (§8, last bullet; §10.6): "`/diagnose` writes one report per run; it does not accumulate a corpus." The diaboli explicitly routed this to the cartographer ("decision-archaeology — a recorded choice with no failure shape"). The choice the cartographer marks is the **decision to decline an inheritance an earlier slice explicitly handed forward** — S3 pointed at S4 and said "you are the home for this," and S4 says "not me."

**Forces.** Keeping S4 a single-report surfacing slice with one clean job (render one report, write one file) versus honouring S3's hand-off and closing the observability gap the escalation trigger depends on. The spec resolves toward scope discipline: S4 stays a surfacing slice and pushes corpus-persistence to "a separate decision after S4." The unspoken force: S3's "natural home" language created a soft expectation that S4 would absorb persistence; declining it is a real choice, not an oversight, and the spec treats it as obvious by listing it under "out of scope."

**Options not taken.**

- Fold invocation persistence into `/diagnose` (append each run to a corpus / log). Honours S3's hand-off but bloats the surfacing slice with an observability concern S4 was not scoped for.
- Add a minimal hook (e.g. write a one-line invocation record alongside the report) as a seed for the corpus. Half-measure; carries the observability concern without the consumer (the escalation trigger) being built.
- Re-open S3's escalation-trigger design as part of S4. Re-litigates a settled S3 decision for no S4 benefit (the diaboli's "explicitly not objecting" reasoning for the unchanged-agent boundary).

**Choice as written.** S4 writes one report per run and accumulates nothing. The observability gap deferred since sub-S2b stays open; if it is to be closed, "it is a separate decision after S4" (§8). The spec declines S3's "natural home" hand-off and names the decline explicitly, leaving the escalation trigger without its data source.

**Consequences.** The Phase-C-escalation trigger from sub-S2b now has *no* slice scheduled to feed it — S2b deferred it, S3 pointed at S4, and S4 declined. The trigger's data dependency is now orphaned across three slices' worth of deferrals, with the parent (#327) closing (#7). Whoever revives the escalation question starts from "no corpus exists and no slice owns building one." No failure is undetected — the escalation trigger is a future-optimisation signal, not a correctness mechanism — so this routes to the cartographer as a clean decision-with-no-failure-shape, exactly as the diaboli flagged. The cartographer's distinct contribution: marking that this is the *third consecutive* deferral of the same concern and that the parent closure removes the natural tracking issue for it.

**Pattern.** **YAGNI / scope discipline** (the surfacing slice does one thing) colliding with **deferred-concern accretion** — a concern repeatedly handed forward ("the next slice is the natural home") accumulates deferral debt until no slice owns it. The hand-off-that-is-declined is an anti-pattern worth naming: a "natural home" assertion in slice N does not bind slice N+1, and the concern can fall through the gap.

**Notes.** Candidate disposition (human to adjudicate): **revisit** — accept the v0.5.0 scope-out, but flag that with #327 closing, the observability/escalation concern loses its tracking home and should be re-filed as a standalone follow-up issue rather than left implicit in three closed slices' §8 sections. The diaboli (O10's closing remark, §10.6) already suggested the cartographer "may promote 'S4 should also persist invocations to a corpus' to a follow-up issue"; `revisit` with that re-filing as the rationale is the natural disposition.

**Adjudicated: promote.** The human promoted this to a reusable principle (AGENTS.md ARCH_DECISIONS — the declined-hand-off / deferred-concern-accretion anti-pattern). The concrete orphaned concern is re-filed as standalone issue [#350](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/350), which becomes its tracking home after parent #327 closes.
