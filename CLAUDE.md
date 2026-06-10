# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YKPS custom Docker image based on [open-webui/open-terminal](https://github.com/open-webui/open-terminal). This repo only contains the customization layer — a Dockerfile that adds pre-installed packages on top of the upstream `ghcr.io/open-webui/open-terminal:latest` image, so users on Open WebUI don't need to install packages at runtime.

## Commands

```bash
# Build image
docker compose build

# Run (set API key via env or .env file)
docker compose up -d

# Rebuild after adding packages
docker compose build --no-cache

# Build without compose
docker build -t open-terminal-ykps .
```

## Repository Structure

- `Dockerfile` — Customization layer. `FROM ghcr.io/open-webui/open-terminal:latest`, installs extra apt/pip/npm packages as `USER root`, then switches back to `USER user`.
- `docker-compose.yml` — Build and run config. API key via `OPEN_TERMINAL_API_KEY` env var.
- `.github/workflows/docker.yml` — CI: builds multi-arch (amd64 + arm64) image, pushes to `ghcr.io/ykpaoschool/open-terminal-ykps`.

## Key Conventions

- **Base image**: `ghcr.io/open-webui/open-terminal:latest`. Pin to a specific tag (e.g. `:0.11.34`) for reproducible builds.
- **User switching**: Always install packages as `USER root`, then switch back to `USER user` at the end.
- **Upstream env vars**: All prefixed with `OPEN_TERMINAL_` (e.g., `OPEN_TERMINAL_API_KEY`, `OPEN_TERMINAL_MULTI_USER`). Full list in [upstream README](https://github.com/open-webui/open-terminal).
