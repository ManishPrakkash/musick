#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Auto-fix permissions in case the user downloaded a zip or skipped the chmod step
chmod +x "$PROJECT_DIR/run.sh" "$PROJECT_DIR/setup.sh" "$PROJECT_DIR/uninstall.sh" 2>/dev/null || true
if [ -d "$PROJECT_DIR/scripts" ]; then
  chmod +x "$PROJECT_DIR/scripts/"*.sh 2>/dev/null || true
fi

bash "$PROJECT_DIR/run.sh" --install
