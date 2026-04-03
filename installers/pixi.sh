#!/bin/bash
# pixi.sh - Install pixi package manager

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_pixi() {
	_echo "installing pixi"
	if should_run; then
		export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$myhome/.config}"
		export XDG_DATA_HOME="${XDG_DATA_HOME:-$myhome/.local/share}"
		export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$myhome/.cache}"
		export PIXI_CACHE_DIR="$XDG_CACHE_HOME/pixi"

		mkdir -p "$XDG_DATA_HOME/pixi" "$PIXI_CACHE_DIR" "$bindir"

		PIXI_BIN_DIR="$bindir" \
			PIXI_NO_PATH_UPDATE=1 \
			curl -fsSL https://pixi.sh/install.sh | bash

		if command -v pixi >/dev/null 2>&1; then
			log_message "SUCCESS" "pixi installed at $(command -v pixi)"
		else
			log_message "WARNING" "pixi not found in PATH after installation" "true"
		fi
	else
		dry_print "Would download and install pixi"
	fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	parse_installer_args "$@"
	init_installer_env
	install_pixi
	log_message "SUCCESS" "pixi installation complete" "true"
fi
