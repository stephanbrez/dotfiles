#!/bin/bash
# packages-fallback.sh - Fallback package definitions when YAML config unavailable
# Source this file to get package arrays and install_fallback_packages()

# ═════ Guard against multiple sourcing ═════
[[ -n "$_PACKAGES_FALLBACK_LOADED" ]] && return 0
_PACKAGES_FALLBACK_LOADED=1

# ═════ Distro-neutral packages ═════
PKG_COMMON=(
	# command line tools
	bat
	btop
	diffutils
	file
	fzf
	gh
	git
	# neovim - installed separately (build from source for apt, pkg mgr for others)
	ripgrep
	shellcheck
	stow
	tldr
	tmux
	trash-cli
	zsh
	# system/server tools
	automake
	bash-completion
	ca-certificates
	cmake
	curl
	# docker - installed separately from official Docker repos
	e2fsprogs
	ethtool
	flatpak
	gcc
	gettext
	meson
	ninja-build
	npm
	pipx
	pkgconf
	python3
	python3-pip
	unzip
	wget
	wl-clipboard
	# fun
)

# ═════ APT-based distro packages ═════
PKG_APT_COMMON="apt-utils build-essential python3-dev python3-venv fd-find silversearcher-ag secure-delete"

# Ubuntu-specific (20.04+)
PKG_UBUNTU_MODERN="$PKG_APT_COMMON fonts-dejavu exfatprogs"
# Ubuntu-specific (older)
PKG_UBUNTU_LEGACY="$PKG_APT_COMMON fonts-dejavu exfat-fuse"
# Debian-specific
PKG_DEBIAN="$PKG_APT_COMMON ttf-dejavu exfat-fuse"
# Other apt-based (Mint, Pop!_OS, etc.)
PKG_APT_OTHER="$PKG_APT_COMMON fonts-dejavu exfat-fuse"

# ═════ DNF-based distro packages ═════
PKG_DNF="dejavu-fonts exfat-utils fd-find the_silver_searcher gnupg2 srm python3-neovim neovim"

# ═════ Install function ═════
install_fallback_packages() {
	log_message "INFO" "Installing packages from fallback definitions..." "true"

	# ─── Install distro-specific packages first ───
	case $pkgmgr in
	apt*)
		case "$DISTRO_ID" in
		ubuntu)
			log_message "INFO" "Installing Ubuntu-specific packages..." "true"
			if [[ "${DISTRO_VERSION%%.*}" -ge 20 ]]; then
				if should_run; then
					eval "$pkgmgr $pkginstall $PKG_UBUNTU_MODERN"
				else
					dry_print "Would install: $PKG_UBUNTU_MODERN"
				fi
			else
				if should_run; then
					eval "$pkgmgr $pkginstall $PKG_UBUNTU_LEGACY"
				else
					dry_print "Would install: $PKG_UBUNTU_LEGACY"
				fi
			fi
			;;
		debian)
			log_message "INFO" "Installing Debian-specific packages..." "true"
			if should_run; then
				eval "$pkgmgr $pkginstall $PKG_DEBIAN"
			else
				dry_print "Would install: $PKG_DEBIAN"
			fi
			;;
		*)
			log_message "INFO" "Installing packages for $DISTRO_ID..." "true"
			if should_run; then
				eval "$pkgmgr $pkginstall $PKG_APT_OTHER"
			else
				dry_print "Would install: $PKG_APT_OTHER"
			fi
			;;
		esac
		;;
	dnf*)
		log_message "INFO" "Installing Fedora-specific packages..." "true"
		if should_run; then
			eval "$pkgmgr groupinstall -y 'Development Tools'"
			eval "$pkgmgr $pkginstall $PKG_DNF"
		else
			dry_print "Would install group: Development Tools"
			dry_print "Would install: $PKG_DNF"
		fi
		;;
	esac

	# ─── Install distro-neutral packages ───
	if should_run; then
		eval "$pkgmgr $pkginstall ${PKG_COMMON[*]}"
	else
		dry_print "Would install distro-neutral packages: ${PKG_COMMON[*]}"
	fi
}
