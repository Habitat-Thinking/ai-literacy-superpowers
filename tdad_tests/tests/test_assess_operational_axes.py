"""Structural tests for the /assess ALCI Part D alignment (v0.40.0).

These are offline, deterministic, file-shape assertions translating the
acceptance scenarios in the design spec:

    docs/superpowers/specs/2026-06-01-assess-operational-axes-design.md

The framework's ALCI was extended upstream with Part D (four operational
axes) and the Habitat Build Gap. /assess is brought into line. The
behavioural contract (that a live /assess run places the axes and
computes a correct gap) is documentation-only at this layer, consistent
with how the plugin's other commands are tested offline.

A load-bearing requirement is SELF-CONTAINMENT: the plugin ships
standalone via the marketplace, so no assess artifact may read the
upstream framework repo at runtime. The four axes' full marker text is
embedded in references/operational-axes.md; the only upstream mention is
the provenance/attribution block in that one file.
"""

from pathlib import Path

import json

import pytest


SKILL_DIR_NAME = "ai-literacy-assessment"


@pytest.fixture(scope="module")
def assess_paths(plugin_path: Path) -> dict:
    """Resolve the assess-related artifact paths once per module."""
    skill = plugin_path / "skills" / SKILL_DIR_NAME
    refs = skill / "references"
    repo_root = plugin_path.parent
    return {
        "repo_root": repo_root,
        "command": plugin_path / "commands" / "assess.md",
        "skill": skill / "SKILL.md",
        "agent": plugin_path / "agents" / "assessor.agent.md",
        "template": refs / "assessment-template.md",
        "operational_axes": refs / "operational-axes.md",
        "sophistication": refs / "sophistication-markers.md",
        "tool_config": refs / "tool-config-evidence.md",
        "how_to": repo_root
        / "docs"
        / "plugins"
        / "ai-literacy-superpowers"
        / "how-to"
        / "run-an-assessment.md",
        "plugin_json": plugin_path / ".claude-plugin" / "plugin.json",
        "marketplace": repo_root / ".claude-plugin" / "marketplace.json",
        "changelog": repo_root / "CHANGELOG.md",
    }


FOUR_AXES = ("Composition", "Testing", "Observability", "Governance")
REGIMES = (
    "Coherent",
    "Ambition outpaces enablement",
    "Inherited habitat",
)


# -- Scenario 5: the new self-contained reference exists --------------


def test_operational_axes_reference_exists(assess_paths: dict) -> None:
    """Scenario 5: references/operational-axes.md exists."""
    page = assess_paths["operational_axes"]
    assert page.is_file(), (
        f"Expected the self-contained operational-axes reference at "
        f"{page} (spec §6)."
    )


def test_operational_axes_reference_names_four_axes_with_markers(
    assess_paths: dict,
) -> None:
    """Scenario 5: the reference names all four axes and embeds L1–L5
    marker text (proves the content is embedded, not referenced)."""
    body = assess_paths["operational_axes"].read_text()
    for axis in FOUR_AXES:
        assert axis in body, (
            f"operational-axes.md must name the {axis!r} axis."
        )
    # Embedded marker text — distinctive quotes from framework Part D.
    embedded_markers = [
        "Agents self-orchestrate into constellations",  # Composition L5
        "We use mutation testing to verify our tests",  # Testing L2
        "Observability is closed-loop",  # Observability L5
        "written constitution (CLAUDE.md / HARNESS.md)",  # Governance L3
    ]
    for marker in embedded_markers:
        assert marker in body, (
            "operational-axes.md must EMBED the verbatim L1–L5 marker "
            f"text (self-containment, §2.4). Missing: {marker!r}"
        )


# -- Scenario 3: Habitat Build Gap formula + regimes -----------------


def test_habitat_build_gap_formula_and_regimes(assess_paths: dict) -> None:
    """Scenario 3: the gap formula and the three interpretation regimes
    are documented in the reference."""
    body = assess_paths["operational_axes"].read_text()
    assert "level_placement − operational_axes_mean" in body, (
        "operational-axes.md must document the Habitat Build Gap "
        "formula `level_placement − operational_axes_mean` (spec §4)."
    )
    for regime in REGIMES:
        assert regime in body, (
            f"operational-axes.md must name the {regime!r} interpretation "
            "regime (spec §4)."
        )


