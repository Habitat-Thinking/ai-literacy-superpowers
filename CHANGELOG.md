# Changelog

## 0.39.1 — 2026-05-28

### Fix — /superpowers-status disposition counting

`/superpowers-status` could over-report pending dispositions when an
objection or choice-story record contained the literal string
`disposition: pending` inside an `evidence:` or `claim:` field — a
common pattern when an objection itself critiques disposition handling.
A naive `grep -c "disposition: pending"` matched those prose occurrences
and reported them as unresolved entries. In 2026-05 this showed
`choice-cartographer.md` as having 3 pending dispositions when every
entry was in fact resolved.

- `commands/superpowers-status.md` now defines a shared "Disposition
  counting" algorithm before Section 7. The rule: count only lines
  matching `^    disposition: pending(\s|$)` within the first
  `---`…`---` frontmatter block. Provides an awk recipe agents and
  humans can paste, and notes that a YAML-aware parser (`yq`,
  `python -c "import yaml"`) is preferred when available.
- Sections 7 (Diaboli) and 8 (Cartographer) reference the shared
  algorithm so the same fix protects both panels.

### Chore — Bump Node.js 20 GitHub Actions before 2026-06-02 cutoff

- `spec-first-check.yml`: bumped `actions/github-script` from v7.0.1 (Node 20) to v9.0.0 (Node 24) ahead of GitHub's 2026-06-02 hard cutoff.
