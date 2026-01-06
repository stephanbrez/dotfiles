# Dotfiles

- [Dotfiles](#dotfiles)
  - [Introduction](#introduction)
    - [Try Before you Buy](#try-before-you-buy)
    - [Machine Specific Config](#machine-specific-config)
  - [Organization](#organization)
    - [Home Directories](#home-directories)
    - [Dotfiles](#dotfiles-1)
    - [Installers](#installers)
  - [Package Configuration](#package-configuration)
    - [YAML Configuration](#yaml-configuration)
    - [Adding a Third-Party Installer](#adding-a-third-party-installer)
  - [Requirements](#requirements)
    - [Git](#git)
    - [Stow](#stow)
  - [Installation](#installation)
    - [Install Script](#install-script)
    - [Manual Install](#manual-install)

## Introduction

This isn't trying to be _yet another collection of dotfiles_. Why? Through the process of writing an install script I got tired of having to spin up a new virtual machine to test each new version. This led to the following two major features (laziness: the true driver of innovation):

### Try Before you Buy

With the use of [_Stowaway Dots_](https://github.com/stephanbrez/dotfiles/blob/main/bin/.local/bin/stowaway-check) (a wrapper for [stow](https://www.gnu.org/software/stow/)), you can selectively use, backup, and adopt dotfiles on a package by package basis. This means you can try these (or any) dotfiles before committing to them, before or after forking this repo. _e.g._ Changed your mind about a specific package? Run the installer again and re-do the dotfiles setup. It's also really useful if you have several machines and only want to use some packages and dotfiles on certain ones (see below).

### Machine Specific Config

Don't want to install packages & apps on your machine? No problem, you can only install dotfiles.
Have more than one machine (like a desktop & laptop)? You can select separate package install configs.

**Other useful ideas & concepts**
There are a lot of great dotfiles managers and solutions out there. A lot of them unfortunately force you to use their naming scheme/file structure/methodology. Dotfiles are very personal, and you may have already spent a lot time organizing them how you want. If you're going to use this repo (isn't that the point of public repos?), wouldn't it be nice if it required minimal changes on your part? It would also be convenient if personalization only had to be done in one file wouldn't it? _Or better yet, wouldn't it be great if the installer was interactive so you didn't have to figure out how to make changes?_

## Methodology

### Organization

#### Home Directories

Following [xdg base directories standards](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

```
.
├── .config/ $XDG_CONFIG_HOME --> app specific configs
│   ├── nvim
│   ├── tmux
│   ├── zsh       --> each app has a folder
│   │   └── zshrc --> config files
│   └── etc...
├── .dotfiles/   --> this repo
├── .local/
│   ├── bin/   $PATH            --> my scripts
│   ├── cache/ $XDG_CACHE_HOME  --> runtime files
│   ├── docs/  ~docs            --> my documents
│   ├── lib/   $pkgManger_HOME  --> app libraries
│   ├── share/ $XDG_DATA_HOME   --> shared app files
│   ├── src/
│   │   └── other_code/
│   └── state/ $XDG_STATE_HOME  --> app state files
│       └── zsh/
│           └── history --> app created files
├── .ssh/
│   ├── authorized_keys
│   ├── config
│   └── known_hosts
└──  ▄█▀ ▀█▀ ▐▄█ █▀ █▀
```

#### Dotfiles

To make it easier to install and configure apps individually, each app has a folder in `~/.dotfiles`. The structure mirrors the home directory structure. The contents then can be symlinked to the proper location in `~` on an app by app basis.

```
.dotfiles/
├── README.md
├── packages.yaml           --> package configuration
├── setup                   --> main install script
├── installers/             --> third-party installer scripts
├── starship/               --> app folder
│   └── .config
│       └── starship.toml   --> symlinked to ~/.config
└── tmux/
    └── .config
        └── tmux            --> symlinked to ~/.config
            └── tmux.conf   --> config files
```

#### Installers

Third-party packages that require special installation (repos, GPG keys, building from source) are handled by modular installer scripts in `installers/`:

```
installers/
├── common.sh             # Shared helper functions (sourced by all)
├── packages-fallback.sh  # Fallback package lists when YAML unavailable
├── docker.sh             # Docker from official repo
├── eza.sh                # eza (modern ls)
├── fastfetch.sh          # System info tool
├── figlet-fonts.sh       # Figlet font collection
├── fzf.sh                # Fuzzy finder binary
├── lazydocker.sh         # Docker TUI
├── lazygit.sh            # Git TUI
├── neovim.sh             # Neovim from source (apt only)
├── onepassword.sh        # 1Password + CLI
├── uv.sh                 # uv Python package manager
├── wezterm.sh            # WezTerm terminal
└── zoxide.sh             # Smarter cd command
```

Each installer can be run standalone or via the main setup script:

```bash
# Run a single installer
sudo ./installers/docker.sh

# Preview what would be installed
sudo ./installers/docker.sh --dry-run

# Verbose output
sudo ./installers/eza.sh --verbose
```

## Package Configuration

### YAML Configuration

Packages are configured in `packages.yaml`. The file supports:

- **Common packages**: Installed on all distros
- **Distro-specific packages**: Ubuntu, Debian, Fedora variants
- **Installation modes**: `minimal` (no third-party) or `full`
- **Third-party toggles**: Enable/disable individual installers

Example structure:

```yaml
common:
  distro_packages:
    - git
    - tmux
    - zsh

ubuntu:
  full:
    distro_packages:
      - build-essential
    third_party:
      docker: true
      lazygit: true
      uv: true
```

### Adding a Third-Party Installer

1. **Create the installer script** `installers/<name>.sh`:

```bash
#!/bin/bash
# <name>.sh - Install <description>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_<name>() {
    _echo "installing <name>"
    if should_run; then
        # Your install commands here
        # Use $ASME to run as the user (not root)
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

2. **Make it executable**:

```bash
chmod +x installers/<name>.sh
```

3. **Add the trigger in `setup`** (search for `INSTALL_ZOXIDE`):

```bash
[[ "$INSTALL_<NAME>" == "true" ]] && install_<name>
```

4. **Enable in `packages.yaml`**:

```yaml
third_party:
  <name>: true
```

The YAML parser automatically exports `<name>: true` as `INSTALL_<NAME>=true`.

## Requirements

At the bare minimum you'll need these to install dotfiles:

### Git

```
brew install git
```

or

```
sudo apt install git
```

### Stow

```
brew install stow
```

or

```
sudo apt install stow
```

## Installation

You can use the interactive install script, or if you're feeling a little masochistic, you can do a manual install.

### Install Script

Automate the setup of your dotfiles with this handy script!

Manually download the script from [here](https://github.com/stephanbrez/dotfiles/blob/main/setup) or run the commands below in your favorite terminal.

You'll need curl for the fully automated setup:
`apt install curl` or `dnf install curl` or `pacman -S curl` or `brew install curl`

First download the script into your **home**:

```
cd ~
curl -LO https://raw.githubusercontent.com/stephanbrez/dotfiles/main/setup
```

Check the script if you want to doublecheck everything (you should never trust explicitly!):

```
less setup
```

Make it executable and then run it _with sudo_:

```
chmod +x setup && sudo ./setup
```

**Command-line options:**

```
sudo ./setup --help       # Show all options
sudo ./setup --dry-run    # Preview what would be done
sudo ./setup --verbose    # Show detailed output
sudo ./setup --yes        # Non-interactive mode (for CI)
sudo ./setup --full       # Force full install on Ubuntu (default is minimal)
```

If you want to have an installation log to review afterwards pipe to a tee to the previous command:

```
chmod +x setup && sudo ./setup | tee setup_dots.log
```

### Manual Install

Check out the [dotfiles repo](https://github.com/stephanbrez/dotfiles)

```
git clone https://github.com/stephanbrez/dotfiles.git
cd ~/.dotfiles
```

Use `stow` to symlink all the files

```
stow . -t ~ --adopt
```

The adopt flag will overwrite all files in `~/.dotfiles` with any matching files in `~`. To restore the files from the remote repo, run:

```
git restore .
```
