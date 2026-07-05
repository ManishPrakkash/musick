<div align="center">
  <img src="./docs/banner.png" alt="Musick Banner" width="100%" style="border-radius: 12px;"/>
  <br><br>
  <p><b>A modern, sleek, and elegant desktop music widget for Linux (Ubuntu, GNOME, Wayland, and X11)</b></p>
</div>

---

## 🎵 Features
- **Universal Support**: Seamlessly parses tracks and cover art from Spotify, YouTube Music (including Web Apps), and native Linux music players.
- **Flawless Design**: Minimalist and beautiful overlay that floats elegantly on your desktop.
- **Adaptive Architecture**: Natively integrates with `wlr-layer-shell` (for Sway/Hyprland) and automatically falls back to perfect bottom-left alignment on standard GNOME Wayland & X11 setups.
- **Instant Sync**: Background cache ensures that album covers and track information change instantly with your media.

## 🚀 Installation

Musick comes with a dead-simple setup script that automatically pulls the necessary dependencies, registers systemd services, and starts the overlay.

Open your terminal and run the following commands:

```bash
# 1. Clone the repository
git clone https://github.com/ManishPrakkash/musick.git
cd musick

# 2. Make the scripts executable
chmod +x setup.sh run.sh uninstall.sh scripts/*.sh

# 3. Run the setup script
./setup.sh
```

That's it! Play some music and watch the magic happen.

## 🧹 Uninstallation

Want to remove it? We ensure a perfectly spotless cleanup.

Open your terminal in the `musick` folder and run:

```bash
# Run the uninstaller
./uninstall.sh
```

This gracefully disables services and cleans up all binaries, configuration folders (`~/.config/musick`), and caches (`~/.cache/musick`), leaving your system pristine.

## 🛠 Advanced / Manual Control
You can also manually manage the widget state using the core `run.sh` script:
- `./run.sh --install`
- `./run.sh --uninstall`
- `./run.sh --status`
- `./run.sh --restart`
