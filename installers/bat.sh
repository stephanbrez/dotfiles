#!/bin/bash
# bat.sh - Symlink batcat to bat (Debian-specific workaround)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_bat() {
	local bindir="${bindir:-$myhome/.local/bin}"
	_echo "setting up bat symlink"
	if should_run; then
		if which batcat >/dev/null 2>&1; then
			if [ ! -e "$bindir/bat" ]; then
				mkdir -p "$bindir"
				ln -s "$(which batcat)" "$bindir/bat"
				log_message "SUCCESS" "bat symlinked to batcat"
			else
				log_message "INFO" "bat symlink already exists, skipping"
			fi
		else
			log_message "INFO" "batcat not found, skipping"
		fi
	else
		dry_print "Would symlink batcat to $bindir/bat"
	fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	parse_installer_args "$@"
	init_installer_env
	install_bat
	log_message "SUCCESS" "bat setup complete" "true"
fi
