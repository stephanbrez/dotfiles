#!/bin/bash
# zoxide.sh - Install zoxide (smarter cd command)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_zoxide() {
    _echo "installing zoxide"
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install zoxide
            log_message "SUCCESS" "zoxide installed via Homebrew"
        else
            dry_print "Would run: brew install zoxide"
        fi
    else
        if should_run; then
            $ASME curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | $ASME bash
            log_message "SUCCESS" "zoxide installed"
        else
            dry_print "Would download and run zoxide install script"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_zoxide
    log_message "SUCCESS" "zoxide installation complete" "true"
fi
