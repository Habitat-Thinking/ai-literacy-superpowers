"""Layer 1: structural tests for the plugin and the scenario corpus.

These tests run offline. They assert facts about the plugin's component
files (frontmatter present, required keys filled) and about the scenario
files in this suite (frontmatter present, target component exists, tier
declared). No model calls. No network. Free.

Why include scenario-validity checks at Layer 1 rather than only
plugin-component checks? Because a scenario that points at a missing
component is an unverified test — it would pass by skipping silently and
nobody would notice. Structural checks on the scenarios themselves are
the meta-defence against that drift: every scenario must reference a
component that actually exists, and every component targeted by Layer 2
or Layer 3 must have a corresponding scenario file.

The plugin-wide parametrised checks deliberately walk *every* component
in the inventory, not just the three the spike targets. The point of
Layer 1 is to be fast enough to run on every PR — and broad enough that
a structural regression anywhere in the plugin is caught the moment it
lands.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

# Make the runner package importable when pytest is invoked from the
# tests-external/ directory without an editable install.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402
from runner.scenario import list_scenarios  # noqa: E402


# ---------------------------------------------------------------------------
# Plugin-wide structural checks (parametrised over every component)
# ---------------------------------------------------------------------------


def _all_components(plugin_path: Path):
    """Iterate every plugin component for parametrisation."""
    yield from plugin_runner.list_agents(plugin_path)
    yield from plugin_runner.list_skills(plugin_path)
    yield from plugin_runner.list_commands(plugin_path)


def _component_id(component) -> str:
    return f"{component.component_type}:{component.name}"


@pytest.mark.structural
class TestPluginComponents:
    """Every agent, skill, and command must have well-formed frontmatter.

    "Well-formed" here means: enumerable, named, described. Strict YAML
    compliance is checked separately (``TestFrontmatterStrictYaml``)
    because the plugin's existing agent files use a Claude-Code-specific
    convention with embedded ``<example>`` blocks that strict YAML
    rejects but the Claude Code loader accepts.
    """

    def test_at_least_one_agent_exists(self, plugin_path):
        agents = list(plugin_runner.list_agents(plugin_path))
        assert agents, "Plugin has no agents — packaging regression"

    def test_at_least_one_skill_exists(self, plugin_path):
        skills = list(plugin_runner.list_skills(plugin_path))
        assert skills, "Plugin has no skills — packaging regression"

    def test_at_least_one_command_exists(self, plugin_path):
        commands = list(plugin_runner.list_commands(plugin_path))
        assert commands, "Plugin has no commands — packaging regression"

    def test_every_component_has_a_name(self, plugin_path):
        """Every component's frontmatter must carry an explicit ``name``.

        Falls back to regex extraction if strict YAML fails — the test
        is asserting "the field is declared in the file", not "the
        whole file is strict YAML".
        """
        missing = [
            _component_id(c)
            for c in _all_components(plugin_path)
            if not c.frontmatter.get("name")
        ]
        assert not missing, (
            f"Components missing 'name' in frontmatter: {missing}. "
            "Every plugin component must declare its identity in YAML."
        )

    def test_every_component_has_a_description(self, plugin_path):
        """Descriptions are how skills are matched and how commands surface
        in autocomplete. A missing description is silent breakage.
        """
        missing = [
            _component_id(c)
            for c in _all_components(plugin_path)
            if not c.frontmatter.get("description")
        ]
        assert not missing, (
            f"Components missing 'description' in frontmatter: {missing}"
        )

    def test_every_skill_has_skill_md(self, plugin_path):
        """A skill directory without a SKILL.md is a broken skill."""
        broken = [
            c.name
            for c in plugin_runner.list_skills(plugin_path)
            if not c.path.exists()
        ]
        assert not broken, (
            f"Skills missing SKILL.md: {broken}. "
            "Skill directories must contain a SKILL.md file."
        )


@pytest.mark.structural
class TestFrontmatterStrictYaml:
    """Surface (but do not block on) strict-YAML parse failures.

    The plugin currently includes agent files whose frontmatter contains
    embedded ``<example>`` blocks — a Claude Code documentation
    convention that strict PyYAML cannot parse. This test reports those
    files as a finding without failing the suite, so the architectural
    question stays visible: does the plugin standardise on strict YAML
    (block scalars, quoted multi-line values) or does the test runner
    adopt the lenient parser the Claude Code loader uses?

    Reporting (not failing) is the right call for the spike. A
    follow-up PR can either fix the frontmatter or formally accept the
    convention; either way, the test layer documents the gap rather
    than hiding it.
    """

    def test_report_parse_errors(self, plugin_path):
        components_with_errors = [
            (_component_id(c), c.parse_error)
            for c in _all_components(plugin_path)
            if c.parse_error
        ]
        if components_with_errors:
            # Print the finding loudly so it appears in pytest output
            # even though the test passes. ``capsys``-style capture
            # would hide it; a pytest skip with reason makes it
            # visible in -v output.
            lines = ["Frontmatter parse errors (non-blocking finding):"]
            for cid, err in components_with_errors:
                lines.append(f"  - {cid}: {err}")
            lines.append(
                "These are recoverable via the fallback parser. "
                "See FINDING-frontmatter-yaml-strictness in the "
                "scenarios folder for the architectural question."
            )
            pytest.skip("\n".join(lines))


# ---------------------------------------------------------------------------
# Component-specific checks for the three spike targets
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestSpikeTargets:
    """The three components the spike targets must each be locatable and
    well-formed. These are tightly coupled to the scenarios below."""

    def test_spec_writer_agent_exists(self, plugin_path):
        component = plugin_runner.find_component(
            plugin_path, name="spec-writer", component_type="agent"
        )
        assert component.frontmatter.get("description"), (
            "spec-writer agent must declare a description"
        )
        # Agents declare which tools they may invoke. spec-writer's
        # discipline is read-and-write of spec/plan files, so it must
        # have at least Read and Write available.
        tools = component.frontmatter.get("tools") or []
        assert "Read" in tools and "Write" in tools, (
            f"spec-writer must declare Read and Write tools; got {tools!r}"
        )

    def test_cupid_code_review_skill_exists(self, plugin_path):
        component = plugin_runner.find_component(
            plugin_path, name="cupid-code-review", component_type="skill"
        )
        description = component.frontmatter.get("description") or ""
        # The description is what the model uses to decide whether to
        # invoke the skill. It must mention the trigger surface.
        assert "CUPID" in description or "cupid" in description.lower(), (
            "cupid-code-review skill description must mention CUPID"
        )

    def test_harness_init_command_exists(self, plugin_path):
        component = plugin_runner.find_component(
            plugin_path, name="harness-init", component_type="command"
        )
        assert component.frontmatter.get("description"), (
            "harness-init command must declare a description"
        )


# ---------------------------------------------------------------------------
# Scenario-corpus structural checks
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestScenarioCorpus:
    """Every scenario file must be parseable and must point at an
    existing component."""

    def test_every_scenario_parses(self, scenarios_dir):
        # Just calling list_scenarios is the test — it raises
        # ValueError on malformed frontmatter, which pytest reports as
        # a failure with the specific scenario path attached.
        scenarios = list_scenarios(scenarios_dir)
        assert scenarios, (
            "No scenarios found. The spike expects at least one "
            "scenario per spike target."
        )

    def test_every_scenario_targets_an_existing_component(
        self,
        scenarios_dir,
        plugin_path,
    ):
        """A scenario that targets a missing component is an unverified
        test — it would silently never run."""
        scenarios = list_scenarios(scenarios_dir)
        broken = []
        for scenario in scenarios:
            try:
                plugin_runner.find_component(
                    plugin_path,
                    name=scenario.component,
                    component_type=scenario.component_type,
                )
            except (LookupError, ValueError) as exc:
                broken.append(f"{scenario.path.name}: {exc}")
        assert not broken, (
            "Scenarios pointing at missing components:\n  - "
            + "\n  - ".join(broken)
        )

    def test_every_scenario_declares_a_tier(self, scenarios_dir):
        scenarios = list_scenarios(scenarios_dir)
        valid_tiers = {"structural", "trigger", "behavioural", "finding"}
        wrong_tier = [
            f"{s.path.name}: tier={s.tier!r}"
            for s in scenarios
            if s.tier not in valid_tiers
        ]
        assert not wrong_tier, (
            "Scenarios with missing or invalid tier "
            f"(must be one of {sorted(valid_tiers)}):\n  - "
            + "\n  - ".join(wrong_tier)
        )

    def test_each_spike_target_has_a_scenario(self, scenarios_dir):
        """The three spike targets must each have at least one scenario.

        This is the meta-rule that prevents the suite from drifting
        away from its declared scope: if someone removes the spec-writer
        scenario, the spike is no longer testing what it claims to.
        """
        scenarios = list_scenarios(scenarios_dir)
        targets = {
            ("spec-writer", "agent"),
            ("cupid-code-review", "skill"),
            ("harness-init", "command"),
        }
        present = {(s.component, s.component_type) for s in scenarios}
        missing = targets - present
        assert not missing, (
            f"Spike targets missing scenarios: {sorted(missing)}"
        )
