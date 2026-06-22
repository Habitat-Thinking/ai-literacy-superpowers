"""Layer 1 structural content checks for dynamic-workflows S4.

These tests are the *deterministic mechanism* behind the structural
scenarios authored at ``scenarios/agents/{code-reviewer,advocatus-diaboli,
assessor,harness-auditor}/`` and ``scenarios/commands/{assess,harness-audit}/``
for slice S4 (the adversarial-review + deep-research workflow-mode upgrade
across four existing agents + two commands).

Per the spec's §6 decision 2 (the verification split), this repo's
deterministic layer reads files and matches structure — it does **not**
spawn a live fan-out or open a second context window. So what is
deterministically asserted here is that each agent doc / command **declares**
the workflow-mode contract (D5 separate-context + non-trivial trigger;
D7 file-count threshold + fan-out-by-area + per-finding separate-agent
verification + cited report; Claude-Code-only scope + non-erroring
fallback; the existing-location/format invariant; INV-1 precision). The
live properties (AC-1 separate context window, AC-6 live fan-out) are
agent-backed and live as ``behavioural`` scenarios, not wired here.

RED state (before S4 implements): none of the four agent docs has a
"Workflow mode" section and neither command documents the large-repo /
non-trivial workflow path, so every declaration assertion below fails on
missing content — RED for the right reason (missing content, not a
malformed scenario or an unresolvable component; all six components
already exist).

Line-wrap note (the trap that bit S3 twice): a required two-word phrase
that an implementer might wrap across a line is NOT asserted as a single
substring. Where a guarantee needs two terms to co-occur, they are
asserted as two independent ``in`` checks on the lowercased section so a
wrapped phrase still passes. Single load-bearing tokens (filenames,
``> 300``, ``> 2``, ``harness.md``) are wrap-safe and asserted directly.

Spec: docs/superpowers/specs/2026-06-22-dynamic-workflows-s4-adversarial-deepresearch-design.md
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


def _workflow_section(plugin_path: Path, name: str, component_type: str) -> str:
    """Return the text from the 'Workflow mode' heading to the next
    same-or-higher-level heading, lowercased. Empty string if absent."""
    text = _component_text(plugin_path, name, component_type)
    m = re.search(
        r"^(#{2,4})\s+.*workflow mode.*$", text, re.IGNORECASE | re.MULTILINE
    )
    if not m:
        return ""
    level = len(m.group(1))
    start = m.end()
    rest = text[start:]
    nxt = re.search(rf"^#{{1,{level}}}\s+\S", rest, re.MULTILINE)
    end = nxt.start() if nxt else len(rest)
    return rest[:end].lower()


# ---------------------------------------------------------------------------
# D5 — code-reviewer: separate-context adversarial review
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS4CodeReviewerWorkflowMode:
    """Structural shadows of AC-1..AC-4 — code-reviewer.agent.md must
    *declare* the separate-context adversarial-review workflow-mode
    contract (scenarios under ``scenarios/agents/code-reviewer/``)."""

    def _section(self, plugin_path: Path) -> str:
        return _workflow_section(plugin_path, "code-reviewer", "agent")

    def test_workflow_mode_section_exists(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert section, (
            "code-reviewer.agent.md must contain a 'Workflow mode' section "
            "(AC-2 / FR-1). None found."
        )

    def test_declares_separate_context_window(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        # Wrap-safe: assert the two load-bearing terms co-occur rather than
        # the joined phrase "context window distinct from the implementer".
        assert "context window" in section and "implementer" in section and (
            "distinct" in section or "separate" in section
        ), (
            "Workflow-mode section must declare the reviewing agent operates "
            "in a context window distinct/separate from the implementer's "
            "(AC-2 / FR-2; the separate-context property). Keep "
            "'context window' unwrapped on one line."
        )

    def test_declares_non_trivial_trigger_two_files(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "non-trivial" in section and "> 2 files" in section, (
            "Workflow-mode section must declare the non-trivial trigger — "
            "workflow mode engages only for non-trivial reviews, default "
            "`> 2 files` changed (AC-2 / FR-2, §6 decision 3 / T2). Keep "
            "'> 2 files' unwrapped."
        )

    def test_declares_trigger_configurable_via_harness_field(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "harness.md" in section and "configur" in section, (
            "Workflow-mode section must state the non-trivial trigger is "
            "configurable via the optional HARNESS.md field (AC-2 / FR-2, "
            "§6 decision 1 M1, one consistent knob across the epic)."
        )

    def test_declares_per_property_dedicated_verifier(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "cupid" in section and "literate" in section and (
            "dedicated verifier" in section
        ), (
            "Workflow-mode section must declare each CUPID property and each "
            "literate-programming property is checked by a dedicated "
            "verifier (AC-3 / FR-3). Keep 'dedicated verifier' unwrapped."
        )

    def test_declares_synthesised_not_collapsed(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "synthesis" in section and "collapse" in section, (
            "Workflow-mode section must state findings are synthesised, NOT "
            "collapsed into a single thumbs-up (AC-3 / FR-3). Assert the "
            "synthesise-not-collapse contrast, not just the word "
            "'synthesis'."
        )

    def test_declares_adapts_template_by_relative_path(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "adversarial-review.workflow.js" in section and (
            "adapt" in section
        ), (
            "Workflow-mode section must state it ADAPTs "
            "adversarial-review.workflow.js by relative path — ADAPT, not "
            "verbatim (AC-3 / FR-3)."
        )

    def test_declares_max_review_cycles_respected(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "max_review_cycles" in section and "3" in section, (
            "Workflow-mode section must state MAX_REVIEW_CYCLES=3 still "
            "holds in workflow mode (AC-4 / FR-4). Keep 'MAX_REVIEW_CYCLES' "
            "unwrapped."
        )

    def test_declares_claude_code_scope_and_fallback(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "claude code" in section and (
            "fall back" in section or "falls back" in section
        ) and ("never error" in section), (
            "Workflow-mode section must state the Claude-Code-only runtime "
            "scope and the non-erroring fallback to single-context review "
            "(AC-2 / FR-5)."
        )

    def test_declares_propose_only_never_writes_durable(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "durable artefact" in section and (
            "propose" in section or "never write" in section or (
                "does not write" in section
            ) or "read-only" in section
        ), (
            "Workflow-mode section must state workflow mode is "
            "propose-only / read-only and never writes a durable artefact "
            "(AC-11 / FR-5 / INV-1). Keep 'durable artefact' unwrapped."
        )


@pytest.mark.structural
class TestS4CodeReviewerReadOnlyToolSet:
    """AC-11 / FR-5: the code-reviewer's tool set must stay read-only (no
    Write/Edit). GREEN today and must STAY green through S4."""

    def test_tools_no_write_no_edit(self, plugin_path: Path) -> None:
        component = plugin_runner.find_component(
            plugin_path, name="code-reviewer", component_type="agent"
        )
        tools = component.frontmatter.get("tools") or []
        assert "Write" not in tools and "Edit" not in tools, (
            f"code-reviewer must stay read-only (INV-1, AC-11); tools must "
            f"not include Write/Edit. Got {tools!r}"
        )


# ---------------------------------------------------------------------------
# D5 — advocatus-diaboli: the rubric-bearing adversary
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS4AdvocatusDiaboliWorkflowRole:
    """Structural shadow of AC-5 — advocatus-diaboli.agent.md must declare
    its rubric-bearing-adversary role in the adversarial-review workflow
    without relaxing its read-only trust boundary
    (scenarios under ``scenarios/agents/advocatus-diaboli/``)."""

    def test_declares_rubric_bearing_adversary_role(
        self, plugin_path: Path
    ) -> None:
        text = _component_text(
            plugin_path, "advocatus-diaboli", "agent"
        ).lower()
        assert "adversarial-review" in text and (
            "rubric-bearing adversary" in text
        ), (
            "advocatus-diaboli.agent.md must declare that in the "
            "adversarial-review workflow it is the rubric-bearing adversary "
            "evaluating the diff against the CUPID + literate rubric "
            "(AC-5 / FR-6). Keep 'rubric-bearing adversary' unwrapped."
        )

    def test_trust_boundary_unchanged_read_only(
        self, plugin_path: Path
    ) -> None:
        # The existing read-only boundary must stay green: no Write/Edit/Bash.
        component = plugin_runner.find_component(
            plugin_path, name="advocatus-diaboli", component_type="agent"
        )
        tools = component.frontmatter.get("tools") or []
        assert (
            "Write" not in tools
            and "Edit" not in tools
            and "Bash" not in tools
        ), (
            f"advocatus-diaboli must keep its read-only trust boundary "
            f"unchanged (AC-5 / FR-6); tools must remain read-only with no "
            f"Write/Edit/Bash. Got {tools!r}"
        )


# ---------------------------------------------------------------------------
# D7 — assessor + harness-auditor: deep-research, fan-out-by-area
# ---------------------------------------------------------------------------


def _assert_deep_research_shape(section: str, agent_label: str) -> None:
    """Shared D7 declaration assertions for both assessor and auditor.

    Each guarantee is asserted as wrap-safe co-occurring tokens, never a
    joined two-word phrase the implementer might wrap.
    """
    assert "> 300" in section, (
        f"{agent_label} workflow-mode section must declare the file-count "
        f"threshold `> 300` (strict greater-than) (AC-7 / FR-7, §6 decision "
        f"1). Keep '> 300' unwrapped."
    )
    assert "file count" in section or "files" in section, (
        f"{agent_label} workflow-mode section must name the metric as repo "
        f"file count (AC-7 / FR-7)."
    )
    assert "harness.md" in section and "configur" in section, (
        f"{agent_label} workflow-mode section must state the threshold is "
        f"configurable via the optional HARNESS.md field (AC-7 / FR-7, "
        f"§6 decision 1 M1)."
    )
    assert "absent" in section or "default" in section, (
        f"{agent_label} workflow-mode section must state the field defaults "
        f"to 300 when absent (AC-7 / §9 safe-default)."
    )
    assert "fan out by area" in section or "fan-out by area" in section or (
        "fan out" in section and "area" in section
    ), (
        f"{agent_label} workflow-mode section must declare fan-out by area "
        f"(AC-7 / FR-7)."
    )
    assert "separate agent" in section and "verif" in section, (
        f"{agent_label} workflow-mode section must declare each finding is "
        f"verified by a separate agent before synthesis (AC-7 / FR-7). Keep "
        f"'separate agent' unwrapped."
    )
    assert "cited report" in section, (
        f"{agent_label} workflow-mode section must declare a cited report "
        f"(file:line citations preserved through synthesis) (AC-7 / FR-7). "
        f"Keep 'cited report' unwrapped."
    )
    assert "deep-assessment.workflow.js" in section and "adapt" in section, (
        f"{agent_label} workflow-mode section must state it ADAPTs "
        f"deep-assessment.workflow.js by relative path (AC-7 / FR-7)."
    )
    assert "claude code" in section and (
        "fall back" in section or "falls back" in section
    ) and ("never error" in section), (
        f"{agent_label} workflow-mode section must state the Claude-Code-only "
        f"scope and the non-erroring fallback to the existing single-context "
        f"scan (AC-7 / FR-7)."
    )


def _assert_output_location_invariant(section: str, agent_label: str) -> None:
    assert "timestamped" in section, (
        f"{agent_label} workflow-mode section must state the output stays a "
        f"timestamped artefact in the existing location/format (AC-9 / FR-9). "
        f"Keep 'timestamped' present."
    )


@pytest.mark.structural
class TestS4AssessorWorkflowMode:
    """Structural shadow of AC-7 / AC-9 / AC-11 — assessor.agent.md must
    declare the deep-research workflow-mode contract
    (scenarios under ``scenarios/agents/assessor/``)."""

    def _section(self, plugin_path: Path) -> str:
        return _workflow_section(plugin_path, "assessor", "agent")

    def test_workflow_mode_section_exists(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert section, (
            "assessor.agent.md must contain a 'Workflow mode' section "
            "(AC-7 / FR-7). None found."
        )

    def test_declares_deep_research_shape(self, plugin_path: Path) -> None:
        _assert_deep_research_shape(self._section(plugin_path), "assessor")

    def test_declares_output_location_invariant(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        _assert_output_location_invariant(section, "assessor")
        assert "assessments/" in section, (
            "assessor workflow-mode section must state the assessment output "
            "stays in the existing location `assessments/YYYY-MM-DD-"
            "assessment.md` (AC-9 / FR-9). Keep 'assessments/' present."
        )

    def test_declares_workflow_proposes_only_not_durable_curated(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        # The *workflow* proposes findings only and never writes one of the
        # four durable curated artefacts; the *agent* still writes its own
        # report. We assert the durable-curated prohibition co-occurs with
        # at least two of the four named artefacts (wrap-safe).
        named = sum(
            t in section
            for t in ("harness.md", "agents.md", "claude.md", "model_routing.md")
        )
        assert "durable" in section and "propose" in section and named >= 2, (
            "assessor workflow-mode section must state the *.workflow.js "
            "workflow itself proposes findings only and never writes a "
            "durable curated artefact (HARNESS.md/AGENTS.md/CLAUDE.md/"
            "MODEL_ROUTING.md) (AC-11 / FR-11) — the prohibition is on those "
            "four, NOT on the assessment report the agent legitimately "
            "writes."
        )

    def test_tools_retain_write_for_own_report(
        self, plugin_path: Path
    ) -> None:
        # AC-11 precision: the assessor LEGITIMATELY writes its own report,
        # so Write/Edit must REMAIN (do not forbid). This stays green.
        component = plugin_runner.find_component(
            plugin_path, name="assessor", component_type="agent"
        )
        tools = component.frontmatter.get("tools") or []
        assert "Write" in tools and "Edit" in tools, (
            f"assessor must retain Write/Edit for its own assessment report "
            f"(AC-11 / FR-11 — INV-1 forbids only the four durable curated "
            f"artefacts, not the assessment doc). Got {tools!r}"
        )


@pytest.mark.structural
class TestS4HarnessAuditorWorkflowMode:
    """Structural shadow of AC-8 / AC-9 / AC-11 — harness-auditor.agent.md
    must declare everything the assessor does PLUS the self-preference
    guard (scenarios under ``scenarios/agents/harness-auditor/``)."""

    def _section(self, plugin_path: Path) -> str:
        return _workflow_section(plugin_path, "harness-auditor", "agent")

    def test_workflow_mode_section_exists(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert section, (
            "harness-auditor.agent.md must contain a 'Workflow mode' section "
            "(AC-8 / FR-8). None found."
        )

    def test_declares_deep_research_shape(self, plugin_path: Path) -> None:
        _assert_deep_research_shape(
            self._section(plugin_path), "harness-auditor"
        )

    def test_declares_self_preference_guard(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        # The one demanded specialisation: >=1 verifier adversarial to the
        # framework's own assumptions. Wrap-safe co-occurring tokens.
        assert "adversarial" in section and "assumption" in section and (
            "framework" in section
        ), (
            "harness-auditor workflow-mode section must declare the "
            "self-preference guard: at least one verifier is adversarial to "
            "the framework's own assumptions (the auditor must not grade its "
            "own homework) (AC-8 / FR-8)."
        )

    def test_declares_output_location_invariant(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        _assert_output_location_invariant(section, "harness-auditor")
        # Auditor's existing write targets: HARNESS.md Status section + badge.
        assert "status" in section and "badge" in section, (
            "harness-auditor workflow-mode section must state the output "
            "stays the existing HARNESS.md Status section + README badge "
            "update (AC-9 / FR-9). Keep 'status' and 'badge' present."
        )

    def test_tools_retain_write_for_own_writes(
        self, plugin_path: Path
    ) -> None:
        component = plugin_runner.find_component(
            plugin_path, name="harness-auditor", component_type="agent"
        )
        tools = component.frontmatter.get("tools") or []
        assert "Write" in tools and "Edit" in tools, (
            f"harness-auditor must retain Write/Edit for its existing "
            f"HARNESS.md Status + README badge writes (AC-11 / FR-11). "
            f"Got {tools!r}"
        )


# ---------------------------------------------------------------------------
# AC-10 — commands document the large-repo / non-trivial workflow path
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS4CommandsDocumentWorkflowPath:
    """Structural shadow of AC-10 — commands/assess.md and
    commands/harness-audit.md must document the large-repo deep-research
    workflow path (scenarios under ``scenarios/commands/{assess,
    harness-audit}/``)."""

    def _text(self, plugin_path: Path, name: str) -> str:
        return _component_text(plugin_path, name, "command").lower()

    def test_assess_documents_workflow_path(self, plugin_path: Path) -> None:
        text = self._text(plugin_path, "assess")
        assert "workflow mode" in text and "> 300" in text and (
            "claude code" in text
        ), (
            "commands/assess.md must document that above the threshold "
            "(`> 300` files) on the Claude Code runtime the dispatched agent "
            "elects its deep-research workflow mode (AC-10 / FR-10). Keep "
            "'> 300' and 'workflow mode' unwrapped."
        )

    def test_assess_documents_fallback(self, plugin_path: Path) -> None:
        text = self._text(plugin_path, "assess")
        assert "fall back" in text or "falls back" in text or (
            "fallback" in text
        ), (
            "commands/assess.md must document the non-erroring fallback "
            "elsewhere (AC-10 / FR-10)."
        )

    def test_harness_audit_documents_workflow_path(
        self, plugin_path: Path
    ) -> None:
        text = self._text(plugin_path, "harness-audit")
        assert "workflow mode" in text and "> 300" in text and (
            "claude code" in text
        ), (
            "commands/harness-audit.md must document that above the "
            "threshold (`> 300` files) on the Claude Code runtime the "
            "auditor elects its deep-research workflow mode (AC-10 / FR-10). "
            "Keep '> 300' and 'workflow mode' unwrapped."
        )

    def test_harness_audit_documents_fallback(
        self, plugin_path: Path
    ) -> None:
        text = self._text(plugin_path, "harness-audit")
        assert "fall back" in text or "falls back" in text or (
            "fallback" in text
        ), (
            "commands/harness-audit.md must document the non-erroring "
            "fallback elsewhere (AC-10 / FR-10)."
        )
