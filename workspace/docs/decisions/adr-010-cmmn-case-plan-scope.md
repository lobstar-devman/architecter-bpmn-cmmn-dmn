# ADR-010: CMMN scope — single linear case plan, sentry-derived transitions, OR'd triggers

**Status:** accepted
**Date:** 2026-08-31

## Context

Implementing `Cmmn\CmmnParser`/`Cmmn\CmmnInterpreter` — explicitly asked
to mirror BPMN's shape and scope (see this repo's own
`AGENT_INSTRUCTIONS.md`) — surfaced the same kind of scope questions
[ADR-008](adr-008-dmn-decision-table-scope.md) settled for DMN. Full
CMMN 1.1 covers stages (plan items containing their own nested plan
items), discretionary items added at runtime by a case worker, if-part
conditions and repetition rules on sentries, milestones and event
listeners as distinct plan item types, and multi-`planItemOnPart`
sentries combined via an explicit `ifPart` expression
(AND/OR/conditional semantics). None of that is needed to mirror the one
worked BPMN scenario (start → task → end, a single linear chain) in CMMN
terms, and building it up front runs against the Simplicity goal, the
same reasoning [ADR-002](adr-002-custom-interpreter.md) gave for
BPMN/DMN.

A CMMN-specific question [ADR-008](adr-008-dmn-decision-table-scope.md)
didn't have to answer: CMMN has no `sequenceFlow` element — nothing in
the spec directly plays that role.
The closest real mechanism is a plan item's `entryCriterion`, which
references a `sentry`, which in turn holds one or more
`planItemOnPart` elements naming a source plan item and the
`standardEvent` (e.g. `complete`) that satisfies it. This ADR records
that `entryCriterion`/`sentry`/`planItemOnPart` — not an invented,
non-spec construct — is what plays BPMN's sequence-flow role here.

## Decision

`CmmnParser`/`CmmnInterpreter` support a defined subset, not the full
CMMN 1.1 spec:

- A single, flat `casePlanModel` — `planItem` elements are not nested
  inside stages or other plan items, and there is no discretionary
  item support (nothing added to the plan at runtime).
- Exactly one designated start: the plan item with no `entryCriterion`.
  If none or more than one qualifies as a start candidate under this
  rule, `CmmnParser` throws rather than guessing.
- Transitions are derived from each plan item's `entryCriterion` →
  `sentry` → `planItemOnPart` (`sourceRef` + `standardEvent`) —
  CMMN's actual spec mechanism, reused as-is rather than modeled on an
  invented, BPMN-shaped construct.
- A sentry's multiple `planItemOnPart` entries (if present) are each
  treated as an independent, OR'd alternative trigger — any one
  satisfies entry. `ifPart` conditions and AND-combination semantics
  are not evaluated.
- Case Role capture, per
  [ADR-005](adr-005-role-context-not-enforced.md): a plan item's role is
  read from its referenced task definition's (`humanTask`, etc.)
  `performerRef` attribute, resolved against `caseRoles/role` —
  organizational metadata only, exposed via `TransitionRoleContext`
  exactly as BPMN Lanes are, never enforced.
- `CmmnInterpreter::drive()` reuses `BpmnInterpreter::drive()`'s exact
  matching algorithm (an event matching a transition's `standardEvent`
  first, an unnamed/no-`standardEvent` transition as fallback) against
  the CMMN-shaped model instead of the BPMN-shaped one.

## Consequences

- Real-world `.cmmn` files using stages, discretionary items, milestones
  as distinct trigger sources, or `ifPart`-conditioned/AND-combined
  sentries will fail loudly (an exception naming what wasn't
  understood) rather than silently producing a wrong plan-item
  ordering — consistent with the Correctness goal
  ([Section 1](../arc42/01-introduction-and-goals.md)) and the same
  stance [ADR-008](adr-008-dmn-decision-table-scope.md) took for DMN.
- CMMN's own case-management character — plan items generally becoming
  available independently rather than in one linear, BPMN-like chain —
  is deliberately not modeled yet. What's implemented is closer to "CMMN
  syntax driving a BPMN-shaped linear interpreter" than general case
  management; that gap is real and intentional, not an oversight.
- The parsed representation (`CmmnCaseModel`/`CmmnNode`/
  `CmmnTransition`) mirrors `BpmnProcessModel`'s shape closely enough
  that `RevisionManager` dispatches to either interpreter through the
  same three small helpers (`drive()`, `roleFor()`, `startNodeIdOf()`)
  — widening CMMN support (stages, discretionary items, non-OR sentry
  combinations) is expected to extend this shape, not replace it.
- Model authors need to know a `.cmmn` file must reduce to one flat,
  linear plan reachable from a single start candidate; this becomes a
  real constraint on CMMN-authoring guidance/tooling, same as
  [ADR-008](adr-008-dmn-decision-table-scope.md)'s DMN constraint.
