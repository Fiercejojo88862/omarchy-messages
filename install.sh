#!/bin/bash
# omarchy-messages installer — Arch / Omarchy / CachyOS.
# Idempotent: safe to re-run.
set -euo pipefail

REPO_URL="https://github.com/gabrielmeir53/iphonebridge.git"
REPO_TAG="v0.5.0"
SRC_DIR="$HOME/.local/src/iphonebridge"
BIN_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

msg() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

# 1. System packages (Arch names — upstream README uses apt).
# NOTE: bluez-obex (not bluez-obexd) on Arch; ofono is AUR-only (calls are optional).
msg "Installing system packages (pacman)…"
sudo pacman -S --needed --noconfirm \
  bluez bluez-utils bluez-obex \
  python-dbus python-gobject \
  gtk4 libadwaita \
  python-virtualenv \
  wl-clipboard

if pacman -Si ofono >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm ofono
else
  warn "ofono not in official repos (AUR-only) — skipping. Calls need it; see docs/TROUBLESHOOTING.md."
  warn "To add calls later:  yay -S ofono   (or: paru -S ofono)"
fi

sudo systemctl enable --now bluetooth 2>/dev/null || true

# 2. Clone / update upstream at pinned tag
if [ -d "$SRC_DIR/.git" ]; then
  msg "Updating iphonebridge in $SRC_DIR…"
  git -C "$SRC_DIR" fetch --tags origin
  git -C "$SRC_DIR" checkout "$REPO_TAG"
else
  msg "Cloning iphonebridge ($REPO_TAG)…"
  mkdir -p "$(dirname "$SRC_DIR")"
  git clone --branch "$REPO_TAG" --depth 1 "$REPO_URL" "$SRC_DIR"
fi

# 3. Venv with system site packages (PyGObject + dbus come from pacman, never PyPI)
if [ ! -d "$SRC_DIR/.venv" ]; then
  msg "Creating venv…"
  python3 -m venv --system-site-packages "$SRC_DIR/.venv"
fi
msg "Installing iphonebridge into venv…"
"$SRC_DIR/.venv/bin/pip" install --upgrade pip
"$SRC_DIR/.venv/bin/pip" install -e "$SRC_DIR"

# 4. Symlinks + Messages wrapper
mkdir -p "$BIN_DIR"
ln -sf "$SRC_DIR/.venv/bin/iphonebridge" "$BIN_DIR/iphonebridge"
ln -sf "$SRC_DIR/.venv/bin/iphonebridge-ui" "$BIN_DIR/iphonebridge-ui"
install -m 0755 "$SCRIPT_DIR/assets/messages" "$BIN_DIR/messages"

# 5. Desktop entry
mkdir -p "$HOME/.local/share/applications"
install -m 0644 "$SCRIPT_DIR/assets/messages.desktop" "$HOME/.local/share/applications/messages.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# 6. Systemd user service
mkdir -p "$HOME/.config/systemd/user"
install -m 0644 "$SCRIPT_DIR/assets/iphonebridge.service" "$HOME/.config/systemd/user/iphonebridge.service"
systemctl --user daemon-reload
systemctl --user enable iphonebridge 2>/dev/null || true

msg "Done. Next steps:"
echo "  1. Pair your iPhone (Settings > Bluetooth, or bluetoothctl)."
echo "  2. Run:  iphonebridge pair-setup"
echo "  3. Run:  systemctl --user restart iphonebridge"
echo "  4. On iPhone: Bluetooth > (i) > enable Show Message Notifications, Sync Contacts, Show System Notifications."
echo "  5. Launch:  messages   (or: iphonebridge-ui --messages)"
echo ""
warn "Optional: per-app notifications need 'iphonebridge ancs-enable' + forget/re-pair (Intel BT only)."
warn "Optional: calls need 'iphonebridge hfp-enable' (see TROUBLESHOOTING.md)."
