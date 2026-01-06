#!/bin/bash
# onepassword.sh - Install 1Password and 1Password CLI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_onepassword() {
    _echo "installing 1Password"
    if [[ "$pkgmgr" != "apt" ]]; then
        log_message "WARNING" "1Password installation only configured for apt-based systems" "true"
        return 1
    fi

    if should_run; then
        # Add 1Password GPG key and repository
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg &&
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | tee /etc/apt/sources.list.d/1password.list

        # Add debsig policy
        mkdir -p /etc/debsig/policies/AC2D62742012EA22/ &&
            curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

        # Add debsig keyring
        mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 &&
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

        # Install 1Password
        apt update && apt install -y 1password 1password-cli
        log_message "SUCCESS" "1Password installed"
    else
        dry_print "Would add 1Password repository and install 1password 1password-cli"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_onepassword
    log_message "SUCCESS" "1Password installation complete" "true"
fi
