# Docs Diataxis reorg — Phase 1 (model-cards) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganise `docs/plugins/model-cards/` from a flat layout into Diataxis quadrant folders (`tutorials/`, `how-to/`, `reference/`, `explanation/`) as the reference implementation for the project-wide convention. Ship the convention machinery — Redirect sunset GC rule, sunset checker script, link-rewriting script, updated CLAUDE.md text — alongside.

**Architecture:** model-cards has 7 movable pages plus an `index.md`. Pages categorise into how-to (2), reference (4), and explanation (1) — no tutorials yet, so the `tutorials/` folder is **not** created in Phase 1. Each moved page gets `redirect_from` covering its old URL forms plus a 12-month sunset marker. The link-rewriting script applies a move-map TSV to every `.md` file in the repo. The Redirect sunset GC rule fires monthly and reports any markers whose date has passed.

**Tech Stack:** Bash 4+ with `set -euo pipefail` and ShellCheck compliance, Jekyll + just-the-docs theme, jekyll-redirect-from plugin (already enabled in `_config.yml`), markdownlint via `npx markdownlint-cli2`.

---

## File Structure

**New files (created in this plan):**

| Path | Responsibility |
| --- | --- |
| `scripts/check-redirect-sunsets.sh` | GC rule tool — scans `docs/plugins/` for `<!-- redirect-sunset: YYYY-MM-DD -->` markers with dates in the past, reports findings on stdout, exits non-zero when findings exist. |
| `scripts/check-redirect-sunsets.test.sh` | Functional test — sets up fixtures (markdown files with past, future, and missing sunset markers), runs the script, asserts the output. |
| `scripts/migrations/rewrite-docs-links.sh` | One-shot tool — reads a move-map TSV from `$1`, rewrites every markdown link in the repo whose left-hand-side matches an entry. Idempotent. |
| `scripts/migrations/rewrite-docs-links.test.sh` | Functional test — fixture move-map + fixture markdown files with old paths, runs the script, asserts the rewrite is correct and idempotent. |
| `scripts/migrations/move-map-model-cards.tsv` | Move map — 7 rows, tab-separated, `<old-path>\t<new-path>`. |
| `docs/plugins/model-cards/how-to/index.md` | Quadrant landing page for "How-to Guides". |
| `docs/plugins/model-cards/reference/index.md` | Quadrant landing page for "Reference". |
| `docs/plugins/model-cards/explanation/index.md` | Quadrant landing page for "Concepts". |
| `docs/plugins/model-cards/how-to/research-a-model-card.md` | Moved from `docs/plugins/model-cards/research-a-model-card.md`. |
| `docs/plugins/model-cards/how-to/seed-your-library.md` | Moved from `docs/plugins/model-cards/seed-your-library.md`. |
| `docs/plugins/model-cards/reference/agents.md` | Moved from `docs/plugins/model-cards/agents.md`. |
| `docs/plugins/model-cards/reference/card-template.md` | Moved from `docs/plugins/model-cards/card-template.md`. |
| `docs/plugins/model-cards/reference/commands.md` | Moved from `docs/plugins/model-cards/commands.md`. |
| `docs/plugins/model-cards/reference/skills.md` | Moved from `docs/plugins/model-cards/skills.md`. |
| `docs/plugins/model-cards/explanation/mitchell-extended-cards.md` | Moved from `docs/plugins/model-cards/mitchell-extended-cards.md`. |

**Modified files (in this plan):**

| Path | Why |
| --- | --- |
| `HARNESS.md` (root) | Add Redirect sunset GC rule. |
| `ai-literacy-superpowers/templates/HARNESS.md` | Add Redirect sunset GC rule (shipped template). |
| `CLAUDE.md` (root) | Update "Docs Site Review" section to reflect quadrant folders. |
| `ai-literacy-superpowers/templates/CLAUDE.md` | Update "Docs Site Review" section (shipped template). |
| `docs/plugins/model-cards/index.md` | Rewrite as landing page with 4 cards (3 quadrants + tutorials-coming-soon line). |
| `ai-literacy-superpowers/.claude-plugin/plugin.json` | Version `0.33.0` → `0.34.0`. |
| `.claude-plugin/marketplace.json` | `plugin_version` `0.33.0` → `0.34.0`. |
| `README.md` | Plugin badge `v0.33.0` → `v0.34.0`. |
| `CHANGELOG.md` | New top heading `## 0.34.0 — 2026-05-07` with theme + bullets. |
| Repo-wide `.md` files | Rewrite links to moved model-cards docs (driven by `rewrite-docs-links.sh`). |

**Categorisation of model-cards pages** (applied here, not the spec):

| Old path | Quadrant | Reason |
| --- | --- | --- |
| `agents.md` | reference | Lists agents and their roles — a "look up the shape of X" page. |
| `card-template.md` | reference | Documents the model-card template structure. |
| `commands.md` | reference | Lists the plugin's commands. |
| `skills.md` | reference | Lists the plugin's skills. |
| `mitchell-extended-cards.md` | explanation | Conceptual background — why the cards are shaped the way they are. |
| `research-a-model-card.md` | how-to | Task-oriented — "do this thing". |
| `seed-your-library.md` | how-to | Task-oriented — "do this thing". |

`tutorials/` is **not** created — model-cards has no end-to-end "learn the plugin from scratch" page yet. The plugin landing page mentions tutorials are coming soon.

---

## Task 1: Implement and test `check-redirect-sunsets.sh`

**Files:**
- Create: `scripts/check-redirect-sunsets.test.sh`
- Create: `scripts/check-redirect-sunsets.sh`

- [ ] **Step 1: Create the scripts/ directory and write the failing test**

```bash
mkdir -p scripts
```

Create `scripts/check-redirect-sunsets.test.sh`:

