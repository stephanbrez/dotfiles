# ZSH Configuration System

A machine-aware, modular zsh configuration system that supports multiple OS types, deployment profiles, and host-specific overrides.

## Overview

This system uses a dispatch-based architecture to load configuration files in a prioritized order:

1. **Base configs** - Universal settings for all machines
2. **OS-specific configs** - Settings for Linux or macOS
3. **Profile-specific configs** - Settings for machine roles (dev-server, laptop, workstation)
4. **Host-specific configs** - Per-machine overrides
5. **Local overrides** - Untracked local customizations

## Quick Start

The entry points are:
- `~/.zprofile` - Environment variables (sourced first)
- `~/.config/zsh/.zshrc` - Shell configuration (sourced second)

Set your profile in `~/.dotfiles.local`:
```sh
export DOTFILES_PROFILE=laptop
```

## Directory Structure

```
zsh/
├── .zprofile                    # Entry point - environment variables
├── README.md                    # This file
└── .config/zsh/
    ├── .zshrc                   # Entry point - shell configuration
    ├── lib/
    │   └── loader.zsh           # Context-aware loading utilities
    ├── zprofile.d/              # Environment configs
    │   ├── 00-base-env.zsh     # Universal environment
    │   ├── 10-linux-env.zsh    # Linux-specific env
    │   ├── 10-macos-env.zsh    # macOS-specific env
    │   ├── 20-dev-server-env.zsh
    │   ├── 20-laptop-env.zsh
    │   └── 20-workstation-env.zsh
    ├── zshrc.d/                 # Shell behavior configs
    │   ├── 00-base.zsh         # Keybinds, history, zinit, completions
    │   ├── 10-linux.zsh       # Linux-specific (fastfetch)
    │   ├── 10-macos.zsh
    │   ├── 20-dev-server.zsh
    │   ├── 20-laptop.zsh
    │   └── 20-workstation.zsh
    ├── aliases.d/               # Command aliases
    │   ├── 00-base.zsh         # All tool aliases
    │   ├── 10-linux.zsh        # apt, update
    │   ├── 10-macos.zsh        # brew, update
    │   └── 20-*.zsh            # Profile-specific aliases
    ├── functions.d/             # Shell functions
    │   ├── 00-base.zsh         # extract, mcd, yazi, uvpyk
    │   ├── 10-linux.zsh
    │   └── 10-macos.zsh
    ├── hosts/                   # Host-specific overrides
    │   └── <hostname>.zsh      # Machine-specific config
    └── .zshrc.local            # Local untracked overrides (gitignored)
```

## File Naming Convention

Files are loaded in numeric order within each directory:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `00-` | Base/universal | `00-base.zsh`, `00-base-env.zsh` |
| `10-` | OS-specific | `10-linux.zsh`, `10-macos.zsh` |
| `20-` | Profile-specific | `20-laptop.zsh`, `20-dev-server.zsh` |

**Suffix convention:**
- `*-env.zsh` - Environment variable files (in `zprofile.d/`)
- `*.zsh` - Shell config files (in `zshrc.d/`, `aliases.d/`, `functions.d/`)

## Profiles

Available profiles:

| Profile | Description |
|---------|-------------|
| `default` | No profile-specific config loaded |
| `dev-server` | Development server settings |
| `laptop` | Laptop-specific settings |
| `workstation` | Workstation/desktop settings |

Set via `~/.dotfiles.local`:
```sh
export DOTFILES_PROFILE=laptop
```

## Loader Functions

The `lib/loader.zsh` file provides context-aware loading utilities:

### `source_os_config <directory> [suffix]`

Sources OS-specific config files (`10-linux*.zsh`, `10-macos*.zsh`).

- **Optional**: No warning if file doesn't exist
- **Warns**: If directory doesn't exist

```zsh
source_os_config "$ZDOTDIR/zshrc.d"           # Looks for 10-linux.zsh
source_os_config "$ZDOTDIR/zprofile.d" "-env" # Looks for 10-linux-env.zsh
```

### `source_profile_config <directory> [suffix]`

Sources profile-specific config files (`20-<profile>*.zsh`).

