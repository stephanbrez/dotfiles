#!/bin/bash

#  ██▓ ███▄    █   ██████ ▄▄▄█████▓ ▄▄▄       ██▓     ██▓    ▓█████  ██▀███
# ▓██▒ ██ ▀█   █ ▒██    ▒ ▓  ██▒ ▓▒▒████▄    ▓██▒    ▓██▒    ▓█   ▀ ▓██ ▒ ██▒
# ▒██▒▓██  ▀█ ██▒░ ▓██▄   ▒ ▓██░ ▒░▒██  ▀█▄  ▒██░    ▒██░    ▒███   ▓██ ░▄█ ▒
# ░██░▓██▒  ▐▌██▒  ▒   ██▒░ ▓██▓ ░ ░██▄▄▄▄██ ▒██░    ▒██░    ▒▓█  ▄ ▒██▀▀█▄
# ░██░▒██░   ▓██░▒██████▒▒  ▒██▒ ░  ▓█   ▓██▒░██████▒░██████▒░▒████▒░██▓ ▒██▒
# ░▓  ░ ▒░   ▒ ▒ ▒ ▒▓▒ ▒ ░  ▒ ░░    ▒▒   ▓▒█░░ ▒░▓  ░░ ▒░▓  ░░░ ▒░ ░░ ▒▓ ░▒▓░
#  ▒ ░░ ░░   ░ ▒░░ ░▒  ░ ░    ░      ▒   ▒▒ ░░ ░ ▒  ░░ ░ ▒  ░ ░ ░  ░  ░▒ ░ ▒░
#  ▒ ░   ░   ░ ░ ░  ░  ░    ░        ░   ▒     ░ ░     ░ ░      ░     ░░   ░
#  ░           ░       ░                 ░  ░    ░  ░    ░  ░   ░  ░   ░

# TODO:
#
# ╔════════════════════════════════════════════════╗
# ║  ░█▄█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀█░█░░░█▀█░█▀▀░█░█  ║
# ║  ░█░█░█▀▀░░█░░█▀█░█░█░█░█░█░█░█░░░█░█░█░█░░█░  ║
# ║  ░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░  ║
# ╚════════════════════════════════════════════════╝
# Automate the installation of dotfiles and tools
# Distro independent
# Also works for Mac
#

#########################################
# Script setup                          #
#########################################
me="stephan"
myhome="/home/$me"
basedir="$myhome/.dotfiles"
bindir="$myhome/.local/bin"
repourl="https://github.com/stephanbrez/dotfiles.git"
dots="nvim starship tmux wezterm zsh"
ASME="sudo -u $me"

# ======== helper functions ======== #
function _echo() { printf "\n╓───── %s \n╙────────────────────────────────────── ─ ─ \n" "$1"; }
function info() { printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"; }
function user() { printf "\r  [ \033[0;33m??\033[0m ] %s\n" "$1"; }
function success() { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
function fail() {
	printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
	echo ''
	exit
}

function linux_package() {
if [ -x "$(command -v apk)" ];
then
    pkgmgr="apk"
    pkginstall="add --no-cache"
    pkgupdate="update"	
elif [ -x "$(command -v apt)" ];
then
    pkgmgr="apt"
    pkginstall="install -y"
    pkgupdate="update"	
elif [ -x "$(command -v dnf)" ];
then
    pkgmgr="dnf"
    pkginstall="install -y"
    pkgupdate="update"	
elif [ -x "$(command -v pacman)" ];
then
    pkgmgr="pacman"
    pkginstall="-S"
    pkgupdate="-Syu"	
elif [ -x "$(command -v zypper)" ];
then
    pkgmgr="zypper"
    pkginstall="install"
    pkgupdate="refresh && zypper update"	
else
    fail "Package manager not found. You must manually install packages.";
fi
}

#########################################
# Install                               #
#########################################
_echo "configuring package manager"

case "$OSTYPE" in
  	darwin*)  
	pkgmgr="brew"
	pkginstall="install"
	pkgupdate="update"
	DARWIN=1 
	;; 
  	linux*)   
	LINUX=1
	linux_package 
	;;
  	bsd*)     	
	OS=$(uname -s)
	VER=$(uname -r) 
	;;
  	msys*)    
	echo "WINDOWS" 
	;;
  	cygwin*)  
	echo "ALSO WINDOWS" 
	;;
  	win32*)
	echo "WINDOWS"
	;;
  	*)        
	fail "unknown: $OSTYPE" 
 	exit 1
	;;
esac

_echo "updating package manager"
eval "$pkgmgr" "$pkgupdate"

