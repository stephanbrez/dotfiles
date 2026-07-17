# Dotfiles

- [Introduction](#introduction)
- [Organization](#organization)
  - [Home Directories](#home-directories)
  - [Dotfiles](#dotfiles)
- [XDG Compliance](#xdg-compliance)
- [Requirements](#requirements)
- [Installation](#installation)
- [Installer System](#installer-system)
  - [Command-Line Options](#command-line-options)
  - [Setup Stages](#setup-stages)
  - [Install Modes](#install-modes)
  - [Package Configuration](#package-configuration)
  - [Adding a Third-Party Installer](#adding-a-third-party-installer)
  - [Runtime Dependencies](#runtime-dependencies)
  - [When to Add a Separate `apt` Branch](#when-to-add-a-separate-apt-branch)
  - [npm-Based Fallback (brew + else)](#npm-based-fallback-brew--else)
  - [Exceptions](#exceptions)
- [Modular ZSH System](#modular-zsh-system)
  - [Entry Points](#entry-points)
  - [Priority Loading Order](#priority-loading-order)
  - [Profile Selection](#profile-selection)
  - [Directory Layout](#directory-layout)
  - [Extending](#extending)

## Introduction

This isn't trying to be _yet another collection of dotfiles_. Why? Through the
process of writing an install script I got tired of having to spin up a new
virtual machine to test each new version. I also wanted something that could
handle the diverse types of machines I use. This led to building a complete
system around three principles:

**Try before you buy** — Selectively adopt dotfiles per package via
[stowaway-check](bin/.local/bin/stowaway-check), an interactive wrapper around
[GNU stow](https://www.gnu.org/software/stow/) that handles conflict resolution,
backups, and batch operations.

**Machine-aware** — Installer config adapts to the machine it runs on. Package
installation differs by distro (Ubuntu, Debian, Fedora, macOS) and mode (minimal
vs full). Shell config adapts to OS and profile (dev-server, laptop,
workstation) with per-host overrides.

**Modular by design** — Every component is a composable unit: standalone
installer scripts, priority-loaded zsh snippets, and per-package stow
directories that mirror `$HOME`.

## Organization

### Home Directories

Follows
[XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
conventions:

```
~
├── .config/          $XDG_CONFIG_HOME → app configs
│   ├── nvim
│   ├── tmux
│   └── zsh           → modular zsh system
├── .dotfiles/        → this repo
├── .local/
│   ├── bin/          ~/.local/bin        → scripts (in $PATH)
│   ├── cache/        $XDG_CACHE_HOME     → runtime files
│   ├── docs/         → ~/Documents symlink
│   ├── lib/          → app libraries
│   ├── share/        $XDG_DATA_HOME      → shared app files
│   ├── src/          → cloned source repos
│   └── state/        $XDG_STATE_HOME     → app state
├── .ssh/
│   ├── authorized_keys
│   ├── config
│   └── known_hosts
├── .dotfiles.local   → untracked profile selection
└──  ▄█▀ ▀█▀ ▐▄█ █▀ █▀
```

### Dotfiles

Each app has a directory in `~/.dotfiles` mirroring the home directory
structure. Contents are symlinked into `~` on a per-package basis by
`stowaway-check`:

```
.dotfiles/
├── setup                    # Main install script (run with sudo)
├── packages.yaml            # Distro-aware package definitions
├── installers/              # Third-party installer scripts
├── bin/                     # → ~/.local/bin
├── zsh/                     # → ~/.config/zsh  (modular dispatch)
├── starship/                # → ~/.config/starship.toml
├── wezterm/                 # → ~/.config/wezterm
└── ...                      # app packages
```

## XDG Compliance

All tools are configured to respect XDG Base Directory variables set in
`zprofile.d/00-base-env.zsh`:

| Variable           | Path             | Tools affected                                         |
| ------------------ | ---------------- | ------------------------------------------------------ |
| `$XDG_CONFIG_HOME` | `~/.config`      | git, nvim, tmux, zsh, starship, ghostty, wezterm, yazi |
| `$XDG_DATA_HOME`   | `~/.local/share` | zinit, cargo, rustup, go, jupyter, conda/mamba         |
| `$XDG_CACHE_HOME`  | `~/.cache`       | zsh history, less history, python                      |

Tool-specific overrides: `CARGO_HOME`, `RUSTUP_HOME`, `GOPATH`,
`JUPYTER_CONFIG_DIR`, `LESSHISTFILE`, `PYTHON_HISTORY`.

## Requirements

- `git` — `sudo apt install git` or `brew install git`
- `stow` — `sudo apt install stow` or `brew install stow`

## Installation

```bash
cd ~
curl -LO https://raw.githubusercontent.com/stephanbrez/dotfiles/main/setup
chmod +x setup && sudo ./setup
```

Or clone manually:

```bash
git clone https://github.com/stephanbrez/dotfiles.git ~/.dotfiles
sudo ~/.dotfiles/setup
```

## Installer System

### Command-Line Options

```bash
sudo ./setup --help       # Show all options
sudo ./setup --dry-run    # Preview what would be done
sudo ./setup --verbose    # Show detailed output
sudo ./setup --yes        # Non-interactive mode (for CI/testing)
sudo ./setup --full       # Force full install on Ubuntu
```

### Setup Stages

The main `setup` script (run with `sudo`) proceeds in stages:

1. **Create XDG directories** — `~/.config`,
   `~/.local/{bin,cache,lib,share,src,state}`
2. **Bootstrap Python** — install python3 + PyYAML from system packages (never
   pip)
3. **Parse `packages.yaml`** — exports distro packages, pipx packages, and
   third-party flags as bash variables
4. **Install distro packages** — via `apt`, `dnf`, `pacman`, `zypper`, `apk`, or
   `brew`
5. **Run third-party installers** — from `installers/*.sh` based on YAML toggles
6. **Symlink dotfiles** — via `stowaway-check` with interactive conflict
   resolution
7. **Setup tmux** — install TPM plugins
8. **Configure git** — prompt for user.name and user.email
9. **Change shell** — `chsh` to zsh

> **macOS**: If Homebrew is not already installed, the installer automatically bootstraps
> it via the official install script and creates a symlink at
> `/usr/local/bin/brew` → `/opt/homebrew/bin/brew` on Apple Silicon so that
> `$ASME brew install ...` works through sudo.

> [Note] claude-code & codex share their target dirs with runtime content, so
> `setup` pre-creates `~/.local/share/{claude-code,codex}` and restows them
> with `--no-folding` after `stowaway-check` to keep shared dirs real and
> symlink only individual files.

### Install Modes

- **Minimal** (Ubuntu default) — distro packages only, no third-party installers
- **Full** (Debian / other distros / macOS, or `--full` flag) — distro packages
  - third-party

### Package Configuration

Packages are defined in `packages.yaml`. The tool handles distro-specific
sections and exports bash variables automatically:

```yaml
common:
    distro_packages:
        - bat
        - git
        - tmux
        - zsh
        - ripgrep
        - stow

ubuntu:
    minimal:
        distro_packages:
            - build-essential
            - python3-dev
        skip_third_party: true

    full:
        distro_packages:
            - build-essential
            - fd-find
        third_party:
            lazygit: true
            eza: true
            uv: true
            zoxide: true
        pipx_packages:
            - emoji-fzf

debian:
    full:
        third_party:
            docker: true
            neovim_source: true

macos:
    skip_common: true
    full:
        distro_packages:
            - bat
            - fzf
            - neovim
            - zsh
        third_party:
            docker: true
            eza: true
            wezterm: true
            zoxide: true
```

Each `third_party` key maps to an `install_<name>()` function via the
`PKG_THIRD_PARTY` array (enabled names are also exported as individual
`INSTALL_<NAME>=true` flags for backwards compatibility). Setting
`skip_third_party: true` skips all third-party installers for that mode. Setting
`skip_common: true` at the distro level skips the `common` package list — used
by `macos` since Homebrew package names and availability differ from Linux
distros.

### Adding a Third-Party Installer

1. **Create the installer script** `installers/<name>.sh`:

```bash
#!/bin/bash
# <name>.sh - Install <description>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_<name>() {
    if command -v <name> &>/dev/null; then
        log_message "INFO" "<name> already installed, skipping"
        return 0
    fi
    _echo "installing <name>"
    # Resolve runtime dependencies first (see Runtime Dependencies):
    # ensure_dep <dep> "pacman=<alt-name>" || return 1
    if should_run; then
        # Install commands here.
        # Use $ASME to run as the user (not root).
        $ASME curl -sSL https://example.com/install.sh | $ASME sh
        log_message "SUCCESS" "<name> installed"
    else
        dry_print "Would install <name>"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_<name>
    log_message "SUCCESS" "<name> installation complete" "true"
fi
```

**Every `install_<name>()` function must be idempotent** — check if the tool is
already installed (`command -v <cmd>`) and return early before `_echo` if so.
This prevents redundant reinstalls when `setup` is re-run and makes standalone
invocation safe to repeat. For tools without a single binary to check, use an
equivalent test (e.g. `[[ -d /path ]]` for font collections).

1. **Make it executable**:

```bash
chmod +x installers/<name>.sh
```

1. **Enable in `packages.yaml`**:

```yaml
third_party:
    <name>: true
```

The `setup` script sources every `installers/*.sh` and auto-discovers the
`install_<name>()` function from the YAML key — no editing of `setup` required.
Enabled names are exported as the `PKG_THIRD_PARTY` array (and, for backwards
compatibility, as individual `INSTALL_<NAME>=true` flags).

Available helpers from `installers/common.sh`:

- `parse_installer_args "$@"` — handles `--dry-run`, `--verbose`, `--help`
- `init_installer_env` — detects user context, architecture, package manager
- `should_run` — returns false in dry-run mode
- `dry_print` — prints what would be done
- `log_message` — structured logging (respects verbose mode)
- `$ASME` — run commands as the real user (via `sudo -u`)
- `$ARCH_GH` / `$ARCH_DEB` — architecture strings for GitHub releases and DEB
  packages
- `$pkgmgr` — detected package manager (`apt`, `dnf`, `pacman`, `zypper`, `apk`,
  `brew`)
- `ensure_dep <cmd> [overrides]` — install a runtime dependency via the native
  package manager if `<cmd>` isn't on `$PATH`. Use this for every dependency an
  installer needs. `overrides` is a space-separated list of `pkgmgr=pkgname`
  pairs for distros where the package name differs from the command (e.g.
  `"pacman=github-cli"`); unlisted distros fall back to `<cmd>`. The helper is a
  no-op if the command is already present and handles dry-run mode internally.

Installer scripts branch on `$pkgmgr` to support multiple distros. The standard
branching pattern is **`brew` + `else`** — a Homebrew branch for macOS and a
universal fallback for all Linux distros:

```bash
install_<name>() {
    _echo "installing <name>"
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install <name>      # or: brew install --cask <name>
            log_message "SUCCESS" "<name> installed via Homebrew"
        else
            dry_print "Would run: brew install <name>"
        fi
    else
        # Universal fallback for all Linux (curl script, GitHub binary, etc.)
        if should_run; then
            $ASME curl -sSL https://example.com/install.sh | $ASME sh
            log_message "SUCCESS" "<name> installed"
        else
            dry_print "Would install <name>"
        fi
    fi
}
```

Use this two-branch form when the Linux install method works on **all** distros
(curl install scripts, static GitHub release tarballs). Examples: `uv.sh`,
`zoxide.sh`, `lazygit.sh`, `lazydocker.sh`, `fzf_binary.sh`.

### Runtime Dependencies

**All installer scripts must resolve their own runtime dependencies.**
Installers run standalone (`sudo ./installers/<name>.sh`) as well as via the
main `setup` flow — in standalone mode, nothing else has been installed yet.
Never assume a tool (`gh`, `git`, `curl`, etc.) is already on `$PATH`.

Use `ensure_dep <cmd> [overrides]` at the top of `install_<name>()` for each
runtime dependency before any branching. The function no-ops if the command is
already present, installs it via the native package manager if not, and handles
dry-run mode internally.

```bash
install_<name>() {
    _echo "installing <name>"
    ensure_dep <dep1> "pacman=<alt-name>" || return 1
    ensure_dep <dep2> || return 1
    # ...then proceed with install branches...
}
```

Only list overrides for distros where the package name differs from the command;
unlisted distros use `<cmd>` as the package name. Examples:

- `ensure_dep gh "pacman=github-cli"` — `gh` on most distros, `github-cli` on
  Arch
- `ensure_dep fd "apt=fd-find dnf=fd-find brew=fd"` — varies across all three
- `ensure_dep ripgrep` — same name everywhere, no overrides needed

For complex tools that warrant a dedicated installer (e.g., Node.js), the
installer should be **idempotent** — check for an existing install and return
early. Callers source the installer and call it directly:

```bash
# Dist package dependency:
ensure_dep gh "pacman=github-cli" || return 1

# Complex tool with dedicated idempotent installer:
declare -f install_nodejs >/dev/null 2>&1 || source "$SCRIPT_DIR/nodejs.sh"
install_nodejs || return 1
```

Place `ensure_dep` / installer calls **outside** `should_run` blocks and follow
each with `|| return 1` to abort cleanly if the dependency can't be satisfied.
The helpers handle dry-run mode internally.

### When to Add a Separate `apt` Branch

Only add a dedicated `apt` branch when the install method is **apt-specific** —
it requires adding a third-party repository/PPA/GPG key or uses `dpkg` to
install a `.deb`. In that case use **`apt` + `brew` + `else`**:

```bash
install_<name>() {
    _echo "installing <name>"
    if [[ "$pkgmgr" == "apt" ]]; then
        if should_run; then
            # Add repo/GPG key, then apt install — or dpkg -i a downloaded .deb
            log_message "SUCCESS" "<name> installed"
        else
            dry_print "Would add <name> repository and install"
        fi
    elif [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install <name>
            log_message "SUCCESS" "<name> installed via Homebrew"
        else
            dry_print "Would run: brew install <name>"
        fi
    else
        log_message "WARNING" "<name> not configured for $pkgmgr" "true"
        log_message "INFO" "Try: $pkgmgr $pkginstall <name>" "true"
        return 1
    fi
}
```

Examples: `eza.sh`, `wezterm.sh`, `onepassword.sh` (add apt repos), `mise.sh`
(PPA + curl fallback), `fastfetch.sh` (`.deb` via `dpkg`), `neovim_source.sh`
(source build → `.deb` on apt, pre-built binary on other Linux).

Do **not** create an `apt` branch just to run `apt install <name>` when a
universal fallback (curl, GitHub binary) works on apt too — that's what `else`
is for.

### npm-Based Fallback (brew + else)

Use this two-branch form when a tool ships a Homebrew tap (covers macOS) and an
npm package for all other distros. The `else` branch sources the idempotent
`nodejs.sh` installer, calls `install_nodejs` to ensure npm is available, then
runs `$ASME npm install -g <pkg>`. Example: `ghui.sh`.

```bash
install_<name>() {
    _echo "installing <name>"
    ensure_dep <runtime-dep> "pacman=<alt>" || return 1
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install <user>/tap/<name>
            log_message "SUCCESS" "<name> installed via Homebrew tap"
        else
            dry_print "Would run: brew install <user>/tap/<name>"
        fi
    else
        # ─── npm fallback for all other distros ───
        declare -f install_nodejs >/dev/null 2>&1 || source "$SCRIPT_DIR/nodejs.sh"
        install_nodejs || return 1
        if should_run; then
            $ASME npm install -g <npm-pkg>
            log_message "SUCCESS" "<name> installed via npm"
        else
            dry_print "Would run: npm install -g <npm-pkg>"
        fi
    fi
}
```

`install_nodejs` is idempotent — it returns early if npm is already on `$PATH`,
so it's safe to call unconditionally. It also handles dry-run mode internally
(via its `should_run` check), so in dry-run the user sees both "Would install
Node.js" and "Would run: npm install -g <npm-pkg>".

### Exceptions

**macOS-only tools** (e.g., `aerospace.sh`) skip the `else` fallback and warn
instead:

```bash
if [[ "$pkgmgr" == "brew" ]]; then
    # brew install --cask <name>
else
    log_message "WARNING" "<name> is macOS-only, skipping for $DISTRO_ID" "true"
    return 1
fi
```

**Distro-neutral installers** don't branch on `$pkgmgr` at all — the method is
the same everywhere (git clone, symlink workaround, universal curl script with
XDG setup). Examples: `figlet-fonts.sh`, `bat.sh`, `fd.sh`, `pixi.sh`.

**Tools needing per-distro repos** (e.g., `docker.sh`) add a `dnf` branch
alongside `apt` — extend the pattern when a distro family needs its own repo
setup, but don't branch for distros that the universal `else` already covers.

## Modular ZSH System

Zsh configuration uses a **priority-layered dispatch system** with two entry
points, managed entirely through `lib/loader.zsh`.

### Entry Points

| File                                        | Purpose           | Sources                                             |
| ------------------------------------------- | ----------------- | --------------------------------------------------- |
| `~/.zprofile` (stowed from `zsh/`)          | Environment setup | `zprofile.d/` via loader                            |
| `~/.config/zsh/.zshrc` (stowed from `zsh/`) | Shell config      | `zshrc.d/`, `aliases.d/`, `functions.d/` via loader |

### Priority Loading Order

Config files are loaded in this order, each layer overriding the previous:

```
00-base          ─── Universal (all machines)
10-<os>          ─── OS-specific (linux, macos)
20-<profile>     ─── Role-specific (dev-server, laptop, workstation)
hosts/<hostname> ─── Per-machine overrides
.zshrc.local     ─── Local untracked overrides
```

### Profile Selection

Set your machine profile in the untracked `~/.dotfiles.local` file:

```bash
export DOTFILES_PROFILE="laptop"
```

💡: make sure that the quoted value matches the <profile> part of the file name.

Defaults to`default` (no profile-specific config) when unset.

The profile value is read in `.zprofile` before any config is loaded, so all
layers can respond to it.

### Directory Layout

```
~/.config/zsh/
├── .zshrc                    # Dispatch entry point
├── lib/
│   └── loader.zsh            # Context-aware sourcing: source_os_config,
│                             # source_profile_config, source_host_config
├── zprofile.d/               # Environment variables (loaded by .zprofile)
│   ├── 00-base-env.zsh       # XDG vars, tool paths, LESS/FZF config
│   ├── 10-linux-env.zsh      # CUDA, /opt/bin paths
│   ├── 10-macos-env.zsh      # (placeholder)
│   ├── 20-dev-server-env.zsh # (placeholder)
│   ├── 20-laptop-env.zsh     # (placeholder)
│   └── 20-workstation-env.zsh# (placeholder)
├── zshrc.d/                  # Shell behavior, plugins, keybinds
│   ├── 00-base.zsh           # zinit, history, completions, fzf,
│   │                         # starship, zoxide, uv, thefuck
│   ├── 10-linux.zsh          # fastfetch on login
│   ├── 10-macos.zsh          # (placeholder)
│   ├── 20-dev-server.zsh     # micromamba + pixi
│   ├── 20-laptop.zsh         # (placeholder)
│   └── 20-workstation.zsh    # (placeholder)
├── aliases.d/                # Modular aliases by OS + profile
│   ├── 00-base.zsh           # eza, docker, git, conda, uv,
│   │                         # wezterm, lazygit, pixi (553 lines)
│   ├── 10-linux.zsh          # apt update aliases
│   ├── 10-macos.zsh          # brew update aliases
│   ├── 20-dev-server.zsh     # (placeholder)
│   ├── 20-laptop.zsh         # (placeholder)
│   └── 20-workstation.zsh    # (placeholder)
├── functions.d/              # Modular functions by OS
│   ├── 00-base.zsh           # extract, mcd, y(), uvpyk, find_man
│   ├── 10-linux.zsh          # (placeholder)
│   └── 10-macos.zsh          # (placeholder)
├── hosts/                    # Per-machine overrides (<hostname>.zsh)
├── plugins/
│   └── plugins.zsh           # Local plugin loader stub
└── starship.zsh              # (reserved for starship config)
```

### Extending

```bash
# Add OS support:
touch zshrc.d/10-<os>.zsh
touch aliases.d/10-<os>.zsh
# Then add a case to lib/loader.zsh source_os_config()

# Add a profile:
touch zshrc.d/20-<profile>.zsh
touch aliases.d/20-<profile>.zsh
touch zprofile.d/20-<profile>-env.zsh
# Then add a case to lib/loader.zsh source_profile_config()

# Machine-specific override (no loader changes needed):
touch hosts/$(hostname -s).zsh
```

Plugin management is handled by
[zinit](https://github.com/zdharma-continuum/zinit) (installed automatically to
`$XDG_DATA_HOME/zinit` on first shell start). The `00-base.zsh` config loads
syntax highlighting, autosuggestions, completions, vi-mode, git aliases, and
Starship via zinit's turbo loader.
