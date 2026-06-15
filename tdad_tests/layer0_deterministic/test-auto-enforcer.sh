#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for templates/ci-auto-enforcer.yml.
#
# The auto-enforcer ships as a single self-contained workflow template, so
# its logic lives in Python heredocs embedded in the YAML. Rather than test
# a copy (which would drift), this harness EXTRACTS each block from the YAML
# at test time and exercises the real shipped code against crafted inputs.
#
# Covers the four bugs fixed for the auto-enforcer cluster:
#   #325 parser double-appends the last constraint
#   #324 parse_field truncates multi-line rules
#   #323 COMMENT_MODE never applies (single-quoted heredoc)
#   #322 no retry on transient 429/529

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YAML="$SCRIPT_DIR/../../ai-literacy-superpowers/templates/ci-auto-enforcer.yml"

python3 - "$YAML" <<'HARNESS_EOF'
import json, os, subprocess, sys, tempfile, textwrap

yaml_path = sys.argv[1]
yaml_lines = open(yaml_path).read().split("\n")


def fail(msg):
    print(f"FAIL: {msg}", file=sys.stderr)
    sys.exit(1)


def extract_block(marker):
    """Return the dedented Python body of the `<<'MARKER'` heredoc."""
    start = next((i for i, l in enumerate(yaml_lines) if f"<<'{marker}'" in l), None)
    if start is None:
        fail(f"heredoc opener for {marker} not found in template")
    body = []
    for l in yaml_lines[start + 1:]:
        if l.strip() == marker:
            return textwrap.dedent("\n".join(body))
        body.append(l)
    fail(f"heredoc {marker} never closed")


PARSER_SRC = extract_block("PYEOF")
COMMENT_SRC = extract_block("COMMENTEOF")
AGENT_SRC = extract_block("AGENTEOF")


# --- #325 + #324: the constraint parser ---------------------------------
def test_parser_dedup_and_multiline():
    harness = textwrap.dedent("""\
        # HARNESS.md

        ## Constraints

        ### First constraint
        - **Rule**: A single-line rule.
        - **Enforcement**: agent
        - **Scope**: pr

        ### Second constraint
        - **Rule**: This rule wraps across
          multiple physical lines and the
          continuation must be folded in.
        - **Enforcement**: agent
        - **Scope**: pr

        ## Garbage Collection

        ### Some GC rule
        - **Frequency**: weekly
        """)
    with tempfile.TemporaryDirectory() as d:
        open(os.path.join(d, "HARNESS.md"), "w").write(harness)
        env_file = os.path.join(d, "gh_env")
        open(env_file, "w").close()
        env = dict(os.environ, GITHUB_ENV=env_file,
                   INCLUDE_CONSTRAINTS="", EXCLUDE_CONSTRAINTS="")
        r = subprocess.run([sys.executable, "-c", PARSER_SRC], cwd=d, env=env,
                           capture_output=True, text=True)
        if r.returncode != 0:
            fail(f"parser exited {r.returncode}: {r.stderr}")
        written = open(env_file).read()
        agents = None
        for line in written.split("\n"):
            if line.startswith("AGENT_CONSTRAINTS="):
                agents = json.loads(line[len("AGENT_CONSTRAINTS="):])
        if agents is None:
            fail("parser wrote no AGENT_CONSTRAINTS")
        names = [c["name"] for c in agents]
        # #325: each constraint exactly once despite the trailing ## section
        if len(names) != len(set(names)):
            fail(f"parser emitted duplicate constraints: {names}")
        if len(names) != 2:
            fail(f"expected 2 agent constraints, got {len(names)}: {names}")
        # #324: the multi-line rule is folded whole, not truncated
        second = next(c for c in agents if c["name"] == "Second constraint")
        if "continuation must be folded in" not in second["rule"]:
            fail(f"multi-line rule truncated: {second['rule']!r}")
        if "multiple physical lines" not in second["rule"]:
            fail(f"multi-line rule missing middle line: {second['rule']!r}")


def test_parser_constraints_as_final_section():
    # #325 acceptance: when ## Constraints is the LAST section, behaviour is
    # unchanged — the trailing flush still emits the final constraint once.
    harness = textwrap.dedent("""\
        # HARNESS.md

        ## Constraints

        ### Only constraint
        - **Rule**: Just one.
        - **Enforcement**: agent
        - **Scope**: pr
        """)
    with tempfile.TemporaryDirectory() as d:
        open(os.path.join(d, "HARNESS.md"), "w").write(harness)
        env_file = os.path.join(d, "gh_env")
        open(env_file, "w").close()
        env = dict(os.environ, GITHUB_ENV=env_file,
                   INCLUDE_CONSTRAINTS="", EXCLUDE_CONSTRAINTS="")
        subprocess.run([sys.executable, "-c", PARSER_SRC], cwd=d, env=env,
                       capture_output=True, text=True, check=True)
        agents = next(json.loads(l[len("AGENT_CONSTRAINTS="):])
                      for l in open(env_file).read().split("\n")
                      if l.startswith("AGENT_CONSTRAINTS="))
        if [c["name"] for c in agents] != ["Only constraint"]:
            fail(f"final-section constraint mis-parsed: {agents}")


