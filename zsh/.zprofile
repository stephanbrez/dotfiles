# ███████╗██████╗ ██████╗  ██████╗ ███████╗██╗██╗     ███████╗
# ╚══███╔╝██╔══██╗██╔══██╗██╔═══██╗██╔════╝██║██║     ██╔════╝
#   ███╔╝ ██████╔╝██████╔╝██║   ██║█████╗  ██║██║     █████╗  
#  ███╔╝  ██╔═══╝ ██╔══██╗██║   ██║██╔══╝  ██║██║     ██╔══╝  
# ███████╗██║     ██║  ██║╚██████╔╝██║     ██║███████╗███████╗
# ╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚══════╝
#
# ZPROFILE DISPATCH - Environment Variables Entry Point
#
# ╔════════════════════════════════════════════════╗
# ║  ░█▄█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀█░█░░░█▀█░█▀▀░█░█  ║
# ║  ░█░█░█▀▀░░█░░█▀█░█░█░█░█░█░█░█░░░█░█░█░█░░█░  ║
# ║  ░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░  ║
# ╚════════════════════════════════════════════════╝
#
# DESIGN:
#   1. Set ZDOTDIR to point zsh at ~/.config/zsh
#   2. Load ~/.dotfiles.local for machine-local profile selection
#   3. Source configs in priority order:
#      - 00-base:      Universal settings (all machines)
#      - 10-<os>:     OS-specific (linux, macos)
#      - 20-<profile>: Role-specific (dev-server, laptop, workstation)
#      - hosts/<hostname>-env: Machine-specific overrides
#
# To add a new profile:
#   1. Create zprofile.d/20-<profile>-env.zsh
#   2. Add case to lib/loader.zsh source_profile_config()
#
# To add a new OS:
#   1. Create zprofile.d/10-<os>-env.zsh
#   2. Add case to lib/loader.zsh source_os_config()
#

# Point zsh at the repo-managed config directory.
export ZDOTDIR="$HOME/.config/zsh"

# Load machine-local overrides/profile selection.
# This file is not tracked in git.
[[ -r "$HOME/.dotfiles.local" ]] && source "$HOME/.dotfiles.local"

# Sane default if DOTFILES_PROFILE is unset
: ${DOTFILES_PROFILE:=default}
export DOTFILES_PROFILE

# Load helper functions
source "$ZDOTDIR/lib/loader.zsh"

# Source configs in priority order
source "$ZDOTDIR/zprofile.d/00-base-env.zsh"
source_os_config "$ZDOTDIR/zprofile.d" "-env"
source_profile_config "$ZDOTDIR/zprofile.d" "-env"
source_host_config "$ZDOTDIR/hosts" "-env"
