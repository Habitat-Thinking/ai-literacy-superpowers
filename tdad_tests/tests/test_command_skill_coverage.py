"""Phase 4 — M-command skill-coverage matrix.

Model-mediated (M) commands derive their substantive behaviour from
their driving skill. ``/assess`` reads the ``ai-literacy-assessment``
skill before proceeding; ``/extract-conventions`` reads the
``convention-extraction`` skill; ``/governance-constrain`` reads the
``governance-constraint-design`` skill. The skill encodes the actual
methodology; the command's prose is the conversational shell that
loads the skill at the right time.

This makes M commands fragile in a specific way: if the driving
skill is renamed, refactored, or split without updating the
referencing command, the command's prose still reads (Phase 1 may
not catch it if the rename split into two skills, both of which
exist), but the command no longer loads the methodology it was
supposed to load. The user gets a guided session driven by whatever
the model improvises in the absence of the missing skill.

This test catches that. It mirrors Phase 3's dispatch-matrix shape
for the skill-driven layer:

- Phase 1 catches "skill reference is broken" (passive — fails when
  the named skill no longer exists).
- Phase 4 catches "M command was supposed to load Y skill and no
  longer does" (active — fails when an expected reference is
  missing, even if the command's prose still parses cleanly).

The two tests have orthogonal coverage. Both belong.

Per the design spec (`docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md`),
Layer 3 behavioural tests of M-command driving skills are the
high-cost, case-by-case follow-up — only worth investing in for
specific skills with assertable side-effects (the ``cupid-code-review``
test in PR #285 is the canonical pattern; ``harness-onboarding`` is a
candidate because it produces an ONBOARDING.md). Those Layer 3 tests
are *not* part of this Phase 4 spike — Phase 4's contribution is the
cheap-and-immediate skill-coverage matrix.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402


# Each entry is ``(command_name, expected_skills)``. The command body
# must reference each named skill — either as a backticked name
# followed by " skill" or " skills", or as a path-style ``skills/<name>``
# reference.
#
# These mappings are derived from the actual command bodies as of
# 2026-05-09. When a command's prose adds or removes a skill load,
# this matrix must be updated alongside the prose change — that is
# the contract this test enforces.
M_COMMAND_SKILL_MATRIX: list[tuple[str, list[str]]] = [
    # /assess uses two skills: the assessment methodology, and the
    # literacy-improvements skill that turns a level into a
    # prioritised improvement plan.
    ("assess", ["ai-literacy-assessment", "literacy-improvements"]),
    # /portfolio-assess aggregates per-repo assessments through the
    # portfolio-assessment skill's discovery and aggregation logic.
    ("portfolio-assess", ["portfolio-assessment"]),
    # /extract-conventions uses convention-extraction (referenced
    # path-style: ``skills/convention-extraction/SKILL.md``).
    ("extract-conventions", ["convention-extraction"]),
    # /harness-constrain has two driving skills: constraint-design
    # for the design framework and verification-slots for the
    # technical reference. Both must be loaded.
    ("harness-constrain", ["constraint-design", "verification-slots"]),
    # /governance-constrain uses the governance-constraint-design
    # skill for the three-frame translation methodology.
    ("governance-constrain", ["governance-constraint-design"]),
    # /harness-gc uses garbage-collection for the GC catalogue and
    # auto-fix safety rubric.
    ("harness-gc", ["garbage-collection"]),
    # /harness-onboarding uses a same-named skill (matched against
    # the skill at skills/harness-onboarding/SKILL.md, not the
    # command at commands/harness-onboarding.md — those are different
    # plugin components).
    ("harness-onboarding", ["harness-onboarding"]),
]


_PLUGIN_PATH = (
    Path(__file__).resolve().parent.parent.parent / "ai-literacy-superpowers"
)


def _command_body(command_name: str) -> str:
    """Read the body of an M command for matching."""
    component = plugin_runner.find_component(
        _PLUGIN_PATH, name=command_name, component_type="command"
    )
    return plugin_runner.read_component_body(component.path)


def _skill_load_present(body: str, skill_name: str) -> bool:
    """Whether the body contains a load-bearing reference to a skill.

    Accepts both backticked and path-style references — the project
    uses both forms across M commands. ``\\b`` word-boundary anchors
    plus a negative lookahead on hyphen prevent false positives like
    ``foo`` matching ``foo-bar`` because ``-`` is a regex word
    boundary.
    """
    backticked = re.compile(
        rf"`{re.escape(skill_name)}`\s+skills?\b(?!-)"
    )
    path_style = re.compile(
        rf"\bskills/{re.escape(skill_name)}\b"
    )
    # Also accept the "Read the X and Y skills" plural form when the
    # named skill appears as either token.
    multi_form = re.compile(
        rf"`[a-z][a-z0-9-]+`\s+and\s+`{re.escape(skill_name)}`\s+skills?\b(?!-)"
    )
    multi_form_first = re.compile(
        rf"`{re.escape(skill_name)}`\s+and\s+`[a-z][a-z0-9-]+`\s+skills?\b(?!-)"
    )
    return bool(
        backticked.search(body)
        or path_style.search(body)
        or multi_form.search(body)
        or multi_form_first.search(body)
    )


@pytest.mark.structural
class TestMCommandSkillCoverage:
    """Each M command must load the specific skills it declares as
    its driving methodology."""

    @pytest.mark.parametrize(
        "command_name,expected_skills",
        M_COMMAND_SKILL_MATRIX,
        ids=lambda v: v if isinstance(v, str) else "",
    )
    def test_command_loads_expected_skills(
        self,
        command_name: str,
        expected_skills: list[str],
    ):
        body = _command_body(command_name)

        missing = [
            skill
            for skill in expected_skills
            if not _skill_load_present(body, skill)
        ]
        if missing:
            pytest.fail(
                f"Command /{command_name} no longer loads the skill(s) "
                f"it is expected to: {missing}.\n"
                "Either the load-bearing skill reference was removed in "
                "a refactor (a regression — the command will fall back "
                "to whatever the model improvises in the absence of the "
                "skill) or the matrix in this test file is out of date "
                "and should be updated alongside the prose change."
            )


@pytest.mark.structural
class TestMatrixCoverage:
    """The matrix itself must be coherent — every skill it references
    must exist; every command must exist."""

    def test_every_referenced_skill_exists(self):
        skill_names = {
            c.name for c in plugin_runner.list_skills(_PLUGIN_PATH)
        }
        broken: list[str] = []
        for cmd, skills in M_COMMAND_SKILL_MATRIX:
            for skill in skills:
                if skill not in skill_names:
                    broken.append(
                        f"{cmd} expects nonexistent skill {skill!r}"
                    )
        assert not broken, (
            "Matrix references missing skills: " + str(broken)
        )

    def test_every_named_command_exists(self):
        command_names = {
            c.name for c in plugin_runner.list_commands(_PLUGIN_PATH)
        }
        missing = [
            cmd
            for cmd, _ in M_COMMAND_SKILL_MATRIX
            if cmd not in command_names
        ]
        assert not missing, (
            f"Matrix names commands that no longer exist: {missing}"
        )

    def test_matrix_covers_every_m_command(self):
        """The 7 M commands documented in the design spec
        (``docs/superpowers/specs/2026-05-09-command-tdad-testing-design.md``)
        should all appear in the matrix. If a new M command lands or
        an existing one is reclassified, the matrix should be updated
        deliberately — this test surfaces the drift if it isn't.

        The expected-set is hand-maintained alongside the spec's
        category §3 listing. Edit-with-care: changing this list means
        the design spec also needs updating.
        """
        expected_m_commands = {
            "assess",
            "portfolio-assess",
            "extract-conventions",
            "harness-constrain",
            "governance-constrain",
            "harness-gc",
            "harness-onboarding",
        }
        matrix_commands = {cmd for cmd, _ in M_COMMAND_SKILL_MATRIX}
        missing_from_matrix = expected_m_commands - matrix_commands
        unexpected_in_matrix = matrix_commands - expected_m_commands
        assert not missing_from_matrix, (
            "M commands missing from skill-coverage matrix: "
            f"{sorted(missing_from_matrix)}"
        )
        assert not unexpected_in_matrix, (
            "Matrix contains commands not classified as M in design spec: "
            f"{sorted(unexpected_in_matrix)}"
        )
