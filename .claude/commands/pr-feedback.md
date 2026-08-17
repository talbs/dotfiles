---
description: Review unresolved PR feedback, validate it, and propose responses + code changes — without editing files or posting comments.
argument-hint: '[PR number, full URL, or empty to use current branch]'
---

Help me triage and plan responses to feedback on a pull request. **Do not edit files. Do not post anything to GitHub.** Output a plan I can act on.

## 1. Resolve the target PR

Argument: `$ARGUMENTS`

- **Empty** — use `git branch --show-current` and find the open PR on origin for that branch via `gh pr list --head <branch> --state open --json number,url,headRepository,baseRepository -q '.[0]'`. If no PR exists, stop and tell me.
- **A bare number** (e.g. `123`) — that PR in the current repo.
- **A full URL** (e.g. `https://github.com/owner/repo/pull/123`) — that PR. Use `--repo owner/repo` on all subsequent `gh` calls so this works cross-repo.

Confirm the target up front in one line: `Reviewing feedback on <owner/repo>#<number> — <title>`.

## 2. Fetch

1. PR metadata: `gh pr view <target> --json title,body,author,headRefName,baseRefName,url,files`
2. My GitHub login (used in the filter step): `gh api user -q .login`
3. Review threads with resolution state — GraphQL is the reliable source:

   ```
   gh api graphql -f query='
     query($owner:String!,$repo:String!,$number:Int!){
       repository(owner:$owner,name:$repo){
         pullRequest(number:$number){
           reviewThreads(first:100){ nodes {
             isResolved isOutdated path line
             comments(first:50){ nodes { author{login} body createdAt url } }
           }}
         }
       }
     }' -f owner=<owner> -f repo=<repo> -F number=<number>
   ```

## 3. Filter to what actually needs attention

Keep a thread only if **both** are true:

- `isResolved` is `false`
- The most recent comment in the thread is **not** authored by me

If nothing remains, say so and stop. Don't fabricate work.

## 4. Validate each surviving thread

For each thread, read the referenced file at the PR head (`gh pr diff` for patch context, or Read the file at `headRefName`). Assess the feedback against what's actually in the diff before categorizing. Don't guess — if the code's ambiguous, look at it.

Categorize each thread as exactly one of:

- **agree → will fix** — valid, not yet addressed
- **agree → already addressed** — valid, but a later commit handles it
- **disagree → needs response** — I have a reason to push back
- **clarify → needs more info** — ambiguous; the reviewer needs to clarify
- **defer → follow-up PR** — valid but out of scope for this PR

## 5. Plan — output format

For each surviving thread, in file/line order:

> ### Thread N — `path:line` — @reviewer
>
> **Feedback**: <one-line paraphrase>
>
> **Category**: <one of the five>
>
> **Proposed response** (neutral tone, paste-ready — not in my voice):
>
> ```markdown
> …
> ```
>
> **Proposed code change**: <described, not applied> — or `None`.

End with a one-line summary: counts per category and recommended next steps (e.g., `3 fixes to make, 1 response to post, 1 follow-up issue to file`).

## Constraints

- No file edits.
- No `gh pr comment`, `gh pr review`, `gh api … -X POST` — never post on my behalf.
- Keep each thread block tight. No walls of text.
- If a thread spans multiple files or has nested sub-discussions, summarize rather than dump.
