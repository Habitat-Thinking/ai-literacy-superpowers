# Diagnostic Legibility plugin — S1 scaffold — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-26 |
| Status | Draft |
| Author | claude-opus-4-7[1m] (interactive session with russmiles) |
| Slice | S1 of 4 in carpaccio slicing record `docs/superpowers/slices/diagnostic-legibility-plugin.md` |
| Parent issue | #327 |
| Deferred sibling issues | #331 (S2), #332 (S3), #333 (S4) |
| Plugin version target | New plugin `diagnostic-legibility` at v0.1.0 |
| Marketplace version target | `0.3.0` → `0.4.0` (listing-contract change: new plugin entry in `plugins[]`) |
| PR ceremony | feature — full `/diaboli` (spec + code) and `/choice-cartograph` |
| Related work | Sister plugin `model-cards/` as structural anchor; spec `2026-05-26-carpaccio-cadence-governor-design.md` for the carpaccio agent that produced the slicing record |

---

## 1. Premise

Issue #327 commissions a new plugin — "Diagnostic Legibility" — and its
first agent. The carpaccio slicing record at
`docs/superpowers/slices/diagnostic-legibility-plugin.md` sliced the
task into four end-to-end-complete pieces; this spec covers slice **S1**
only: the plugin scaffold, with no functional agent logic.

The slicing decision was deliberate. The plugin-vs-nested structural
choice is a material decision the human will live with downstream, and
making it visible before any agent code is written keeps redirection
cheap. The slice ships a structurally complete, loadable plugin that
the rest of the marketplace can register and that future slices (S2
two-model agent, S3 cross-check, S4 surfacing) can build into without
restructuring.

## 2. Plugin identity and charter

### 2.1 Charter

The plugin's stated purpose, recorded in `plugin.json` and the README,
is broader than codebase legibility alone:

> Agents accountable for helping to maintain human understanding.

Codebase legibility (the first agent, scoped in S2–S4) is the
inaugural instance; the plugin is sized to grow into other domains
(governance legibility, decision legibility) under the same
discipline.

### 2.2 Identity fields

| Field | Value |
| --- | --- |
| Directory | `diagnostic-legibility/` (repo root; sibling of `model-cards/` and `ai-literacy-superpowers/`) |
| Plugin name | `diagnostic-legibility` |
| Initial version | `0.1.0` |
| Author | `Russ Miles` (matches sibling-plugin convention) |
| Description | "Agents accountable for helping to maintain human understanding. The first agent builds, self-challenges, and cross-checks two models of a codebase scope — architectural moving parts and domain concepts — and surfaces the mutually-corrected models on demand. Future agents will extend the discipline to other domains." |
| Keywords | `diagnostic-legibility`, `human-understanding`, `ai-accountability`, `legibility`, `two-model`, `cross-check`, `ai-literacy` |

## 3. Scaffold contents

All paths are relative to `diagnostic-legibility/` unless noted.

### 3.1 Plugin manifest

`/.claude-plugin/plugin.json` containing the identity fields from §2.2.
Mirrors the schema used by `model-cards/.claude-plugin/plugin.json`.

### 3.2 README

`/README.md` with:

