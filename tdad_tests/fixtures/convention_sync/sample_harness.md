# HARNESS.md — Spike Phase 2 fixture

This is a deliberately small but realistic HARNESS.md used as input
to the convention-sync spike helper. It carries enough structure to
exercise the parser and the renderer without becoming a maintenance
burden.

## Context

### Stack

- Primary languages: Python 3.12, Bash
- Build system: uv + pyproject
- Test framework: pytest
- Container strategy: none in this fixture

### Conventions

- Naming: snake_case for files, PascalCase for classes
- Docstrings on all public modules and functions
- Use literate programming preamble for new source files

## Constraints

### Consistent formatting

- Rule: All source files must pass the project's configured formatter
  without changes
- Enforcement: deterministic
- Scope: commit

### No secrets in source

- Rule: No API keys, tokens, passwords, or private keys may appear
  in committed source files
- Enforcement: deterministic
- Scope: commit

## Garbage Collection

This section is intentionally not covered by the spike helper —
Garbage Collection is harness-internal and convention-sync skips it
deliberately.
