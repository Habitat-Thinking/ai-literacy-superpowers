"""Layer 1 structural content checks for dynamic-workflows S5.

These tests are the *deterministic mechanism* behind the structural
scenarios authored at ``scenarios/agents/orchestrator/`` and
``scenarios/commands/superpowers-status/`` for slice S5 (the
orchestrator classify-and-act routing step + the superpowers-status
routing surface).

Per the spec's §6 decision 2 (the verification split), this repo's
deterministic layer reads files and matches structure — it does **not**
dispatch the orchestrator or classify a live task. So what is
deterministically asserted here is that the orchestrator doc **declares**
the routing contract (classification step before the pipeline; the
``orchestrator-routing`` opt-in flag, default off; static-is-the-sole-
default stated three ways; the four routes + triggers + adapt-by-relative-
path; the GATE/GUARDRAIL-hold-on-every-route invariant; the
Claude-Code-only scope + non-erroring static fallback; the INV-1
propose-only boundary + tools-unchanged; the INV-2 triage quarantine) and
that ``superpowers-status`` **documents** the routing posture + last-route
surface. The live properties (AC-1 routine→static, AC-2 taste→tournament,
AC-3 incident→root-cause) are agent-backed and live as ``behavioural``
scenarios, not wired here. AC-4 (GATE/GUARDRAIL hold across a real
non-static route) is unverified/declared; its structural shadow (the doc
*states* the invariant) is asserted here.

RED state (before S5 implements): ``orchestrator.agent.md`` has no
"Task classification" / "Workflow routing" section and
``superpowers-status.md`` documents no routing posture / last-route
surface, so every declaration assertion below fails on missing content —
RED for the right reason (missing content, not a malformed scenario or an
unresolvable component; both components already exist). The
tools-unchanged check is GREEN today and stays green.

Line-wrap note (the trap that bit S3 twice and S4 twice): a required
two-word phrase that an implementer might wrap across a line is NOT
asserted as a single substring. Where a guarantee needs two terms to
co-occur, they are asserted as two independent ``in`` checks on the
lowercased section so a wrapped phrase still passes. Single load-bearing
tokens (filenames, ``orchestrator-routing``, ``harness.md``,
``max_review_cycles``) are wrap-safe and asserted directly; ``claude
code`` is two words and is split.

Spec: docs/superpowers/specs/2026-06-23-dynamic-workflows-s5-orchestrator-routing-design.md
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


def _routing_section(plugin_path: Path, name: str, component_type: str) -> str:
    """Return the text from the 'Task classification' / 'Workflow routing'
    heading to the next same-or-higher-level heading, lowercased. Empty
    string if absent."""
    text = _component_text(plugin_path, name, component_type)
    m = re.search(
        r"^(#{2,4})\s+.*(task classification|workflow routing).*$",
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


# ---------------------------------------------------------------------------
# AC-5 — classification step before the pipeline; opt-in flag; static-default
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS5OrchestratorClassificationStep:
    """Structural shadow of AC-5 (and AC-1) — orchestrator.agent.md must
    *declare* a classification step before the pipeline, the
    ``orchestrator-routing`` opt-in flag (default off), and the
    static-default supremacy rule (scenarios under
    ``scenarios/agents/orchestrator/``)."""

    def _section(self, plugin_path: Path) -> str:
        return _routing_section(plugin_path, "orchestrator", "agent")

    def test_classification_section_exists(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert section, (
            "orchestrator.agent.md must contain a 'Task classification' or "
            "'Workflow routing' section (AC-5 / FR-1). None found."
        )

    def test_declares_classification_runs_before_pipeline(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        # Wrap-safe: assert the routing step runs before the pipeline / as
        # the first action, asserting co-occurring tokens.
        assert "pipeline" in section and (
            "before" in section or "first action" in section
        ), (
            "Classification section must state it runs before the pipeline "
            "dispatches / as the first action (AC-5 / FR-1). Keep 'first "
            "action' unwrapped."
        )

    def test_declares_orchestrator_routing_flag_default_off(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        # 'orchestrator-routing' and 'harness.md' are single unwrappable
        # tokens; default-off is asserted via co-occurring tokens.
        assert "orchestrator-routing" in section and "harness.md" in section, (
            "Classification section must name the explicit opt-in flag — the "
            "optional `orchestrator-routing` field in HARNESS.md (AC-5 / "
            "FR-2, §6 decision 1 M1). Both tokens are single/unwrappable."
        )
        assert ("default" in section or "absent" in section) and (
            "off" in section
        ), (
            "Classification section must state the flag defaults to off when "
            "absent (AC-5 / FR-2 / §9 safe-default — the conservative "
            "direction)."
        )

    def test_declares_static_is_sole_default_three_ways(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        # Static-default supremacy: flag-off, ordinary coding, AND ambiguous
        # all select static, with no extra compute. Wrap-safe co-occurrence.
        assert "static" in section and "default" in section, (
            "Classification section must state the static pipeline is the "
            "sole default (AC-5 / FR-3). Keep 'static pipeline' unwrapped."
        )
        assert ("flag-off" in section or "flag off" in section) and (
            "ambiguous" in section
        ), (
            "Classification section must state the static pipeline is "
            "selected for flag-off, ordinary coding, AND ambiguous "
            "classification alike (AC-5 / FR-3 — the static-default "
            "supremacy rule, stated three ways). Keep 'ambiguous' unwrapped."
        )
        assert "no extra compute" in section or (
            "no" in section and "extra compute" in section
        ), (
            "Classification section must state the flag-off / static no-op "
            "spends no extra compute (AC-5 / FR-3, the over-orchestration "
            "guard). Keep 'extra compute' unwrapped."
        )


# ---------------------------------------------------------------------------
# AC-6 — the four routes and their triggers
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS5OrchestratorFourRoutes:
    """Structural shadow of AC-6 (and AC-2, AC-3) — the classification
    section must declare all four routes + triggers + adapt-by-relative-path
    (scenarios under ``scenarios/agents/orchestrator/``)."""

    def _section(self, plugin_path: Path) -> str:
        return _routing_section(plugin_path, "orchestrator", "agent")

    def test_declares_static_route(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert "static pipeline" in section or (
            "static" in section and "ordinary coding" in section
        ), (
            "Classification section must declare the static route — ordinary "
            "coding → the existing static pipeline (the default) (AC-6 / "
            "FR-4). Keep 'static pipeline' unwrapped."
        )

    def test_declares_tournament_route(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert "tournament" in section and "rubric-bearing judge" in section, (
            "Classification section must declare the tournament route — "
            "design/naming/taste → a tournament with a rubric-bearing judge "
            "(AC-6 / FR-4; structural shadow of AC-2). Keep 'rubric-bearing "
            "judge' unwrapped."
        )

    def test_declares_root_cause_route(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert "root-cause" in section and "hypotheses" in section and (
            "3" in section
        ), (
            "Classification section must declare the root-cause route — "
            "debugging/flaky-test/incident → root-cause investigation with "
            "≥3 independent hypotheses (AC-6 / FR-4; structural shadow of "
            "AC-3). Keep 'root-cause' unwrapped."
        )

    def test_declares_root_cause_disjoint_evidence_and_panel(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "disjoint" in section and "evidence" in section, (
            "Classification section must declare the root-cause hypotheses "
            "come from disjoint evidence (AC-6 / FR-4). Keep 'disjoint "
            "evidence' unwrapped."
        )
        assert "verif" in section or "refut" in section, (
            "Classification section must declare the root-cause route runs a "
            "verifier/refuter panel (AC-6 / FR-4)."
        )

    def test_declares_triage_route_under_inv2(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert "triage" in section and (
            "inv-2" in section or "quarantine" in section
        ), (
            "Classification section must declare the triage route — large "
            "backlogs → triage-at-scale under INV-2 quarantine (AC-6 / "
            "FR-4). Keep 'triage' unwrapped."
        )

    def test_declares_adapts_template_by_relative_path(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert ".workflow.js" in section and "adapt" in section and (
            "relative path" in section
        ), (
            "Classification section must state any non-static route ADAPTs "
            "the relevant `*.workflow.js` template by relative path — ADAPT, "
            "not verbatim (AC-6 / FR-4)."
        )


# ---------------------------------------------------------------------------
# AC-7 (structural shadow of AC-4) — GATE/GUARDRAIL hold on every route
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS5OrchestratorGateGuardrailInvariant:
    """Structural shadow of AC-7 / AC-4 — the classification section must
    state the Plan Approval GATE and MAX_REVIEW_CYCLES=3 GUARDRAIL hold on
    every route (scenarios under ``scenarios/agents/orchestrator/``).

    AC-4 (live enforcement across a real non-static route) is
    unverified/declared and is NOT asserted here — only the doc's
    declaration of the invariant is checkable from a file read."""

    def _section(self, plugin_path: Path) -> str:
        return _routing_section(plugin_path, "orchestrator", "agent")

    def test_declares_plan_approval_gate_holds(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "plan approval" in section and "gate" in section, (
            "Classification section must state the Plan Approval GATE remains "
            "in force on every route (AC-7 / FR-5). Keep 'Plan Approval' "
            "unwrapped."
        )

    def test_declares_max_review_cycles_guardrail_holds(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "max_review_cycles" in section and "3" in section, (
            "Classification section must state the MAX_REVIEW_CYCLES=3 "
            "GUARDRAIL remains in force on every route (AC-7 / FR-5). Keep "
            "'MAX_REVIEW_CYCLES' unwrapped."
        )

    def test_declares_invariant_holds_on_every_route(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        assert "every route" in section and (
            "gate" in section or "guardrail" in section
        ), (
            "Classification section must state the GATE/GUARDRAIL hold on "
            "EVERY route (static and non-static alike) — no route bypasses, "
            "weakens, or multiplies them (AC-7 / FR-5). Keep 'every route' "
            "unwrapped."
        )


# ---------------------------------------------------------------------------
# AC-8 / AC-9 — Claude-Code scope + fallback; INV-1 propose-only; INV-2
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS5OrchestratorClaudeCodeScopeAndInvariants:
    """Structural shadow of AC-8 / AC-9 — the classification section must
    declare the Claude-Code-only scope + non-erroring static fallback, the
    INV-1 propose-only boundary, and the INV-2 triage quarantine
    (scenarios under ``scenarios/agents/orchestrator/``)."""

    def _section(self, plugin_path: Path) -> str:
        return _routing_section(plugin_path, "orchestrator", "agent")

    def test_declares_claude_code_scope_and_fallback(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        # 'claude code' is two words — split it.
        assert "claude" in section and "code" in section and (
            "fall back" in section
            or "falls back" in section
            or "fallback" in section
        ) and ("never error" in section), (
            "Classification section must state the non-static routes require "
            "the Claude Code runtime and that on a tree without it — or with "
            "the flag off — the classifier selects the static pipeline and "
            "never errors (AC-8 / FR-6). Keep 'Claude Code' unwrapped."
        )

    def test_declares_propose_only_never_writes_durable(
        self, plugin_path: Path
    ) -> None:
        section = self._section(plugin_path)
        # The prohibition is on the four durable curated artefacts; assert
        # 'durable' + 'propose' co-occur with at least two named artefacts.
        named = sum(
            t in section
            for t in (
                "harness.md",
                "agents.md",
                "claude.md",
                "model_routing.md",
            )
        )
        assert "durable" in section and "propose" in section and named >= 2, (
            "Classification section must state every route is propose-only — "
            "any workflow a route spawns never writes a durable curated "
            "artefact (HARNESS.md/AGENTS.md/CLAUDE.md/MODEL_ROUTING.md) "
            "(AC-9 / FR-7 / INV-1). Keep 'durable artefact' unwrapped."
        )

    def test_declares_inv2_triage_quarantine(self, plugin_path: Path) -> None:
        section = self._section(plugin_path)
        assert "low-privilege" in section and "trusted" in section and (
            "inv-2" in section or "quarantine" in section
        ), (
            "Classification section must state the triage route reads "
            "untrusted/public content only with low-privilege agents and "
            "that only separate trusted agents act on it (AC-9 / FR-8 / "
            "INV-2). Keep 'low-privilege' unwrapped."
        )


@pytest.mark.structural
class TestS5OrchestratorToolsUnchanged:
    """AC-9 / FR-7: the orchestrator's `tools` list is unchanged — the
    classification step adds no new write capability. GREEN today and must
    STAY green through S5."""

    # The current tool set, read from the live frontmatter. S5 must not
    # alter it; this asserts the exact set stays put (it does NOT assert a
    # specific new tool).
    _EXPECTED = ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Agent", "WebFetch"]

    def test_tools_unchanged(self, plugin_path: Path) -> None:
        component = plugin_runner.find_component(
            plugin_path, name="orchestrator", component_type="agent"
        )
        tools = component.frontmatter.get("tools") or []
        assert tools == self._EXPECTED, (
            f"orchestrator `tools` must stay unchanged through S5 — the "
            f"classification step adds no new write capability (AC-9 / FR-7 / "
            f"INV-1). Expected {self._EXPECTED!r}, got {tools!r}."
        )


# ---------------------------------------------------------------------------
# AC-10 — superpowers-status surfaces routing posture + last route
# ---------------------------------------------------------------------------


@pytest.mark.structural
class TestS5SuperpowersStatusRouteSurface:
    """Structural shadow of AC-10 — commands/superpowers-status.md must
    document a routing surface reporting posture (opt-in/off-by-default vs
    enabled) and the last route taken (else unavailable) (scenario under
    ``scenarios/commands/superpowers-status/``)."""

    def _text(self, plugin_path: Path) -> str:
        return _component_text(
            plugin_path, "superpowers-status", "command"
        ).lower()

    def test_documents_routing_posture(self, plugin_path: Path) -> None:
        text = self._text(plugin_path)
        assert "routing" in text and "opt-in" in text and (
            "enabled" in text
        ) and ("off" in text and "default" in text), (
            "superpowers-status.md must document the routing posture — "
            "`opt-in, off by default` (absent/off) vs `enabled` (set), read "
            "from the orchestrator-routing HARNESS.md field (AC-10 / FR-9). "
            "Keep 'opt-in' and 'off by default' unwrapped."
        )

    def test_documents_last_route_or_unavailable(
        self, plugin_path: Path
    ) -> None:
        text = self._text(plugin_path)
        assert "route" in text and "unavailable" in text, (
            "superpowers-status.md must document the most-recent route taken "
            "when a durable trace exists, degrading to `unavailable` "
            "otherwise (AC-10 / FR-9, §6 decision 3 / S1). Keep 'last route' "
            "and 'unavailable' unwrapped."
        )

    def test_documents_four_route_names(self, plugin_path: Path) -> None:
        text = self._text(plugin_path)
        assert all(
            r in text for r in ("static", "tournament", "root-cause", "triage")
        ), (
            "superpowers-status.md must name the four routes the last-route "
            "surface can report (static / tournament / root-cause / triage) "
            "(AC-10 / FR-9). Keep 'root-cause' unwrapped."
        )
