# 4. Solution Strategy

## Technology Decisions

| Decision | Choice | Serves quality goal |
|---|---|---|
| Execution model | Custom interpreter over parsed BPMN/CMMN/DMN XML — no external runtime dependency (e.g. no embedded JVM engine). | Simplicity, Correctness |
| State persistence | Event sourcing — every state transition is persisted as an immutable event; current state and revision history (including rollback) are derived from the event log. | Auditable, Correctness |
| Single-entity transitions | Processed synchronously, in-process. | Simplicity |
| Bulk transitions | Offloaded to Laravel queue workers for horizontal scale-out; entities sharing the same triggering event and model revision are grouped into fixed-size batches, one queue job per batch, to reduce dispatch overhead. | Performance (10k transitions/sec) |

_Free text, hand-authored, cross-linked to ADRs in
[Decisions](../decisions/index.md) — see ADR candidates: custom
interpreter vs. embedding an existing engine, event sourcing for state._

## Top-level Decomposition

One module per OMG standard, built on a shared core:

- **Core** — model persistence, the event-sourced revisioning engine, and
  the drop-in Laravel Model contract shared by all three standards.
- **BPMN module** — parsing and interpretation of BPMN 2.0 process
  models.
- **CMMN module** — parsing and interpretation of CMMN 1.1 case models.
- **DMN module** — parsing and evaluation of DMN decision models.

This decomposition is detailed further in
[Section 5: Building Block View](05-building-block-view.md).
