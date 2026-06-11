# Model Routing

<!-- Model-tier guidance for agent dispatch. Agent definitions stay
     model: inherit — routing decisions are made at dispatch time. -->

## Agent Routing

| Agent | Model tier | Rationale |
| --- | --- | --- |
| orchestrator | Most capable | Coordination, judgment, decomposition |
| spec-writer | Most capable | Design judgment, specification quality |
| advocatus-diaboli | Most capable | Adversarial reasoning, evidence-grounded objection — judgment-heavy, not throughput-heavy. Both spec-time and code-time dispatches use this tier; the judgment load is equivalent across modes. |
| tdd-agent | Standard | Structured output from specs |
| {{LANGUAGE}}-implementer | Standard / Capable | Depends on task complexity |
| code-reviewer | Most capable | Nuance, quality judgment |
| integration-agent | Standard | Procedural workflow |
| cost-estimator | Standard | Read-and-author against a fixed methodology and named grounding sources — applies the cost-estimation skill and emits a conforming record. Not deep adversarial judgment or design synthesis; it follows a defined derivation (like tdd-agent). |

## Token Budget Guidance

| Role | Typical range | Escalation signal |
| --- | --- | --- |
| spec-writer | 50-100k tokens | >100k: scope too large, decompose |
| tdd-agent | 50-150k tokens | >150k: too many scenarios, split |
| implementer | 100-250k tokens | >250k: task needs decomposition |
| code-reviewer | 50-100k tokens | >100k: too many files, batch |
| integration-agent | 30-80k tokens | >80k: CI issues, investigate |

## Sovereignty Considerations

### Data Classification

| Data sensitivity | Routing rule | Example |
| --- | --- | --- |
| Public | Any model, any hosting | Open-source code generation, public documentation |
| Internal | Cloud APIs acceptable with appropriate ToS | Internal tooling, non-regulated business logic |
| Sensitive | Cloud private endpoints or self-hosted | PII processing, financial calculations, health data |
| Restricted | Self-hosted only | Regulatory-mandated data residency, classified information |

### Local Model Availability

| Agent role | Local model option | When to use local |
| --- | --- | --- |
| implementer | Qwen 2.5-Coder / DeepSeek Coder V2 | Sensitive data, cost optimisation at scale |
| code-reviewer | (frontier API recommended) | Local models lack sufficient judgment for review |
| integration-agent | Any capable local model | Procedural workflow, no sensitive data concerns |

### Fallback Strategy

If the primary model provider is unavailable:

1. Route to local model for non-frontier tasks
2. Queue frontier-required tasks until provider recovers
3. Specifications are precise enough to regenerate with any capable model
