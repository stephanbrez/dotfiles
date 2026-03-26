#  █████╗ ██╗     ██╗ █████╗ ███████╗███████╗███████╗
# ██╔══██╗██║     ██║██╔══██╗██╔════╝██╔════╝██╔════╝
# ███████║██║     ██║███████║███████╗█████╗  ███████╗
# ██╔══██║██║     ██║██╔══██║╚════██║██╔══╝  ╚════██║
# ██║  ██║███████╗██║██║  ██║███████║███████╗███████║
# ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
#
# lib/loader.zsh - Context-aware config loading utilities
#
# Helper functions for sourcing config files based on:
#   - OS type (linux, macos) - OPTIONAL
#   - Profile role (dev-server, laptop, workstation) - REQUIRED if set
#   - Hostname (machine-specific overrides) - OPTIONAL
#
# Usage:
#   source "$ZDOTDIR/lib/loader.zsh"
#   source_os_config "$ZDOTDIR/zshrc.d" ["-env"]
#   source_profile_config "$ZDOTDIR/aliases.d" ["-env"]
#   source_host_config "$ZDOTDIR/hosts" ["-env"]
#

# Source OS-specific config (10-*.zsh)
# Note: OS-specific configs are OPTIONAL; no warning if file doesn't exist.
# Looks for files matching: 10-linux<suffix>.zsh, 10-macos<suffix>.zsh
# Usage: source_os_config <directory> [suffix]
source_os_config() {
  local dir="$1" suffix="${2:-}"
  [[ -d "$dir" ]] || { echo "⚠️  loader.zsh: directory not found: $dir" >&2; return }
  case "$OSTYPE" in
    linux*)   [[ -r "$dir/10-linux${suffix}.zsh" ]] && source "$dir/10-linux${suffix}.zsh" ;;
    darwin*)  [[ -r "$dir/10-macos${suffix}.zsh" ]] && source "$dir/10-macos${suffix}.zsh" ;;
  esac
}

# Source profile-specific config (20-*.zsh)
# Note: Profile configs are REQUIRED when DOTFILES_PROFILE is set to a known profile.
# Looks for files matching: 20-dev-server<suffix>.zsh, 20-laptop<suffix>.zsh, etc.
# Usage: source_profile_config <directory> [suffix]
source_profile_config() {
  local dir="$1" suffix="${2:-}"
  local profile="${DOTFILES_PROFILE:-default}"
  [[ -d "$dir" ]] || { echo "⚠️  loader.zsh: directory not found: $dir" >&2; return }
  case "$profile" in
    dev-server)
      [[ -r "$dir/20-dev-server${suffix}.zsh" ]] && source "$dir/20-dev-server${suffix}.zsh" \
        || echo "⚠️  loader.zsh: skipping 20-dev-server${suffix}.zsh (not found in $dir)" >&2
      ;;
    laptop)
      [[ -r "$dir/20-laptop${suffix}.zsh" ]] && source "$dir/20-laptop${suffix}.zsh" \
        || echo "⚠️  loader.zsh: skipping 20-laptop${suffix}.zsh (not found in $dir)" >&2
      ;;
    workstation)
      [[ -r "$dir/20-workstation${suffix}.zsh" ]] && source "$dir/20-workstation${suffix}.zsh" \
        || echo "⚠️  loader.zsh: skipping 20-workstation${suffix}.zsh (not found in $dir)" >&2
      ;;
    default)
      # No profile-specific config for default - this is expected
      ;;
    *)
      echo "⚠️  loader.zsh: unknown profile '$profile' (expected: dev-server, laptop, workstation, default)" >&2
      ;;
  esac
}

# Source host-specific config
# Note: Host-specific configs are OPTIONAL; no warning if file doesn't exist.
# Looks for files matching: <hostname><suffix>.zsh
# Usage: source_host_config <directory> [suffix]
source_host_config() {
  local dir="$1" suffix="${2:-}"
  local host_short
  [[ -d "$dir" ]] || { echo "⚠️  loader.zsh: directory not found: $dir" >&2; return }
  host_short="$(hostname -s 2>/dev/null)"
  [[ -n "$host_short" && -r "$dir/${host_short}${suffix}.zsh" ]] && \
    source "$dir/${host_short}${suffix}.zsh"
}