```bash
#!/usr/bin/env bash
#
# Functional test for check-redirect-sunsets.sh.
# Sets up fixture markdown files with past, future, and missing sunset
# markers; runs the script against the fixture directory; asserts the
# output is correct.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/check-redirect-sunsets.sh"
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

# Fixture: a page with a past sunset marker
mkdir -p "$FIXTURE/docs/plugins/test-plugin/how-to"
cat >"$FIXTURE/docs/plugins/test-plugin/how-to/expired.md" <<'EOF'
---
title: Expired
redirect_from:
  - /old-path/
# redirect-sunset: 2020-01-01
---

# Expired
EOF

# Fixture: a page with a future sunset marker
cat >"$FIXTURE/docs/plugins/test-plugin/how-to/future.md" <<'EOF'
---
title: Future
redirect_from:
  - /old-path/
# redirect-sunset: 2099-01-01
---

# Future
EOF

# Fixture: a page with no sunset marker
cat >"$FIXTURE/docs/plugins/test-plugin/how-to/none.md" <<'EOF'
---
title: None
---

# None
EOF

# Run the script against the fixture
output=$("$SCRIPT" "$FIXTURE/docs/plugins" 2>&1) && rc=$? || rc=$?

# Assert: exit code is non-zero (findings exist)
if [[ "$rc" -eq 0 ]]; then
  echo "FAIL: expected non-zero exit code, got $rc"
  echo "Output: $output"
  exit 1
fi

# Assert: output mentions expired.md
if ! grep -q "expired.md" <<<"$output"; then
  echo "FAIL: expected 'expired.md' in output"
  echo "Output: $output"
  exit 1
fi

# Assert: output does NOT mention future.md
if grep -q "future.md" <<<"$output"; then
  echo "FAIL: future.md should not be flagged"
  echo "Output: $output"
  exit 1
fi

# Assert: output does NOT mention none.md
if grep -q "none.md" <<<"$output"; then
  echo "FAIL: none.md should not be flagged"
  echo "Output: $output"
  exit 1
fi

echo "PASS: check-redirect-sunsets.sh"
```

Make it executable:

```bash
chmod +x scripts/check-redirect-sunsets.test.sh
```

- [ ] **Step 2: Run the test to verify it fails (script does not exist yet)**

Run: `bash scripts/check-redirect-sunsets.test.sh`
Expected: FAIL — `scripts/check-redirect-sunsets.sh` not found (or "No such file or directory").

- [ ] **Step 3: Implement the script**

Create `scripts/check-redirect-sunsets.sh`:

```bash
#!/usr/bin/env bash
#
# check-redirect-sunsets.sh — implements the Redirect sunset GC rule.
#
# Scans the given directory tree for markdown files containing a
# <!-- redirect-sunset: YYYY-MM-DD --> marker whose date is in the past.
# Reports each finding on stdout. Exits 0 if no findings, 1 if findings
# exist, 2 on usage or environment error.
#
# Usage: check-redirect-sunsets.sh [directory]
# Defaults to docs/plugins when called from the repo root.

set -euo pipefail

target="${1:-docs/plugins}"

if [[ ! -d "$target" ]]; then
  echo "Error: directory not found: $target" >&2
  exit 2
fi

today="$(date +%Y-%m-%d)"
findings=0

while IFS= read -r -d '' file; do
  # Extract the date from the marker line. The marker format is exactly
  # `<!-- redirect-sunset: YYYY-MM-DD -->` (HTML comment, hyphen-separated date).
  marker_date="$(grep -oE '<!-- redirect-sunset: [0-9]{4}-[0-9]{2}-[0-9]{2} -->' "$file" \
    | head -1 \
    | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"

  if [[ -z "$marker_date" ]]; then
    continue
  fi

  if [[ "$marker_date" < "$today" ]]; then
    echo "$file: redirect sunset $marker_date has passed (today: $today)"
    findings=$((findings + 1))
  fi
done < <(find "$target" -type f -name "*.md" -print0)

if [[ "$findings" -gt 0 ]]; then
  echo "Total findings: $findings"
  exit 1
fi

exit 0
```

Make it executable:

```bash
chmod +x scripts/check-redirect-sunsets.sh
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bash scripts/check-redirect-sunsets.test.sh`
Expected: `PASS: check-redirect-sunsets.sh`

- [ ] **Step 5: Verify ShellCheck and bash -n compliance**

Run: `shellcheck scripts/check-redirect-sunsets.sh scripts/check-redirect-sunsets.test.sh`
Expected: no output (no findings).

Run: `bash -n scripts/check-redirect-sunsets.sh && bash -n scripts/check-redirect-sunsets.test.sh`
Expected: no output, exit code 0.

- [ ] **Step 6: Commit**

```bash
git add scripts/check-redirect-sunsets.sh scripts/check-redirect-sunsets.test.sh
git commit -m "feat(scripts): add check-redirect-sunsets.sh GC tool

Implements the Redirect sunset GC rule's check tool. Scans a directory
tree for markdown files containing a <!-- redirect-sunset: YYYY-MM-DD -->
marker with a date in the past. Reports findings, exits non-zero when
any are found.

Includes a functional test (check-redirect-sunsets.test.sh) covering
past/future/missing-marker fixtures."
```

---

## Task 2: Implement and test `rewrite-docs-links.sh`

**Files:**
- Create: `scripts/migrations/rewrite-docs-links.test.sh`
- Create: `scripts/migrations/rewrite-docs-links.sh`

- [ ] **Step 1: Create the scripts/migrations/ directory and write the failing test**

```bash
mkdir -p scripts/migrations
```

Create `scripts/migrations/rewrite-docs-links.test.sh`:

