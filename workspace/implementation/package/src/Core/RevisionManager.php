<?php

namespace Lobstar\BpmEngine\Core;

/**
 * Manages transitions between model revisions for active entities,
 * including rollback. See docs/arc42/06-runtime-view.md.
 */
class RevisionManager
{
    public function __construct(
        protected ModelRegistry $modelRegistry,
        protected EventStore $eventStore,
    ) {
    }

    public function transition(mixed $instance, string $event): mixed
    {
        throw new \RuntimeException('Not implemented yet.');
    }

    public function rollback(mixed $instance, int $targetRevision): mixed
    {
        throw new \RuntimeException('Not implemented yet.');
    }
}
