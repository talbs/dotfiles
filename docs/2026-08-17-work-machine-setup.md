# Work machine setup — design

Date: 2026-08-17
Status: approved, ready for implementation planning

Setting up a fresh MacBook Pro as the work machine. The current Mac stays and becomes personal. Nothing is migrated with Migration Assistant — this is a cold build, and the dotfiles repo becomes the mechanism rather than a checklist that rots.

The repo currently assumes one personal machine. It grows a second profile instead of a second copy.

## Decisions

| Area                 | Decision                                | Why                                                                                                                                                                                                                                                                                                     |
| -------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Runtime manager      | mise, replacing asdf                    | asdf 0.14 here is the shell-script era. mise activates from `.tool-versions` automatically, which matters because runtime switching never appears in 4,669 commands of shell history — it should be invisible.                                                                                          |
| Terminal             | Warp                                    | Staying put. Already in daily use, and its blocks and command history are established workflow habit. Switching buys nothing the current setup lacks, and costs a migration plus new config to maintain.                                                                                                |
| Shell                | plain zsh + atuin, no prompt framework  | oh-my-zsh's git plugin ships 169 aliases. Measured usage of `gst`/`gco`/`gp`/`ga`/`gcm`/`gd`/`gl`: zero. Workflow is `lazygit` (787 uses) and raw `git` (403). The framework is pure startup cost. No starship either — Warp renders its own prompt, so a second prompt renderer is redundant work.       |
| Editor               | VS Code                                 | Cursor is retired on both machines, not just work. Claude Code becomes the primary AI coding surface.                                                                                                                                                                                                   |
| Xcode                | Command Line Tools only                 | Full Xcode is ~15GB and nothing here needs it.                                                                                                                                                                                                                                                          |
| Container runtime    | OrbStack, no Docker Desktop             | Already proven — the current machine runs devenv on OrbStack today.                                                                                                                                                                                                                                     |
| Virtualization       | Vagrant via the plain `vagrant` cask    | `hashicorp/tap` is now flagged Untrusted by Homebrew and refuses to load. See Hazards.                                                                                                                                                                                                                  |
| Git identity         | One email on both machines              | `hi.talbs@gmail.com` everywhere, so contribution credit lands on a single GitHub account. Directory-scoped identity is dropped.                                                                                                                                                                         |
| Commit signing       | SSH, `~/.ssh/id_ed25519.pub`            | Already the repo's decision from PR #2. No UID matching, no GPG Keychain, no key expiry.                                                                                                                                                                                                                |
| Apps                 | Minimum viable, add on demand           | Only what blocks day-one work gets installed. Everything else waits until first reach.                                                                                                                                                                                                                  |
| Node package manager | npm                                     | Every JS repo in play ships `package-lock.json`. Measured: npm 580, pnpm 0, bun 0, yarn 0.                                                                                                                                                                                                              |

### One identity, everywhere

The goal is contribution credit across every project, which is an **author email** question, not a signing one. GitHub attributes commits by matching the author email against a verified email on the account; the signature only produces the Verified badge.

Commit history on this machine shows four identities in play:

| Email                   | Where                                                        |
| ----------------------- | ------------------------------------------------------------ |
| `hi.talbs@gmail.com`    | 118 in webawesome-app, 505 in fontawesome, 13 in web-awesome |
| `brian@fortawesome.com` | 263 in fontawesome, 15 in web-awesome                        |
| `talbs@fortawesome.com` | 43 in fontawesome                                            |
| `brian@awesome.me`      | the new work address                                         |

Recent webawesome-app commits, through 2026-07-29, are all `hi.talbs@gmail.com`. That is the account credit should accrue to, so a single `user.email` applies on both machines and directory-scoped identity is dropped entirely — it was solving for per-repo emails, which is the fragmentation being eliminated.

SSH signing follows from the same goal. GPG only grants Verified when the committer email matches a UID on the key, so a single identity plus GPG means maintaining UIDs; SSH signing has no such coupling, and it drops GPG Keychain, `pinentry-mac`, and key expiry. The repo already made this call in PR #2.

Verified: `user.signingkey = ~/.ssh/id_ed25519.pub` with `gpg.format = ssh` produces a real `SSH SIGNATURE` block in the commit object, validating as good for `hi.talbs@gmail.com`.

**Retroactive credit, worth doing separately.** Adding `brian@fortawesome.com`, `talbs@fortawesome.com`, and `brian@awesome.me` as verified emails on the GitHub account retroactively attributes the ~320 commits currently authored under them. That is an account settings change, not a dotfiles one.

