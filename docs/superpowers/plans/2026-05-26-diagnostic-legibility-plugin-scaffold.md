# Diagnostic Legibility plugin — S1 scaffold — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship slice S1 of the carpaccio slicing record at `docs/superpowers/slices/diagnostic-legibility-plugin.md` — a structurally complete, loadable `diagnostic-legibility` plugin at v0.1.0 with no functional agent code. Register it in the marketplace and the docs site.

**Architecture:** A new top-level plugin directory `diagnostic-legibility/` (sibling of `model-cards/` and `ai-literacy-superpowers/`) containing `.claude-plugin/plugin.json`, README, CHANGELOG, and empty placeholder subdirectories (`agents/`, `skills/`, `commands/`, `templates/`). Registration in `.claude-plugin/marketplace.json` and a docs-site landing page complete the loop. The marketplace listing version bumps `0.3.0` → `0.4.0` because adding a `plugins[]` entry is a listing-contract change.

**Tech Stack:** Markdown + JSON. No code added. The existing version-check workflow iterates `plugins[]` and verifies per-plugin sync (marketplace entry `version` matches each plugin's `plugin.json` `version`); both entries for the new plugin land at `0.1.0`.

**Spec reference:** `docs/superpowers/specs/2026-05-26-diagnostic-legibility-plugin-scaffold-design.md`

---

## File structure

```
diagnostic-legibility/                                # NEW directory
├── .claude-plugin/
│   └── plugin.json                                   # NEW
├── README.md                                         # NEW
├── CHANGELOG.md                                      # NEW
├── agents/.gitkeep                                   # NEW (empty placeholder)
├── skills/.gitkeep                                   # NEW
├── commands/.gitkeep                                 # NEW
└── templates/.gitkeep                                # NEW

docs/plugins/diagnostic-legibility/                   # NEW directory
├── index.md                                          # NEW (landing page)
└── _template.md                                      # NEW (Diataxis quadrant template)

.claude-plugin/marketplace.json                       # MODIFIED (add entry, bump version)
README.md                                             # MODIFIED (table row + badge)
```

No file under `ai-literacy-superpowers/` is touched. No file under `model-cards/` is touched.

---

## Phase 1 — Plugin manifest + scaffold

### Task 1: Plugin manifest

**Files:**
- Create: `diagnostic-legibility/.claude-plugin/plugin.json`

- [ ] **Step 1: Create directory and write the manifest**

```bash
mkdir -p diagnostic-legibility/.claude-plugin
```

Write `diagnostic-legibility/.claude-plugin/plugin.json` with EXACTLY this content:

```json
{
  "name": "diagnostic-legibility",
  "version": "0.1.0",
  "description": "Agents accountable for helping to maintain human understanding. The first agent builds, self-challenges, and cross-checks two models of a codebase scope — architectural moving parts and domain concepts — and surfaces the mutually-corrected models on demand. Future agents will extend the discipline to other domains.",
  "author": {
    "name": "Russ Miles"
  },
  "keywords": [
    "diagnostic-legibility",
    "human-understanding",
    "ai-accountability",
    "legibility",
    "two-model",
    "cross-check",
    "ai-literacy"
  ]
}
```

- [ ] **Step 2: Verify valid JSON**

```bash
python3 -c "import json; json.load(open('diagnostic-legibility/.claude-plugin/plugin.json'))" && echo "valid"
```

Expected: `valid`

- [ ] **Step 3: Commit**

```bash
git add diagnostic-legibility/.claude-plugin/plugin.json
git commit -m "Diagnostic Legibility plugin — manifest at v0.1.0"
```

### Task 2: README

**Files:**
- Create: `diagnostic-legibility/README.md`

- [ ] **Step 1: Write the README**

Write `diagnostic-legibility/README.md` with EXACTLY this content:

```markdown
# diagnostic-legibility

Agents accountable for helping to maintain human understanding.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/)
and [model-cards](../model-cards/) in the same marketplace.

## Status

**v0.1.0 — scaffold only.** This plugin is structurally complete and
loadable but ships with no functional agents or commands. It is here
so the next three deliverables can land on a stable foundation:

- [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent (architectural + domain models with per-model self-challenge)
- [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism (mutual model correction)
- [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — S4: Surfacing interface (on-demand human legibility command)

The carpaccio slicing record at
[`docs/superpowers/slices/diagnostic-legibility-plugin.md`](../docs/superpowers/slices/diagnostic-legibility-plugin.md)
records the full decomposition from parent issue
[#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).

## Charter

The plugin's purpose is to host agents that are accountable for
maintaining human understanding of complex systems. The inaugural
agent (in development) builds two models of a codebase scope — one
for architectural moving parts, one for domain concepts — subjects
each to a challenge–refine cycle, then uses them to cross-check and
correct each other, producing mutually-corrected models that can be
surfaced on demand.

The framing is deliberately broad: codebase legibility is the first
instance, but the discipline (two-model + cross-check + on-demand
surfacing) generalises to other domains. Future agents may apply it
to governance artefacts, decision records, or other complex systems.

## Install

```bash
# In Claude Code
claude plugin install diagnostic-legibility@ai-literacy-superpowers

# In Copilot CLI
copilot plugin install diagnostic-legibility@ai-literacy-superpowers
```

The plugin will install successfully but offer no commands at v0.1.0.
Wait for S2 (#331) to land before expecting functional behaviour.

## Sister plugins in the same marketplace

- [`ai-literacy-superpowers`](../ai-literacy-superpowers/) — the flagship. Harness engineering, agent orchestration, the decision-discipline triad (carpaccio, advocatus-diaboli, choice-cartographer), CUPID code review, compound learning.
- [`model-cards`](../model-cards/) — Mitchell-extended model card research and authoring.
```

- [ ] **Step 2: Commit**

```bash
git add diagnostic-legibility/README.md
git commit -m "Diagnostic Legibility plugin — README with charter and next-deliverable links"
```

### Task 3: CHANGELOG

**Files:**
- Create: `diagnostic-legibility/CHANGELOG.md`

- [ ] **Step 1: Write the CHANGELOG**

Write `diagnostic-legibility/CHANGELOG.md` with EXACTLY this content:

```markdown
# Changelog

## 0.1.0 — 2026-05-26

### Scaffold

Initial plugin scaffold. Establishes the Diagnostic Legibility plugin
as a first-class entry in the marketplace.

- `.claude-plugin/plugin.json` declaring the plugin at v0.1.0 with the
  charter: *"Agents accountable for helping to maintain human
  understanding."*
- Empty placeholder directories `agents/`, `skills/`, `commands/`,
  `templates/` — structural signals for where future content lands.
- README documenting the charter, the v0.1.0 scaffold-only status,
  and links to the three deferred issues (#331 S2, #332 S3, #333 S4).
- Docs-site landing page at `docs/plugins/diagnostic-legibility/`.

No functional agents or commands yet — the first agent ships in
[#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331)
(S2).

Tracks parent issue [#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).
```

- [ ] **Step 2: Commit**

```bash
git add diagnostic-legibility/CHANGELOG.md
git commit -m "Diagnostic Legibility plugin — CHANGELOG v0.1.0 entry"
```

### Task 4: Placeholder directories

**Files:**
- Create: `diagnostic-legibility/agents/.gitkeep`
- Create: `diagnostic-legibility/skills/.gitkeep`
- Create: `diagnostic-legibility/commands/.gitkeep`
- Create: `diagnostic-legibility/templates/.gitkeep`

- [ ] **Step 1: Create all four empty placeholder files**

```bash
mkdir -p diagnostic-legibility/agents diagnostic-legibility/skills diagnostic-legibility/commands diagnostic-legibility/templates
touch diagnostic-legibility/agents/.gitkeep
touch diagnostic-legibility/skills/.gitkeep
touch diagnostic-legibility/commands/.gitkeep
touch diagnostic-legibility/templates/.gitkeep
```

- [ ] **Step 2: Verify**

```bash
ls -la diagnostic-legibility/{agents,skills,commands,templates}/.gitkeep
```

Expected: four `.gitkeep` files listed.

- [ ] **Step 3: Commit**

```bash
git add diagnostic-legibility/agents/.gitkeep diagnostic-legibility/skills/.gitkeep diagnostic-legibility/commands/.gitkeep diagnostic-legibility/templates/.gitkeep
git commit -m "Diagnostic Legibility plugin — empty placeholder directories"
```

---

## Phase 2 — Docs site

### Task 5: Docs landing page

**Files:**
- Create: `docs/plugins/diagnostic-legibility/index.md`

- [ ] **Step 1: Create the directory and landing page**

```bash
mkdir -p docs/plugins/diagnostic-legibility
```

Write `docs/plugins/diagnostic-legibility/index.md` with EXACTLY this content:

```markdown
---
title: Diagnostic Legibility
---
# Diagnostic Legibility

Agents accountable for helping to maintain human understanding.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/index.md)
and [model-cards](../model-cards/index.md) in the same marketplace.

## Charter

The plugin's purpose is to host agents that are accountable for
maintaining human understanding of complex systems. The inaugural
agent (in development) builds two models of a codebase scope — one
for architectural moving parts, one for domain concepts — subjects
each to a challenge–refine cycle, then uses them to cross-check and
correct each other, producing mutually-corrected models that can be
surfaced on demand to a human.

The framing is deliberately broad: codebase legibility is the first
instance, but the discipline (two-model + cross-check + on-demand
surfacing) generalises to other domains. Future agents may apply it
to governance artefacts, decision records, or other complex systems.

## Status: v0.1.0 — scaffold only

This plugin is structurally complete and loadable but ships with no
functional agents or commands yet. The next three deliverables are
filed as separate issues:

- [#331](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/331) — S2: Two-model agent
- [#332](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/332) — S3: Cross-check mechanism
- [#333](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/333) — S4: Surfacing interface

The carpaccio slicing that produced this decomposition is recorded at
[`docs/superpowers/slices/diagnostic-legibility-plugin.md`](../../superpowers/slices/diagnostic-legibility-plugin.md)
and traces back to parent issue
[#327](https://github.com/Habitat-Thinking/ai-literacy-superpowers/issues/327).

## Quadrant pages

No tutorials, how-to guides, reference, or concept pages exist yet.
Per the project convention, each Diataxis quadrant folder will be
scaffolded when its first page is written. Watch the three deferred
issues above to see what lands when.
```

- [ ] **Step 2: Commit**

```bash
git add docs/plugins/diagnostic-legibility/index.md
git commit -m "Docs — Diagnostic Legibility plugin landing page"
```

### Task 6: Diataxis quadrant template

**Files:**
- Create: `docs/plugins/diagnostic-legibility/_template.md`

- [ ] **Step 1: Identify the existing template to mirror**

```bash
ls docs/plugins/ai-literacy-superpowers/_template.md
```

Expected: file exists.

- [ ] **Step 2: Copy the existing template**

```bash
cp docs/plugins/ai-literacy-superpowers/_template.md docs/plugins/diagnostic-legibility/_template.md
```

The template contains the Diataxis-quadrant header guidance and is
plugin-agnostic (it is used as a reference, not as a navigable page).

- [ ] **Step 3: Commit**

```bash
git add docs/plugins/diagnostic-legibility/_template.md
git commit -m "Docs — Diagnostic Legibility plugin Diataxis quadrant template"
```

---

## Phase 3 — Marketplace registration

### Task 7: marketplace.json entry + version bump

**Files:**
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Inspect the current marketplace.json**

```bash
cat .claude-plugin/marketplace.json
```

Expected: top-level `version: "0.3.0"`, `plugin_version: "0.39.0"`, two entries in `plugins[]`.

- [ ] **Step 2: Bump top-level version and add the new plugin entry**

Edit `.claude-plugin/marketplace.json`. Change the top-level `"version": "0.3.0",` to `"version": "0.4.0",`.

Within the `"plugins": [ ... ]` array, append a new entry after the `model-cards` entry (preserving the array's existing entries, indentation, and trailing commas — be careful with valid JSON):

```json
    {
      "name": "diagnostic-legibility",
      "source": "./diagnostic-legibility",
      "description": "Agents accountable for helping to maintain human understanding. First agent (in development) builds, self-challenges, and cross-checks two models of a codebase scope.",
      "version": "0.1.0"
    }
```

Make sure the previous entry's closing `}` gets a comma after it before the new entry's opening `{`.

- [ ] **Step 3: Verify the JSON is valid and contains both versions correctly**

```bash
python3 -c "
import json
d = json.load(open('.claude-plugin/marketplace.json'))
assert d['version'] == '0.4.0', f'top-level version: {d[\"version\"]}'
names = [p['name'] for p in d['plugins']]
assert 'diagnostic-legibility' in names, f'missing diagnostic-legibility, have: {names}'
dl = next(p for p in d['plugins'] if p['name'] == 'diagnostic-legibility')
assert dl['version'] == '0.1.0', f'diagnostic-legibility version: {dl[\"version\"]}'
assert d['plugin_version'] == '0.39.0', f'plugin_version (should be unchanged): {d[\"plugin_version\"]}'
print('marketplace.json OK')
"
```

Expected: `marketplace.json OK`.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "Marketplace — register diagnostic-legibility plugin and bump listing 0.3.0 -> 0.4.0"
```

### Task 8: Root README — badge + table row

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read the current marketplace-table and version-badges section**

```bash
sed -n '1,35p' README.md
```

Look for the row of plugin version badges (around line 6-7: `ai-literacy-superpowers`, `model-cards`) and the marketplace table (around line 30).

- [ ] **Step 2: Add a diagnostic-legibility badge**

In the badge block at the top of the README, add a new badge line for the new plugin immediately after the existing `model-cards` badge:

```markdown
[![diagnostic-legibility](https://img.shields.io/badge/diagnostic--legibility-v0.1.0-4682B4?style=flat-square)](diagnostic-legibility/)
```

Place it between the existing `model-cards` badge line and the next line (which should be the `Skills` count badge).

- [ ] **Step 3: Update the Marketplace badge version**

Change the existing Marketplace badge from `v0.3.0` to `v0.4.0`:

```markdown
[![Marketplace](https://img.shields.io/badge/Marketplace-v0.4.0-4682B4?style=flat-square)](.claude-plugin/marketplace.json)
```

- [ ] **Step 4: Add a row to the marketplace table**

Find the table that begins:

```markdown
| Plugin | Version | What it does | Docs |
```

Append a new row immediately after the `model-cards` row:

```markdown
| **`diagnostic-legibility`** | v0.1.0 | Scaffold-only. Will host agents accountable for maintaining human understanding. First agent (in development) builds, self-challenges, and cross-checks two models of a codebase scope — see #327 and the slicing record for the four-slice roadmap. | [docs](docs/plugins/diagnostic-legibility/index.md) |
```

- [ ] **Step 5: Verify no stale 0.3.0 references remain in the badge block**

```bash
grep -n "Marketplace-v0.3.0\|diagnostic--legibility-v0\.1\.0" README.md
```

Expected: zero hits for `Marketplace-v0.3.0`; at least one hit for `diagnostic--legibility-v0.1.0`.

- [ ] **Step 6: Commit**

```bash
git add README.md
git commit -m "Root README — register diagnostic-legibility in marketplace table and badges"
```

---

## Phase 4 — Verify and ship

### Task 9: Local CI gate checks

- [ ] **Step 1: Spec-first ordering**

```bash
git log main..HEAD --reverse --oneline | head -1
```

Expected: the first line is the spec commit (`Spec — Diagnostic Legibility plugin S1 scaffold`).

- [ ] **Step 2: Per-plugin version sync**

```bash
python3 -c "
import json
m = json.load(open('.claude-plugin/marketplace.json'))
for p in m['plugins']:
    pj = json.load(open(p['source'] + '/.claude-plugin/plugin.json'))
    assert p['version'] == pj['version'], f'{p[\"name\"]}: marketplace={p[\"version\"]} plugin.json={pj[\"version\"]}'
    print(f'{p[\"name\"]}: {pj[\"version\"]} OK')
"
```

Expected: each plugin reports its version followed by `OK`.

- [ ] **Step 3: marketplace.json plugin_version unchanged**

```bash
python3 -c "
import json
m = json.load(open('.claude-plugin/marketplace.json'))
assert m['plugin_version'] == '0.39.0', f'plugin_version changed: {m[\"plugin_version\"]}'
print('plugin_version unchanged at 0.39.0')
"
```

Expected: `plugin_version unchanged at 0.39.0`.

- [ ] **Step 4: No ai-literacy-superpowers files changed**

```bash
git diff --name-only main..HEAD -- ai-literacy-superpowers/ | head -1
```

Expected: empty (no output). If anything appears, investigate — this PR should not touch ai-literacy-superpowers.

- [ ] **Step 5: TDAD and docs-reference parity checks should be no-ops**

The added files for this PR are scoped to `diagnostic-legibility/`,
`docs/plugins/diagnostic-legibility/`, `.claude-plugin/marketplace.json`,
and `README.md`. None matches the TDAD-scenario-check or
docs-reference-parity-check patterns (which gate on
`ai-literacy-superpowers/agents/`, `.../skills/`, `.../commands/`).
The checks will pass as no-ops; no local verification needed.

### Task 10: Push, PR, watch CI, merge

- [ ] **Step 1: Push the branch**

```bash
git push -u origin diagnostic-legibility-plugin
```

- [ ] **Step 2: Open the PR**

```bash
gh pr create --title "Diagnostic Legibility plugin — S1 scaffold (v0.1.0)" --body "$(cat <<'EOF'
## Summary

Slice S1 of the carpaccio slicing record at \`docs/superpowers/slices/diagnostic-legibility-plugin.md\` for issue #327. Ships a structurally complete, loadable \`diagnostic-legibility\` plugin at v0.1.0 with no functional agent code. Future slices land as:

- #331 — S2: Two-model agent (architectural + domain models with per-model self-challenge)
- #332 — S3: Cross-check mechanism (mutual model correction)
- #333 — S4: Surfacing interface (on-demand human legibility command)

Spec: \`docs/superpowers/specs/2026-05-26-diagnostic-legibility-plugin-scaffold-design.md\`
Plan: \`docs/superpowers/plans/2026-05-26-diagnostic-legibility-plugin-scaffold.md\`

## What's in the PR

- New plugin at \`diagnostic-legibility/\` with manifest, README, CHANGELOG, and empty placeholder directories (\`agents/\`, \`skills/\`, \`commands/\`, \`templates/\`).
- Docs-site landing page at \`docs/plugins/diagnostic-legibility/index.md\` and a Diataxis quadrant template.
- Marketplace registration: new entry in \`.claude-plugin/marketplace.json\` \`plugins[]\`; listing version bumped \`0.3.0\` → \`0.4.0\` (per CLAUDE.md, adding a plugins[] entry is a listing-contract change).
- Root README badge + marketplace table row.

The \`ai-literacy-superpowers\` plugin and the \`model-cards\` plugin are not touched. \`plugin_version\` in marketplace.json stays at \`0.39.0\`.

## Test plan

- [ ] Spec-first ordering: first commit is the spec.
- [ ] Per-plugin version sync passes: \`diagnostic-legibility\` plugin.json (0.1.0) matches its marketplace.json entry (0.1.0); \`ai-literacy-superpowers\` and \`model-cards\` unchanged.
- [ ] Marketplace \`plugin_version\` unchanged at 0.39.0.
- [ ] TDAD scenario presence check is a no-op (no component files added).
- [ ] Docs reference parity check is a no-op (no component files added).
- [ ] Markdown lint passes.
- [ ] Docs build check passes (landing page renders).

Tracks parent issue #327. Does **not** close it — the deferred slices S2/S3/S4 remain open; #327 will close when the final slice merges (currently planned to be S4 #333).
EOF
)"
```

- [ ] **Step 3: Watch CI**

```bash
gh pr checks $(gh pr view --json number --jq .number) --watch
```

Wait until all checks pass. If anything fails, investigate the failure log (`gh run view <run-id> --log-failed`), fix at the root cause, commit, and re-watch.

- [ ] **Step 4: Merge**

```bash
PR_NUM=$(gh pr view --json number --jq .number)
gh pr merge "$PR_NUM" --squash --delete-branch
```

- [ ] **Step 5: Verify issue #327 stays OPEN**

```bash
gh issue view 327 --json state --jq .state
```

Expected: `OPEN`. The parent issue stays open until the final slice (S4, #333) merges. The S1 PR description should NOT contain `Closes #327`.

- [ ] **Step 6: Sync marketplace cache**

```bash
bash ai-literacy-superpowers/scripts/sync-marketplace-cache.sh
CACHE="${HOME}/.claude/plugins/marketplaces/ai-literacy-superpowers"
git -C "${CACHE}" pull --ff-only origin main
```

Confirms the marketplace cache picks up the new plugin entry and the version bump.

---

## Out of scope (deferred to S2/S3/S4)

- Any agent, skill, or command implementation inside `diagnostic-legibility/`.
- TDAD scenarios for the plugin (no component files trigger the constraint).
- Diataxis quadrant pages (tutorials/, how-to/, reference/, explanation/) — created when their first page is written.
- A version-check workflow extension that also gates `diagnostic-legibility`'s plugin.json + CHANGELOG + README badge for three-way consistency (the current workflow only enforces three-way sync for `ai-literacy-superpowers`; the per-plugin sync inside `plugins[]` already gates marketplace ↔ plugin.json). If three-way sync becomes valuable for sister plugins, that's a separate cross-cutting PR.
- Docs-reference parity extension for sister plugins (the current check is hard-coded to `ai-literacy-superpowers/` paths; S2 may surface the need to extend it).
