# Compound Learning

<!-- This file is the project's persistent memory across AI sessions.
     It accumulates patterns, gotchas, and decisions so that each session
     builds on what previous sessions learned — rather than rediscovering
     the same things from scratch.

     IMPORTANT: This file is often generated or updated by LLM agents.
     Review new entries with the same scepticism you would apply to any
     generated content. Entries should reflect observed reality in the
     codebase, not aspirational conventions. An entry in GOTCHAS that
     does not reflect an actual problem that was actually solved is noise
     that increases the cognitive cost of every future session. -->

## STYLE

<!-- Patterns and idioms that work well in this codebase.
     Each entry: what to do, and why it works here. -->

- All hook scripts are advisory only — they warn but never block.
  Output uses JSON `systemMessage` format so Claude Code surfaces
  the message without interrupting the session flow.

- Reflection-driven amendments may go through `chore`-labelled PRs
  even when behavioural, provided four preconditions hold: (a) the
  reflection has been captured in `REFLECTION_LOG.md` and merged via
  PR; (b) the work is scoped in a tracked GitHub issue with
  explicit "in scope" and "out of scope" sections; (c) the
  implementation is additive (new sub-phase, new reference file)
  or conservatively bounded (new behaviour applies incrementally
  with a CHANGELOG note governing how aggressively); (d) the
  version bump and CHANGELOG entry are honest about the
  behavioural change. The `chore` label exempts spec-first ordering
  and adjudication constraints; the version-consistency check still
  applies. Reserve full feature-flow ceremony (spec → diaboli →
  adjudicate → implement → diaboli code-mode → adjudicate) for
  *net-new capability* (the Choice Cartographer was the canonical
  feature PR); use chore for *refining existing capability driven
  by captured signal* (Units A and B for the assessor). The
  distinction is calibrated rather than codified — judgement, not a
  rule. (Source: REFLECTION_LOG 2026-04-28 entry on Units A and B,
  building on the marker-bump and Cartographer flows from earlier
  in the same conversation.)

## GOTCHAS

<!-- Traps, surprises, and non-obvious constraints. Entries
     accumulate as the pipeline discovers them.
     Each entry: what the trap is, and how to avoid it. -->

- When adding a new deterministic constraint (like ShellCheck),
  always run a test pass against the full codebase before promoting
  — including files created earlier in the same session. ShellCheck
  found 4 issues in scripts that had passed both implementer and
  spec compliance review. Deterministic tools catch what LLM review
  misses. (Source: REFLECTION_LOG 2026-04-06)

- Worktree-isolated subagents lose Bash permissions — the `.claude/
  settings.local.json` allow-list does not propagate to worktree
  paths. Use regular background agents on separate branches instead,
  but expect branch cross-contamination when multiple agents share
  the same repo. Plan for cherry-pick cleanup when dispatching
  parallel implementation agents without worktrees.
  (Source: REFLECTION_LOG 2026-04-07)

- Background subagents may lack Write/Edit permissions even when the
  parent context has them. For write-heavy tasks (e.g. generating
  full documentation pages), either use foreground agents so the user
  can approve tool calls, or have the parent extract content from
  subagent output and do the writes itself. The subagent output logs
  at `/private/tmp/claude-*/tasks/<agent-id>.output` contain the
  drafted content even when writes were denied.
  (Source: REFLECTION_LOG 2026-04-11)

- Before proposing a new CI workflow, grep `.github/workflows/` for
  related checks. This project already has version-check.yml,
  lint-markdown.yml, harness.yml, gc.yml, and pages.yml. Proposing
  a duplicate wastes a branch cycle and erodes trust.
  (Source: REFLECTION_LOG 2026-04-11)

- This project's harness is self-referential — the plugin defines
  the harness framework, and its own HARNESS.md uses that framework.
  Changes to template files (`templates/HARNESS.md`) do not
  automatically propagate to the project's root `HARNESS.md`. The
  command-prompt sync and plugin manifest currency GC rules are
  critical here to catch drift. (Source: REFLECTION_LOG 2026-04-06)

- Long uninterrupted sessions degrade judgment in ways that are
  invisible from inside the session — output keeps flowing, but
  pattern-matching narrows and surprise-detection drops. Take a
  time-based break (90-minute self-check, end-of-day stop) rather
  than a task-based one. Specifically: if the next decision involves
  judgment about *whether* to do something (vs how to do it), and
  you've been working continuously for 90+ minutes, defer the
  decision to a fresh session. Task-based stops ("when this is done")
  routinely paper over depletion because the task always extends.
  (Source: 2026-04-28 assessment Q4 — depletion-management gap.)

## ARCH_DECISIONS

<!-- Key architectural decisions and the reasoning behind them.
     Each entry: what was decided, why, and what the alternatives were. -->

