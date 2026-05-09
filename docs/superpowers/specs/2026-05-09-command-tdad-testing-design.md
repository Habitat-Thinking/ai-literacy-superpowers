# TDAD Testing Strategy for Slash Commands — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-09 |
| Status | **Amended 2026-05-09 — see Amendment 1 below** (originally: Draft pending user review) |
| Author | claude-opus-4-7[1m] (interactive session) |
| Plugin version target | none (design-only PR; implementation lands separately) |
| PR ceremony | `chore`-labelled — design-only document; diaboli and choice-cartograph deliberately skipped per AGENTS.md STYLE on architecture decisions captured in spec form |
| Related work | TDAD spike PR #282, SDK runner PR #285, finding scenario `tdad_tests/scenarios/commands/harness-init/FINDING-command-tdab-gap.md`, issue #284, Phase 1 PR #294, Phase 2 PR #295, Phase 3 PR #296, Phase 4 PR #297 |

---

## Amendment 1 — 2026-05-09: helpers stay test-stage (Option I)

**Supersedes**: §4's framing of Option C-direct as "the markdown command becomes glue between the user and the helper", and §5's Phase 2 expansion line ("If the spike works, expand to the remaining 9 P commands in a single follow-up PR" — read as "and update the command markdowns to invoke the helpers").

**Decision**: For all P commands, helpers stay in `tdad_tests/spike_helpers/`
as test-stage code. Command markdowns continue as prose-driven instructions
to the model. Tests verify the *documented behaviour*; drift between the
helper and the command's prose is a test failure the author resolves
manually.

### Why this changes

The original §4 Option C-direct conflated two distinct decisions:

