# Docs site Diataxis reorg — Design Spec

| Field | Value |
| --- | --- |
| Date | 2026-05-07 |
| Status | Draft — pending user review |
| Author | claude-opus-4-7[1m] (interactive session) |
| Plugin version target | v0.34.0 (minor bump — Phase 1 only; Phase 2 is docs-only and outside the plugin directory) |
| PR ceremony | `chore`-labelled both PRs — diaboli and choice-cartograph deliberately skipped per AGENTS.md STYLE on reflection-driven amendments and project-owner judgement |
| Related work | PR #258 (docs site consistency pass), PR #259 (docs propagation constraint added) |

---

## 1. Summary

The docs site under `docs/plugins/<plugin-name>/` is currently a flat list of markdown files — 81 in `ai-literacy-superpowers/`, 8 in `model-cards/` — with the four Diataxis quadrants represented only as logical sections inside each plugin's `index.md`. This spec reorganises both plugins' docs into Diataxis-conforming folder structure: each plugin gets `tutorials/`, `how-to/`, `reference/`, and `explanation/` sub-folders, with friendly nav labels rendered via `nav_label` frontmatter on the just-the-docs theme.

The migration ships in two phases. Phase 1 reorganises the smaller `model-cards` plugin (8 pages) and establishes the convention machinery: the new GC rule for sunset-dated redirects, the link-rewriting script, the convention text in `CLAUDE.md` and `templates/CLAUDE.md`. Phase 2 applies the proven pattern to the 81-page `ai-literacy-superpowers` flagship.

---

## 2. Why

Three forces drive this reorg:

1. **Cognitive load of a flat list of 81 pages.** The plugin's `index.md` already groups pages by Diataxis section, but the *physical* organisation does not match — a contributor browsing the source sees a flat directory and has to consult the index to understand where a page belongs. The flat structure scales poorly: 81 pages today; more next quarter.

2. **The site theme already supports nesting natively.** `_config.yml` uses `just-the-docs`, which renders nested navigation via `parent:` / `grand_parent:` / `has_children:` frontmatter. The infrastructure is there; only the content layout has not caught up.

3. **The Diataxis intent was already encoded once and decayed.** The plugin's existing `index.md` carries `redirect_from: [/tutorials/, /how-to/, /reference/, /explanation/]` — someone considered Diataxis URLs at some point. Those redirects currently go nowhere because no such folders exist. This reorg makes the encoded intent real.

