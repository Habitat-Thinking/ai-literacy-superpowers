---
name: harness-init
description: Set up a living harness for this project — select features, discover the stack, define conventions, generate HARNESS.md with enforcement. Re-run to add features incrementally.
---

# /harness-init

Set up a living harness for this project. Choose which features to
configure — context engineering, constraints, garbage collection, CI,
and observability — then walk through a guided conversation for each.
Re-run at any time to add features incrementally; existing
configuration is preserved.

Read the `harness-engineering` and `context-engineering` skills from
this plugin before proceeding. They provide the conceptual framework
and convention-writing guidance needed for this conversation.

## Process

### 1. Discover

Dispatch the `harness-discoverer` agent to scan the project. Wait for
its discovery report before proceeding.

Also check whether `HARNESS.md` already exists. If it does, note which
sections contain real content (not the placeholder marker
`<!-- Not yet configured. Run /harness-init and select this feature to set up. -->`).
Pass this information to the feature selection step so it can set
appropriate defaults.

### 2. Present Findings

Show the user what was discovered:

- Tech stack and versions
- Existing linters, formatters, and CI checks
- Any existing convention documentation (CLAUDE.md, CONTRIBUTING.md)
- Pre-commit hooks already in place

Frame this as: "Here's what your project already has. Let's build on
it."

### 3. Select Features

Present a feature selection menu. The six selectable areas are:

| Feature | What it configures | Default (first run) |
| --- | --- | --- |
| Context engineering | Stack declaration + conventions | on |
| Architectural constraints | Enforcement rules + secret detection | on |
| Garbage collection | Periodic entropy checks | on |
| CI configuration | GitHub Actions workflow + auto-enforcer | on |
| Observability | README badge + status section | on |
| Affordances | Declared-tool inventory (`## Affordances` section) | off |

**First run** (no HARNESS.md exists): all features default to on **except
Affordances, which is opt-in (default off)** — most projects adopt it later
via `/harness-affordance discover` once they have a populated permissions
allowlist to scan. The user can turn it on here.

**Re-run** (HARNESS.md exists): detect which sections are already
configured by checking for the placeholder marker
`<!-- Not yet configured. Run /harness-init and select this feature to set up. -->`
in each section. Already-configured sections default to off (skip).
Unconfigured sections default to on. The user can toggle any combination.

Tell the user: "All features are selected by default. Deselect any you
want to skip for now — you can always add them later by re-running
/harness-init."

On re-run, tell the user which features are already configured and
frame unconfigured features as recommendations: "These features aren't
set up yet. I recommend adding them."

### 4. Ask About Conventions

**Gate**: only run this step if "Context engineering" was selected in
step 3. If not selected, skip to the next step silently.

Ask the user about their conventions, one topic at a time. Use the
discovery report to make informed suggestions. Cover:

- **Naming**: What casing and patterns does the team use?
- **File structure**: How are files organised? One type per file?
- **Error handling**: How should errors be handled and propagated?
- **Documentation**: What must have doc comments? What should comments
  explain?

For each topic, offer concrete options based on what the discoverer
found. Use the convention patterns from the `context-engineering` skill
to ensure conventions are enforceable.

### 5. Ask About Constraints

**Gate**: only run this step if "Architectural constraints" was selected
in step 3. If not selected, skip to the next step silently.

For each convention, ask whether the user wants it enforced. For each
that should be enforced:

- Check if a deterministic tool was discovered that could enforce it
- If yes, offer to configure it and set enforcement to `deterministic`
- If no, offer agent-based enforcement or leave as `unverified`

Ask about scope: should this check run at commit time (fast feedback),
PR time (strict gate), or weekly (periodic sweep)?

#### Secret detection (default constraint)

The template includes a "No secrets in source" constraint. During setup:

1. Check whether `gitleaks` is available: `command -v gitleaks`
2. If **found**: inform the user that the constraint will be set to
   `deterministic` with gitleaks as the tool. Ask if they want to
   customise the configuration (e.g. add allowlist paths). Offer to
   run an initial scan: `gitleaks detect --source . --no-banner`
3. If **not found**: inform the user that the constraint will remain
   `unverified`. Suggest installation:
   - macOS: `brew install gitleaks`
   - Linux/Go: `go install github.com/gitleaks/gitleaks/v8@latest`
   - Then re-run `/harness-init` or use `/harness-constrain` to promote

Either way, tell the user what happened and allow them to override.
Read the `secrets-detection` skill from this plugin for full gitleaks
guidance if the user asks questions about configuration or scanning.

### 6. Ask About Garbage Collection

**Gate**: only run this step if "Garbage collection" was selected in
step 3. If not selected, skip to the next step silently.

Ask whether the user wants periodic checks for:

- Documentation freshness
- Dependency currency
- Convention drift
- Dead code

For each, set frequency and auto-fix preference.

### 7. Generate HARNESS.md

**First run** (no HARNESS.md exists):

Read the template from `${CLAUDE_PLUGIN_ROOT}/templates/HARNESS.md`.
For each selected feature, replace placeholder values with discovered
facts and user responses as before. For each unselected feature, replace
the section body with the placeholder marker:

```text
<!-- Not yet configured. Run /harness-init and select this feature to set up. -->
```

**Affordances** is opt-in: if **unselected** (the default), replace the
`## Affordances` section body with the placeholder marker like any other
unselected feature. If **selected**, keep the section's example entries and
schema comments in place and tell the user to run
`/harness-affordance discover` to populate it from their real config.

Write the result to `HARNESS.md` at the project root.

**Re-run** (HARNESS.md exists):

