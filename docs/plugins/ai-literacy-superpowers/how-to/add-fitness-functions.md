---
title: Add Fitness Functions
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 3
redirect_from:
  - /how-to/add-fitness-functions/
  - /how-to/add-fitness-functions.html
---

# Add Fitness Functions

Add architectural fitness functions to HARNESS.md as weekly GC rules that detect system-wide
degradation — layer boundary violations, rising coupling, and complexity hotspots — that
per-change constraints miss.

---

## 1. Identify what to measure

Fitness functions answer "Is the system still healthy?" at a system-wide level. Pick checks
from these categories:

| Category | Examples |
| -------- | -------- |
| Structural | Layer boundary violations, circular dependencies |
| Coupling | Fan-in/fan-out growth, instability index changes |
| Complexity | Files with high churn correlated with growing complexity |
| Coverage | Test coverage declining in architecturally important layers |

Start with one structural check. Add coupling or complexity checks after the first is
running reliably.

---

## 2. Pick a tool for your stack

| Stack | Tool | Install |
| ----- | ---- | ------- |
| JavaScript/TypeScript | dependency-cruiser | `npm install --save-dev dependency-cruiser` |
| Java/Kotlin | ArchUnit | Add to build dependencies |
| Go | go-cleanarch | `go install github.com/roblaszczak/go-cleanarch@latest` |
| Python | import-linter | `pip install import-linter` |
| Any language | semgrep | `brew install semgrep` |

Verify the tool works against your codebase before wiring it into the harness:

```bash
# JavaScript example
npx dependency-cruiser --validate .dependency-cruiser.js src/

# Go example
go-cleanarch -application app -domain domain -infrastructure infra ./...
```

The tool should exit non-zero when a violation is present.

---

## 3. Add a GC rule to HARNESS.md

Open `HARNESS.md` and add an entry to the Garbage Collection section. Use
`deterministic` when the tool produces a clear pass/fail, and `agent` when
results need trend interpretation:

```markdown
### Layer boundary compliance

- **What it checks**: No imports crossing declared architectural boundaries
- **Frequency**: weekly
- **Enforcement**: deterministic
- **Tool**: npx dependency-cruiser --validate .dependency-cruiser.js src/
- **Auto-fix**: false
```

For checks that produce metrics rather than pass/fail (coupling trends, complexity scores),
use agent enforcement:

```markdown
### Coupling trend

- **What it checks**: Inter-module coupling has not increased since last snapshot
- **Frequency**: weekly
- **Enforcement**: agent
- **Tool**: npx dependency-cruiser --output-type metrics src/
- **Auto-fix**: false
```

Keep `Auto-fix` as `false` for all fitness functions. Architectural issues require
human judgement about the right fix.

---

## 4. Run the fitness function manually

Before relying on the scheduled GC run, confirm the rule works:

```text
/harness-gc
```

The GC agent reads the weekly rules from `HARNESS.md`, executes each tool command,
and reports findings. Review the output to confirm your new rule fires correctly.

---

## 5. Interpret the results

Fitness functions produce trend data, not binary pass/fail. Use this table:

| Trend | Action |
| ----- | ------ |
| Stable or improving | Record the snapshot, no action needed |
| Slow decline (1-2 snapshots) | Note it; watch next week |
| Sustained decline (3+ snapshots) | Create an issue with the trend data |
| Sudden spike | Investigate commits since the last snapshot |

---

## 6. Promote to a constraint if needed

If the same violation appears in three or more consecutive weekly snapshots, promote
it to a per-PR constraint so it blocks new violations at merge time:

1. Extract the specific pattern from the fitness function
2. Run `/harness-constrain` to add a targeted constraint in HARNESS.md
3. Set scope to `pr` and enforcement to `deterministic`
4. Keep the broader fitness function running — it catches drift the narrower
   constraint does not
