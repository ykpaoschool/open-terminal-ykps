#!/bin/sh
# Smoke test for the image's pre-installed toolchain.
#
# Runs *inside* the container (as the default user), on every platform CI
# publishes, so a dependency that is installed but unusable cannot ship.
# Invoke from the host:
#
#   docker run --rm --entrypoint sh \
#     -v "$PWD/scripts:/scripts:ro" IMAGE /scripts/smoke-test.sh
#
# Keep the npm checks in sync with the Dockerfile's global npm packages.
set -eu

# apt packages: the PPTX -> PDF -> text/image acceptance path.
for bin in libreoffice soffice pdftoppm pdftotext pdfinfo; do
  command -v "$bin" >/dev/null 2>&1 || {
    echo "missing binary: $bin" >&2
    exit 1
  }
done

# pip packages.
python3 -c "import defusedxml, PIL, markitdown"

# Global npm packages must resolve from any working directory, and for both
# module systems: `NODE_PATH` would only cover `require()`, so ESM is checked
# explicitly (see the Dockerfile for why the image links /node_modules).
cd /tmp
node -e "require('pptxgenjs')"
node --input-type=module -e "import 'pptxgenjs'"

echo "smoke OK"
