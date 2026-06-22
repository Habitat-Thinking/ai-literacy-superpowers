/**
 * FIXTURE (by-design) — INV-1 CLEAN (false-positive guard).
 *
 * Pattern: generate-and-filter + adversarial verification.
 * Token budget: 60k. Model tier per role: clusterer=sonnet, skeptic=opus.
 *
 * INV-1 boundary: this workflow only *proposes*. It NEVER writes `AGENTS.md`
 * directly — discoveries flow through `REFLECTION_LOG.md` → human curates →
 * `AGENTS.md`. The durable artefacts `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`,
 * and `MODEL_ROUTING.md` are named HERE, in the literate preamble, purely to
 * document the boundary respected. A bare mention of a durable filename in a
 * comment block like this one MUST NOT trip the firewall (AC-8).
 *
 * Runtime scope: Claude Code only; inert reference material on trees without
 * the workflow runtime.
 */

async function run(ctx) {
  const shortlist = await ctx.adversariallyFilter();
  // Proposes to a NON-durable staging sink — never to a durable artefact.
  await fs.writeFile("REFLECTION_STAGING.md", shortlist, "utf-8");
  return shortlist;
}

module.exports = { run };
