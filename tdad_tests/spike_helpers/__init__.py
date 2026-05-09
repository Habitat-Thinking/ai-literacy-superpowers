"""Phase 2 spike helpers.

These modules implement minimal Python versions of two procedural
plugin commands (`/convention-sync` and `/observatory-verify`) so that
their deterministic logic can be unit-tested. The spike's purpose is
to validate the per-category strategy from the Phase-2 design spec
(``docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md``):
extracting P-category command logic into Python (Option C-direct) is
testable, and the test scaffolding is cheap.

Scope is deliberately narrow:

- ``convention_sync`` handles only the Cursor ``.cursor/rules/
  conventions.mdc`` output. Copilot and Windsurf are left for Phase 3.
- ``observatory_verify`` handles only one signal source (Snapshot).
  The remaining four sources (Governance, Reflection log, HARNESS.md,
  Assessment) are left for Phase 3.

The helpers live under ``tdad_tests/`` rather than the packaged plugin
because they are spike-stage code: a follow-up Phase 3 PR is expected
to either promote them to ``ai-literacy-superpowers/scripts/`` (where
the command markdowns can invoke them) or refactor them based on what
the spike teaches. Keeping them in test scaffolding for now avoids
accidentally treating a spike artefact as production code.
"""
