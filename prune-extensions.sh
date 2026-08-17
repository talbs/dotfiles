#!/bin/bash
set -e

# Uninstalls every VS Code extension not listed in the Brewfile.
# Dry-run by default; pass --apply to actually remove.

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BREWFILE="$DOTFILES/Brewfile"
APPLY=""
[ "${1:-}" = "--apply" ] && APPLY="yes"

command -v code >/dev/null || { echo "code CLI not on PATH"; exit 1; }

keep=$(grep '^vscode "' "$BREWFILE" | sed 's/^vscode "//; s/"$//' | tr 'A-Z' 'a-z' | sort)
installed=$(code --list-extensions | tr 'A-Z' 'a-z' | sort)
remove=$(comm -13 <(echo "$keep") <(echo "$installed"))

if [ -z "$remove" ]; then
  echo "nothing to prune — installed extensions already match the Brewfile"
  exit 0
fi

count=$(echo "$remove" | wc -l | tr -d ' ')

if [ -z "$APPLY" ]; then
  echo "would remove $count extensions (dry run):"
  echo "$remove" | sed 's/^/  /'
  echo
  echo "keeping $(echo "$keep" | wc -l | tr -d ' '):"
  echo "$keep" | sed 's/^/  /'
  echo
  echo "re-run with --apply to remove them"
  exit 0
fi

# Snapshot first, and never clobber it — a second run would otherwise record
# the already-pruned state and destroy the only recovery record
snapshot="$DOTFILES/.extensions-before-prune.txt"
if [ -e "$snapshot" ]; then
  echo "keeping existing snapshot at $snapshot"
else
  echo "$installed" > "$snapshot"
  echo "snapshotted $(echo "$installed" | wc -l | tr -d ' ') extensions to $snapshot"
fi

echo "removing $count extensions..."
while IFS= read -r ext; do
  code --uninstall-extension "$ext" >/dev/null 2>&1 && echo "  removed $ext" || echo "  FAILED  $ext"
done <<< "$remove"

echo "done. restore any one with: code --install-extension <id>"
