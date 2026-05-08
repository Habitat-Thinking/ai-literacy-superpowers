"""Shared pytest fixtures for the TDAB external test suite.

The fixtures here exist to keep individual tests focused on what they are
asserting rather than on the plumbing that gets them into a position to
assert. Three fixtures earn their keep:

- ``plugin_path`` resolves the on-disk location of the packaged plugin so
  tests can read agent, skill, and command files without hard-coding paths.
  Using a fixture (rather than a module-level constant) means the resolution
  logic lives in one place and can be overridden in a future per-environment
  layout (e.g. CI runners).

- ``needs_api`` is the gate that turns Layer 2 and Layer 3 tests into
  no-ops when no API key is present. Spike philosophy: tests must be
  runnable on a developer machine without surprises. Layer 1 stays free
  and fast; the cost-bearing layers are opt-in via environment.

- ``violation_fixture_path`` returns the path to the fixture code that
  the cupid-code-review skill is expected to find faults in. Centralising
  the path keeps the scenario file and the test in agreement.

These fixtures are deliberately not parametrised over the full plugin
component inventory. The spike tests three named components; the runner
that scales to all 71 will need its own parametrisation pass.
"""

from __future__ import annotations

import os
from pathlib import Path

import pytest


@pytest.fixture(scope="session")
def plugin_path() -> Path:
    """Resolve the packaged plugin directory."""
    # tests-external/ is a sibling of the inner ai-literacy-superpowers/
    # packaged directory inside the repo. The repo root sits one level up
    # from this conftest.
    repo_root = Path(__file__).resolve().parent.parent
    packaged = repo_root / "ai-literacy-superpowers"
    if not packaged.is_dir():
        pytest.fail(
            f"Plugin directory not found at {packaged!r}. "
            "Has the plugin been moved or renamed?"
        )
    return packaged


@pytest.fixture(scope="session")
def has_api_key() -> bool:
    """Whether the Anthropic API key is available in the environment."""
    return bool(os.environ.get("ANTHROPIC_API_KEY"))


@pytest.fixture
def needs_api(has_api_key: bool) -> None:
    """Skip the test if no API key is available."""
    if not has_api_key:
        pytest.skip(
            "ANTHROPIC_API_KEY not set — Layer 2 and Layer 3 tests are "
            "skipped offline. Run `export ANTHROPIC_API_KEY=...` to "
            "enable."
        )


@pytest.fixture(scope="session")
def fixtures_dir() -> Path:
    """Root of the test fixture corpus."""
    return Path(__file__).resolve().parent / "fixtures"


@pytest.fixture(scope="session")
def scenarios_dir() -> Path:
    """Root of the test scenario corpus."""
    return Path(__file__).resolve().parent / "scenarios"
