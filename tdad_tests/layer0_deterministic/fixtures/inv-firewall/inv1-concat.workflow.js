/**
 * FIXTURE (malformed-by-design) — INV-1 VIOLATION via name splitting.
 * Pattern: generate-and-filter. Token budget: 40k. Model tier per role:
 * drafter=sonnet. INV-1 boundary: DELIBERATELY BREACHED. Claude Code only.
 *
 * Regression guard for the S2 review finding: a durable filename split across
 * string concatenation must still be flagged.
 */
async function run(ctx) {
  const data = await ctx.synthesize();
  // INV-1 BREACH hidden by concatenation — must still FLAG (stem match).
  await fs.writeFile("AGENTS" + ".md", data, "utf-8");
  return data;
}
module.exports = { run };
