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

ARG OPEN_TERMINAL_VERSION=0.16.3
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

# Node resolves bare specifiers by walking from the importing file up to the
# filesystem root looking for `node_modules`, but `npm install -g` puts packages
# outside that chain. Linking the global root at `/` makes it part of every walk,
# so globals resolve from any cwd, as any user, for both module systems.
#
# Do not replace this with `ENV NODE_PATH=$(npm root -g)`:
#   - ESM (`import`) ignores NODE_PATH entirely (only `require()` honours it),
#   - sudo strips NODE_PATH via env_reset, which breaks multi-user mode where
#     commands run through `sudo -u`.
# The target is resolved at build time so a base-image Node layout change
# (/usr/lib -> /usr/local/lib, etc.) cannot silently break resolution.
RUN test ! -e /node_modules \
 && ln -s "$(npm root -g)" /node_modules

# Fail the build if a pre-installed global package is not importable. Keep this
# list in sync with the packages above; scripts/smoke-test.sh repeats it against
# the published image in CI.
RUN node -e "require('pptxgenjs')" \
 && node --input-type=module -e "import 'pptxgenjs'"

USER user
