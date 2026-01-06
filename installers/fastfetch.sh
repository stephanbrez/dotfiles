#!/bin/bash
# fastfetch.sh - Install fastfetch system info tool

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_fastfetch() {
    _echo "installing fastfetch"
    if should_run; then
        curl -Lo fastfetch-linux.deb "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-$(dpkg --print-architecture).deb" &&
            dpkg -i fastfetch-linux.deb &&
            rm -rf fastfetch-linux.deb
        log_message "SUCCESS" "fastfetch installed"
    else
        dry_print "Would download and install fastfetch"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_fastfetch
    log_message "SUCCESS" "fastfetch installation complete" "true"
fi
