#!/bin/bash
# ghui.sh - Install ghui (GitHub PR TUI)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_ghui() {
    if command -v ghui &>/dev/null; then
        log_message "INFO" "ghui already installed, skipping"
        return 0
    fi
    _echo "installing ghui"
    ensure_dep gh "pacman=github-cli" || return 1
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install kitlangton/tap/ghui
            log_message "SUCCESS" "ghui installed via Homebrew tap"
        else
            dry_print "Would run: brew install kitlangton/tap/ghui"
        fi
    else
        # ─── npm fallback for all other distros ───
        declare -f install_nodejs >/dev/null 2>&1 || source "$SCRIPT_DIR/nodejs.sh"
        install_nodejs || return 1
        if should_run; then
            $ASME npm install -g @kitlangton/ghui
            log_message "SUCCESS" "ghui installed via npm"
        else
            dry_print "Would run: npm install -g @kitlangton/ghui"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_ghui
    log_message "SUCCESS" "ghui installation complete" "true"
fi
