#!/bin/bash
# figlet-fonts.sh - Install figlet font collection

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_figlet_fonts() {
    _echo "setting up ascii/ansi art tools"
    if should_run; then
        rm -rf /usr/share/figlet/
        git clone --depth=1 https://github.com/xero/figlet-fonts.git /usr/share/figlet/
        log_message "SUCCESS" "figlet fonts installed"
    else
        dry_print "Would install figlet fonts to /usr/share/figlet/"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_figlet_fonts
    log_message "SUCCESS" "figlet fonts installation complete" "true"
fi