**Standardize the key filename.** The config references `~/.ssh/id_ed25519.pub`, so generating the new machine's key at that exact path makes the config work with no edit.

## What does not come across

Carried on the current machine, deliberately dropped:

- **asdf** and its `~/.asdf/installs` tree — 23 Node versions, 10 Erlang, 10 Elixir, 8 Python.
- **`NODEJS_CHECK_SIGNATURES=no`** — an asdf-nodejs plugin workaround. Meaningless under mise.
- **Fig residue** — `source ~/fig-export/dotfiles/dotfile.zsh`, plus Kiro CLI pre/post blocks bracketing both `.zshrc` and `.zprofile`. Fig is a dead product.
- **Duplicate tooling** — mcfly alongside atuin; starship, pure, and spaceship all installed, none of them kept.
- **`legit` git aliases** — `switch`, `sprout`, `harvest`, `unpublish`, `graft`, `sync`, `publish`. The tool is abandoned; the aliases are broken shims.
- **FA-only aliases** — `bd`, `bdf`, `binreset`, `seed`. Measured usage: zero each.
- **`NODE_OPTIONS="--max-old-space-size=8192"`** — likely a bandaid for a Node 16/18-era build. Left out. Add it back only if a build actually OOMs.
- **Docker Desktop** — installed here by devenv's `install-docker.sh` at some point, then superseded by OrbStack and left idle.
- **oh-my-zsh** — 11 plugins, 169 unused git aliases.

## Repo structure

The only genuine difference between the two machines is the Brewfile. Identity is now identical on both, and so is the mise config. A `profiles/` tree for one file would be ceremony, so the split is additive instead: work is base plus extras, never a separate copy.

```
dotfiles/
  install.sh              # ./install.sh work | personal
  Brewfile                # shared base
  Brewfile.work           # + vagrant, orbstack, awscli
  Brewfile.personal       # + personal-only casks
  git/
    gitconfig             # one identity, both machines
    gitignore_global
  zsh/
    zshrc                 # sources the rest, nothing else
    path.zsh
    aliases.zsh
    tools.zsh
  mise/config.toml
  claude/
    CLAUDE.md
    settings.json
  vscode/settings.json
  editorconfig
  prettierrc
```

**Rule that has to hold: no secrets in this repo, ever.** Signing key IDs and email addresses are fine. Private keys, tokens, and anything resembling `devenv/.secrets` come from 1Password at runtime.

### git/gitconfig

Identity is deliberately absent. It arrives via directory-scoped includes, which means the same file is correct on both machines.

```ini
[init]
  defaultBranch = main
[push]
  default = current
[pull]
  rebase = true
[branch]
  autosetupmerge = true
  autosetuprebase = always
[rebase]
  autosquash = true
[rerere]
  enabled = true
[core]
  editor = code --wait
  excludesfile = ~/.gitignore_global
[color]
  ui = true
[credential]
  helper = osxkeychain
[filter "lfs"]
  clean = git-lfs clean -- %f
  smudge = git-lfs smudge -- %f
  process = git-lfs filter-process
  required = true
[alias]
  branches = for-each-ref --sort='-authordate:iso8601' --format=' %(authordate:relative)%09%(refname:short)' refs/heads
  fixup = !sh -c \"git rebase -i $(git merge-base HEAD ${1:-origin/main})\" -

[user]
  name = Brian Talbot
  email = hi.talbs@gmail.com
  signingkey = ~/.ssh/id_ed25519.pub
[gpg]
  format = ssh
[commit]
  gpgsign = true
```

Two things to know about that block.

`signingkey` points at the **public** key and uses `~`, not an absolute path. The version currently on `main` says `/Users/brian/.ssh/id_ed25519_github` — a file that does not exist. With `gpgsign = true` that is not a warning, it is a hard failure: `fatal: failed to write commit object`, and every commit aborts. Anyone running `install.sh` before this fix could not commit at all.

Local verification of SSH signatures needs `gpg.ssh.allowedSignersFile`; without it `git log --show-signature` reports no signature even though one is present. GitHub's Verified badge does not depend on it, so it is optional — add it if you want `git verify-commit` to work offline.

Note `origin/main` in the `fixup` alias — the current version still says `origin/master`.

### Brewfile (shared)

```ruby
# Shell
brew "atuin"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# Git
brew "git"
brew "git-lfs"
brew "gh"
brew "lazygit"

# Runtimes
brew "mise"

# Search and shell utilities
brew "ripgrep"
brew "fd"
brew "jq"
brew "tree"

# Terminal and secrets
cask "warp"
cask "1password"
cask "1password-cli"
```

