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
        WARNING) printf "[\033[31m;1 !!! \033[0m][%s] %s\n" "$timestamp" "$message" ;;
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

# ═════ Package Manager Detection ═════
detect_package_manager() {
    if [ -x "$(command -v apk)" ]; then
        pkgmgr="apk"
        pkginstall="add --no-cache"
        pkgupdate="update"
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
