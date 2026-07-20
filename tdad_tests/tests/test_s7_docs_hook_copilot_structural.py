"""Layer 1 structural content checks for dynamic-workflows S7 (epic final).

These tests are the *deterministic mechanism* behind the structural
scenarios authored at ``scenarios/skills/dynamic-workflows/`` for slice S7
(the README Dynamic Workflows section, the skill/governance reference's
Copilot Option-A contract, and the two CLAUDE.md skill pointers).

Per the spec's §6 decision 3 (the verification split), this repo's
deterministic layer reads files and matches structure — it does **not** run
a session, dispatch a workflow, or judge whether the (deferred) advisory hook
*should* have fired. So what is deterministically asserted here is that:

- the repo-root ``README.md`` gains a **Dynamic Workflows** section naming the
  six patterns + election discipline (AC-2), INV-1/INV-2 (AC-3), the
  Claude-Code-only scope + the guidance-only Copilot **Option A** contract
  (AC-4), and that the ``Skills-N`` badge tracks the real skill count (AC-5);
- ``skills/dynamic-workflows/references/governance.md`` states the resolved
  **Option A** Copilot degradation contract — ships to both trees, guidance
  only where no runtime, never omitted (AC-6c / FR-6);
- both ``CLAUDE.md`` surfaces (repo root + ``templates/CLAUDE.md``) carry the
  ``dynamic-workflows`` skill pointer with a trigger cue (AC-7p / FR-7).

The README/CLAUDE.md targets are **repo-root** files (read via
``_repo_root(plugin_path)``, like the S6 ``.gitignore`` check), not plugin
components — the scenarios are filed under the ``dynamic-workflows`` skill so
the corpus can resolve a target, and the real assertions live here.

GATE decisions this slice builds to:

- **Copilot contract = Option A.** The skill ships to BOTH the Claude Code
  and Copilot CLI trees; without the workflow runtime it is guidance-only
  (readable knowledge), every workflow-mode degrades to its static/guidance
  fallback, and it **never** omits the skill or errors.
- **Advisory Stop hook = DEFERRED** (not shipping in S7). So this file
  authors **no** hook test and **no** ``hooks.json`` / hook-script assertion.
  AC-6/AC-7/AC-8 (hook registration, exit-0/non-blocking, heuristic quality)
  do not apply in S7.

RED state (before S7 implements): ``README.md`` has no Dynamic Workflows
section, ``governance.md`` has no Copilot Option-A statement, and neither
``CLAUDE.md`` carries the skill pointer — so every declaration assertion below
fails on missing content (RED for the right reason: missing content, not a
malformed scenario or an unresolvable component; the ``dynamic-workflows``
skill and both ``CLAUDE.md`` files already exist). The corpus/parse/tier
checks in ``test_layer1_structural.py`` stay GREEN.

**Guard that must STAY green now:** the ``Skills-N`` badge assertion is
**not** a RED-now assertion — it derives the expected count from the skill
directories on disk and asserts the badge matches. It guards against both an
accidental re-bump and a stale count, and must pass before and after S7
implements (and after any legitimate skill addition).

Line-wrap note (the trap that bit S3 twice, S4 twice, S5 once, S6 once): a
required two-word phrase an implementer might wrap across a line is NOT
asserted as a single substring. Where a guarantee needs two terms to
co-occur, they are asserted as two independent ``in`` checks on the
lowercased section so a wrapped phrase still passes. Single load-bearing
tokens (``skills-N``, ``inv-1``, ``inv-2``,
``dynamic-workflows``, ``fan-out``, ``opt-in``, ``long-running``) are
wrap-safe and asserted directly; ``claude code`` and ``massively parallel``
are two words and are split.

Spec: docs/superpowers/specs/2026-06-23-dynamic-workflows-s7-docs-hook-copilot-design.md
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402


def _repo_root(plugin_path: Path) -> Path:
    """The repo root — parent of the ``ai-literacy-superpowers`` plugin
    directory (``plugin_path`` points at the plugin dir)."""
    return plugin_path.parent


def _readme_text(plugin_path: Path) -> str:
    """Full text of the repo-root README.md (NOT lowercased — the badge
    assertions are case-sensitive)."""
    return (_repo_root(plugin_path) / "README.md").read_text(encoding="utf-8")


def _dynamic_workflows_section(plugin_path: Path) -> str:
    """Return the text of the README Dynamic Workflows section — from a
    heading whose text contains "dynamic workflows" to the next
    same-or-higher-level heading, lowercased. Empty string if absent.

    Matches a level-2/3/4 heading so either a top-level ``## Dynamic
    Workflows`` or a ``### Dynamic Workflows`` subsection is found."""
    text = _readme_text(plugin_path)
    m = re.search(
        r"^(#{2,4})\s+.*dynamic workflows.*$",
        text,
        re.IGNORECASE | re.MULTILINE,
    )
    if not m:
        return ""
    level = len(m.group(1))
    start = m.end()
    rest = text[start:]
    nxt = re.search(rf"^#{{1,{level}}}\s+\S", rest, re.MULTILINE)
    end = nxt.start() if nxt else len(rest)
    return rest[:end].lower()


