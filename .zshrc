# Homebrew — first, so $(brew --prefix) resolves below
eval "$(/opt/homebrew/bin/brew shellenv)"

# Path
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Completions
autoload -Uz compinit && compinit

# Runtimes and history — no prompt init, Warp draws its own
eval "$(mise activate zsh)"
eval "$(atuin init zsh)"

# Suggestions, then highlighting — highlighting must load last to wrap the
# widgets the others install. Warp has both built in; these are here for the
# VS Code integrated terminal and anything else that is not Warp.
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Editor
export EDITOR='code'
export VISUAL='code'

# GPG
export GPG_TTY=$(tty)

# Aliases
alias lg='lazygit'
alias ll='ls -lFh'
alias la='ls -lAFh'
alias ff='find . -type f -name'
