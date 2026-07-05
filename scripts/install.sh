#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${MUSICK_PROJECT_DIR:?}"
source "$PROJECT_DIR/scripts/helpers.sh"
INSTALL_DIR="$HOME/.local/share/musick"
CONFIG_DIR="$HOME/.config/musick"
SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$SYSTEMD_DIR" "$HOME/.cache/musick"

NEEDED=()
have playerctl || NEEDED+=("playerctl")
have curl || NEEDED+=("curl")
dpkg -l | grep -q "^ii.*webp-pixbuf-loader" 2>/dev/null || NEEDED+=("webp-pixbuf-loader")
python3 - <<'PY' >/dev/null 2>&1 || NEEDED+=("python3-gi" "gir1.2-gtk-3.0" "gir1.2-gtklayershell-0.1")
import gi
gi.require_version("Gtk","3.0")
gi.require_version("GtkLayerShell","0.1")
PY

if ((${#NEEDED[@]})); then
  sudo apt update
  sudo apt install -y "${NEEDED[@]}"
fi

install -m 755 "$PROJECT_DIR/scripts/media-cache.sh" "$INSTALL_DIR/media-cache.sh"
install -m 755 "$PROJECT_DIR/overlay/musick_overlay.py" "$INSTALL_DIR/musick_overlay.py"
[[ -f "$CONFIG_DIR/musick.conf" ]] || cp "$PROJECT_DIR/config/musick.conf" "$CONFIG_DIR/musick.conf"

sed "s|@@INSTALL_DIR@@|$INSTALL_DIR|g" "$PROJECT_DIR/systemd/musick-cache.service" > "$SYSTEMD_DIR/musick-cache.service"
cp "$PROJECT_DIR/systemd/musick-cache.timer" "$SYSTEMD_DIR/musick-cache.timer"
sed "s|@@INSTALL_DIR@@|$INSTALL_DIR|g" "$PROJECT_DIR/systemd/musick-overlay.service" > "$SYSTEMD_DIR/musick-overlay.service"

systemctl --user daemon-reload
systemctl --user enable --now musick-cache.timer
systemctl --user enable --now musick-overlay.service
green "Musick installed."
