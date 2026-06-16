#!/usr/bin/env bash
set -euo pipefail
# Layer 0 test for the ## Affordances section in templates/HARNESS.md.
#
# This validates the STATIC template block (the four example entries) against
# the affordance field schema — required fields, Mode/Trigger pairing, Mode
# value, and Last-reviewed date format. It does NOT test /harness-affordance
# add's write logic, which is model-mediated (a command spec, not a script);
# that is covered by the add validation checkpoint and the spec's manual
# acceptance scenarios (see the step-3 spec's Adjudication A5).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS="$SCRIPT_DIR/../../ai-literacy-superpowers/templates/HARNESS.md"

python3 - "$HARNESS" <<'PYEOF'
import re, sys

text = open(sys.argv[1]).read()


def fail(msg):
    print(f"FAIL: {msg}", file=sys.stderr)
    sys.exit(1)


# Isolate the ## Affordances section (heading to next ## heading).
m = re.search(r"^## Affordances\s*$(.*?)^## ", text, re.MULTILINE | re.DOTALL)
if not m:
    fail("no ## Affordances section found in templates/HARNESS.md")
section = m.group(1)

# Strip HTML comments so example field lines inside comments are not parsed.
section_nc = re.sub(r"<!--.*?-->", "", section, flags=re.DOTALL)

# Split into entries on ### headings.
parts = re.split(r"^### (.+?)\s*$", section_nc, flags=re.MULTILINE)
# parts = [pre, name1, body1, name2, body2, ...]
entries = list(zip(parts[1::2], parts[2::2]))
if len(entries) < 4:
    fail(f"expected the 4 example entries, found {len(entries)}: "
         f"{[n for n, _ in entries]}")

VALID_MODES = {"local-mcp", "central-mcp", "cli", "hook"}
REQUIRED = ["Mode", "Identity", "Audit trail", "Permission", "Last reviewed"]


def field(body, name):
    # `- **Field**: value` — value may wrap onto continuation lines.
    m = re.search(rf"^- \*\*{re.escape(name)}\*\*:\s*(.*)$", body, re.MULTILINE)
    return m.group(1).strip() if m else None


for name, body in entries:
    for req in REQUIRED:
        if field(body, req) is None:
            fail(f"entry '{name}' missing required field '{req}'")

    mode = field(body, "Mode")
    # Mode value may carry a parenthetical (e.g. "central-mcp (api.honeycomb.io)").
    mode_word = mode.split()[0] if mode else ""
    if mode_word not in VALID_MODES:
        fail(f"entry '{name}' has invalid Mode '{mode}'")

    trigger = field(body, "Trigger")
    if mode_word == "hook" and trigger is None:
        fail(f"entry '{name}' is Mode: hook but has no Trigger")
    if mode_word != "hook" and trigger is not None:
        fail(f"entry '{name}' is Mode: {mode_word} but declares a Trigger")

    last = field(body, "Last reviewed")
    if not re.match(r"^\d{4}-\d{2}-\d{2}$", last or ""):
        fail(f"entry '{name}' Last reviewed is not YYYY-MM-DD: '{last}'")

# At least one hook example (exercises the Trigger pairing) and one non-hook.
modes = {field(b, "Mode").split()[0] for _, b in entries}
if "hook" not in modes:
    fail("expected at least one hook example to exercise the Trigger pairing")
if not (modes - {"hook"}):
    fail("expected at least one non-hook example")

print(f"All affordance-template checks passed ({len(entries)} entries).")
PYEOF