```bash
#!/usr/bin/env bash
#
# Functional test for rewrite-docs-links.sh.
# Sets up a fixture move-map and a tree of markdown files containing
# both old-path and unrelated links; runs the script; asserts the
# old-path links are rewritten and unrelated links are untouched.
# Also asserts idempotency: running the script twice produces the same
# output as running it once.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/rewrite-docs-links.sh"
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

# Fixture move-map: TSV with two rows
cat >"$FIXTURE/move-map.tsv" <<'EOF'
docs/plugins/test-plugin/research-a-model-card.md	docs/plugins/test-plugin/how-to/research-a-model-card.md
docs/plugins/test-plugin/agents.md	docs/plugins/test-plugin/reference/agents.md
EOF

# Fixture markdown files: a mix of links to be rewritten and untouched
mkdir -p "$FIXTURE/docs/plugins/test-plugin"
cat >"$FIXTURE/sample.md" <<'EOF'
See [Research a Model Card](docs/plugins/test-plugin/research-a-model-card.md)
and [Agents](docs/plugins/test-plugin/agents.md). Unrelated:
[README](README.md) and [Other](docs/plugins/other-plugin/agents.md).
EOF

cat >"$FIXTURE/no-matches.md" <<'EOF'
Just a [README](README.md) link, nothing to rewrite.
EOF

# Run the script against the fixture
cd "$FIXTURE"
"$SCRIPT" move-map.tsv

# Assert: links in sample.md are rewritten
if ! grep -qF "docs/plugins/test-plugin/how-to/research-a-model-card.md" sample.md; then
  echo "FAIL: research-a-model-card.md link was not rewritten in sample.md"
  cat sample.md
  exit 1
fi
if ! grep -qF "docs/plugins/test-plugin/reference/agents.md" sample.md; then
  echo "FAIL: agents.md link was not rewritten in sample.md"
  cat sample.md
  exit 1
fi

# Assert: unrelated links in sample.md are untouched
if ! grep -qF "[README](README.md)" sample.md; then
  echo "FAIL: README link was clobbered in sample.md"
  exit 1
fi
if ! grep -qF "docs/plugins/other-plugin/agents.md" sample.md; then
  echo "FAIL: other-plugin/agents.md link was clobbered in sample.md"
  exit 1
fi

# Assert: no-matches.md is unchanged
if ! grep -qF "[README](README.md) link" no-matches.md; then
  echo "FAIL: no-matches.md was modified unexpectedly"
  exit 1
fi

# Assert: idempotency — running again produces no change
md5_before=$(md5sum sample.md no-matches.md | sort)
"$SCRIPT" move-map.tsv
md5_after=$(md5sum sample.md no-matches.md | sort)

if [[ "$md5_before" != "$md5_after" ]]; then
  echo "FAIL: script is not idempotent"
  echo "Before: $md5_before"
  echo "After:  $md5_after"
  exit 1
fi

echo "PASS: rewrite-docs-links.sh"
```

Make it executable:

```bash
chmod +x scripts/migrations/rewrite-docs-links.test.sh
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash scripts/migrations/rewrite-docs-links.test.sh`
Expected: FAIL — `scripts/migrations/rewrite-docs-links.sh` not found.

- [ ] **Step 3: Implement the script**

Create `scripts/migrations/rewrite-docs-links.sh`:

```bash
#!/usr/bin/env bash
#
# rewrite-docs-links.sh — one-shot link rewriter for docs reorgs.
#
# Reads a move-map TSV from $1 with `<old-path>\t<new-path>` rows.
# Rewrites every markdown link in the repo whose left-hand-side matches
# an old-path. Idempotent — running the script twice with the same
# move-map produces the same output as running it once.
#
# Usage: rewrite-docs-links.sh <move-map.tsv>
#
# Skips: .git/, node_modules/, observability/archive/, reflections/archive/,
# docs/superpowers/specs/ (specs may quote old paths in their "before"
# examples), docs/superpowers/objections/ and stories/ (historical),
# CHANGELOG.md (historical PR descriptions).

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <move-map.tsv>" >&2
  exit 2
fi

map="$1"

if [[ ! -f "$map" ]]; then
  echo "Error: move-map not found: $map" >&2
  exit 2
fi

# Build a list of every markdown file in the repo that we should rewrite.
mapfile -t targets < <(find . -type f -name "*.md" \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./observability/archive/*" \
  -not -path "./reflections/archive/*" \
  -not -path "./docs/superpowers/specs/*" \
  -not -path "./docs/superpowers/objections/*" \
  -not -path "./docs/superpowers/stories/*" \
  -not -path "./docs/superpowers/plans/*" \
  -not -path "./CHANGELOG.md" \
  -not -path "./model-cards/CHANGELOG.md")

# Read the move-map and apply each rewrite to every target file.
while IFS=$'\t' read -r old new; do
  if [[ -z "$old" || -z "$new" ]]; then
    continue
  fi

  # Escape for sed: the paths contain forward slashes and dots, so we
  # use | as the sed delimiter. Dots in the source are not regex-active
  # in fixed-string context, so plain substitution is safe.
  for file in "${targets[@]}"; do
    if grep -qF "$old" "$file"; then
      # Use a temp file to keep the operation atomic per file.
      sed "s|$old|$new|g" "$file" >"$file.tmp" && mv "$file.tmp" "$file"
    fi
  done
done <"$map"
```

Make it executable:

```bash
chmod +x scripts/migrations/rewrite-docs-links.sh
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bash scripts/migrations/rewrite-docs-links.test.sh`
Expected: `PASS: rewrite-docs-links.sh`

- [ ] **Step 5: ShellCheck and bash -n**

Run: `shellcheck scripts/migrations/rewrite-docs-links.sh scripts/migrations/rewrite-docs-links.test.sh`
Expected: no output.

Run: `bash -n scripts/migrations/rewrite-docs-links.sh && bash -n scripts/migrations/rewrite-docs-links.test.sh`
Expected: no output, exit code 0.

- [ ] **Step 6: Commit**

```bash
git add scripts/migrations/rewrite-docs-links.sh scripts/migrations/rewrite-docs-links.test.sh
git commit -m "feat(scripts): add rewrite-docs-links.sh migration tool

One-shot link rewriter for docs reorgs. Reads a move-map TSV with
<old-path>\\t<new-path> rows; rewrites every markdown link in the repo
whose left-hand-side matches an old-path. Idempotent.

Skips historical/archived directories (specs, objections, stories,
plans, archive trees, CHANGELOGs) so those preserve their old paths
as quoted text. Includes a functional test covering rewrite, untouched
unrelated links, and idempotency."
```

---

## Task 3: Add the Redirect sunset GC rule

**Files:**
- Modify: `HARNESS.md` (root)
- Modify: `ai-literacy-superpowers/templates/HARNESS.md`

- [ ] **Step 1: Add the rule to HARNESS.md (root)**

Locate the `## Garbage Collection` section. The rule should be inserted after `### Onboarding document staleness` and before `### Template currency` to keep alphabetical-ish grouping with the other "freshness" rules.

In `HARNESS.md`, find this block:

```markdown
### Onboarding document staleness

- **What it checks**: Whether ONBOARDING.md is older than the most
  recent change to HARNESS.md, AGENTS.md, or REFLECTION_LOG.md
- **Frequency**: monthly
- **Enforcement**: deterministic
- **Tool**: file date comparison
- **Auto-fix**: false

### Template currency
```

Insert this block between them:

