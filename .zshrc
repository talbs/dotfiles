# Homebrew — first, so $(brew --prefix) resolves below
eval "$(/opt/homebrew/bin/brew shellenv)"

# Path
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Oh My Zsh — empty theme so Warp keeps drawing its own prompt. It runs compinit
# itself, so there is no separate autoload here. zsh-autosuggestions and
# zsh-syntax-highlighting are Homebrew installs sourced below, not omz plugins,
# and `osx` is the old name for `macos`.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(brew common-aliases docker git github macos node npm web-search yarn)
source "$ZSH/oh-my-zsh.sh"

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

# Aliases
alias lg='lazygit'
alias ll='ls -lFh'
alias la='ls -lAFh'
alias ff='find . -type f -name'