- Decision: content-emitting agents in this codebase use a three-part trust
  architecture — **agent-emit + dispatcher-persist + human-disposes**. The
  agent's tool boundary is research-and-author only (no Edit, no Bash); the
  agent returns content as a string; the dispatching command writes the file
  after a structured human review (accept / edit / re-run / abort). This
  pattern is in production across three agents: `advocatus-diaboli`,
  `choice-cartographer`, and `model-card-researcher`. Three repetitions
  promote it from convention to named architecture (Hunt/Thomas's Rule of
  Three). Future research-and-author agents in this codebase should default
  to this shape unless an explicit reason argues otherwise. The two halves
  are: (1) tool-boundary — minimum-trust-surface, no shell, no edit; (2)
  human-gate — structured review summary, named dispositions, command
  refuses to persist when the agent emits a refusal string (e.g.
  model-card-researcher's REFUSED: line for unconfirmed model existence).
  **Ordering invariant (promoted from S4 cartographer Story #1): the human
  disposition must PRECEDE the write — the dispose-then-write ordering is the
  invariant, not merely the agent/command tool split.** The S4 `/diagnose`
  spec's pre-diaboli draft satisfied the tool split (read-only agent, command
  writes) yet wrote the file *then* printed a summary, reducing the human gate
  to a post-hoc read; only the diaboli (O1) caught it. A spec can honour the
  pattern's name and still break its invariant, so check the ordering, not just
  the tool boundary. `/diagnose` is the fourth production instance. Watch item:
  `/diagnose` ships only accept/abort, a narrower disposition vocabulary than
  the named architecture's accept/edit/re-run/abort and the model-card
  precedent; if that narrowing recurs on the next command spec, the divergence
  may warrant its own sub-rule.
  Source: `docs/superpowers/stories/model-cards-plugin-design.md` stories
  #7 and #8 (original promotion); `docs/superpowers/stories/dl-s4-diagnose-command-design.md`
  story #1 (ordering-invariant sharpening).

- Decision: hook scripts never block, only warn. Reason: this is a
  plugin used across diverse projects — blocking hooks could break
  workflows the plugin authors cannot predict. Advisory messages let
  users decide how to act. Alternative considered: configurable
  blocking (rejected — complexity not justified for the advisory
  value these hooks provide).

- Decision: health snapshots are generated artifacts committed
  directly to main. Reason: they do not affect behaviour and
  gating them on PR review would add friction to the observability
  cadence. Alternative considered: PR workflow for snapshots
  (rejected — would discourage frequent snapshot generation).

- Decision: every command that produces structured output parsed by
  downstream consumers must include a validation checkpoint step.
  The pattern is: generate, read back, check against format spec,
  fix in place. Reason: agents consistently drift from format specs
  under cognitive load — the governance-auditor ignored its own
  9-field format spec, /harness-health generated deprecated YAML
  blocks. Reference templates set intent but do not guarantee
  compliance. The checkpoint is the verification layer, analogous
  to type checking in compiled code. Alternative considered:
  relying on agent instructions alone (rejected — proven unreliable
  across 8 commands). Alternative considered: hook-based validation
  (rejected — hooks are advisory-only with 30-second timeouts, too
  limited for format verification). (Source: REFLECTION_LOG 2026-04-15)

- Decision: advocatus-diaboli is hard-wired into the spec-first pipeline as an
  agent-enforced PR constraint from the outset (Option B — not optional, not
  advisory). The agent is dispatched after spec-writer and before plan approval;
  the plan-approval gate refuses progression while any disposition is `pending`;
  the harness-enforcer checks objection record completeness at PR time.
  Alternatives considered and rejected: (1) manual invocation only — discovers
  utility in early PRs but never creates discipline; users skip it under pressure;
  (2) advisory gate without constraint — same failure mode; the gate exists only
  when someone remembers to run it; (3) deterministic schema check alone — can
  verify no `pending` values remain but cannot detect rubber-stamping
  (`disposition: accepted, rationale: "ok"` would pass). Agent enforcement is
  chosen because "resolved" is a judgment call on rationale quality. Conditions
  under which this would be revisited: if disposition distribution clusters on
  `deferred — not material` over a meaningful sample (20+ PRs), tune the SKILL.md
  charter (tighten evidence requirements, raise the evidence bar) before weakening
  the constraint. Do not weaken the constraint at first friction — that builds
  ceremony, not a gate.

- Decision: diaboli runs at two dispatch points (spec-time and code-time) using
  a single agent with mode-based category weighting. One agent, two dispatches —
  not two agents. Spec-time dispatch runs after spec-writer, before plan approval;
  code-time dispatch runs once after the final code-reviewer PASS (or escalation),
  before integration-agent. The integration-approval gate mirrors the plan-approval
  gate: refuses while any code-mode disposition is `pending`. Alternatives
  considered and rejected: (1) separate code-diaboli agent — rejected: duplicates
  charter, fragments maintenance, creates divergent evolution risk; (2) running
  diaboli inside the code-reviewer loop per cycle — rejected: burns tokens on draft
  code, and adversarial review of drafts conflates the code-reviewer's constructive
  role with diaboli's adversarial one; (3) running code-time diaboli only for PRs
  above a size threshold — rejected: premature optimisation without
  disposition-distribution data to justify it. Conditions for revisit: if code-time
  disposition distribution diverges sharply from spec-time across a meaningful sample
  (20+ PRs), consider whether the two modes need genuinely separate charters rather
  than weighting.

- Decision: diaboli activity is surfaced as descriptive stats in existing
  observability surfaces (`/superpowers-status` Section 7 and the harness-health
  snapshot Diaboli panel) without thresholds or new enforcement, pending a
  reflection-informed evaluation. Alternatives considered and rejected:
  (1) adding a disposition-balance GC rule now — rejected because no data yet
  exists on what healthy looks like, and a premature threshold creates
  rubber-stamping pressure (the exact failure mode the mechanism is designed to
  prevent); (2) adding a separate `/diaboli-status` command — rejected because it
  fragments the observability surface; status and health are already the canonical
  panels and adding a third creates a maintenance surface with no corresponding
  benefit. Conditions under which this is revisited: after 10 fully-resolved
  objection records OR by 2026-07-19, whichever comes first — write a reflection
  on the observed patterns (disposition distribution, mean objections, median
  days) and decide whether a threshold or GC rule is warranted. The revisit
  output is a reflection entry, not an automatic constraint.

- Decision: cross-cutting methodology lives in
  `skills/<skill-name>/references/<contract>.md` files, consumed by
  multiple agents/commands/skills via reference rather than inlined
  at each consumer. The pattern has four instances in production:
  `skills/choice-cartographer/references/validation-checks.md` (the
  cartographer's validation checkpoint, consumed by the
  `/choice-cartograph` command and the orchestrator's step 5);
  `skills/ai-literacy-assessment/references/habitat-discovery.md`,
  `tool-config-evidence.md`, and `sophistication-markers.md` (the
  assessor's discovery, parallel-tool, and sophistication
  methodologies, each consumed by `assessor.agent.md`,
  `harness-discoverer.agent.md`, the `assess` command, and the
  `ai-literacy-assessment` SKILL). Edits to a contract land in one
  place and propagate; consumers reference the file by path rather
  than duplicating its content. Alternatives considered and
  rejected: (1) inline the methodology in each consumer — rejected:
  silently drifts as one consumer is edited and the others are not,
  which is the exact failure mode the references-file idiom
  prevents (caught explicitly in code-mode diaboli on PR #210, see
  O8 of `docs/superpowers/objections/choice-cartographer-code.md`);
  (2) put the methodology in the SKILL.md itself — rejected: SKILL
  files are loaded as context for the agent's reasoning, but the
  methodology is also consumed deterministically by validation
  checkpoints and command processes, which need a stable file
  reference. Conditions under which the idiom should be revisited:
  if a reference file accumulates more than ~250 lines or three
  obviously distinct contracts, split it; the value is one contract
  per file. (Source: REFLECTION_LOG 2026-04-28 entry on Units A and
  B for the assessor.)

- Decision: a "natural home" hand-off in slice N does not bind slice N+1.
  When a slice defers a concern by pointing at a later slice as its "natural
  home", that pointer is a *suggestion*, not a commitment the later slice
  inherits — the later slice is free to decline it, and when it does, the
  concern is orphaned unless deliberately re-filed. Repeatedly handing the
  same concern forward ("the next slice will own this") accrues **deferred-
  concern-accretion debt**: by the time the chain's parent issue closes, the
  concern has no tracking home and falls through the gap. Rule: when a slice
  declines an inherited hand-off, either (a) absorb it, or (b) re-file it as a
  standalone issue with its own lifecycle — never leave it implicit in a
  closed slice's "out of scope" section. Worked instance: the
  diagnostic-legibility invocation-persistence corpus for the Phase-C
  escalation trigger was deferred at S2b, pointed at S4 by S3 §8 as its
  "natural home", and declined by S4 — three consecutive deferrals with the
  parent (#327) closing. Re-filed as standalone issue #350 at S4 adjudication.
  Alternative considered and rejected: trusting the §8 "out of scope" note to
  carry the concern forward — rejected because closing the parent removes the
  natural tracking issue and the note becomes archaeology no one re-reads.
  Source: `docs/superpowers/stories/dl-s4-diagnose-command-design.md` story #8
  (promoted disposition); tracking issue #350.

## TEST_STRATEGY

<!-- How tests are structured in this project. Helps agents write consistent
     tests without reading every test file from scratch. -->

- This project has no application code or test suite. Content is
  validated by markdownlint (CI), ShellCheck, bash -n syntax checks,
  and gitleaks secret scanning. All validation is deterministic and
  runs in the harness CI workflow.

## DESIGN_DECISIONS

<!-- Interface contracts, data shapes, and design choices that are stable and
     that agents should not second-guess without good reason. -->

- Plugin components follow strict naming: skills use `SKILL.md`
  inside `skills/<name>/`, agents use `<name>.agent.md`, commands
  use `<name>.md`, hook scripts use `<name>.sh` (kebab-case). All
  names are lowercase kebab-case except `SKILL.md`.
