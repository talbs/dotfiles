#!/usr/bin/env bash
# SessionStart context loader.
# Gates: cwd must be a git repo AND contain CLAUDE.md or AGENTS.md.
# Output: a markdown block with branch state, recent commits, open PRs,
# and the most recent plan file (last 3 days). Injected via additionalContext.

set -uo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[[ -f CLAUDE.md || -f AGENTS.md ]] || exit 0

repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
repo_name=$(basename "$repo_root")
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
dirty_count=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
recent_commits=$(git log --oneline -3 2>/dev/null)

pr_block=""
if command -v gh >/dev/null 2>&1; then
  pr_json=$(gh pr list --author @me --limit 5 --json title,number,url,state 2>/dev/null || printf '[]')
  pr_count=$(printf '%s' "$pr_json" | jq 'length' 2>/dev/null || echo 0)
  if [ "$pr_count" -gt 0 ]; then
    pr_block=$(printf '%s' "$pr_json" | jq -r '.[] | "- #\(.number) \(.title) (\(.state))"')
  fi
fi

plan_block=""
plans_dir="$HOME/.claude/plans"
if [ -d "$plans_dir" ]; then
  recent_plan=$(find "$plans_dir" -maxdepth 1 -name '*.md' -mtime -3 2>/dev/null | head -1)
  if [ -n "$recent_plan" ]; then
    plan_block="- $(basename "$recent_plan") (modified $(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$recent_plan" 2>/dev/null))"
  fi
fi

context="## Project context (auto-loaded)

**Repo:** \`$repo_name\` on \`$branch\` ($dirty_count uncommitted file(s))

**Last 3 commits:**
\`\`\`
$recent_commits
\`\`\`
"

if [ -n "$pr_block" ]; then
  context+="
**Your open PRs in this repo:**
$pr_block
"
fi

if [ -n "$plan_block" ]; then
  context+="
**Recent plan file (last 3 days):**
$plan_block
"
fi

jq -n --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'

exit 0
