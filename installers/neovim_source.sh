#!/bin/bash
# neovim_source.sh - Install neovim (source build on apt, pre-built binary elsewhere)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_neovim_source() {
	if command -v nvim &>/dev/null; then
		log_message "INFO" "nvim already installed, skipping"
		return 0
	fi
	_echo "installing neovim"
	if [[ "$pkgmgr" == "apt" ]]; then
		# Build from source for Debian/Ubuntu (outdated repos)
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
	elif [[ "$pkgmgr" == "brew" ]]; then
		if should_run; then
			$ASME brew install neovim
			log_message "SUCCESS" "neovim installed via Homebrew"
		else
			dry_print "Would run: brew install neovim"
		fi
	else
		if should_run; then
			curl -L "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH_GH}.tar.gz" -o /tmp/nvim-linux.tar.gz
			rm -rf "/opt/nvim-linux-${ARCH_GH}"
			tar -C /opt -xzf /tmp/nvim-linux.tar.gz
			ln -sf "/opt/nvim-linux-${ARCH_GH}/bin/nvim" /usr/local/bin/nvim
			rm /tmp/nvim-linux.tar.gz
			log_message "SUCCESS" "neovim installed from pre-built binary"
		else
			dry_print "Would download neovim pre-built binary to /opt"
			dry_print "Would symlink nvim to /usr/local/bin/nvim"
		fi
	fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	parse_installer_args "$@"
	init_installer_env
	install_neovim_source
	log_message "SUCCESS" "neovim installation complete" "true"
fi