- Opening paragraph stating the broader charter (§2.1).
- A "What it does" section that says the plugin is in scaffold state
  (v0.1.0) and lists the next deliverables as the three deferred
  issues with their numbers (#331 S2, #332 S3, #333 S4).
- An "Install" section with the standard `claude plugin install` and
  `copilot plugin install` commands (mirrors `model-cards/README.md`).
- A "Sister plugins" section pointing at `ai-literacy-superpowers/`
  and `model-cards/`.

The README explicitly names that the plugin is structurally complete
but functionally empty in v0.1.0 — readers should not expect commands
to work yet.

### 3.3 CHANGELOG

`/CHANGELOG.md` with a single entry:

```
## 0.1.0 — 2026-05-26

### Scaffold

Initial plugin scaffold. Establishes the Diagnostic Legibility plugin
as a first-class entry in the marketplace. Empty placeholder directories
for agents/, skills/, commands/, templates/. Charter recorded in
plugin.json and README. No functional agents or commands yet — the first
agent ships in #331 (S2).

Tracks parent issue #327.
```

### 3.4 Placeholder directories

The following directories are created with `.gitkeep` files. They
mirror `model-cards/` structure so future content has obvious homes:

- `/agents/.gitkeep`
- `/skills/.gitkeep`
- `/commands/.gitkeep`
- `/templates/.gitkeep`

No code, no skill markdown, no command markdown is added. The
directories exist as structural signals for future slices.

## 4. Docs site

### 4.1 Landing page

`docs/plugins/diagnostic-legibility/index.md` (new) with:

- Heading: "Diagnostic Legibility"
- Charter (one paragraph) — same broader framing as the README.
- "Status: v0.1.0 scaffold" — links to #331, #332, #333 as the next
  three deliverables.
- "Related plugins" section pointing at
  `docs/plugins/ai-literacy-superpowers/` and
  `docs/plugins/model-cards/`.

### 4.2 Diataxis template

`docs/plugins/diagnostic-legibility/_template.md` — copy of
`docs/plugins/ai-literacy-superpowers/_template.md` so future
quadrant pages have header guidance. Same convention as the sibling
plugins.

### 4.3 No quadrant folders yet

Per the project convention in `CLAUDE.md`: a quadrant folder
(`tutorials/`, `how-to/`, `reference/`, `explanation/`) is created
only when the plugin has at least one page in that quadrant. S1 has
no quadrant pages; quadrants will be added when S2–S4 ship content.

## 5. Marketplace registration

### 5.1 New plugin entry

Add an entry to `.claude-plugin/marketplace.json` `plugins[]` array:

```json
{
  "name": "diagnostic-legibility",
  "source": "./diagnostic-legibility",
  "description": "Agents accountable for helping to maintain human understanding. First agent (in development) builds, self-challenges, and cross-checks two models of a codebase scope.",
  "version": "0.1.0"
}
```

### 5.2 Marketplace listing version bump

`.claude-plugin/marketplace.json` top-level `version` bumps from
`0.3.0` to `0.4.0`. Per `CLAUDE.md`'s Marketplace Versioning section,
adding a plugin entry to `plugins[]` is a listing-contract change and
requires a marketplace minor bump.

The existing `plugin_version` field stays at `0.39.0` — this PR does
not change the `ai-literacy-superpowers` plugin.

### 5.3 Root README registration

Add a row for `diagnostic-legibility` to the marketplace table in the
root `README.md`, mirroring the existing rows for
`ai-literacy-superpowers` and `model-cards`. The row uses the same
phrasing as the marketplace.json description.

A new plugin badge in the README header (matching the style of the
existing `ai-literacy-superpowers` and `model-cards` version badges)
is added at v0.1.0.

## 6. User stories and acceptance scenarios

### 6.1 Story — the plugin is loadable as a marketplace entry

**As** a user of the marketplace
**I want** to discover the `diagnostic-legibility` plugin from the
marketplace listing
**So that** I can install it via `claude plugin install
diagnostic-legibility@ai-literacy-superpowers` without errors, even
though no functional commands exist yet.

```gherkin
Given a fresh checkout of the repository on the merged main
When the marketplace.json is parsed
Then `plugins[]` contains an entry with name "diagnostic-legibility"
And the entry's source path `./diagnostic-legibility` resolves to a
    directory containing `.claude-plugin/plugin.json`
And that plugin.json is valid JSON with version "0.1.0"
```

### 6.2 Story — the scaffold signals where future work lands

**As** a contributor or agent reading the plugin's directory
**I want** to see clear, empty placeholder directories
**So that** I know where future agents, skills, commands, and templates
should be written.

```gherkin
Given the diagnostic-legibility/ directory
When I list its contents
Then I see agents/, skills/, commands/, templates/ as directories
And each contains a .gitkeep file
And none of them contains any other file
```

### 6.3 Story — the README sets expectations honestly

**As** a user opening the plugin's README
**I want** to know that the plugin is in scaffold state
**So that** I do not expect any command to work yet and I can find the
issues that track the next deliverables.

```gherkin
Given the diagnostic-legibility/README.md on the merged main
When I read it
Then it states the charter in the opening paragraph
And it states that v0.1.0 is a scaffold with no functional agents
And it links to issues #331, #332, #333 as the next three deliverables
```

### 6.4 Story — the docs site lists the plugin

**As** a user of the docs site
**I want** to find a landing page for the plugin under
`docs/plugins/diagnostic-legibility/`
**So that** I can read the charter without leaving the docs site.

```gherkin
Given a build of the docs site on the merged main
When the site's nav is loaded
Then it includes a section for "Diagnostic Legibility"
And that section has an index.md landing page
And the landing page contains the charter and the next-deliverable
    issue links
```

### 6.5 Story — the marketplace version reflects the listing change

**As** an operator of the marketplace cache
**I want** the marketplace.json `version` to bump when a new plugin
entry is added
**So that** caches and CI checks know that the listing contract
changed.

```gherkin
Given the merged main
When I read .claude-plugin/marketplace.json
Then the top-level `version` is "0.4.0"
And the `plugin_version` field is unchanged from before this PR
And the `plugins[]` array has the new diagnostic-legibility entry
```

## 7. Files to add and modify

### 7.1 New files

| Path | Purpose |
| --- | --- |
| `diagnostic-legibility/.claude-plugin/plugin.json` | Plugin manifest. |
| `diagnostic-legibility/README.md` | Plugin README with charter and scaffold note. |
| `diagnostic-legibility/CHANGELOG.md` | v0.1.0 changelog. |
| `diagnostic-legibility/agents/.gitkeep` | Placeholder for future agent files. |
| `diagnostic-legibility/skills/.gitkeep` | Placeholder for future skill files. |
| `diagnostic-legibility/commands/.gitkeep` | Placeholder for future command files. |
| `diagnostic-legibility/templates/.gitkeep` | Placeholder for future template files. |
| `docs/plugins/diagnostic-legibility/index.md` | Docs site landing page. |
| `docs/plugins/diagnostic-legibility/_template.md` | Diataxis quadrant template (mirror of sibling plugin's). |

### 7.2 Modified files

| Path | Change |
| --- | --- |
| `.claude-plugin/marketplace.json` | Add `diagnostic-legibility` entry to `plugins[]`; bump top-level `version` `0.3.0` → `0.4.0`. |
| `README.md` (repo root) | Add `diagnostic-legibility` row to the marketplace table; add a version badge in the header block. |

## 8. Out of scope at v0.1.0

The slice's narrowing keeps the following deliberately out of scope.
They are listed here so the spec is honest about what is *not*
shipping:

- **Any agent, skill, or command implementation.** Reserved for
  S2 (#331), S3 (#332), and S4 (#333).
- **TDAD scenarios for the plugin.** No scaffold component triggers
  the TDAD-scenario-presence constraint because no
  `agents/<name>.agent.md`, `skills/<name>/SKILL.md`, or
  `commands/<name>.md` file is added in this PR. Scenarios will
  ship with their corresponding components in later slices.
- **Diataxis quadrant pages.** Per project convention, quadrant
  folders are scaffolded only when their first page exists.
- **Docs-reference parity entries.** The new constraint added in PR
  #330 (`docs-reference-parity-check`) gates the appearance of
  reference-page entries against the addition of plugin component
  files. S1 adds no component files, so no reference-page entries
  are required.

## 9. Compatibility and rollout

- **Backwards compatibility:** existing plugins (`ai-literacy-superpowers`,
  `model-cards`) are unaffected. No file inside their directories changes.
- **Cache behaviour:** `sync-marketplace-cache.sh` fires when
  `.claude-plugin/marketplace.json` differs from `origin/main` —
  this PR triggers it (both `version` and `plugins[]` change).
  `sync-to-global-cache.sh` runs on the `Stop` hook and would
  rsync the new plugin's content into the versioned slot at
  `~/.claude/plugins/cache/ai-literacy-superpowers/diagnostic-legibility/`
  on the next session boundary.
- **CI gates:** all existing gates apply. Spec-first check is
  satisfied by this spec being the first commit on the branch.
  Version-consistency check applies only to
  `ai-literacy-superpowers/.claude-plugin/plugin.json` and is
  unaffected. TDAD scenario presence check is a no-op (no
  component files added). Docs-reference parity check is a no-op
  (no component files added).

## 10. Open questions resolved during brainstorming

| Question | Decision |
| --- | --- |
| Standalone plugin vs nested inside ai-literacy-superpowers | Standalone — carpaccio slicing record S1 decision focus. |
| Charter scope | Broader: "agents accountable for helping to maintain human understanding"; codebase legibility is the first instance. |
| Scaffold extent | Empty placeholder directories with `.gitkeep` (mirrors `model-cards/`'s structure); no stub agents. |
| Docs site shape | Landing page + Diataxis template only; quadrant folders deferred until they have content. |
| Marketplace version bump | `0.3.0` → `0.4.0` (listing-contract change per CLAUDE.md). |

## 11. References

- Issue #327 — parent commission.
- Carpaccio slicing record: `docs/superpowers/slices/diagnostic-legibility-plugin.md` — 4-slice decomposition with this spec covering S1.
- Sister plugin: `model-cards/` — structural anchor.
- Spec `2026-05-26-carpaccio-cadence-governor-design.md` — the carpaccio agent that produced the slicing record.
- `CLAUDE.md` — Marketplace Versioning section; Docs Site Review section.
