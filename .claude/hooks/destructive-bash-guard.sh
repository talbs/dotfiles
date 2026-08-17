#!/usr/bin/env bash
# PreToolUse Bash guard.
# Reads the hook payload on stdin. If the command matches a destructive pattern,
# emits JSON asking Claude Code to prompt for confirmation. Otherwise stays
# silent so the command runs normally. Always exits 0 — never blocks outright.

set -uo pipefail

payload=$(cat)
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')

[ -z "$cmd" ] && exit 0

patterns=(
  'rm[[:space:]]+(-[^[:space:]]*r[^[:space:]]*f|-[^[:space:]]*f[^[:space:]]*r|-r[[:space:]]+-f|-f[[:space:]]+-r|--recursive[[:space:]]+--force|--force[[:space:]]+--recursive)'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'git[[:space:]]+push[[:space:]][^|;&]*--force'
  'git[[:space:]]+push[[:space:]]([^|;&]*[[:space:]])?-f([[:space:]]|$)'
  'git[[:space:]]+clean[[:space:]][^|;&]*-[a-zA-Z]*f'
  'git[[:space:]]+branch[[:space:]]+-D[[:space:]]'
  'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)'
  'TRUNCATE[[:space:]]+(TABLE|[A-Za-z_])'
  'kubectl[[:space:]]+delete'
  'docker[[:space:]]+system[[:space:]]+prune'
  'sudo[[:space:]]+rm[[:space:]]'
  # Project wrappers hide their damage behind a flag, so match on the flag.
  # devenv: -X purge and -R reset-search are both documented as irreversible.
  '\./dev[[:space:]][^|;&]*(--purge|--destroy-vm|--destroy-project|--reset-search|--reset-db|--prune)'
  '\./dev[[:space:]][^|;&]*-(X|D|R|P)([[:space:]]|$)'
  '(\./)?bin/reset(-db)?([[:space:]]|$)'
)

joined=$(IFS='|'; echo "${patterns[*]}")

if printf '%s' "$cmd" | grep -qiE "$joined"; then
  matched=$(printf '%s' "$cmd" | grep -oiE "$joined" | head -1)
  jq -n --arg cmd "$cmd" --arg matched "$matched" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ("Destructive command pattern detected (matched: " + $matched + "). Confirm intent before allowing.\n\nFull command: " + $cmd)
    }
  }'
fi

exit 0
