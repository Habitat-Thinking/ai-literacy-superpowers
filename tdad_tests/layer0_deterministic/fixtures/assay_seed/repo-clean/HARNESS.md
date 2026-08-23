# Harness

## Context

A small service. Python, pytest, GitHub Actions.

## Constraints

### Tests pass before merge

- **Rule**: The test suite must pass before a pull request is merged.
- **Enforcement**: deterministic
- **Tool**: `pytest`
- **Scope**: pr