Read the existing `HARNESS.md`. For each selected feature, replace the
corresponding section (`## Context`, `## Constraints`,
`## Garbage Collection`, `## Affordances`, or `## Status`) with freshly
generated content from user responses. For unselected features, preserve
the existing section content verbatim — do not modify it. If the
**Affordances** feature is newly selected on a project that lacks the
section, insert `## Affordances` from the template **after
`## Garbage Collection` and before `## Status`** (matching the template's
section order) without touching the other sections.

Section boundaries are defined by the `##` headings in the template:
`## Context`, `## Constraints`, `## Garbage Collection`, `## Affordances`,
`## Status`. Each section runs from its `##` heading to the next `##`
heading or end of file.

**Template version marker (both first run and re-run):**

After writing HARNESS.md, ensure it contains a `<!-- template-version: X.Y.Z -->`
comment on its own line immediately after the intro comment block,
where X.Y.Z is the current plugin version read from
`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`. If the marker
already exists, update it to the current version. If it does not
exist, insert it after the line containing
`https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html -->`.

### 8. Validate Generated HARNESS.md

**This step is mandatory.** After writing HARNESS.md, read it and
verify its structure against `templates/HARNESS.md`.

**Structural checks:**

1. All 4 top-level sections present: `## Context`,
   `## Constraints`, `## Garbage Collection`, `## Observability`
2. Context section has `### Stack` and `### Conventions`
   subsections (either with content or the placeholder marker)
3. Observability section has `### Operating cadence`,
   `### Health thresholds`, and `### Regression detection`
   subsections
4. `## Status` section present with all 4 fields: Last audit,
   Constraints enforced, Garbage collection active, Drift detected
5. Template version marker comment present:
   `<!-- template-version: X.Y.Z -->` where X.Y.Z matches the
   current plugin version
6. **Affordances (optional):** `## Affordances` is only required when the
   Affordances feature was selected. If selected, the section is present
   (with example entries or the placeholder marker) and sits after
   `## Garbage Collection`. If not selected, its absence is **not** a
   failure.

If any check fails, fix HARNESS.md in place:

- Add missing sections from the template with placeholder markers
- Insert the template version marker if absent
- Add missing Status fields with default values

Do not re-run the init conversation. Fix the output directly.

### 9. Generate CI Configuration

**Gate**: only run this step if "CI configuration" was selected in
step 3.

**Dependency**: CI configuration requires constraints to exist. If
"Architectural constraints" was not selected in step 3 and no
`## Constraints` section exists in HARNESS.md (or it contains only the
placeholder marker), tell the user: "CI configuration requires at least
one constraint to enforce. Skipping CI setup — run /harness-init again
after adding constraints." Then skip to the next step.

If constraints exist (either just configured or from a previous run),
proceed with the existing CI generation logic:

If GitHub Actions was detected (or the user confirms it), read the
template from `${CLAUDE_PLUGIN_ROOT}/templates/ci-github-actions.yml`.
Add deterministic tool steps for each PR-scoped deterministic
constraint. Write to `.github/workflows/harness.yml`.

If no CI was detected, offer the generic script from
`${CLAUDE_PLUGIN_ROOT}/templates/ci-generic.sh`.

#### Auto-enforcer for agent PR constraints

After generating `harness.yml`, check whether the HARNESS.md being
produced contains any agent-scoped PR constraints. If it does:

1. Inform the user: "Your harness includes agent-based PR constraints.
   These cannot run in the standard CI workflow — they require the
   auto-enforcer action."
2. Offer to copy `${CLAUDE_PLUGIN_ROOT}/templates/ci-auto-enforcer.yml`
   to `.github/workflows/auto-enforcer.yml` as part of the init commit
3. Remind the user to add the `ANTHROPIC_API_KEY` secret to their
   repository before the first PR: Settings > Secrets and variables >
   Actions > New repository secret
4. Read the `auto-enforcer-action` skill from this plugin for full
   setup guidance if the user asks questions

If no agent PR constraints exist, skip this offer silently.

### 10. Add README Badge

**Gate**: only run this step if "Observability" was selected in step 3.

**Dependency**: the badge requires HARNESS.md to exist with at least
one configured section. If HARNESS.md contains only placeholder markers
(no real content was generated), tell the user: "No harness features
configured yet — skipping badge. Run /harness-init to add features
first." Then skip to the next step.

If HARNESS.md has content, proceed with badge generation as before:

Add the harness badge to the project's README.md. Use the badge update
script at `${CLAUDE_PLUGIN_ROOT}/scripts/update-badge.sh` or insert
manually:

```text
[![Harness](https://img.shields.io/badge/Harness-0%2FN_enforced-808080?style=flat-square)](HARNESS.md)
```

### 11. Commit

Stage and commit all generated files:

- HARNESS.md
- CI workflow (if generated)
- README.md (badge update)

Commit message: "Initialize project harness with HARNESS.md"

### 12. Tag Repository

If the project is hosted on GitHub, add the `agent-harness-enabled`
topic tag to the repository:

```bash
gh repo edit --add-topic agent-harness-enabled 2>/dev/null
```

This tag signals to portfolio assessments and other tooling that the
repo has a harness. If `gh` is not available or the command fails
(not a GitHub repo, no permissions), skip silently.

Also add the badge to the README if not already present:

```text
[![Agent Harness Enabled](https://img.shields.io/badge/Agent_Harness-Enabled-000000?style=flat-square)](HARNESS.md)
```

### 13. Summary

Tell the user:

- Which features were configured in this run
- How many constraints were declared and how many are enforced (if
  constraints were configured)
- Which features remain unconfigured, framed as next steps:
  "To add garbage collection later, run /harness-init and select it"
- What to do next: `/harness-constrain` to add more rules,
  `/harness-status` to check health, `/harness-audit` to verify
  enforcement
