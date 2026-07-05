#!/usr/bin/env bash
set -euo pipefail
ACTION="${1:-status}"
case "$ACTION" in
  status) systemctl --user --no-pager --full status musick-cache.timer musick-overlay.service || true ;;
  restart) systemctl --user daemon-reload; systemctl --user restart musick-cache.timer musick-overlay.service; systemctl --user --no-pager --full status musick-cache.timer musick-overlay.service || true ;;
  *) exit 1 ;;
esac
