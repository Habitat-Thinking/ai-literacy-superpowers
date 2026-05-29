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

    def test_plugin_json_at_0_3_0(
        self, diagnostic_legibility_path: Path
    ) -> None:
        manifest_path = (
            diagnostic_legibility_path
            / ".claude-plugin"
            / "plugin.json"
        )
        manifest = json.loads(manifest_path.read_text())
        assert manifest["version"] == "0.3.0", (
            "diagnostic-legibility/.claude-plugin/plugin.json must "
            "carry version '0.3.0' (was '0.2.0' at sub-S2a). "
            f"Actual: {manifest['version']!r}"
        )

    def test_marketplace_entry_at_0_3_0(self, repo_root: Path) -> None:
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
        assert entry["version"] == "0.3.0", (
            "marketplace.json diagnostic-legibility entry must be at "
            f"'0.3.0'. Actual: {entry['version']!r}"
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

    def test_changelog_has_0_3_0_heading(
        self, diagnostic_legibility_path: Path
    ) -> None:
        changelog = (
            diagnostic_legibility_path / "CHANGELOG.md"
        ).read_text()
        assert "## 0.3.0 — 2026-05-28" in changelog, (
            "CHANGELOG.md must contain a `## 0.3.0 — 2026-05-28` heading. "
            "Note: the dash is the em-dash (U+2014), matching the format "
            "enforced by the version-consistency CI check."
        )

    def test_changelog_references_followup_issues(
        self, diagnostic_legibility_path: Path
    ) -> None:
        """Stories #338 (revisit follow-up — TDAD scope) and #339
        (promotion follow-up — observability) must be named in the
        CHANGELOG so the audit trail surfaces them when someone reads
        the release notes."""
        changelog = (
            diagnostic_legibility_path / "CHANGELOG.md"
        ).read_text()
        assert "#338" in changelog, (
            "CHANGELOG entry must reference #338 (revisit follow-up "
            "from the choice-cartographer record)."
        )
        assert "#339" in changelog, (
            "CHANGELOG entry must reference #339 (promotion follow-up "
            "from the choice-cartographer record)."
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
        two machine-parseable contract terms (Q<N> prefix and the
        (empty scope) sentinel) so downstream consumers reading only
        the description know what to grep for.
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
