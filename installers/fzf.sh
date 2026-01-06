#!/bin/bash
# fzf.sh - Install/update fzf fuzzy finder binary

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_fzf_binary() {
    _echo "installing/updating fzf"
    if should_run; then
        FZF_VERSION=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        $ASME curl -L "https://github.com/junegunn/fzf/releases/latest/download/fzf-${FZF_VERSION}-linux_$(dpkg --print-architecture).tar.gz" -o "$myhome/.local/src/fzf.tar.gz"
        mkdir -p "$myhome/.local/src"
        tar xzf "$myhome/.local/src/fzf.tar.gz" -C /usr/bin/ fzf &&
            chmod +x /usr/bin/fzf &&
            rm "$myhome/.local/src/fzf.tar.gz"
        log_message "SUCCESS" "fzf $FZF_VERSION installed"
    else
        dry_print "Would download and install latest fzf"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_fzf_binary
    log_message "SUCCESS" "fzf installation complete" "true"
fi