```markdown
### Onboarding document staleness

- **What it checks**: Whether ONBOARDING.md is older than the most
  recent change to HARNESS.md, AGENTS.md, or REFLECTION_LOG.md
- **Frequency**: monthly
- **Enforcement**: deterministic
- **Tool**: file date comparison
- **Auto-fix**: false

### Redirect sunset

- **What it checks**: Whether any markdown file in `docs/plugins/`
  contains a `<!-- redirect-sunset: YYYY-MM-DD -->` marker with a
  date in the past — indicating a temporary redirect has expired and
  should be reviewed for removal
- **Frequency**: monthly
- **Enforcement**: deterministic
- **Tool**: `scripts/check-redirect-sunsets.sh docs/plugins`
- **Auto-fix**: false (curator decides whether to extend or remove)

### Template currency
```

- [ ] **Step 2: Add the same rule to `ai-literacy-superpowers/templates/HARNESS.md`**

Apply the identical insertion to the shipped template at `ai-literacy-superpowers/templates/HARNESS.md`. Find the same `### Onboarding document staleness` → `### Template currency` boundary and insert the same `### Redirect sunset` block. The text is identical.

- [ ] **Step 3: Run markdownlint to verify both files pass**

Run: `npx markdownlint-cli2 HARNESS.md ai-literacy-superpowers/templates/HARNESS.md`
Expected: no warnings.

- [ ] **Step 4: Run the script against the live docs tree to confirm zero day-1 findings**

Run: `bash scripts/check-redirect-sunsets.sh docs/plugins`
Expected: exit code 0, no output (no markers exist yet — they get added in later tasks with future dates).

- [ ] **Step 5: Commit**

```bash
git add HARNESS.md ai-literacy-superpowers/templates/HARNESS.md
git commit -m "feat(harness): add Redirect sunset GC rule

Adds a monthly deterministic GC rule that scans docs/plugins/ for
<!-- redirect-sunset: YYYY-MM-DD --> markers with dates in the past.
Tool: scripts/check-redirect-sunsets.sh. Auto-fix: false (curator
decides whether to extend or remove the redirect).

Lands in both HARNESS.md (root) and templates/HARNESS.md so projects
running /superpowers-init or /harness-upgrade pick up the rule."
```

---

## Task 4: Update the "Docs Site Review" section in CLAUDE.md

**Files:**
- Modify: `CLAUDE.md` (root)
- Modify: `ai-literacy-superpowers/templates/CLAUDE.md`

- [ ] **Step 1: Update CLAUDE.md (root)**

Locate the `## Docs Site Review` section. Replace the current paragraph that begins "For each plugin, content is grouped using the Diataxis framework as sections within the plugin's `index.md` (page locations are flat within the plugin directory)" with the new convention.

Find:

```markdown
For each plugin, content is grouped using the Diataxis framework as
sections within the plugin's `index.md` (page locations are flat
within the plugin directory):

- **How-to guides** — task-oriented (one guide per command or workflow)
- **Explanation** — conceptual background (why things work the way they do)
- **Reference** — API/schema reference material
- **Tutorials** — end-to-end walkthroughs

For changes to the `ai-literacy-superpowers` plugin, pages live at
`docs/plugins/ai-literacy-superpowers/<slug>.md`. For sister plugins,
under `docs/plugins/<plugin-name>/<slug>.md`.
```

Replace with:

```markdown
For each plugin, content is organised into Diataxis quadrant folders:

- `tutorials/` — nav label "Getting Started" — end-to-end walkthroughs
- `how-to/` — nav label "How-to Guides" — task-oriented (one guide per
  command or workflow)
- `reference/` — nav label "Reference" — API/schema reference material
- `explanation/` — nav label "Concepts" — conceptual background

Pages live at `docs/plugins/<plugin-name>/<quadrant>/<slug>.md`. The
plugin's root `index.md` is a landing page that links to each quadrant;
each quadrant has its own `index.md` with `has_children: true` so
just-the-docs renders the nested tree. Friendly nav labels are set via
`nav_label` frontmatter. The `_template.md` file stays at the plugin
root with header guidance for each quadrant. A quadrant folder is
created only when the plugin has at least one page in that quadrant —
empty quadrants are not scaffolded.

For the `ai-literacy-superpowers` plugin, pages live at
`docs/plugins/ai-literacy-superpowers/<quadrant>/<slug>.md`. For sister
plugins, under `docs/plugins/<plugin-name>/<quadrant>/<slug>.md`.
```

- [ ] **Step 2: Apply the same replacement to `ai-literacy-superpowers/templates/CLAUDE.md`**

The shipped template carries the same "Docs Site Review" text. Apply the identical replacement.

- [ ] **Step 3: Run markdownlint**

Run: `npx markdownlint-cli2 CLAUDE.md ai-literacy-superpowers/templates/CLAUDE.md`
Expected: no warnings.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md ai-literacy-superpowers/templates/CLAUDE.md
git commit -m "docs(claude.md): update Docs Site Review for Diataxis quadrants

Replaces the old 'flat layout with Diataxis sections in index.md'
convention with the new 'quadrant folders' convention. Lands in both
CLAUDE.md (root) and templates/CLAUDE.md so projects running
/superpowers-init pick up the new layout."
```

---

## Task 5: Build the model-cards move-map TSV

**Files:**
- Create: `scripts/migrations/move-map-model-cards.tsv`

- [ ] **Step 1: Write the move-map**

Create `scripts/migrations/move-map-model-cards.tsv` with these 7 rows. Use literal tab characters between columns (most editors enter them with the tab key when not configured for tab-expansion; in vi `:set noexpandtab`).

```text
docs/plugins/model-cards/research-a-model-card.md	docs/plugins/model-cards/how-to/research-a-model-card.md
docs/plugins/model-cards/seed-your-library.md	docs/plugins/model-cards/how-to/seed-your-library.md
docs/plugins/model-cards/agents.md	docs/plugins/model-cards/reference/agents.md
docs/plugins/model-cards/card-template.md	docs/plugins/model-cards/reference/card-template.md
docs/plugins/model-cards/commands.md	docs/plugins/model-cards/reference/commands.md
docs/plugins/model-cards/skills.md	docs/plugins/model-cards/reference/skills.md
docs/plugins/model-cards/mitchell-extended-cards.md	docs/plugins/model-cards/explanation/mitchell-extended-cards.md
```

- [ ] **Step 2: Verify the file is tab-separated**

Run: `awk -F'\t' '{ if (NF != 2) { print "BAD ROW: "NR": "$0; exit 1 } }' scripts/migrations/move-map-model-cards.tsv`
Expected: no output, exit code 0 (every row has exactly 2 tab-separated columns).

- [ ] **Step 3: Verify every old path exists**

Run:

```bash
while IFS=$'\t' read -r old new; do
  [[ -f "$old" ]] || echo "MISSING: $old"
