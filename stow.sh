#!/usr/bin/env bash

set -euo pipefail

info()  { echo -e "\e[1;34m[*]\e[0m $*"; }
ok()    { echo -e "\e[1;32m[✓]\e[0m $*"; }
warn()  { echo -e "\e[1;33m[!]\e[0m $*"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$HOME/.dotfiles"

info "Stowing dotfiles (hypr wayle vicinae wezterm zsh local-bin)..."
(cd "$DOTFILES_DIR" && stow hypr wayle vicinae wezterm zsh local-bin swappy)