---
paths:
  - '**/shoelace-style/**'
  - '**/webawesome/**'
  - '**/webawesome-app/**'
  - '**/webawesome-pro/**'
---

# Web Awesome repos

Component, utility, and token knowledge comes from the `webawesome` skill, installed from the package's own `dist/skills/`. Don't restate any of it here. It's versioned with the library; this file isn't.

- Default branches differ: `next` on `webawesome`, `main` on `webawesome-app` and `dotfiles`. Confirm before branching, don't assume.
- The repos nest: `webawesome-app` contains `webawesome`, which contains `packages/webawesome` and `packages/webawesome-pro`. One change can span three repos and need three PRs. Cross-link them.

## Dev servers

| cwd is inside                        | Command                                   | Port               |
| ------------------------------------ | ----------------------------------------- | ------------------ |
| `webawesome/packages/webawesome`     | `npm start`                               | dynamic, 4000–4999 |
| `webawesome/packages/webawesome-pro` | `npm start`                               | dynamic, 4000–4999 |
| `webawesome` repo root               | `npm start` (docs) or `npm run start:pro` | dynamic, 4000–4999 |
| `webawesome-app`                     | `npm run dev`                             | 3000               |

Both docs sites are 11ty + browser-sync. `scripts/build.js` calls `getPort({ port: portNumbers(4000, 4999) })` and takes the first free one, so never assume 4000. If `webawesome-app` will not boot, its services are probably down — `npm run docker:start`, and expect it to be slow.
