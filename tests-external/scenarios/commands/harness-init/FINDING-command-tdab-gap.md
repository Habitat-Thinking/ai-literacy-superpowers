---
component: harness-init
component_type: command
tier: finding
---

# Finding: command-testing gap (harness-init)

## The Finding

Slash commands are the spike's awkward case. Agents and skills can be
exercised through the Claude Agent SDK directly: an agent's frontmatter
becomes the system prompt and tool list for an SDK session, and a
skill's description plus body get loaded as the model's reference
material. Both fit the SDK's existing abstractions cleanly.

A slash command does not. A command file like `harness-init.md` is a
*procedural script* written for the Claude Code runtime — it dispatches
subagents, writes files, asks the user questions, and threads state
across multiple turns. The Claude Agent SDK exposes none of this
machinery: it has agents, tools, skills, and message streams, but no
"slash command" abstraction.

Three options surface, none of them obviously right:

### Option A: Translate the command into an SDK pseudo-script

Read `harness-init.md`, parse its sections, and re-implement the same
behaviour as a sequence of SDK calls (dispatch the harness-discoverer
agent → check its output → ask follow-up questions → write
`HARNESS.md`). The test then runs the pseudo-script and asserts the
final state.

**Cost**: every command needs a hand-written runner. Maintenance
burden grows with command count.

**Risk**: the test is testing the *runner's* re-implementation of the
command, not the command itself. A divergence between the runner and
the actual Claude Code execution path is invisible.

### Option B: Run the command via the Claude Code CLI

Spin up Claude Code as a subprocess in a fixture directory, feed it
the `/harness-init` invocation, capture the output, assert the file
state.

**Cost**: requires Claude Code installed and configured in CI. Slow
(full session startup per test). Difficult to script around the
command's interactive prompts.

**Risk**: tests become coupled to Claude Code's CLI semantics, which
are themselves still evolving.

### Option C: Test only the deterministic side-effects

A command's actual *value* is mostly its side-effects on the file
system: `harness-init` writes a `HARNESS.md`, optionally creates
hooks, possibly modifies `.gitignore`. Test those side-effects
through a different surface — e.g., a `harness-init` Python helper
that performs the same writes — and treat the markdown command file
as glue between the user and the helper.

**Cost**: requires extracting side-effect logic out of the command
markdown into testable code. Many commands today are pure markdown.

**Risk**: not all commands have a clean separation between
"deterministic side-effect" and "model-mediated decision". `/assess`,
for example, is mostly model-mediated.

## Recommendation (for follow-up design)

The architecture for command testing is its own design problem and
should not be handled inside this spike. The recommended next step is:

1. Inventory the 25 commands by what they actually *do*: which are
   procedural-and-deterministic (write files, run scripts), which are
   model-mediated (require inference at multiple steps), which are
   mostly orchestration (dispatch subagents).
2. For procedural-deterministic commands, prefer Option C — extract
   side-effect logic into testable scripts.
3. For model-mediated commands, accept Option B — schedule them as a
   separate, expensive test tier that runs nightly.
4. For orchestration commands, test the *dispatched components*
   (which Layer 3 already covers for agents and skills) and treat the
   command as glue.

## Spike outcome

The spike's job here is to surface the question, not to answer it.
This finding moves the architecture from "we will TDAB everything"
to "we will TDAB agents and skills cleanly; commands need a separate
design pass." That refinement is itself a productive output of the
spike.
