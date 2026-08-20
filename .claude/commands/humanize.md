---
description: Strip AI tells from a piece of text and rewrite it to read like a real person
argument-hint: [paste text, or leave blank to use the text above]
---

You are de-slopping a piece of writing so it stops reading as machine-generated. This is foreign text (not drafted under my voice rules), so your job is to remove the AI fingerprints while keeping the author's meaning intact — not to overwrite it with my persona unless I say so.

Text to rewrite:
$ARGUMENTS

(If nothing was pasted above, use the most recent block of text in this conversation.)

Rewrite it against these passes. Apply them together, not as six separate outputs:

- **Rougher, more direct.** Say it the way someone who actually lived it would. Cut anything rehearsed, overbuilt, or written to sound impressive.
- **Fix the rhythm.** Real thinking is uneven — punchy in places, slower in others. Break any pattern where the pacing is too controlled or every sentence is the same length. Fragments are fine.
- **Strip the named tells.** Kill everything in **AI tells** in `~/.claude/CLAUDE.md` — that section is the canonical list, don't keep a second copy here.
- **Take a position.** Cut the neutral-observer, please-everyone tone. Let a clear point of view, opinions, and small contradictions come through.
- **Un-polish it.** Writing that's too clean and too precise is itself a tell. Go sentence by sentence and rough up anything that reads overcorrected — like every word was second-guessed.

Output only the rewritten text. Then, on a separate line below a `---`, name the one line you're least sure about and why — don't claim it's fixed.
