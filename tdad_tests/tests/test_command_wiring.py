"""Phase 1: command wiring tests.

Every slash command file in the plugin tells the model what to do —
typically by referencing other plugin components. ``/harness-init``
says "Dispatch the harness-discoverer agent." ``/assess`` says "Read
the ai-literacy-assessment skill before proceeding." These prose
references are how the command's behaviour is wired to the rest of
the plugin.

When a referenced agent or skill is renamed or removed, the
referencing command silently breaks. The model reads the prose, looks
for the named component, fails to find it, and falls back to whatever
guess it can construct. This is the rename-without-callsite-update
failure class — it is invisible to schema-style frontmatter checks
because the *frontmatter* is fine; the rot is in the body.

This test catches that failure at PR time. It walks every command
body, extracts the prose references that follow the project's
conventional shapes, and asserts each referent exists.

Why patterns rather than a parser? Because the references are written
in English. ``Dispatch the X agent`` is human prose, not structured
markup. Capturing the conventions the team actually uses (backticked
names; "and" lists for multi-skill references; path-style references
to ``skills/<name>``) catches the references most commands actually
make. False negatives — a reference written in some unconventional
phrasing — are acceptable: that is just an uncovered surface, not a
silent regression. False positives (matching "the agent" as if "the"
were an agent name) are worse, so the patterns are tight: backticked
names always count; un-backticked names must contain at least one
hyphen (the project's actual agent and skill names overwhelmingly do).

Phase 1 is one of the cheapest, highest-leverage tests in the suite.
It runs offline, in milliseconds, parametrised per command — failures
point at the specific command and the specific missing reference.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402


# The plugin path is fixed for parametrisation at collection time.
# Tests that need a fixture-resolved path use the ``plugin_path``
# fixture instead; this constant is purely for parametrize() ids.
_PLUGIN_PATH = (
    Path(__file__).resolve().parent.parent.parent / "ai-literacy-superpowers"
)


# Reference-extraction patterns. The patterns are layered so the
# multi-name forms run first — otherwise the single-name patterns
# would consume just the trailing name in "X and Y skills" and miss
# the leading one.
#
# Pattern shapes:
# - backticked name immediately before agent/agents/skill/skills
# - un-backticked hyphenated name immediately before the same words
# - "X and Y skills" form (captures both names from one match)
# - "skills/<name>" path-style reference
#
# Two correctness invariants the patterns enforce:
#
# 1. The hyphen requirement on un-backticked names stops "the agent"
#    and "any skill" from matching — common English words don't
#    contain hyphens, but every plugin agent and most plugin skills do.
#
# 2. The trailing keyword (agent / agents / skill / skills) must NOT
#    be followed by another hyphen. Without this, ``--add-topic
#    agent-harness-enabled`` matches as if "add-topic" were an agent
#    name, because ``agent-harness-enabled`` starts with the literal
#    token "agent" with hyphens being word boundaries. The negative
#    lookahead ``(?!-)`` on the trailing keyword rejects this case.
_PATTERNS_PER_KIND: dict[str, list[re.Pattern]] = {
    "skill": [
        # X and Y form must run before the single-name forms.
        re.compile(
            r"`([a-z][a-z0-9-]+)`\s+and\s+`([a-z][a-z0-9-]+)`\s+skills?\b(?!-)"
        ),
        re.compile(r"`([a-z][a-z0-9-]+)`\s+skills?\b(?!-)"),
        re.compile(r"\b([a-z][a-z0-9]*-[a-z][a-z0-9-]*)\s+skills?\b(?!-)"),
        re.compile(r"\bskills/([a-z][a-z0-9-]+)\b"),
    ],
    "agent": [
        re.compile(r"`([a-z][a-z0-9-]+)`\s+agents?\b(?!-)"),
        re.compile(r"\b([a-z][a-z0-9]*-[a-z][a-z0-9-]*)\s+agents?\b(?!-)"),
    ],
}


# Names that match the lexical patterns but are not real plugin
# components. The list is empty by intent — every entry would be a
# real false positive worth understanding before suppressing — and
# kept here as the documented escape hatch for genuine ambiguity if
# it surfaces. Today nothing needs to live here.
_KNOWN_FALSE_POSITIVES: dict[str, set[str]] = {
    "agent": set(),
    "skill": set(),
}


def extract_references(body: str) -> dict[str, set[str]]:
    """Extract agent and skill references from a command body.

    Returns a mapping ``{"agent": {name, ...}, "skill": {name, ...}}``.
    The returned set is the *deduplicated* set of names the command
    body claims to reference. Filtering against the plugin's actual
    component listing happens at the test layer, not here.
    """
    references: dict[str, set[str]] = {"agent": set(), "skill": set()}
    for kind, patterns in _PATTERNS_PER_KIND.items():
        for pattern in patterns:
            for match in pattern.finditer(body):
                for name in match.groups():
                    if name and name not in _KNOWN_FALSE_POSITIVES[kind]:
                        references[kind].add(name)
    return references


# Materialise the command list at collection time so pytest can
# generate one parametrised case per command. Falling back to a
# single failed case if discovery fails — preferable to silent
# zero-test runs.
def _commands_for_parametrize() -> list[plugin_runner.Component]:
    if not _PLUGIN_PATH.is_dir():
        return []
    return list(plugin_runner.list_commands(_PLUGIN_PATH))


_ALL_COMMANDS = _commands_for_parametrize()


@pytest.mark.structural
class TestCommandWiring:
    """Every command body must reference only real plugin components.

    These are pure structural / wiring checks — no LLM, no fixtures,
    no per-command setup beyond reading the file. They catch the
    rename-without-callsite-update class of failure at PR time, before
    the referencing command silently breaks for users.
    """

    def test_at_least_one_command_discovered(self):
        assert _ALL_COMMANDS, (
            "No commands discovered for parametrisation. "
            f"Plugin path searched: {_PLUGIN_PATH!r}"
        )

    @pytest.mark.parametrize(
        "command",
        _ALL_COMMANDS,
        ids=lambda command: command.name,
    )
    def test_command_references_resolve(
        self,
        command: plugin_runner.Component,
        plugin_path: Path,
    ):
        """Every agent/skill the command references must exist."""
        body = plugin_runner.read_component_body(command.path)
        refs = extract_references(body)

        agent_names = {c.name for c in plugin_runner.list_agents(plugin_path)}
        skill_names = {c.name for c in plugin_runner.list_skills(plugin_path)}

        missing_agents = refs["agent"] - agent_names
        missing_skills = refs["skill"] - skill_names

        if missing_agents or missing_skills:
            details: list[str] = []
            if missing_agents:
                details.append(
                    f"missing agents: {sorted(missing_agents)}"
                )
            if missing_skills:
                details.append(
                    f"missing skills: {sorted(missing_skills)}"
                )
            pytest.fail(
                f"Command /{command.name} references components that "
                f"do not exist. {'; '.join(details)}.\n"
                "Either the referenced component was renamed or removed "
                "without updating this command's callsite, or the "
                "command's prose phrasing falls outside the wiring "
                "test's pattern set (see _KNOWN_FALSE_POSITIVES in "
                "this file)."
            )


# ---------------------------------------------------------------------------
# Self-tests: confirm the extractor catches the conventional shapes and
# rejects the adversarial ones. These run regardless of plugin state and
# protect the wiring check itself from regressing if patterns are tuned.
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestExtractor:
    """The wiring check is only as good as its extractor; verify it."""

    def test_backticked_agent_reference(self):
        body = "Dispatch the `harness-discoverer` agent to scan."
        refs = extract_references(body)
        assert refs["agent"] == {"harness-discoverer"}

    def test_unbackticked_hyphenated_agent_reference(self):
        body = "Run the choice-cartographer agent against the spec."
        refs = extract_references(body)
        assert refs["agent"] == {"choice-cartographer"}

    def test_backticked_skill_reference(self):
        body = "Read the `convention-sync` skill from this plugin."
        refs = extract_references(body)
        assert refs["skill"] == {"convention-sync"}

    def test_x_and_y_skills_reference(self):
        body = (
            "Read the `harness-engineering` and `context-engineering` "
            "skills from this plugin before proceeding."
        )
        refs = extract_references(body)
        assert refs["skill"] == {
            "harness-engineering",
            "context-engineering",
        }

    def test_path_style_skill_reference(self):
        body = (
            "Read `${CLAUDE_PLUGIN_ROOT}/skills/convention-extraction/"
            "SKILL.md` for the full guidance."
        )
        refs = extract_references(body)
        assert "convention-extraction" in refs["skill"]

    def test_common_words_are_not_captured(self):
        # "the agent" and "any skill" appear in prose; the un-backticked
        # patterns require a hyphen, so common English words don't match.
        body = (
            "The agent reads the file. Any skill could in principle "
            "be loaded here."
        )
        refs = extract_references(body)
        assert refs["agent"] == set()
        assert refs["skill"] == set()

    def test_hyphenated_compound_starting_with_agent_is_rejected(self):
        # ``gh repo edit --add-topic agent-harness-enabled`` is the
        # canonical case from assess.md and harness-init.md. Before
        # the negative-lookahead invariant, the pattern matched
        # "add-topic" as if it were an agent name. With ``(?!-)`` on
        # the trailing keyword, it does not.
        body = "gh repo edit --add-topic agent-harness-enabled 2>/dev/null"
        refs = extract_references(body)
        assert refs["agent"] == set()
        assert refs["skill"] == set()

    def test_words_not_followed_by_agent_or_skill_are_ignored(self):
        # The patterns require the trailing token to be "agent",
        # "agents", "skill", or "skills". Hyphenated names followed by
        # any other word are ignored, which is the desired behaviour:
        # we only care about *references* to plugin components, not
        # mentions of hyphenated terms in general.
        body = "The architecture-decision pattern guides our choices."
        refs = extract_references(body)
        assert refs["agent"] == set()
        assert refs["skill"] == set()
