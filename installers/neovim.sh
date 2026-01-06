#!/bin/bash
# neovim.sh - Build and install neovim from source (apt-based systems only)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_neovim_source() {
	# Build from source for Debian/Ubuntu (outdated repos)
	# Other distros like Fedora use package manager version
	if [[ "$pkgmgr" != "apt" ]]; then
		log_message "INFO" "Skipping neovim build - use package manager version for $DISTRO_ID" "true"
		log_message "INFO" "Try: $pkgmgr $pkginstall neovim" "true"
		return 0
	fi

	_echo "building neovim from source"
	if should_run; then
		# Ensure build dependencies are installed
		apt install -y ninja-build gettext cmake unzip curl build-essential file

		$ASME git clone https://github.com/neovim/neovim "$myhome"/.local/src/neovim &&
			cd "$myhome"/.local/src/neovim &&
			git checkout stable &&
			make CMAKE_BUILD_TYPE=RelWithDebInfo &&
			cd build &&
			cpack -G DEB &&
			dpkg -i nvim-linux-"${ARCH_GH}".deb

		# Install Python bindings for neovim
		apt install -y python3-neovim
		log_message "SUCCESS" "neovim Python bindings installed"
		log_message "SUCCESS" "neovim built and installed from source"
	else
		dry_print "Would clone neovim repo and build from source"
		dry_print "Would install nvim-linux-${ARCH_GH}.deb"
	fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	parse_installer_args "$@"
	init_installer_env
	install_neovim_source
	log_message "SUCCESS" "neovim installation complete" "true"
fi
