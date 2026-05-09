"""SDK invocation helpers for Layer 2 (trigger) and Layer 3 (behavioural).

This module is the bridge between the markdown scenario format and the
Claude Agent SDK. It deliberately exposes a small surface — three
async functions — and hides everything else behind it. The reason is
literate-programming-shaped: the test files should read like assertions
about behaviour, not like SDK plumbing.

The three exposed helpers:

- ``match_skills`` (Layer 2): given a query and a list of skill
  ``(name, description)`` pairs, ask the model which skills it would
  invoke. Returns the list of matching skill names.

- ``invoke_agent`` (Layer 3, spec-writer-shaped): load an agent's
  body as the system prompt, give it tool access in a sandboxed
  ``cwd``, send a user message, capture text response and tool uses.
  Returns a structured result the test can assert against.

- ``grade_with_rubric`` (Layer 3, judge step): hand a piece of
  output and a list of pass/fail criteria to a separate inference,
  receive a per-criterion verdict. This is LLM-as-judge for the
  probabilistic assertions that resist exact-match.

Why three helpers, not one? Because the three failure modes are
different. ``match_skills`` failure means a description has drifted.
``invoke_agent`` failure means the agent's body produces wrong
behaviour. ``grade_with_rubric`` failure could be either — but the
caller knows which output it asked the rubric to grade.

The SDK is imported defensively. If the package isn't available
(common on Python ≤3.10 systems where the spike's Layer 1 still
needs to run), the imports degrade gracefully and any helper raises a
clear error if called. Layer 1 tests, which never call these helpers,
remain runnable.

Cost discipline: this module picks model defaults that keep per-test
cost low. Trigger checks default to Haiku (cheap, sufficient for
classification). Behavioural runs default to Sonnet (capable enough,
not Opus prices). Callers can override.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path

# Defensive SDK import. The SDK requires Python 3.11+ and is only
# needed for Layer 2 and Layer 3. Layer 1 must keep working without it.
# Tests that call into this module are gated on ANTHROPIC_API_KEY via
# the ``needs_api`` fixture, so a missing SDK is a strictly stronger
# failure mode than a missing key — but the error message should be
# clearer than ``ImportError``.
try:
    from claude_agent_sdk import (
        ClaudeAgentOptions,
        query,
    )

    _SDK_AVAILABLE = True
    _SDK_IMPORT_ERROR: str | None = None
except ImportError as exc:  # pragma: no cover - environment-dependent
    ClaudeAgentOptions = None  # type: ignore[assignment]
    query = None  # type: ignore[assignment]
    _SDK_AVAILABLE = False
    _SDK_IMPORT_ERROR = str(exc)


# Model defaults. Picked to keep per-test cost low while remaining
# capable enough to be informative. ``HAIKU`` for classification-style
# work (trigger matching, rubric grading); ``SONNET`` for generation
# work (spec writing, code review).
HAIKU = "claude-haiku-4-5-20251001"
SONNET = "claude-sonnet-4-6"


@dataclass
class AgentInvocationResult:
    """Captured output from a single ``invoke_agent`` call."""

    response_text: str
    """The assistant's final text response (concatenation of all
    text blocks across all assistant messages)."""

    tool_uses: list[dict] = field(default_factory=list)
    """One entry per tool call: ``{"tool": str, "input": dict}``."""

    cwd: Path | None = None
    """The working directory the agent ran in — useful for asserting
    against file system state after the run."""


def _require_sdk() -> None:
    """Raise a clear error if the SDK isn't importable.

    Used at the top of every helper so the failure surface is
    well-named: callers see ``RuntimeError: claude-agent-sdk is not
    installed`` instead of an ``AttributeError`` deeper in the stack.
    """
    if not _SDK_AVAILABLE:
        raise RuntimeError(
            "claude-agent-sdk is not installed. Layer 2 and Layer 3 "
            "tests require it. Install with: pip install claude-agent-sdk "
            f"(import error: {_SDK_IMPORT_ERROR})"
        )


def _extract_text(message) -> str:
    """Pull all text from an assistant message's content blocks.

    The SDK exposes typed message objects with ``content`` lists of
    blocks. Each block has either a ``text`` attribute (text block) or
    ``name``/``input`` attributes (tool use block). This helper walks
    the text blocks and concatenates them; tool uses are handled
    elsewhere.
    """
    parts: list[str] = []
    content = getattr(message, "content", None)
    if not content:
        return ""
    for block in content:
        text = getattr(block, "text", None)
        if isinstance(text, str):
            parts.append(text)
    return "".join(parts)


def _extract_tool_uses(message) -> list[dict]:
    """Pull tool-use records from an assistant message."""
    uses: list[dict] = []
    content = getattr(message, "content", None)
    if not content:
        return uses
    for block in content:
        # Tool use blocks have a ``name`` (the tool) and an ``input``
        # (the structured arguments). Text blocks do not.
        name = getattr(block, "name", None)
        if not name:
            continue
        tool_input = getattr(block, "input", {}) or {}
        uses.append({"tool": name, "input": dict(tool_input)})
    return uses


# ---------------------------------------------------------------------------
# Layer 2: skill description trigger matching
# ---------------------------------------------------------------------------


async def match_skills(
    user_query: str,
    skill_index: list[tuple[str, str]],
    *,
    model: str = HAIKU,
) -> list[str]:
    """Ask the model which skills from a list it would invoke for a query.

    Parameters
    ----------
    user_query
        The user message that should (or should not) trigger one or
        more skills.
    skill_index
        List of ``(skill_name, description)`` pairs the model is
        choosing from. The full plugin's skill index — not just the
        target skill — should be passed, so the test exercises the
        same matching surface a real session would.
    model
        Model identifier. Defaults to Haiku; trigger matching is a
        classification task, not a generation task.

    Returns
    -------
    list[str]
        The skill names the model identifies as matching. Empty list
        if the model returned nothing parseable.
    """
    _require_sdk()

    listing = "\n".join(
        f"- {name}: {description}" for name, description in skill_index
    )
    prompt = (
        "Below is the catalogue of skills available to a Claude session, "
        "each with its description.\n\n"
        f"{listing}\n\n"
        "Given the following user query, identify which skills you would "
        "invoke to handle it. Return a JSON array of skill names — "
        "exactly as they appear in the catalogue above. If no skills "
        "match, return [].\n\n"
        f'Query: "{user_query}"\n\n'
        "Respond with just the JSON array, no markdown, no commentary."
    )

    options = ClaudeAgentOptions(
        system_prompt=(
            "You are a skill-matching assistant. Your job is to identify "
            "which catalogued skills would handle a given query. "
            "Respond with a JSON array only."
        ),
        allowed_tools=[],
        model=model,
    )

    response_text = ""
    async for message in query(prompt=prompt, options=options):
        response_text += _extract_text(message)

    # Be tolerant of the model wrapping its response in markdown
    # despite the instruction. Strip code fences before parsing.
    cleaned = response_text.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.strip("`")
        # Remove a leading "json" marker if present.
        if cleaned.lower().startswith("json"):
            cleaned = cleaned[4:].strip()

    try:
        parsed = json.loads(cleaned)
    except json.JSONDecodeError:
        return []
    if not isinstance(parsed, list):
        return []
    # Normalise: when the catalogue spans multiple plugins, the model
    # sometimes ignores the "exactly as they appear" instruction and
    # returns plugin-qualified forms like ``"model-cards:model-cards"``
    # instead of the bare skill name. Strip any ``<prefix>:`` segment
    # so the matcher's behaviour is the same in single-plugin and
    # multi-plugin cases. Surfaced by a real Layer 2 run on the
    # cross-plugin model-cards trigger test.
    names: list[str] = []
    for entry in parsed:
        text = str(entry)
        if ":" in text:
            text = text.rsplit(":", 1)[-1]
        names.append(text)
    return names


# ---------------------------------------------------------------------------
# Layer 3: agent invocation
# ---------------------------------------------------------------------------


async def invoke_agent(
    *,
    system_prompt: str,
    allowed_tools: list[str],
    user_message: str,
    cwd: Path,
    model: str = SONNET,
) -> AgentInvocationResult:
    """Run an agent's prompt against a fixture working directory.

    Parameters
    ----------
    system_prompt
        The agent's body (everything after the frontmatter in the
        agent's ``.agent.md`` file). This becomes the SDK's system
        prompt for the run.
    allowed_tools
        The tool list declared in the agent's frontmatter — typically
        a subset of ``["Read", "Write", "Edit", "Glob", "Grep",
        "Bash"]``.
    user_message
        The task the agent is being given.
    cwd
        Working directory for the run. The agent's tool calls operate
        relative to this directory; the test asserts against its
        contents afterwards. Pytest's ``tmp_path`` is the natural
        source.
    model
        Model identifier. Defaults to Sonnet.
    """
    _require_sdk()

    options = ClaudeAgentOptions(
        system_prompt=system_prompt,
        allowed_tools=allowed_tools,
        cwd=str(cwd),
        # Tests run unattended; permission prompts would block forever.
        # ``bypassPermissions`` is the SDK's mode that auto-accepts
        # tool invocations within ``allowed_tools``.
        permission_mode="bypassPermissions",
        model=model,
    )

    response_parts: list[str] = []
    tool_uses: list[dict] = []
    async for message in query(prompt=user_message, options=options):
        response_parts.append(_extract_text(message))
        tool_uses.extend(_extract_tool_uses(message))

    return AgentInvocationResult(
        response_text="".join(response_parts),
        tool_uses=tool_uses,
        cwd=cwd,
    )


# ---------------------------------------------------------------------------
# Layer 3: rubric grading via LLM-as-judge
# ---------------------------------------------------------------------------


async def grade_with_rubric(
    output: str,
    criteria: list[str],
    *,
    model: str = HAIKU,
) -> dict[str, bool]:
    """Grade an output against a list of pass/fail criteria.

    Parameters
    ----------
    output
        The text the rubric is grading. For a Layer 3 review test,
        this is the model's review of fixture code; for a Layer 3
        spec test, this is the produced ``spec.md`` content.
    criteria
        Ordered list of criteria the rubric should evaluate. Each
        criterion should be unambiguously true or false against the
        output.
    model
        Model identifier. Defaults to Haiku — grading is
        classification, not generation.

    Returns
    -------
    dict[str, bool]
        Mapping of criterion (verbatim from the input list) to a
        boolean verdict. Missing keys (model returned a partial
        response) default to ``False`` so over-counting never happens.
    """
    _require_sdk()

    numbered = "\n".join(
        f"{index + 1}. {criterion}"
        for index, criterion in enumerate(criteria)
    )
    prompt = (
        "Grade the following output against the criteria below.\n\n"
        "OUTPUT:\n---\n"
        f"{output}\n"
        "---\n\nCRITERIA:\n"
        f"{numbered}\n\n"
        "For each criterion, respond with true if the output clearly "
        "satisfies it, false otherwise. Be strict — false positives "
        "make the rubric useless.\n\n"
        "Return a JSON object mapping the criterion's number (as a "
        'string) to true or false. Example: {"1": true, "2": false}\n'
        "No markdown, no commentary, just the JSON object."
    )

    options = ClaudeAgentOptions(
        system_prompt=(
            "You are a strict rubric grader. You evaluate whether an "
            "output meets each criterion exactly. Respond with JSON only."
        ),
        allowed_tools=[],
        model=model,
    )

    response_text = ""
    async for message in query(prompt=prompt, options=options):
        response_text += _extract_text(message)

    cleaned = response_text.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.strip("`")
        if cleaned.lower().startswith("json"):
            cleaned = cleaned[4:].strip()

    try:
        verdicts = json.loads(cleaned)
    except json.JSONDecodeError:
        verdicts = {}
    if not isinstance(verdicts, dict):
        verdicts = {}

    # Map numbered keys back to the criterion text. The caller wants
    # to assert against the criteria they wrote, not against the
    # transient numbering we used in the prompt.
    result: dict[str, bool] = {}
    for index, criterion in enumerate(criteria):
        key = str(index + 1)
        verdict = verdicts.get(key, False)
        result[criterion] = bool(verdict) if isinstance(verdict, bool) else False
    return result
