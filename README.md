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

| File                   | Description                                                |
| ---------------------- | ---------------------------------------------------------- |
| `.gitconfig`           | Git preferences (rebase, commit aliases, Cursor as editor) |
| `.gitignore_global`    | Global gitignore for macOS/editor files                    |
| `.zshrc`               | Oh My Zsh config with mise, atuin, and custom aliases      |
| `.prettierrc`          | Global Prettier formatting rules                           |
| `.editorconfig`        | Universal editor defaults                                  |
| `Brewfile`             | Homebrew packages and Cursor extensions                    |
| `CLAUDE.md`            | Global preferences for Claude Code                         |
| `claude-settings.json` | Claude Code hooks (Prettier auto-format, notifications)    |
| `cursor/settings.json` | Cursor editor settings                                     |
| `cursor-rules.md`      | Global AI rules for Cursor (reference copy)                |
| `mise/config.toml`     | Global tool versions (Node, pnpm)                          |
| `raycast/`             | Importable snippets and quicklinks                         |

## Setup on a Fresh Mac

| Step | Command / Action                                                                  |
| ---- | --------------------------------------------------------------------------------- |
| 1    | Install [Homebrew](https://brew.sh)                                               |
| 2    | `git clone git@github.com:talbs/dotfiles.git ~/.dotfiles`                         |
| 3    | `brew bundle install --file=~/.dotfiles/Brewfile`                                 |
| 4    | Symlink configs (see below)                                                       |
| 5    | Import Raycast snippets and quicklinks from `raycast/`                            |
| 6    | Copy `claude-settings.json` to `~/.claude/settings.json`                          |
| 7    | Paste contents of `cursor-rules.md` into Cursor Settings > General > Rules for AI |

### Symlinks

| Source                             | Target                                                    |
| ---------------------------------- | --------------------------------------------------------- |
| `~/.dotfiles/.gitconfig`           | `~/.gitconfig`                                            |
| `~/.dotfiles/.gitignore_global`    | `~/.gitignore_global`                                     |
| `~/.dotfiles/.zshrc`               | `~/.zshrc`                                                |
| `~/.dotfiles/.prettierrc`          | `~/.prettierrc`                                           |
| `~/.dotfiles/.editorconfig`        | `~/.editorconfig`                                         |
| `~/.dotfiles/mise/config.toml`     | `~/.config/mise/config.toml`                              |
| `~/.dotfiles/CLAUDE.md`            | `~/.claude/CLAUDE.md`                                     |
| `~/.dotfiles/cursor/settings.json` | `~/Library/Application Support/Cursor/User/settings.json` |
