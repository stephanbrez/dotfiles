#!/bin/bash
# wezterm.sh - Install WezTerm terminal emulator

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_wezterm() {
    if command -v wezterm &>/dev/null; then
        log_message "INFO" "wezterm already installed, skipping"
        return 0
    fi
    _echo "installing wezterm"
    if [[ "$pkgmgr" == "apt" ]]; then
        if should_run; then
            curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | tee /etc/apt/sources.list.d/wezterm.list
            apt update && apt install -y wezterm
            log_message "SUCCESS" "wezterm installed"
        else
            dry_print "Would add wezterm repository and install wezterm"
        fi
    elif [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install --cask wezterm
            log_message "SUCCESS" "wezterm installed via Homebrew cask"
        else
            dry_print "Would run: brew install --cask wezterm"
        fi
    else
        log_message "WARNING" "WezTerm installation only configured for apt and brew" "true"
        return 1
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_wezterm
    log_message "SUCCESS" "wezterm installation complete" "true"
fi
