# 12. Glossary

_Domain and technical terms. Where a term is formally defined in a
source of truth (e.g. a DMN input/output label, an OpenAPI schema field,
a BPMN element name), prefer generating this table from that source
rather than hand-maintaining it._

| Term | Definition | Source |
|---|---|---|
| OMG | Object Management Group — the standards body that defines BPMN, CMMN, and DMN. | — |
| BPMN | Business Process Model and Notation — an OMG standard for modeling business processes as flows of activities and events. | — |
| CMMN | Case Management Model and Notation — an OMG standard for modeling case-based work that doesn't follow a strict predefined sequence. | — |
| DMN | Decision Model and Notation — an OMG standard for modeling and evaluating decision logic (decision tables). | — |
| Model Definition | A named BPMN, CMMN, or DMN model managed by the Model Registry; has one or more Model Revisions. | [Cross-cutting Concepts](08-crosscutting-concepts.md), `data-model/domain-model.mmd` |
| Model Revision | A specific version of a Model Definition's XML; entities can transition or roll back between revisions. | [Cross-cutting Concepts](08-crosscutting-concepts.md), `data-model/domain-model.mmd` |
| Instance | An active process or case entity being driven through a specific Model Revision. | [Cross-cutting Concepts](08-crosscutting-concepts.md), `data-model/domain-model.mmd` |
| Transition Event | An immutable event recording one state transition of an Instance, per the event-sourcing decision ([ADR-003](../decisions/adr-003-event-sourcing.md)). | [Cross-cutting Concepts](08-crosscutting-concepts.md), `data-model/domain-model.mmd` |
| Decision Log | A record of one DMN decision evaluation — inputs, outputs, and the Model Revision used — for auditability. | [Cross-cutting Concepts](08-crosscutting-concepts.md), `data-model/domain-model.mmd` |
