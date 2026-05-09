"""Test-stage helpers for procedural plugin commands.

Each helper here implements the deterministic logic of one
procedural-category slash command — the "what would the command
*do* if it were a Python script" core, with the model-mediated
wrapping (asking the user, formatting, judgement calls) excluded.

Tests in ``tdad_tests/tests/`` exercise these helpers against
fixtures and assert on the resulting structure. Helpers stay
test-stage per the design spec amendment (PR #298) — they are
not promoted to ``ai-literacy-superpowers/scripts/`` because the
plugin ships shell-only and the language-runtime cost of moving
to Python at consumer machines is not justified by the
test-coverage benefit. The helpers therefore mirror the documented
behaviour rather than replacing it; drift between helper and
prose is a test failure the author resolves manually.

Helpers shipped here:

| Module | Mirrors | What it covers |
| --- | --- | --- |
| ``convention_sync`` | ``/convention-sync`` | HARNESS.md → Cursor conventions.mdc (Cursor only) |
| ``observatory_verify`` | ``/observatory-verify`` | Snapshot signal source only |
| ``harness_status`` | ``/harness-status`` | Parse HARNESS.md Status section |
| ``harness_upgrade`` | ``/harness-upgrade`` | Section-level diff template vs project |
| ``harness_affordance`` | ``/harness-affordance discover`` | Scan settings/hooks/mcp configs |
| ``governance_health`` | ``/governance-health`` | Latest audit summary |
| ``superpowers_status`` | ``/superpowers-status`` | Habitat-file existence sweep |
| ``reflect`` | ``/reflect`` | Format reflection entry from fields |
| ``harness_health`` | ``/harness-health`` (quick mode) | Aggregate health snapshot |
| ``cost_capture`` | ``/cost-capture`` | Latest cost snapshot read |
| ``markdown`` | (shared utility) | Section + field extraction |

Deliberate omission:

- ``/worktree`` is wholly git operations (``git worktree add``,
  ``git worktree remove``, ``git worktree prune``). A Python helper
  would just be a thin wrapper around ``subprocess.run(["git",
  "worktree", ...])``; the work is already in ``git`` and a wrapper
  test is testing git, not the command's logic. Layer 1 wiring
  already verifies the command's references resolve. No helper is
  built; this is documented in the suite README's "Coverage gaps
  and deferrals" section.
"""
