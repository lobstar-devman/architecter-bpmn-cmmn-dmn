# ADR-001: Ship as a drop-in Laravel Model

**Status:** accepted
**Date:** 2026-08-25

## Context

The system needs to hold and drive BPMN, CMMN, and DMN models on behalf
of entities that live in a consuming application's own Domain-Driven
Design Business Layer (see [Section 1](../arc42/01-introduction-and-goals.md)).
The consuming application should not need to run or integrate with a
separate service to get this behavior.

## Decision

Distribute the system as a Composer package that provides a drop-in
Laravel Eloquent Model. Consuming applications install the package and
use its Model classes directly, in-process, rather than calling out to a
standalone API or service (see [Context & Scope](../arc42/03-context-and-scope.md)).

## Consequences

- No network boundary between the engine and the host application —
  simpler integration, but couples the engine's runtime to the host
  app's PHP/Laravel version and process model.
- Deployment has no infrastructure of its own; see
  [Deployment View](../arc42/07-deployment-view.md).
- Throughput scaling (the 10,000 transitions/sec quality goal) must be
  achieved via the host app's own scale-out (e.g. queue workers), not by
  scaling a separate engine service.
