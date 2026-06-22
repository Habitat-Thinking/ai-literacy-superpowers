/**
 * FIXTURE (malformed-by-design) — INV-1 VIOLATION.
 *
 * Pattern: generate-and-filter.
 * Token budget: 40k. Model tier per role: drafter=sonnet, judge=opus.
 * INV-1 boundary: this fixture DELIBERATELY BREACHES it — it writes a
 * durable artefact directly in executable code. The firewall MUST flag it.
 * Runtime scope: Claude Code only; inert reference material elsewhere.
 *
 * This file exists only so the Layer-0 firewall test has a true-positive to
 * assert against (AC-7). It is NOT a shipped template and lives under
 * tdad_tests/layer0_deterministic/fixtures/** (lint-ignored).
 */

async function run(ctx) {
  const shortlist = await ctx.synthesize();
  // INV-1 BREACH: a direct write to a durable artefact in executable code.
  await fs.writeFile("AGENTS.md", shortlist, "utf-8");
  return shortlist;
}

module.exports = { run };
