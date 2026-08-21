---
name: last-mile
description: Wrap up finished work into branches, commits, and a PR summary. Use when the work on disk is done and needs to land, or when asked to "make commits", "make logical commits", "split this into branches", "wrap this up", "review our work then commit", or "give me a PR summary".
---

# Last mile

Takes finished work from "it's done on disk" to "branches and commits, ready for me to push". The work already exists; this is the delivery leg.

There is exactly **one approval gate** and it sits before anything is committed. Everything before the gate is analysis. Everything after it is mechanical.

**Never push.** Never open the PR. Never post to GitHub. Output the summary and stop.

## Stage 0 — Work out what state the work is in

Look before you run anything. Check **every repo the work touches and every branch in them**, not just the branch you happen to be standing on. The most common miss is a branch that exists locally and nowhere else, in a repo currently checked out on `main`.

Ignore dirt that predates this work and is unrelated to it — a stray lockfile does not make this a full run. Say which files you are ignoring and why.

- **Uncommitted changes that belong to this work** — the full flow applies. Continue to Stage 1.
- **Committed, but unpushed or pushed without a PR** — the split already happened. Run Stages 1 and 2, then treat Stage 3 as a review of the existing split rather than a proposal for a new one. Stage 4 does nothing unless Stage 3 found something to change.
- **Nothing uncommitted, nothing unpushed, PRs already open** — say so in one line, report where each branch stands, and stop. Do not walk the remaining stages to look busy.

Report which of the three you found, per repo, before continuing.

## Stage 1 — Wrap-up review

Run the Wrap-up review from CLAUDE.md: design hat, dev hat, severity-tagged findings in `path:line — [severity] [hat] issue + suggestion` form.

If it's clean, say so in one line. Don't manufacture critique to look thorough.

If a real review already ran on this work — a code review, another agent, a colleague — skip this stage and say which review you're relying on. A third pass over the same diff finds nothing and costs a turn.

Fix `blocker` findings before continuing. Surface `nit` and `nice-to-have` in the Stage 3 plan and let me choose.

## Stage 2 — Comment audit

CLAUDE.md already mandates a comment check at the end of every turn that wrote code. This stage adds the part that rule can't do: re-run it across **the whole session's diff**, not just the last turn, and report one line — `Comments: N added, M kept.`

## Stage 3 — Propose the plan, then STOP

If Stage 0 found the work already committed, answer each of these about what exists rather than proposing something new. Say plainly whether the existing split is right; do not rewrite history to look tidier when the repo squash-merges anyway.

Present, in this order:

1. **The split.** Which changes group into which branch, and why. Unrelated concerns get separate branches. If the work stacks (branch B depends on branch A), say so and name the base explicitly.
2. **Base branches.** For each branch, what it forks from. Check the repo's actual default rather than assuming `main`.
3. **Branch names.** Three candidates per branch, following the branch-name rules in CLAUDE.md (including its prefix exceptions). One line of why each. Flag your recommendation. I pick.
4. **Commit plan.** The subject line for each commit, in lowercase present participle. Bodies only where the subject genuinely can't carry it.
5. **Leftovers.** Any `nit` or `nice-to-have` from Stage 1 not being addressed.

Then stop and wait. Do not create a branch, stage a file, or commit anything until I answer.

## Stage 4 — Execute

Create the branches, make the commits. If a commit doesn't apply cleanly, stop and say so rather than improvising a different split.

When the work was already committed and Stage 3 found nothing to change, this stage does nothing. Say so and move to Stage 5.

## Stage 5 — PR summary

**Title.** Title Case, matching what I already ship:

- Capitalize the first word, the last word, and every major word.
- Lowercase articles (`a`, `an`, `the`), coordinating conjunctions (`and`, `but`, `or`), and prepositions of four letters or fewer (`of`, `to`, `in`, `on`, `for`, `with`, `from`, `into`) unless they start or end the title.
- Anything in backticks keeps its literal casing. `.claude/rules` and `wa-prose` never become `.Claude/Rules` or `Wa-Prose`.
- A leading scope is fine and common in the work repos, for example `Workspaces: Outline Role Badges` or `Switch: Move Focus Ring from thumb to control`.
- `+` reads better than "and" when joining two nouns: `Rendering + Legibility`.

**Use GitHub-flavored markdown hard.** The body is a document, not a paragraph. Reach for structure whenever it makes the thing scannable:

- Tables for anything comparative — before and after, option matrices, which file loads when. A table beats three sentences describing the same grid.
- Bulleted lists for anything enumerable. One idea per bullet.
- Backticks on every filename, identifier, flag, and token.
- Task lists for follow-ups the reader might pick up.
- `<details>` around long output such as logs or full file dumps, so the page stays readable.

Structure and formatting:

- Format as copy-pasteable GitHub-flavored markdown: title shown separately above, body in a single fenced ` ```markdown ` block. Don't wrap that block in an outer escape-fence — the visual padding from nested fencing is more annoying than the artifact.
- Open with a lead paragraph (one or two sentences) framing what the PR does. If it's a follow-up to another PR, link the prior PR by URL inline.
- Use `### Topic` (h3) headings for grouped changes. **Aim for tight** — the diff carries detail, the body just explains intent. Reach for bulleted lists when a section enumerates distinct items; stay in prose when it's one continuous thought.
- Inline `code` liberally for filenames, identifiers, attributes, and tokens.
- **No `## Summary` or `## Test plan` headers** — just the lead paragraph and the topic sections.
- If there are companion PRs in other repos, list them under a `## Companion PRs` (h2) heading at the bottom with bulleted GitHub URLs.
- Don't add Claude/co-author footers unless I ask.
- Write the body to **Plain language** above, every time. I should never have to follow up asking for it simpler or more human-readable.

Also follow **Markdown formatting** in CLAUDE.md — no hard wrapping in anything bound for GitHub or Slack.

For voice, apply **Plain language** and the prose half of **AI tells** from CLAUDE.md. Both, every time — I should never have to ask for "simpler" or "more human-readable" as a follow-up.

Do not apply the full **Writing in my voice** treatment. A PR description is not a blog post: no persona, no fragments-for-emphasis, no deliberate roughing up.

Before showing me the summary, check it: no sentence over 25 words, no em-dash where a period would do, every piece of jargon glossed on first use. Report the sentence count and any you could not get under 25 words, with the reason. Do not just assert it reads simply — count.

One summary per repo touched. Cross-link companion PRs only when they are in repos with the same audience; never link a personal repo from a work PR.
