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

| File                   | Description                                                   |
| ---------------------- | ------------------------------------------------------------- |
| `install.sh`           | One-command setup — symlinks configs, runs Brew bundle        |
| `.gitconfig`           | Git preferences (rebase, aliases, Cursor as editor, rerere)   |
| `.gitignore_global`    | Global gitignore for macOS, editors, `.warp/`, `.claude/`     |
| `.zshrc`               | Oh My Zsh config, trimmed for Warp (mise, atuin, aliases)     |
| `.prettierrc`          | Global Prettier formatting rules                              |
| `.editorconfig`        | Universal editor defaults                                     |
| `Brewfile`             | Homebrew packages, CLI tools (fd, ripgrep, tree), Cursor exts |
| `CLAUDE.md`            | Global preferences for Claude Code                            |
| `claude-settings.json` | Claude Code hooks (Prettier auto-format, notifications)       |
| `cursor/settings.json` | Cursor editor settings                                        |
| `cursor-rules.md`      | Global AI rules for Cursor (kept in sync with `CLAUDE.md`)    |
| `mise/config.toml`     | Global tool versions (Node, pnpm)                             |
| `raycast/`             | Importable snippets and quicklinks                            |

## Setup on a Fresh Mac

| Step | Command / Action                                                                  |
| ---- | --------------------------------------------------------------------------------- |
| 1    | Install [Homebrew](https://brew.sh)                                               |
| 2    | `git clone git@github.com:talbs/dotfiles.git ~/.dotfiles`                         |
| 3    | `cd ~/.dotfiles && ./install.sh`                                                  |
| 4    | Import Raycast snippets and quicklinks from `raycast/`                            |
| 5    | Paste contents of `cursor-rules.md` into Cursor Settings > General > Rules for AI |

`install.sh` symlinks all configs (backing up existing files) and runs `brew bundle`.
