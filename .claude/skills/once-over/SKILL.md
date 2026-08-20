---
name: once-over
description: Boot the dev server, open the page in a browser, and look at the change. Use for any visual, CSS, layout, or copy change that needs to be seen — and before asking me what something looks like or asking me for a screenshot.
---

# Once-over

Close the visual loop without me. If you are about to ask "can you check how this looks?" or "send me a screenshot", use this instead.

One bounded pass, not a polishing loop. That is what the name is for.

## Finding the server

Read `package.json` scripts and take the first of `dev`, `start`, `serve`, `preview` that actually starts a server. If none of them do, say so and ask rather than guessing. If the project has no web UI at all, this skill does not apply — say that and stop.

The repo's own `CLAUDE.md` or a path-scoped rule may name the exact command and port range. When one has loaded, it wins over guessing.

## Booting

1. **Check for a running server first.** `lsof -nP -iTCP -sTCP:LISTEN | grep -E ':(3000|4[0-9]{3}|5173)\b'` (avoid a bare `5[0-9]{3}` — macOS AirPlay sits on 5000 and Postgres on 5432, and both would read as "already running"). If the right one is already up, reuse it. Do not boot a second copy.
2. Start it in the background.
3. **Read the port out of the server output, don't guess.** Many dev servers take the first free port in a range instead of a fixed one. Poll the log for the first `http://localhost:<port>` it emits, or until 90s passes.
4. `preview_start` with the resolved URL.

If the server will not come up, its backing services are probably down. Say so rather than sitting silent.

## The pass

1. Navigate to the page the change actually affects. Work it out from the diff; ask only if genuinely ambiguous.
2. Screenshot.
3. Judge it against what I asked for. Be specific: is the spacing what I said, is the ring cropped to the control, did the badge change appearance.
4. If it is obviously wrong, fix and re-shoot.
5. **Stop after 3 iterations**, whatever the state. Surface what you have.
6. Report with the screenshot and the diff together.

Check both light and dark mode when the change touches color, and narrow width when it touches layout.

## Honesty rules

You are a weak judge of visual quality. Act accordingly.

- Always show me the screenshot, even when you think it is right. Never report "looks good" without the image.
- Say which of the 3 iterations you used and what changed between them.
- Flag what you could not verify — hover, focus-visible, transitions, anything needing real interaction.
- If it looks wrong and you do not know why, say that. Don't keep tweaking values hoping it resolves.
