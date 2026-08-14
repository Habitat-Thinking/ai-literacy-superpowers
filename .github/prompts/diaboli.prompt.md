---
name: diaboli
description: Run the adversarial reviewer on a spec or implementation — produces the objection record at docs/superpowers/objections/<slug>.md (spec mode) or <slug>-code.md (code mode); use after spec-writer completes or after the final code-reviewer PASS
---

# Diaboli

Run the advocatus-diaboli adversarial reviewer against a spec file (spec mode)
or implementation (code mode).

## Usage

```text
/diaboli docs/superpowers/specs/<date>-<name>.md [--mode spec|code]
```

`--mode` defaults to `spec`. Pass `--mode code` after the final code-reviewer
PASS, before integration-agent.

## Steps

1. Confirm the spec file exists at the path provided
2. Derive the slug: strip the date prefix and `.md` extension from the filename
3. Determine output path from mode:
   - Spec mode: `docs/superpowers/objections/<slug>.md`
   - Code mode: `docs/superpowers/objections/<slug>-code.md`
4. Read the spec file in full; in code mode also read implementation files
   changed on the current branch
5. Read `ai-literacy-superpowers/skills/advocatus-diaboli/SKILL.md` for the
   charter, six categories, severity definitions, dispatch mode weighting,
   and output format
6. Apply category weighting for the active mode (see Dispatch Modes section
   in SKILL.md)
7. Generate objection record content following the skill's output format:
   - YAML frontmatter with `mode: spec|code`, all objections
     (`disposition: pending`, `disposition_rationale: null`)
   - Prose sections per objection (`## O<N> — <category> — <severity>`)
   - Closing "Explicitly not objecting to" section (at least three entries)
8. Write to the mode-appropriate path (overwrite if exists)
9. Validate the written file: check frontmatter structure including `mode:`
   field, field presence, pending dispositions, category/severity enum values,
   objection count (1–12), prose sections, closing section
10. Fix any validation failures in place
11. Report: output path, mode, objection count by severity, category distribution
12. Remind the user to fill in dispositions before the appropriate gate:
    - Spec mode: plan-approval gate
    - Code mode: integration-approval gate
