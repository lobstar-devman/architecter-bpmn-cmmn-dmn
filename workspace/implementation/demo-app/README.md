# Demo host app

A minimal, real Laravel application used to exercise the BPM Engine
package end-to-end (not just through Orchestra Testbench), matching the
"Consuming Laravel Application" in Context & Scope (arc42 Section 3) and
the web/app-server + queue-worker roles in the Deployment View
(Section 7) — see the docs-toolkit's served site
(`http://localhost:8000`) for both.

This directory is intentionally empty except for this README and the
`Dockerfile` — a full Laravel skeleton is fetched via Composer, not
hand-authored.

## One-time bootstrap

```
docker compose run --rm demo-app composer create-project laravel/laravel . --prefer-dist
```

Then add the package as a local path dependency. In the generated
`composer.json`, add:

```json
"repositories": [
    { "type": "path", "url": "../package" }
]
```

(Inside the container the package is bind-mounted at `/package`, a
sibling of `/app` — see `../docker-compose.yml` — so the relative path
`../package` resolves correctly.)

Then:

```
docker compose run --rm demo-app composer require lobstar/bpm-engine:@dev
docker compose run --rm demo-app php artisan migrate
docker compose up demo-app demo-app-worker postgres
```

`demo-app` serves the app (`php artisan serve`); `demo-app-worker` runs
`php artisan queue:work`, consuming batched transition jobs dispatched by
`QueueDispatcher` (see Runtime View, arc42 Section 6).
