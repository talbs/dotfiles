# Path
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Oh My Zsh (minimal — Warp handles prompt, highlighting, and autosuggestions)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_AUTO_TITLE="true"
plugins=(git macos)
source $ZSH/oh-my-zsh.sh

# Tools
eval "$(mise activate zsh)"
eval "$(atuin init zsh)"

# Editor
export EDITOR='cursor'
export VISUAL='cursor'

# GPG
export GPG_TTY=$(tty)

# Aliases
alias lg='lazygit'
alias ll='ls -lFh'
alias la='ls -lAFh'
alias ff='find . -type f -name'
# pnpm
export PNPM_HOME="/Users/brian/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
