# ADR-006: No built-in MCP server — AI-agent access goes through the business domain

**Status:** accepted
**Date:** 2026-08-25

## Context

MCP (Model Context Protocol) servers are becoming a common way to expose
an application's operations to AI agents. It would be possible for the
BPM Engine to ship an out-of-the-box MCP server exposing its generic
primitives — `RevisionManager::transition()`, `::rollback()`,
`DmnEvaluator::evaluate()` — directly as MCP tools. This ADR decides
against that.

## Decision

The BPM Engine does not ship an MCP server, and none of its components
are AI-agent-facing. This extends two earlier decisions to a new
interface type:

- **No service boundary** ([ADR-001](adr-001-drop-in-laravel-model.md)):
  the engine is an in-process, drop-in Laravel Model, not a standalone
  service. An MCP server is itself a service boundary — exactly what
  ADR-001 chose not to build.
- **Wrong vocabulary for AI agents**: `transition()`, `rollback()`, and
  raw event names are generic engine primitives, not business language.
  An AI agent should be offered domain verbs — "ApproveInvoice",
  "EscalateCase" — not engine internals. Only the host application,
  which is the one actually modeling the business domain (per
  [Section 1](../arc42/01-introduction-and-goals.md)), can provide that
  translation.

This is also consistent with
[ADR-005](adr-005-role-context-not-enforced.md): real access control
sits with the host application, exercised before it calls into the
engine. An MCP server bound directly to the engine's primitives would be
a second entry point that could bypass whatever authorization the host
app built in front of `transition()`/`rollback()` — the same problem
ADR-005 already guards against, now for a new kind of caller.

If a host application wants AI-agent access, the recommended shape is:
expose MCP tools named for domain operations (e.g. `ApproveInvoice`,
`EscalateCase`), each of which performs the host's own authorization
check and then calls the corresponding `RevisionManager::transition()`
(or `rollback()`) internally — the engine is used the same way any other
caller uses it, not given a bespoke bypass.

## Consequences

- The engine's public surface stays purely a PHP API + Postgres tables +
  Laravel events (per [Context & Scope](../arc42/03-context-and-scope.md))
  — no new deployment target, no new auth surface to secure, consistent
  with the Simplicity quality goal.
- AI-agent access to any BPM Engine-driven process is only ever as good
  as the host application's own domain modeling and authorization — the
  engine provides no shortcut and no fallback if the host doesn't build
  one.
- Every host application that wants AI-agent access has to build its own
  MCP layer; there's no shared/reusable implementation to adopt.
