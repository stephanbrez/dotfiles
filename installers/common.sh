#!/bin/bash
# common.sh - Shared library for installer scripts
# Source this file to get helper functions and environment setup

# ═════ Guard against multiple sourcing ═════
[[ -n "$_INSTALLER_COMMON_LOADED" ]] && return 0
_INSTALLER_COMMON_LOADED=1

# ═════ Default values ═════
verbose_mode=${verbose_mode:-false}
dry_run=${dry_run:-false}

# ═════ Helper Functions ═════
_echo() {
    printf "\n╓───── %s \n╙────────────────────────────────────── ─ ─ \n" "$1"
}

user() {
    printf "\r  [ \033[33m??\033[0m ] %s" "$1"
}

fail() {
    printf "\r\033[2K  [ \033[01;31mFAIL\033[0m ] %s\n" "$1"
    echo ''
    exit 1
}

dry_print() {
    printf "  [ \033[36mDRY\033[0m ] %s\n" "$1"
}

should_run() {
    ! $dry_run
}

log_message() {
    local message_type=$1
    local message=$2
    local force=${3:-false}
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    if $verbose_mode || [[ "$force" == "true" ]]; then
        case $message_type in
        DEBUG) printf "  [ \033[36mDebug\033[0m ][%s] %s\n" "$timestamp" "$message" ;;
        INFO) printf "[ \033[34m>>\033[0m ] %s\n" "$message" ;;
        WARNING) printf "[\033[1;31m !!! \033[0m][%s] %s\n" "$timestamp" "$message" ;;
        SUCCESS) printf "\033[2K  [ \033[32mOK\033[0m ] %s\n" "$message" ;;
        *) printf "[UNKNOWN][%s] %s\n" "$timestamp" "$message" ;;
        esac
    fi
}

# ═════ Architecture Detection ═════
detect_architecture() {
    ARCH=$(uname -m)
    case "$ARCH" in
    x86_64) ARCH_DEB="amd64" ARCH_GH="x86_64" ;;
    aarch64) ARCH_DEB="arm64" ARCH_GH="arm64" ;;
    armv7l) ARCH_DEB="armhf" ARCH_GH="armv7" ;;
    *) ARCH_DEB="$ARCH" ARCH_GH="$ARCH" ;;
    esac
    export ARCH ARCH_DEB ARCH_GH
}

# ═════ Homebrew Bootstrap ═════
bootstrap_brew() {
    command -v brew &>/dev/null && return 0
    [[ "$(uname)" != "Darwin" ]] && return 1

    _echo "bootstrapping Homebrew"
    if should_run; then
        log_message "INFO" "Installing Homebrew..." "true"
        # Don't force NONINTERACTIVE=1: bootstrap_brew only runs on macOS (see
        # guard above), where `sudo ./setup` is always run from an attended
        # terminal. The Homebrew installer auto-detects interactivity from the
        # TTY and $CI env var — forcing NONINTERACTIVE makes its sudo check
        # use `sudo -n`, which fails hard if $SUDO_USER's timestamp isn't live.
        if [ -n "$SUDO_USER" ]; then
            sudo -u "$SUDO_USER" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # Make brew available in the current shell session
        local brew_path=""
        if [[ -x /opt/homebrew/bin/brew ]]; then
            brew_path="/opt/homebrew/bin/brew"
        elif [[ -x /usr/local/bin/brew ]]; then
            brew_path="/usr/local/bin/brew"
        fi

        if [[ -z "$brew_path" ]]; then
            fail "Homebrew binary not found after installation"
        fi

        eval "$("$brew_path" shellenv)"

        command -v brew &>/dev/null && log_message "SUCCESS" "Homebrew installed" || fail "Homebrew installation failed"
    else
        dry_print "Would install Homebrew via official installer"
    fi
}

