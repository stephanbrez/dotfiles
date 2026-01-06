#!/bin/bash
# lazydocker.sh - Install lazydocker Docker TUI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_lazydocker() {
    _echo "installing lazydocker"
    if should_run; then
        # Prepare the download URL
        GITHUB_LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/jesseduffield/lazydocker/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
        GITHUB_FILE="lazydocker_${GITHUB_LATEST_VERSION//v/}_$(uname -s)_${ARCH_GH}.tar.gz"
        GITHUB_URL="https://github.com/jesseduffield/lazydocker/releases/download/${GITHUB_LATEST_VERSION}/${GITHUB_FILE}"

        # Install/update the local binary
        curl -L -o lazydocker.tar.gz "$GITHUB_URL"
        tar xzvf lazydocker.tar.gz lazydocker
        install -Dm 755 lazydocker -t "/usr/local/bin"
        rm lazydocker lazydocker.tar.gz
        log_message "SUCCESS" "lazydocker $GITHUB_LATEST_VERSION installed"
    else
        dry_print "Would download and install lazydocker"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_lazydocker
    log_message "SUCCESS" "lazydocker installation complete" "true"
fi
