# Open Terminal — YKPS Custom Image

A custom Docker image based on [open-webui/open-terminal](https://github.com/open-webui/open-terminal) with pre-installed packages for YKPS. Published to `ghcr.io/ykpaoschool/open-terminal-ykps`.

## Quick Start

```bash
# Build
docker compose build

# Run (set API key via env or .env file)
docker compose up -d
```

Or with plain Docker:

```bash
docker build -t open-terminal-ykps .
docker run -d --name open-terminal -p 8000:8000 \
  -e OPEN_TERMINAL_API_KEY=your-secret-key \
  open-terminal-ykps
```

## Versioning

This image tracks upstream Open Terminal stable releases. The tracked version lives in [`UPSTREAM_VERSION`](UPSTREAM_VERSION) (e.g. `0.13.0`), and every image tag mirrors the upstream **image** tag — so `UPSTREAM_VERSION=0.13.0` produces `ghcr.io/ykpaoschool/open-terminal-ykps:0.13.0`. `latest` always points at the tracked stable version, never at upstream's dev (`main`) branch.

> Mind the `v`: upstream's GitHub release tags carry one (`v0.13.0`) but its image tags do not (`0.13.0`). `UPSTREAM_VERSION` stores the image tag form, so it drops straight into the Dockerfile's `FROM`.

## How upgrades work

- A daily workflow polls upstream for new stable releases and opens a PR bumping `UPSTREAM_VERSION` (and the Dockerfile's arg default).
- Merging that PR triggers CI, which builds and publishes the new version (and moves `latest`).
- Dependency changes rebuild the *current* tracked version in place — they don't advance the Open Terminal baseline.

See [CLAUDE.md](CLAUDE.md) for the full workflow details.

## Adding Packages

Edit `Dockerfile` and add packages to the appropriate section:

```dockerfile
# apt packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    vim nano jq \
    && rm -rf /var/lib/apt/lists/*

# pip packages
RUN pip install --no-cache-dir \
    httpx polars

# npm packages (global)
RUN npm install -g \
    typescript tsx
```

Rebuild after changes: `docker compose build`

## Building a Different Base Version

The base version comes from `UPSTREAM_VERSION` via the Dockerfile's `OPEN_TERMINAL_VERSION` arg. To build something else locally (e.g. an older version for rollback testing):

```bash
docker compose build --build-arg OPEN_TERMINAL_VERSION=0.12.5
```

To change the tracked version permanently, edit `UPSTREAM_VERSION` — or just merge the automated bump PR. Don't hand-edit the Dockerfile's arg default; `track-upstream.yml` keeps it in sync.

## License

MIT
