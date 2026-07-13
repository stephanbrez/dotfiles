#!/bin/bash
# glow.sh - Install glow (terminal markdown reader from Charm)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_glow() {
    if command -v glow &>/dev/null; then
        log_message "INFO" "glow already installed, skipping"
        return 0
    fi
    _echo "installing glow"
    if [[ "$pkgmgr" == "apt" ]]; then
        # ─── glow for Debian/Ubuntu (Charm apt repository) ───
        if should_run; then
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list >/dev/null
            apt update && apt install -y glow
            log_message "SUCCESS" "glow installed from Charm repository"
        else
            dry_print "Would add Charm apt repository and install glow"
        fi
    elif [[ "$pkgmgr" == "dnf" ]]; then
        # ─── glow for Fedora (Charm yum repository) ───
        if should_run; then
            echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | tee /etc/yum.repos.d/charm.repo >/dev/null
            dnf install -y glow
            log_message "SUCCESS" "glow installed from Charm repository"
        else
            dry_print "Would add Charm yum repository and install glow"
        fi
    elif [[ "$pkgmgr" == "brew" ]]; then
        # ─── glow for macOS (Homebrew) ───
        if should_run; then
            $ASME brew install glow
            log_message "SUCCESS" "glow installed via Homebrew"
        else
            dry_print "Would run: brew install glow"
        fi
    else
        # ─── glow via native package manager (Arch, Void, Nix, FreeBSD, Solus) ───
        if should_run; then
            eval "$pkgmgr $pkginstall glow"
            log_message "SUCCESS" "glow installed via $pkgmgr"
        else
            dry_print "Would run: $pkgmgr $pkginstall glow"
        fi
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_glow
    log_message "SUCCESS" "glow installation complete" "true"
fi
