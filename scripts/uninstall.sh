#!/usr/bin/env bash
set -euo pipefail
SYSTEMD_DIR="$HOME/.config/systemd/user"
INSTALL_DIR="$HOME/.local/share/musick"
CONFIG_DIR="$HOME/.config/musick"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/musick"

systemctl --user disable --now musick-overlay.service 2>/dev/null || true
systemctl --user disable --now musick-cache.timer 2>/dev/null || true
systemctl --user disable --now musick-cache.service 2>/dev/null || true

rm -f "$SYSTEMD_DIR/musick-overlay.service" "$SYSTEMD_DIR/musick-cache.timer" "$SYSTEMD_DIR/musick-cache.service"
rm -rf "$INSTALL_DIR"
rm -rf "$CONFIG_DIR"
rm -rf "$CACHE_DIR"

systemctl --user daemon-reload
echo "Musick perfectly uninstalled. All configurations and caches removed."
