"""Layer 1 structural content checks for dynamic-workflows S6.

These tests are the *deterministic mechanism* behind the structural
scenarios authored at ``scenarios/commands/reflect/`` and
``scenarios/agents/integration-agent/`` for slice S6 (the optional
``/reflect --mine`` reflection-mining mode + the integration-agent
augments-never-replaces note).

Per the spec's §6 decision 3 (the verification split), this repo's
deterministic layer reads files and matches structure — it does **not**
run ``/reflect --mine``, dispatch a workflow, or diff ``AGENTS.md``. So
what is deterministically asserted here is that ``reflect.md`` **declares**
the ``--mine`` contract (the opt-in mode + unchanged default capture path;
the cluster → adversarial filter → shortlist shape + adapt-by-relative-
path; the INV-1 staging-only / never-AGENTS.md / byte-for-byte / human-
promotes boundary; the candidate shape + gitignored-regenerated lifecycle;
the Claude-Code-only scope + non-erroring guidance-only fallback), that
``integration-agent.agent.md`` **declares** mining augments-never-replaces
human curation, and that the repo-root ``.gitignore`` carries a
``REFLECTION_STAGING.md`` entry (§6 decision 1, L1). The live ``--mine``
run (AC-1) is agent-backed and lives as a ``behavioural`` scenario, not
wired here. AC-9 (GC-pressure reduction) is observational and not asserted.

RED state (before S6 implements): ``reflect.md`` has no "Mining mode" /
"--mine" section, ``integration-agent.agent.md`` has no augments-never-
replaces note, and ``.gitignore`` has no ``REFLECTION_STAGING.md`` entry —
so every declaration assertion below fails on missing content (RED for the
right reason: missing content, not a malformed scenario or an unresolvable
component; both components already exist). The corpus/parse/tier checks in
``test_layer1_structural.py`` stay GREEN.

Line-wrap note (the trap that bit S3 twice, S4 twice, S5 once): a required
two-word phrase that an implementer might wrap across a line is NOT
asserted as a single substring. Where a guarantee needs two terms to
co-occur, they are asserted as two independent ``in`` checks on the
lowercased section so a wrapped phrase still passes. Single load-bearing
tokens (``--mine``, ``reflection-mining.workflow.js``,
``reflection_staging.md``, ``agents.md``, ``.gitignore``) are wrap-safe and
asserted directly; ``claude code`` is two words and is split.

Spec: docs/superpowers/specs/2026-06-23-dynamic-workflows-s6-reflection-mining-design.md
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402


def _component_text(
    plugin_path: Path, name: str, component_type: str
) -> str:
    component = plugin_runner.find_component(
        plugin_path, name=name, component_type=component_type
    )
    return component.path.read_text(encoding="utf-8")


def _mining_section(plugin_path: Path) -> str:
    """Return the text of the ``reflect.md`` mining-mode section — from a
    level-2/3/4 heading containing "mining mode" OR "--mine" to the next
    same-or-higher-level heading, lowercased. Empty string if absent."""
    text = _component_text(plugin_path, "reflect", "command")
    m = re.search(
        r"^(#{2,4})\s+.*(mining mode|--mine).*$",
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


def _repo_root(plugin_path: Path) -> Path:
    """The repo root — parent of the ``ai-literacy-superpowers`` plugin
    directory (``plugin_path`` points at the plugin dir)."""
    return plugin_path.parent


# ---------------------------------------------------------------------------
# AC-3 / FR-1 — the --mine mode is opt-in; the default capture path unchanged
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS6ReflectMineModeOptIn:
    """Structural shadow of AC-3 — reflect.md must *declare* a mining-mode
    section, that ``--mine`` is opt-in, and that the default capture path is
    unchanged (scenarios under ``scenarios/commands/reflect/``)."""

    def test_mining_section_exists(self, plugin_path: Path) -> None:
        section = _mining_section(plugin_path)
        assert section, (
            "reflect.md must contain a 'Mining mode' or '--mine' section "
            "(AC-3 / FR-1). None found."
        )

    def test_declares_mine_is_opt_in(self, plugin_path: Path) -> None:
        section = _mining_section(plugin_path)
        # '--mine' is a single unwrappable token; opt-in asserted as
        # co-occurring tokens.
        assert "--mine" in section and (
            "opt-in" in section or "opt in" in section or "optional" in section
        ), (
            "Mining-mode section must declare `--mine` is optional / opt-in — "
            "an additive mode, not the default (AC-3 / FR-1). Keep '--mine' "
            "and 'opt-in' unwrapped."
        )

    def test_declares_default_capture_path_unchanged(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # Wrap-safe: 'default' + 'capture' + 'unchanged' as co-occurring
        # tokens, NOT a joined substring.
        assert "default" in section and "capture" in section and (
            "unchanged" in section
        ), (
            "Mining-mode section must state the default /reflect capture "
            "behaviour is unchanged — bare /reflect still writes a fragment "
            "and regenerates the log (AC-3 / FR-1). Keep 'default', "
            "'capture', and 'unchanged' unwrapped."
        )


# ---------------------------------------------------------------------------
# AC-4 / FR-2 — cluster → adversarial filter → shortlist; adapts by rel path
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS6ReflectMineShape:
    """Structural shadow of AC-4 — the mining-mode section must declare the
    cluster → adversarial filter → shortlist shape and that it adapts
    ``reflection-mining.workflow.js`` by relative path (scenarios under
    ``scenarios/commands/reflect/``)."""

    def test_declares_cluster_filter_shortlist_shape(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # Three independent single-word tokens; each kept unwrapped.
        assert "cluster" in section, (
            "Mining-mode section must declare the CLUSTER phase — group the "
            "reflection entries by recurring theme (AC-4 / FR-2). Keep "
            "'cluster' unwrapped."
        )
        assert "adversarial" in section, (
            "Mining-mode section must declare the ADVERSARIAL pre-filter "
            "phase (a skeptic refutes weak candidates) (AC-4 / FR-2). Keep "
            "'adversarial' unwrapped."
        )
        assert "shortlist" in section, (
            "Mining-mode section must declare the vetted SHORTLIST phase "
            "(AC-4 / FR-2). Keep 'shortlist' unwrapped."
        )

    def test_declares_would_have_prevented_filter_question(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # 'would this' + 'prevented' co-occurring, NOT a joined substring.
        assert ("would this" in section or "would the rule" in section) and (
            "prevented" in section or "prevent" in section
        ), (
            "Mining-mode section must declare the adversarial filter asks "
            "'would this rule have prevented a real past mistake?' (AC-4 / "
            "FR-2). Keep 'would this' and 'prevented' unwrapped."
        )

    def test_declares_adapts_template_by_relative_path(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # 'reflection-mining.workflow.js' is a single unwrappable token;
        # 'relative path' kept unwrapped, asserted co-occurring with 'adapt'.
        assert "reflection-mining.workflow.js" in section and (
            "adapt" in section
        ) and ("relative path" in section), (
            "Mining-mode section must state mining ADAPTs "
            "`reflection-mining.workflow.js` by relative path — ADAPT, not "
            "run verbatim (AC-4 / FR-2). Keep 'relative path' unwrapped."
        )


# ---------------------------------------------------------------------------
# AC-5 / FR-3 — INV-1 staging-only / never-AGENTS.md / human-promotes
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS6ReflectInv1Boundary:
    """Structural shadow of AC-5 (deterministic shadow of AC-2) — the
    mining-mode section must declare mining writes ONLY to
    ``REFLECTION_STAGING.md`` and NEVER to ``AGENTS.md``, that AGENTS.md is
    byte-for-byte unchanged, and that promotion is a human ``Promoted:`` act
    (scenarios under ``scenarios/commands/reflect/``)."""

    def test_declares_staging_only_never_agents_md(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # 'reflection_staging.md' and 'agents.md' are single unwrappable
        # tokens (lowercased). 'only' + 'never' co-occurring.
        assert "reflection_staging.md" in section and "agents.md" in section, (
            "Mining-mode section must name both REFLECTION_STAGING.md (the "
            "sole write target) and AGENTS.md (never written) (AC-5 / FR-3 / "
            "INV-1). Both tokens are single/unwrappable."
        )
        assert "only" in section and "never" in section, (
            "Mining-mode section must state the shortlist is written ONLY to "
            "REFLECTION_STAGING.md and NEVER to AGENTS.md (nor "
            "HARNESS.md/CLAUDE.md/MODEL_ROUTING.md) (AC-5 / FR-3 / INV-1). "
            "Keep 'only' and 'never' unwrapped."
        )

    def test_declares_agents_md_byte_for_byte_unchanged(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # 'byte-for-byte' kept unwrapped, asserted co-occurring with
        # 'unchanged'.
        assert ("byte-for-byte" in section or "byte for byte" in section) and (
            "unchanged" in section
        ), (
            "Mining-mode section must state AGENTS.md stays byte-for-byte "
            "unchanged by mining until a human promotes (AC-5 / FR-3, "
            "deterministic shadow of AC-2). Keep 'byte-for-byte' unwrapped."
        )

    def test_declares_human_promotes_propose_only(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # 'human' + 'promote/promoted' + 'propose/proposes' co-occurring.
        assert "human" in section and (
            "promote" in section or "promoted" in section
        ) and ("propose" in section), (
            "Mining-mode section must state a human still promotes from "
            "staging through the existing `Promoted:` flow — mining proposes, "
            "the human curates (AC-5 / FR-3 / INV-1). Keep 'human' and "
            "'promotes' unwrapped."
        )


# ---------------------------------------------------------------------------
# AC-6 / FR-4, FR-7 — candidate shape + staging-not-permanent + lifecycle
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS6ReflectStagingShapeAndLifecycle:
    """Structural shadow of AC-6 — the mining-mode section must declare the
    staging candidate shape (proposed rule + source fragment(s) + adversarial
    verdict/evidence), the staging-not-permanent status, and the
    gitignored/regenerated-each-run lifecycle (scenarios under
    ``scenarios/commands/reflect/``)."""

    def test_declares_candidate_shape(self, plugin_path: Path) -> None:
        section = _mining_section(plugin_path)
        # Each candidate carries: proposed rule + source fragment(s) +
        # verdict/evidence. Independent co-occurring tokens.
        assert "rule" in section, (
            "Mining-mode section must declare each staging candidate carries "
            "the proposed rule / insight (AC-6 / FR-4). Keep 'proposed rule' "
            "unwrapped."
        )
        assert "source" in section, (
            "Mining-mode section must declare each candidate carries the "
            "source reflection fragment(s) it clusters (AC-6 / FR-4). Keep "
            "'source' unwrapped."
        )
        assert "verdict" in section or "evidence" in section, (
            "Mining-mode section must declare each candidate carries the "
            "adversarial-filter verdict / evidence (AC-6 / FR-4). Keep "
            "'verdict' and 'evidence' unwrapped."
        )

    def test_declares_staging_not_permanent(self, plugin_path: Path) -> None:
        section = _mining_section(plugin_path)
        # 'staging' + 'permanent' + 'review' co-occurring.
        assert "staging" in section and "permanent" in section and (
            "review" in section
        ), (
            "Mining-mode section must state REFLECTION_STAGING.md is a "
            "staging / working area for human review — NOT the permanent "
            "record, NOT a durable curated artefact (AC-6 / FR-4). Keep "
            "'staging' and 'permanent' unwrapped."
        )

    def test_declares_gitignored_regenerated_lifecycle(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # 'gitignore' + regenerate/overwrite co-occurring.
        assert "gitignore" in section and (
            "regenerate" in section
            or "regenerated" in section
            or "overwrite" in section
            or "overwritten" in section
        ), (
            "Mining-mode section must state REFLECTION_STAGING.md is "
            "gitignored and regenerated (overwritten) each run — the §6 "
            "decision 1 / L1 lifecycle (AC-6 / FR-7). Keep 'gitignored' and "
            "'regenerated' unwrapped."
        )


@pytest.mark.structural
class TestS6GitignoreHasStagingEntry:
    """FR-7 (§6 decision 1, L1): the repo-root ``.gitignore`` must carry a
    ``REFLECTION_STAGING.md`` entry — the one .gitignore touch S6 makes
    (scenario under ``scenarios/commands/reflect/``).

    RED now: no such entry exists. This is a deterministic file-read on the
    repo-root ``.gitignore``, not the plugin directory."""

    def test_gitignore_contains_reflection_staging_entry(
        self, plugin_path: Path
    ) -> None:
        gitignore = _repo_root(plugin_path) / ".gitignore"
        assert gitignore.is_file(), (
            f"Expected a repo-root .gitignore at {gitignore!r} (FR-7)."
        )
        text = gitignore.read_text(encoding="utf-8")
        assert "REFLECTION_STAGING.md" in text, (
            "Repo-root .gitignore must contain a REFLECTION_STAGING.md entry — "
            "the gitignored, regenerated-each-run staging file (§6 decision 1, "
            "L1 / FR-7). 'REFLECTION_STAGING.md' is a single unwrappable token."
        )


# ---------------------------------------------------------------------------
# AC-7 / FR-5 — Claude-Code-only scope + non-erroring guidance-only fallback
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS6ReflectClaudeCodeScopeAndFallback:
    """Structural shadow of AC-7 — the mining-mode section must declare the
    Claude-Code-only runtime scope and the non-erroring guidance-only
    fallback (scenarios under ``scenarios/commands/reflect/``)."""

    def test_declares_claude_code_runtime_scope(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # 'claude code' is two words — split it. + 'runtime'.
        assert "claude" in section and "code" in section and (
            "runtime" in section
        ), (
            "Mining-mode section must state `--mine` requires the Claude Code "
            "runtime (AC-7 / FR-5). Keep 'Claude Code' unwrapped — asserted as "
            "two co-occurring tokens."
        )

    def test_declares_guidance_only_non_erroring_fallback(
        self, plugin_path: Path
    ) -> None:
        section = _mining_section(plugin_path)
        # 'guidance' + (never error / does not error) + a degrade/fallback word.
        assert "guidance" in section and (
            "never error" in section
            or "never errors" in section
            or "does not error" in section
            or "not error" in section
        ) and (
            "fallback" in section
            or "fall back" in section
            or "degrade" in section
            or "degrades" in section
        ), (
            "Mining-mode section must state that without the runtime `--mine` "
            "degrades to guidance only and never errors — pointing at the "
            "readable skill knowledge and the manual cluster/vet/promote path "
            "(AC-7 / FR-5, §6 decision 2 / F1). Keep 'guidance-only' and "
            "'never errors' unwrapped."
        )


# ---------------------------------------------------------------------------
# AC-8 / FR-6 — integration-agent: mining augments, never replaces, curation
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS6IntegrationAgentAugmentsNotReplaces:
    """Structural shadow of AC-8 — integration-agent.agent.md must declare
    reflection mining augments, never replaces, human curation (scenario
    under ``scenarios/agents/integration-agent/``)."""

    def _text(self, plugin_path: Path) -> str:
        return _component_text(
            plugin_path, "integration-agent", "agent"
        ).lower()

    def test_declares_mining_augments_never_replaces(
        self, plugin_path: Path
    ) -> None:
        text = self._text(plugin_path)
        # 'mining' + 'augment(s)' + 'replace(s)' co-occurring.
        assert "mining" in text and (
            "augment" in text or "augments" in text
        ) and ("replace" in text or "replaces" in text), (
            "integration-agent.agent.md must state reflection mining augments, "
            "never replaces, human curation (AC-8 / FR-6). Keep 'augments' and "
            "'replaces' unwrapped."
        )

    def test_declares_human_curation_unchanged(
        self, plugin_path: Path
    ) -> None:
        text = self._text(plugin_path)
        # 'human' + 'curation' co-occurring (NOT a joined substring).
        assert "human" in text and "curation" in text, (
            "integration-agent.agent.md must state the human curation gate is "
            "the only path into AGENTS.md/HARNESS.md (AC-8 / FR-6). Keep "
            "'human' and 'curation' unwrapped — asserted as two co-occurring "
            "tokens."
        )

    def test_declares_promoted_gate_unchanged(
        self, plugin_path: Path
    ) -> None:
        text = self._text(plugin_path)
        # The agent already documents the Promoted-field convention, so a
        # bare 'promoted' + 'only' would pass vacuously on pre-S6 text. The
        # S6 note must tie the Promoted gate to MINING explicitly: assert the
        # gate prose co-occurs with mining/augment AND 'unchanged'/'only'.
        # Single tokens; 'mining'/'augment' are the S6-introduced markers.
        assert "promoted" in text and (
            "mining" in text or "augment" in text
        ) and ("unchanged" in text or "only" in text), (
            "integration-agent.agent.md must state the human `Promoted:`-line "
            "gate is the only path into AGENTS.md/HARNESS.md and is unchanged "
            "by mining (AC-8 / FR-6). 'Promoted' is wrap-safe; the note must "
            "tie the gate to the new mining augments-not-replaces stance, not "
            "rely on the pre-existing Promoted-field prose."
        )
