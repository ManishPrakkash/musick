#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${MUSICK_PROJECT_DIR:?}"
source "$PROJECT_DIR/scripts/helpers.sh"
echo "=== Musick Doctor ==="
bash "$PROJECT_DIR/scripts/detect_env.sh" || true
for b in playerctl python3 systemctl; do
  if have "$b"; then green "OK $b"; else red "MISS $b"; fi
done
python3 - <<'PY'
try:
 import gi
 gi.require_version("Gtk","3.0")
 gi.require_version("GtkLayerShell","0.1")
 print("OK python GTK stack")
except Exception as e:
 print("MISS GTK stack", e)
PY
playerctl -l 2>/dev/null || true
systemctl --user --no-pager --full status musick-cache.timer musick-overlay.service || true
