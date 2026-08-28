#!/usr/bin/env bash
# Idempotent Cloud Agent setup for the Perfect Media Server MkDocs site.
# Installs the system libraries required by Material for MkDocs' social-card
# (imaging) plugin, then builds a Python virtualenv with the docs toolchain.
set -euo pipefail

cd "$(dirname "$0")/.."

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
if [ ! -x .venv/bin/python ]; then
  python3 -m venv .venv
fi
# shellcheck disable=SC1091
. .venv/bin/activate

pip install --upgrade --quiet pip
pip install --quiet "mkdocs-material[imaging]" mkdocs-minify-plugin -r requirements.txt

# Fail fast if the config can't be loaded / built.
mkdocs build --clean --quiet

echo "pms-wiki environment ready. Run: source .venv/bin/activate && mkdocs serve -a 0.0.0.0:8000"
