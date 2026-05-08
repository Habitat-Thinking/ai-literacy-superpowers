---
component: assessor
component_type: agent
tier: finding
---

# Finding: agent frontmatter is not strict YAML

## The Finding

The Layer 1 structural sweep flagged six agent files whose frontmatter
is not strict YAML:

- `agent:assessor`
- `agent:governance-auditor`
- `agent:harness-auditor`
- `agent:harness-discoverer`
- `agent:harness-enforcer`
- `agent:harness-gc`

All six follow the same pattern: a multi-line ``description:`` value
that contains embedded ``<example>`` blocks with their own colon-bearing
keys (``Context:``, ``user:``, ``assistant:``). Strict PyYAML rejects
the second colon as the start of a new mapping value. The Claude Code
loader accepts it.

The assessor file (line 3 onwards) is the canonical illustration:

```yaml
---
name: assessor
description: Use this agent to run an AI literacy assessment ... Examples:

 <example>
 Context: User wants to know their team's AI literacy level
 user: "Where are we on the AI literacy framework?"
 ...
```

The colon after ``Context`` is what trips strict YAML.

## Why this matters

The structural test layer asserts "every component has parseable
frontmatter". That assertion fails today against ~45% of plugin agents.
Rather than block the spike on this, the test reports the finding via
``pytest.skip`` so the architectural question stays visible without
breaking the suite.

## The architectural question

Two paths forward, and the spike does not pick between them:

### Option A: Standardise the plugin on strict YAML

Convert the six affected files to use a YAML block scalar:

```yaml
description: |
  Use this agent to run an AI literacy assessment ... Examples:

  <example>
  Context: User wants to know their team's AI literacy level
  ...
```

The ``|`` token tells YAML to treat the indented block as a literal
string. Block scalars are well-supported by every YAML library and
remove the ambiguity entirely.

**Cost**: a small, mechanical edit to each affected file. One PR.
**Benefit**: every YAML parser everywhere parses the frontmatter
cleanly. The strict-YAML structural test passes. No special cases.

### Option B: Adopt the Claude Code loader's lenient convention

Document the convention formally — *agent descriptions may contain
indented blocks that strict YAML cannot parse; loaders should treat
the description value as everything from ``description:`` to the next
recognised top-level key (``model``, ``color``, ``tools``)* — and
update the test runner's parser to follow that convention.

**Cost**: an extra parsing layer on every consumer of plugin
frontmatter. The convention has to be re-implemented in every
language and tool that wants to read the plugin.
**Benefit**: existing files unchanged. The convention matches what
Claude Code's loader actually does.

## Recommendation (for follow-up)

Option A is structurally simpler and ages better. The mechanical edit
is small and the resulting files are parseable by every YAML library
without per-tool parsing logic. The argument for Option B (zero edits
to existing files) only holds if the test runner is the only
non-Claude-Code consumer that will ever read these files; given the
plugin is documented at the framework level and likely to be consumed
by independent tooling over time, that assumption is fragile.

The spike does not implement either option. It surfaces the choice and
treats the structural-test skip as an explicit, named outcome rather
than a quiet failure.

## Related

- Test surfacing the finding: ``tests/test_layer1_structural.py:TestFrontmatterStrictYaml``
- Companion finding for commands: ``scenarios/commands/harness-init/FINDING-command-tdab-gap.md``