done <scripts/migrations/move-map-model-cards.tsv
```

Expected: no `MISSING:` lines.

- [ ] **Step 4: Verify no new path already exists**

Run:

```bash
while IFS=$'\t' read -r old new; do
  [[ ! -e "$new" ]] || echo "EXISTS: $new"
done <scripts/migrations/move-map-model-cards.tsv
```

Expected: no `EXISTS:` lines.

- [ ] **Step 5: Commit**

```bash
git add scripts/migrations/move-map-model-cards.tsv
git commit -m "chore(scripts): add model-cards move-map for Diataxis reorg

Maps the 7 movable model-cards docs files to their Diataxis quadrant
destinations. Driven by the categorisation methodology in the spec
(verb-form heuristic):

  reference/   — agents.md, card-template.md, commands.md, skills.md
  how-to/      — research-a-model-card.md, seed-your-library.md
  explanation/ — mitchell-extended-cards.md

No tutorials/ — model-cards has no end-to-end walkthrough page yet."
```

---

## Task 6: Move model-cards files into quadrants and add redirects

**Files:**
- Modify (move): all 7 source files listed in the move-map
- After move: each new file gets `redirect_from` + sunset marker frontmatter

- [ ] **Step 1: Create the three quadrant directories**

```bash
mkdir -p docs/plugins/model-cards/how-to
mkdir -p docs/plugins/model-cards/reference
mkdir -p docs/plugins/model-cards/explanation
```

- [ ] **Step 2: Move each file with `git mv` so history is preserved**

```bash
git mv docs/plugins/model-cards/research-a-model-card.md   docs/plugins/model-cards/how-to/research-a-model-card.md
git mv docs/plugins/model-cards/seed-your-library.md       docs/plugins/model-cards/how-to/seed-your-library.md
git mv docs/plugins/model-cards/agents.md                  docs/plugins/model-cards/reference/agents.md
git mv docs/plugins/model-cards/card-template.md           docs/plugins/model-cards/reference/card-template.md
git mv docs/plugins/model-cards/commands.md                docs/plugins/model-cards/reference/commands.md
git mv docs/plugins/model-cards/skills.md                  docs/plugins/model-cards/reference/skills.md
git mv docs/plugins/model-cards/mitchell-extended-cards.md docs/plugins/model-cards/explanation/mitchell-extended-cards.md
```

Verify each move with `git status` — every file should show as renamed (not deleted+added).

- [ ] **Step 3: Update frontmatter and add redirects to each moved file**

For each moved file, the existing frontmatter currently has `parent: model-cards, grand_parent: Plugins`. Update to reflect the new position in the nav tree, and add `redirect_from` + sunset marker.

Apply this transformation to each of the 7 files. The mapping of `parent:` and `grand_parent:` per quadrant is:

| Quadrant | parent: | grand_parent: |
| --- | --- | --- |
| how-to | How-to Guides | model-cards |
| reference | Reference | model-cards |
| explanation | Concepts | model-cards |

For example, `docs/plugins/model-cards/how-to/research-a-model-card.md` — update its frontmatter from:

```yaml
---
title: Research a Model Card
layout: default
parent: model-cards
grand_parent: Plugins
nav_order: 2
---
```

To:

```yaml
---
title: Research a Model Card
layout: default
parent: How-to Guides
grand_parent: model-cards
nav_order: 1
redirect_from:
  - /plugins/model-cards/research-a-model-card/
  - /plugins/model-cards/research-a-model-card.html
# redirect-sunset: 2027-05-07
---
```

`nav_order` is reset to a small integer per quadrant (1, 2, 3, …) since the quadrant is now the parent. Within a quadrant, order pages alphabetically by title or by reading-order intent — keep what makes sense.

Apply the analogous transformation to the other 6 files. The full list of redirects to add:

| File | redirect_from list |
| --- | --- |
| `how-to/research-a-model-card.md` | `/plugins/model-cards/research-a-model-card/`, `/plugins/model-cards/research-a-model-card.html` |
| `how-to/seed-your-library.md` | `/plugins/model-cards/seed-your-library/`, `/plugins/model-cards/seed-your-library.html` |
| `reference/agents.md` | `/plugins/model-cards/agents/`, `/plugins/model-cards/agents.html` |
| `reference/card-template.md` | `/plugins/model-cards/card-template/`, `/plugins/model-cards/card-template.html` |
| `reference/commands.md` | `/plugins/model-cards/commands/`, `/plugins/model-cards/commands.html` |
| `reference/skills.md` | `/plugins/model-cards/skills/`, `/plugins/model-cards/skills.html` |
| `explanation/mitchell-extended-cards.md` | `/plugins/model-cards/mitchell-extended-cards/`, `/plugins/model-cards/mitchell-extended-cards.html` |

Every file gets the same sunset marker: `# redirect-sunset: 2027-05-07`.

- [ ] **Step 4: Run markdownlint on the seven moved files**

Run: `npx markdownlint-cli2 docs/plugins/model-cards/how-to/*.md docs/plugins/model-cards/reference/*.md docs/plugins/model-cards/explanation/*.md`
Expected: no warnings.

- [ ] **Step 5: Verify the redirect-sunset GC rule fires correctly**

Run: `bash scripts/check-redirect-sunsets.sh docs/plugins`
Expected: exit code 0, no output (sunset is in 2027, not yet expired).

- [ ] **Step 6: Commit**

```bash
git add docs/plugins/model-cards
git commit -m "refactor(docs): move model-cards pages into Diataxis quadrants

Phase 1 of the docs Diataxis reorg. Moves 7 model-cards docs files
into how-to/, reference/, and explanation/ quadrant folders. Each
moved file gains:

  - parent: <quadrant-label>, grand_parent: model-cards frontmatter
  - redirect_from list covering / and .html variants of the old URL
  - <!-- redirect-sunset: 2027-05-07 --> marker (12-month sunset)

Categorisation per the verb-form heuristic in the spec. tutorials/
not created — no end-to-end walkthrough page exists for model-cards."
```

---

## Task 7: Create quadrant `index.md` files for model-cards

**Files:**
- Create: `docs/plugins/model-cards/how-to/index.md`
- Create: `docs/plugins/model-cards/reference/index.md`
- Create: `docs/plugins/model-cards/explanation/index.md`

