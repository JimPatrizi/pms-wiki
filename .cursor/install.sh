#!/usr/bin/env bash
# Idempotent Cloud Agent setup for the Perfect Media Server MkDocs site.
# Installs the system libraries required by Material for MkDocs' social-card
# (imaging) plugin, then builds a Python virtualenv with the docs toolchain.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# The virtualenv lives outside the repo, at a stable absolute path, so it
# survives the fresh git checkout a prebuilt-environment agent boots into
# (a repo-local .venv would be dropped because it is gitignored).
VENV_DIR="${MKDOCS_VENV:-$HOME/.venvs/pms-wiki}"

# System libraries: cairo/pango/freetype are needed by the "social" and
# "privacy" plugins to rasterize social cards; python3-venv provides ensurepip.
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq --no-install-recommends \
  python3-venv \
  libcairo2 libfreetype6 libffi8 libjpeg-turbo8 libpng16-16t64 \
  libpango-1.0-0 libpangocairo-1.0-0 pngquant

# Python environment. The production Docker image layers these on top of the
# private mkdocs-material-insiders base, so requirements.txt intentionally omits
# mkdocs-material itself; we install the community edition here for local dev.
if [ ! -x "$VENV_DIR/bin/python" ]; then
  python3 -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1091
. "$VENV_DIR/bin/activate"

pip install --upgrade --quiet pip
pip install --quiet "mkdocs-material[imaging]" mkdocs-minify-plugin -r "$REPO_DIR/requirements.txt"

# Fail fast if the config can't be loaded / built.
( cd "$REPO_DIR" && mkdocs build --clean --quiet )

echo "pms-wiki environment ready. Serve with: bash .cursor/serve.sh"
