# ADR-002: Custom interpreter over embedding an existing engine

**Status:** accepted
**Date:** 2026-08-25

## Context

BPMN, CMMN, and DMN models need to be interpreted/evaluated at runtime.
Mature engines exist for these standards (e.g. Camunda, Flowable), but
they run on the JVM. This system ships as a Laravel package
([ADR-001](adr-001-drop-in-laravel-model.md)) and targets the Simplicity
quality goal — see [Section 1](../arc42/01-introduction-and-goals.md).

## Decision

Build a custom interpreter in PHP that parses BPMN 2.0, CMMN 1.1, and DMN
XML directly into an internal representation and interprets/evaluates it,
rather than embedding or shelling out to an existing JVM- or JS-based
engine. See [Solution Strategy](../arc42/04-solution-strategy.md) and
[Building Block View](../arc42/05-building-block-view.md) for the
resulting module structure (Parser + Interpreter/Evaluator per standard).

## Consequences

- No external runtime dependency (JVM, Node) to install/operate alongside
  the host Laravel app — keeps deployment simple, in line with ADR-001.
- The engine only supports the subset of each OMG standard that gets
  implemented, rather than inheriting full coverage from a mature
  existing engine; correctness against the OMG specs (the Correctness
  quality goal) is entirely this project's responsibility.
- More implementation effort up front than integrating an existing
  engine.
