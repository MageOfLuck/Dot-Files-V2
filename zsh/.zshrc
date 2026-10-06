source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

PROMPT='%F{#80FFF0}%m%f %F{#6E69BC}%~%f %# '

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

eval "$(starship init zsh)"

alias update='sudo pacman -Syu && paru -Sua'

# better completion menu
zstyle ':completion:*' menu select
autoload -Uz compinit && compinit