#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "linking dotfiles from $DOTFILES"

# Symlink helper: backs up existing file, then links
link() {
  local src="$DOTFILES/$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  backing up $dst -> $dst.backup"
    mv "$dst" "$dst.backup"
  fi
  # -n so re-runs replace a directory symlink instead of nesting inside it
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

# Dotfiles
link ".gitconfig"           "$HOME/.gitconfig"
link ".gitignore_global"    "$HOME/.gitignore_global"
link ".zshrc"               "$HOME/.zshrc"
link ".prettierrc"          "$HOME/.prettierrc"
link ".editorconfig"        "$HOME/.editorconfig"

# App configs
link "mise/config.toml"     "$HOME/.config/mise/config.toml"
link "CLAUDE.md"            "$HOME/.claude/CLAUDE.md"
link "claude-settings.json" "$HOME/.claude/settings.json"
link ".claude/hooks"        "$HOME/.claude/hooks"
link ".claude/commands"     "$HOME/.claude/commands"
link "vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

# Homebrew
if command -v brew &>/dev/null; then
  echo "running brew bundle..."
  brew bundle --file="$DOTFILES/Brewfile"
else
  echo "homebrew not found — install from https://brew.sh first"
fi

echo "done"