- [ ] **Step 1: Create `how-to/index.md`**

```markdown
---
title: How-to Guides
nav_label: How-to Guides
parent: model-cards
grand_parent: Plugins
has_children: true
nav_order: 2
---

# How-to Guides

Task-oriented guides for the `model-cards` plugin. Pick the page that
matches what you want to do.

- [Research a Model Card](research-a-model-card) — author a single
  Mitchell-extended card from a model name.
- [Seed Your Library](seed-your-library) — bulk-populate cards for a
  set of frontier models from the shipped seed list.
```

- [ ] **Step 2: Create `reference/index.md`**

```markdown
---
title: Reference
nav_label: Reference
parent: model-cards
grand_parent: Plugins
has_children: true
nav_order: 3
---

# Reference

Lookup material for the `model-cards` plugin's components and
artefacts.

- [Agents](agents) — the `model-card-researcher` agent.
- [Skills](skills) — the `model-cards` skill that grounds the agent.
- [Commands](commands) — the `/model-card` slash command.
- [Card Template](card-template) — structure of a Mitchell-extended
  model card (the 9 canonical sections plus Operational Details).
```

- [ ] **Step 3: Create `explanation/index.md`**

```markdown
---
title: Concepts
nav_label: Concepts
parent: model-cards
grand_parent: Plugins
has_children: true
nav_order: 4
---

# Concepts

Conceptual background for the `model-cards` plugin.

- [Mitchell-Extended Cards](mitchell-extended-cards) — why the cards
  are shaped the way they are; the consumer-evaluator audience the
  Operational Details section serves.
```

- [ ] **Step 4: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/model-cards/how-to/index.md docs/plugins/model-cards/reference/index.md docs/plugins/model-cards/explanation/index.md`
Expected: no warnings.

- [ ] **Step 5: Commit**

```bash
git add docs/plugins/model-cards/how-to/index.md docs/plugins/model-cards/reference/index.md docs/plugins/model-cards/explanation/index.md
git commit -m "feat(docs): add quadrant landing pages for model-cards

Creates how-to/index.md, reference/index.md, and explanation/index.md
for the model-cards plugin. Each carries:

  - has_children: true so just-the-docs renders nested children
  - nav_label set to the friendly label (Getting Started / How-to
    Guides / Reference / Concepts) per the spec naming convention
  - A short prose intro plus a list of the pages in the quadrant"
```

---

## Task 8: Rewrite `model-cards/index.md` as a landing page

**Files:**
- Modify: `docs/plugins/model-cards/index.md`

- [ ] **Step 1: Rewrite the file**

The current `docs/plugins/model-cards/index.md` lists pages by section. Replace it with a landing page that points to the quadrant indices.

Replace the entire body (everything below the frontmatter) with:

```markdown
# model-cards

Research and author Mitchell-extended model cards from a model name.

`model-cards` is a sister plugin to `ai-literacy-superpowers` in the
same marketplace. It is aimed at evaluators researching new models,
and produces 10-section cards (Mitchell et al.'s 9 canonical sections
plus an "Operational Details" section for consumer-evaluator
audiences) with per-claim citations and tiered source provenance.

The plugin's source lives at [`model-cards/`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/tree/main/model-cards)
in the repository.

## Where to start

| If you want to… | Go to |
| --- | --- |
| Do a specific task (research a card, seed your library) | [How-to Guides](how-to/) |
| Look up an agent, command, skill, or the card schema | [Reference](reference/) |
| Understand why the cards are shaped the way they are | [Concepts](explanation/) |

End-to-end tutorials are not yet shipped for this plugin.
```

Keep the existing frontmatter as-is (it already has `parent: Plugins, has_children: true, nav_order: 1`).

- [ ] **Step 2: Run markdownlint**

Run: `npx markdownlint-cli2 docs/plugins/model-cards/index.md`
Expected: no warnings.

- [ ] **Step 3: Commit**

```bash
git add docs/plugins/model-cards/index.md
git commit -m "refactor(docs): rewrite model-cards index as landing page

Replaces the old per-section page-listing index with a Diataxis-aware
landing page that links to each quadrant's own index. Mentions that
tutorials are not yet shipped for this plugin."
```

---

## Task 9: Run the rewrite script + verification grep

**Files:**
- Repo-wide `.md` files containing links to old model-cards docs paths

- [ ] **Step 1: Run the rewrite script**

Run from the repo root:

```bash
bash scripts/migrations/rewrite-docs-links.sh scripts/migrations/move-map-model-cards.tsv
```

Expected: no output, exit code 0.

- [ ] **Step 2: Verification grep — no remaining flat-path links to migrated pages**

For each row in the move-map, search the repo for any remaining link to the old path. Run:

```bash
while IFS=$'\t' read -r old new; do
  echo "=== Searching for: $old ==="
  grep -rn -F "$old" \
    --include="*.md" \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=archive \
    --exclude-dir=specs \
    --exclude-dir=plans \
    --exclude-dir=objections \
    --exclude-dir=stories \
    --exclude=CHANGELOG.md \
    . || true
done <scripts/migrations/move-map-model-cards.tsv
```

Expected: no output under any `=== Searching for: ===` heading. If any line appears, that's a missed rewrite — investigate and fix manually before continuing.

- [ ] **Step 3: Inspect the diff**

```bash
git status
git diff --stat
```

Expected: a list of modified files. Each modification should be a link rewrite from a flat path to a quadrant path. Spot-check 3-5 files to confirm the rewrites are correct.

- [ ] **Step 4: Run markdownlint on the modified files**

Run: `npx markdownlint-cli2 "**/*.md"`
Expected: no warnings.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor(docs): rewrite repo-wide links to migrated model-cards pages

Applies scripts/migrations/move-map-model-cards.tsv across every .md
file in the repo (excluding archives, specs, plans, objections,
stories, and CHANGELOG entries which preserve their old-path quotes).
Verification grep confirms no flat-path links remain to the migrated
pages."
```

---

## Task 10: Bump plugin version, marketplace pointer, README badge, CHANGELOG