No `gnupg` or `pinentry-mac` — SSH signing needs neither, and `ssh-keygen` ships with macOS.

### Brewfile.work

```ruby
# Containers and VMs — order matters, see runbook
cask "orbstack"
cask "vagrant"

# Cloud
brew "awscli"

# Editor
cask "visual-studio-code"

# Work comms and design
cask "slack"
cask "figma"
cask "google-chrome"
```

Deliberately **not** here: `hashicorp/tap`. See Hazards.

VS Code extensions come from the `migrate-to-vscode` branch, which already did the audit this section originally called for: it drops the deprecated `shopify.theme-check-vscode`, drops `chouzz.vscode-better-align`, `gruntfuggly.todo-tree`, and `markwylde.vscode-filesize`, and adds `anthropic.claude-code`, `github.copilot`, and `github.copilot-chat`. Nothing further needed here.

### mise/config.toml

```toml
[tools]
node = "lts"
ruby = "3.4"
```

Two notes.

`node = "lts"` resolves to **24** as of August 2026, not 22. That is correct as a global default — `webawesome-app` pins `nodejs 22.13.0` in its own `.tool-versions`, and mise reads asdf-style version files natively, so the repo wins inside the repo. Both are true at once and neither needs a command typed.

`ruby` is here for one specific reason. devenv's prereq check is only `command -v ruby` — it does not compare versions, which is why macOS's bundled Ruby 2.6.10 satisfies it today. But if Apple finally drops system Ruby, `./dev -i` falls through to `install-ruby.sh`, which runs `brew link ruby@3.1 --force` — a global PATH stomp on a fresh machine. Having any mise-managed Ruby on PATH means that branch never executes. Ruby via mise compiles from source and takes a few minutes; that is a one-time cost.

pnpm and bun are omitted per the measured-usage finding. `fontawesome` carries its own `mise.toml` requesting bun, which mise installs on demand when you enter that directory.

### zsh/zshrc

Sources the other three files and nothing else. No framework.

```sh
source ~/.config/zsh/path.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/tools.zsh
```

### zsh/tools.zsh

```sh
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Completions
autoload -Uz compinit && compinit

# Runtimes and history — Warp draws the prompt, so nothing does here
eval "$(mise activate zsh)"
eval "$(atuin init zsh)"

# Suggestions and highlighting — highlighting must load last
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export EDITOR="code --wait"
export VISUAL="code --wait"

# 1Password CLI plugins, if configured
[[ -f ~/.config/op/plugins.sh ]] && source ~/.config/op/plugins.sh
```

`zsh-syntax-highlighting` must be sourced last or it will not wrap the widgets the other plugins install.

### zsh/aliases.zsh

Survivors only, all with non-zero measured usage or standalone value:

```sh
alias lg='lazygit'
alias ll='ls -lFh'
alias la='ls -lAFh'
alias ff='find . -type f -name'
alias gbsc="git branch --sort=-committerdate"
alias gfp='git fetch --prune'
alias gbdg='git branch -vv | grep ": gone]" | awk "{print \$1}" | xargs git branch -D'
alias listening="lsof -Pnl +M -i | grep LISTEN"
alias lip="ipconfig getifaddr en0"
```

### install.sh

Takes a profile, is idempotent, and can be dry-run. The current version has neither a profile nor a dry-run, and has never been executed.

Behaviour:

1. Accept `work` or `personal` as `$1`. Exit with usage if absent — no default, because the profile decides which Brewfile runs.
2. Support `--dry-run`, printing every link and brew action without performing any.
3. Symlink shared files, backing up any existing non-symlink to `.backup` first.
4. Run `brew bundle --file Brewfile`, then `brew bundle --file Brewfile.<profile>`.
5. Be safe to re-run. Every step checks before acting.

Git identity is not part of the profile — it is the same on both machines, so `git/gitconfig` carries it directly.

Link map:

| Source                         | Destination                                             |
| ------------------------------ | ------------------------------------------------------- |
| `git/gitconfig`                | `~/.gitconfig`                                          |
| `git/gitignore_global`         | `~/.gitignore_global`                                   |
| `zsh/zshrc`                    | `~/.zshrc`                                              |
| `zsh/{path,aliases,tools}.zsh` | `~/.config/zsh/`                                        |
| `mise/config.toml`             | `~/.config/mise/config.toml`                            |
| `claude/CLAUDE.md`             | `~/.claude/CLAUDE.md`                                   |
| `claude/settings.json`         | `~/.claude/settings.json`                               |
| `vscode/settings.json`         | `~/Library/Application Support/Code/User/settings.json` |
| `editorconfig`                 | `~/.editorconfig`                                       |
| `prettierrc`                   | `~/.prettierrc`                                         |

