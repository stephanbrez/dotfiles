#
# lib/loader.zsh - Context-aware config loading utilities
#
# Helper functions for sourcing config files based on:
#   - OS type (linux, macos)
#   - Profile role (dev-server, laptop, workstation)
#   - Hostname (machine-specific overrides)
#
# Usage:
#   source "$ZDOTDIR/lib/loader.zsh"
#   source_os_config "$ZDOTDIR/zshrc.d"
#   source_profile_config "$ZDOTDIR/aliases.d"
#   source_host_config "$ZDOTDIR/hosts" "-env"
#

# Source OS-specific config (10-*.zsh)
# Looks for files matching: 10-linux.zsh, 10-macos.zsh
# Usage: source_os_config <directory>
source_os_config() {
  local dir="$1"
  case "$OSTYPE" in
    linux*)   [[ -r "$dir/10-linux.zsh" ]] && source "$dir/10-linux.zsh" ;;
    darwin*)  [[ -r "$dir/10-macos.zsh" ]] && source "$dir/10-macos.zsh" ;;
  esac
}

# Source profile-specific config (20-*.zsh)
# Looks for files matching: 20-dev-server.zsh, 20-laptop.zsh, 20-workstation.zsh
# Usage: source_profile_config <directory>
source_profile_config() {
  local dir="$1"
  case "${DOTFILES_PROFILE:-default}" in
    dev-server)   [[ -r "$dir/20-dev-server.zsh" ]] && source "$dir/20-dev-server.zsh" ;;
    laptop)       [[ -r "$dir/20-laptop.zsh" ]] && source "$dir/20-laptop.zsh" ;;
    workstation)  [[ -r "$dir/20-workstation.zsh" ]] && source "$dir/20-workstation.zsh" ;;
  esac
}

# Source host-specific config
# Looks for files matching: <hostname>.zsh or <hostname><suffix>.zsh
# Usage: source_host_config <directory> [suffix]
source_host_config() {
  local dir="$1" suffix="${2:-}"
  local host_short
  host_short="$(hostname -s 2>/dev/null)"
  [[ -n "$host_short" && -r "$dir/${host_short}${suffix}.zsh" ]] && \
    source "$dir/${host_short}${suffix}.zsh"
}
