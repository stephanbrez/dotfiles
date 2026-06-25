#!/bin/bash
# eza.sh - Install eza (modern ls replacement)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_eza() {
    _echo "installing eza"
    if [[ "$pkgmgr" == "apt" ]]; then
        if should_run; then
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
            chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            apt update && apt install -y eza
            log_message "SUCCESS" "eza installed"
        else
            dry_print "Would add eza repository and install eza"
        fi
    elif [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install eza
            log_message "SUCCESS" "eza installed via Homebrew"
        else
            dry_print "Would run: brew install eza"
        fi
    else
        log_message "WARNING" "eza installation not configured for $pkgmgr" "true"
        log_message "INFO" "Try: $pkgmgr $pkginstall eza" "true"
        return 1
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_eza
    log_message "SUCCESS" "eza installation complete" "true"
fi
