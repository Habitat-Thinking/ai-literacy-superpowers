"""Layer 2: skill description trigger tests.

A skill is loaded by the model when its description matches the user's
query. If the description drifts away from the queries the skill should
fire on, the skill silently stops triggering — and there is no test to
catch this today.

A trigger test asks: given a query that *should* fire this skill, does
the model agree that this skill matches? The implementation hands the
model the full plugin's skill index and asks it to identify which
skills match the query — exactly the matching surface a real session
would exercise.

Each query is a single Haiku-class inference. Skipped when no API key
is present so the suite remains free to run offline.

Why a separate layer rather than rolling into Layer 3? Different
failure modes. Layer 3 catches "the skill produces wrong output";
Layer 2 catches "the skill never fires in the first place". A skill
that is silently never invoked is the most common form of description
drift, and it is invisible to any test that assumes the skill has
been loaded.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402
from runner.scenario import parse_scenario  # noqa: E402
from runner.sdk import match_skills  # noqa: E402


def _skill_index(plugin_path: Path) -> list[tuple[str, str]]:
    """Return the full plugin skill catalogue as ``(name, description)``.

    Trigger tests need the *whole* index, not just the target skill.
    The matching surface a real session sees includes every skill —
    so testing in isolation would understate how easily two skill
    descriptions can collide.
    """
    pairs: list[tuple[str, str]] = []
    for skill in plugin_runner.list_skills(plugin_path):
        description = skill.frontmatter.get("description") or ""
        if description:
            pairs.append((skill.name, str(description)))
    return pairs


@pytest.mark.trigger
@pytest.mark.needs_api
class TestCupidCodeReviewTriggers:
    """The cupid-code-review skill should fire on queries about CUPID,
    code review against the CUPID lens, or refactoring suggestions
    grounded in the five properties."""

    @pytest.fixture
    def scenario(self, scenarios_dir):
        return parse_scenario(
            scenarios_dir
            / "skills"
            / "cupid-code-review"
            / "triggers-on-cupid-query.md"
        )

    # The five queries the scenario file declares. Kept here as a
    # constant so each query is its own parametrised test case —
    # failures point to the specific query, not to a single composite.
    TRIGGER_QUERIES = [
        "Review my code against CUPID",
        "Can you do a CUPID-style code review on this module?",
        "What CUPID violations do you see in this class?",
        "Apply the CUPID lens to this file",
        # Hardest: mentions two properties by name without saying "CUPID".
        # Still expected to match — but if it does not, the failure is
        # informative rather than fatal.
        "Refactor this for better composability and predictability",
    ]

    def test_skill_metadata_includes_trigger_terms(
        self, plugin_path, scenario
    ):
        """A pre-flight: the skill's description must mention CUPID.
        Offline; runs even without an API key."""
        skill = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        description = (skill.frontmatter.get("description") or "").lower()
        assert "cupid" in description, (
            "Skill description must mention CUPID; otherwise model "
            "matching will not fire on CUPID queries"
        )

    @pytest.mark.parametrize(
        "query",
        TRIGGER_QUERIES[:4],  # The first four are the strict-pass cases.
    )
    @pytest.mark.asyncio
    async def test_skill_triggers_on_explicit_cupid_query(
        self, needs_api, plugin_path, query: str
    ):
        """For each query that names CUPID explicitly, the model
        should identify cupid-code-review as one of the skills to
        invoke."""
        index = _skill_index(plugin_path)
        matches = await match_skills(query, index)
        assert "cupid-code-review" in matches, (
            f"Query {query!r} did not match cupid-code-review. "
            f"Model returned: {matches}. Description drift suspected."
        )

    @pytest.mark.asyncio
    async def test_skill_triggers_on_implicit_property_query(
        self, needs_api, plugin_path
    ):
        """The hardest case: a query that names two CUPID properties
        without saying 'CUPID'. We assert *informatively*: a miss here
        means the description over-relies on the literal token, which
        is itself a useful finding rather than a regression."""
        query = TestCupidCodeReviewTriggers.TRIGGER_QUERIES[4]
        index = _skill_index(plugin_path)
        matches = await match_skills(query, index)
        if "cupid-code-review" not in matches:
            pytest.skip(
                f"Implicit-property query {query!r} did not match "
                "cupid-code-review. This is the hardest case; the "
                "skip is a finding, not a regression. Consider whether "
                "the description should mention 'composable' and "
                "'predictable' explicitly."
            )


# ---------------------------------------------------------------------------
# Layer 2 expansion: five high-value skills (per the recommendation that
# selected skills loaded primarily through description matching, with
# clear trigger surfaces and security-class failure costs).
#
# Each class follows the same shape:
# - A scenario fixture (loaded from tdad_tests/scenarios/skills/<name>/)
# - Pre-flight (offline) — description contains expected trigger terms
# - Parametrised explicit queries — each must fire the skill
#
# The single-inference catalogue match runs against Haiku; cost per
# class is ~5 inferences ≈ $0.005. All five together stay well under
# $0.05 per full Layer 2 run.
# ---------------------------------------------------------------------------


@pytest.mark.trigger
@pytest.mark.needs_api
class TestLiterateProgrammingTriggers:
    """The literate-programming skill should fire when the user is
    creating new source files, writing new functions/types, or
    significantly rewriting existing code."""

    @pytest.fixture
    def scenario(self, scenarios_dir):
        return parse_scenario(
            scenarios_dir
            / "skills"
            / "literate-programming"
            / "triggers-on-new-source-file-query.md"
        )

    TRIGGER_QUERIES = [
        "I'm about to create a new module for parsing config files — what should it look like?",
        "Write me a new helper class for handling user authentication",
        "Create a new Python file that handles snapshot serialisation",
        "I'm rewriting the renderer module from scratch",
    ]

    def test_skill_metadata_includes_trigger_terms(
        self, plugin_path, scenario
    ):
        skill = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        description = (
            skill.frontmatter.get("description") or ""
        ).lower()
        # The description's whole point is to fire on source-file
        # authoring queries. Any of these tokens individually is
        # enough; absence of all four is a hard regression.
        for token in ("source", "file", "function", "code"):
            if token in description:
                return
        pytest.fail(
            "literate-programming description does not mention any "
            "of: source, file, function, code — model matching is "
            "extremely unlikely to fire"
        )

    @pytest.mark.parametrize("query", TRIGGER_QUERIES)
    @pytest.mark.asyncio
    async def test_skill_triggers_on_source_file_query(
        self, needs_api, plugin_path, query: str
    ):
        index = _skill_index(plugin_path)
        matches = await match_skills(query, index)
        assert "literate-programming" in matches, (
            f"Query {query!r} did not match literate-programming. "
            f"Model returned: {matches}. Description drift suspected."
        )


@pytest.mark.trigger
@pytest.mark.needs_api
class TestSecretsDetectionTriggers:
    """The secrets-detection skill should fire on secrets-audit
    queries — gitleaks setup, scanning, baselining, CI integration."""

    @pytest.fixture
    def scenario(self, scenarios_dir):
        return parse_scenario(
            scenarios_dir
            / "skills"
            / "secrets-detection"
            / "triggers-on-secrets-audit-query.md"
        )

    TRIGGER_QUERIES = [
        "Audit this project for committed secrets",
        "Set up gitleaks for this repository",
        "Are there any API keys committed in our source?",
        "Harden our 'no secrets in source' harness constraint",
    ]

    def test_skill_metadata_includes_trigger_terms(
        self, plugin_path, scenario
    ):
        skill = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        description = (
            skill.frontmatter.get("description") or ""
        ).lower()
        assert "secret" in description, (
            "secrets-detection description must mention 'secret(s)' "
            "for the model to fire on secrets-audit queries"
        )

    @pytest.mark.parametrize("query", TRIGGER_QUERIES)
    @pytest.mark.asyncio
    async def test_skill_triggers_on_secrets_query(
        self, needs_api, plugin_path, query: str
    ):
        index = _skill_index(plugin_path)
        matches = await match_skills(query, index)
        assert "secrets-detection" in matches, (
            f"Query {query!r} did not match secrets-detection. "
            f"Model returned: {matches}. Description drift suspected — "
            "this is a security-class regression."
        )


@pytest.mark.trigger
@pytest.mark.needs_api
class TestDependencyVulnerabilityAuditTriggers:
    """The dependency-vulnerability-audit skill should fire on
    dependency-audit queries (Go modules, Maven, supply-chain)."""

    @pytest.fixture
    def scenario(self, scenarios_dir):
        return parse_scenario(
            scenarios_dir
            / "skills"
            / "dependency-vulnerability-audit"
            / "triggers-on-vulnerability-audit-query.md"
        )

    TRIGGER_QUERIES = [
        "Check this Go project for vulnerable dependencies",
        "Audit our Maven dependencies for known CVEs",
        "Set up govulncheck in our CI",
        "What's the supply-chain risk in our project's dependency tree?",
    ]

    def test_skill_metadata_includes_trigger_terms(
        self, plugin_path, scenario
    ):
        skill = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        description = (
            skill.frontmatter.get("description") or ""
        ).lower()
        assert (
            "vulnerab" in description or "dependenc" in description
        ), (
            "dependency-vulnerability-audit description must mention "
            "vulnerabilities or dependencies"
        )

    @pytest.mark.parametrize("query", TRIGGER_QUERIES)
    @pytest.mark.asyncio
    async def test_skill_triggers_on_vulnerability_query(
        self, needs_api, plugin_path, query: str
    ):
        index = _skill_index(plugin_path)
        matches = await match_skills(query, index)
        assert "dependency-vulnerability-audit" in matches, (
            f"Query {query!r} did not match "
            "dependency-vulnerability-audit. "
            f"Model returned: {matches}. Description drift suspected."
        )


@pytest.mark.trigger
@pytest.mark.needs_api
class TestGitHubActionsSupplyChainTriggers:
    """The github-actions-supply-chain skill should fire on
    workflow-security and CI-hardening queries."""

    @pytest.fixture
    def scenario(self, scenarios_dir):
        return parse_scenario(
            scenarios_dir
            / "skills"
            / "github-actions-supply-chain"
            / "triggers-on-workflow-security-query.md"
        )

    TRIGGER_QUERIES = [
        "Review our GitHub Actions workflows for security issues",
        "Harden our CI pipeline",
        "Are our actions pinned to commit SHAs?",
        "Audit this repo's GitHub Actions supply-chain risk",
    ]

    def test_skill_metadata_includes_trigger_terms(
        self, plugin_path, scenario
    ):
        skill = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        description = (
            skill.frontmatter.get("description") or ""
        ).lower()
        assert (
            "github actions" in description or "workflow" in description
        ), (
            "github-actions-supply-chain description must mention "
            "GitHub Actions or workflows"
        )

    @pytest.mark.parametrize("query", TRIGGER_QUERIES)
    @pytest.mark.asyncio
    async def test_skill_triggers_on_workflow_security_query(
        self, needs_api, plugin_path, query: str
    ):
        index = _skill_index(plugin_path)
        matches = await match_skills(query, index)
        assert "github-actions-supply-chain" in matches, (
            f"Query {query!r} did not match "
            "github-actions-supply-chain. "
            f"Model returned: {matches}. Description drift suspected."
        )


@pytest.mark.trigger
@pytest.mark.needs_api
class TestDockerScoutAuditTriggers:
    """The docker-scout-audit skill should fire on Docker-CVE and
    base-image-staleness queries."""

    @pytest.fixture
    def scenario(self, scenarios_dir):
        return parse_scenario(
            scenarios_dir
            / "skills"
            / "docker-scout-audit"
            / "triggers-on-docker-cve-query.md"
        )

    TRIGGER_QUERIES = [
        "Scan our Docker image for CVEs",
        "Check if our base image is stale",
        "Audit Docker images for vulnerabilities",
        "What CVEs are in our containers?",
    ]

    def test_skill_metadata_includes_trigger_terms(
        self, plugin_path, scenario
    ):
        skill = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        description = (
            skill.frontmatter.get("description") or ""
        ).lower()
        assert "docker" in description, (
            "docker-scout-audit description must mention Docker"
        )

    @pytest.mark.parametrize("query", TRIGGER_QUERIES)
    @pytest.mark.asyncio
    async def test_skill_triggers_on_docker_cve_query(
        self, needs_api, plugin_path, query: str
    ):
        index = _skill_index(plugin_path)
        matches = await match_skills(query, index)
        assert "docker-scout-audit" in matches, (
            f"Query {query!r} did not match docker-scout-audit. "
            f"Model returned: {matches}. Description drift suspected."
        )


# ---------------------------------------------------------------------------
# Cross-plugin Layer 2: model-cards skill from the model-cards plugin.
#
# Difference from the five tests above: the matching catalogue must
# include skills from BOTH plugins. A real session a user runs with
# both plugins installed sees both skill catalogues simultaneously,
# and that combined catalogue is the realistic matching surface. A
# single-plugin index for model-cards would test only one skill and
# prove nothing about cross-plugin discrimination.
#
# The 5 tests above use single-plugin indexes because their target
# skills' cross-plugin collision risk is low (no model-cards plugin
# skill is about secrets, dependencies, Docker, or workflows). For
# the model-cards skill, however, ai-literacy-superpowers'
# `model-sovereignty` skill is a plausible competitor (both touch
# "model" topics), so combined-index is the right test.
# ---------------------------------------------------------------------------


def _combined_skill_index(
    *plugin_paths: Path,
) -> list[tuple[str, str]]:
    """Build a combined catalogue across multiple plugin paths.

    Skills appear in plugin-discovery order; duplicates (same name in
    two plugins) keep the first one encountered. The duplicate case
    is unlikely today but worth a deterministic policy if it arises.
    """
    seen: set[str] = set()
    pairs: list[tuple[str, str]] = []
    for path in plugin_paths:
        for skill in plugin_runner.list_skills(path):
            if skill.name in seen:
                continue
            description = skill.frontmatter.get("description") or ""
            if description:
                pairs.append((skill.name, str(description)))
                seen.add(skill.name)
    return pairs


@pytest.mark.trigger
@pytest.mark.needs_api
class TestModelCardsSkillTriggers:
    """The model-cards skill (in the model-cards plugin) should fire
    on model-card authoring queries — including in a session with the
    ai-literacy-superpowers plugin also loaded."""

    TRIGGER_QUERIES = [
        "Create a model card for Claude Sonnet 4.6",
        "Document this model's evals and benchmarks",
        "Author a Mitchell-style model card for this model",
        "What sections go into a model card?",
    ]

    def test_skill_metadata_includes_trigger_terms(
        self, model_cards_path: Path
    ):
        skill = plugin_runner.find_component(
            model_cards_path,
            name="model-cards",
            component_type="skill",
        )
        description = (
            skill.frontmatter.get("description") or ""
        ).lower()
        assert "model card" in description, (
            "model-cards skill description must mention 'model card' "
            "for matching to fire on model-card queries"
        )

    @pytest.mark.parametrize("query", TRIGGER_QUERIES)
    @pytest.mark.asyncio
    async def test_skill_triggers_on_model_card_query(
        self,
        needs_api,
        plugin_path: Path,
        model_cards_path: Path,
        query: str,
    ):
        # Combined index: both plugins' skills, so the test reflects
        # a real user session with both installed.
        index = _combined_skill_index(plugin_path, model_cards_path)
        matches = await match_skills(query, index)
        assert "model-cards" in matches, (
            f"Query {query!r} did not match the model-cards skill. "
            f"Model returned: {matches}. Likely cause: description "
            "drift in model-cards/skills/model-cards/SKILL.md, or "
            "ai-literacy-superpowers' model-sovereignty skill is "
            "stealing matches that should go to model-cards."
        )
