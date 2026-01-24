#!/bin/bash
# pastel.sh - Install/update pastel color tool binary

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_pastel_binary() {
    _echo "installing/updating pastel"
    if should_run; then
        PASTEL_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/pastel/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        $ASME curl -L "https://github.com/sharkdp/pastel/releases/download/v${PASTEL_VERSION}/pastel_${PASTEL_VERSION}_${ARCH_DEB}.deb" -o "$myhome/.local/src/pastel.deb"
        mkdir -p "$myhome/.local/src"
        dpkg -i "$myhome/.local/src/pastel.deb" &&
            rm "$myhome/.local/src/pastel.deb"
        log_message "SUCCESS" "pastel $PASTEL_VERSION installed"
    else
        dry_print "Would download and install latest pastel"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_pastel_binary
    log_message "SUCCESS" "pastel installation complete" "true"
fi