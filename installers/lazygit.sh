#!/bin/bash
# lazygit.sh - Install lazygit Git TUI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_lazygit() {
    if command -v lazygit &>/dev/null; then
        log_message "INFO" "lazygit already installed, skipping"
        return 0
    fi
    _echo "installing lazygit"
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install lazygit
            log_message "SUCCESS" "lazygit installed via Homebrew"
        else
            dry_print "Would run: brew install lazygit"
        fi
    else
        if should_run; then
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH_GH}.tar.gz"
            tar xf lazygit.tar.gz lazygit
            install lazygit /usr/local/bin
            rm -rf lazygit.tar.gz lazygit
            log_message "SUCCESS" "lazygit $LAZYGIT_VERSION installed"
        else
            dry_print "Would download and install lazygit"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_lazygit
    log_message "SUCCESS" "lazygit installation complete" "true"
fi
