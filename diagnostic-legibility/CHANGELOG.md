# Changelog

## 0.2.0 — 2026-05-26

### LegibilityElement schema

Adds the `LegibilityElement` schema artefact at
`templates/legibility-element.md`. The schema covers both the
architectural and domain dimensions of the diagnostic-legibility
agent (built in sub-S2b, issue #335) under a single flat record type;
the dimensions are typed by the collection wrapper `LegibilityModel`,
not by the record itself. Carries `name`, `description`, `evidence`
(list of `{path, excerpt?}`), `confidence` (low/medium/high), and
`challenge_notes`. Wrapper adds `scope`, `generated_at`,
`generated_by`, and the two collections.

Replaces the `templates/.gitkeep` placeholder from v0.1.0.

Validation is enforced by the agent during construction; no runtime
validator ships at this version.

Sub-S1 of the meta-iteration recorded at
`docs/superpowers/slices/dl-s2-two-model-agent.md`. Tracks parent
issue #331. Sub-S2b (challenge protocol + working agent) is deferred
to issue #335.

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
