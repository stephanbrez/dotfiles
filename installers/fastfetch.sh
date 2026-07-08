#!/bin/bash
# fastfetch.sh - Install fastfetch system info tool

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_fastfetch() {
    _echo "installing fastfetch"
    if [[ "$pkgmgr" == "apt" ]]; then
        if should_run; then
            curl -Lo fastfetch-linux.deb "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-$ARCH_DEB.deb" &&
                dpkg -i fastfetch-linux.deb &&
                rm -rf fastfetch-linux.deb
            log_message "SUCCESS" "fastfetch installed"
        else
            dry_print "Would download and install fastfetch .deb"
        fi
    elif [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew install fastfetch
            log_message "SUCCESS" "fastfetch installed via Homebrew"
        else
            dry_print "Would run: brew install fastfetch"
        fi
    else
        if should_run; then
            eval "$pkgmgr $pkginstall fastfetch"
            log_message "SUCCESS" "fastfetch installed via $pkgmgr"
        else
            dry_print "Would run: $pkgmgr $pkginstall fastfetch"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_fastfetch
    log_message "SUCCESS" "fastfetch installation complete" "true"
fi