**Files:**
- Modify: `ai-literacy-superpowers/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Bump `plugin.json`**

Update `ai-literacy-superpowers/.claude-plugin/plugin.json`'s `version` field from `0.33.0` to `0.34.0`.

- [ ] **Step 2: Bump `marketplace.json`**

Update `.claude-plugin/marketplace.json`'s top-level `plugin_version` field from `0.33.0` to `0.34.0`. The listing's own `version` field does **not** change — this is a plugin version bump, not a listing-contract change.

- [ ] **Step 3: Update the README badge**

In `README.md`, find the line:

```markdown
[![ai-literacy-superpowers](https://img.shields.io/badge/ai--literacy--superpowers-v0.33.0-4682B4?style=flat-square)](ai-literacy-superpowers/)
```

Update to:

```markdown
[![ai-literacy-superpowers](https://img.shields.io/badge/ai--literacy--superpowers-v0.34.0-4682B4?style=flat-square)](ai-literacy-superpowers/)
```

The marketplace plugin table row's version cell (line 30) — currently `v0.33.0` — also bumps to `v0.34.0`.

- [ ] **Step 4: Add the new CHANGELOG section**

In `CHANGELOG.md`, insert a new top heading immediately above the current top heading. It must start with the version followed by a dash and date:

```markdown
## 0.34.0 — 2026-05-07

### Feature — Diataxis docs reorg (Phase 1: model-cards)

Establishes the project-wide Diataxis folder convention for the docs
site and applies it to the `model-cards` plugin as the reference
implementation. Plugin docs now live at
`docs/plugins/<plugin-name>/<quadrant>/<slug>.md` where `<quadrant>`
is one of `tutorials/`, `how-to/`, `reference/`, or `explanation/`.
URLs are Diataxis-pure; sidebar nav uses friendly labels via
just-the-docs `nav_label` frontmatter.

Ships the convention machinery: a new **Redirect sunset** GC rule
(monthly, deterministic, scans for expired `<!-- redirect-sunset:
YYYY-MM-DD -->` markers), the `scripts/check-redirect-sunsets.sh`
tool that backs it, and the `scripts/migrations/rewrite-docs-links.sh`
one-shot link rewriter. Updates `CLAUDE.md` and
`templates/CLAUDE.md` to document the new layout convention.

The `model-cards` plugin's 7 movable docs pages were moved into
how-to/, reference/, and explanation/ quadrants (no tutorials/ —
no end-to-end walkthrough page exists yet). Every moved page
carries `redirect_from` covering both old URL forms (`/slug/` and
`/slug.html`) plus a 12-month sunset marker (2027-05-07).

`ai-literacy-superpowers` plugin docs migration arrives in Phase 2
as a separate PR (no version bump — outside the plugin directory).
```

The current top heading (`## 0.33.0 — 2026-05-07`) stays unchanged below.

- [ ] **Step 5: Verify the version-consistency relationship**

Run:

```bash
echo "plugin.json: $(jq -r .version ai-literacy-superpowers/.claude-plugin/plugin.json)"
echo "marketplace.json plugin_version: $(jq -r .plugin_version .claude-plugin/marketplace.json)"
echo "README badge: $(grep -oE 'ai--literacy--superpowers-v[0-9]+\.[0-9]+\.[0-9]+' README.md | head -1)"
echo "CHANGELOG top: $(grep -m1 '^## ' CHANGELOG.md)"
```

Expected: all four show `0.34.0` (the README badge will read `ai--literacy--superpowers-v0.34.0`).

- [ ] **Step 6: Run markdownlint**

Run: `npx markdownlint-cli2 README.md CHANGELOG.md`
Expected: no warnings.

- [ ] **Step 7: Commit**

```bash
git add ai-literacy-superpowers/.claude-plugin/plugin.json .claude-plugin/marketplace.json README.md CHANGELOG.md
git commit -m "chore: bump ai-literacy-superpowers to v0.34.0

Plugin minor bump driven by the new Redirect sunset GC rule, the
scripts/check-redirect-sunsets.sh tool, the
scripts/migrations/rewrite-docs-links.sh one-shot link rewriter,
and the templates/CLAUDE.md and templates/HARNESS.md updates that
ship the new docs convention to projects running /superpowers-init.

Marketplace plugin_version pointer updated. README badge and
marketplace plugin row also refreshed."
```

---

## Task 11: Local site build + deployed-branch nav verification

**Files:**
- No file changes — this is verification only

- [ ] **Step 1: Build the Jekyll site locally**

If the project has a `Gemfile`, run:

```bash
cd docs && bundle install && bundle exec jekyll serve --port 4000
```

If not, the `pages.yml` GitHub Actions workflow can be triggered on the branch instead (see Step 3).

Verify on `http://localhost:4000`:

1. The plugin landing page (`/plugins/model-cards/`) renders with the four-quadrant table.
2. Each quadrant index renders (`/plugins/model-cards/how-to/`, `/reference/`, `/explanation/`).
3. Each moved page renders at its new URL (`/plugins/model-cards/how-to/research-a-model-card/`).
4. Visiting an old URL (`/plugins/model-cards/research-a-model-card/`) redirects to the new location (jekyll-redirect-from generates HTML meta-refresh stubs).
5. **Sidebar nav verification** (the load-bearing check). Expand the `model-cards` group in the left sidebar. You should see the three quadrant labels ("How-to Guides", "Reference", "Concepts") nested under `model-cards`, and each page nested under its quadrant. If the pages appear at the same level as the quadrants (or are not visible), just-the-docs is not handling the 4-level nesting.

- [ ] **Step 2: If the local nav check fails, apply the fallback**

If just-the-docs flattens the nav (4 levels not supported by the installed theme version), fall back to the **flat nav with quadrant URLs** strategy:

- Keep all the quadrant folders and files in place. URLs stay Diataxis-pure.
- Update each moved page's frontmatter: `parent: model-cards, grand_parent: Plugins` (3 levels, not 4). Remove `nav_label` and the per-quadrant `parent: How-to Guides`-style references.
- Delete the three quadrant `index.md` files (their navigation purpose disappeared).
- Restore the page-listing in `model-cards/index.md` — the plugin index becomes the single navigation surface again, but now grouping by quadrant matches the URL structure.

If this fallback is applied, document it in the commit message and the CHANGELOG entry, and revise the spec section § 3 in a follow-up commit on this branch.

- [ ] **Step 3: Push the branch and let GitHub Actions render the site**

```bash
git push -u origin chore/docs-diataxis-reorg-model-cards
```

The `pages.yml` workflow renders the site to a preview URL. Verify the same five points from Step 1 against the deployed preview.

If both the local build and the deployed preview pass, proceed to Task 12.

- [ ] **Step 4: No commit (verification only)**

This task produces no file changes. If the fallback in Step 2 was applied, the file changes from that fallback are committed there with their own message.

---

## Task 12: Open the PR and watch CI

**Files:**
- No file changes — this is the integration step

- [ ] **Step 1: Confirm the working tree is clean and pushed**

```bash
git status
git log --oneline origin/main..HEAD
```

Expected: clean working tree; the commit list shows the 10 commits from Tasks 1-10 (Task 11 produced no commits unless the fallback was applied).

- [ ] **Step 2: Open the PR with the chore label**

```bash
gh pr create --label chore \
  --title "chore: docs Diataxis reorg phase 1 — model-cards + convention machinery" \
  --body "$(cat <<'EOF'
## Summary

Phase 1 of the docs site Diataxis reorg ([spec](docs/superpowers/specs/2026-05-07-docs-diataxis-reorg-design.md)).
Reorganises `docs/plugins/model-cards/` into Diataxis quadrant folders
as the reference implementation, and ships the convention machinery
that Phase 2 will reuse for the `ai-literacy-superpowers` flagship
migration.

## What's in this PR

- **New GC rule: Redirect sunset** — monthly deterministic check that
  flags expired `<!-- redirect-sunset: YYYY-MM-DD -->` markers in
  `docs/plugins/`. Lands in both `HARNESS.md` and
  `templates/HARNESS.md`.
- **`scripts/check-redirect-sunsets.sh`** — the GC rule's tool, with
  functional test.
- **`scripts/migrations/rewrite-docs-links.sh`** — one-shot link
  rewriter, with functional test. Reused by Phase 2.
- **`scripts/migrations/move-map-model-cards.tsv`** — 7-row move map.
- **`docs/plugins/model-cards/`** — 7 pages moved into how-to/,
  reference/, explanation/ quadrants. Each moved page gets
  `redirect_from` for both `/slug/` and `/slug.html` variants plus a
  12-month sunset marker (2027-05-07). `tutorials/` not created
  (no end-to-end walkthrough exists yet).
- **`docs/plugins/model-cards/<quadrant>/index.md`** — three new
  quadrant landing pages.
- **`docs/plugins/model-cards/index.md`** — rewritten as a landing
  page with a 4-cell quadrant table.
- **`CLAUDE.md` and `templates/CLAUDE.md`** — "Docs Site Review"
  section updated to document the quadrant convention.
- **Plugin version bump 0.33.0 → 0.34.0** with `marketplace.json`
  pointer, README badge, and CHANGELOG entry.

## Why chore label

This PR is a structural/mechanical refactor of an existing
documentation surface. The implementation is conservatively bounded
(model-cards only — Phase 2 is a separate PR); the version bump is
honest about the behavioural change (new GC rule, new templates
content); the convention is fully specified in the linked design.
Per AGENTS.md STYLE, the `chore` label is acceptable for
behavioural changes meeting these conditions, and exempts
`/diaboli` and `/choice-cartograph` adjudication.

## Test plan

- [x] `scripts/check-redirect-sunsets.sh` functional tests pass.
- [x] `scripts/migrations/rewrite-docs-links.sh` functional tests pass
      (rewrite + idempotency).
- [x] Repo-wide verification grep finds zero remaining flat-path
      links to migrated model-cards pages.
- [x] markdownlint clean across HARNESS.md, CLAUDE.md, and all
      modified docs.
- [x] Local Jekyll build renders the four-level nested nav correctly
      (or the documented fallback was applied — see commit history).
- [ ] CI green.
- [ ] Branch preview spot-check: 3-5 redirected URLs resolve to the
      new locations.

## Phase 2 follow-up

`ai-literacy-superpowers` flagship migration ships in a separate PR
on its own branch. No version bump for that PR — `docs/plugins/`
is outside the plugin directory.
EOF
)"
```

- [ ] **Step 3: Watch CI**

```bash
gh pr checks $(gh pr view --json number -q .number) --watch
```

Expected: all checks green. The five expected checks are `markdownlint` (×2 — one per workflow), `Check spec-first commit ordering`, `Check version consistency`, and `Enforce PR constraints`.

- [ ] **Step 4: Hand off to the user for merge**

Once CI is green, report the PR URL to the user. The user merges; this plan does not auto-merge.

After merge, the user will:

1. Run `/harness-sync` to absorb the new GC rule into convention surfaces and ONBOARDING.md.
2. Open Phase 2 (a new branch + plan + PR for the `ai-literacy-superpowers` flagship migration).

---

## Self-Review

Verifying coverage against the spec:

- **§ 3 Target structure**: Tasks 6, 7, 8 cover quadrant folders, quadrant indices, and plugin landing page rewrite. ✓
- **§ 4 Naming convention**: Tasks 6 and 7 use the friendly nav labels via `nav_label` frontmatter, with quadrant folders carrying the Diataxis-pure URLs. ✓
- **§ 5 Categorisation methodology**: Applied as the move-map content in Task 5. ✓
- **§ 6 Redirect strategy**: Tasks 6 (frontmatter) and 3 (GC rule) and 1 (sunset check tool). ✓
- **§ 7 Internal link migration**: Tasks 2 (rewrite script), 5 (move-map), 9 (apply + verify). ✓
- **§ 8 Convention text and constraint updates**: Tasks 3 (HARNESS additions) and 4 (CLAUDE.md updates). ✓
- **§ 9 Two-phase plan, Phase 1 file list**: Every file listed in spec § 9 Phase 1 has a creating/modifying task in this plan. ✓
- **§ 10 Verification**: Task 11 (local build + nav verification + branch preview), Task 9 step 2 (verification grep), Task 1 step 5 (sunset GC clean run on day 1). ✓
- **§ 11 Out of scope**: Honoured — no `/docs-sync` analogue, no per-quadrant landing-page enrichment beyond a thin intro, no Diataxis structure for `docs/superpowers/`, no markdown lint additions, no versioned docs, no search tuning, no auto-categorisation script. ✓
- **§ 12 Risks**: Mitigated. The 4-level nav rendering risk has an explicit Task 11 Step 2 fallback. The mass-rewrite risk has the verification grep in Task 9 Step 2. The page miscategorisation risk is bounded by `redirect_from` (a wrong call is cheap to fix later).

Placeholder scan: clean. Type/path consistency: every file path and frontmatter field referenced in later tasks is defined in earlier tasks (move-map TSV format, sunset marker format, frontmatter field names).

No issues found. Plan is ready.
