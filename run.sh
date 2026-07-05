#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="install"
case "${1:-}" in
  --doctor) MODE="doctor" ;;
  --status) MODE="status" ;;
  --restart) MODE="restart" ;;
  --uninstall) MODE="uninstall" ;;
esac
export MUSICK_PROJECT_DIR="$PROJECT_DIR"
case "$MODE" in
  install) bash "$PROJECT_DIR/scripts/install.sh" ;;
  doctor) bash "$PROJECT_DIR/scripts/doctor.sh" ;;
  status) bash "$PROJECT_DIR/scripts/service-control.sh" status ;;
  restart) bash "$PROJECT_DIR/scripts/service-control.sh" restart ;;
  uninstall) bash "$PROJECT_DIR/scripts/uninstall.sh" ;;
esac