Note the VS Code destination — `Code/User/`, not `Cursor/User/` as the current script has it.

### Migrating the current repo layout

The restructure moves existing files rather than rewriting them. Use `git mv` so history follows.

| Now                    | Becomes                                         |
| ---------------------- | ----------------------------------------------- |
| `.gitconfig`           | `git/gitconfig`, signing key path corrected     |
| `.gitignore_global`    | `git/gitignore_global`                          |
| `.zshrc`               | split into `zsh/{zshrc,path,aliases,tools}.zsh` |
| `.editorconfig`        | `editorconfig`                                  |
| `.prettierrc`          | `prettierrc`                                    |
| `CLAUDE.md`            | `claude/CLAUDE.md`                              |
| `claude-settings.json` | `claude/settings.json`                          |
| `Brewfile`             | `Brewfile` + `Brewfile.work`, split             |

Dropping the leading dot on `editorconfig` and `prettierrc` keeps every source file visible in the repo while the symlink restores the dot at the destination. The same pattern already applies to `git/` and `zsh/`.

Two items need decisions the restructure does not make for them:

- **Cursor is retired entirely** — not work-only, both machines. `cursor/settings.json` moves to `vscode/settings.json` and `cursor-rules.md` is deleted; the `migrate-to-vscode` branch already does both. No profile carries Cursor, and nothing generates `~/.cursor/rules/`. Exactly one stale reference survives that no branch cleans — the `CLAUDE.md` line explaining the Cursor split, which arrives with the voice stack. (`{cursor}` in `raycast/snippets.json` is Raycast's text-cursor placeholder, and `.cursor/` in `.gitignore_global` is worth keeping to catch stray dotdirs. Neither is an editor reference.)
- **`raycast/`** is unaddressed above because Raycast is on the add-on-demand list. Leave the directory in place and link it from the personal profile only, until Raycast earns a spot on the work machine.

### `docs/` is gitignored

`.gitignore` in `main` is a single line: `docs/`. This design document cannot be committed until that is narrowed to `docs/superpowers/`, which is [Likely] the actual intent — keeping generated plan noise out while allowing hand-written docs.

### Homebrew over hand-installed apps

`brew bundle` can fail on a cask when a matching app is already present from a manual install — `It seems there is already an App at...`. This affects the **personal** profile run, not the fresh work machine: 1Password and OrbStack were both installed by hand on the current Mac. Either remove the app first or pass `--force` on that one cask. The work machine has no such collisions because nothing is installed by hand.

## Accounts — do this before the machine arrives

These are other-people-shaped and they gate `./dev` entirely. Nothing else on the list can unblock them, so they go first.

| Account | Contact | Needed for |
| --- | --- | --- |
| Fonticons email | — | Everything downstream |
| 1Password (Fonticons) | Travis Chase, Alex Poiry | devenv secrets, SSH agent |
| quay.io | Rob Madole | Container image pulls |
| AWS | Rob Madole, Tim Crowell | ECR, LocalStack config |
| GitHub org access | — | FortAwesome, shoelace-style repos |

Verify each one works from the *current* machine before the new one arrives. Debugging an account problem and a fresh-machine problem simultaneously is how a one-day setup becomes three.

## Day-one runbook

Most of a machine setup is parallel. This part is not.

1. **Xcode Command Line Tools** — `xcode-select --install`. Nothing else installs before this.
2. **Homebrew** — from brew.sh.
3. **1Password + CLI**, signed in. Enable the SSH agent for auth keys.
4. **SSH key** — generate ed25519 **at `~/.ssh/id_ed25519`**, the exact path `git/gitconfig` expects. Store it in 1Password. Test with `ssh -T git@github.com`.
5. **Register the same key twice on GitHub** — once as an Authentication key, once as a **Signing** key. Two separate entries in Settings → SSH and GPG keys, one public key. Skipping the second means commits sign locally but never show Verified.
6. **Clone dotfiles** to `~/Projects/talbs/dotfiles`, run `./install.sh work --dry-run`, read the output, then `./install.sh work`.
7. **Open Warp**, confirm mise activation and atuin history in a fresh session.
8. **mise** — `mise install`, then verify `node --version` reports 24.
9. **Clone the JS repos.** In `webawesome-app`, confirm mise auto-switches to 22.13.0, then `npm install && npm start`. This is the first real proof the machine works.
10. **devenv last** — clone `FortAwesome/devenv`, then `./dev -v`. Budget hours. It pulls a lot of images.

**Step 10 depends on OrbStack already being on PATH from step 6.** This is the highest-stakes ordering in the document; see Hazards.

## Hazards

**`hashicorp/tap` is Untrusted.** Homebrew now refuses to load casks from it:

> Refusing to load cask hashicorp-vagrant from untrusted tap hashicorp/tap

The current machine has the tap from before that policy landed, so it still works there and will look fine right up until a fresh `brew bundle` fails. The plain `vagrant` cask is healthy at **2.4.9** against devenv's required minimum of 2.4.1, so use it and do not tap hashicorp at all.

**devenv will install Docker Desktop if you let it.** `devenv-prereqs.sh` calls `install-docker.sh` when `command -v docker` fails *or* reports below `DOCKER_VERSION=26.0.0` from `versions.conf`. That script `curl`s a ~700MB DMG and `sudo cp`s Docker.app into `/Applications` — which is how Docker.app got onto the current machine. OrbStack's docker CLI reports 29.4.0, so the check passes and the installer never fires. **Install OrbStack before running `./dev`.**

**devenv cannot be dry-run in a VM or container.** `install-docker.sh` calls `check-virtualization.sh` and hard-exits on detection. Step 10 can only be validated on real hardware.

**OrbStack is not brew-managed on the current machine.** It was installed by hand, which is why `brew list --cask` never showed it. `Brewfile.work` fixes that going forward.

**Docker credentials are keychain-based, not Desktop-based.** `~/.docker/config.json` uses `credsStore: osxkeychain` for quay.io and ECR. Nothing in the auth path depends on Docker Desktop, which is why OrbStack has worked without anyone noticing the switch.

**devenv installs 1Password itself if missing.** Since 1Password is step 3, those checks pass silently. Harmless, worth knowing.

## Validating install.sh before the machine arrives

A fresh MacBook is the worst place to find out which parts of an untested script are wrong. This one has never run — `~/.zshrc` on the current machine is a regular file, not a symlink, and there is no `mise` binary.

Test in a throwaway macOS user account on the current machine:

1. System Settings → Users & Groups → add a standard user, `dotfilestest`.
2. Log in as that user. Homebrew is shared at `/opt/homebrew`, but the home directory is empty — which is exactly the condition being tested.
3. Clone the repo, run `./install.sh work --dry-run`, read every line.
4. Run `./install.sh work` for real. Fix what breaks, commit, re-run until a cold run is clean.
5. Verify: Warp opens a clean zsh session, `mise doctor` is clean, and `git config user.email` returns `hi.talbs@gmail.com` everywhere.
6. Log out, delete the account.

This exercises real Homebrew, real casks, and real macOS defaults. It cannot validate devenv — that needs the virtualization check to pass — but devenv self-installs its own prerequisites anyway, so it is the part least in need of rehearsal.

## Add on demand

Not installed on day one. Reach for it, then install it:

Dash, Postico or TablePlus, Raycast, CleanShot X, Rectangle, Fantastical, Obsidian, Firefox, Safari Technology Preview, Adobe Creative Cloud, ImageOptim, Gifski, Numi, xScope, Karabiner-Elements, Amphetamine, HazeOver, TopNotch, Cloudflare WARP.

Staying on the personal machine: Steam, Spotify, Amazon Music, Sonos, Sleeve, Paprika, Jooki, Flighty, Ivory, Pocket, qbittorrent, Hue Sync, Mirror for Roku, Discord, Basecamp.

Already dead, install nowhere: Fig, FontExplorer X Pro, Hyper, Thaw, Tunnelblick, MRUpdater, Kiro CLI.

## Success criteria

The machine is done when all of these are true:

- `git config user.email` returns `hi.talbs@gmail.com` in every repo, on both machines.
- A test commit succeeds and `git cat-file commit HEAD` contains an `SSH SIGNATURE` block.
- A commit in an FA repo shows Verified on GitHub and appears on the `talbs` contribution graph.
- `webawesome-app` starts on Node 22.13.0 without a version manager command being typed.
- `./dev -v` brings up devenv and `https://fa.test:4443` loads.
- `docker context show` returns `orbstack`, and `/Applications/Docker.app` does not exist.
- `./install.sh work` re-run on the finished machine changes nothing.
