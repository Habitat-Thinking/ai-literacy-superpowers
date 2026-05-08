---
title: Set Up Model Routing
layout: default
parent: ai-literacy-superpowers
grand_parent: Plugins
nav_order: 19
redirect_from:
  - /how-to/set-up-model-routing/
  - /how-to/set-up-model-routing.html
---

# Set Up Model Routing

Decide which models handle which workloads, document those routing rules
in `MODEL_ROUTING.md`, and evaluate your sovereignty position.

---

## 1. Understand the decision hierarchy

Exhaust simpler approaches before escalating complexity. Each step adds
maintenance burden:

1. **Prompting + context engineering** — the default. Most teams
   underestimate how far this carries them.
2. **RAG** — when the limitation is knowledge that is volatile, large, or
   frequently changing.
3. **Fine-tuning (LoRA/QLoRA)** — when the limitation is behaviour:
   consistent domain-specific patterns at scale.
4. **Distillation** — when the limitation is size or speed (edge
   deployment, latency-sensitive workloads).
5. **Local hosting** — when the limitation is privacy, cost at scale, or
   independence from vendor defaults.

---

## 2. Classify your data

List every type of data that flows through your AI interactions. Classify
each as one of:

| Class | Description | Default routing |
| --- | --- | --- |
| Public | No restrictions | Cloud API |
| Internal | Business context, non-sensitive | Cloud API |
| Sensitive | PII, financial, health | Local or private cloud |
| Restricted | Regulated, trade secret, residency-bound | Local only |

If any data is Sensitive or Restricted, local hosting is non-negotiable
for those interactions. Consult your legal and compliance teams before
routing Restricted data to any external API.

---

## 3. Answer the routing decision questions

Work through these questions in order. Stop at the first "yes."

**Does your data require local processing?**
PII, regulated data, trade secrets, or data subject to residency
requirements means local hosting is required for those interactions.

**Does knowledge change frequently?**
Information changing weekly or monthly — add a RAG layer regardless of
hosting choice. RAG updates instantly; fine-tuning requires retraining.

**Does the model need consistent domain behaviour at scale?**
Reliable format compliance, style consistency, or decision logic across
thousands of requests — evaluate fine-tuning with LoRA/QLoRA.

**Is baseline load above the break-even threshold?**
Approximately 30M tokens per day sustained makes self-hosted inference
economically justified within four months.

**None of the above?**
Use cloud API models with good prompting and context engineering.

---

## 4. Create `MODEL_ROUTING.md`

Create a `MODEL_ROUTING.md` file at the repository root that documents
your routing decisions:

```markdown
# Model Routing

## Data Classification

| Data type | Class | Routing |
| --- | --- | --- |
| Source code context | Internal | Cloud API (Claude) |
| User PII in prompts | Sensitive | Blocked — strip before sending |
| Internal docs | Internal | Cloud API (Claude) |

## Routing Rules

| Workload | Model | Reason |
| --- | --- | --- |
| Code generation | Claude Sonnet (cloud) | Reasoning quality required |
| Doc generation | Claude Haiku (cloud) | Cost-sensitive, lower stakes |
| On-device inference | Ollama (local) | Sensitive internal data |

## Fallback

If the primary model API is unavailable:
1. [Alternative model or provider]
2. Degrade to [manual process]

## Sovereignty Test

If our primary API provider changed pricing, rate-limited us, or
discontinued our model tomorrow:
- Fallback model identified: [yes/no — model name]
- Specifications precise enough to regenerate with another model: [yes/no]
- Local alternative evaluated: [yes/no — tool name]
- Data classification covering all flows: [yes/no]
```

---

## 5. Evaluate local hosting options

If local hosting is needed for any workload, evaluate your options:

**Ollama** — simplest local inference, good for development and
privacy-sensitive workloads:

```bash
brew install ollama
ollama pull llama3
ollama run llama3
```

**vLLM** — production-grade inference server for GPU-backed deployments:

```bash
pip install vllm
python -m vllm.entrypoints.openai.api_server --model mistralai/Mistral-7B-v0.1
```

Test that local inference meets your quality bar before committing to it
for production workloads.

---

## 6. Plan maintenance cadence

Custom models accumulate maintenance debt. Document the cadence in
`MODEL_ROUTING.md`:

- **Version pinning** — pin model versions and test before updating
- **Retraining** — quarterly for fine-tuned models
- **Drift detection** — monitor output quality metrics over time
- **Exit strategy** — every custom model needs a cloud fallback

---

## Summary

After completing these steps you have:

- Data classified by sensitivity and routed accordingly
- `MODEL_ROUTING.md` documenting routing rules and fallback options
- A completed sovereignty test showing your vendor dependency position
- A maintenance plan for any custom or local models in use
