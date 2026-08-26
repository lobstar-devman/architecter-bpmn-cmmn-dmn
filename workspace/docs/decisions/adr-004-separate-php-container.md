# ADR-004: Separate PHP/Laravel container from the docs-toolkit container

**Status:** accepted
**Date:** 2026-08-25

## Context

Implementation of the BPM Engine package (see
[Section 5](../arc42/05-building-block-view.md)) needs PHP 8.4, Composer,
and PostgreSQL. The existing `architecting-toolkit` container (see
[Sources of Truth](../sources-of-truth/index.md)) provides Node.js/Java
tooling for rendering documentation diagrams (Structurizr CLI, Mermaid
CLI, bpmn-to-image, Redoc) and has no PHP runtime at all.

## Decision

Run the PHP/Laravel implementation (the `package` Testbench harness and
the `demo-app` host application) in their own containers, defined in a
separate `docker-compose.yml` under `implementation/` (grouping the
package, the demo host app, and their compose file together, apart from
the docs sources), rather than adding PHP to the docs-toolkit image or
building one combined container.

## Consequences

- Two independent tool chains (docs rendering vs. PHP/Laravel runtime)
  stay cleanly separated — neither image carries dependencies it doesn't
  need.
- ~~The `package` container's whole-project bind mount gives implementers
  direct access to the arc42 docs, Structurizr DSL, and domain model
  while writing code that has to match them~~ — **superseded by
  [ADR-007](adr-007-implementation-self-contained.md):** the `package`
  container no longer bind-mounts the whole project; docs are read via
  the docs-toolkit's served site instead, and `implementation/` is kept
  self-contained and relocatable to its own repository.
- Two `docker-compose.yml` files and two sets of `Dockerfile`s to
  maintain instead of one; contributors need to know which one is for
  docs and which is for implementation.
