"""Layer 3: full behavioural tests via the Claude Agent SDK.

These tests dispatch the actual component (an agent or a skill-bearing
session) against a fixture and assert observable outputs — the file
state after a spec-writer run, the violations a cupid-code-review skill
identifies, the side-effects of a command. This is TDAB proper.

Layer 3 is expensive: each test is a full SDK invocation, possibly
multi-turn, and runs against the model. The spike wires up the
architecture and demonstrates the test shape but defers actual API
invocations to a follow-up. The skipped tests carry explicit TODOs and
reference the scenario files where the assertions live.

The skipped state is deliberate. The alternative is to spend money on
runs whose architecture might still change after the spike is reviewed
— premature commitment. The structural validity of these tests
(scenario presence, fixture presence, target component existence) is
checked at Layer 1, so anything that *can* be verified offline is
already verified.

Why include the cupid-code-review scenario as a behavioural test when
its skill is loaded by description match (which is what Layer 2
already exercises)? Because Layer 2 only verifies that the skill *would
load*. Layer 3 verifies that, when loaded, the skill produces the
expected output for a known input. Both layers can pass independently;
both can fail independently. The two failures point at different fixes.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner.scenario import parse_scenario  # noqa: E402


@pytest.mark.behavioural
@pytest.mark.needs_api
class TestSpecWriterCreatesSpec:
    """spec-writer agent against a clean fixture should produce a
    spec.md with the structural elements its agent prompt requires:
    user story, acceptance scenarios, numbered functional requirements.
    """

    @pytest.fixture
    def scenario(self, scenarios_dir):
        return parse_scenario(
            scenarios_dir
            / "agents"
            / "spec-writer"
            / "creates-spec-with-acceptance-scenarios.md"
        )

    def test_scenario_loads(self, scenario):
        """A precondition: the scenario must be loadable and complete.

        This is offline and runs even without an API key — it ensures
        the scenario file remains valid as the spec-writer agent
        evolves.
        """
        assert scenario.component == "spec-writer"
        assert scenario.component_type == "agent"
        assert scenario.tier == "behavioural"
        # The scenario must declare the four conventional sections so
        # the runner knows what to dispatch and what to assert.
        for required in ("Given", "When", "Then"):
            assert required in scenario.sections, (
                f"spec-writer scenario missing '{required}' section"
            )

    def test_spec_writer_produces_required_sections(
        self, needs_api, scenario, tmp_path
    ):
        """Layer 3 proper: dispatch the spec-writer agent against an
        empty repo fixture and assert the resulting spec.md.

        Wired but not yet executed against the live API. The scenario
        file at scenarios/agents/spec-writer/... carries the exact
        prompt and assertions; a runner will load that scenario, hand
        it to the SDK, and grade the output against a rubric.
        """
        pytest.skip(
            "SDK behavioural-runner pending implementation; see "
            "scenarios/agents/spec-writer/"
            "creates-spec-with-acceptance-scenarios.md"
        )


@pytest.mark.behavioural
@pytest.mark.needs_api
class TestCupidCodeReviewIdentifiesViolations:
    """cupid-code-review skill against fixture code with deliberate
    CUPID violations should identify at least the obvious ones."""

    @pytest.fixture
    def scenario(self, scenarios_dir):
        return parse_scenario(
            scenarios_dir
            / "skills"
            / "cupid-code-review"
            / "identifies-violations.md"
        )

    @pytest.fixture
    def violation_fixture(self, fixtures_dir):
        path = fixtures_dir / "cupid-violations" / "user_repository.py"
        if not path.exists():
            pytest.fail(
                f"CUPID violation fixture not found at {path!r}. "
                "The scenario references it; the test cannot run "
                "without it."
            )
        return path

    def test_scenario_loads(self, scenario):
        assert scenario.component == "cupid-code-review"
        assert scenario.component_type == "skill"
        assert scenario.tier == "behavioural"

    def test_fixture_exists(self, violation_fixture):
        """A precondition: the violation code the scenario assumes
        must be present and readable. Offline."""
        text = violation_fixture.read_text(encoding="utf-8")
        assert text, "CUPID violation fixture is empty"
        # Sanity-check that the fixture is structurally what it claims
        # to be — Python code with a class. A wholly different file
        # would silently change what the scenario asserts.
        assert "class" in text, (
            "CUPID violation fixture should contain at least one class"
        )

    def test_skill_identifies_cupid_violations(
        self, needs_api, scenario, violation_fixture
    ):
        """Layer 3 proper: dispatch a session with the skill loaded,
        feed it the fixture, and rubric-grade the response.

        Wired but not yet executed.
        """
        pytest.skip(
            "SDK behavioural-runner pending implementation; see "
            "scenarios/skills/cupid-code-review/identifies-violations.md"
        )


@pytest.mark.behavioural
class TestHarnessInitCommandFinding:
    """The harness-init command surfaces the spike's biggest finding:
    slash commands do not have a clean SDK invocation path. The
    architectural question is documented in the scenario folder."""

    def test_finding_scenario_exists(self, scenarios_dir):
        """The finding is itself a scenario — that's how we keep the
        gap visible and tracked alongside the components that have
        runnable tests."""
        finding = (
            scenarios_dir
            / "commands"
            / "harness-init"
            / "FINDING-command-tdab-gap.md"
        )
        assert finding.exists(), (
            "Spike finding for harness-init must exist; the command-"
            "testing gap is the most consequential output of the spike."
        )

    def test_finding_declares_finding_tier(self, scenarios_dir):
        finding = parse_scenario(
            scenarios_dir
            / "commands"
            / "harness-init"
            / "FINDING-command-tdab-gap.md"
        )
        assert finding.tier == "finding", (
            "FINDING-prefixed scenarios must declare tier=finding "
            "so the runner does not attempt to dispatch them"
        )