- **Required**: Warns if profile is set but file doesn't exist
- **Warns**: If directory doesn't exist
- **Warns**: If profile is unknown (typo protection)

```zsh
source_profile_config "$ZDOTDIR/zshrc.d"           # Looks for 20-laptop.zsh
source_profile_config "$ZDOTDIR/zprofile.d" "-env" # Looks for 20-laptop-env.zsh
```

### `source_host_config <directory> [suffix]`

Sources host-specific config files (`<hostname>*.zsh`).

- **Optional**: No warning if file doesn't exist
- **Warns**: If directory doesn't exist

```zsh
source_host_config "$ZDOTDIR/hosts"      # Looks for <hostname>.zsh
source_host_config "$ZDOTDIR/hosts" "-env" # Looks for <hostname>-env.zsh
```

## Adding New Configurations

### Add a New Profile

1. Create environment file:
   ```sh
   touch .config/zsh/zprofile.d/20-myprofile-env.zsh
   ```

2. Create shell config files (as needed):
   ```sh
   touch .config/zsh/zshrc.d/20-myprofile.zsh
   touch .config/zsh/aliases.d/20-myprofile.zsh
   touch .config/zsh/functions.d/20-myprofile.zsh
   ```

3. Add to `lib/loader.zsh` in `source_profile_config()`:
   ```zsh
   myprofile)
     [[ -r "$dir/20-myprofile${suffix}.zsh" ]] && source "$dir/20-myprofile${suffix}.zsh" \
       || echo "⚠️  loader.zsh: skipping 20-myprofile${suffix}.zsh (not found in $dir)" >&2
     ;;
   ```

### Add a New OS

1. Create environment file:
   ```sh
   touch .config/zsh/zprofile.d/10-freebsd-env.zsh
   ```

2. Create shell config files (as needed):
   ```sh
   touch .config/zsh/zshrc.d/10-freebsd.zsh
   touch .config/zsh/aliases.d/10-freebsd.zsh
   touch .config/zsh/functions.d/10-freebsd.zsh
   ```

3. Add to `lib/loader.zsh` in `source_os_config()`:
   ```zsh
   freebsd*)
     [[ -r "$dir/10-freebsd${suffix}.zsh" ]] && source "$dir/10-freebsd${suffix}.zsh"
     ;;
   ```

### Add Host-Specific Config

Just create a file named after your hostname:

```sh
# For a machine named "myserver"
touch .config/zsh/hosts/myserver.zsh
touch .config/zsh/hosts/myserver-env.zsh
```

No changes to `loader.zsh` needed - host configs are auto-discovered.

## Local Overrides

For machine-specific settings that shouldn't be tracked in git:

1. `~/.dotfiles.local` - Set `DOTFILES_PROFILE` and other machine-local vars
2. `~/.config/zsh/.zshrc.local` - Local shell customizations

Both files are gitignored.

## Warnings

The loader provides helpful warnings:

| Scenario | Warning |
|----------|---------|
| Directory not found | `⚠️  loader.zsh: directory not found: /path` |
| Profile file missing | `⚠️  loader.zsh: skipping 20-laptop.zsh (not found in /path)` |
| Unknown profile | `⚠️  loader.zsh: unknown profile 'foo' (expected: dev-server, laptop, workstation, default)` |

OS and host configs are optional - no warning if missing.

## Migration from Old System

If migrating from a monolithic `.zshrc`:

1. Move environment variables to `zprofile.d/00-base-env.zsh`
2. Move shell settings to `zshrc.d/00-base.zsh`
3. Move aliases to `aliases.d/00-base.zsh`
4. Move functions to `functions.d/00-base.zsh`
5. Extract OS-specific parts to `10-*.zsh` files
6. Extract profile-specific parts to `20-*.zsh` files

## Dependencies

The base config uses:
- [zinit](https://github.com/zdharma-continuum/zinit) - Plugin manager
- [starship](https://starship.rs/) - Prompt
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smart cd
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [eza](https://github.com/eza-community/eza) - Modern ls
- [bat](https://github.com/sharkdp/bat) - Modern cat

Install via your package manager or let zinit handle some automatically.
