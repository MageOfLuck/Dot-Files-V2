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
# 2. AUR helper
# ================================================================
AUR_HELPER=""
if command -v paru &>/dev/null; then
    AUR_HELPER="paru"
    ok "paru already present."
elif command -v yay &>/dev/null; then
    AUR_HELPER="yay"
    ok "yay already present."
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
# 3. NVIDIA
# ================================================================

if pacman -Q 2>/dev/null | grep -q 'linux-cachyos.*nvidia-open'; then
    info "Detected CachyOS bundled nvidia-open kernel — skipping nvidia-open-dkms."
    sudo pacman -S --needed --noconfirm \
        nvidia-utils \
        lib32-nvidia-utils \
        nvidia-settings
else
    info "No bundled nvidia-open kernel detected — installing DKMS variant."
    sudo pacman -S --needed --noconfirm \
        nvidia-open-dkms \
        nvidia-utils \
        lib32-nvidia-utils \
        nvidia-settings
fi

# ================================================================
# 4. Optional extra packages from pkglist.txt / aurpacks.txt
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
# 5. Shell — set zsh as default
# ================================================================
if [[ "$SHELL" != *zsh ]]; then
    info "Setting zsh as your default shell (you'll be prompted for your password)..."
    chsh -s "$(command -v zsh)"
    ok "Default shell changed to zsh (takes effect next login)."
else
    ok "zsh already default."
fi

# ================================================================
# 6. Baseline .zshrc (only if none exists — won't clobber yours)
# ================================================================
ZSHRC="$HOME/.zshrc"
if [[ ! -f "$ZSHRC" ]]; then
    info "No .zshrc found, writing a baseline one..."
    cat > "$ZSHRC" <<'EOF'
# ---- history ----
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# ---- completion ----
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# ---- plugins (from pacman packages) ----
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- prompt ----
eval "$(starship init zsh)"

# ---- aliases ----
alias ls='eza --icons'
alias ll='eza -l --icons'
alias cat='bat'
alias pacs='pacman -Ss'
alias update='sudo pacman -Syu'
EOF
    ok "Baseline .zshrc written to $ZSHRC"
else
    warn ".zshrc already exists, leaving it untouched. Merge the snippet manually if you want it."
fi

# ================================================================
# 7. Dotfiles — clone and stow
# ================================================================
DOTFILES_DIR="$HOME/.dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
    info "Cloning dotfiles repo..."
    git clone https://github.com/MageOfLuck/Mages-Dot-Files.git "$DOTFILES_DIR"
    ok "Cloned to $DOTFILES_DIR."
else
    warn "$DOTFILES_DIR already exists, skipping clone."
fi

info "Stowing dotfiles (hypr wayle vicinae wezterm zsh local-bin)..."
(cd "$DOTFILES_DIR" && stow hypr wayle vicinae wezterm zsh local-bin)
ok "Dotfiles stowed."

echo
ok "Rebuild complete.