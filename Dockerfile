# Custom Open Terminal image with pre-installed packages.
# Based on the upstream full image which already includes:
# Python, Node.js, Docker CLI, gcc, ffmpeg, data science libs, etc.
#
# The upstream base version is pinned by OPEN_TERMINAL_VERSION, which mirrors
# the repo's source of truth, the UPSTREAM_VERSION file. CI always passes it in
# explicitly; the default below is kept in sync by track-upstream.yml so that a
# plain `docker compose build` reproduces the same image.
#
# Note: upstream tags its images *without* a leading "v" (0.13.0), even though
# its GitHub release tags carry one (v0.13.0). UPSTREAM_VERSION uses the image
# tag form, so it drops straight into the FROM line below.

ARG OPEN_TERMINAL_VERSION=0.14.0
FROM ghcr.io/open-webui/open-terminal:${OPEN_TERMINAL_VERSION}

USER root

# ── Extra apt packages ──────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    libreoffice-core-nogui \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# ── Extra pip packages ──────────────────────────────────────────────
RUN pip install --no-cache-dir \
    defusedxml \
    Pillow \
    "markitdown[pptx]"

# ── Extra npm packages (global) ─────────────────────────────────────
RUN npm install -g \
    pptxgenjs

USER user
