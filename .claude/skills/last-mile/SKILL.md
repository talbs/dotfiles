---
name: last-mile
argument-hint: '[repo] [branch] — omit to check everything'
description: Wrap up finished work into branches, commits, and a PR summary. Use when the work on disk is done and needs to land, or when asked to "make commits", "make logical commits", "split this into branches", "wrap this up", "review our work then commit", or "give me a PR summary".
---

# Last mile

Takes finished work from "it's done on disk" to "branches and commits, ready for me to push". The work already exists; this is the delivery leg.

There is exactly **one approval gate** and it sits before anything is committed. Everything before the gate is analysis. Everything after it is mechanical.

**Never push.** Never open the PR. Never post to GitHub. Output the summary and stop.

## Stage 0 — Work out what state the work is in

**If I named a repo or a branch, scope to it.** Look only there, say in one line what you are skipping, and skip Stage 0's wider scan. `last-mile dotfiles chore/case-in-point` means that branch in that repo and nothing else.

With no argument, check **every repo the work touches and every branch in them**, not just the branch you happen to be standing on. The most common miss is a branch that exists locally and nowhere else, in a repo currently checked out on `main`.

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

**Body.** A body is one plain sentence and a few bullets. The reader should get the gist from the first line and the rest in five seconds. The diff carries the detail.

Shape:

1. **Lead.** One sentence on the value or the reason for the work: what was wrong, or what someone can do now. A second sentence for what the PR does is fine when the first can't carry both. Never a third. Each stays under 20 words and does not run on; if it needs a comma to survive, it's two sentences.
2. **Bullets.** Two to five. Each is a fragment under twelve words, lowercase, no trailing period. Only what a reviewer needs before opening the diff: a caveat, a follow-up, a rename, a behaviour they'd trip on. Vary the count with the PR; four every time reads as a form.
3. **Links.** One line at the end when there is one: `Stacks on <url>.`, `Closes #123.`, companion PRs. Full URL for anything in another repo. Companions only when they're in repos with the same audience; never link a personal repo from a work PR.

Rules:

- Aim for 60 words, never over 75. Count them. A two-sentence lead eats half the budget, so it usually means three bullets, not five. If the draft is over 75, cut before showing me; don't ask.
- No headings, no tables, no "why" paragraph. Anything that reads as a section is too much.
- A before/after screenshot replaces any bullet describing pixels. Say where it goes; I'll attach it.
- The delete test: if a reviewer would see it in the diff, it doesn't go in a bullet. If every bullet fails that test you've written a changelog. Start over from the lead.
- Backticks on filenames and identifiers, at most two per line.
- No `## Summary` or `## Test plan` headers. No Claude/co-author footers unless I ask.
- Format as copy-pasteable GitHub-flavored markdown: title shown separately above, body in a single fenced ` ```markdown ` block. Don't wrap that block in an outer escape-fence.
- Follow **Markdown formatting** in CLAUDE.md — no hard wrapping in anything bound for GitHub.

Voice: **Plain language** and the prose half of **AI tells** from CLAUDE.md, every time. Not the full **Writing in my voice** treatment — no persona, no fragments-for-emphasis in the lead, no deliberate roughing up. Watch for the opposite tell too: a casual tic added to sound human ("while I was in there", "heads up that") is still a tell. Cut it.

What this looks like. This replaced a 200-word, two-section body for the same PR:

```markdown
Clicking a `#` link on the docs site could land you thousands of pixels above the target. This waits for components to load before jumping.

- the page is taller before components load, so the jump missed
- `scroll.js` already did this for reload, now for `#` links too
- back/forward and restored scroll positions still win
```

Before showing me the summary, report the word count, and any lead sentence over 20 words or bullet over twelve, with the reason. Do not just assert it reads simply — count.

One summary per repo touched.