# --- #323: comment-mode honoured via argv -------------------------------
def run_comment(results, mode):
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as f:
        json.dump(results, f)
        rf = f.name
    try:
        r = subprocess.run([sys.executable, "-c", COMMENT_SRC, rf, mode],
                           capture_output=True, text=True, check=True)
        return r.stdout.strip()
    finally:
        os.unlink(rf)


def test_comment_mode_findings_only_suppresses_all_pass():
    out = run_comment([{"name": "a", "type": "agent", "status": "PASS", "findings": "--"}],
                      "findings-only")
    if out != "SKIP_COMMENT":
        fail(f"all-PASS findings-only should SKIP_COMMENT, got: {out!r}")


def test_comment_mode_always_posts_all_pass():
    out = run_comment([{"name": "a", "type": "agent", "status": "PASS", "findings": "--"}],
                      "always")
    if "Auto-Enforcer Results" not in out:
        fail(f"mode=always should post a comment, got: {out!r}")


def test_comment_skip_is_a_finding():
    out = run_comment([{"name": "a", "type": "agent", "status": "SKIP", "findings": "x"}],
                      "findings-only")
    if "Auto-Enforcer Results" not in out:
        fail(f"SKIP should surface a comment in findings-only, got: {out!r}")


def test_comment_fail_posts():
    out = run_comment([{"name": "a", "type": "deterministic", "status": "FAIL", "findings": "boom"}],
                      "findings-only")
    if "Auto-Enforcer Results" not in out:
        fail(f"FAIL should post a comment, got: {out!r}")


# --- #322: bounded retry on transient errors ----------------------------
RETRY_PREAMBLE = textwrap.dedent("""\
    import os, urllib.request, urllib.error, time
    _count_file = os.environ["CALL_COUNT_FILE"]
    _scenario = os.environ["FAKE_SCENARIO"]
    _n = {"i": 0}
    class _Resp:
        def __init__(self, b): self._b = b
        def read(self): return self._b
        def __enter__(self): return self
        def __exit__(self, *a): return False
    def _fake(req, timeout=60):
        _n["i"] += 1
        open(_count_file, "w").write(str(_n["i"]))
        if _scenario == "529_then_ok":
            if _n["i"] == 1:
                raise urllib.error.HTTPError("u", 529, "Overloaded", {}, None)
            return _Resp(b'{"content":[{"text":"NO_FINDINGS"}]}')
        if _scenario == "persistent_529":
            raise urllib.error.HTTPError("u", 529, "Overloaded", {}, None)
        if _scenario == "fail_fast_401":
            raise urllib.error.HTTPError("u", 401, "Unauthorized", {}, None)
        raise AssertionError("unknown scenario")
    urllib.request.urlopen = _fake
    time.sleep = lambda *a, **k: None
    """)


def run_agent(scenario):
    patched = RETRY_PREAMBLE + AGENT_SRC
    with tempfile.TemporaryDirectory() as d:
        rf = os.path.join(d, "results.json")
        open(rf, "w").write("[]")
        ccf = os.path.join(d, "calls")
        env = dict(os.environ, FAKE_SCENARIO=scenario, CALL_COUNT_FILE=ccf,
                   ANTHROPIC_API_KEY="test-key", AGENT_MODEL="claude-test")
        env.pop("DIFF_FILE", None)
        r = subprocess.run([sys.executable, "-c", patched, "Test", "A rule", rf],
                           cwd=d, env=env, capture_output=True, text=True)
        if r.returncode != 0:
            fail(f"agent block exited {r.returncode} ({scenario}): {r.stderr}")
        status = json.load(open(rf))[-1]["status"]
        calls = int(open(ccf).read()) if os.path.exists(ccf) else 0
        return status, calls


def test_retry_transient_then_succeeds():
    status, calls = run_agent("529_then_ok")
    if status != "PASS":
        fail(f"529-then-OK should retry to PASS, got {status}")
    if calls != 2:
        fail(f"529-then-OK should make 2 calls, made {calls}")


def test_retry_persistent_skips_after_window():
    status, calls = run_agent("persistent_529")
    if status != "SKIP":
        fail(f"persistent 529 should end SKIP, got {status}")
    if calls != 3:
        fail(f"persistent 529 should exhaust 3 attempts, made {calls}")


def test_non_transient_fails_fast():
    status, calls = run_agent("fail_fast_401")
    if status != "SKIP":
        fail(f"401 should SKIP, got {status}")
    if calls != 1:
        fail(f"401 should fail fast (1 call), made {calls}")


TESTS = [v for k, v in sorted(globals().items()) if k.startswith("test_")]
for t in TESTS:
    t()
print(f"All {len(TESTS)} auto-enforcer tests passed.")
HARNESS_EOF
