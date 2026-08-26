# Decisions (ADRs)

Architecture Decision Records for this project. Each significant decision
identified during an architecture step (see
[Solution Strategy](../arc42/04-solution-strategy.md) and
[Building Block View](../arc42/05-building-block-view.md)) is recorded
here, hand-authored in prose (ADRs are a narrative artifact, not a
diagrammable source of truth).

## Log

| # | Title | Status | Date |
|---|---|---|---|
| [ADR-001](adr-001-drop-in-laravel-model.md) | Ship as a drop-in Laravel Model | accepted | 2026-08-25 |
| [ADR-002](adr-002-custom-interpreter.md) | Custom interpreter over embedding an existing engine | accepted | 2026-08-25 |
| [ADR-003](adr-003-event-sourcing.md) | Event sourcing for state transitions and revisions | accepted | 2026-08-25 |
| [ADR-004](adr-004-separate-php-container.md) | Separate PHP/Laravel container from the docs-toolkit container | accepted | 2026-08-25 |
| [ADR-005](adr-005-role-context-not-enforced.md) | Role/lane data is exposed via an event, not enforced | accepted | 2026-08-25 |
| [ADR-006](adr-006-no-builtin-mcp-server.md) | No built-in MCP server — AI-agent access goes through the business domain | accepted | 2026-08-25 |
| [ADR-007](adr-007-implementation-self-contained.md) | Implementation is self-contained and relocatable; docs are read via the served site | accepted | 2026-08-25 |

## Template

```markdown
# ADR-NNN: <Title>

**Status:** proposed | accepted | superseded by ADR-NNN
**Date:** YYYY-MM-DD

## Context
What is the issue that we're seeing that motivates this decision?

## Decision
What is the change that we're proposing/doing?

## Consequences
What becomes easier or harder as a result of this change?
```
