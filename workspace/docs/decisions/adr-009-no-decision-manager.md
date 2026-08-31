# ADR-009: No Decision Manager — DMN Evaluator resolves, evaluates, and logs directly

**Status:** accepted
**Date:** 2026-08-31

## Context

[Section 6](../arc42/06-runtime-view.md)'s "Evaluate a DMN decision
table" sequence shows the host app calling `evaluate(decisionKey,
inputData)` directly on the DMN Evaluator, which itself calls the Model
Registry to resolve — and, via the Model Registry, the DMN Parser to
parse/cache — the decision model before evaluating. This differs from
BPMN: there, the Revision Manager (a Core component) sits between the
host app and the BPMN Interpreter, resolving the model, invoking the
Interpreter, persisting the transition, and dispatching
`TransitionRoleContext`. [Section 8](../arc42/08-crosscutting-concepts.md)
requires a Decision Log row per evaluation (inputs, outputs, and the
model revision used), and [Section 5](../arc42/05-building-block-view.md)'s
Building Block View names no orchestrating "Decision Manager" component
for DMN the way it names Revision Manager for BPMN/CMMN.

Implementing against the diagram as drawn therefore leaves the DMN
Evaluator doing three things — resolve, evaluate, log — where the BPMN
side splits the equivalent work across two components (Revision Manager
and BPMN Interpreter). That asymmetry is deliberate, not an
oversight, and this ADR records why it wasn't corrected by adding a
matching component.

## Decision

DMN evaluation keeps the flat structure the runtime view diagrams: the
DMN Evaluator resolves the target decision via the Model Registry,
evaluates it, and writes the Decision Log row itself. It is not split
into a pure, Interpreter-equivalent evaluation step plus a separate Core
orchestrator. No new Building Block View component ("Decision Manager")
is introduced — the same "no new component" stance
[ADR-005](adr-005-role-context-not-enforced.md) took for role/lane
handling.

## Consequences

- The DMN Evaluator's responsibilities (resolve + evaluate + log) are
  broader than the BPMN Interpreter's (evaluate only) — an intentional,
  standing asymmetry between the BPMN and DMN modules.
- The DMN Evaluator can't be unit-tested against a parsed decision model
  in isolation without also exercising Model Registry resolution and
  Decision Log persistence, unlike the BPMN Interpreter's `drive()`,
  which is pure. Accepted because decision evaluation isn't invoked
  mid-transition today — there's no caller for a pure
  evaluate-against-an-already-resolved-model step yet.
- If a future scenario needs DMN evaluation triggered from inside a
  running BPMN/CMMN transition (e.g., a business rule task), that will
  most likely justify extracting a pure evaluation method alongside a
  Core-level Decision Manager mirroring Revision Manager. Revisit this
  ADR then, instead of reshaping the DMN Evaluator ad hoc under
  implementation pressure.
- Keeps the DMN module's shape a literal match to the diagrammed
  sequence, rather than speculatively building for a BPMN-triggers-DMN
  use case that isn't in scope yet.