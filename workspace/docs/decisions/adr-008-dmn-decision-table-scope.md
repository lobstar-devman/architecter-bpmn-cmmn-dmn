# ADR-008: DMN scope — single decision table, FIRST hit policy, minimal FEEL unary tests

**Status:** accepted
**Date:** 2026-08-31

## Context

Implementing `Dmn\DmnParser`/`Dmn\DmnEvaluator` against the "Evaluate a
DMN decision table" runtime scenario
([Section 6](../arc42/06-runtime-view.md)) and the Decision Log domain
model ([Section 8](../arc42/08-crosscutting-concepts.md)) surfaced scope
questions the design didn't settle: full DMN 1.3 covers multiple
decisions per model wired into a decision requirement graph (DRGs, with
one decision's output feeding another's input), boxed expressions beyond
decision tables, every hit policy (UNIQUE, ANY, PRIORITY, OUTPUT ORDER,
RULE ORDER, and the COLLECT variants), and the full FEEL expression
language for unary tests (ranges, lists, negation, string/date
functions, and more). Building that up front isn't needed to drive the
milestone's runtime scenario and runs against the Simplicity goal,
echoing [ADR-002](adr-002-custom-interpreter.md)'s reasoning for
BPMN/CMMN.

## Decision

`DmnParser`/`DmnEvaluator` support a defined subset, not the full DMN
1.3 spec:

- Exactly one <decisionTable> per DMN XML document — no decision requirement graph, no decision-to-decision dependencies. DmnParser throws if it finds zero or more than one, rather than silently picking one.
- Only the `FIRST` hit policy. `DmnEvaluator` throws, naming the
  unsupported policy, if a decision table declares anything else —
  it never silently mis-evaluates a hit policy it doesn't implement.
- A minimal FEEL unary-test grammar for `inputEntry`: `-` (wildcard/any),
  a single comparison operator (`<`, `<=`, `>`, `>=`) against a numeric
  literal, or an exact literal equality match (string, number, or
  boolean). No ranges (`[1..10]`), lists (`1,2,3`), negation
  (`not(...)`), or other FEEL functions.
- `outputEntry` literals are boolean, numeric, or string values only.

## Consequences

- Real-world DMN files using multiple decisions, a non-FIRST hit policy,
  or richer FEEL expressions fail loudly (a thrown exception naming what
  wasn't understood) rather than silently producing a wrong result —
  consistent with the Correctness goal
  ([Section 1](../arc42/01-introduction-and-goals.md)) preferring
  explicit failure over silent misinterpretation.
- Model authors need to know which subset is supported; this becomes a
  real constraint on what DMN-authoring guidance/tooling should
  validate or warn about before a `.dmn` file reaches this engine.
- The parsed representation (`DmnDecisionModel`/`DmnRule`) models one
  decision table generically enough that widening any of the above
  (more hit policies, a fuller FEEL subset) is expected to be additive
  work on the existing shape, not a redesign. Supporting multiple
  decisions/a DRG is the one item here that would likely need a new
  parsed-representation shape, not just a wider grammar.
