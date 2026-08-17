# Work machine setup — design

Date: 2026-08-17
Status: approved, ready for implementation planning

Setting up a fresh MacBook Pro as the work machine. The current Mac stays and becomes personal. Nothing is migrated with Migration Assistant — this is a cold build, and the dotfiles repo becomes the mechanism rather than a checklist that rots.

The repo currently assumes one personal machine. It grows a second profile instead of a second copy.

## Decisions

| Area | Decision | Why |
| --- | --- | --- |
| Runtime manager | mise, replacing asdf | asdf 0.14 here is the shell-script era. mise activates from `.tool-versions` automatically, which matters because runtime switching never appears in 4,669 commands of shell history — it should be invisible. |
| Terminal | Warp | Staying put. Already in daily use, and its blocks and command history are established workflow habit. Switching buys nothing the current setup lacks, and costs a migration plus new config to maintain. |
| Shell | plain zsh + atuin, no prompt framework | oh-my-zsh's git plugin ships 169 aliases. Measured usage of `gst`/`gco`/`gp`/`ga`/`gcm`/`gd`/`gl`: zero. Workflow is `lazygit` (787 uses) and raw `git` (403). The framework is pure startup cost. No starship either — Warp renders its own prompt, so a second prompt renderer is redundant work at every shell start. |
| Editor | VS Code | Cursor is retired on both machines, not just work. Claude Code becomes the primary AI coding surface. |
| Xcode | Command Line Tools only | Full Xcode is ~15GB and nothing here needs it. |
| Container runtime | OrbStack, no Docker Desktop | Already proven — the current machine runs devenv on OrbStack today. |
| Virtualization | Vagrant via the plain `vagrant` cask | `hashicorp/tap` is now flagged Untrusted by Homebrew and refuses to load. See Hazards. |
| Git identity | `includeIf` by directory | Fixes both machines with one file. Work identity applies inside FA and Shoelace checkouts regardless of which Mac they sit on. |
| Commit signing | New GPG key, work-only | Chosen. See Open decisions — the repo's `.gitconfig` already disagrees. |
| Apps | Minimum viable, add on demand | Only what blocks day-one work gets installed. Everything else waits until first reach. |
| Node package manager | npm | Every JS repo in play ships `package-lock.json`. Measured: npm 580, pnpm 0, bun 0, yarn 0. |

### Open decisions

**Commit signing conflicts with itself.** The decision above is a new GPG key. But `dotfiles/.gitconfig` in this repo already carries:

```
[gpg]
  format = ssh
[user]
  signingkey = /Users/brian/.ssh/id_ed25519_github
```

Both cannot ship. GPG keeps GPG Keychain, `pinentry-mac`, `GPG_TTY`, and key expiry; SSH signing drops all four and reuses the auth key already in 1Password. The spec below writes the GPG path because that was the call. Flipping to SSH is a two-line change in `git/identity.work` — do it before implementation, not after.

**pnpm in `CLAUDE.md`.** The global preferences file says "Use pnpm, not npm." In the FA and WA repos that is actively harmful — pnpm generates a competing lockfile alongside the committed `package-lock.json`. Recommend making that line project-conditional, or cutting it. Not blocking, but it will misdirect every Claude Code session on the new machine until it's fixed.

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

The only genuine difference between the two machines is the Brewfile. Identity is handled by `includeIf`, and the mise config is identical. A `profiles/` tree for one file would be ceremony, so the split is additive instead: work is base plus extras, never a separate copy.

```
dotfiles/
  install.sh              # ./install.sh work | personal
  Brewfile                # shared base
  Brewfile.work           # + vagrant, orbstack, awscli
  Brewfile.personal       # + personal-only casks
  git/
    gitconfig             # no user.email anywhere in it
    identity.work         # brian@awesome.me + work signing key
    identity.personal     # hi.talbs@gmail.com + DD06856FBC8F19D3
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

[includeIf "gitdir:~/Projects/FortAwesome/"]
  path = ~/.config/git/identity.work
[includeIf "gitdir:~/Projects/shoelace-style/"]
  path = ~/.config/git/identity.work
[includeIf "gitdir:~/Projects/talbs/"]
  path = ~/.config/git/identity.personal
```

Note `origin/main` in the `fixup` alias — the current version still says `origin/master`.

### git/identity.work

```ini
[user]
  name = Brian Talbot
  email = brian@awesome.me
  signingkey = <new-work-gpg-key-id>
[commit]
  gpgsign = true
```

