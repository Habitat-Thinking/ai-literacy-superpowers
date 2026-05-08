"""Layer 2: skill description trigger tests.

A skill is loaded by the model when its description matches the user's
query. If the description drifts away from the queries the skill should
fire on, the skill silently stops triggering — and there is no test to
catch this today.

A trigger test asks: given a query that *should* fire this skill, does
the model agree that this skill matches? The implementation is a single
inference: hand the model a list of skill descriptions and a query, ask
it to identify which skills match, and assert that the target skill is
in the response.

These tests cost a single API call each. They are skipped when no API
key is present so the suite remains free to run in offline contexts.

Why a separate layer rather than rolling into Layer 3? Because the
failure modes are different. Layer 3 catches "the skill produces wrong
output". Layer 2 catches "the skill never fires in the first place".
A skill that is silently never invoked is the most common form of
description drift, and it is invisible to any test that assumes the
skill has been loaded.

Implementation note: the spike wires up the test structure but defers
the live SDK invocation to a follow-up. The TODO is explicit and the
test is marked ``skip`` until a runner is implemented. This keeps Layer
1 green and the architectural shape visible, while honouring spike cost
discipline.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402
from runner.scenario import parse_scenario  # noqa: E402


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

    def test_skill_metadata_includes_trigger_terms(
        self, plugin_path, scenario
    ):
        """A pre-flight: the skill's description should contain at
        least one of the queries the scenario expects to match. This
        is a structural check that does not need the API but does
        depend on the scenario being declared.
        """
        skill = plugin_runner.find_component(
            plugin_path,
            name=scenario.component,
            component_type=scenario.component_type,
        )
        description = (skill.frontmatter.get("description") or "").lower()
        # The scenario lists expected trigger queries in its 'When'
        # section as a bullet list. We do not require an exact textual
        # match — just that at least one substantive trigger word
        # appears in the description.
        triggers = scenario.sections.get("When", "").lower()
        assert "cupid" in triggers, (
            "Trigger scenario must mention CUPID (the skill's defining concept)"
        )
        assert "cupid" in description, (
            "Skill description must mention CUPID; otherwise model "
            "matching will not fire on CUPID queries"
        )

    def test_skill_triggers_via_sdk(self, needs_api, scenario):
        """Layer 2 proper: dispatch a query to the SDK with the
        plugin's skill descriptions loaded, and assert the model
        identifies cupid-code-review as a match.

        Wired but not yet implemented — the SDK invocation pattern is
        documented in the scenario file and will be filled in when the
        spike is promoted out of spike status. Marked skip rather than
        xfail so it shows up as 'pending implementation' rather than
        'expected to fail'.
        """
        pytest.skip(
            "SDK trigger-runner pending implementation; see "
            "scenarios/skills/cupid-code-review/triggers-on-cupid-query.md"
        )