1. *Can the deterministic core be extracted into Python and tested
   with fixtures?* — yes; Phase 2 (PR #295) demonstrated this for
   `convention-sync` and `observatory-verify`.
2. *Should that extracted logic ship inside the plugin and be invoked
   by the command at runtime?* — the original spec answered "yes"
   implicitly; this amendment answers "no" deliberately.

The two questions look related but have different cost/benefit
profiles. The first is about test coverage; the second is about plugin
distribution.

### The cost the original spec did not weigh

The plugin today ships shell scripts only — `archive-promoted-reflections.sh`,
`migrate-reflection-log.sh`, `update-badge.sh`, etc. Zero language-runtime
requirements beyond bash. Every consumer can install the plugin and use
every command with whatever they already have on their machine.

Promoting Python helpers into `ai-literacy-superpowers/scripts/` would
add a hard runtime dependency: every plugin user would need Python 3.11+
installed (the SDK requires it; the helpers should target the same
minimum). That is a meaningful regression in plugin friction — much
harder to undo than to avoid.

### The three options re-weighed

| Option | Test verifies | Plugin runtime deps | Drift between helper and prose |
| --- | --- | --- | --- |
| **I — Helpers stay in `tdad_tests/`** | the documented behaviour (a parallel implementation) | unchanged (bash + Unix tools) | silent unless tests fail |
| **II — Helpers re-implemented as bash, ship in `scripts/`** | the actual production code path | unchanged | caught by test failure |
| **III — Helpers ship as Python in `scripts/`** | the actual production code path | **+Python 3.11** | caught by test failure |

The original spec's "the command becomes glue" framing was Option III in
spirit; it skipped past the runtime-deps column.

### Why Option I is the right answer for most commands

The TDAD suite's purpose is *catching regressions in documented
behaviour*. Option I delivers that purpose without changing the plugin's
distribution model. The drift-detection cost (a test author has to read
both the helper and the command prose to confirm they still align) is
real but small — and at PR-time, an attentive review catches it.

The argument for Option II/III only holds when the test failure mode
of "drift between helper and prose, caught only when someone notices"
is genuinely unacceptable for a specific command. That bar should be
met case-by-case, not blanket.

### What does NOT change

- Phases 1, 3, 4 (the wiring and matrix tests) — still cheap, still
  applied to every command.
- Phase 2's spike helpers — they earned their keep by validating that
  P-command logic *can* be tested. They stay in `tdad_tests/spike_helpers/`.
- Per-skill Layer 3 tests for M commands — still case-by-case follow-up.

### What changes for the rollout from Phase 2

The work previously framed as "Phase 3 rollout: promote helpers to
scripts/, update command markdowns, expand to 9 more P commands" is
now: "expand the test-stage helpers in `tdad_tests/spike_helpers/` to
cover the remaining 9 P commands, *without* moving them into the plugin
or changing the command markdowns."

If a specific command has a side-effect severe enough to justify the
language-runtime dependency, that's a per-command Option III decision —
write a separate spec for it, weigh the trade-off explicitly, and only
proceed if the cost is justified.

### Methodological note

The spec's omission was a thinking failure worth recording: I conflated
"can be extracted for testing" with "should ship as production code".
Different decisions, different trade-offs. A pre-merge review pass that
asks "for each architectural recommendation, what are the costs the
spec hasn't weighed?" would have caught this. Captured in
REFLECTION_LOG.md alongside this amendment.

---

## 1. Summary

The TDAD spike (PR #282) validated the three-layer test architecture for
*agents* and *skills* but explicitly punted on *slash commands* — the
finding scenario at
`tdad_tests/scenarios/commands/harness-init/FINDING-command-tdab-gap.md`
documents three options (re-implement as SDK pseudo-script, run via
Claude Code subprocess, test deterministic side-effects only) without
choosing between them. Issue #284 asked for a design pass.

This spec proposes a **per-category** testing strategy: the 25 plugin
commands are not a homogeneous set, and the right test approach depends
on what kind of command it is. Three categories — Procedural,
Orchestration, Model-mediated — each get a different testing answer.
The strategy phases roll-out from cheap structural smoke (every
command, immediately) through Option C extraction (procedural
commands, next) to the hardest cases (model-mediated commands, last,
and only if cost/benefit holds).

The deliverable of this spec is the **decision and the phasing**, not
implementation. A follow-up spike — analogous to PR #282 — would pick
2–3 commands per category and validate the per-category pattern before
scaling.

---

## 2. Why

### The architectural awkwardness

Agents and skills exercise cleanly through the Claude Agent SDK. An
agent's frontmatter becomes the system prompt and tool list for an
SDK session; a skill's body and description load as the model's
reference material. Both fit the SDK's existing abstractions.

A slash command file like `harness-init.md` is a *procedural script*
written for the Claude Code runtime — it dispatches subagents, writes
files, asks the user questions, and threads state across multiple
turns. The Claude Agent SDK has no slash-command abstraction. The
spike's three options (re-implement, run via Claude Code subprocess,
test deterministic side-effects) all carry real costs, and none is
universally right.

### Why per-category instead of one answer

Reading the 25 commands, three patterns are visible:

- Some commands are **mostly mechanical** — they read files, transform
  them, write files. The model-mediated bits are minor (asking the
  user a clarifying question; formatting output). Their value is in
  the *side-effect* on the file system. Test the side-effects.
- Some commands are **orchestration shells** — they dispatch one or
  more existing agents, then write the agents' output to a file. The
  command itself contains very little logic; the *agents* are where
  the work happens. Test the agents (already covered by Layer 3
  TDAD); the command becomes a thin smoke test that the dispatch
  wiring is correct.
- Some commands are **genuinely model-mediated** — they run a multi-
  turn interactive session where the model reasons across questions,
  user answers, and accumulating context. There is no clean
  side-effect to assert against because the value *is* the model's
  reasoning. These are the hardest to test, and applying TDAD to them
  is the highest-cost / highest-fragility category.

A per-category answer means we get the cheap wins first (mechanical
commands tested cheaply) and acknowledge that some commands may
deliberately stay at lower tiers of the framework's promotion ladder
(unverified or agent-verified-only) because Layer-3 testing them
costs more than the value they return.

---

## 3. Inventory: 25 commands by category

### Category P — Procedural-deterministic (11 commands)

These are mostly mechanical: read files, transform, write files. The
inferential work is minor (formatting the output, asking a single
clarifying question). Their value is the side-effect on the file
system.

| Command | What it does | Why P |
| --- | --- | --- |
| `convention-sync` | Read HARNESS.md, generate Cursor/Copilot/Windsurf files | Pure transformation |
| `harness-status` | Read HARNESS.md Status section, format and print | Read + format |
| `harness-upgrade` | Diff template vs local HARNESS.md, present items | Mostly mechanical with light judgement |
| `harness-affordance discover` | Scan config files, emit draft inventory | Pure scan + emit |
| `governance-health` | Read governance audit reports, print summary | Read + format |
| `observatory-verify` | Check 82 signals against output files | Pure data verification |
| `worktree` | Git worktree operations | Pure shell |
| `superpowers-status` | Check files exist, print dashboard | Pure file checks |
| `reflect` | Append entry to REFLECTION_LOG.md | File append (model formats the entry) |
| `harness-health` (quick mode) | Read multiple data sources, aggregate, format | Read + aggregate |
| `cost-capture` | Guide user through dashboards, write snapshot | Data entry with model formatting |

### Category O — Orchestration (7 commands)

These commands dispatch one or more existing agents and write the
agents' output to a file. The command file is glue; the *agents* do
the substantive work.

| Command | Dispatches | Why O |
| --- | --- | --- |
| `harness-audit` | harness-discoverer + harness-enforcer | Multi-agent dispatch |
| `governance-audit` | governance-auditor | Single agent dispatch |
| `harness-init` | harness-discoverer + guided init | Dispatch + guided wrap |
| `harness-sync` | composes /convention-sync + audit-engine | Multiplexer |
| `superpowers-init` | full habitat setup orchestration | Complex orchestration |
| `choice-cartograph` | choice-cartographer agent | Single agent dispatch |
| `diaboli` | advocatus-diaboli agent | Single agent dispatch |

### Category M — Model-mediated (7 commands)

These commands run a multi-turn interactive session. The model reasons
across questions, user answers, and accumulating context. The value is
the reasoning trajectory, not a single asserted output.

| Command | What makes it M |
| --- | --- |
| `assess` | Multi-step assessment (scan, ask, score, recommend, badge update) |
| `portfolio-assess` | Aggregation with model synthesis across many repos |
| `extract-conventions` | Interactive 5-question session with reasoning between answers |
| `harness-constrain` | Interactive constraint authoring with iterative refinement |
| `governance-constrain` | Interactive governance constraint authoring with three-frame check |
| `harness-gc` | Two interactive modes (add rule / run rules) with model reasoning |
| `harness-onboarding` | Multi-source synthesis of an ONBOARDING.md document |

### Inventory totals

11 + 7 + 7 = 25. ✓

---

## 4. Per-category testing strategy

### P — Test side-effects (Option C from the spike)

**Approach.** For each P command, identify its observable side-effects
on the file system or stdout. Write a Layer-3-equivalent test that:

1. Sets up a fixture project state
2. Invokes the command's deterministic core
3. Asserts the side-effects (files created, content matches expected,
   stdout contains expected sentinels)

**Two viable invocation paths**, both worth supporting:

- **C-direct**: extract the deterministic core into a Python helper,
  test the helper. The markdown command becomes glue between the user
  and the helper. This is the cleanest pattern for genuinely
  side-effect-driven commands like `convention-sync` and
  `observatory-verify`.

- **C-subprocess**: run the command file's bash blocks (the existing
  command files contain shell snippets the model invokes) directly
  as subprocesses, with a controlled fixture cwd. Skip the
  model-mediated wrapper. Useful when the command's logic is already
  in shell; rewriting in Python would be busywork.

