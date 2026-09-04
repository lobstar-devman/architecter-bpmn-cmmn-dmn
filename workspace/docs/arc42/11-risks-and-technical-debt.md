# 11. Risks & Technical Debt

_Free text, hand-authored. Reviewed and updated at each architecture
step. Known technical debt items should reference the ADR (if any) that
accepted the trade-off._

| Risk | Description | Related ADR |
|---|---|---|
| OMG spec complexity/coverage gaps | BPMN/CMMN/DMN are large specifications; the custom interpreter may not cover every element or edge case, risking incomplete conformance against the Correctness goal. | [ADR-002](../decisions/adr-002-custom-interpreter.md) |
| Performance target unproven | The 10,000 transitions/sec goal (see [Quality Requirements](10-quality-requirements.md)) is unvalidated — no implementation or benchmark exists yet. | — |
| Event sourcing complexity | Event sourcing adds architectural complexity (replay, projections, eventual consistency) that trades against the Simplicity quality goal. | [ADR-003](../decisions/adr-003-event-sourcing.md) |
| Parsers don't validate unsupported elements | `BpmnParser`/`CmmnParser`/`DmnParser` only collect the specific element types they support, via targeted XPath queries — they never scan for and reject unrecognized elements (gateways, subprocesses, boundary events, CMMN stages/discretionary items, DMN DRGs, etc.) at parse time. The "fail loudly, not silently" language in [ADR-008](../decisions/adr-008-dmn-decision-table-scope.md)/[ADR-010](../decisions/adr-010-cmmn-case-plan-scope.md)/[ADR-011](../decisions/adr-011-bpmn-process-scope.md)'s Consequences is narrower than it reads: failure happens incidentally, only if a transition later needs a lookup that was never captured (e.g. `BpmnProcessModel::node()` throwing on an unknown id) — not from any deliberate graph-validation pass. An unsupported element that's never actually traversed into can parse and run to completion without ever surfacing an error. | [ADR-002](../decisions/adr-002-custom-interpreter.md), [ADR-008](../decisions/adr-008-dmn-decision-table-scope.md), [ADR-010](../decisions/adr-010-cmmn-case-plan-scope.md), [ADR-011](../decisions/adr-011-bpmn-process-scope.md) |