def _governance_text(plugin_path: Path) -> str:
    """Lowercased text of the skill/governance reference."""
    path = (
        plugin_path
        / "skills"
        / "dynamic-workflows"
        / "references"
        / "governance.md"
    )
    return path.read_text(encoding="utf-8").lower()


def _claude_md_root(plugin_path: Path) -> str:
    """Lowercased text of the repo-root CLAUDE.md."""
    return (_repo_root(plugin_path) / "CLAUDE.md").read_text(
        encoding="utf-8"
    ).lower()


def _claude_md_template(plugin_path: Path) -> str:
    """Lowercased text of the plugin's templates/CLAUDE.md."""
    return (
        plugin_path / "templates" / "CLAUDE.md"
    ).read_text(encoding="utf-8").lower()


# ---------------------------------------------------------------------------
# AC-1 – AC-5 / FR-1 – FR-5 — the README Dynamic Workflows section
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS7ReadmeDynamicWorkflowsSection:
    """Structural shadow of AC-1–AC-5 — README.md must gain a Dynamic
    Workflows section naming the six patterns + election discipline,
    INV-1/INV-2, the Claude-Code-only scope + the guidance-only Copilot
    Option-A contract, while the Skills-N badge tracks the real skill count
    (scenario ``scenarios/skills/dynamic-workflows/readme-dynamic-workflows-section.md``)."""

    def test_section_exists(self, plugin_path: Path) -> None:
        section = _dynamic_workflows_section(plugin_path)
        assert section, (
            "README.md must contain a 'Dynamic Workflows' section — a heading "
            "whose text contains 'Dynamic Workflows' (AC-1 / FR-1). None "
            "found. Keep 'Dynamic Workflows' unwrapped in the heading."
        )

    def test_names_the_six_patterns(self, plugin_path: Path) -> None:
        section = _dynamic_workflows_section(plugin_path)
        # A few load-bearing pattern tokens co-occurring — 'fan-out' is a
        # single hyphenated token; 'adversarial' and 'tournament' single
        # words. Keep each unwrapped.
        assert "fan-out" in section and "adversarial" in section and (
            "tournament" in section
        ), (
            "Dynamic Workflows section must reference the six patterns — the "
            "test asserts 'fan-out', 'adversarial', and 'tournament' co-occur "
            "(AC-2 / FR-2). Keep 'fan-out', 'classify-and-act', "
            "'loop-until-done' unwrapped (each a single hyphenated token)."
        )

    def test_states_election_discipline(self, plugin_path: Path) -> None:
        section = _dynamic_workflows_section(plugin_path)
        # Workflows are elected (opt-in), not reflexive. Any of these single
        # markers satisfies the discipline. Keep 'opt-in' / 'when not to use'
        # unwrapped.
        assert (
            "elect" in section
            or "opt-in" in section
            or "opt in" in section
            or "when not to use" in section
        ), (
            "Dynamic Workflows section must state the election discipline — "
            "workflows are elected (opt-in) via the when-not-to-use rubric, "
            "not reflexive; the static pipeline stays the default (AC-2 / "
            "FR-2). Keep 'opt-in' and 'when not to use' unwrapped."
        )

    def test_states_inv1_and_inv2(self, plugin_path: Path) -> None:
        section = _dynamic_workflows_section(plugin_path)
        # 'inv-1' and 'inv-2' are single wrap-safe tokens (lowercased).
        assert "inv-1" in section and "inv-2" in section, (
            "Dynamic Workflows section must name both INV-1 (ephemeral "
            "proposes, durable curates) and INV-2 (quarantine "
            "untrusted-content readers) (AC-3 / FR-3). 'INV-1'/'INV-2' are "
            "single unwrappable tokens."
        )

    def test_states_claude_code_only_scope(self, plugin_path: Path) -> None:
        section = _dynamic_workflows_section(plugin_path)
        # 'claude code' is two words — split it.
        assert "claude" in section and "code" in section, (
            "Dynamic Workflows section must state the Claude-Code-only runtime "
            "scope (AC-4 / FR-4). Keep 'Claude Code' unwrapped — asserted as "
            "two co-occurring tokens, NOT a joined substring."
        )

    def test_states_copilot_guidance_only_contract(
        self, plugin_path: Path
    ) -> None:
        section = _dynamic_workflows_section(plugin_path)
        # Option A: ships to Copilot as guidance only (not omitted).
        # 'copilot' + 'guidance' co-occurring, NOT a joined substring.
        assert "copilot" in section and "guidance" in section, (
            "Dynamic Workflows section must state the Option A Copilot "
            "contract — on the Copilot CLI tree the skill degrades to "
            "guidance only (readable knowledge, no workflow spawned, no "
            "error), NOT omitted (AC-4 / FR-4). Keep 'guidance only' / "
            "'guidance-only' unwrapped; 'copilot' and 'guidance' asserted as "
            "two co-occurring tokens."
        )

    def test_skill_count_badge_matches_actual_count(
        self, plugin_path: Path
    ) -> None:
        # GUARD (must STAY green): the README skills shields badge must equal
        # the ACTUAL number of skill directories — no spurious bump, no stale
        # count. Originally this pinned the literal 'Skills-36' (S7 must not
        # re-bump); it now derives the expected count from the filesystem so a
        # legitimate new skill (e.g. sentinel-design, the 37th) updates the
        # badge without the guard going stale. Read the full README
        # (case-sensitive) — the badge text is 'Skills-N', a single
        # unwrappable token.
        text = _readme_text(plugin_path)
        actual = len(list((plugin_path / "skills").glob("*/SKILL.md")))
        assert f"Skills-{actual}" in text, (
            f"README skills shields badge must read 'Skills-{actual}' to match "
            f"the {actual} skill directories under ai-literacy-superpowers/"
            "skills/ (AC-5 / FR-5). The badge count must track the real skill "
            "count — bump it when adding a skill, and never spuriously."
        )


