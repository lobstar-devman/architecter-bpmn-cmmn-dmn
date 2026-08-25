# 11. Risks & Technical Debt

_Free text, hand-authored. Reviewed and updated at each architecture
step. Known technical debt items should reference the ADR (if any) that
accepted the trade-off._

| Risk | Description | Related ADR |
|---|---|---|
| OMG spec complexity/coverage gaps | BPMN/CMMN/DMN are large specifications; the custom interpreter may not cover every element or edge case, risking incomplete conformance against the Correctness goal. | [ADR-002](../decisions/adr-002-custom-interpreter.md) |
| Performance target unproven | The 10,000 transitions/sec goal (see [Quality Requirements](10-quality-requirements.md)) is unvalidated — no implementation or benchmark exists yet. | — |
| Event sourcing complexity | Event sourcing adds architectural complexity (replay, projections, eventual consistency) that trades against the Simplicity quality goal. | [ADR-003](../decisions/adr-003-event-sourcing.md) |
