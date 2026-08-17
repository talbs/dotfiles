#!/usr/bin/env bash
# PostToolUse Write|Edit hook.
# Routes by extension:
#   .ex/.exs/.heex → mix format (if mix.exs found up the tree)
#   *              → prettier (preserves prior behavior, handles filenames with spaces)

set -uo pipefail

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -z "$file" ] && exit 0
[ ! -f "$file" ] && exit 0

ext="${file##*.}"
file_dir=$(dirname "$file")

find_up() {
  local marker="$1"
  local d="$file_dir"
  while [ "$d" != "/" ] && [ -n "$d" ]; do
    [ -f "$d/$marker" ] && { echo "$d"; return 0; }
    d=$(dirname "$d")
  done
  return 1
}

run_prettier() {
  local target="$1"
  if command -v npx >/dev/null 2>&1; then
    npx prettier --write "$target" >/dev/null 2>&1 || true
  fi
}

case "$ext" in
  ex|exs|heex)
    mix_root=$(find_up mix.exs)
    if [ -n "$mix_root" ] && command -v mix >/dev/null 2>&1; then
      (cd "$mix_root" && mix format "$file") >/dev/null 2>&1 || true
    fi
    ;;
  *)
    run_prettier "$file"
    ;;
esac

exit 0
