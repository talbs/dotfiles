```
        _____________________________
       |  _________________________  |
       | |                         | |
       | |        _       _        | |
       | |       | |     | |       | |
       | |       |_|     |_|       | |
       | |                         | |
       | |        \       /        | |
       | |         \_____/         | |
       | |                         | |
       | |_________________________| |
       |   ________________    _     |
       |  |  ____________  |  | |    |
       |  | |            | |  |_|    |
       |  | |____________| |         |
       |  |________________|         |
       |_____________________________|
      /                              /
     / talbs/dotfiles               /
    /______________________________/
```

# dotfiles

Personal development environment configuration for macOS.

## What's Inside

| File                   | Description                                                          |
| ---------------------- | -------------------------------------------------------------------- |
| `install.sh`           | Setup — `./install.sh work\|personal [--dry-run]`                     |
| `prune-extensions.sh`  | Removes VS Code extensions not listed in any Brewfile (dry-run by default) |
| `.gitconfig`           | Git preferences (rebase, aliases, VS Code as editor, rerere)         |
| `.gitignore_global`    | Global gitignore for macOS, editors, `.warp/`, `.claude/`            |
| `.zshrc`               | Plain zsh for Warp — mise, atuin, completions, plugins, aliases      |
| `.prettierrc`          | Global Prettier formatting rules                                     |
| `.editorconfig`        | Universal editor defaults                                            |
| `Brewfile`             | Shared Homebrew packages, CLI tools, and the canonical VS Code extension list |
| `Brewfile.work`        | Work-only extras — OrbStack, Vagrant, AWS CLI                        |
| `CLAUDE.md`            | Global preferences for Claude Code                                   |
| `claude-settings.json` | Claude Code settings — wires hooks, plugins, preferences             |
| `.claude/hooks/`       | Claude Code hook scripts (safety guard, session context, formatters) |
| `.claude/commands/`    | Claude Code slash commands — `/humanize`, `/pr-feedback`             |
| `.claude/skills/`      | Claude Code skills — `ship`, `once-over`, linked individually        |
| `vscode/settings.json` | VS Code editor settings                                              |
| `mise/config.toml`     | Global tool versions (Node)                                          |
| `raycast/`             | Importable snippets and quicklinks                                   |
| `claude-app-instructions.md` | Custom instructions for the Claude app — hand-synced with `CLAUDE.md` |
| `docs/`                | Design docs, including the work machine setup spec                   |

## Setup on a Fresh Mac

| Step | Command / Action                                           |
| ---- | ---------------------------------------------------------- |
| 1    | Install [Homebrew](https://brew.sh)                        |
| 2    | `git clone git@github.com:talbs/dotfiles.git ~/Projects/talbs/dotfiles` |
| 3    | Generate this machine's SSH key and point the signing symlink at it (below) |
| 4    | `cd ~/Projects/talbs/dotfiles && ./install.sh work\|personal --dry-run`, read it, then drop `--dry-run` |
| 5    | Sign into Claude Code (installed by the Brewfile) and Copilot in VS Code    |
| 6    | Optional: `brew install --cask raycast`, then import from `raycast/` |

`install.sh` takes a profile and symlinks all configs, backing up existing files. It runs `brew bundle` against the shared `Brewfile`, then against `Brewfile.<profile>` for that machine's extras. Pass `--dry-run` first to see every link and brew action without performing any.

### Signing key

`.gitconfig` is shared across machines, so it can't name any one machine's key. It always points at `~/.ssh/id_ed25519_signing.pub`, and each machine symlinks that to its own key:

```sh
ssh-keygen -t ed25519 -C "hi.talbs@gmail.com" -f ~/.ssh/id_ed25519_<machine>
ln -sfn id_ed25519_<machine> ~/.ssh/id_ed25519_signing
ln -sfn id_ed25519_<machine>.pub ~/.ssh/id_ed25519_signing.pub
```

Register the public key on GitHub **twice** — once as an Authentication key, once as a Signing key. Skip the second and commits sign locally but never show Verified.

Do this before `install.sh`, which derives `~/.ssh/allowed_signers` from the pointer and warns if it is missing. Without the pointer, `commit.gpgsign = true` makes every commit fail with `fatal: failed to write commit object`.
