"""Layer 1 structural tests for the diagnostic-legibility plugin at v0.3.0.

Sub-S2b ships the working `diagnostic-legibility` agent, the version
bump from 0.2.0 to 0.3.0, the CHANGELOG entry, and two docs-site pages
(how-to and explanation). These are deterministic, file-shape assertions
— the agent's behavioural contract (challenge_notes shape, Q<N> prefix,
sentinels) is covered by the spec at
`docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md`
as acceptance documentation rather than executable tests.

The TDAD scenario discipline does not extend to the diagnostic-legibility
plugin (the TDAD-scenario-check workflow is scoped to the
`ai-literacy-superpowers/` plugin only). Story #7 / issue #338 documents
the intentional gap. This file is the deterministic structural layer that
guards the v0.3.0 deliverables; it mirrors the precedent set by
`test_model_cards_structural.py` for the sibling plugin.

Spec reference:
    docs/superpowers/specs/2026-05-28-dl-s2b-challenge-protocol-design.md
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
    """The plugin version bump from 0.2.0 to 0.3.0 must land in lockstep
    across plugin.json, marketplace.json's per-plugin entry, and the
    CHANGELOG heading.

    The marketplace listing's top-level `version` (0.4.0) and its
    `plugin_version` pointer (0.39.1 at spec time) are explicitly
    unchanged by this slice — the spec §9 names this and the
    integration-agent is responsible for taking `plugin_version` from
    main verbatim at rebase time.
    """

    def test_plugin_json_at_0_4_0(
        self, diagnostic_legibility_path: Path
    ) -> None:
        manifest_path = (
            diagnostic_legibility_path
            / ".claude-plugin"
            / "plugin.json"
        )
        manifest = json.loads(manifest_path.read_text())
        assert manifest["version"] == "0.4.0", (
            "diagnostic-legibility/.claude-plugin/plugin.json must "
            "carry version '0.4.0' (was '0.3.0' at sub-S2b). "
            f"Actual: {manifest['version']!r}"
        )

    def test_marketplace_entry_at_0_4_0(self, repo_root: Path) -> None:
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
        assert entry["version"] == "0.4.0", (
            "marketplace.json diagnostic-legibility entry must be at "
            f"'0.4.0' (was '0.3.0' at sub-S2b). Actual: {entry['version']!r}"
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
            f"per spec §9. Actual: {marketplace['version']!r}"
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

    def test_changelog_has_0_4_0_heading(
        self, diagnostic_legibility_path: Path
    ) -> None:
        changelog = (
            diagnostic_legibility_path / "CHANGELOG.md"
        ).read_text()
        assert "## 0.4.0 — 2026-06-01" in changelog, (
            "CHANGELOG.md must contain a `## 0.4.0 — 2026-06-01` heading. "
            "Note: the dash is the em-dash (U+2014), matching the format "
            "enforced by the version-consistency CI check."
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

    def test_how_to_links_forward_to_issue_333(
        self, repo_root: Path
    ) -> None:
        """The how-to page documents the bare-Task-tool invocation
        pattern as the v0.3.0 surface and links forward to issue #333
        (parent S4 — the `/diagnose` command) so a reader who hits the
        ergonomics gap can find the work that closes it."""
        page = (
            repo_root
            / "docs"
            / "plugins"
            / "diagnostic-legibility"
            / "how-to"
            / "invoke-the-agent.md"
        )
        body = page.read_text()
        assert "#333" in body, (
            "How-to page must reference issue #333 — the forward link "
            "to parent S4 (the `/diagnose` command surface)."
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
