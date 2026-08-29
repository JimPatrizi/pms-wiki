#!/usr/bin/env bash
# Start the MkDocs live-reload dev server for the Perfect Media Server site.
# Uses the virtualenv created by .cursor/install.sh (stable absolute path).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${MKDOCS_VENV:-$HOME/.venvs/pms-wiki}"

# shellcheck disable=SC1091
. "$VENV_DIR/bin/activate"
cd "$REPO_DIR"
exec mkdocs serve -a 0.0.0.0:8000
