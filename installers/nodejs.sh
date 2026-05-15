#!/bin/bash
# nodejs.sh - Install Node.js via NodeSource, configure npm XDG prefix

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_nodejs() {
    _echo "installing Node.js"
    if should_run; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            $ASME brew install node
        else
            case "$pkgmgr" in
            apt)  NODESOURCE_URL="https://deb.nodesource.com/setup_lts.x" ;;
            dnf|yum) NODESOURCE_URL="https://rpm.nodesource.com/setup_lts.x" ;;
            *)    NODESOURCE_URL="" ;;
            esac

            if [[ -n "$NODESOURCE_URL" ]]; then
                curl -fsSL "$NODESOURCE_URL" | bash -
                eval "$pkgmgr $pkginstall nodejs"
            else
                log_message "INFO" "NodeSource not supported on this distro, using distro package" "true"
                eval "$pkgmgr $pkginstall nodejs"
            fi
        fi

        if command -v npm &>/dev/null; then
            $ASME npm config set prefix "$myhome/.local/share/npm"
            log_message "SUCCESS" "Node.js installed, npm prefix set to ~/.local/share/npm"
        else
            log_message "WARNING" "npm not found after install, skipping prefix config" "true"
            return 1
        fi
    else
        dry_print "Would install Node.js via NodeSource"
        dry_print "Would set npm prefix to ~/.local/share/npm"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_nodejs
    log_message "SUCCESS" "Node.js installation complete" "true"
fi
