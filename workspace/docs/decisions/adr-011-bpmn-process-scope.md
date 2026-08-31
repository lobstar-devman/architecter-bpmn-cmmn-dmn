# ADR-011: BPMN scope — start/task/end only, unconditional linear sequence flow

**Status:** accepted
**Date:** 2026-08-31

## Context

`Cmmn\CmmnParser`/`Cmmn\CmmnInterpreter`
([ADR-010](adr-010-cmmn-case-plan-scope.md)) and
`Dmn\DmnParser`/`Dmn\DmnEvaluator`
([ADR-008](adr-008-dmn-decision-table-scope.md)) each record the
specific, partial subset of their OMG standard this engine supports,
both citing BPMN as the shape they mirror. But
`Bpmn\BpmnParser`/`Bpmn\BpmnInterpreter` — implemented first, and the
thing the other two are mirroring — never had its own equivalent record.
[ADR-002](adr-002-custom-interpreter.md) documents the general
build-vs-buy decision (a custom interpreter, not an embedded engine) and
notes as a general consequence that "the engine only supports the subset
of each OMG standard that gets implemented," but names no specifics for
BPMN. That's a real omission: a reader sees DMN and CMMN's scope stated
explicitly and could reasonably assume BPMN, mentioned nowhere as
partial, is more complete than it is. It isn't — this ADR states BPMN's
scope the same way [ADR-008](adr-008-dmn-decision-table-scope.md) and
[ADR-010](adr-010-cmmn-case-plan-scope.md) state DMN's and CMMN's, per
[ADR-002](adr-002-custom-interpreter.md)'s same Simplicity-goal
reasoning, kept as its own document rather than folded into ADR-002 for
the same one-decision-per-ADR reasons
[ADR-008](adr-008-dmn-decision-table-scope.md)/[ADR-010](adr-010-cmmn-case-plan-scope.md)
were.

## Decision

`BpmnParser`/`BpmnInterpreter` support a defined subset, not the full
BPMN 2.0 spec:

- Three flow-node types: `startEvent`, a task family (`task`,
  `userTask`, `serviceTask`, `manualTask`, `scriptTask`,
  `businessRuleTask`, `sendTask`, `receiveTask` — all captured
  uniformly as a generic `task` node, with no type-specific behavior),
  and `endEvent`. No gateways (exclusive, parallel, inclusive, complex,
  or event-based) — no branching or merging logic. No subprocesses
  (embedded, call activity, event subprocess, or transaction), no
  boundary events, no intermediate throw/catch events (timer, message,
  signal, error, escalation, compensation), and no multi-instance
  markers.
- Sequence flows carry an optional `name`, matched against the
  triggering event by exact string equality; an unnamed flow is the
  fallback when no name matches (or none of a node's flows are named at
  all). `conditionExpression` is never read or evaluated, and BPMN's own
  `default` sequence-flow attribute is ignored — "unnamed" is standing
  in for "default," not implementing it.
- Exactly one `startEvent` is required; `BpmnParser` throws if it finds
  zero or more than one, rather than silently picking whichever the XML
  query happens to return first. See Consequences — drafting this ADR
  is what surfaced that `BpmnParser` originally didn't enforce this
  (nor, it turned out, did `CmmnParser`/`DmnParser` on the
  more-than-one case), so this rule was made uniform across all three
  parsers as part of writing this ADR down, not asserted after the fact
  about pre-existing behavior.
- Lane/Pool role capture, per
  [ADR-005](adr-005-role-context-not-enforced.md): reads
  `<lane>`/`<flowNodeRef>` only, assuming a single Pool. No multi-pool
  collaboration diagrams, participants, or message flows between pools.

## Consequences

- Real-world `.bpmn` files using gateways, subprocesses, boundary or
  intermediate events, or conditional sequence flows fail loudly (an
  exception naming what wasn't understood, from the same "no matching
  outgoing flow" or "unknown node" checks already in
  `BpmnInterpreter`) rather than silently producing a wrong path —
  consistent with the Correctness goal
  ([Section 1](../arc42/01-introduction-and-goals.md)) and the stance
  [ADR-008](adr-008-dmn-decision-table-scope.md)/[ADR-010](adr-010-cmmn-case-plan-scope.md)
  already took for DMN/CMMN.
- Writing this ADR surfaced that none of the three parsers actually
  failed closed on an ambiguous (as opposed to missing) single entry
  point: each threw on zero candidates but silently took the first on
  more than one. That's fixed uniformly — `BpmnParser`, `CmmnParser`,
  and `DmnParser` all now throw on zero *or* more than one — rather
  than leaving BPMN as a known gap and CMMN/DMN as an unexamined
  assumption. Recorded here so the fix has a paper trail distinct from
  ADR-008's/ADR-010's original (inaccurate, at the time) claim that
  CMMN/DMN already enforced this.
- Model authors need to know a `.bpmn` file must reduce to one linear,
  gateway-free chain from a single start event; this becomes a real
  constraint on BPMN-authoring guidance/tooling, same as
  [ADR-008](adr-008-dmn-decision-table-scope.md)'s DMN constraint and
  [ADR-010](adr-010-cmmn-case-plan-scope.md)'s CMMN constraint.
- The parsed representation (`BpmnProcessModel`/`BpmnNode`/`BpmnFlow`)
  is what `CmmnCaseModel`/`CmmnNode`/`CmmnTransition`
  ([ADR-010](adr-010-cmmn-case-plan-scope.md)) was deliberately shaped
  to mirror; widening BPMN support (gateways, subprocesses, conditional
  flows) is expected to need a richer shape than today's linear chain,
  which would in turn be the natural trigger to revisit CMMN's shape
  too.
