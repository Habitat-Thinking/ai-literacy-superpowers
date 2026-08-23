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
    "test-auto-enforcer",
    # #509 — an advisory prompt hook must not hold a blocking position.
    # PreToolUse prompt hooks can only allow or deny; there is no warn channel.
    "test-hooks-advisory-placement",
    # Cadence Sentinels S7 — docs parity and the cadence substrate as a whole.
    # D1/D2/D3 derive both sides rather than pinning a count; K1-K5 assert the
    # one property the per-library tests structurally cannot show.
    "test-sentinel-docs-coverage",
    # #507 — the sentinel roster is a derived fact pinned in three places.
    # Membership only: the tables carry prose no generator would write well.
    "test-sentinel-roster-parity",
    # #519 — the sentinel docs were written for authors, not users. Derives
    # the agent-command relation from reference/commands.md's own field.
    "test-sentinel-usage-path",
    "test-hooks-doc-parity",
    "test-cadence-integration",
    "test-affordances-template",
    "test-affordance-check",
    "test-affordance-staleness",
    "test-affordance-recorder",
    "test-affordance-invocations",
    # dynamic-workflows S2 — INV-1/INV-2 firewall matcher + template substrate.
    # RED until S2 ships the matcher script and the four templates.
    "test-inv1-firewall",
    "test-workflow-templates",
    # sentinel agent category — the read-only integrity matcher for
    # role: sentinel agents (§5.4).
    "test-sentinel-integrity",
    # harness-health badge writer — mirrors the authoritative Health line
    # rather than re-deriving it (regression: "Trend alerts: none").
    "test-update-health-badge",
    # Cadence Sentinels S1 — the shared substrate S2–S5 consume: the pact
    # block reader, the session registry lease, and the two record contracts.
    # RED until S1 ships lib/pact-blocks.sh, the two registry libraries and
    # their hooks, lib/record-paths.sh, and the reference format pages.
    "test-pact-blocks",
    "test-session-registry",
    "test-record-contracts",
    # Cadence Sentinels S2 — the Coda's ritual. RED until S2 ships
    # scripts/next-action-hint.sh and hooks/scripts/parked-resume-check.sh.
    "test-next-action",
    "test-parked-resume",
    # Cadence Sentinels S3 — the pact writer. RED until S3 ships
    # hooks/scripts/lib/pact-write.sh.
    "test-pact-write",
    # Cadence Sentinels S4 — the WIP breach check. RED until S4 ships
    # hooks/scripts/wip-check.sh.
    "test-wip-check",
    # Cadence Sentinels S3b — the advisory rail. RED until S3b ships
    # hooks/scripts/lib/advisory-rail.sh.
    "test-advisory-rail",
    "test-mast-boundary",
    # Cadence Sentinels S5 — the consultation-disposition matcher. RED until
    # S5 ships scripts/check-consultation-dispositions.py.
    "test-convene-check",
    # Harness Evolution S0 — the HDR + surfaces.yaml validator. RED until S0
    # ships scripts/check-harness-decisions.py. This is the one place every
    # governance refusal lives: the Registrar is a plugin agent with Write, so
    # a rule that existed only in its prompt would be a rule it could talk
    # itself past. Here it turns the build red instead.
    "test-harness-decisions",
    # Harness Evolution S1 — the Registrar's write path. R2 asserts the copied
    # rule text is byte-identical (the fixture's first line ends in two spaces:
    # a markdown hard break that a well-meaning .rstrip() destroys). R13 hashes
    # every file under harness/ before and after each refusal, because "nothing
    # was written" deserves a measurement rather than a reading of the code.
    "test-harness-registrar",
    # Harness Evolution S2 — compilation, the enforcement report, and the drift
    # check. C12b asserts that a validator DECLARED but absent does not lift the
    # enforcement degradation, and C14 asserts the git-backed frozen-record
    # check: region drift cannot catch an agent rewording the rule in the
    # accepted HDR and recompiling, because the region would then match.
    "test-harness-compile",
    # Harness Evolution S3 — the assay linter and the forward-test fixture.
    # A6 asserts EVERY malformed finding is reported in one pass: /harness-propose
    # parses lazily so one bad block costs one finding, but at write time the
    # question is whether the document is well-formed, and a linter that stopped
    # at the first defect would send an author round the loop once per mistake
    # against a record that is append-only once written.
    "test-harness-assay",
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
