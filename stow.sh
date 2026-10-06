#!/usr/bin/env bash
 
set -euo pipefail
 
info()  { echo -e "\e[1;34m[*]\e[0m $*"; }
ok()    { echo -e "\e[1;32m[✓]\e[0m $*"; }
warn()  { echo -e "\e[1;33m[!]\e[0m $*"; }
 
DOTFILES_DIR="$HOME/.dotfiles"
 
# package : target
PACKAGES=(
  "hypr:$HOME/.config/hypr"
  "swappy:$HOME/.config/swappy"
  "wayle:$HOME/.config/wayle"
  "vicinae:$HOME/.config/vicinae"
  "starship:$HOME/.config"
  "wezterm:$HOME/.config/wezterm"
  "bin:$HOME/.local/bin"
  "vicinae-themes:$HOME/.local/share/vicinae/themes"
  "zsh:$HOME"
)
 
# Hyprland generates its own hyprland.lua, which blocks the symlink.
# Move it aside if it's a real file; leave it alone if it's already a symlink.
HYPR_LUA="$HOME/.config/hypr/hyprland.lua"
if [[ -f "$HYPR_LUA" && ! -L "$HYPR_LUA" ]]; then
  warn "Moving generated hyprland.lua aside (hyprland.lua.bak)"
  mv -f "$HYPR_LUA" "$HYPR_LUA.bak"
fi
 
info "Stowing dotfiles from $DOTFILES_DIR..."
for entry in "${PACKAGES[@]}"; do
  IFS=: read -r pkg target <<< "$entry"
  mkdir -p "$target"
  stow -d "$DOTFILES_DIR" -t "$target" "$pkg"
  ok "$pkg -> $target"
done