# ADR-012: BPMN vocabulary hashing — computed on demand, flat, BPMN-only

**Status:** accepted
**Date:** 2026-09-04

## Context

`model_revisions.xml` stores raw BPMN/CMMN/DMN XML. The XML's own `id`
attributes — and, for BPMN, sequence-flow `name` attributes, matched by
`BpmnInterpreter::selectFlow()` — function as a de facto vocabulary that
host-app code hard-codes against: comparing `Instance::current_state` to
a literal node id, or driving a transition with a literal event name
expected to match a flow's `name`.

Nothing today detects when a new Model Revision
(`Core\ModelRegistry::store()`) silently removes or renames an id/flow
name a host app still depends on. The only signal is a runtime
exception from `BpmnInterpreter`/`BpmnProcessModel` once an `Instance`
actually reaches the changed state — this is exactly the kind of drift
the Correctness goal ([Section 1](../arc42/01-introduction-and-goals.md))
argues for catching earlier and more explicitly, the same reasoning
behind every "fail loudly, not silently" decision already recorded
([ADR-008](adr-008-dmn-decision-table-scope.md)'s hit-policy/output-name
checks, [ADR-011](adr-011-bpmn-process-scope.md)'s single-start-event
enforcement).

`BpmnNode`/`BpmnFlow` are today's parsed-representation internals —
public and readonly, but never documented as a stable contract;
[ADR-011](adr-011-bpmn-process-scope.md) already notes their shape is
expected to widen as BPMN support grows. A host app comparing against
them directly would break on future parser-shape changes unrelated to
its own vocabulary concerns, and would need to reimplement the
ordering/deduplication logic needed for a stable comparison itself.

`CmmnCaseModel` mirrors `BpmnProcessModel`'s shape
([ADR-010](adr-010-cmmn-case-plan-scope.md)); `DmnDecisionModel` is
already flat with no id-keyed lookup
([ADR-008](adr-008-dmn-decision-table-scope.md)). Neither is addressed
by this decision — extending this concept to CMMN would be additive
later, mirroring [ADR-010](adr-010-cmmn-case-plan-scope.md)'s own
precedent, if a real scenario needs it; DMN would need its own,
differently-shaped decision.

## Decision

A new value object, `Bpmn\BpmnVocabulary` (`nodeIds: list<string>`,
`flowNames: list<string>`), plus a new
`BpmnProcessModel::vocabulary(): BpmnVocabulary` method, expose a
model's stable DSL vocabulary with no new coupling to `BpmnNode`/
`BpmnFlow`:

- `nodeIds` is every key of `BpmnProcessModel::$nodes`.
- `flowNames` is every distinct, non-null `BpmnFlow::$name` — a flat,
  deduplicated set across the whole process, not scoped per source
  node. This is a deliberate precision tradeoff: `BpmnInterpreter`
  actually matches `(sourceNodeId, event)` pairs, so a flow name moving
  from one source node to another while remaining present elsewhere in
  the model goes undetected. Chosen over a richer per-node shape for
  the same Simplicity reasoning as
  [ADR-002](adr-002-custom-interpreter.md)/[ADR-008](adr-008-dmn-decision-table-scope.md)/[ADR-010](adr-010-cmmn-case-plan-scope.md)/[ADR-011](adr-011-bpmn-process-scope.md)
  — the flat set covers the far more common case (a name added,
  removed, or typo'd entirely) at a fraction of the shape/serialization
  complexity.
- Both sorted ascending (`SORT_STRING`) for deterministic ordering,
  independent of parser iteration order.
- `BpmnNode::$name` (display label, never matched against),
  `BpmnNode::$role` (organizational metadata, per
  [ADR-005](adr-005-role-context-not-enforced.md)), `BpmnFlow::$id`,
  and `BpmnNode::$type` (confirmed unused by `BpmnInterpreter` today —
  only outgoing-flow matching drives interpretation) are excluded.

`BpmnVocabulary::hash()` returns a SHA-256 digest, algorithm-prefixed
(`sha256:<hex>`, for forward compatibility if the algorithm ever
changes) of `BpmnVocabulary::toCanonicalJson()` — a deterministic
`json_encode()` of `{"nodeIds": [...], "flowNames": [...]}`.

Unlike `BpmnNode`/`BpmnFlow`, `BpmnVocabulary` is a stable, versioned
public contract a host app may depend on directly.

No new database column or migration. `ModelRegistry::resolve()` already
caches the parsed `BpmnProcessModel` per model_revision id;
`vocabulary()`/`hash()` are computed on demand from that cached object —
cheap, given [ADR-011](adr-011-bpmn-process-scope.md)'s linear,
gateway-free chain shape. A persisted hash-at-`store()`-time was
considered and rejected for now: it needs a migration, a backfill plan
for existing revisions, and its own algorithm-versioning story (a
persisted hash computed under a since-changed vocabulary definition
would be silently wrong). Revisit only if a host app needs to query hash
history across many revisions without resolving/parsing each one — no
such need exists yet.

No change to `Core\ModelRegistry`. `resolve()` already returns
everything needed; a passthrough method there would just be a second
way to call `vocabulary()`/`hash()` on the same cached object —
duplication, not simplification.

Scoped to BPMN only. No Artisan command ships with this decision — the
package's public surface stays PHP-API-only; a host app builds its own
check (e.g. a snapshot/golden-file test comparing `hash()` against a
committed baseline) using whatever CI mechanism it already has. This
package cannot know how a host app wants to store or compare its
expected copy — the same cross-repo isolation reasoning that already
keeps this repo from designing against `demo-app`'s internals applies
here to not over-prescribing its CI shape.

## Consequences

- Detects added, removed, or renamed node ids and sequence-flow names
  between any two resolved model revisions, cheaply and without
  exposing `BpmnNode`/`BpmnFlow`'s internal shape as a host-app
  dependency.
- Does not detect a flow name moving from one source node to another
  while remaining present elsewhere in the model — a known, explicitly
  accepted precision gap (see Decision).
- Does not detect a node changing type (e.g. `task` → `endEvent`) while
  keeping the same id — `BpmnInterpreter` doesn't use type today, so
  there is no corresponding runtime behavior this would protect against
  yet; revisit if that changes.
- CMMN and DMN remain undetected for this kind of drift; extending to
  CMMN is expected to be additive (mirroring onto `CmmnCaseModel`, per
  [ADR-010](adr-010-cmmn-case-plan-scope.md)'s mirroring pattern)
  if/when a real scenario needs it. DMN would need its own,
  differently-shaped decision (its vocabulary is
  `decisionKey`/`inputExpressions`/`outputNames`, not node-id-shaped).
- A host app's committed baseline needs updating whenever it
  deliberately changes vocabulary — the same maintenance cost as any
  golden-file test; this package makes the comparison possible, not
  free.
- Model authors changing a `.bpmn` file's ids or flow names should
  expect this to be a visible, intentional decision from the host app's
  side (a failing baseline comparison), not a silent runtime surprise
  the next time an `Instance` reaches the changed state.
