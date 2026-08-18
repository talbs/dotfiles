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
| `prune-extensions.sh`  | Removes VS Code extensions not in the Brewfile (dry-run by default)  |
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
| `vscode/settings.json` | VS Code editor settings                                              |
| `mise/config.toml`     | Global tool versions (Node)                                          |
| `raycast/`             | Importable snippets and quicklinks                                   |

## Setup on a Fresh Mac

| Step | Command / Action                                           |
| ---- | ---------------------------------------------------------- |
| 1    | Install [Homebrew](https://brew.sh)                        |
| 2    | `git clone git@github.com:talbs/dotfiles.git ~/Projects/talbs/dotfiles` |
| 3    | `cd ~/Projects/talbs/dotfiles && ./install.sh work`        |
| 4    | Sign into Copilot and the Claude Code extension in VS Code |
| 5    | Import Raycast snippets and quicklinks from `raycast/`     |

`install.sh` takes a profile and symlinks all configs, backing up existing files. It runs `brew bundle` against the shared `Brewfile`, then against `Brewfile.<profile>` for that machine's extras. Pass `--dry-run` first to see every link and brew action without performing any.
