#!/bin/bash
# uv.sh - Install uv Python package manager (Astral)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_uv() {
    _echo "installing uv"
    if should_run; then
        $ASME curl -LsSf https://astral.sh/uv/install.sh | $ASME sh
        log_message "SUCCESS" "uv installed"
    else
        dry_print "Would download and run uv install script"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_uv
    log_message "SUCCESS" "uv installation complete" "true"
fi