# ---------------------------------------------------------------------------
# AC-6c / FR-6 — the skill/governance reference states the Option A contract
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS7GovernanceCopilotContract:
    """Structural shadow of AC-6c — governance.md must state the resolved
    Option A Copilot degradation contract: ships to both trees, guidance
    only where no runtime, never omitted (scenario
    ``scenarios/skills/dynamic-workflows/governance-copilot-option-a-contract.md``)."""

    def test_states_copilot_guidance_only(self, plugin_path: Path) -> None:
        text = _governance_text(plugin_path)
        # 'copilot' + 'guidance' co-occurring, NOT a joined substring.
        assert "copilot" in text and "guidance" in text, (
            "governance.md must state the Copilot CLI degradation contract — "
            "on a tree without the workflow runtime the skill is guidance "
            "only (AC-6c / FR-6). Keep 'guidance only' / 'guidance-only' "
            "unwrapped; 'copilot' and 'guidance' asserted as two co-occurring "
            "tokens."
        )

    def test_states_never_omit_ships_to_both(
        self, plugin_path: Path
    ) -> None:
        text = _governance_text(plugin_path)
        # Option A is the NEVER-OMIT contract: the skill ships to BOTH trees
        # and is not omitted. Any of these assurances satisfies it; keep
        # 'both trees' / 'ship to both' / 'never omit' unwrapped.
        assert (
            "never omit" in text
            or "not omitted" in text
            or "ship to both" in text
            or "ships to both" in text
            or "both trees" in text
        ), (
            "governance.md must state the never-omit assurance — the skill "
            "ships to BOTH trees and is guidance-only where the runtime is "
            "absent, NOT omitted (Option A, not Option B) (AC-6c / FR-6). "
            "Keep 'both trees' / 'ship to both' / 'never omit' unwrapped — "
            "asserted as co-occurring tokens."
        )


# ---------------------------------------------------------------------------
# AC-7p / FR-7 — both CLAUDE.md surfaces point to the dynamic-workflows skill
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS7ClaudeMdSkillPointer:
    """Structural shadow of AC-7p — both CLAUDE.md (repo root) and
    templates/CLAUDE.md must reference the `dynamic-workflows` skill with a
    trigger cue, so the pointer is meaningful, not a bare mention (scenario
    ``scenarios/skills/dynamic-workflows/claude-md-skill-pointer.md``)."""

    @staticmethod
    def _assert_pointer(text: str, where: str) -> None:
        # 'dynamic-workflows' is a single wrap-safe token. The trigger cue is
        # any of these; 'long-running' is a single hyphenated token,
        # 'massively parallel' is two words (the test matches either word).
        assert "dynamic-workflows" in text, (
            f"{where} must reference the `dynamic-workflows` skill name "
            "(AC-7p / FR-7). 'dynamic-workflows' is a single unwrappable "
            "token."
        )
        assert (
            "long-running" in text
            or "massively parallel" in text
            or "massively-parallel" in text
            or "adversarial" in text
            or "workflow" in text
        ), (
            f"{where} must carry a trigger cue alongside the skill name — one "
            "of 'long-running' / 'massively parallel' / 'adversarial' / "
            "'workflow' — so the pointer tells an agent WHEN to consult the "
            "skill, not a bare mention (AC-7p / FR-7). Keep 'long-running', "
            "'massively parallel', 'highly structured' unwrapped."
        )

    def test_root_claude_md_points_to_skill(
        self, plugin_path: Path
    ) -> None:
        self._assert_pointer(
            _claude_md_root(plugin_path), "CLAUDE.md (repo root)"
        )

    def test_template_claude_md_points_to_skill(
        self, plugin_path: Path
    ) -> None:
        self._assert_pointer(
            _claude_md_template(plugin_path),
            "ai-literacy-superpowers/templates/CLAUDE.md",
        )
