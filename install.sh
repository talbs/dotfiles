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

# Signing key pointer — .gitconfig names id_ed25519_signing.pub on every
# machine, so each one symlinks it to its own key. Missing, commits abort with
# "failed to write commit object", which reads like a git bug rather than setup.
if [ ! -e "$HOME/.ssh/id_ed25519_signing.pub" ]; then
  echo "  WARNING: ~/.ssh/id_ed25519_signing.pub is missing — commits will fail to sign"
  echo "           point it at this machine's key:"
  echo "           ln -sfn id_ed25519_<machine> ~/.ssh/id_ed25519_signing"
  echo "           ln -sfn id_ed25519_<machine>.pub ~/.ssh/id_ed25519_signing.pub"
elif [ ! -e "$HOME/.ssh/allowed_signers" ]; then
  # Derived, not authored — regenerating beats remembering to hand-write it
  email=$(git config --file "$DOTFILES/.gitconfig" user.email)
  printf '%s %s\n' "$email" "$(cat "$HOME/.ssh/id_ed25519_signing.pub")" > "$HOME/.ssh/allowed_signers"
  echo "  wrote ~/.ssh/allowed_signers for $email"
fi

# Homebrew
if command -v brew &>/dev/null; then
  echo "running brew bundle..."
  brew bundle --file="$DOTFILES/Brewfile"
else
  echo "homebrew not found — install from https://brew.sh first"
fi

echo "done"
