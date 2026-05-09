"""Phase 3 rollout — Option C helpers for the remaining procedural commands.

Phase 2 (PR #295) demonstrated Option C-direct on two procedural
commands (convention-sync, observatory-verify). The design spec
amended in PR #298 made the rollout discipline explicit: helpers
stay in ``tdad_tests/spike_helpers/``, command markdowns continue as
prose, tests verify the documented behaviour.

This module tests the remaining helpers:

| Helper | Mirrors | Test surface |
| --- | --- | --- |
| ``harness_status`` | ``/harness-status`` | Status section parsing |
| ``governance_health`` | ``/governance-health`` | Latest-audit summary |
| ``superpowers_status`` | ``/superpowers-status`` | Habitat-file sweep |
| ``reflect`` | ``/reflect`` | Reflection-entry formatter |
| ``harness_health`` | ``/harness-health`` quick mode | Aggregate snapshot |
| ``harness_upgrade`` | ``/harness-upgrade`` | Section-level diff |
| ``harness_affordance`` | ``/harness-affordance discover`` | Config scanner |
| ``cost_capture`` | ``/cost-capture`` | Latest-snapshot read |

``/worktree`` deliberately has no helper — the command is wholly git
operations and a wrapper would test git rather than command logic.
The deferral is documented in
``tdad_tests/spike_helpers/__init__.py`` and the suite README.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from spike_helpers import (  # noqa: E402
    cost_capture,
    governance_health,
    harness_affordance,
    harness_health,
    harness_status,
    harness_upgrade,
    reflect as reflect_helper,
    superpowers_status,
)
from spike_helpers.reflect import ReflectionEntry  # noqa: E402


# ---------------------------------------------------------------------------
# harness-status
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestHarnessStatusHelper:
    @pytest.fixture
    def harness_fixture(self, fixtures_dir: Path) -> Path:
        return fixtures_dir / "procedural" / "sample_harness_status.md"

    def test_parses_status_fields(self, harness_fixture: Path):
        text = harness_fixture.read_text(encoding="utf-8")
        status = harness_status.parse_status(text)
        assert status.last_audit == "2026-05-09"
        assert status.constraints_enforced == "22/23 (96%)"
        assert status.gc_active == "14/14"
        assert status.drift_detected == "no"

    def test_missing_status_section_returns_empty(self):
        text = "# Some other doc\n\n## Constraints\n\nNothing here.\n"
        status = harness_status.parse_status(text)
        assert status.last_audit is None
        assert status.constraints_enforced is None

    def test_read_status_raises_on_missing_file(self, tmp_path: Path):
        with pytest.raises(FileNotFoundError) as excinfo:
            harness_status.read_status(tmp_path / "no_such_harness.md")
        assert "HARNESS.md" in str(excinfo.value)


# ---------------------------------------------------------------------------
# governance-health
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestGovernanceHealthHelper:
    @pytest.fixture
    def audit_fixture(self, fixtures_dir: Path) -> Path:
        return fixtures_dir / "procedural" / "sample_governance_audit.md"

    def test_parses_summary_fields(self, audit_fixture: Path):
        text = audit_fixture.read_text(encoding="utf-8")
        summary = governance_health.parse_summary(text)
        assert summary.audit_date == "2026-05-09"
        assert summary.constraint_count == "5 governance constraints in HARNESS.md"
        assert summary.falsifiability_ratio == "4/5 (80%)"
        assert summary.drift_score == "2 (low)"

    def test_finds_latest_audit_in_directory(
        self, tmp_path: Path, audit_fixture: Path
    ):
        # Layout: observability/governance/audit-{older,newer}.md.
        gov_dir = tmp_path / "governance"
        gov_dir.mkdir()
        (gov_dir / "audit-2026-04-01.md").write_text("older")
        (gov_dir / "audit-2026-05-09.md").write_text(
            audit_fixture.read_text(encoding="utf-8")
        )
        latest = governance_health.find_latest_audit(gov_dir)
        assert latest is not None
        assert latest.name == "audit-2026-05-09.md"

    def test_no_audit_returns_none(self, tmp_path: Path):
        empty_dir = tmp_path / "governance"
        empty_dir.mkdir()
        assert governance_health.read_latest_audit_summary(empty_dir) is None


# ---------------------------------------------------------------------------
# superpowers-status
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestSuperpowersStatusHelper:
    def test_all_present_when_files_exist(self, tmp_path: Path):
        for relpath in (
            "CLAUDE.md",
            "AGENTS.md",
            "HARNESS.md",
            "MODEL_ROUTING.md",
            "REFLECTION_LOG.md",
        ):
            (tmp_path / relpath).write_text("placeholder")
        report = superpowers_status.check_habitat(tmp_path)
        assert report.all_present
        assert report.missing == []

    def test_missing_files_listed(self, tmp_path: Path):
        # Only CLAUDE.md present; expect 4 missing.
        (tmp_path / "CLAUDE.md").write_text("placeholder")
        report = superpowers_status.check_habitat(tmp_path)
        assert not report.all_present
        missing_names = {f.name for f in report.missing}
        assert "AGENTS.md" in missing_names
        assert "HARNESS.md" in missing_names
        assert "MODEL_ROUTING.md" in missing_names
        assert "REFLECTION_LOG.md" in missing_names


# ---------------------------------------------------------------------------
# reflect
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestReflectHelper:
    def test_format_includes_separator_and_required_fields(self):
        entry = ReflectionEntry(
            date="2026-05-09",
            agent="test-agent",
            task="Do a thing",
            surprise="It was easier than expected",
        )
        rendered = reflect_helper.format_entry(entry)
        # Separator before the entry so it appends cleanly.
        assert "\n---\n" in rendered
        # All required fields present in the rendered text.
        for required in (
            "**Date**: 2026-05-09",
            "**Agent**: test-agent",
            "**Task**: Do a thing",
            "**Surprise**: It was easier than expected",
            "**Proposal**: none",
            "**Improvement**: none",
            "**Signal**: none",
            "**Constraint**: none",
        ):
            assert required in rendered

    def test_session_metadata_emitted_only_when_provided(self):
        entry_no_metadata = ReflectionEntry(
            date="2026-05-09",
            agent="test-agent",
            task="Do a thing",
            surprise="None",
        )
        rendered = reflect_helper.format_entry(entry_no_metadata)
        assert "**Session metadata**" not in rendered

        entry_with_metadata = ReflectionEntry(
            date="2026-05-09",
            agent="test-agent",
            task="Do a thing",
            surprise="None",
            session_metadata=["Duration: 5 min", "Model tiers: capable"],
        )
        rendered = reflect_helper.format_entry(entry_with_metadata)
        assert "**Session metadata**" in rendered
        assert "  - Duration: 5 min" in rendered
        assert "  - Model tiers: capable" in rendered


# ---------------------------------------------------------------------------
# harness-health (quick mode)
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestHarnessHealthHelper:
    def test_aggregate_walks_inputs(
        self, tmp_path: Path, fixtures_dir: Path
    ):
        # Compose a minimal project root with all the inputs the
        # quick-mode aggregate looks at.
        harness_text = (
            fixtures_dir / "procedural" / "sample_harness_status.md"
        ).read_text(encoding="utf-8")
        (tmp_path / "HARNESS.md").write_text(harness_text)
        (tmp_path / "AGENTS.md").write_text("# AGENTS")
        (tmp_path / "REFLECTION_LOG.md").write_text(
            "# Reflection Log\n\n---\n\nentry 1 body\n\n---\n\nentry 2 body\n"
        )
        (tmp_path / "assessments").mkdir()
        (tmp_path / "assessments" / "2026-04-01-assessment.md").write_text(
            "..."
        )
        snapshots_dir = tmp_path / "observability" / "snapshots"
        snapshots_dir.mkdir(parents=True)
        (snapshots_dir / "2026-05-09-snapshot.md").write_text("...")

        snapshot = harness_health.aggregate(tmp_path)

        assert snapshot.enforcement_ratio == "22/23 (96%)"
        assert snapshot.drift_status == "no"
        assert snapshot.reflection_count == 2
        assert snapshot.agents_md_present is True
        assert snapshot.last_assessment_date == "2026-04-01"
        assert snapshot.last_snapshot_date == "2026-05-09"

    def test_missing_inputs_degrade_gracefully(self, tmp_path: Path):
        snapshot = harness_health.aggregate(tmp_path)
        assert snapshot.enforcement_ratio is None
        assert snapshot.reflection_count == 0
        assert snapshot.agents_md_present is False
        assert snapshot.last_assessment_date is None


# ---------------------------------------------------------------------------
# harness-upgrade
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestHarnessUpgradeHelper:
    def test_diff_identifies_new_sections(self):
        template = (
            "# Template\n\n"
            "## Context\n\nbody\n\n"
            "## Constraints\n\nbody\n\n"
            "## Garbage Collection\n\nbody\n\n"
            "## Status\n\nbody\n\n"
            "## Affordances\n\nbody\n"
        )
        project = (
            "# Project\n\n"
            "## Context\n\nbody\n\n"
            "## Constraints\n\nbody\n\n"
            "## Status\n\nbody\n"
        )
        diff = harness_upgrade.diff_harness(template, project)
        assert set(diff.new_headings) == {
            "Garbage Collection",
            "Affordances",
        }
        assert diff.removed_headings == []

    def test_diff_identifies_removed_sections(self):
        template = "# Template\n\n## Context\n\nbody\n"
        project = (
            "# Project\n\n"
            "## Context\n\nbody\n\n"
            "## Custom Section\n\nbody\n"
        )
        diff = harness_upgrade.diff_harness(template, project)
        assert diff.new_headings == []
        assert diff.removed_headings == ["Custom Section"]


# ---------------------------------------------------------------------------
# harness-affordance discover
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestHarnessAffordanceHelper:
    def test_scans_settings_hooks_mcp(self, tmp_path: Path):
        claude_dir = tmp_path / ".claude"
        claude_dir.mkdir()
        (claude_dir / "settings.json").write_text(
            json.dumps(
                {
                    "permissions": {
                        "allow": ["Read", "Bash(git:*)"],
                        "deny": ["Bash(rm -rf:*)"],
                    }
                }
            )
        )
        (claude_dir / "hooks.json").write_text(
            json.dumps({"hooks": {"PreToolUse": [], "Stop": []}})
        )
        (tmp_path / ".mcp.json").write_text(
            json.dumps(
                {
                    "mcpServers": {
                        "honeycomb": {"type": "sse"},
                        "filesystem": {"type": "stdio"},
                    }
                }
            )
        )

        inventory = harness_affordance.discover(tmp_path)
        assert inventory.permissions_allow == ["Read", "Bash(git:*)"]
        assert inventory.permissions_deny == ["Bash(rm -rf:*)"]
        assert inventory.hook_events == ["PreToolUse", "Stop"]
        assert inventory.mcp_servers == ["filesystem", "honeycomb"]

    def test_missing_configs_yield_empty_inventory(self, tmp_path: Path):
        inventory = harness_affordance.discover(tmp_path)
        assert inventory.permissions_allow == []
        assert inventory.hook_events == []
        assert inventory.mcp_servers == []

    def test_malformed_json_does_not_crash(self, tmp_path: Path):
        claude_dir = tmp_path / ".claude"
        claude_dir.mkdir()
        (claude_dir / "settings.json").write_text("{ this is not json")
        inventory = harness_affordance.discover(tmp_path)
        assert inventory.permissions_allow == []


# ---------------------------------------------------------------------------
# cost-capture
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestCostCaptureHelper:
    @pytest.fixture
    def costs_fixture(self, fixtures_dir: Path) -> Path:
        return fixtures_dir / "procedural" / "sample_cost_snapshot.md"

    def test_parses_summary_fields(self, costs_fixture: Path):
        text = costs_fixture.read_text(encoding="utf-8")
        snapshot = cost_capture.parse_snapshot(text)
        assert snapshot.capture_date == "2026-05-09"
        assert snapshot.total_spend == "$42.18 (rolling 7 days)"
        assert snapshot.primary_provider == "Anthropic"

    def test_find_latest_picks_chronologically(
        self, tmp_path: Path, costs_fixture: Path
    ):
        costs_dir = tmp_path / "costs"
        costs_dir.mkdir()
        (costs_dir / "2026-04-01-costs.md").write_text("older")
        (costs_dir / "2026-05-09-costs.md").write_text(
            costs_fixture.read_text(encoding="utf-8")
        )
        latest = cost_capture.find_latest_snapshot(costs_dir)
        assert latest is not None
        assert latest.name == "2026-05-09-costs.md"

    def test_empty_costs_dir_returns_none(self, tmp_path: Path):
        costs_dir = tmp_path / "costs"
        costs_dir.mkdir()
        assert cost_capture.read_latest(costs_dir) is None
