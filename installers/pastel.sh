#!/bin/bash
# pastel.sh - Install/update pastel color tool binary

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_pastel_binary() {
    _echo "installing/updating pastel"
    if [[ "$pkgmgr" == "apt" ]]; then
        if should_run; then
            PASTEL_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/pastel/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            mkdir -p "$myhome/.local/src"
            $ASME curl -L "https://github.com/sharkdp/pastel/releases/download/v${PASTEL_VERSION}/pastel_${PASTEL_VERSION}_${ARCH_DEB}.deb" -o "$myhome/.local/src/pastel.deb"
            dpkg -i "$myhome/.local/src/pastel.deb" &&
                rm "$myhome/.local/src/pastel.deb"
            log_message "SUCCESS" "pastel $PASTEL_VERSION installed"
        else
            dry_print "Would download and install latest pastel .deb"
        fi
    elif [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install pastel
            log_message "SUCCESS" "pastel installed via Homebrew"
        else
            dry_print "Would run: brew install pastel"
        fi
    else
        if should_run; then
            PASTEL_VERSION=$(curl -s "https://api.github.com/repos/sharkdp/pastel/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -L "https://github.com/sharkdp/pastel/releases/download/v${PASTEL_VERSION}/pastel-v${PASTEL_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/pastel.tar.gz
            tar xzf /tmp/pastel.tar.gz -C /tmp/ pastel
            install -Dm 755 /tmp/pastel -t /usr/local/bin
            rm -rf /tmp/pastel /tmp/pastel.tar.gz
            log_message "SUCCESS" "pastel $PASTEL_VERSION installed"
        else
            dry_print "Would download and install latest pastel binary"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_pastel_binary
    log_message "SUCCESS" "pastel installation complete" "true"
fi