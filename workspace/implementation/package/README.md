# BPM Engine (package)

The Composer package implementing the BPM Engine design documented in
[../../docs/arc42](../../docs/arc42/01-introduction-and-goals.md).

## Code ↔ docs traceability

The [Building Block View](../../docs/arc42/05-building-block-view.md),
[Runtime View](../../docs/arc42/06-runtime-view.md), and
[domain model](../../docs/arc42/08-crosscutting-concepts.md) are the
design source of truth (per `architecting-agent.md`'s living-system
principle) that this code implements. If implementing something reveals
the design needs to change — a method signature, a new component, a
schema tweak — update the relevant doc/source-of-truth file first (and
re-run `../../scripts/generate-docs.sh`), then adjust the code to match.
Don't let the two silently drift apart.

Inside the `package` container the whole project is mounted at
`/workspace`, so these docs are readable from wherever you're working:
`/workspace/docs`, `/workspace/architecture`, `/workspace/data-model`.

## Status

Every class under `src/` is currently a stub — it establishes the API
surface implied by the docs (method signatures, dependencies between
components) but throws `RuntimeException('Not implemented yet.')`. Real
BPMN/CMMN/DMN parsing and interpretation logic is the next step.

## Commands

Run from the `implementation/` directory (one level above this one,
where `docker-compose.yml` lives):

```
docker compose build package
docker compose run --rm package composer install
docker compose run --rm package vendor/bin/pest
docker compose run --rm package vendor/bin/pint --test
docker compose run --rm package vendor/bin/phpstan analyse
docker compose run --rm package bash   # ad hoc shell, with /workspace/docs etc. readable
```
