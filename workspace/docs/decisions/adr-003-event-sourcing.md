# ADR-003: Event sourcing for state transitions and revisions

**Status:** accepted
**Date:** 2026-08-25

## Context

The system must support revisioning of OMG models and let active
entities transition or roll back between revisions
(see [Section 1](../arc42/01-introduction-and-goals.md)), while also
meeting the Auditable quality goal — the system should be independently
verifiable.

## Decision

Persist every state transition as an immutable event in an Event Store,
rather than only persisting current-state snapshots. Current state and
revision history — including rollback to a prior model revision — are
derived from the event log by the Revision Manager. See
[Solution Strategy](../arc42/04-solution-strategy.md),
[Building Block View](../arc42/05-building-block-view.md), and the
[Cross-cutting domain model](../arc42/08-crosscutting-concepts.md)
(`Instance`, `Transition Event`).

## Consequences

- Rollback and audit trails come for free from the event log, directly
  serving the Auditable quality goal.
- Reconstructing current state requires replaying (or reading a
  maintained projection of) the event log rather than a single row read
  — adds complexity relative to plain CRUD, weighed against the
  Simplicity quality goal.
- The Event Store's write path is on the critical path for the
  Performance quality goal (10,000 transitions/sec) and must be designed
  accordingly.
