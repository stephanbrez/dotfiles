#!/bin/bash
# tmux.sh - Install TPM (Tmux Plugin Manager) and plugins
# Runs after tmux.conf is stowed so TPM knows which plugins to install.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_tmux() {
    local tpm="$myhome/.tmux/plugins/tpm"

    # Idempotent: skip if TPM is already cloned
    if [[ -d "$tpm/.git" ]]; then
        log_message "INFO" "TPM already installed, skipping"
        return 0
    fi

    _echo "setting up tmux"
    ensure_dep git || return 1

    if should_run; then
        # Skip gracefully if tmux isn't installed — not a failure. setup gates
        # this call on PKG_TMUX (emitted by the parser when tmux is in the
        # distro's package list), so reaching here means tmux was configured.
        # But the package may not have installed successfully, so double-check.
        if ! command -v tmux &>/dev/null; then
            log_message "INFO" "tmux not installed, skipping TPM setup"
            return 0
        fi
        $ASME mkdir -p "$tpm"
        # Legacy migration: move tpm from old stowed location (~/.config/tmux/plugins/tpm)
        if [[ -e "$myhome/.config/tmux/plugins/tpm" ]]; then
            mv "$myhome/.config/tmux/plugins/tpm" "$tpm"
            pushd "$tpm" >/dev/null || { log_message "WARNING" "Failed to enter $tpm" "true"; return 1; }
            $ASME git pull -q origin master || log_message "WARNING" "Failed to update existing TPM" "true"
            popd >/dev/null || true
        else
            $ASME git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm" &&
                $ASME "$tpm"/scripts/install_plugins.sh >/dev/null &&
                $ASME "$tpm"/scripts/clean_plugins.sh >/dev/null &&
                $ASME "$tpm"/scripts/update_plugin.sh >/dev/null
        fi
        log_message "SUCCESS" "TPM installed"
    else
        dry_print "Would clone TPM and install tmux plugins"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_tmux
    log_message "SUCCESS" "tmux setup complete" "true"
fi
