#!/usr/bin/env bash
set -euo pipefail
echo "Session: ${XDG_SESSION_TYPE:-unknown}"
echo "Desktop: ${XDG_CURRENT_DESKTOP:-unknown}"
echo "Hyprland: ${HYPRLAND_INSTANCE_SIGNATURE:-not-detected}"
