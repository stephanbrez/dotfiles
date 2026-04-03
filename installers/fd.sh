#!/bin/bash
# fd.sh - Symlink fdfind to fd (Debian-specific workaround)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_fd() {
	local bindir="${bindir:-$myhome/.local/bin}"
	_echo "setting up fd symlink"
	if should_run; then
		if which fdfind >/dev/null 2>&1; then
			if [ ! -e "$bindir/fd" ]; then
				mkdir -p "$bindir"
				ln -s "$(which fdfind)" "$bindir/fd"
				log_message "SUCCESS" "fd symlinked to fdfind"
			else
				log_message "INFO" "fd symlink already exists, skipping"
			fi
		else
			log_message "INFO" "fdfind not found, skipping"
		fi
	else
		dry_print "Would symlink fdfind to $bindir/fd"
	fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	parse_installer_args "$@"
	init_installer_env
	install_fd
	log_message "SUCCESS" "fd setup complete" "true"
fi
