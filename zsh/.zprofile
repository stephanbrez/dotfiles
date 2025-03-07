#!/bin/sh
#
# ███████╗██████╗ ██████╗  ██████╗ ███████╗██╗██╗     ███████╗
# ╚══███╔╝██╔══██╗██╔══██╗██╔═══██╗██╔════╝██║██║     ██╔════╝
#   ███╔╝ ██████╔╝██████╔╝██║   ██║█████╗  ██║██║     █████╗  
#  ███╔╝  ██╔═══╝ ██╔══██╗██║   ██║██╔══╝  ██║██║     ██╔══╝  
# ███████╗██║     ██║  ██║╚██████╔╝██║     ██║███████╗███████╗
# ╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚══════╝
#
# env vars to set on login
# read first
#
# ╔════════════════════════════════════════════════╗
# ║  ░█▄█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀█░█░░░█▀█░█▀▀░█░█  ║
# ║  ░█░█░█▀▀░░█░░█▀█░█░█░█░█░█░█░█░░░█░█░█░█░░█░  ║
# ║  ░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░  ║
# ╚════════════════════════════════════════════════╝
#
# Force XDG specification compliance: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest


# follow XDG base dir specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# bootstrap .zshrc to ~/.config/zsh/.zshrc, any other zsh config files can also reside here
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# default programs
export EDITOR="nvim"
export TERM="st"
export TERMINAL="st"
# export MUSPLAYER="termusic"
export BROWSER="librewolf"
export BROWSER2="firefox"
# export DISPLAY=:0 # useful for some scripts

# history files
export LESSHISTFILE="$XDG_CACHE_HOME/less_history"
export PYTHON_HISTORY="$XDG_DATA_HOME/python/history"

###########################
#          PATHS          #
###########################
# add scripts to path
export PATH=$HOME/.local/bin:/usr/local/bin:/opt/nvim/:$PATH
# export PATH="$XDG_CONFIG_HOME/scripts:$PATH"

# ======== XDG Compliance ======== #
# https://wiki.archlinux.org/title/XDG_Base_Directory

# moving other files and some other vars
# export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"
# export XPROFILE="$XDG_CONFIG_HOME/x11/xprofile"
# export XRESOURCES="$XDG_CONFIG_HOME/x11/xresources"
# export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0" # gtk 3 & 4 are XDG compliant
# export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
# export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
# export GNUPGHOME="$XDG_DATA_HOME/gnupg"
# export CARGO_HOME="$XDG_DATA_HOME/cargo"
# export GOPATH="$XDG_DATA_HOME/go"
# export GOBIN="$GOPATH/bin"
# export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
# export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
# export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
# export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
# export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"
# export _JAVA_AWT_WM_NONREPARENTING=1
# export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
# export FFMPEG_DATADIR="$XDG_CONFIG_HOME/ffmpeg"
# export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
# export DATE=$(date "+%A, %B %e  %_I:%M%P")
#
###########################
#         PLUGINS         #
###########################

# ======== 1Password ======== #
export SSH_AUTH_SOCK=~/.1password/agent.sock

# ======== emoji-fzf ======== #
zinit light-mode wait lucid for pschmitt/emoji-fzf.zsh
# Path to the emoji-fzf executable
EMOJI_FZF_BIN_PATH="emoji-fzf"
# Bind to Ctrl-K by default. Unset to disable.
EMOJI_FZF_BINDKEY=
# Fuzzy matching tool to use for the emoji selection
EMOJI_FZF_FUZZY_FINDER=fzf
# Optional arguments to pass to the fuzzy finder tool
EMOJI_FZF_FUZZY_FINDER_ARGS=
# Path to an optional custom alias JSON file
EMOJI_FZF_CUSTOM_ALIASES=
# Set to non-empty value to prepend the emoji before the emoji aliases
EMOJI_FZF_PREPEND_EMOJIS=1
# Set to non-empty value to skip the creation of shell aliases
EMOJI_FZF_NO_ALIAS=
# Set clipboard management tool
EMOJI_FZF_CLIPBOARD="wl-copy"

# ======== fzf ======== #
# use fd instead of find
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"    # use fd for ctrl-t
# Preview directories with tree 
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Rose Pine Dawn Theme
export FZF_DEFAULT_OPTS="
	--color=fg:#797593,bg:#faf4ed,hl:#d7827e
	--color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
	--color=border:#dfdad9,header:#286983,gutter:#faf4ed
	--color=spinner:#ea9d34,info:#56949f,separator:#dfdad9
	--color=pointer:#907aa9,marker:#b4637a,prompt:#797593"
# export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 30% --preview='bat -p --color=always {}'"
export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview" # separate opts for history widget
export MANPAGER="less -R --use-color -Dd+r -Du+b" # colored man pages
export STARSHIP_CONFIG=$HOME/.config/starship.toml

# colored less + termcap vars
export LESS="R --use-color -Dd+r -Du+b"
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"