# -- Scenario 1 + 2: assessment template sections --------------------


def test_template_has_operational_axes_and_gap_sections(
    assess_paths: dict,
) -> None:
    """Scenario 1: the template carries both new sections."""
    body = assess_paths["template"].read_text()
    assert "## Operational Axes (ALCI Part D)" in body, (
        "assessment-template.md must add a `## Operational Axes "
        "(ALCI Part D)` section (spec §6)."
    )
    assert "## Habitat Build Gap" in body, (
        "assessment-template.md must add a `## Habitat Build Gap` "
        "section (spec §6)."
    )


def test_template_operational_axes_table_names_axes(
    assess_paths: dict,
) -> None:
    """Scenario 2: the template's Operational Axes table names all four
    axes and has a placement + evidence column."""
    body = assess_paths["template"].read_text()
    for axis in FOUR_AXES:
        assert axis in body, (
            f"assessment-template.md Operational Axes table must row the "
            f"{axis!r} axis (spec §6)."
        )
    assert "| Axis | Placement | Evidence |" in body, (
        "assessment-template.md must give the Operational Axes table a "
        "`Axis | Placement | Evidence` header (spec §6)."
    )


# -- Scenario 4 + 8: SKILL documents Part D + hybrid -----------------


def test_skill_documents_part_d(assess_paths: dict) -> None:
    """Scenario 4: the SKILL documents the four axes, the gap, and the
    regimes."""
    body = assess_paths["skill"].read_text()
    assert "Operational Axes (ALCI Part D)" in body, (
        "SKILL.md must document the Operational Axes (ALCI Part D) "
        "section (spec §6)."
    )
    for axis in FOUR_AXES:
        assert axis in body, f"SKILL.md must name the {axis!r} axis."
    assert "Habitat Build Gap = level_placement − operational_axes_mean" in body, (
        "SKILL.md must document the Habitat Build Gap formula."
    )


def test_skill_documents_hybrid_administration(assess_paths: dict) -> None:
    """Scenario 8: the SKILL documents both the evidence-first default
    and the opt-in survey."""
    body = assess_paths["skill"].read_text()
    assert "Evidence-first" in body or "evidence-first" in body, (
        "SKILL.md must document the evidence-first default (spec §5.1)."
    )
    assert "40-statement" in body, (
        "SKILL.md must document the opt-in 40-statement survey "
        "(spec §5.2)."
    )


# -- Scenario 6: assessor agent --------------------------------------


def test_agent_gathers_axes_and_computes_gap(assess_paths: dict) -> None:
    """Scenario 6: the assessor agent gathers per-axis evidence, emits
    the sections, computes the gap, and cross-references governance."""
    body = assess_paths["agent"].read_text()
    assert "operational-axes.md" in body, (
        "assessor agent must point at references/operational-axes.md "
        "for the axis methodology (self-contained source)."
    )
    assert "Habitat Build Gap" in body, (
        "assessor agent must compute the Habitat Build Gap (spec §6)."
    )
    # Governance axis ↔ Governance Dimension cross-reference + consistency.
    assert "Governance Dimension" in body and "Governance axis" in body, (
        "assessor agent must cross-reference the Governance axis and the "
        "Governance Dimension (spec §7)."
    )
    assert "consistent" in body, (
        "assessor agent must state the Governance axis and Dimension "
        "report a consistent level (spec §7)."
    )


# -- Scenario 7: command document step + validation checkpoint -------


def test_command_documents_sections_and_checkpoint(
    assess_paths: dict,
) -> None:
    """Scenario 7: the command documents the new document sections and a
    validation checkpoint covering them."""
    body = assess_paths["command"].read_text()
    assert "Operational Axes (ALCI Part D)" in body, (
        "assess.md must document the Operational Axes section in the "
        "document step (spec §6)."
    )
    assert "Habitat Build Gap" in body, (
        "assess.md must document the Habitat Build Gap (spec §6)."
    )
    # Validation checkpoint covers gap consistency + governance match.
    assert "level placement minus the operational axes mean" in body, (
        "assess.md validation checkpoint must verify gap = level − mean "
        "(spec §6, checkpoint check 6)."
    )
    assert "Governance axis placement matches the Governance Dimension" in body, (
        "assess.md validation checkpoint must verify the two governance "
        "views do not diverge (spec §6, checkpoint check 7)."
    )


