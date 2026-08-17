#!/usr/bin/env bash
# PostToolUse Write|Edit hook.
# Routes by extension:
#   .ex/.exs/.heex → mix format, run from the mix project root
#   web formats    → prettier
# Anything else exits without work — this runs on every Write and Edit, so an
# unmatched extension must not cost a process spawn.

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
  local pkg_root
  local -a bin=()

  pkg_root=$(find_up package.json)
  if [ -n "$pkg_root" ] && [ -x "$pkg_root/node_modules/.bin/prettier" ]; then
    bin=("$pkg_root/node_modules/.bin/prettier")
  elif command -v prettier >/dev/null 2>&1; then
    bin=(prettier)
  elif command -v npx >/dev/null 2>&1; then
    # --no-install so a missing prettier fails fast instead of downloading one
    bin=(npx --no-install prettier)
  else
    return 0
  fi

  "${bin[@]}" --write "$target" >/dev/null 2>&1 || true
}

case "$ext" in
  ex|exs|heex)
    mix_root=$(find_up mix.exs)
    if [ -n "$mix_root" ] && command -v mix >/dev/null 2>&1; then
      (cd "$mix_root" && mix format "$file") >/dev/null 2>&1 || true
    fi
    ;;
  # .njk and .liquid are absent on purpose — prettier needs plugins for those.
  js|jsx|mjs|cjs|ts|tsx|mts|cts|css|scss|less|html|hbs|vue|svelte|json|jsonc|json5|md|markdown|mdx|yaml|yml|graphql|gql)
    run_prettier "$file"
    ;;
esac

exit 0