### git/identity.personal

```ini
[user]
  name = Brian Talbot
  email = hi.talbs@gmail.com
  signingkey = DD06856FBC8F19D3
[commit]
  gpgsign = true
```

This one matters on the *current* machine too. It is signing FA commits as `hi.talbs@gmail.com` today, and it will still hold `FortAwesome/` checkouts after it becomes personal.

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
brew "gnupg"
brew "pinentry-mac"

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

`pinentry-mac` is here only because the GPG signing decision requires it. It leaves with a switch to SSH signing.

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
export GPG_TTY=$(tty)

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

1. Accept `work` or `personal` as `$1`. Exit with usage if absent — no default, because guessing wrong writes the wrong git identity.
2. Support `--dry-run`, printing every link and brew action without performing any.
3. Symlink shared files, backing up any existing non-symlink to `.backup` first.
4. Symlink `git/identity.<profile>` to `~/.config/git/identity.<profile>` — and only that one, so a work machine never carries the personal identity file.
5. Run `brew bundle --file Brewfile`, then `brew bundle --file Brewfile.<profile>`.
6. Be safe to re-run. Every step checks before acting.

Link map:

| Source | Destination |
| --- | --- |
| `git/gitconfig` | `~/.gitconfig` |
| `git/gitignore_global` | `~/.gitignore_global` |
| `git/identity.<profile>` | `~/.config/git/identity.<profile>` |
| `zsh/zshrc` | `~/.zshrc` |
| `zsh/{path,aliases,tools}.zsh` | `~/.config/zsh/` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `editorconfig` | `~/.editorconfig` |
| `prettierrc` | `~/.prettierrc` |

Note the VS Code destination — `Code/User/`, not `Cursor/User/` as the current script has it.

### Migrating the current repo layout

The restructure moves existing files rather than rewriting them. Use `git mv` so history follows.

| Now | Becomes |
| --- | --- |
| `.gitconfig` | `git/gitconfig`, with identity stripped out |
| `.gitignore_global` | `git/gitignore_global` |
| `.zshrc` | split into `zsh/{zshrc,path,aliases,tools}.zsh` |
| `.editorconfig` | `editorconfig` |
| `.prettierrc` | `prettierrc` |
| `CLAUDE.md` | `claude/CLAUDE.md` |
| `claude-settings.json` | `claude/settings.json` |
| `Brewfile` | `Brewfile` + `Brewfile.work`, split |

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
4. **SSH auth key** — generate ed25519, store in 1Password, add to GitHub. Test with `ssh -T git@github.com`.
5. **New work GPG key** — generate, upload the public key to GitHub, record the key ID in `git/identity.work`.
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
5. Verify: Warp opens a clean zsh session, `mise doctor` is clean, `git config user.email` is empty at `~` and `brian@awesome.me` inside a `~/Projects/FortAwesome/` checkout.
6. Log out, delete the account.

This exercises real Homebrew, real casks, and real macOS defaults. It cannot validate devenv — that needs the virtualization check to pass — but devenv self-installs its own prerequisites anyway, so it is the part least in need of rehearsal.

## Add on demand

Not installed on day one. Reach for it, then install it:

Dash, Postico or TablePlus, Raycast, CleanShot X, Rectangle, Fantastical, Obsidian, Firefox, Safari Technology Preview, Adobe Creative Cloud, ImageOptim, Gifski, Numi, xScope, Karabiner-Elements, Amphetamine, HazeOver, TopNotch, Cloudflare WARP.

Staying on the personal machine: Steam, Spotify, Amazon Music, Sonos, Sleeve, Paprika, Jooki, Flighty, Ivory, Pocket, qbittorrent, Hue Sync, Mirror for Roku, Discord, Basecamp.

Already dead, install nowhere: Fig, FontExplorer X Pro, Hyper, Thaw, Tunnelblick, MRUpdater, Kiro CLI.

## Success criteria

The machine is done when all of these are true:

- `git config user.email` returns nothing at `~`, `brian@awesome.me` inside `~/Projects/FortAwesome/`, and `hi.talbs@gmail.com` inside `~/Projects/talbs/`.
- A commit in an FA repo shows Verified on GitHub.
- `webawesome-app` starts on Node 22.13.0 without a version manager command being typed.
- `./dev -v` brings up devenv and `https://fa.test:4443` loads.
- `docker context show` returns `orbstack`, and `/Applications/Docker.app` does not exist.
- `./install.sh work` re-run on the finished machine changes nothing.
