"""Layer 3: full behavioural tests via the Claude Agent SDK.

These tests dispatch the actual component (an agent's body as system
prompt with its declared tools, or a skill's body as context) against a
fixture, capture observable outputs, and assert behaviour. This is TDAB
proper.

Layer 3 is the expensive layer. Each test is a full SDK invocation,
sometimes multi-turn, against a generation-class model. The suite is
gated on ``ANTHROPIC_API_KEY`` and the tests still skip gracefully
without one — so contributors can run Layer 1 freely and Layer 3 only
when they mean to.

Structural sub-tests (scenario validity, fixture existence, finding
files in place) run offline. They protect the Layer 3 surface from the
silent failure mode where a behavioural test passes because its
fixture has been deleted or its scenario silently no-ops.

Why a rubric step on Layer 3? Because the assertions a behavioural
test wants to make about LLM-generated text resist exact match. "Does
this review name at least three methods from the fixture?" is a
boolean — but evaluating it is itself a small inference. LLM-as-judge
makes that step explicit and reproducible.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402
from runner.scenario import parse_scenario  # noqa: E402
from runner.sdk import grade_with_rubric, invoke_agent  # noqa: E402


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

    @pytest.fixture
    def empty_repo(self, tmp_path: Path) -> Path:
        """A minimal fixture repository the agent runs in. CLAUDE.md
        and AGENTS.md exist as the agent's first action expects to
        read them, but they are deliberately minimal so the agent
        produces a spec from the user message rather than from
        accumulated repo conventions."""
        (tmp_path / "CLAUDE.md").write_text(
            "# Project conventions\n\n"
            "Spec-first discipline: every feature begins with a "
            "spec in `specs/<feature>/spec.md`.\n",
            encoding="utf-8",
        )
        (tmp_path / "AGENTS.md").write_text(
            "# Compound learning\n\n"
            "(Empty — fresh project; this fixture has no prior "
            "patterns or gotchas to surface.)\n",
            encoding="utf-8",
        )
        return tmp_path

    def test_scenario_loads(self, scenario):
        """A precondition: the scenario must be loadable and complete.

        Offline; runs even without an API key — ensures the scenario
        file remains valid as the spec-writer agent evolves.
        """
        assert scenario.component == "spec-writer"
        assert scenario.component_type == "agent"
        assert scenario.tier == "behavioural"
        for required in ("Given", "When", "Then"):
            assert required in scenario.sections, (
                f"spec-writer scenario missing '{required}' section"
            )

    @pytest.mark.asyncio
    async def test_spec_writer_produces_required_sections(
        self,
        needs_api,
        plugin_path,
        scenario,
        empty_repo: Path,
    ):
        """Layer 3 proper: dispatch the spec-writer agent against an
        empty repo and assert the resulting spec.md."""
        agent = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        body = plugin_runner.read_component_body(agent.path)

        # The agent's tool list comes from its frontmatter — typically
        # Read, Write, Edit, Glob, Grep. Falling back to a safe
        # superset if the frontmatter parse was lenient.
        tools = list(agent.frontmatter.get("tools") or [])
        if not tools:
            tools = ["Read", "Write", "Edit", "Glob", "Grep"]

        user_message = (
            "Add a spec for user authentication. The feature must "
            "support email-and-password login with rate-limited "
            "login attempts. Write the spec to specs/auth/spec.md."
        )

        result = await invoke_agent(
            system_prompt=body,
            allowed_tools=tools,
            user_message=user_message,
            cwd=empty_repo,
        )

        spec_path = empty_repo / "specs" / "auth" / "spec.md"
        assert spec_path.exists(), (
            f"spec-writer did not create {spec_path.relative_to(empty_repo)}. "
            f"Tool uses recorded: {[u['tool'] for u in result.tool_uses]!r}"
        )

        spec = spec_path.read_text(encoding="utf-8").lower()

        # Heuristic structural assertions — the spec format the
        # scenario describes. Assertions are intentionally tolerant
        # of variation in heading text but strict on the underlying
        # structure (story, scenarios, FRs).
        assert "user stor" in spec, (
            "spec.md should contain a User Story section"
        )
        assert "given" in spec and "when" in spec and "then" in spec, (
            "spec.md should contain acceptance scenarios in "
            "Given/When/Then format"
        )
        assert "fr-" in spec or "fr-001" in spec or "functional requirement" in spec, (
            "spec.md should contain numbered functional requirements"
        )
        # Rate-limiting is the single most likely thing to be missed.
        assert "rate" in spec or "limit" in spec or "throttle" in spec, (
            "spec.md should mention rate-limiting (a key requirement "
            "in the user message that easily gets omitted)"
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
        """Offline precondition: the violation code must be present."""
        text = violation_fixture.read_text(encoding="utf-8")
        assert text, "CUPID violation fixture is empty"
        assert "class" in text, (
            "CUPID violation fixture should contain at least one class"
        )

    @pytest.mark.asyncio
    async def test_skill_identifies_cupid_violations(
        self,
        needs_api,
        plugin_path,
        scenario,
        violation_fixture: Path,
        tmp_path: Path,
    ):
        """Layer 3 proper: load the skill into a session, feed it the
        fixture, rubric-grade the response."""
        skill = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        skill_body = plugin_runner.read_component_body(skill.path)
        fixture_code = violation_fixture.read_text(encoding="utf-8")

        # We splice the skill body into the system prompt rather than
        # relying on the SDK's filesystem-based skill loading. This
        # decouples the test from any skill-loading mechanics that
        # vary between SDK versions and Claude Code itself — what we
        # are exercising is "given the skill's content as context,
        # does it produce a useful review?"
        system_prompt = (
            "You are a code reviewer. The following SKILL describes "
            "the lens you should apply to any code under review.\n\n"
            "=== SKILL: cupid-code-review ===\n"
            f"{skill_body}\n"
            "=== END SKILL ===\n"
        )
        user_message = (
            "Please apply the CUPID lens to this Python file and "
            "identify the most significant violations of each "
            "property. Reference specific methods and attributes "
            "from the code in your review.\n\n"
            "```python\n"
            f"{fixture_code}\n"
            "```"
        )

        result = await invoke_agent(
            system_prompt=system_prompt,
            allowed_tools=[],
            user_message=user_message,
            # No filesystem state to persist; tmp_path is just somewhere
            # safe to anchor the cwd.
            cwd=tmp_path,
        )

        # Rubric: three pass/fail criteria, mirroring the scenario.
        # Pass requires 3 of 3; 2 of 3 is amber; ≤1 is fail.
        criteria = [
            "The review references at least three named methods or "
            "attributes from the fixture (e.g. UserManager, get_user, "
            "runSqlQuery, flushBuffer, audit_buffer, authenticate, "
            "emailUser).",
            "The review names at least four of the five CUPID "
            "properties (Composable, Unix philosophy, Predictable, "
            "Idiomatic, Domain-based).",
            "The review proposes at least one concrete refactoring "
            "step grounded in the fixture code (extract dependency, "
            "rename method, split class, etc.) — not a generic "
            "principle reference.",
        ]
        verdicts = await grade_with_rubric(result.response_text, criteria)
        passed = sum(1 for v in verdicts.values() if v)

        # Hard fail at ≤1; soft fail (skip) at 2; pass at 3.
        if passed >= 3:
            return  # pass
        if passed == 2:
            pytest.skip(
                f"Amber: 2 of 3 rubric criteria passed.\n"
                f"Verdicts: {verdicts}\n\n"
                "Investigate but do not block. The review may have "
                "been too generic in one dimension."
            )
        pytest.fail(
            f"Only {passed} of 3 rubric criteria passed.\n"
            f"Verdicts: {verdicts}\n\n"
            f"Review:\n{result.response_text[:800]}..."
        )


@pytest.mark.behavioural
class TestHarnessInitCommandFinding:
    """The harness-init command surfaces the spike's biggest finding:
    slash commands do not have a clean SDK invocation path. The
    architectural question is documented in the scenario folder and
    in issue #284."""

    def test_finding_scenario_exists(self, scenarios_dir):
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
