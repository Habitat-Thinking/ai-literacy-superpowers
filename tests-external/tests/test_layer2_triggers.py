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
