"""Layer 1 structural content checks for dynamic-workflows S3.

These tests are the *deterministic mechanism* behind the structural
scenarios authored at
``scenarios/agents/harness-enforcer/`` for slice S3 (the harness-enforcer
fan-out upgrade). Each test reads a target file
(``agents/harness-enforcer.agent.md`` or
``skills/verification-slots/SKILL.md``) and asserts that the declarations
the scenarios promise are present in checkable language.

Per the spec's §6 decision 2 (the verification split), this repo's
deterministic layer reads files and matches structure — it does **not**
spawn a live fan-out. So what is deterministically asserted here is that
the agent doc **declares** the workflow-mode contract (threshold,
configurability, fan-out/skeptic/synthesis-barrier, count-equality,
Claude-Code-only scope, read-only boundary) and that ``verification-slots``
documents the fan-out slot. The live properties (AC-1 exactly-N verifiers,
AC-2 false-positive reduction) are agent-backed and live as ``behavioural``
scenarios, not wired here.

RED state (before S3 implements): ``agents/harness-enforcer.agent.md`` has
no "Workflow mode" section and ``verification-slots/SKILL.md`` has no
fan-out slot, so every assertion below fails on a missing declaration —
RED for the right reason (missing content, not a malformed scenario or an
unresolvable component).

Spec: docs/superpowers/specs/2026-06-22-dynamic-workflows-s3-enforcer-fanout-design.md
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402


def _agent_text(plugin_path: Path) -> str:
    component = plugin_runner.find_component(
        plugin_path, name="harness-enforcer", component_type="agent"
    )
    return component.path.read_text(encoding="utf-8")


def _agent_workflow_section(plugin_path: Path) -> str:
    """Return the text from the 'Workflow mode' heading to the next
    same-or-higher-level heading, lowercased. Empty string if absent."""
    text = _agent_text(plugin_path)
    m = re.search(r"^(#{2,4})\s+.*workflow mode.*$", text, re.IGNORECASE | re.MULTILINE)
    if not m:
        return ""
    level = len(m.group(1))
    start = m.end()
    # Find the next heading at the same or higher level.
    rest = text[start:]
    nxt = re.search(rf"^#{{1,{level}}}\s+\S", rest, re.MULTILINE)
    end = nxt.start() if nxt else len(rest)
    return rest[:end].lower()


def _skill_text(plugin_path: Path) -> str:
    component = plugin_runner.find_component(
        plugin_path, name="verification-slots", component_type="skill"
    )
    return component.path.read_text(encoding="utf-8").lower()


@pytest.mark.structural
class TestS3WorkflowModeDeclared:
    """Structural shadows of D3 — the agent doc must *declare* the
    workflow-mode contract (scenarios under
    ``scenarios/agents/harness-enforcer/``)."""

    def test_workflow_mode_section_exists(self, plugin_path: Path) -> None:
        section = _agent_workflow_section(plugin_path)
        assert section, (
            "harness-enforcer.agent.md must contain a 'Workflow mode' "
            "section (AC-5 / FR-1). None found."
        )

    def test_declares_default_8_threshold(self, plugin_path: Path) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "threshold" in section and "8" in section, (
            "Workflow-mode section must declare a default threshold of 8 "
            "(AC-5 / FR-2)."
        )

    def test_declares_configurable_via_harness_field(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "harness.md" in section and "configur" in section and (
            "fan-out-threshold" in section
        ), (
            "Workflow-mode section must state the threshold is "
            "configurable per project via the optional HARNESS.md "
            "`fan-out-threshold` field, named explicitly "
            "(AC-5 / FR-2, §6 decision M1)."
        )

    def test_declares_absent_field_defaults_to_8(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "absent" in section or "default" in section, (
            "Workflow-mode section must state the field defaults to 8 when "
            "absent (AC-5 / §9 safe-default risk)."
        )

    def test_declares_strict_greater_than_trigger(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "exceed" in section or "greater than" in section or ">" in section, (
            "Workflow-mode section must declare a strict > trigger — "
            "exactly 8 stays single-context (AC-4)."
        )

    def test_declares_below_threshold_single_context(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "single-context" in section or "single context" in section, (
            "Workflow-mode section must state ≤ threshold keeps the "
            "existing single-context behaviour (AC-4 / FR-6)."
        )

    def test_declares_no_extra_compute_below_threshold(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "no workflow" in section or "no extra compute" in section or (
            "no verifier" in section
        ), (
            "Workflow-mode section must state the below-threshold path "
            "spends no extra compute / authors no workflow (AC-4 / FR-6)."
        )

    def test_declares_fanout_one_verifier_per_rule(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "per rule" in section or "per harness.md rule" in section, (
            "Workflow-mode section must declare fan-out: one verifier per "
            "rule (AC-6 / FR-4)."
        )

    def test_declares_skeptic_persona(self, plugin_path: Path) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "skeptic" in section, (
            "Workflow-mode section must declare the skeptic persona "
            "(AC-6 / FR-4)."
        )

    def test_declares_synthesis_barrier_all_n(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "synthesis barrier" in section and "all n" in section, (
            "Workflow-mode section must declare a synthesis barrier that "
            "waits for all N before reporting (AC-6 / FR-4)."
        )

    def test_declares_adapts_template_by_relative_path(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "enforcer-fanout.workflow.js" in section and "adapt" in section, (
            "Workflow-mode section must state it ADAPTs "
            "enforcer-fanout.workflow.js by relative path (AC-6 / FR-7)."
        )

    def test_declares_count_equality_guarantee(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "all constraints checked" in section and (
            "verifier results" in section
        ) and "equal" in section, (
            "Workflow-mode section must declare the count-equality "
            "guarantee in checkable language: when it reports 'all "
            "constraints checked', the count of verifier results must "
            "equal the enforceable count (AC-3 / FR-5) — assert the "
            "equality clause, not just the trigger phrase."
        )

    def test_declares_unverified_excluded_from_count(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "unverified" in section and "exclud" in section, (
            "Workflow-mode section must define the enforceable count as "
            "excluding `unverified` constraints (AC-3 / FR-3)."
        )

    def test_declares_no_silent_drop(self, plugin_path: Path) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "silent" in section and "drop" in section, (
            "Workflow-mode section must state no enforceable constraint is "
            "silently dropped (AC-3 / FR-5)."
        )

    def test_declares_first_run_reflection_log(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "reflection_log" in section and (
            "first run" in section or "first time" in section
        ), (
            "Workflow-mode section must declare the first-run "
            "REFLECTION_LOG obligation for the skeptic observation "
            "(AC-2 declaration / FR-8)."
        )

    def test_does_not_overpromise_deterministic_reduction(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        forbidden = [
            "deterministic false-positive",
            "deterministic false positive",
            "ci-checkable false-positive",
            "ci verifies the reduction",
        ]
        hit = [p for p in forbidden if p in section]
        assert not hit, (
            "The skeptic false-positive reduction must NOT be promised as "
            f"deterministic / CI-checkable (§6 decision 3). Found: {hit}"
        )

    def test_declares_claude_code_runtime_requirement(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "claude code" in section, (
            "Workflow-mode section must state workflow mode requires the "
            "Claude Code runtime (AC-7 / FR-9)."
        )

    def test_declares_non_erroring_fallback(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert ("fall back" in section or "falls back" in section) and (
            "never error" in section
        ), (
            "Workflow-mode section must state the enforcer falls back to "
            "single-context behaviour and never errors where the runtime "
            "is absent (AC-7 / FR-9)."
        )

    def test_declares_propose_only_never_writes_durable(
        self, plugin_path: Path
    ) -> None:
        section = _agent_workflow_section(plugin_path)
        assert "durable artefact" in section and (
            "never write" in section or "does not write" in section or (
                "propose-only" in section
            ) or "read-only" in section or "read and report" in section
        ), (
            "Workflow-mode section must state workflow mode is "
            "propose-only / read-only and never writes a durable artefact "
            "(AC-9 / FR-10 / INV-1)."
        )


@pytest.mark.structural
class TestS3ReadOnlyToolSet:
    """AC-9 / FR-10: the enforcer's tool set must stay read-only — the
    INV-1 enforcement at the agent level. This check is GREEN today (the
    list is already correct) and must STAY green through S3."""

    def test_tools_unchanged_no_write_no_edit(
        self, plugin_path: Path
    ) -> None:
        component = plugin_runner.find_component(
            plugin_path, name="harness-enforcer", component_type="agent"
        )
        tools = component.frontmatter.get("tools") or []
        assert "Write" not in tools and "Edit" not in tools, (
            f"harness-enforcer must stay read-only (INV-1, AC-9); tools "
            f"must not include Write/Edit. Got {tools!r}"
        )
        for required in ("Read", "Glob", "Grep", "Bash"):
            assert required in tools, (
                f"harness-enforcer tools must retain {required!r}; "
                f"got {tools!r}"
            )


@pytest.mark.structural
class TestS3VerificationSlotsFanoutSlot:
    """AC-8 / FR-11: verification-slots/SKILL.md must document the fan-out
    slot as a first-class agent-backed slot with the uniform contract."""

    def test_documents_fanout_slot(self, plugin_path: Path) -> None:
        text = _skill_text(plugin_path)
        assert "fan-out" in text or "fan out" in text, (
            "verification-slots/SKILL.md must document the fan-out slot "
            "(AC-8 / FR-11)."
        )

    def test_fanout_slot_names_verifier_per_rule_and_skeptic(
        self, plugin_path: Path
    ) -> None:
        text = _skill_text(plugin_path)
        assert "per rule" in text and "skeptic" in text, (
            "The fan-out slot must be described as one verifier per rule "
            "plus a skeptic (AC-8 / FR-11)."
        )

    def test_fanout_slot_uniform_contract(self, plugin_path: Path) -> None:
        text = _skill_text(plugin_path)
        # The uniform result shape: pass/fail + {file, line, message}. The
        # existing SKILL already states pass/fail + the finding shape, so
        # the load-bearing new assertion is that the fan-out slot is tied
        # to it. We require the fan-out term to co-occur with the contract.
        assert ("fan-out" in text or "fan out" in text) and (
            "synthesis barrier" in text
        ) and "pass/fail" in text, (
            "The fan-out slot must state its output conforms to the same "
            "pass/fail + {file, line, message} contract, with the "
            "synthesis barrier reconciling N results into one shape "
            "(AC-8 / FR-11)."
        )
