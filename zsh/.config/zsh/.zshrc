# ███████╗███████╗██╗  ██╗██████╗  ██████╗
# ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#   ███╔╝ ███████╗███████║██████╔╝██║     
#  ███╔╝  ╚════██║██╔══██║██╔══██╗██║     
# ███████╗███████║██║  ██║██║  ██║╚██████╗
# ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#
# ZSHRC DISPATCH - Shell Configuration Entry Point
#
# ╔════════════════════════════════════════════════╗
# ║  ░█▄█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀█░█░░░█▀█░█▀▀░█░█  ║
# ║  ░█░█░█▀▀░░█░░█▀█░█░█░█░█░█░█░█░░░█░█░█░█░░█░  ║
# ║  ░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░  ║
# ╚════════════════════════════════════════════════╝
#
# DESIGN:
#   Sources configs in priority order:
#      - 00-base:      Universal settings (all machines)
#      - 10-<os>:     OS-specific (linux, macos)
#      - 20-<profile>: Role-specific (dev-server, laptop, workstation)
#      - hosts/<hostname>: Machine-specific overrides
#      - .zshrc.local: Local untracked overrides
#
# Directory structure:
#   zshrc.d/     - Shell behavior, plugins, keybinds
#   aliases.d/   - Command aliases
#   functions.d/ - Shell functions
#
# To add a new profile:
#   1. Create zshrc.d/20-<profile>.zsh
#   2. Create aliases.d/20-<profile>.zsh (optional)
#   3. Add case to lib/loader.zsh source_profile_config()
#
# To add a new OS:
#   1. Create zshrc.d/10-<os>.zsh
#   2. Create aliases.d/10-<os>.zsh (optional)
#   3. Create functions.d/10-<os>.zsh (optional)
#   4. Add case to lib/loader.zsh source_os_config()
#

# Load helper functions
source "$ZDOTDIR/lib/loader.zsh"

# ======== Shell Config ======== #
source "$ZDOTDIR/zshrc.d/00-base.zsh"
source_os_config "$ZDOTDIR/zshrc.d"
source_profile_config "$ZDOTDIR/zshrc.d"

# ======== Aliases ======== #
source "$ZDOTDIR/aliases.d/00-base.zsh"
source_os_config "$ZDOTDIR/aliases.d"
source_profile_config "$ZDOTDIR/aliases.d"

# ======== Functions ======== #
source "$ZDOTDIR/functions.d/00-base.zsh"
source_os_config "$ZDOTDIR/functions.d"

# ======== Host & Local Overrides ======== #
source_host_config "$ZDOTDIR/hosts"
[[ -r "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
