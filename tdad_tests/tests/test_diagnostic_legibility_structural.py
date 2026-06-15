"""Layer 1 structural tests for the diagnostic-legibility plugin at
v0.3.0 / v0.4.0 / v0.5.0 / v0.6.0 / v0.7.0 / v0.8.0.

Sub-S2b shipped the working `diagnostic-legibility` agent (v0.3.0); S3
shipped the cross-check (v0.4.0); S4 shipped the human-facing `/diagnose`
command (v0.5.0); P1 of the pipeline-map feature shipped the standalone
`ConceptualPipelineMap` data-model template (v0.6.0); P2 added the
front-of-pipeline `mode: scope-resolution` capability (v0.7.0); P3 adds
`mode: pipeline` — within the resolved bound, trace control flow into a
ConceptualPipelineMap and build the architectural/domain collections,
self-challenging pipeline stages through a flow-flavoured five-question
cover plus a scope-relevance feedback loop (v0.8.0; cross-check deferred
to P4). These are deterministic, file-shape assertions — the agent's and
command's behavioural contracts are covered by their specs as acceptance
documentation rather than executable tests.

The TDAD scenario discipline does not extend to the diagnostic-legibility
plugin (the TDAD-scenario-check workflow is scoped to the
`ai-literacy-superpowers/` plugin only). Story #7 / issue #338 documents
the intentional gap. This file is the deterministic structural layer that
guards each slice's deliverables; it mirrors the precedent set by
`test_model_cards_structural.py` for the sibling plugin.

Spec references:
    docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md
    docs/superpowers/specs/2026-05-29-dl-s3-cross-check-mechanism-design.md
    docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md
    docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from runner import plugin as plugin_runner  # noqa: E402


# Resolve the diagnostic-legibility plugin directory once. Mirrors the
# `model_cards_path` fixture pattern in conftest.py but kept local to
# this test module because no other test file in the suite targets the
# diagnostic-legibility plugin at v0.3.0.
@pytest.fixture(scope="module")
def diagnostic_legibility_path() -> Path:
    repo_root = Path(__file__).resolve().parent.parent.parent
    packaged = repo_root / "diagnostic-legibility"
    if not packaged.is_dir():
        pytest.fail(
            f"diagnostic-legibility plugin directory not found at "
            f"{packaged!r}. Has it been moved or renamed?"
        )
    return packaged


@pytest.fixture(scope="module")
def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent.parent


# ---------------------------------------------------------------------
# Versioning
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestDiagnosticLegibilityVersioning:
    """The P3 plugin version bump from 0.7.0 to 0.8.0 must land in
    lockstep across plugin.json, marketplace.json's per-plugin entry,
    and the CHANGELOG heading. A new agent capability (the
    `mode: pipeline` flow-tracing build) is a behavioural plugin change,
    so P3 takes a minor bump (P1/P2 took the same; S2a/S3 precedent).

    The marketplace listing's top-level `version` (0.4.0) and its
    `plugin_version` pointer are explicitly unchanged by this slice —
    the spec §9 names this and the integration-agent is responsible for
    taking `plugin_version` from main verbatim at rebase time.
    """

    def test_plugin_json_at_0_8_0(
        self, diagnostic_legibility_path: Path
    ) -> None:
        manifest_path = (
            diagnostic_legibility_path
            / ".claude-plugin"
            / "plugin.json"
        )
        manifest = json.loads(manifest_path.read_text())
        assert manifest["version"] == "0.8.0", (
            "diagnostic-legibility/.claude-plugin/plugin.json must "
            "carry version '0.8.0' (was '0.7.0' at P2). "
            f"Actual: {manifest['version']!r}"
        )

    def test_marketplace_entry_at_0_8_0(self, repo_root: Path) -> None:
        marketplace_path = (
            repo_root / ".claude-plugin" / "marketplace.json"
        )
        marketplace = json.loads(marketplace_path.read_text())
        entry = next(
            (
                p
                for p in marketplace["plugins"]
                if p["name"] == "diagnostic-legibility"
            ),
            None,
        )
        assert entry is not None, (
            "No diagnostic-legibility entry in marketplace.json plugins[]"
        )
        assert entry["version"] == "0.8.0", (
            "marketplace.json diagnostic-legibility entry must be at "
            f"'0.8.0' (was '0.7.0' at P2). Actual: {entry['version']!r}"
        )

    def test_marketplace_top_level_version_unchanged(
        self, repo_root: Path
    ) -> None:
        marketplace_path = (
            repo_root / ".claude-plugin" / "marketplace.json"
        )
        marketplace = json.loads(marketplace_path.read_text())
        assert marketplace["version"] == "0.4.0", (
            "marketplace.json top-level `version` must remain at '0.4.0' "
            "per spec §9 (a per-plugin entry's content change is the "
            "plugin's own contract, not the listing contract). "
            f"Actual: {marketplace['version']!r}"
        )

    def test_marketplace_plugin_version_matches_canonical(
        self, repo_root: Path
    ) -> None:
        """Per spec §9 (code-mode O3), `plugin_version` is owned by
        ai-literacy-superpowers PRs. This test asserts the field tracks
        the canonical plugin.json rather than a hard-coded literal — so
        if main bumps ai-literacy-superpowers between spec-time and
        merge-time, the integration-agent's rebase resolves the conflict
        in main's favour and this test still passes. A redundancy check
        on top of the version-consistency CI workflow.
        """
        marketplace_path = (
            repo_root / ".claude-plugin" / "marketplace.json"
        )
        canonical_path = (
            repo_root
            / "ai-literacy-superpowers"
            / ".claude-plugin"
            / "plugin.json"
        )
        marketplace = json.loads(marketplace_path.read_text())
        canonical = json.loads(canonical_path.read_text())
        assert marketplace["plugin_version"] == canonical["version"], (
            "marketplace.json `plugin_version` must equal the canonical "
            "ai-literacy-superpowers/.claude-plugin/plugin.json `version`. "
            f"marketplace.json: {marketplace['plugin_version']!r}; "
            f"canonical: {canonical['version']!r}. If these disagree, "
            "this PR has either drifted from main or bumped a value it "
            "does not own (per spec §9)."
        )

    def test_changelog_has_0_8_0_heading(
        self, diagnostic_legibility_path: Path
    ) -> None:
        changelog = (
            diagnostic_legibility_path / "CHANGELOG.md"
        ).read_text()
        assert "## 0.8.0 — 2026-06-15" in changelog, (
            "CHANGELOG.md must contain a `## 0.8.0 — 2026-06-15` heading "
            "naming the P3 pipeline mode. Note: the dash is the em-dash "
            "(U+2014), matching the format enforced by the "
            "version-consistency CI check."
        )

    def test_changelog_prior_headings_persist(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Audit trail: the prior v0.7.0 (P2), v0.6.0 (P1) and v0.5.0
        (S4) headings must remain when v0.8.0 is prepended."""
        changelog = (
            diagnostic_legibility_path / "CHANGELOG.md"
        ).read_text()
        for heading in (
            "## 0.7.0 — 2026-06-15",
            "## 0.6.0 — 2026-06-14",
            "## 0.5.0 — 2026-06-01",
        ):
            assert heading in changelog, (
                f"Prior `{heading}` heading must persist as the CHANGELOG "
                "audit trail when v0.8.0 is added."
            )

    def test_changelog_references_followup_issues(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The v0.4.0 entry must name #347 (granularity-routing schema
        discipline promotion — paired Stories #1+#4) and #348
        (dispatcher-first error contracts promotion — Story #6). The
        prior v0.3.0 entry continues to name #338 and #339; those
        references must persist too."""
        changelog = (
            diagnostic_legibility_path / "CHANGELOG.md"
        ).read_text()
        # New v0.4.0 follow-ups
        assert "#347" in changelog, (
            "v0.4.0 CHANGELOG entry must reference #347 (granularity-"
            "routing schema discipline promotion follow-up — paired "
            "Stories #1 and #4)."
        )
        assert "#348" in changelog, (
            "v0.4.0 CHANGELOG entry must reference #348 (dispatcher-first "
            "error contracts promotion follow-up — Story #6)."
        )
        # Prior v0.3.0 follow-ups should still be in the file (audit
        # trail preservation)
        assert "#338" in changelog, (
            "Prior v0.3.0 CHANGELOG entry's reference to #338 must "
            "persist (audit trail)."
        )
        assert "#339" in changelog, (
            "Prior v0.3.0 CHANGELOG entry's reference to #339 must "
            "persist (audit trail)."
        )


# ---------------------------------------------------------------------
# Agent file
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestDiagnosticLegibilityAgent:
    """The agent file replaces the .gitkeep placeholder from v0.1.0 and
    must carry the expected frontmatter. The body's full behavioural
    contract is covered by the spec; this test only guards file-shape
    and tool-boundary invariants that downstream consumers depend on.
    """

    def test_gitkeep_removed(
        self, diagnostic_legibility_path: Path
    ) -> None:
        gitkeep = diagnostic_legibility_path / "agents" / ".gitkeep"
        assert not gitkeep.exists(), (
            "diagnostic-legibility/agents/.gitkeep must be removed once "
            "the agent file lands. The placeholder is no longer needed "
            "and its presence signals an incomplete migration."
        )

    def test_agent_file_present(
        self, diagnostic_legibility_path: Path
    ) -> None:
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        assert agent_file.is_file(), (
            "Expected agent file at "
            f"{agent_file.relative_to(diagnostic_legibility_path.parent)}"
        )

    def test_agent_frontmatter_name(
        self, diagnostic_legibility_path: Path
    ) -> None:
        component = plugin_runner.find_component(
            diagnostic_legibility_path,
            name="diagnostic-legibility",
            component_type="agent",
        )
        assert component.parse_error is None, (
            "Agent frontmatter must parse as strict YAML. "
            f"Parse error: {component.parse_error!r}"
        )
        assert component.frontmatter.get("name") == "diagnostic-legibility"

    def test_agent_tool_boundary(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The agent is a read-only emitter, matching the three sibling
        emitters (advocatus-diaboli, choice-cartographer,
        model-card-researcher). Tools must include Read, Glob, Grep —
        and must NOT include Write, Edit, or Bash."""
        component = plugin_runner.find_component(
            diagnostic_legibility_path,
            name="diagnostic-legibility",
            component_type="agent",
        )
        tools_raw = component.frontmatter.get("tools", "")
        # The tools field is conventionally a comma-separated string;
        # split and normalise.
        if isinstance(tools_raw, list):
            tools = {t.strip() for t in tools_raw}
        else:
            tools = {t.strip() for t in str(tools_raw).split(",")}

        for required in ("Read", "Glob", "Grep"):
            assert required in tools, (
                f"Agent tools must include {required!r}. "
                f"Actual tools: {sorted(tools)!r}"
            )
        for forbidden in ("Write", "Edit", "Bash"):
            assert forbidden not in tools, (
                f"Agent tools must NOT include {forbidden!r} — the agent "
                "is a read-only emitter per spec §2.3. "
                f"Actual tools: {sorted(tools)!r}"
            )

    def test_agent_description_mentions_legibility_model(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The description field is what the Claude Code skill matcher
        reads to decide when to fire the agent. It must name the
        artefact the agent emits (a LegibilityModel) so the matcher
        can route invocations to it.

        Per code-mode O5: also asserts the description surfaces the
        machine-parseable contract terms (Q<N> prefix, (empty scope)
        sentinel) so downstream consumers reading only the description
        know what to grep for.

        Per S3 spec §4.2: extended to require CC<N> prefix and
        cross_check_status field names so the v0.4.0 cross-check
        contract is also visible at the discovery surface.
        """
        component = plugin_runner.find_component(
            diagnostic_legibility_path,
            name="diagnostic-legibility",
            component_type="agent",
        )
        description = component.frontmatter.get("description") or ""
        assert "LegibilityModel" in description, (
            "Agent description must mention 'LegibilityModel' so the "
            "skill matcher can route invocations to it. "
            f"Actual description: {description!r}"
        )
        assert "Q<N>" in description, (
            "Agent description must name the `Q<N>` prefix convention so "
            "consumers reading only the description know the agent's "
            "challenge_notes follow a machine-parseable format. "
            f"Actual description: {description!r}"
        )
        assert "(empty scope)" in description, (
            "Agent description must name the `(empty scope)` sentinel so "
            "consumers know the literal pattern-match handle for the "
            "degenerate case. "
            f"Actual description: {description!r}"
        )
        assert "CC<N>" in description, (
            "Agent description must name the `CC<N>` prefix convention "
            "for cross-check entries so consumers reading only the "
            "description know the v0.4.0 cross-check contract. "
            f"Actual description: {description!r}"
        )
        assert "cross_check_status" in description, (
            "Agent description must name the `cross_check_status` "
            "wrapper field so consumers reading only the description "
            "know to read the model-level cross-check status. "
            f"Actual description: {description!r}"
        )

    def test_agent_body_references_schema_template(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The agent's prompt must reference the schema template path so
        readers (and the agent itself, via its system prompt) can locate
        the contract its outputs must follow."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        expected_path = "templates/legibility-element.md"
        assert expected_path in body, (
            f"Agent body must reference the schema template path "
            f"{expected_path!r} so the contract is locatable from the "
            "agent file itself."
        )


# ---------------------------------------------------------------------
# Load-bearing string contracts (code-mode O1, O4)
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestDiagnosticLegibilityStringContracts:
    """The agent's downstream consumers (parent S3 cross-check, future
    /diagnose command) pattern-match on exact literal strings emitted by
    the agent. Drift in those literals — a typo, a punctuation change, a
    well-meaning paraphrase — would ship through every other CI gate
    silently. These tests guard the literals at the place they are
    defined: the agent file itself.

    The behavioural-runtime contract (the agent actually emitting these
    strings on each invocation) is covered by the spec as acceptance
    documentation — this layer guards the static text only.
    """

    def test_agent_body_contains_empty_scope_sentinel(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per spec §3.6 and code-mode O4: the literal `(empty scope)`
        is the downstream pattern-match handle for the degenerate-output
        case. The agent file must carry it verbatim, parentheses
        included."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        sentinel = "(empty scope)"
        assert sentinel in body, (
            f"Agent body must contain the literal sentinel {sentinel!r} "
            "verbatim (parentheses included) — this is the pattern-match "
            "handle downstream consumers (S3 cross-check #332, /diagnose "
            "command #333) rely on for the degenerate-output case."
        )

    def test_agent_body_contains_challenge_applied_sentinel(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per spec §3.5 and code-mode O4: the literal `Challenge applied;
        no questions surfaced changes` is the sentinel that disambiguates
        'challenge ran cleanly' from 'challenge never ran' (empty
        challenge_notes[]). The agent file must carry it verbatim."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        sentinel = "Challenge applied; no questions surfaced changes"
        assert sentinel in body, (
            f"Agent body must contain the literal sentinel {sentinel!r} "
            "verbatim. A reflexive edit (e.g. 'no question surfaced' "
            "singular, or any punctuation change) invalidates the "
            "downstream cross-check (#332) silently."
        )

    def test_agent_body_uses_canonical_q_prefix_form(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per code-mode O1: the `Q<N> (lowercase-question-name):`
        prefix is the canonical form for challenge_notes entries.
        Asserts the five canonical prefixes appear in the agent body
        and the deprecated no-parens forms (`Q2 evidence`,
        `Q3 confounders`, `Q4 confidence`) do not."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        canonical_prefixes = (
            "Q1 (boundary):",
            "Q2 (evidence):",
            "Q3 (confounders):",
            "Q4 (confidence):",
            "Q5 (description integrity):",
        )
        # The agent body should name the canonical form somewhere — at
        # minimum the example, the protocol section, or the format-spec
        # callout. We assert each canonical prefix appears at least once.
        for prefix in canonical_prefixes:
            assert prefix in body, (
                f"Agent body must reference the canonical prefix form "
                f"{prefix!r} (lowercase question-name, parentheses, colon) "
                "so the agent's prompt teaches one consistent form."
            )
        # The deprecated no-parens forms (the original O1 evidence) must
        # be absent — if they appear, the agent's prompt teaches an
        # inconsistent form.
        deprecated_forms = (
            "Q2 evidence",
            "Q3 confounders",
            "Q4 confidence",
        )
        for deprecated in deprecated_forms:
            assert deprecated not in body, (
                f"Agent body must NOT contain the deprecated form "
                f"{deprecated!r} (no parens). Use the canonical "
                f"{deprecated.split()[0]} (lowercase-name): form instead."
            )


# ---------------------------------------------------------------------
# Docs pages
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestDiagnosticLegibilityDocs:
    """The docs site gains two content pages and their quadrant
    landing pages (per the docs convention — quadrant folders are
    scaffolded only when they have at least one page).

    Per the docs convention in CLAUDE.md, pages live at
    `docs/plugins/diagnostic-legibility/<quadrant>/<slug>.md`.
    """

    def test_how_to_page_present(self, repo_root: Path) -> None:
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "how-to"
            / "invoke-the-agent.md"
        )
        assert page.is_file(), (
            f"Expected how-to page at {page.relative_to(repo_root)!s}"
        )

    def test_how_to_quadrant_index_present(self, repo_root: Path) -> None:
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "how-to"
            / "index.md"
        )
        assert page.is_file(), (
            "Each Diataxis quadrant folder needs its own index.md so "
            "mkdocs-awesome-pages renders the section as a navigable "
            f"group. Missing: {page.relative_to(repo_root)!s}"
        )

    def test_explanation_page_present(self, repo_root: Path) -> None:
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "explanation"
            / "challenge-refine-protocol.md"
        )
        assert page.is_file(), (
            f"Expected explanation page at {page.relative_to(repo_root)!s}"
        )

    def test_explanation_quadrant_index_present(
        self, repo_root: Path
    ) -> None:
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "explanation"
            / "index.md"
        )
        assert page.is_file(), (
            "Each Diataxis quadrant folder needs its own index.md so "
            "mkdocs-awesome-pages renders the section as a navigable "
            f"group. Missing: {page.relative_to(repo_root)!s}"
        )

    def test_invoke_agent_how_to_links_to_diagnose_how_to(
        self, repo_root: Path
    ) -> None:
        """Per S4 spec §7.2 / §7.3 item 12: #333 is now closed (the
        `/diagnose` command shipped), so the invoke-the-agent how-to's
        former forward-link note to #333 is replaced with a link to the
        new run-the-diagnose-command how-to. The bare-Task-tool dispatch
        content stays (it is still the lower-level surface)."""
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "how-to"
            / "invoke-the-agent.md"
        )
        body = page.read_text()
        assert "run-the-diagnose-command" in body, (
            "invoke-the-agent.md must link to the new "
            "`run-the-diagnose-command` how-to now that the `/diagnose` "
            "command surface it anticipated (#333) exists. The former "
            "forward-link note to #333 is resolved into this link."
        )


# ---------------------------------------------------------------------
# Cross-check contract (S3, v0.4.0)
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestDiagnosticLegibilityCrossCheck:
    """The v0.4.0 cross-check (Phase C) adds load-bearing string
    contracts beyond v0.3.0: the canonical `CC<N> (lowercase-name):`
    prefix for cross-check entries, the `Cross-check applied; ...`
    sentinel for clean per-element runs, the dropped CC-skipped
    sentinel (its information moves to the model-level
    `cross_check_status` field per cartographer Stories #1 + #4), and
    the two named direction-specific failure modes per cartographer
    Story #5. The agent's structured refusal contract per Story #6 is
    also asserted as a literal-text guard.

    Behavioural-runtime contract (the agent actually emitting these on
    each invocation) is covered by spec acceptance documentation; this
    layer guards the agent file's static text only.
    """

    def test_agent_body_contains_cross_check_applied_sentinel(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per spec §3.5: the literal `Cross-check applied; no questions
        surfaced changes` is the per-element clean-run sentinel for
        Phase C. The CC-skipped sibling sentinel (which differed only
        in one verb) was dropped at adjudication time — its information
        now lives at model level."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        sentinel = "Cross-check applied; no questions surfaced changes"
        assert sentinel in body, (
            f"Agent body must contain the literal sentinel {sentinel!r} "
            "verbatim. Per cartographer Story #4, this sentinel records "
            "per-element evidence that Phase C reached the element "
            "cleanly; downstream consumers pattern-match on it."
        )

    def test_agent_body_does_not_contain_cc_skipped_sentinel(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per cartographer Stories #1 + #4 (paired promoted): the
        original draft's per-element CC-skipped sentinel was dropped.
        Its information now lives in the model-level
        `cross_check_status` field. Re-introducing the per-element
        sentinel would re-introduce the prefix-match conflation (O4)
        and the granularity violation (O9)."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        banned = "Cross-check skipped; only one collection present"
        assert banned not in body, (
            f"Agent body must NOT contain the literal {banned!r}. The "
            "per-element CC-skipped sentinel was dropped at adjudication "
            "time. The model-level `cross_check_status: "
            "skipped_asymmetric` field carries this fact at the right "
            "granularity. See cartographer Stories #1 and #4."
        )

    def test_agent_body_uses_canonical_cc_prefix_form(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per spec §3.4 and §3.5 (post-diaboli): the canonical CC
        prefix mirrors the Q form — `CC<N> (lowercase-name):` with
        lowercase question name, parentheses, and colon. The five
        canonical CC prefixes must all appear in the agent body."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        canonical_prefixes = (
            "CC1 (boundary contradiction):",
            "CC2 (evidence overlap):",
            "CC3 (cross-confounders):",
            "CC4 (cross-confidence calibration):",
            "CC5 (mutual description integrity):",
        )
        for prefix in canonical_prefixes:
            assert prefix in body, (
                f"Agent body must reference the canonical CC prefix "
                f"form {prefix!r} (lowercase question name, parens, "
                "colon) so the agent's prompt teaches one consistent "
                "form. The S2b Q-prefix discipline is the precedent."
            )

    def test_agent_body_names_direction_failure_modes(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per cartographer Story #5 + spec §3.4: the two
        direction-specific failure modes must be named in the agent
        body so the dimension-flavoured weighting has named targets
        rather than inheriting S2b's per-element failure modes."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        # A→D direction targets architectural assumptions implicit in
        # domain descriptions
        assert "architectural-implicit assumption" in body, (
            "Agent body must name the A→D direction's failure mode "
            "(`architectural-implicit assumption in domain description`)"
            " — per cartographer Story #5, the analogy doing real work "
            "requires direction-specific failure modes to be named "
            "rather than inherited from S2b."
        )
        # D→A direction targets domain-concept smear
        assert "domain-concept smear" in body, (
            "Agent body must name the D→A direction's failure mode "
            "(`domain-concept smear in architectural element`) — per "
            "cartographer Story #5."
        )

    def test_agent_body_contains_refusal_line_shape(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per cartographer Story #6 (promoted, #348) and spec §3.6 +
        §3.7: the structured refusal line shape must appear in the
        agent body. Programmatic dispatchers pattern-match on this
        shape to route to error handling."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        refusal_prefix = "diagnostic-legibility refusal:"
        assert refusal_prefix in body, (
            f"Agent body must contain the literal refusal-line prefix "
            f"{refusal_prefix!r} per spec §3.6 / §3.7. This is the "
            "pattern-match handle for programmatic dispatchers; absence "
            "lets the structured-refusal contract drift to "
            "free-form error messages."
        )

    def test_agent_body_names_mode_markers(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per spec §2.4 / §3.7: two mode markers (full and
        cross-check-only) must be named in the agent body. The
        construct-only mode was dropped at adjudication (cartographer
        Story #2 / diaboli O2) and must not appear."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        assert "mode: full" in body, (
            "Agent body must name `mode: full` as the default mode "
            "(Phase A + B + C) per spec §2.4."
        )
        assert "mode: cross-check-only" in body, (
            "Agent body must name `mode: cross-check-only` as the "
            "Phase-C-against-supplied-YAML mode per spec §2.4."
        )
        # Drop-construct-only assertion — per cartographer Story #2,
        # the third mode was explicitly dropped at adjudication. If
        # it reappears, it must come back with a named consumer
        # justifying the surface area.
        assert "mode: construct-only" not in body, (
            "Agent body must NOT name `mode: construct-only` — the "
            "third mode was dropped at adjudication (cartographer "
            "Story #2 / diaboli O2). It can return when a named "
            "consumer materialises; until then it is YAGNI."
        )

    def test_agent_body_names_cross_check_status_values(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per spec §2.2 / §3.6: the three legal cross_check_status
        values must be named so the agent's contract documents the
        full state space."""
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        body = agent_file.read_text()
        for value in ("completed", "skipped_asymmetric", "not_run"):
            assert value in body, (
                f"Agent body must name the `cross_check_status` value "
                f"{value!r} so the dispatcher-facing contract is "
                "complete."
            )

    def test_canonical_ordering_invariant_on_fixture(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per cartographer Story #7 and spec §7.2 test #10: O5's
        adjudicated commitment is TWO enforcement layers for the
        Q-before-CC ordering invariant — agent emit-time
        self-verification (visible in the agent body's Phase C
        algorithm step 6) AND a fixture-based structural test
        (this).

        The structural-layer test exercises a deliberately-interleaved
        challenge_notes list against the canonical-ordering invariant.
        It does NOT execute the agent's reasoning protocol (Layer 1
        is offline, no API key); it asserts the invariant directly,
        confirming the contract is enforceable from outside the
        agent. A future Layer 3 behavioural test would exercise the
        agent's actual re-ordering."""
        # Fixture: a challenge_notes list with Q and CC entries
        # interleaved out of canonical order.
        interleaved = [
            "Q1 (boundary): drafted the service boundary explicitly.",
            "CC2 (evidence overlap): cross-check surfaced shared evidence with Credential.",
            "Q3 (confounders): named SessionStore as a distinct nearby concept.",
            "CC1 (boundary contradiction): A-D direction surfaced a contradiction.",
            "Challenge applied; no questions surfaced changes",
        ]

        # Canonical-ordering rule: all Q<N> entries (and the Q-applied
        # sentinel) come before all CC<N> entries (and the CC-applied
        # sentinel) in the list.
        def _is_q_class(entry: str) -> bool:
            return entry.startswith("Q") or entry == (
                "Challenge applied; no questions surfaced changes"
            )

        def _is_cc_class(entry: str) -> bool:
            return entry.startswith("CC") or entry == (
                "Cross-check applied; no questions surfaced changes"
            )

        def _canonical_order(entries: list[str]) -> list[str]:
            q = [e for e in entries if _is_q_class(e)]
            cc = [e for e in entries if _is_cc_class(e)]
            other = [e for e in entries if not (_is_q_class(e) or _is_cc_class(e))]
            return q + cc + other

        canonical = _canonical_order(interleaved)

        # Invariant 1: the canonical ordering preserves all entries
        # (no drops, no duplicates).
        assert sorted(canonical) == sorted(interleaved), (
            "Canonical re-ordering must preserve the entry set "
            "(no drops, no duplicates)."
        )

        # Invariant 2: the canonical ordering has all Q-class entries
        # before all CC-class entries.
        last_q_idx = max(
            (i for i, e in enumerate(canonical) if _is_q_class(e)),
            default=-1,
        )
        first_cc_idx = min(
            (i for i, e in enumerate(canonical) if _is_cc_class(e)),
            default=len(canonical),
        )
        assert last_q_idx < first_cc_idx, (
            f"Canonical ordering violated: last Q-class index "
            f"({last_q_idx}) must be less than first CC-class index "
            f"({first_cc_idx}). Canonical: {canonical!r}."
        )

        # Invariant 3: the original interleaved input was NOT
        # canonical (the test exercises a real interleaving).
        assert canonical != interleaved, (
            "Test fixture must be deliberately interleaved (not "
            "already canonical) so the test exercises the re-ordering "
            "rule rather than asserting trivially."
        )

    def test_schema_template_documents_cross_check_status_field(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Per cartographer Stories #1 + #4 (paired promoted) and spec
        §7.2: the schema template at templates/legibility-element.md
        is updated to document the additive `cross_check_status`
        wrapper field. This is the schema's first post-S2a touch and
        is governed by the granularity-routing discipline."""
        template = (
            diagnostic_legibility_path
            / "templates"
            / "legibility-element.md"
        )
        body = template.read_text()
        assert "cross_check_status" in body, (
            "Schema template must document the `cross_check_status` "
            "wrapper field added at v0.4.0. The field is additive to "
            "the LegibilityModel wrapper (back-compat with v0.3.0). "
            "Per cartographer Stories #1 and #4, the granularity-"
            "routing rule says model-level facts earn wrapper fields; "
            "this is the worked example."
        )
        # All three legal values must be documented in the template
        for value in ("completed", "skipped_asymmetric", "not_run"):
            assert value in body, (
                f"Schema template must document the "
                f"`cross_check_status: {value}` legal value."
            )


# ---------------------------------------------------------------------
# /diagnose command (S4, v0.5.0)
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestDiagnosticLegibilityDiagnoseCommand:
    """S4 ships the human-facing `/diagnose` command at v0.5.0. These
    are offline, deterministic, file-shape assertions translating the
    spec's §6 acceptance scenarios (1–8, 5b, 8b) and §7.3 test items.

    The command's behavioural contract (that a live invocation produces
    the §5 report structure) is covered by spec §6 Scenario 9 as
    acceptance documentation, not as an executable test — this layer
    guards the command file's static text, frontmatter, the version
    triplet, the .gitignore entry, and the docs entries only.

    Spec reference:
        docs/superpowers/specs/2026-06-01-dl-s4-diagnose-command-design.md
    """

    def _command_body(self, diagnostic_legibility_path: Path) -> str:
        command_file = (
            diagnostic_legibility_path / "commands" / "diagnose.md"
        )
        return command_file.read_text()

    # -- Scenario 1 / §7.3 item 1 + 2 ---------------------------------

    def test_command_file_present_and_gitkeep_removed(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 1 / §7.3 item 1: the command file exists and the
        commands/.gitkeep placeholder (standing since the v0.1.0
        scaffold) has been removed once the real command lands —
        mirroring the agents/.gitkeep removal at sub-S2b."""
        command_file = (
            diagnostic_legibility_path / "commands" / "diagnose.md"
        )
        assert command_file.is_file(), (
            "Expected command file at "
            f"{command_file.relative_to(diagnostic_legibility_path.parent)}"
        )
        gitkeep = diagnostic_legibility_path / "commands" / ".gitkeep"
        assert not gitkeep.exists(), (
            "diagnostic-legibility/commands/.gitkeep must be removed once "
            "diagnose.md lands (mirrors the agents/.gitkeep removal at "
            "sub-S2b). The placeholder is no longer needed."
        )

    def test_command_frontmatter_name_and_description(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 1 / §7.3 item 2: the command frontmatter parses as
        strict YAML; `name == "diagnose"`; `description` is non-empty."""
        component = plugin_runner.find_component(
            diagnostic_legibility_path,
            name="diagnose",
            component_type="command",
        )
        assert component.parse_error is None, (
            "Command frontmatter must parse as strict YAML. "
            f"Parse error: {component.parse_error!r}"
        )
        assert component.frontmatter.get("name") == "diagnose", (
            "Command frontmatter `name` must be 'diagnose'. "
            f"Actual: {component.frontmatter.get('name')!r}"
        )
        description = component.frontmatter.get("description") or ""
        assert description.strip(), (
            "Command frontmatter must have a non-empty `description`."
        )

    # -- Scenario 2 / §7.3 item 3 + 6 ---------------------------------

    def test_command_documents_signature(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 2 / §7.3 item 3: the body documents the signature
        `/diagnose <scope> [--out <dir>]` — a single verb with a
        required `<scope>` positional and an optional `--out`."""
        body = self._command_body(diagnostic_legibility_path)
        assert "/diagnose <scope> [--out <dir>]" in body, (
            "Command body must document the signature "
            "`/diagnose <scope> [--out <dir>]` verbatim (spec §3.2)."
        )

    def test_command_documents_default_output_path_and_filename(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 2 / §7.3 item 6: the body states the default output
        directory `diagnostic-legibility/output/` and the filename
        convention `<scope-slug>-legibility-...md`."""
        body = self._command_body(diagnostic_legibility_path)
        assert "diagnostic-legibility/output/" in body, (
            "Command body must state the default output directory "
            "`diagnostic-legibility/output/` (spec §4.3)."
        )
        assert "<scope-slug>-legibility-" in body, (
            "Command body must state the filename convention prefix "
            "`<scope-slug>-legibility-` (spec §4.3)."
        )
        assert ".md" in body, (
            "Command body must state the report extension `.md` "
            "(spec §4.3 — the report is markdown, not YAML)."
        )

    # -- Scenario 3 / §7.3 item 4 + 5 ---------------------------------

    def test_command_documents_mode_full_dispatch(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 3 / §7.3 item 4: the body documents dispatching the
        diagnostic-legibility agent in `mode: full` (spec §3.3 / §4.4)."""
        body = self._command_body(diagnostic_legibility_path)
        assert "mode: full" in body, (
            "Command body must name `mode: full` as the dispatch mode "
            "(spec §3.3 — /diagnose always runs the full pipeline)."
        )
        assert "diagnostic-legibility" in body, (
            "Command body must name the `diagnostic-legibility` agent it "
            "dispatches (spec §4.4)."
        )

    def test_command_documents_refusal_handling(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 3 / §7.3 item 5: the body documents the refusal
        contract — surface the `diagnostic-legibility refusal:` line
        verbatim and abort with no file written (spec §4.5)."""
        body = self._command_body(diagnostic_legibility_path)
        assert "diagnostic-legibility refusal:" in body, (
            "Command body must contain the literal refusal-line prefix "
            "`diagnostic-legibility refusal:` it pattern-matches on "
            "(spec §4.5)."
        )
        assert "verbatim" in body, (
            "Command body must document surfacing the refusal line "
            "*verbatim* (spec §4.5 step 1)."
        )
        assert "LegibilityModel" in body, (
            "Command body must reference the `LegibilityModel` YAML as "
            "the agent's return shape (spec §4.4 / Scenario 3)."
        )

    # -- Scenario 4 / §7.3 item 9 -------------------------------------

    def test_command_documents_report_geometry(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 4 / §7.3 item 9: the body documents the report
        geometry — a two-column cross-check summary table (the
        side-by-side) plus stacked `### Architectural model` /
        `### Domain model` bodies, Q/CC grouping, the three
        cross_check_status values, and the A→D / D→A correction counts
        defined as elements carrying ≥1 CC<N> entry (spec §5.2–§5.3)."""
        body = self._command_body(diagnostic_legibility_path)
        assert "side-by-side" in body, (
            "Command body must document the two-column cross-check "
            "summary table as the `side-by-side` (spec §5.3 item 1)."
        )
        assert "### Architectural model" in body, (
            "Command body must document the stacked `### Architectural "
            "model` subsection (spec §5.3 item 2)."
        )
        assert "### Domain model" in body, (
            "Command body must document the stacked `### Domain model` "
            "subsection (spec §5.3 item 2)."
        )
        assert "A→D" in body and "D→A" in body, (
            "Command body must document the A→D and D→A correction "
            "directions (spec §5.2)."
        )
        for value in ("completed", "skipped_asymmetric", "not_run"):
            assert value in body, (
                "Command body must surface the `cross_check_status` "
                f"value {value!r} (spec §5.1 / §5.2)."
            )
        assert "CC<N>" in body, (
            "Command body must define the correction count by the "
            "`CC<N>` entry (elements carrying ≥1 CC<N> entry — spec "
            "§5.2's elements-revised definition)."
        )
        assert "elements revised" in body, (
            "Command body must use the human-facing `elements revised` "
            "label for the correction-count semantic (spec §5.2)."
        )
        # Code-mode diaboli O1: token-presence alone would pass on a body
        # that documented the geometry in the wrong ORDER. These offline
        # relative-ordering checks pin what a Layer 0/1 test genuinely
        # can — the canonical layout sequence — without claiming to
        # verify a live render (behavioural verification is Layer 3).
        assert body.index("### Architectural model") < body.index(
            "### Domain model"
        ), (
            "Architectural model section must be documented BEFORE the "
            "Domain model section (spec §5.3 — canonical stacked order)."
        )
        a_to_d_def = body.index("A→D corrections")
        assert (
            "architectural" in body[a_to_d_def : a_to_d_def + 120]
        ), (
            "The A→D corrections definition must bind A→D to "
            "*architectural* elements (spec §5.2) — guards against the "
            "transposed A→D/D→A definition O5 flags."
        )

    # -- Scenario 5 / §7.3 item 8 -------------------------------------

    def test_command_documents_validation_checkpoint(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 5 / §7.3 item 8: the body documents an output
        validation checkpoint with the narrowed §5.5 scope — no literal
        `<DISPATCHER:` leak, both collections rendered, Q/CC ordering
        present, fix in place (no re-dispatch), and that the human
        accept gate (not the checkpoint) is the last line of defence
        (spec §4.7 / §5.5)."""
        body = self._command_body(diagnostic_legibility_path)
        assert "validation checkpoint" in body, (
            "Command body must document an output `validation checkpoint` "
            "(spec §4.7 / CLAUDE.md Output Validation Checkpoints)."
        )
        assert "<DISPATCHER:" in body, (
            "Command body must name the literal `<DISPATCHER:` substring "
            "as the no-unsubstituted-placeholder checkpoint check "
            "(spec §5.5 check 2)."
        )
        assert "re-dispatch" in body, (
            "Command body must state the checkpoint fixes deviations in "
            "place rather than re-dispatching the agent (spec §5.5)."
        )
        assert "last line of defence" in body, (
            "Command body must state the human accept gate (not the "
            "validation checkpoint) is the last line of defence before "
            "write (spec §4.8 / §5.5)."
        )

    # -- Scenario 5b / §7.3 item 8b -----------------------------------

    def test_command_documents_confirm_before_write_gate(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 5b / §7.3 item 8b: the body documents the
        confirm-before-write gate that runs AFTER the validation
        checkpoint and BEFORE the write — a summary naming the resolved
        path, an overwrite flag, an accept/abort prompt, write only on
        accept, abort writes nothing and creates no directory
        (spec §4.8)."""
        body = self._command_body(diagnostic_legibility_path)
        assert "accept" in body and "abort" in body, (
            "Command body must document the accept/abort confirm-before-"
            "write prompt (spec §4.8)."
        )
        assert "overwrite" in body, (
            "Command body must document flagging when the resolved path "
            "already exists and would be overwritten (spec §4.8 step 2)."
        )
        assert "resolved" in body, (
            "Command body must document the summary naming the resolved "
            "target path before any write (spec §4.8 step 1 / §5.6)."
        )

    # -- Scenario 6 / §7.3 item 7 -------------------------------------

    def test_command_documents_dispatcher_placeholder_substitution(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Scenario 6 / §7.3 item 7: the body documents substituting the
        `<DISPATCHER: ...>` timestamp and model-identifier placeholders
        before persisting, and that the same resolved date supplies the
        filename's `<YYYY-MM-DD>` stamp (spec §3.5 / §4.3)."""
        body = self._command_body(diagnostic_legibility_path)
        assert "generated_at" in body, (
            "Command body must document substituting the `generated_at` "
            "<DISPATCHER: ...> placeholder (spec §3.5)."
        )
        assert "generated_by" in body, (
            "Command body must document substituting the `generated_by` "
            "<DISPATCHER: ...> placeholder (spec §3.5)."
        )
        assert "<YYYY-MM-DD>" in body, (
            "Command body must document that the same resolved date "
            "supplies the filename's `<YYYY-MM-DD>` stamp (spec §4.3)."
        )

    # -- Scenario 7 / §7.3 item 10 + 11 -------------------------------

    def test_marketplace_top_level_version_still_0_4_0(
        self, repo_root: Path
    ) -> None:
        """Scenario 7 / §7.3 item 10 (O9): the marketplace top-level
        `version` is NOT bumped by S4 — it stays at 0.4.0. (The existing
        TestDiagnosticLegibilityVersioning.test_marketplace_top_level_
        version_unchanged already pins this; this is the S4-scenario-
        named restatement.)"""
        marketplace = json.loads(
            (repo_root / ".claude-plugin" / "marketplace.json").read_text()
        )
        assert marketplace["version"] == "0.4.0", (
            "marketplace.json top-level `version` must remain '0.4.0' "
            "(per spec §9 / O9: a per-plugin entry's description rewrite "
            "is the plugin's own contract, not the listing contract). "
            f"Actual: {marketplace['version']!r}"
        )

    def test_marketplace_entry_description_drops_stale_sentence(
        self, repo_root: Path
    ) -> None:
        """§7.3 item 10 (O9, negative-presence): the diagnostic-
        legibility entry `description` was rewritten — the now-false
        trailing sentence about the command landing later is gone."""
        marketplace = json.loads(
            (repo_root / ".claude-plugin" / "marketplace.json").read_text()
        )
        entry = next(
            p
            for p in marketplace["plugins"]
            if p["name"] == "diagnostic-legibility"
        )
        description = entry.get("description", "")
        stale = "Human-facing `/diagnose` command lands in a later slice."
        assert stale not in description, (
            "marketplace.json diagnostic-legibility entry `description` "
            f"must no longer contain the stale sentence {stale!r} — the "
            "command now exists (spec §9 / O9). Actual description: "
            f"{description!r}"
        )

    # -- Scenario 8 / §7.3 item 11 + 12 -------------------------------

    def test_diagnose_how_to_page_present(
        self, repo_root: Path
    ) -> None:
        """Scenario 8 / §7.3 item 11: the how-to guide for /diagnose
        exists (CLAUDE.md "new component → how-to guide" convention)."""
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "how-to"
            / "run-the-diagnose-command.md"
        )
        assert page.is_file(), (
            f"Expected how-to page at {page.relative_to(repo_root)!s} "
            "(spec §7.1)."
        )

    def test_diagnose_reference_page_present(
        self, repo_root: Path
    ) -> None:
        """Scenario 8 / §7.3 item 11: the reference entry for /diagnose
        exists, satisfying the CI "new component → reference entry"
        expectation (spec §7.1)."""
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "reference"
            / "diagnose-command.md"
        )
        assert page.is_file(), (
            f"Expected reference page at {page.relative_to(repo_root)!s} "
            "(spec §7.1)."
        )

    def test_reference_quadrant_index_present(
        self, repo_root: Path
    ) -> None:
        """§7.1: the reference quadrant landing page exists — the first
        reference-quadrant page for this plugin, scaffolded now that the
        quadrant has a page (CLAUDE.md docs convention)."""
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "reference"
            / "index.md"
        )
        assert page.is_file(), (
            "Each Diataxis quadrant folder needs its own index.md so "
            "mkdocs-awesome-pages renders the section as a navigable "
            f"group. Missing: {page.relative_to(repo_root)!s} (spec §7.1)."
        )

    # -- .gitignore (O3) / §7.2 ---------------------------------------

    def test_gitignore_ignores_output_directory(
        self, repo_root: Path
    ) -> None:
        """§7.2 (O3 accepted): the repo-root .gitignore must ignore
        `diagnostic-legibility/output/` so generated reports are never
        committed nor rsynced into the plugin cache by
        sync-to-global-cache.sh."""
        gitignore = (repo_root / ".gitignore").read_text()
        assert "diagnostic-legibility/output/" in gitignore, (
            "Repo-root .gitignore must contain an entry for "
            "`diagnostic-legibility/output/` (spec §7.2 / O3) so "
            "generated reports stay out of the repo and the plugin cache."
        )


# ---------------------------------------------------------------------
# ConceptualPipelineMap data-model template (P1, v0.6.0)
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestConceptualPipelineMapTemplate:
    """P1 ships the `ConceptualPipelineMap` as its own standalone
    data-model template — NOT a collection bolted onto `LegibilityModel`
    (spec §4). These are deterministic, file-shape assertions over the
    template's documented field contract and its decoupling invariants.
    The model's behavioural production (the agent emitting a conforming
    map) is later-slice work (P3+); P1 fixes the schema, mirroring the
    role sub-S2a played for `LegibilityElement`.

    Spec reference:
        docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md
    """

    def _template_body(self, diagnostic_legibility_path: Path) -> str:
        template = (
            diagnostic_legibility_path
            / "templates"
            / "conceptual-pipeline-map.md"
        )
        return template.read_text()

    # -- file presence (spec §4) --------------------------------------

    def test_template_file_present(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Spec §4: the model is defined in its OWN template at
        `templates/conceptual-pipeline-map.md`, not folded into
        `legibility-element.md`."""
        template = (
            diagnostic_legibility_path
            / "templates"
            / "conceptual-pipeline-map.md"
        )
        assert template.is_file(), (
            "Expected the ConceptualPipelineMap template at "
            f"{template.relative_to(diagnostic_legibility_path.parent)} "
            "(spec §4 — the map is its own standalone model)."
        )

    def test_template_names_the_model(
        self, diagnostic_legibility_path: Path
    ) -> None:
        body = self._template_body(diagnostic_legibility_path)
        assert "ConceptualPipelineMap" in body, (
            "Template must name the top-level model `ConceptualPipelineMap`."
        )

    # -- the four record types and their fields (spec §4, slice P1) ----

    def test_wrapper_fields_documented(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The ConceptualPipelineMap wrapper carries task,
        scope_resolution, entry, stages, transitions, and the two
        dispatcher-filled provenance fields."""
        body = self._template_body(diagnostic_legibility_path)
        for field in (
            "task",
            "scope_resolution",
            "entry",
            "stages",
            "transitions",
            "generated_at",
            "generated_by",
        ):
            assert field in body, (
                f"Template must document the wrapper field {field!r} "
                "(spec §4 / template top-level field set)."
            )

    def test_pipeline_stage_fields_documented(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """PipelineStage: id, label, kind, condition, part_of, realises,
        evidence, confidence, challenge_notes."""
        body = self._template_body(diagnostic_legibility_path)
        assert "PipelineStage" in body, (
            "Template must define the `PipelineStage` record."
        )
        for field in (
            "id",
            "label",
            "kind",
            "condition",
            "part_of",
            "realises",
            "evidence",
            "confidence",
            "challenge_notes",
        ):
            assert field in body, (
                f"Template must document the PipelineStage field "
                f"{field!r} (spec §4)."
            )

    def test_pipeline_transition_fields_documented(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """PipelineTransition: from, to, condition_label, kind,
        evidence."""
        body = self._template_body(diagnostic_legibility_path)
        assert "PipelineTransition" in body, (
            "Template must define the `PipelineTransition` record."
        )
        for field in ("from", "to", "condition_label", "evidence"):
            assert field in body, (
                f"Template must document the PipelineTransition field "
                f"{field!r} (spec §4)."
            )

    def test_scope_resolution_fields_documented(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """ScopeResolution: in_scope, adjacent_excluded,
        scope_confidence — the disclosed provenance of the DERIVED
        bound (spec §3.1, §4)."""
        body = self._template_body(diagnostic_legibility_path)
        assert "ScopeResolution" in body, (
            "Template must define the `ScopeResolution` record."
        )
        for field in (
            "in_scope",
            "adjacent_excluded",
            "scope_confidence",
        ):
            assert field in body, (
                f"Template must document the ScopeResolution field "
                f"{field!r} (spec §3.1 / §4)."
            )

    # -- the control-flow ontology (spec §4.1) ------------------------

    def test_stage_kind_enum_values(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """`kind` is a conceptual role with exactly three values:
        step | decision | outcome (spec §4.1 — a conceptual category,
        not a shape)."""
        body = self._template_body(diagnostic_legibility_path)
        for value in ("step", "decision", "outcome"):
            assert value in body, (
                f"Template must document the stage `kind` value "
                f"{value!r} (spec §4.1)."
            )

    def test_confidence_enum_values_reused(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The model reuses the legibility discipline's epistemic
        `confidence` (low/medium/high) on stages and `scope_confidence`
        (spec §4.2)."""
        body = self._template_body(diagnostic_legibility_path)
        for value in ("low", "medium", "high"):
            assert value in body, (
                f"Template must document the confidence value {value!r}."
            )

    # -- the decoupling invariants (spec §4.1, §4.2) ------------------

    def test_id_is_opaque_not_display_numbering(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The load-bearing decoupling choice: `id` is a stable OPAQUE
        slug, and display numbering (`5A`, `5A.1`) is renderer-derived,
        never stored (spec §4.1 / §4.2)."""
        body = self._template_body(diagnostic_legibility_path)
        assert "opaque" in body.lower(), (
            "Template must state that `id` is a stable OPAQUE identifier "
            "(spec §4.2 — the load-bearing decoupling choice)."
        )
        # The display-numbering examples are named as renderer-derived,
        # NOT stored.
        assert "5A" in body, (
            "Template must name display numbering (e.g. `5A`/`5A.1`) as "
            "a renderer-derived concern the model does not store "
            "(spec §4.1)."
        )

    def test_presentation_and_producer_agnostic_claim(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Spec §4.1: the honest claim is presentation- and
        producer-agnostic — NOT the over-broad 'implementation-agnostic'
        (diaboli O2). The model deliberately commits to a control-flow
        ontology."""
        body = self._template_body(diagnostic_legibility_path)
        low = body.lower()
        assert "presentation-agnostic" in low, (
            "Template must claim the model is `presentation-agnostic` "
            "(spec §4.1)."
        )
        assert "producer-agnostic" in low, (
            "Template must claim the model is `producer-agnostic` "
            "(spec §4.1)."
        )

    def test_realises_cross_reference_seam(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """A stage cross-references the architectural/domain element it
        `realises` BY NAME — the P4 cross-check seam that leaves the map
        valid standalone (spec §4.2 / §4.3)."""
        body = self._template_body(diagnostic_legibility_path)
        assert "realises" in body, (
            "Template must document the `realises` cross-reference."
        )
        for key in ("architectural", "domain"):
            assert key in body, (
                f"Template must document the `realises.{key}` "
                "cross-reference key (spec §4.2)."
            )

    def test_empty_task_sentinel_documented(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Spec §4.3 / template Validation (diaboli O7): a task that
        resolves to no process emits an empty `stages: []` with a
        populated scope_resolution at `low` confidence — distinct from,
        and able to co-occur with, the `(empty scope)` sentinel that
        governs the architectural[]/domain[] collections."""
        body = self._template_body(diagnostic_legibility_path)
        assert "stages: []" in body, (
            "Template must document the empty-task sentinel "
            "(`stages: []`) per spec §4.3 / O7."
        )
        assert "(empty scope)" in body, (
            "Template must name the `(empty scope)` sentinel and explain "
            "the two degenerate sentinels coexist (spec §4.3 / O7)."
        )

    def test_challenge_notes_prefix_conventions(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Stages reuse the legibility audit-trail convention: `Q<N>`
        self-challenge and `CC<N>` cross-check note prefixes (spec §4.2
        — the same convention as legibility-element.md)."""
        body = self._template_body(diagnostic_legibility_path)
        assert "Q<N>" in body, (
            "Template must reference the `Q<N>` self-challenge note "
            "prefix convention (spec §4.2)."
        )
        assert "CC<N>" in body, (
            "Template must reference the `CC<N>` cross-check note prefix "
            "convention (spec §4.2 — the P4 cross-check seam)."
        )

    def test_excludes_display_and_implementation_concerns(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Spec §4.1 / template Boundaries: the model deliberately
        EXCLUDES display concerns (numbering, shapes, layout, target
        format) and implementation concerns (tracing strategy,
        persistence, runtime/execution overlay). Stating the exclusions
        is what keeps the decoupling enforceable."""
        body = self._template_body(diagnostic_legibility_path)
        low = body.lower()
        # Display concerns named as out-of-model.
        for term in ("shapes", "layout"):
            assert term in low, (
                f"Template must name the display concern {term!r} as a "
                "renderer concern the model excludes (spec §4.1)."
            )
        # Implementation concerns named as out-of-model.
        for term in ("persistence", "overlay"):
            assert term in low, (
                f"Template must name the implementation concern {term!r} "
                "as a producer/consumer concern the model excludes "
                "(spec §4.1)."
            )

    def test_dispatcher_placeholders_for_provenance(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """generated_at / generated_by are dispatcher-filled via the
        `<DISPATCHER: ...>` placeholder convention, matching
        LegibilityModel (spec §4 / template field table)."""
        body = self._template_body(diagnostic_legibility_path)
        assert "<DISPATCHER:" in body, (
            "Template must use the `<DISPATCHER: ...>` placeholder "
            "convention for the provenance fields the dispatcher fills."
        )


# ---------------------------------------------------------------------
# Scope-resolution mode (P2, v0.7.0)
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestDiagnosticLegibilityScopeResolution:
    """P2 adds the front-of-pipeline `mode: scope-resolution` capability
    to the diagnostic-legibility agent: take a natural-language work task
    (optionally biased by a `near:` hint) and emit a bounded, disclosed
    `ScopeResolution` — the 'what does my task touch?' surface — rather
    than a `LegibilityModel`. These are deterministic, file-shape
    assertions over the agent file's static text and frontmatter. The
    behavioural contract (a live dispatch actually resolving a real task
    to a sound bound) is covered by spec §5 as acceptance documentation
    and by the P2 hand-validation acceptance step, not as an executable
    Layer-1 test.

    Spec reference:
        docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md (§3, §5)
    """

    def _agent_body(self, diagnostic_legibility_path: Path) -> str:
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        return agent_file.read_text()

    # -- discovery surface (the frontmatter description) --------------

    def test_description_names_scope_resolution_mode(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The description is what the skill matcher reads. It must name
        the new `mode: scope-resolution` and the `ScopeResolution`
        artefact so invocations route to it, and surface the
        failure-direction disclosure contract."""
        component = plugin_runner.find_component(
            diagnostic_legibility_path,
            name="diagnostic-legibility",
            component_type="agent",
        )
        description = component.frontmatter.get("description") or ""
        assert "scope-resolution" in description, (
            "Agent description must name the `scope-resolution` mode "
            "(spec §5). "
            f"Actual: {description!r}"
        )
        assert "ScopeResolution" in description, (
            "Agent description must name the `ScopeResolution` artefact "
            "the scope-resolution mode emits."
        )

    # -- mode marker plumbing ----------------------------------------

    def test_body_declares_three_modes(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The Inputs section must name `mode: scope-resolution` as a
        third recognised mode alongside full and cross-check-only."""
        body = self._agent_body(diagnostic_legibility_path)
        assert "mode: scope-resolution" in body, (
            "Agent body must name the `mode: scope-resolution` marker."
        )
        assert "mode: full" in body and "mode: cross-check-only" in body, (
            "Agent body must still name the prior two modes."
        )

    def test_unrecognised_mode_refusal_lists_scope_resolution(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The unrecognised-mode refusal example must list
        `scope-resolution` among the legal values, so the structured
        refusal stays accurate for programmatic dispatchers. (P3 extends
        the enumeration to include `pipeline` — the value list grows as
        modes are added; this test only requires scope-resolution to
        remain present.)"""
        body = self._agent_body(diagnostic_legibility_path)
        assert "'scope-resolution'" in body, (
            "The unrecognised-mode refusal example must enumerate all "
            "three legal mode values including 'scope-resolution'."
        )

    # -- inputs: task (required) and near (biases, not bounds) -------

    def test_body_documents_task_and_near_inputs(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """scope-resolution takes a required `task:` and an optional
        `near:` hint that BIASES but does not BOUND the search
        (spec §7.1 / diaboli O3)."""
        body = self._agent_body(diagnostic_legibility_path)
        assert "`task`" in body or "`task:`" in body, (
            "Agent body must document the required `task` input."
        )
        assert "`near`" in body or "`near:`" in body, (
            "Agent body must document the optional `near` hint input."
        )
        assert "biases" in body and "does not bound it" in body, (
            "Agent body must state that `near` biases but does not bound "
            "the search (spec §7.1 / diaboli O3) — e.g. the anti-pattern "
            "'biases the search; it does not bound it'."
        )

    # -- the protocol ------------------------------------------------

    def test_body_has_scope_resolution_protocol(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """A dedicated protocol section must describe the four-step
        relevance-scoping behaviour (spec §5)."""
        body = self._agent_body(diagnostic_legibility_path)
        assert "Scope-resolution protocol" in body, (
            "Agent body must carry a `Scope-resolution protocol` section."
        )
        # The four steps' verbs.
        for cue in (
            "Interpret the task intent",
            "Locate implicated code",
            "Bound the slice",
            "Disclose",
        ):
            assert cue in body, (
                f"Scope-resolution protocol must name the step {cue!r} "
                "(spec §5)."
            )

    def test_body_names_failure_directions(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The honesty contract: below `high` confidence the producer
        must name the suspected failure DIRECTION — under-reach or
        over-reach (spec §3.2 / diaboli O4). A single scalar cannot say
        which way an uncertain bound failed."""
        body = self._agent_body(diagnostic_legibility_path)
        assert "under-reach" in body, (
            "Agent body must name the `under-reach` failure direction "
            "(spec §3.2)."
        )
        assert "over-reach" in body, (
            "Agent body must name the `over-reach` failure direction "
            "(spec §3.2)."
        )

    def test_body_documents_disclosure_fields(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The ScopeResolution disclosure surface: in_scope,
        adjacent_excluded (the load-bearing honesty field, never
        omitted), scope_confidence."""
        body = self._agent_body(diagnostic_legibility_path)
        for field in ("in_scope", "adjacent_excluded", "scope_confidence"):
            assert field in body, (
                f"Agent body must document the ScopeResolution field "
                f"{field!r}."
            )

    def test_body_documents_empty_task_contract(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """A well-formed task that resolves to no process is an honest
        empty result (in_scope: [] + scope_confidence: low), NOT a
        refusal; refuse only when `task:` is missing/empty (spec §4.3
        empty-task analogue)."""
        body = self._agent_body(diagnostic_legibility_path)
        assert "empty-task contract" in body.lower() or (
            "empty-task" in body.lower()
        ), (
            "Agent body must document the empty-task contract for "
            "scope-resolution mode."
        )
        assert "in_scope: []" in body, (
            "Agent body must show the empty-task shape `in_scope: []`."
        )
        # The missing-task refusal example.
        assert (
            "scope-resolution mode requires a non-empty task" in body
        ), (
            "Agent body must carry the missing/empty-task refusal "
            "example for scope-resolution mode."
        )

    # -- output shape divergence -------------------------------------

    def test_body_states_output_is_scoperesolution_not_model(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """In scope-resolution mode the output is a ScopeResolution, NOT
        a LegibilityModel and NOT a full ConceptualPipelineMap (no
        stages/transitions — no flow traced at v0.7.0). The mode's
        divergent output shape must be stated explicitly so consumers do
        not expect a LegibilityModel."""
        body = self._agent_body(diagnostic_legibility_path)
        assert "conceptual-pipeline-map.md" in body, (
            "Agent body must reference the conceptual-pipeline-map.md "
            "template as the home of the ScopeResolution contract."
        )
        # The divergence is stated near the scope-resolution output.
        assert "not a `LegibilityModel`" in body or (
            "*not* a `LegibilityModel`" in body
        ), (
            "Agent body must state that scope-resolution output is NOT a "
            "LegibilityModel."
        )

    # -- read-only boundary unchanged --------------------------------

    def test_scope_resolution_keeps_read_only_boundary(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Resolving scope is more reading, not more capability — the
        Read/Glob/Grep boundary is unchanged (spec §5). Re-assert the
        tool boundary holds with the new mode present."""
        component = plugin_runner.find_component(
            diagnostic_legibility_path,
            name="diagnostic-legibility",
            component_type="agent",
        )
        tools_raw = component.frontmatter.get("tools", "")
        if isinstance(tools_raw, list):
            tools = {t.strip() for t in tools_raw}
        else:
            tools = {t.strip() for t in str(tools_raw).split(",")}
        for required in ("Read", "Glob", "Grep"):
            assert required in tools, (
                f"Agent tools must include {required!r}."
            )
        for forbidden in ("Write", "Edit", "Bash"):
            assert forbidden not in tools, (
                f"Agent tools must NOT include {forbidden!r} — "
                "scope-resolution is more reading, not more capability "
                "(spec §5)."
            )

    # -- anti-patterns (the failure modes the protocol guards) -------

    def test_body_names_scope_resolution_anti_patterns(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The Anti-patterns section must name the scope-resolution
        failure modes: silent boundary, near-as-hard-bound, and
        change-site prediction (the deferred follow-on #368)."""
        body = self._agent_body(diagnostic_legibility_path)
        low = body.lower()
        assert "silent boundary" in low, (
            "Anti-patterns must name the `silent boundary` failure mode."
        )
        assert "#368" in body, (
            "Anti-patterns must reference #368 — change-site prediction "
            "is a deferred follow-on, not part of v0.7.0 scope-resolution."
        )


# ---------------------------------------------------------------------
# Pipeline mode (P3, v0.8.0)
# ---------------------------------------------------------------------


@pytest.mark.structural
class TestDiagnosticLegibilityPipelineMode:
    """P3 adds `mode: pipeline` to the diagnostic-legibility agent: within
    the bound resolved by the scope-resolution protocol, trace control
    flow into a ConceptualPipelineMap and build the architectural/domain
    LegibilityModel collections, then self-challenge pipeline stages
    through a flow-flavoured five-question cover plus a scope-relevance
    feedback loop. Cross-check is deferred to P4. Output is one response
    with two standalone fenced YAML blocks. Deterministic, file-shape
    assertions over the agent file's static text and frontmatter.

    Spec reference:
        docs/superpowers/specs/2026-06-03-dl-pipeline-map-design.md (§6.1, §6.2)
    """

    def _agent_body(self, diagnostic_legibility_path: Path) -> str:
        agent_file = (
            diagnostic_legibility_path
            / "agents"
            / "diagnostic-legibility.agent.md"
        )
        return agent_file.read_text()

    # -- discovery surface -------------------------------------------

    def test_description_names_pipeline_mode(
        self, diagnostic_legibility_path: Path
    ) -> None:
        component = plugin_runner.find_component(
            diagnostic_legibility_path,
            name="diagnostic-legibility",
            component_type="agent",
        )
        description = component.frontmatter.get("description") or ""
        assert "pipeline" in description, (
            "Agent description must name the `pipeline` mode (spec §6)."
        )
        assert "ConceptualPipelineMap" in description, (
            "Agent description must name the ConceptualPipelineMap the "
            "pipeline mode emits."
        )

    # -- mode plumbing -----------------------------------------------

    def test_body_declares_four_modes(
        self, diagnostic_legibility_path: Path
    ) -> None:
        body = self._agent_body(diagnostic_legibility_path)
        for marker in (
            "mode: full",
            "mode: cross-check-only",
            "mode: scope-resolution",
            "mode: pipeline",
        ):
            assert marker in body, (
                f"Agent body must name the `{marker}` marker (four modes "
                "at v0.8.0)."
            )

    def test_unrecognised_mode_refusal_lists_pipeline(
        self, diagnostic_legibility_path: Path
    ) -> None:
        body = self._agent_body(diagnostic_legibility_path)
        assert (
            "'full', 'cross-check-only', 'scope-resolution', or 'pipeline'"
            in body
        ), (
            "The unrecognised-mode refusal example must enumerate all "
            "four legal mode values including 'pipeline'."
        )

    def test_pipeline_missing_task_refusal_example(
        self, diagnostic_legibility_path: Path
    ) -> None:
        body = self._agent_body(diagnostic_legibility_path)
        assert (
            "pipeline mode requires a non-empty task" in body
        ), (
            "Agent body must carry the missing/empty-task refusal example "
            "for pipeline mode."
        )

    # -- the protocol ------------------------------------------------

    def test_body_has_pipeline_protocol(
        self, diagnostic_legibility_path: Path
    ) -> None:
        body = self._agent_body(diagnostic_legibility_path)
        assert "Pipeline protocol" in body, (
            "Agent body must carry a `Pipeline protocol` section."
        )

    def test_pipeline_phase_a_trace_steps(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Phase A (pipeline) must name the trace behaviour: entry-point
        discovery, following the dominant path, classifying stage kinds,
        recording transitions + realises, and building the
        architectural/domain collections within the bound (spec §6.1)."""
        body = self._agent_body(diagnostic_legibility_path)
        low = body.lower()
        assert "entry point" in low or "entry points" in low, (
            "Pipeline Phase A must name entry-point discovery (spec §6.1)."
        )
        assert "dominant" in low, (
            "Pipeline Phase A must name following the dominant call/data "
            "path (spec §6.1)."
        )
        # Stage kinds the trace classifies.
        for kind in ("step", "decision", "outcome"):
            assert kind in body, (
                f"Pipeline Phase A must name the `{kind}` stage kind."
            )
        assert "realises" in body, (
            "Pipeline Phase A must record `realises` cross-model links "
            "(the P4 cross-check seam)."
        )

    def test_pipeline_builds_all_three_collections(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Pipeline mode builds the ConceptualPipelineMap AND the
        architectural[]/domain[] collections within the bound (spec
        §4.3 / §6.1 — the cross-model bundle P4 reads)."""
        body = self._agent_body(diagnostic_legibility_path)
        assert "architectural[]" in body and "domain[]" in body, (
            "Pipeline mode must build the architectural[]/domain[] "
            "collections alongside the map."
        )

    def test_one_dominant_pipeline_per_task(
        self, diagnostic_legibility_path: Path
    ) -> None:
        body = self._agent_body(diagnostic_legibility_path)
        assert "one dominant pipeline" in body.lower(), (
            "Pipeline mode traces ONE dominant pipeline per task at "
            "v0.8.0 (multiple pipelines out of scope, spec §8)."
        )

    # -- flow-flavoured challenge cover -------------------------------

    def test_five_flow_flavoured_questions(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """The Phase B (pipeline) cover: phantom edge, condition
        fidelity, missed branch, smeared step, ungrounded node (spec
        §6.2)."""
        body = self._agent_body(diagnostic_legibility_path)
        low = body.lower()
        for q in (
            "phantom edge",
            "condition fidelity",
            "missed branch",
            "smeared step",
            "ungrounded node",
        ):
            assert q in low, (
                f"Agent body must name the flow-flavoured challenge "
                f"question {q!r} (spec §6.2)."
            )

    def test_scope_relevance_feedback_loop(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Phase B re-tests the P2 bound against the trace and feeds
        under/over-reach corrections back into scope_resolution — the
        predicted-vs-traced loop (spec §6.2)."""
        body = self._agent_body(diagnostic_legibility_path)
        low = body.lower()
        assert "scope-relevance" in low, (
            "Pipeline Phase B must name the scope-relevance check."
        )
        # It feeds corrections back into scope_resolution.
        assert "scope_resolution" in body, (
            "The scope-relevance check must feed corrections back into "
            "`scope_resolution`."
        )

    # -- output shape ------------------------------------------------

    def test_pipeline_output_two_blocks(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Pipeline mode emits two standalone fenced YAML blocks in one
        response: ConceptualPipelineMap then LegibilityModel (spec §4.3
        resolution)."""
        body = self._agent_body(diagnostic_legibility_path)
        # The output section names the two-block contract.
        assert "two" in body.lower() and "ConceptualPipelineMap" in body, (
            "Pipeline output must be documented as two standalone YAML "
            "blocks (ConceptualPipelineMap + LegibilityModel)."
        )
        assert "LegibilityModel" in body, (
            "Pipeline output must name the second block, LegibilityModel."
        )

    def test_pipeline_defers_cross_check(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """At v0.8.0 pipeline mode does NOT run Phase C: the
        LegibilityModel carries `cross_check_status: not_run` and no
        CC<N> entries (cross-check is P4)."""
        body = self._agent_body(diagnostic_legibility_path)
        assert "cross_check_status: not_run" in body, (
            "Pipeline mode must document emitting "
            "`cross_check_status: not_run` (Phase C deferred to P4)."
        )

    # -- anti-patterns -----------------------------------------------

    def test_pipeline_anti_patterns(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Anti-patterns must name the pipeline failure modes: phantom
        edges, tracing beyond the bound, multiple pipelines, and running
        cross-check in pipeline mode."""
        body = self._agent_body(diagnostic_legibility_path)
        low = body.lower()
        assert "phantom edge" in low, (
            "Anti-patterns must name phantom edges (pipeline mode)."
        )
        assert "beyond the bound" in low, (
            "Anti-patterns must name tracing beyond the bound."
        )
        assert "multiple pipelines" in low, (
            "Anti-patterns must name multiple pipelines in one map."
        )
        assert "running cross-check in pipeline mode" in low, (
            "Anti-patterns must forbid running cross-check in pipeline "
            "mode (Phase C is P4)."
        )
