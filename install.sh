#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PROFILE=""
DRY_RUN=""

usage() {
  echo "usage: ./install.sh work|personal [--dry-run]"
  exit 1
}

for arg in "$@"; do
  case "$arg" in
    work | personal) PROFILE="$arg" ;;
    --dry-run) DRY_RUN="yes" ;;
    *)
      echo "unknown argument: $arg"
      usage
      ;;
  esac
done

# No default profile — guessing wrong installs the wrong machine's software
[ -n "$PROFILE" ] || usage

if [ -n "$DRY_RUN" ]; then
  echo "DRY RUN — nothing will be written"
fi
echo "linking dotfiles from $DOTFILES (profile: $PROFILE)"

# Symlink helper: backs up existing file, then links
link() {
  local src="$DOTFILES/$1"
  local dst="$2"
  if [ -n "$DRY_RUN" ]; then
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
      echo "  would back up $dst -> $dst.backup"
    fi
    echo "  would link $dst -> $src"
    return
  fi
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

# Skills link one at a time so ~/.claude/skills stays a real directory. Linking the
# whole directory into this repo makes installers (npx skills add, plugins) write their
# skills into a synced git repo. hooks/ and commands/ stay whole-directory links above
# because nothing else writes into them.
skills_dir="$HOME/.claude/skills"

# Links one skill into the scan path. A real directory there belongs to something else,
# so it moves OUT of the scan path — a sibling .backup would register as a duplicate skill.
link_skill() {
  local src="$1" dst="$skills_dir/$2"
  if [ -n "$DRY_RUN" ]; then
    [ -d "$dst" ] && [ ! -L "$dst" ] && echo "  would back up $dst -> $HOME/.claude/skills-backup/$2"
    echo "  would link $dst -> $src"
    return
  fi
  if [ -d "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$HOME/.claude/skills-backup"
    rm -rf "$HOME/.claude/skills-backup/$2"
    mv "$dst" "$HOME/.claude/skills-backup/$2"
    echo "  backing up $dst -> $HOME/.claude/skills-backup/$2"
  fi
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

if [ -n "$DRY_RUN" ]; then
  [ -L "$skills_dir" ] && echo "  would replace symlink $skills_dir with a real directory"
  echo "  would ensure directory $skills_dir"
else
  [ -L "$skills_dir" ] && rm "$skills_dir"
  mkdir -p "$skills_dir"
fi

# The loop below only adds, so a skill removed from this repo would leave a dangling link.
if [ -d "$skills_dir" ] && [ ! -L "$skills_dir" ]; then
  for stale in "$skills_dir"/*; do
    [ -L "$stale" ] && [ ! -e "$stale" ] || continue
    if [ -n "$DRY_RUN" ]; then
      echo "  would prune stale link $stale"
    else
      rm "$stale"
      echo "  pruning stale link $stale"
    fi
  done
fi

for skill_dir in "$DOTFILES"/.claude/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill=$(basename "$skill_dir")
  # In a dry run the old directory symlink is still in place, so the destination resolves
  # through it into the repo and would wrongly report a backup. The real run removes it first.
  if [ -n "$DRY_RUN" ] && [ -L "$skills_dir" ]; then
    echo "  would link $skills_dir/$skill -> $DOTFILES/.claude/skills/$skill"
    continue
  fi
  link_skill "$DOTFILES/.claude/skills/$skill" "$skill"
done

link "vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

# Web Awesome's own component skill is generated build output, so it is not versioned
# here. It lives at ~/.agents/skills/ via `npx skills add` and is linked in on work
# machines only. Re-run the add command after a Web Awesome release to refresh it.
if [ "$PROFILE" = work ]; then
  wa_skill="$HOME/.agents/skills/webawesome"
  wa_src="$HOME/Projects/shoelace-style/webawesome-app/webawesome/packages/webawesome/dist/skills/webawesome"
  if [ -d "$wa_skill" ]; then
    link_skill "$wa_skill" webawesome
  else
    echo "  skipping webawesome skill — not installed. To add it, build the component"
    echo "  package, then: npx skills add $wa_src"
  fi
fi

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
  if [ -n "$DRY_RUN" ]; then
    echo "  would write ~/.ssh/allowed_signers for $email"
  else
    printf '%s %s\n' "$email" "$(cat "$HOME/.ssh/id_ed25519_signing.pub")" > "$HOME/.ssh/allowed_signers"
    echo "  wrote ~/.ssh/allowed_signers for $email"
  fi
fi

# Oh My Zsh — .zshrc sources it, so a machine without it gets a broken shell.
# Cloned rather than installed via the upstream curl-pipe-sh script: that script's
# only lasting effect is this same shallow clone once you tell it to keep your own
# .zshrc, so running it would just execute code we never reviewed.
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  oh-my-zsh already installed"
elif [ -n "$DRY_RUN" ]; then
  echo "  would clone oh-my-zsh into ~/.oh-my-zsh"
else
  echo "  cloning oh-my-zsh..."
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" || true
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "  WARNING: oh-my-zsh did not install. Your shell will start without the"
    echo "           git aliases until you re-run this script with a network connection."
  fi
fi

# Homebrew — shared base first, then the profile's extras
if command -v brew &>/dev/null; then
  for bundle in "$DOTFILES/Brewfile" "$DOTFILES/Brewfile.$PROFILE"; do
    if [ ! -f "$bundle" ]; then
      echo "no $(basename "$bundle") — skipping"
      continue
    fi
    if [ -n "$DRY_RUN" ]; then
      echo "would run: brew bundle --file=$(basename "$bundle")"
    else
      echo "running brew bundle --file=$(basename "$bundle")..."
      brew bundle --file="$bundle"
    fi
  done
else
  echo "homebrew not found — install from https://brew.sh first"
fi

echo "done"