def test_command_offers_optin_survey(assess_paths: dict) -> None:
    """Scenario 8: the command offers the opt-in survey."""
    body = assess_paths["command"].read_text()
    assert "opt-in" in body and "survey" in body, (
        "assess.md must offer the opt-in ALCI Part D survey (spec §5.2)."
    )


# -- Scenario 9: version triplet at 0.40.0 ---------------------------


def test_plugin_json_at_0_40_0(assess_paths: dict) -> None:
    """Scenario 9: plugin.json is at 0.40.0."""
    manifest = json.loads(assess_paths["plugin_json"].read_text())
    assert manifest["version"] == "0.40.0", (
        f"plugin.json must be 0.40.0 (was 0.39.1). Actual: "
        f"{manifest['version']!r}"
    )


def test_marketplace_entry_and_plugin_version_at_0_40_0(
    assess_paths: dict,
) -> None:
    """Scenario 9: the ai-literacy-superpowers marketplace entry version
    and the top-level plugin_version are 0.40.0; the top-level listing
    `version` is unchanged."""
    marketplace = json.loads(assess_paths["marketplace"].read_text())
    entry = next(
        p
        for p in marketplace["plugins"]
        if p["name"] == "ai-literacy-superpowers"
    )
    assert entry["version"] == "0.40.0", (
        f"ai-literacy-superpowers marketplace entry must be 0.40.0. "
        f"Actual: {entry['version']!r}"
    )
    assert marketplace["plugin_version"] == "0.40.0", (
        f"marketplace plugin_version must track 0.40.0. Actual: "
        f"{marketplace['plugin_version']!r}"
    )
    assert marketplace["version"] == "0.4.0", (
        "top-level marketplace listing `version` must be unchanged at "
        f"0.4.0 (plugin behavioural bump does not move it). Actual: "
        f"{marketplace['version']!r}"
    )


def test_changelog_has_0_40_0_heading(assess_paths: dict) -> None:
    """Scenario 9: the CHANGELOG has a 0.40.0 heading."""
    body = assess_paths["changelog"].read_text()
    assert "## 0.40.0 — 2026-06-01" in body, (
        "CHANGELOG.md must have a `## 0.40.0 — 2026-06-01` heading "
        "(note the em dash, not a hyphen)."
    )


# -- Scenario 10: docs how-to ----------------------------------------


def test_how_to_documents_axes_and_gap(assess_paths: dict) -> None:
    """Scenario 10: run-an-assessment.md documents the operational axes
    and the Habitat Build Gap."""
    body = assess_paths["how_to"].read_text()
    assert "Habitat Build Gap" in body, (
        "run-an-assessment.md must document the Habitat Build Gap "
        "(spec §6)."
    )
    for axis in FOUR_AXES:
        assert axis in body, (
            f"run-an-assessment.md must name the {axis!r} axis."
        )


# -- Scenario 11: no upstream runtime dependency ---------------------


def test_no_upstream_runtime_dependency(assess_paths: dict) -> None:
    """Scenario 11: the execution artifacts (command, SKILL, agent,
    template, evidence references) contain no reference to the upstream
    framework repo — all Part D content is embedded locally. The only
    permitted upstream mention is the provenance block in
    operational-axes.md (attribution + re-sync pointer, not a runtime
    read)."""
    upstream = "ai-literacy-for-software-engineers"
    execution_artifacts = (
        "command",
        "skill",
        "agent",
        "template",
        "sophistication",
        "tool_config",
        "how_to",
    )
    for key in execution_artifacts:
        body = assess_paths[key].read_text()
        assert upstream not in body, (
            f"{key} ({assess_paths[key].name}) must not reference the "
            f"upstream repo {upstream!r} — Part D content is embedded in "
            "operational-axes.md; no artifact reads the upstream repo at "
            "runtime (spec §2.4 / scenario 11)."
        )
    # operational-axes.md may name the upstream ONLY in provenance, and
    # must embed the markers (proven by the embedded-markers test above).
    ref_body = assess_paths["operational_axes"].read_text()
    assert "Provenance" in ref_body, (
        "operational-axes.md must confine its single upstream mention to "
        "a clearly-marked Provenance block (spec §2.4)."
    )
