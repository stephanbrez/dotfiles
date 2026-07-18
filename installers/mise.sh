#!/bin/bash
# mise.sh - Install mise (polyglot dev tool version manager)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_mise() {
    if command -v mise &>/dev/null; then
        log_message "INFO" "mise already installed, skipping"
        return 0
    fi
    _echo "installing mise"
    ensure_dep curl || return 1
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install mise
            log_message "SUCCESS" "mise installed via Homebrew"
        else
            dry_print "Would run: brew install mise"
        fi
    else
        # Universal fallback: mise.run curl installer (works on all Linux
        # distros). The jdxcode/mise PPA only publishes for newer Ubuntu
        # releases, so the curl installer is the reliable cross-distro method.
        if should_run; then
            $ASME curl -sS https://mise.run | $ASME sh
            log_message "SUCCESS" "mise installed via mise.run"
        else
            dry_print "Would download and run mise install script (mise.run)"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_mise
    log_message "SUCCESS" "mise installation complete" "true"
fi
