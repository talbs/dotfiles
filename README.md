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

| File                   | Description                                                    |
| ---------------------- | -------------------------------------------------------------- |
| `install.sh`           | One-command setup — symlinks configs, runs Brew bundle         |
| `.gitconfig`           | Git preferences (rebase, aliases, VS Code as editor, rerere)   |
| `.gitignore_global`    | Global gitignore for macOS, editors, `.warp/`, `.claude/`      |
| `.zshrc`               | Oh My Zsh config, trimmed for Warp (mise, atuin, aliases)      |
| `.prettierrc`          | Global Prettier formatting rules                               |
| `.editorconfig`        | Universal editor defaults                                      |
| `Brewfile`             | Homebrew packages, CLI tools (fd, ripgrep, tree), VS Code exts |
| `CLAUDE.md`            | Global preferences for Claude Code                             |
| `claude-settings.json` | Claude Code hooks (Prettier auto-format, notifications)        |
| `vscode/settings.json` | VS Code editor settings                                        |
| `mise/config.toml`     | Global tool versions (Node, pnpm)                              |
| `raycast/`             | Importable snippets and quicklinks                             |

## Setup on a Fresh Mac

| Step | Command / Action                                           |
| ---- | ---------------------------------------------------------- |
| 1    | Install [Homebrew](https://brew.sh)                        |
| 2    | `git clone git@github.com:talbs/dotfiles.git ~/.dotfiles`  |
| 3    | `cd ~/.dotfiles && ./install.sh`                           |
| 4    | Sign into Copilot and the Claude Code extension in VS Code |
| 5    | Import Raycast snippets and quicklinks from `raycast/`     |

`install.sh` symlinks all configs (backing up existing files) and runs `brew bundle`.
