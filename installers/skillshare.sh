#!/bin/bash
# skillshare.sh - Install skillshare (AI CLI skills sync tool)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_skillshare() {
    if command -v skillshare &>/dev/null; then
        log_message "INFO" "skillshare already installed, skipping"
        return 0
    fi
    _echo "installing skillshare"
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install skillshare
            log_message "SUCCESS" "skillshare installed via Homebrew"
        else
            dry_print "Would run: brew install skillshare"
        fi
    else
        if should_run; then
            $ASME curl -fsSL https://raw.githubusercontent.com/runkids/skillshare/main/install.sh | $ASME sh
            log_message "SUCCESS" "skillshare installed"
        else
            dry_print "Would download and run skillshare install script"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_skillshare
    log_message "SUCCESS" "skillshare installation complete" "true"
fi