# install all the things \o/
_echo "installing packages"
# build package list
pkgInstall=(
	# command line tools
	bat
	btop
	diffutils
	doxygen
	fd-find
	findutils
	gawk
	gh
	git
	luarocks
	mawk
	mc
	neovim
	ripgrep
	shellcheck
	silversearcher-ag
	stow
	tldr
	tmux
 	trash-cli
	zsh
	# system/server tools
 	automake
	bash
	bash-completion
	build-essential
	ca-certificates
	clamav-base
	cmake
	coreutils
	curl
	docker.io
	dpkg
	e2fsprogs
	ethtool
	fail2ban
	gcc
	golang
	golang-doc
	golang-src
	gpg
 	meson
	pkgconf
	psmisc
	python3
	python3-pip
	python3-venv
	rkhunter
	secure-delete
	sudo
	util-linux
 	wget
	# fun
	toilet
)
case $pkgmgr in
	apt*)
	# Debian specific tools
	eval "$pkgmgr" "$pkginstall" "apt-utils dash debianutils"
	;;
esac
eval "$pkgmgr" "$pkginstall" "${pkgInstall[*]}"

# manually add apt sources
mkdir -p /etc/apt/keyrings

# ======== install 1password ======== #
sudo -s \
	curl -sS https://downloads.1password.com/linux/keys/1password.asc |
	gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" |
	tee /etc/apt/sources.list.d/1password.list
mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol |
	tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc |
	gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
apt install -y 1password 1password-cli

# ======== install eza ======== #
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
apt install -y eza

# ======== install fzf ======== #
$ASME git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &&
	~/.fzf/install

# ======== install glow ======== #
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
apt update && apt install glow

# ======== install lazygit ======== #
cd "$myhome" &&
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') &&
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" &&
	tar xf lazygit.tar.gz lazygit &&
	install lazygit /usr/local/bin &&
	cd "$basedir"

# ======== install wezterm ======== #
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
apt install wezterm

# ======== install zoxide ======== #
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
# fix fd clash
ln -s "$(which fd)" "$bindir"/fd

# ======== Fun stuff ======== #
_echo "setting up ascii/ansi art tools"
rm -rf /usr/share/figlet/
git clone --depth=1 https://github.com/xero/figlet-fonts.git /usr/share/figlet/
$ASME git clone --depth=1 https://github.com/digitallyserviced/tdfgo.git "$myhome"/.local/src/tdfgo &&
	cd "$myhome"/.local/src/tdfgo &&
	$ASME go build &&
	mv ./tdfgo "$myhome"/.local/bin/tdfgo &&
	chmod +x "$myhome"/.local/bin/tdfgo &&
	mkdir -p "$myhome"/.config/tdfgo &&
	mv ./fonts "$myhome"/.config/tdfgo/fonts

#########################################
# Setup                                 #
#########################################
_echo "creating directories"
$ASME mkdir -p \
	"$myhome/.{config,local}" \
	"$myhome/.local/{bin,cache,lib,share,src,state}"
$ASME ln -s "$myhome"/Documents "$myhome"/.local/docs

# ======== setup dotfiles ======== #
_echo "setting up dotfiles"
if [ -d "$basedir/.git" ]; then
	info "Updating dotfiles using existing git..."
	cd "$basedir" &&
		$ASME git pull --quiet --rebase origin main || exit 1 # no use continuing if git pull fails
else
	info "Checking out dotfiles using git..."
	rm -rf "$basedir"
	$ASME git clone --quiet "$repourl" "$basedir" &&
		cd "$basedir" &&
		$ASME stow "$dots" -t "$myhome" --adopt &&
		$ASME git restore .
fi

_echo "setting up starship"
curl -sS https://starship.rs/install.sh | sh

# ======== setup git ======== #
# Git config name
echo "Please enter your FULL NAME for Git configuration:"
read git_user_name

# Git config email
echo "Please enter your EMAIL for Git configuration:"
read git_user_email

# Set git credentials
git config --global user.name "$git_user_name"
git config --global user.email "$git_user_email"
success 'gitconfig'

# ======== setup tmux ======== #
_echo "setting up tmux"
if which tmux >/dev/null 2>&1; then
	tpm="$myhome/.tmux/plugins/tpm"
	$ASME mkdir -p "$tpm"
	if [ -e "$myhome/.config/tmux/plugins/tpm" ]; then
		mv "$myhome/.config/tmux/plugins/tpm" "$tpm"
		pushd "$tpm" >/dev/null &&
			$ASME git pull -q origin master &&
			popd >/dev/null || return
	else
		$ASME git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm" &&
			$ASME "$tpm"/scripts/install_plugins.sh >/dev/null &&
			$ASME "$tpm"/scripts/clean_plugins.sh >/dev/null &&
			$ASME "$tpm"/scripts/update_plugin.sh >/dev/null
	fi
else
	fail "Skipping tmux setup because tmux isn't installed."
fi

# ======== zsh ======== #
_echo "setting up zsh"
if which zsh >/dev/null 2>&1; then
	$ASME chsh -s "$(which zsh)"
fi

#########################################
# Manual Install                        #
#########################################
# fastfetch
_echo "opening fastfetch release page"
xdg-open https://github.com/fastfetch-cli/fastfetch/releases/latest