**Cost**: low. ~$0 per test (no LLM). Wall-clock seconds, not minutes.
**Granularity**: per-command at first; per-side-effect over time.
**Coverage target**: all 11 P commands.

### O — Test the dispatched components, smoke the command

**Approach.** Orchestration commands inherit most of their value from
the agents they dispatch. The framework already has Layer 3 TDAD for
agents (PR #285). Extend that to cover every dispatched agent, and
test the *command* with a thin smoke check:

1. **Structural** (Layer 1-equivalent): the command file exists, its
   frontmatter parses, it references agents and skills that actually
   exist in the plugin.
2. **Wiring** (new minimal layer): parse the command's body, extract
   the agent dispatches it declares (e.g., grep for `Dispatch the
   harness-discoverer agent`), assert each named agent exists. This
   catches the failure mode where a command renames its target agent
   but forgets to update the dispatch line.

The substantive testing — does the dispatched agent actually do the
right thing? — lives at Layer 3 for the agent itself, not for the
command. Each O command becomes a thin shell over already-tested
agents.

**Cost**: ~$0 per test (structural and grep). Wall-clock sub-second.
**Coverage target**: all 7 O commands at the structural+wiring level;
all 13 plugin agents at Layer 3 (4 of which are spike targets already
or upcoming).

### M — Acknowledge the cost; instrument lightly

**Approach.** Genuinely model-mediated commands resist Layer-3 TDAD
because the value is the multi-turn reasoning trajectory, not a single
asserted output. Three claims drive the recommendation:

- **The combinatorial cost is high.** A 5-question interactive session
  has many branches. Even if each branch is testable in isolation,
  the test matrix scales with branch count × user-answer space.
- **Test fragility scales with model variance.** The trajectory of an
  interactive session changes with every model upgrade. Tests written
  against today's reasoning may fail tomorrow even when the command
  is still working as intended.
- **The framework's promotion ladder permits lower tiers.** A command
  staying *unverified* or *agent-verified-via-its-skills* is a valid
  outcome. Not every component must reach Layer 3.

For M commands, this spec recommends:

1. **Layer 1 structural check** (covered by the universal pass below)
2. **Skill-coverage check**: the command references its driving
   skill (`assess` ↔ `ai-literacy-assessment` skill, `extract-conventions`
   ↔ `convention-extraction` skill, etc.) and that skill exists. Most
   M commands offload their substantive logic to a skill; the skill
   is the right unit of test.
3. **No Layer 3** (deliberately). Skills get Layer 3 tests where
   feasible (the cupid-code-review pattern from PR #285 generalises
   to several other skills); the M commands themselves remain
   structurally smoked but behaviourally unverified.

**Cost**: ~$0 (structural + skill-coverage). Some skill Layer-3 tests
already covered.
**Coverage target**: all 7 M commands at structural + skill-coverage;
some driving skills at Layer 3 in subsequent iterations.

---

## 5. Phasing

The phases are explicitly designed so cost grows monotonically and
each phase produces a usable result on its own.

### Phase 1 — Universal structural pass (cheap, immediate)

For **all 25 commands**, add to the existing `tdad_tests` Layer 1
suite:

- Frontmatter is well-formed (already covered for all components by
  the existing `TestPluginComponents` class — verify it currently
  passes for all commands; it does).
- The command body references agents and skills that exist
  (this is the new check — a structural-wiring pass that walks each
  command's prose for `Dispatch the <name> agent` / `Read the <name>
  skill` patterns and asserts each named referent exists).

**Cost**: $0, sub-second. **Coverage**: 25 / 25. **Output**:
`tdad_tests/tests/test_command_wiring.py` (or extend
`test_layer1_structural.py`).

This phase alone would have caught the rename-without-callsite-update
failure class that the team has hit at least once before per the
existing `Plugin-framework anchoring` GC rule history. The check is
PR-time rather than weekly, so the failure is caught earlier.

### Phase 2 — Spike Option C against 2 P commands

Pick 2 of the 11 P commands and validate Option C. Recommended:

- `convention-sync` (cleanest case; pure transformation; HARNESS.md
  in → tool-rule files out)
- `observatory-verify` (clearest assertion surface; 82 named signals
  to check)

For each: extract or wrap the deterministic logic, write 1–2
behavioural tests with a fixture project, assert side-effects.

**Cost**: ~1 hour of design + ~3 hours of implementation per command.
**Output**: per-command test files in `tdad_tests/tests/`,
fixtures in `tdad_tests/fixtures/`. Spike PR analogous to #282.

If the spike works, expand to the remaining 9 P commands in a single
follow-up PR. If it doesn't, the spike has surfaced what makes Option
C harder than the design assumed — informative either way.

### Phase 3 — Orchestration command wiring

Add `command-dispatches-existing-agents` parametrised tests across
the 7 O commands. Each test parses the command body and asserts each
named agent exists in `agents/`. ~$0, fast.

This is essentially a tightening of Phase 1's wiring check, scoped
explicitly to dispatch lines.

### Phase 4 — Skill-driven M commands (only if cost/benefit holds)

The M commands' value lives in their driving skills. Inventory each
M command's skill, write Layer-3 tests for the *skill* (per the
existing PR #285 pattern for cupid-code-review), and call this
sufficient. The M command itself stays at structural+skill-coverage.

If a particular M command has a side-effect worth asserting
(`assess` writes an assessment doc; `harness-onboarding` writes
ONBOARDING.md), wrap that side-effect in a Phase-2-style Option C
test — case by case.

**Cost**: variable per skill. Run only after Phases 1–3 prove the
architecture and the team has bandwidth to invest.

### What this spec deliberately defers

- Subprocess-based testing of the full Claude Code runtime (Option B
  from the spike). Listed as "deliberately not chosen": the
  CI-environment cost and subprocess fragility are too high for the
  return.
- Per-command behavioural tests for every M command. Acknowledged as
  expensive; deliberately not pursued unless Phase 4 proves
  worthwhile per command.

---

## 6. Trade-offs and open questions

### Trade-off — Option C-direct vs C-subprocess

For P commands, the choice between extracting logic into Python and
running existing bash blocks as subprocesses is a per-command call.
C-direct produces cleaner, faster, more parametrisable tests; the
extraction work is cost upfront. C-subprocess works with what already
exists; the subprocess invocation is more fragile (env vars, working
directory, shell quoting) but no extraction is needed.

The Phase-2 spike should explicitly try both patterns on its 2 chosen
commands and let real evidence settle the per-command default.

### Open question — what counts as a "wiring" check?

Phase 1's wiring check (does the command reference agents that exist?)
is a structural test. The simple form — grep for `Dispatch the <name>
agent` — works for current command conventions. If commands evolve to
use a more flexible reference style (templated names, dynamic
lookup), the grep loses fidelity.

A more robust form would parse the command's body as markdown,
extract code-fenced blocks and prose mentions, and validate against
a structured allowlist. That's more work; the simple grep is fine
until it breaks.

### Open question — should M commands ever reach Layer 3?

This spec says "no, by default; case by case if there's a clear
side-effect." That position deserves to be revisited if/when M
commands start failing in production in ways that simpler tests would
have caught. For now, the recommendation reflects cost/benefit; if
the cost calculus changes, the recommendation should update.

### Open question — should the spec write itself as a skill?

The per-category pattern (P / O / M) is a piece of architectural
knowledge that future agents may need. Currently the knowledge lives
in this spec and (after merge) in the harness-engineering skill or
TDAD-related skill body. If/when a second instance of the same
question arises (e.g., when applying TDAD to a new component type
in a future plugin), the pattern should be promoted from
"spec we wrote once" to "skill the team can apply on demand."

---

## 7. Decision

Adopt the per-category strategy. Sequence the phases as listed.
Phase 1 (universal structural pass) is the cheapest and highest-
leverage; do it first regardless of subsequent decisions. Phase 2
validates the architecture for P commands before scaling. Phase 3
tightens orchestration wiring. Phase 4 is opt-in per command.

Issue #284 closes once this spec is reviewed and approved. The
phases themselves are tracked as separate follow-up issues so each
phase can be picked up independently.

---

## 8. What this spec does NOT propose

- **A version bump.** This is design-only; no plugin behaviour changes
  in this PR.
- **An immediate full implementation.** The phases are deliberate; the
  next PR is Phase 1 alone.
- **A single right answer for command testing.** The premise of this
  spec is that there isn't one; the right answer is per category, and
  pretending otherwise leads to either over-engineering (testing P
  commands the same heavyweight way M commands need) or
  under-engineering (using P-style tests on M commands that need
  more).
- **Removal of any existing tests.** Layer 0 (deterministic plumbing),
  Layer 1, Layer 2, Layer 3 all stand as built. This is a *new
  testing direction*, not a replacement.
