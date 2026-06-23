---
component: reflect
component_type: command
tier: structural
---

# Scenario: the --mine section declares the Claude-Code-only runtime scope and the non-erroring guidance-only fallback (AC-7 / FR-5)

## Given

The mining-mode section of
`ai-literacy-superpowers/commands/reflect.md`.

## When

The `--mine` section is read.

## Then

- The section states `--mine` **requires the Claude Code runtime** — dynamic
  workflows are a Claude Code runtime capability, not transferable to other
  coding agents. `claude code` is **two words** — keep it **unwrapped**; the
  content test asserts "claude" and "code" as two independent co-occurring
  tokens (NOT a joined "claude code" substring), plus "runtime".
- The section states that on a tree **without** the runtime, `--mine`
  **degrades to guidance only** and **never errors** — it points the curator
  at the readable `dynamic-workflows` skill knowledge and the manual
  cluster / vet / promote path. Keep "guidance-only" (or "guidance only") and
  "never errors" each **unwrapped**; the content test asserts
  "guidance" co-occurring with "never error"/"never errors"/"does not error"
  and "fallback"/"fall back"/"degrade"/"degrades".

## Rubric

Deterministic structural shadow of AC-7 / FR-5. Dynamic workflows are a
Claude Code runtime capability; the plugin ships to both trees, so `--mine`
is Claude-Code-gated. Where the runtime exists, `--mine` spawns the
cluster→filter→shortlist workflow and writes `REFLECTION_STAGING.md`; where
it does not, `--mine` degrades to guidance only and never errors (§6 decision
2, option F1). The default `/reflect` capture path is identical on every
tree.

The load-bearing specifics:

- the fallback is **guidance-only and non-erroring** — it points the curator
  at the readable skill knowledge and the manual cluster/vet/promote path,
  leaving them able to act (just manually), rather than a bare no-op or an
  error;
- the broader cross-CLI degradation *contract* (guidance-only vs omit) is
  open-question 4, resolved in S7 — this section states only S6's own **local**
  non-erroring guidance-only behaviour and must not over-claim the S7
  contract.

## Evaluation

Evaluated deterministically by
`tests/test_s6_reflection_mining_structural.py`
(`TestS6ReflectClaudeCodeScopeAndFallback`). RED now because the mining-mode
section does not exist, so the Claude-Code-scope and guidance-only-fallback
phrases are absent.
