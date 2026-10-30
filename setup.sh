#!/usr/bin/env bash
#
#
# Optional extras (auto-detected if present next to this script):
#   pkglist.txt   - extra official-repo packages, one per line
#   aurpacks.txt  - extra AUR packages, one per line

set -euo pipefail

# ================================================================
# Helpers
# ================================================================
info()  { echo -e "\e[1;34m[*]\e[0m $*"; }
ok()    { echo -e "\e[1;32m[✓]\e[0m $*"; }
warn()  { echo -e "\e[1;33m[!]\e[0m $*"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ================================================================
# 1. Full system update
# ================================================================
info "Syncing and updating system..."
sudo pacman -Syyu --noconfirm
ok "System up to date."

# ================================================================
# 1. AUR helper
# ================================================================
AUR_HELPER=""
if command -v paru &>/dev/null; then
    AUR_HELPER="paru"
    ok "paru already present."
else
    info "Installing paru (AUR helper)..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru-build
    (cd /tmp/paru-build && makepkg -si --noconfirm)
    rm -rf /tmp/paru-build
    AUR_HELPER="paru"
    ok "paru installed."
fi

# ================================================================
# 2. Optional extra packages from pkglist.txt / aurpacks.txt
#     (drop these next to the script if you keep a running list)
# ================================================================
if [[ -f "$SCRIPT_DIR/pkglist.txt" ]]; then
    info "Installing extra official-repo packages from pkglist.txt..."
    sudo pacman -S --needed - < "$SCRIPT_DIR/pkglist.txt"
    ok "pkglist.txt packages installed."
fi

if [[ -f "$SCRIPT_DIR/aurpacks.txt" ]]; then
    info "Installing extra AUR packages from aurpacks.txt..."
    "$AUR_HELPER" -S --needed - < "$SCRIPT_DIR/aurpacks.txt"
    ok "aurpacks.txt packages installed."
fi

# ================================================================
# 3. Shell — set zsh as default
# ================================================================
if [[ "$SHELL" != *zsh ]]; then
    info "Setting zsh as your default shell (you'll be prompted for your password)..."
    chsh -s "$(command -v zsh)"
    ok "Default shell changed to zsh (takes effect next login)."
else
    ok "zsh already default."
fi

# ================================================================
# 4. Dotfiles — clone
# ================================================================
DOTFILES_DIR="$HOME/.dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
    info "Moving dotfiles folders to $DOTFILES_DIR..."
    mkdir -p "$DOTFILES_DIR"
    shopt -s nullglob
    for dir in */; do
        mv "$dir" "$DOTFILES_DIR/"
    done
    shopt -u nullglob
    ok "Moved folders to $DOTFILES_DIR."
else
    warn "$DOTFILES_DIR already exists, skipping move."
fi

echo
ok "Rebuild complete.