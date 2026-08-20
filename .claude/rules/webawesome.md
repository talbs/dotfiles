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
