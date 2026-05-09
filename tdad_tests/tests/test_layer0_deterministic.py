"""Layer 0: deterministic plumbing tests.

The framework's harness promotion ladder (Theme #10) names three
verification tiers — unverified, agent-verified, deterministic. Layers
1–3 of this suite cover agent-verified territory. Layer 0 covers the
deterministic-tier work: tests of the bash scripts and parser library
that the agents *depend on*.

These tests exist as bash scripts under
``layer0_deterministic/test-*.sh``. Each script tests a piece of plugin
plumbing (reflection-log archival, migration proposal generation,
parser library functions) in its native shell. Rewriting them as
Python would lose the property that the tests exercise the actual
shell code in a real shell.

This module dispatches each bash test script through pytest. Failure
output from the bash script is preserved verbatim (the script's
``FAIL: ...`` message tells the developer exactly which sub-test
failed, even though pytest reports failure at the script level).

Why include shell tests in a suite labelled "TDAD" — Test-Driven
Agentic Discipline? Because the agent depends on the plumbing. The
integration-agent's behaviour of writing a well-formed reflection
entry is itself agent-verified work (Layer 3 territory if we ever
write it), but the *script that archives that entry on a schedule* is
deterministic plumbing whose correctness is a precondition for the
agent's correctness. Both belong in the same harness; both belong in
the same suite. The promotion ladder is the unifying frame.

Layer 0 runs offline, fast (< 5 seconds total), and free.
"""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

import pytest


# All bash test scripts that should be dispatched as Layer 0 tests.
# Listed by stem (without ``.sh``); the dispatcher resolves the full
# path under ``layer0_deterministic/``. Adding a new bash test means
# adding a new entry here — no other code changes needed.
BASH_TEST_SCRIPTS = [
    "test-reflection-log-helpers",
    "test-archive-promoted-reflections",
    "test-migrate-reflection-log",
]


@pytest.fixture(scope="session")
def layer0_dir() -> Path:
    """Resolve the layer0_deterministic/ directory."""
    return Path(__file__).resolve().parent.parent / "layer0_deterministic"


@pytest.fixture(scope="session")
def bash_executable() -> str:
    """Locate the system bash. The bash test scripts run on
    /usr/bin/env bash by their shebang; this fixture confirms there
    *is* a bash on the PATH so we can fail informatively rather than
    cryptically if it is missing (e.g. on a minimal CI container).
    """
    bash = shutil.which("bash")
    if not bash:
        pytest.fail(
            "bash not found on PATH. Layer 0 tests require a POSIX "
            "shell to dispatch the existing bash test scripts. "
            "Install bash or run Layer 0 in an environment that has it."
        )
    return bash


@pytest.mark.structural
@pytest.mark.parametrize("script_stem", BASH_TEST_SCRIPTS)
def test_bash_script_passes(
    script_stem: str,
    layer0_dir: Path,
    bash_executable: str,
) -> None:
    """Each bash test script must exit 0.

    On failure, the bash script's stdout and stderr are captured and
    surfaced through pytest's report so the specific sub-test that
    failed (the bash file's ``FAIL: ...`` line) is visible without
    re-running by hand.
    """
    script = layer0_dir / f"{script_stem}.sh"
    assert script.is_file(), (
        f"Bash test script not found: {script}. "
        "Has it been moved or renamed?"
    )

    result = subprocess.run(
        [bash_executable, str(script)],
        capture_output=True,
        text=True,
        # Layer 0 must stay fast. A bash test that takes longer than
        # this is either hung or doing something unintended.
        timeout=60,
    )

    if result.returncode != 0:
        pytest.fail(
            f"{script_stem}.sh exited {result.returncode}\n\n"
            f"--- stdout ---\n{result.stdout}\n"
            f"--- stderr ---\n{result.stderr}\n"
        )
