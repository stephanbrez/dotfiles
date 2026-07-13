#!/bin/bash
# uv.sh - Install uv Python package manager (Astral)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_uv() {
    if command -v uv &>/dev/null; then
        log_message "INFO" "uv already installed, skipping"
        return 0
    fi
    _echo "installing uv"
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install uv
            log_message "SUCCESS" "uv installed via Homebrew"
        else
            dry_print "Would run: brew install uv"
        fi
    else
        if should_run; then
            $ASME curl -LsSf https://astral.sh/uv/install.sh | $ASME sh
            log_message "SUCCESS" "uv installed"
        else
            dry_print "Would download and run uv install script"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_uv
    log_message "SUCCESS" "uv installation complete" "true"
fi
