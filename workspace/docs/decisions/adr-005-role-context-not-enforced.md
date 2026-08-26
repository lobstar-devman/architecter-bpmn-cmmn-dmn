# ADR-005: Role/lane data is exposed via an event, not enforced

**Status:** accepted
**Date:** 2026-08-25

## Context

BPMN Pools/Lanes and CMMN's own Case Role concept model organizational
accountability — which role, department, or participant is responsible
for an activity — not technical access control. Neither OMG standard
defines IAM semantics (authentication, permission checks, allow/deny
decisions). The BPM Engine is scoped to match the OMG specs as written
([ADR-002](adr-002-custom-interpreter.md)), so it has no native concept
of a permission gate either — but that leaves open what, if anything, it
should do with the role/lane data the specs already give it.

## Decision

The engine treats Lane/Pool/Case Role assignments as **role-context
metadata for a real extensibility point**, not an enforcement mechanism:

- `BpmnParser`/`CmmnParser` (see
  [Building Block View](../arc42/05-building-block-view.md)) capture,
  for each activity, the lane/role (BPMN) or case role (CMMN) it's
  assigned to, as part of the parsed internal representation.
- `RevisionManager` dispatches a `TransitionRoleContext` Laravel event
  immediately **after** `EventStore::append()` durably records the
  transition — not before execution. The event carries the instance, the
  triggering event, and the resolved role.
- The event is purely observational: the engine never inspects listener
  results, and — because it only fires once the transition is already
  recorded — a listener cannot abort or gate it, by construction, not
  just by convention.
- This applies uniformly to BPMN Lanes/Pools and CMMN Case Roles, one
  policy for "role modeling elements" across both standards. DMN has no
  equivalent construct and is untouched by this decision.
- No new [Building Block View](../arc42/05-building-block-view.md)
  component: this lives inside the existing Parser/Interpreter and
  Revision Manager components, not a separate "AuthorizationGate".

Real access control — authenticating the actor, checking their
permissions against the reported role, deciding whether to allow the
call at all — is entirely the host application's responsibility,
exercised however it likes (a listener, middleware in front of whatever
triggers the transition, an async check, etc.), and must run *before*
calling `RevisionManager::transition()`/`rollback()` if it needs to
actually stop anything.

## Consequences

- The engine never becomes a second, competing IAM system, and stays
  correct against the OMG specs as literally defined — serves the
  Simplicity and Correctness quality goals
  ([Section 1](../arc42/01-introduction-and-goals.md)).
- A host app that needs a hard guarantee that no transition runs without
  an authorization check must enforce that itself before calling
  `transition()`/`rollback()` — the engine gives it the role/lane
  context it needs to do so, but cannot gate anything itself, since
  `TransitionRoleContext` only fires after the fact.
- The event's payload becomes a stability contract: a breaking change to
  it is a breaking change for every host app relying on it for auditing.
