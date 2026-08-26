# ADR-007: Implementation is self-contained and relocatable; docs are read via the served site, not a bind-mount

**Status:** accepted
**Date:** 2026-08-25

## Context

[ADR-004](adr-004-separate-php-container.md) gave the `package`
container a whole-project bind mount so implementers could read the
arc42 docs, Structurizr DSL, and domain model from inside it. On review,
this was solving a problem that doesn't really exist: a developer reads
documentation in their own editor or browser, not by `cat`-ing files
from inside a shell in the PHP container — and the docs-toolkit already
serves the rendered site over HTTP (`mkdocs serve`, published at
`localhost:8000`). The bind mount also permanently coupled
`implementation/` to living inside this same repo/filesystem, which
conflicts with `package/` being a real, independently-publishable
Composer package (`lobstar/bpm-engine`) that should eventually live in
its own repository.

The served site turns out to be a strict superset of what an
implementer needs, not an approximation of it: both Structurizr and
Mermaid render to SVG, not raster images, so every diagram's component
descriptions, relationship labels, and sequence messages remain real,
selectable, searchable text on the rendered page — nothing is flattened
into pixels. Combined with the hand-authored prose (goals, ADR
reasoning, cross-references), which exists only in the docs and never in
any source-of-truth file, the served site covers everything. The raw
source-of-truth files (`workspace.dsl`, `*.mmd`) are the *authoring*
format — needed by whoever edits the architecture and runs
`scripts/generate-docs.sh` — not by whoever is implementing against the
already-published design. Conflating those two roles is what made the
whole-project bind mount seem necessary in ADR-004.

## Decision

- The `package` container mounts only `./package` (its own directory) —
  no whole-project bind mount.
- Anyone implementing against the design docs reads them the normal way:
  in their editor, or via the docs-toolkit's served site at
  `http://localhost:8000` (run separately — see the docs repo's own
  `docker-compose.yml`) — not from inside the implementation container.
- `implementation/` (the `package` and `demo-app` directories, and their
  `docker-compose.yml`) has zero references outside itself — no relative
  paths, no bind mounts, nothing pointing back into the docs repo — so
  it can be copied out into its own git repository at any time (`cp -r
  implementation/ ~/new-repo && cd ~/new-repo && git init`) with nothing
  to fix up. It stays inside this repo for now purely because it hasn't
  been split out yet, not because it depends on being here.
- This supersedes the whole-project-mount consequence of
  [ADR-004](adr-004-separate-php-container.md) — that ADR's core
  decision (a separate container per concern) stands unchanged; only the
  bind-mount detail changes.

## Consequences

- `implementation/` can be extracted to its own repository (its own git
  history, CI, Packagist release) at any point with a plain copy — no
  path fixes, no compose rewrites.
- Anyone working inside the `package` container's shell no longer has
  filesystem access to the docs — they read the docs where they'd
  naturally already be looking (editor/browser), which was always the
  actual behavior anyway.
- The traceability convention (design docs first, code follows) still
  holds — it's now stated as prose in `package/README.md` pointing at
  the served docs site, rather than at in-container file paths.
