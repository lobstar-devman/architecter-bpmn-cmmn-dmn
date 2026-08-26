# Develops/tests the BPM Engine package via Orchestra Testbench.
# Separate from the docs-toolkit image (see ADR-004) — this one is PHP
# runtime only, the docs-toolkit is Node/Java diagram-rendering tooling.

FROM php:8.4-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libpq-dev \
        libonig-dev \
        libzip-dev \
    && docker-php-ext-install pdo_pgsql mbstring zip bcmath \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# The whole project (not just this directory) is bind-mounted at
# /workspace at `docker compose` runtime — see ../docker-compose.yml —
# so docs/, architecture/, and data-model/ are readable from inside this
# container. See README.md for why.
WORKDIR /workspace/implementation/package