A fourth, weaker force: this is a maintenance hygiene action that recently surfaced via two related PRs (#258 docs site consistency pass; #259 docs propagation constraint). The current flat structure makes "find every reference to the old command" harder than it needs to be — every grep happens against an undifferentiated pool of pages. Quadrant folders narrow the search surface and make the docs propagation constraint easier to satisfy in future PRs.

---

## 3. Target structure

Each plugin gets the same shape:

```text
docs/plugins/<plugin-name>/
  index.md                          # Plugin landing page
  _template.md                      # Stays at root (template, not content)
  tutorials/
    index.md                        # nav_label: "Getting Started"
    <slug>.md
  how-to/
    index.md                        # nav_label: "How-to Guides"
    <slug>.md
  reference/
    index.md                        # nav_label: "Reference"
    <slug>.md
  explanation/
    index.md                        # nav_label: "Concepts"
    <slug>.md
```

URLs resolve to `/plugins/<plugin>/<quadrant>/<slug>` (Diataxis-pure paths). Sidebar nav renders friendly labels via `nav_label` frontmatter. `_template.md` stays at the plugin root so it is discoverable to anyone adding any page-type, with header guidance for each quadrant.

### Plugin landing page (`index.md`)

```markdown
---
title: <plugin-name>
parent: Plugins
has_children: true
nav_order: <n>
---

# <plugin-name>

[1-paragraph plugin description]

## Where to start

| If you want to… | Go to |
| ---             | ---   |
| Learn the framework end-to-end | [Getting Started](tutorials/) |
| Do a specific task | [How-to Guides](how-to/) |
| Look up a command, agent, or schema | [Reference](reference/) |
| Understand why things work this way | [Concepts](explanation/) |
```

The current per-plugin `index.md`'s page listings move into the four quadrant index files. The plugin index becomes a brief overview + four cards, not a full listing.

The existing `redirect_from: [/tutorials/, ...]` block on the current plugin index is dropped — those URLs become real folders, and a redirect that points to itself is meaningless.

### Quadrant landing pages (`<quadrant>/index.md`)

```markdown
---
title: How-to Guides
nav_label: How-to Guides
parent: <plugin-name>
has_children: true
nav_order: 2
---

# How-to Guides

Task-oriented guides for [plugin-name].

[List of pages in this quadrant — auto-rendered by just-the-docs via has_children, plus an introductory paragraph]
```

---

## 4. Naming convention

URLs use Diataxis-pure folder names: `tutorials/`, `how-to/`, `reference/`, `explanation/`. Sidebar nav uses friendly labels: "Getting Started", "How-to Guides", "Reference", "Concepts". The mapping is fixed across all plugins:

| Folder        | Nav label       |
| ---           | ---             |
| `tutorials/`  | Getting Started |
| `how-to/`     | How-to Guides   |
| `reference/`  | Reference       |
| `explanation/`| Concepts        |

The hybrid (URLs Diataxis-pure, nav labels friendly) was chosen because it preserves the framework signal in URLs (long-lived) while giving non-Diataxis-aware readers a friendlier sidebar.

---

## 5. Page categorisation methodology

The verb-form heuristic, applied per page:

| Quadrant | Verb form | Reader's question |
| ---      | ---       | --- |
| `tutorials/` | "Let's learn X end-to-end" | "I'm new — show me the whole thing" |
| `how-to/` | "Do this specific task" | "I know what I want to accomplish" |
| `reference/` | "Look up the shape of X" | "What are the fields?" |
| `explanation/` | "Understand the idea behind X" | "Why does this exist?" |

**Tie-breaker for ambiguous pages**: when a page reads as 60% how-to + 40% explanation, prefer how-to (the place readers click looking to *do* something). When a page reads 60% explanation + 40% reference, prefer explanation (reference is for things with a discrete schema; explanation is for things with a discrete *idea*).

The actual file-by-file categorisation is built during the implementation plan as a `move-map.tsv` artefact, not enumerated in this spec. The spec declares the methodology; the plan applies it.

---

## 6. Redirect strategy

Every moved page gets `redirect_from` frontmatter for both its old flat URL and a `.html` variant (Jekyll-rendered older URLs). A sunset marker is added as an HTML comment so the file frontmatter stays clean and a `grep` can find every expired redirect.

```markdown
---
title: Sync the harness
parent: How-to Guides
grand_parent: ai-literacy-superpowers
redirect_from:
  - /plugins/ai-literacy-superpowers/sync-harness/
  - /plugins/ai-literacy-superpowers/sync-harness.html
# redirect-sunset: 2027-05-07
---
```

Sunset duration: **12 months**. Long enough that search engines have re-crawled and most bookmarks have decayed; short enough that the docs do not accumulate redirect cruft indefinitely.

### New GC rule — Redirect sunset

Lands in `HARNESS.md` (root) and `templates/HARNESS.md` (shipped) in Phase 1:

```markdown
### Redirect sunset

- **What it checks**: Whether any markdown file in `docs/plugins/` contains
  a `<!-- redirect-sunset: YYYY-MM-DD -->` marker with a date in the past
- **Frequency**: monthly
- **Enforcement**: deterministic
- **Tool**: `scripts/check-redirect-sunsets.sh`
- **Auto-fix**: false (curator decides whether to extend or remove)
```

`auto-fix: false` because removing a redirect is a small irreversible URL change — worth a human glance.

The rule will have findings around 2027-05-07 when the first batch of redirects sunset. Once those are processed, the rule sits dormant until the next docs migration. Worth keeping dormant rather than retiring — it is a useful fitness function for any future docs reshape.

---

## 7. Internal link migration

Every cross-link inside the docs (and from `README.md`, `ONBOARDING.md`, `CHANGELOG.md`, the plugin source files, and the convention files in `.cursor/`, `.github/`, `.windsurf/`) currently uses the flat path. After the move, those become quadrant-prefixed paths.

### Mechanism

1. **Build the move-map** as a deterministic artefact during the implementation plan: `<old-path> → <new-path>`, one row per moved page, committed as `scripts/migrations/move-map-<plugin>.tsv`.

2. **Apply the rewrite via a single-purpose script**, `scripts/migrations/rewrite-docs-links.sh`. The script reads a move-map TSV and rewrites every markdown link in the repo whose left-hand-side matches an entry in the map. The script is committed in Phase 1 and reused in Phase 2.

3. **Verification grep**: after the rewrite runs, search the entire repo for any remaining links to flat paths inside the migrated plugin's docs. Any match is a missed rewrite. This grep is what makes a script-driven rewrite safer than per-link manual editing.

### Scope boundary

External links pointing into the docs site (from blog posts, READMEs in other repos, social media) are not rewritten. That is what `redirect_from` is for. Plugin-source files (skills, commands, agents) that link into `docs/` for explanatory deep-dives are rewritten — the script targets every `.md` file in the repo, not just `docs/`.

---

## 8. Convention text and constraint updates

Three text-content updates land in **Phase 1** so the convention is canonical when the flagship migrates.

### CLAUDE.md (root) and templates/CLAUDE.md (shipped)

The "Docs Site Review" section currently says:

> For each plugin, content is grouped using the Diataxis framework as sections within the plugin's `index.md` (page locations are flat within the plugin directory)

Becomes:

> For each plugin, content is organised into Diataxis quadrant folders. Pages live at `docs/plugins/<plugin-name>/<quadrant>/<slug>.md` where `<quadrant>` is one of `tutorials/`, `how-to/`, `reference/`, or `explanation/`. The plugin's root `index.md` is a landing page that links to each quadrant; quadrants render with friendly nav labels ("Getting Started", "How-to Guides", "Reference", "Concepts") via just-the-docs `nav_label` frontmatter. The `_template.md` file stays at the plugin root with header guidance for each quadrant.

### HARNESS.md constraint scopes — no edit needed

Two existing constraints reference docs paths:

- `Docs site kept current` — Rule mentions "the corresponding docs pages in `docs/`"
- `Docs propagation when shipping new commands` — Rule mentions "every reference in `docs/plugins/<plugin>/`"

Both still hold under the new structure. `docs/plugins/<plugin>/` still exists, just with sub-folders. The harness-enforcer's grep already recurses; the constraint behaviour is unchanged. **No HARNESS.md text edits required for these two constraints.**

### New constraint added

Only the **Redirect sunset** GC rule (per § 6). No new PR-time constraints.

---

## 9. Two-phase plan

### Phase 1 — model-cards as reference implementation (chore PR)

Files inside the plugin directory change → minor version bump (`0.33.0` → `0.34.0`):

- `docs/plugins/model-cards/` — move 8 files into the 4 quadrant folders, add `redirect_from` + sunset markers
- `ai-literacy-superpowers/templates/CLAUDE.md` — update "Docs Site Review" section
- `ai-literacy-superpowers/templates/HARNESS.md` — add **Redirect sunset** GC rule
- `HARNESS.md` (root) — add **Redirect sunset** GC rule
- `CLAUDE.md` (root) — update "Docs Site Review" section
- `scripts/check-redirect-sunsets.sh` — new (the GC rule's tool)
- `scripts/migrations/rewrite-docs-links.sh` — new
- `scripts/migrations/move-map-model-cards.tsv` — new
- `CHANGELOG.md`, `plugin.json`, `marketplace.json`, README badge — bumped together
- After merge: run `/harness-sync` so convention surfaces and `ONBOARDING.md` absorb the new GC rule

### Phase 2 — ai-literacy-superpowers migration (chore PR)

Touches *only* `docs/plugins/ai-literacy-superpowers/` and `scripts/migrations/`. **No version bump** — outside the plugin directory:

- `docs/plugins/ai-literacy-superpowers/` — move 81 files into the 4 quadrants, add redirects + sunsets
- `scripts/migrations/move-map-ai-literacy-superpowers.tsv` — new
- Rewrite script applied across the repo to update internal cross-links
- CHANGELOG entry under existing `0.34.0` heading
- PR description links back to this spec for traceability

### Spec lifecycle

This spec lands as the first commit on the Phase 1 branch (`chore/docs-diataxis-reorg-model-cards`). From that point both PRs reference it. After Phase 2 merges, the spec joins the existing `docs/superpowers/specs/` corpus as historical record.

### Spec-first / adjudication exemption

Both PRs use the `chore` label. Per CLAUDE.md's "Spec-First Exemptions" table and HARNESS.md's `PRs have adjudicated objections` and `PRs have adjudicated choice stories` constraint texts, the chore label clears all three relevant gates. Per AGENTS.md STYLE on reflection-driven amendments, the chore-label-for-behavioural-change path is acceptable when the implementation is conservatively bounded (each phase is its own PR), the version bump is honest about the change, and the work has been brainstormed and specified. All four conditions hold here.

---

## 10. Verification

Each phase verifies before its PR opens:

1. **Build the site locally** (or via the Pages workflow on the branch) — confirm just-the-docs renders the nested nav correctly with friendly labels, no orphaned pages, no broken cross-links.
2. **Run the rewrite-script verification grep** — no remaining links to flat paths inside the migrated plugin's docs.
3. **Spot-check 3-5 redirected URLs** — visit the old flat URL on the deployed branch preview, confirm `redirect_from` resolves to the new location.
4. **Run the new redirect-sunset GC rule** — confirm no entries are flagged on day 1 (sunsets are 12 months in the future).
5. **Run `/harness-sync` after Phase 1 merges** — confirm the synced convention files and `ONBOARDING.md` absorb the new GC rule cleanly.

---

## 11. Out of scope

Explicitly deferred so the spec does not quietly grow into them:

- **Sister-plugin docs sync command.** No `/docs-sync` analogue to `/convention-sync` is proposed. If a third plugin lands later, its docs follow this convention by example, not by automation. Worth revisiting only if a third plugin arrives and manual application proves error-prone.
- **Per-quadrant landing-page enrichment.** Each quadrant's `index.md` will be a thin "here are the pages in this quadrant" listing on Day 1. Richer per-quadrant onboarding is a future-pass concern.
- **Diataxis structure for `docs/superpowers/`.** That subtree (`specs/`, `plans/`, `objections/`, `stories/`) is workflow records, not user-facing docs. Stays flat with its existing structure.
- **Markdown lint rule additions for the new structure.** No new MD rules added. Existing markdownlint config applies unchanged.
- **Versioned docs / multi-version site.** Single-version site stays single-version. No `/v0.33/` or `/latest/` segment.
- **Search index tuning.** just-the-docs search picks up new pages automatically. No custom search config changes.
- **Auto-categorisation script.** No script that reads existing pages and proposes which quadrant each belongs to. The categorisation is a human judgment call applied page-by-page in the implementation plan.

---

## 12. Risks

- **Mass link rewrite missing edge cases.** Mitigation: the verification grep in § 10 step 2 catches any flat-path link the script missed. The grep is the load-bearing safety net.
- **External bookmarks decaying faster than the 12-month sunset.** Mitigation: `redirect_from` survives until the sunset GC rule flags expiry; the curator can extend the sunset rather than remove it if external traffic is still meaningful.
- **just-the-docs nested nav rendering surprises.** Mitigation: Phase 1 (model-cards, 8 pages) is the reference implementation. Any rendering issue is found and fixed there before the 81-page Phase 2 migration.
- **Page miscategorisation.** Mitigation: the verb-form heuristic and tie-breaker rule (§ 5) make calls reproducible. Genuine ambiguous-case disagreements can be resolved by moving the page later — `redirect_from` makes such moves cheap.
