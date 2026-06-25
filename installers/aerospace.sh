#!/bin/bash
# aerospace.sh - Install AeroSpace tiling window manager (macOS only)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_aerospace() {
    _echo "installing AeroSpace"
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install --cask aerospace
            log_message "SUCCESS" "AeroSpace installed via Homebrew cask"
        else
            dry_print "Would run: brew install --cask aerospace"
        fi
    else
        log_message "WARNING" "AeroSpace is macOS-only, skipping for $DISTRO_ID" "true"
        return 1
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_aerospace
    log_message "SUCCESS" "AeroSpace installation complete" "true"
fi