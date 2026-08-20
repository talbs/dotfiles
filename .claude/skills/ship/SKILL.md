---
name: ship
description: Wrap up finished work into branches, commits, and a PR summary. Use when the work on disk is done and needs to land, or when asked to "make commits", "make logical commits", "split this into branches", "wrap this up", "review our work then commit", or "give me a PR summary".
---

# Ship

Takes finished work from "it's done on disk" to "branches and commits, ready for me to push".

There is exactly **one approval gate** and it sits before anything is committed. Everything before the gate is analysis. Everything after it is mechanical.

**Never push.** Never open the PR. Never post to GitHub. Output the summary and stop.

## Stage 1 — Wrap-up review

Run the Wrap-up review from CLAUDE.md: design hat, dev hat, severity-tagged findings in `path:line — [severity] [hat] issue + suggestion` form.

If it's clean, say so in one line. Don't manufacture critique to look thorough.

Fix `blocker` findings before continuing. Surface `nit` and `nice-to-have` in the Stage 3 plan and let me choose.

## Stage 2 — Comment audit

CLAUDE.md already mandates a comment check at the end of every turn that wrote code. This stage adds the part that rule can't do: re-run it across **the whole session's diff**, not just the last turn, and report one line — `Comments: N added, M kept.`

## Stage 3 — Propose the plan, then STOP

Present, in this order:

1. **The split.** Which changes group into which branch, and why. Unrelated concerns get separate branches. If the work stacks (branch B depends on branch A), say so and name the base explicitly.
2. **Base branches.** For each branch, what it forks from. Check the repo's actual default rather than assuming `main`.
3. **Branch names.** Three candidates per branch, following the branch-name rules in CLAUDE.md (including its prefix exceptions). One line of why each. Flag your recommendation. I pick.
4. **Commit plan.** The subject line for each commit, in lowercase present participle. Bodies only where the subject genuinely can't carry it.
5. **Leftovers.** Any `nit` or `nice-to-have` from Stage 1 not being addressed.

Then stop and wait. Do not create a branch, stage a file, or commit anything until I answer.

## Stage 4 — Execute

Create the branches, make the commits. If a commit doesn't apply cleanly, stop and say so rather than improvising a different split.

## Stage 5 — PR summary

Follow the PR descriptions rules in CLAUDE.md for structure and formatting.

For voice, apply **Plain language** and the prose half of **AI tells** from CLAUDE.md. Both, every time — I should never have to ask for "simpler" or "more human-readable" as a follow-up.

Do not apply the full **Writing in my voice** treatment. A PR description is not a blog post: no persona, no fragments-for-emphasis, no deliberate roughing up.

One summary per repo touched. If there are companion PRs across repos, cross-link them.
