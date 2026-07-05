#!/usr/bin/env bash
set -euo pipefail
SYSTEMD_DIR="$HOME/.config/systemd/user"
INSTALL_DIR="$HOME/.local/share/musick"
systemctl --user disable --now musick-overlay.service 2>/dev/null || true
systemctl --user disable --now musick-cache.timer 2>/dev/null || true
systemctl --user disable --now musick-cache.service 2>/dev/null || true
rm -f "$SYSTEMD_DIR/musick-overlay.service" "$SYSTEMD_DIR/musick-cache.timer" "$SYSTEMD_DIR/musick-cache.service"
rm -rf "$INSTALL_DIR"
systemctl --user daemon-reload
echo "Musick uninstalled."
