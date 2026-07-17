#!/bin/bash
# claude-code.sh - Install Claude Code CLI (Anthropic)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_claude_code() {
    if command -v claude &>/dev/null; then
        log_message "INFO" "claude-code already installed, skipping"
        return 0
    fi
    _echo "installing claude-code"
    ensure_dep curl || return 1
    if should_run; then
        $ASME curl -fsSL https://claude.ai/install.sh | $ASME bash
        log_message "SUCCESS" "claude-code installed"
    else
        dry_print "Would download and run claude-code install script"
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_claude_code
    log_message "SUCCESS" "claude-code installation complete" "true"
fi
