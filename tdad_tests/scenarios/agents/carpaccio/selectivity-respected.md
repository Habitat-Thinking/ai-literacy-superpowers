---
component: carpaccio
component_type: agent
tier: structural
fixture: empty-repo
---

# Scenario: carpaccio respects the 9-slice cap

## Given

The agent is invoked with a deliberately sprawling task
description containing ≥ 20 candidate decision boundaries:

> *"Build a new analytics dashboard. Requirements: (1) ingest
> events from Kafka; (2) parse the event schema; (3) validate
> payloads against the schema; (4) write valid events to
> ClickHouse; (5) emit a dead-letter queue for invalid
> payloads; (6) expose a REST API for query; (7) implement
> auth on the REST API; (8) implement rate limiting on the
> REST API; (9) build a React front-end for the dashboard;
> (10) add a date-range picker; (11) add filter controls per
> event type; (12) cache query results; (13) implement
> WebSocket push for real-time updates; (14) build an
> embeddable widget version; (15) write OpenAPI docs;
> (16) build the deployment Helm chart; (17) add OpenTelemetry
> tracing; (18) add Prometheus metrics; (19) emit a
> Honeycomb-compatible event stream; (20) write the runbook."*

## When

The carpaccio agent runs to completion.

## Then

The returned content must:

- Have `slices` array length ≤ 9
- The `## Explicitly not slicing on` section documents
  what was considered and discarded
- The prose for each surviving slice covers a meaningful
  cluster of the 20 listed items (not just one bullet
  per slice)

## Rubric

- *Did the agent compress thoughtfully?* The 9 surviving
  slices should each cover a coherent grouping of the
  20 input bullets — not "one slice per bullet" truncated
  at 9.
- *Did the agent document the compression?* The reasoning
  for grouping should be visible either in slice
  rationales or in the "Explicitly not slicing on" section.

## Cleanup

Remove the temporary fixture repository.

## Implementation note

This is a `tier: structural` scenario — it tests an
invariant (the cap) rather than fine-grained behaviour.
Same runner shape as `multi-decision-task.md`.