# ═════ Package Manager Detection ═════
detect_package_manager() {
    if [ -x "$(command -v apk)" ]; then
        pkgmgr="apk"
        pkginstall="add --no-cache"
        pkgupdate="update"
    elif [ -x "$(command -v brew)" ]; then
        pkgmgr="brew"
        pkginstall="install"
        pkgupdate="update"
        DISTRO_ID="macos"
    elif [[ "$(uname)" == "Darwin" ]]; then
        # macOS without Homebrew on PATH — don't auto-bootstrap. Standalone
        # installers should never force the user to run ./setup. Check standard
        # install locations and give a targeted error with the eval or install
        # command.
        local brew_prefix=""
        [[ -x /opt/homebrew/bin/brew ]] && brew_prefix="/opt/homebrew"
        [[ -x /usr/local/bin/brew ]] && brew_prefix="/usr/local"
        if [[ -n "$brew_prefix" ]]; then
            fail "Homebrew is installed at $brew_prefix but not on PATH.
Run: eval \"\$($brew_prefix/bin/brew shellenv)\""
        else
            fail "Homebrew not found. Install it:
  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
Then add to PATH: eval \"\$(/opt/homebrew/bin/brew shellenv)\""
        fi
    elif [ -x "$(command -v apt)" ]; then
        pkgmgr="apt"
        pkginstall="install -y"
        pkgupdate="update"
        # ─── Detect Debian vs Ubuntu ───
        if [ -f /etc/os-release ]; then
            DISTRO_ID=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
            DISTRO_VERSION=$(grep "^VERSION_ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
        else
            DISTRO_ID="debian"
            DISTRO_VERSION="unknown"
        fi
    elif [ -x "$(command -v dnf)" ]; then
        pkgmgr="dnf"
        pkginstall="install -y"
        pkgupdate="update"
        DISTRO_ID="fedora"
    elif [ -x "$(command -v pacman)" ]; then
        pkgmgr="pacman"
        pkginstall="-S --noconfirm"
        pkgupdate="-Syu"
        DISTRO_ID="arch"
    elif [ -x "$(command -v zypper)" ]; then
        pkgmgr="zypper"
        pkginstall="install -y"
        pkgupdate="refresh"
        DISTRO_ID="opensuse"
    else
        log_message "WARNING" "Package manager not found" "true"
        pkgmgr=""
    fi
    export pkgmgr pkginstall pkgupdate DISTRO_ID DISTRO_VERSION
}

# ═════ User/Permission Detection ═════
detect_user_context() {
    if [ "$EUID" -ne 0 ]; then
        fail "This script must be run with sudo\nUsage: sudo $0"
    fi

    if [ -n "$SUDO_USER" ]; then
        me="$SUDO_USER"
        myhome=$(eval echo "~$SUDO_USER")
    else
        if [ -f /.dockerenv ] || [ -n "$CI" ]; then
            me="root"
            myhome="/root"
        else
            fail "Running as raw root is not supported\nPlease run with sudo as a regular user"
        fi
    fi

    ASME="sudo -u $me"
    # On macOS with Homebrew, include brew's bin in PATH so $ASME brew works
    # through sudo's secure_path (which doesn't include /opt/homebrew/bin on
    # Apple Silicon). Without this, sudo -u resets PATH and brew isn't found.
    if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
        local brew_bin
        brew_bin="$(brew --prefix)/bin"
        ASME="sudo -u $me env PATH=$brew_bin:/usr/bin:/bin:/usr/sbin:/sbin"
    fi
    export me myhome ASME
}

# ═════ Argument Parsing for Standalone Installers ═════
show_installer_help() {
    local script_name="${1:-installer}"
    cat <<-EOF
		Usage: sudo $script_name [OPTIONS]

		Options:
		  -v, --verbose    Verbose mode - show detailed output
		  -n, --dry-run    Dry-run mode - preview commands without executing
		  -h, --help       Show this help message

		Examples:
		  sudo $script_name              Run installation
		  sudo $script_name --dry-run    Preview what would be done
		  sudo $script_name -v           Run with verbose output
	EOF
    exit 0
}

parse_installer_args() {
    local script_name="${0##*/}"
    while getopts "vnh-:" option; do
        case $option in
        v) verbose_mode=true ;;
        n) dry_run=true ;;
        h) show_installer_help "$script_name" ;;
        -)
            case "${OPTARG}" in
            verbose) verbose_mode=true ;;
            dry-run) dry_run=true ;;
            help) show_installer_help "$script_name" ;;
            *)
                echo "Unknown option --${OPTARG}"
                exit 1
                ;;
            esac
            ;;
        *)
            echo "Usage: sudo $script_name [-v|--verbose] [-n|--dry-run] [-h|--help]"
            exit 1
            ;;
        esac
    done

    if $dry_run; then
        echo "═══════════════════════════════════════════════"
        echo "  DRY-RUN MODE - No changes will be made"
        echo "═══════════════════════════════════════════════"
    fi
}

# ═════ Initialize Installer Environment ═════
init_installer_env() {
    detect_user_context
    detect_architecture
    detect_package_manager

    log_message "DEBUG" "User: $me, Home: $myhome"
    log_message "DEBUG" "Arch: $ARCH ($ARCH_DEB), Distro: $DISTRO_ID"
    log_message "DEBUG" "Package manager: $pkgmgr"
}

# ═════ Ensure a runtime dependency is installed ═════
# Usage: ensure_dep <cmd> [overrides]
#   <cmd>       command name to check on $PATH (also the default package name)
#   [overrides] space-separated "pkgmgr=pkgname" pairs for distros where the
#               package name differs from the command. Only list exceptions;
#               unlisted distros fall back to <cmd>.
# Examples:
#   ensure_dep gh "pacman=github-cli"
#   ensure_dep fd "apt=fd-find dnf=fd-find brew=fd"
#   ensure_dep ripgrep
ensure_dep() {
    local cmd=$1
    local overrides=${2:-}
    local pkg=$cmd

    if command -v "$cmd" &>/dev/null; then return 0; fi
    if [[ -z "$pkgmgr" ]]; then
        log_message "WARNING" "Cannot install $cmd: no package manager detected" "true"
        return 1
    fi

    if [[ -n "$overrides" ]]; then
        for pair in $overrides; do
            local mgr=${pair%%=*}
            local name=${pair#*=}
            [[ "$pkgmgr" == "$mgr" ]] && pkg=$name && break
        done
    fi

    log_message "INFO" "$cmd not found, installing $pkg via $pkgmgr" "true"
    if should_run; then
        if [[ "$pkgmgr" == "brew" ]]; then
            $ASME brew install "$pkg"
        else
            eval "$pkgmgr $pkginstall $pkg"
        fi
        command -v "$cmd" &>/dev/null || { log_message "WARNING" "$cmd unavailable after installing $pkg" "true"; return 1; }
    else
        dry_print "Would install $pkg via $pkgmgr"
    fi
}
