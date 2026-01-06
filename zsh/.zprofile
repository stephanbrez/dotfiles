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
# TODO:
# set wget-hsts file location
#
# ╔════════════════════════════════════════════════╗
# ║  ░█▄█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀█░█░░░█▀█░█▀▀░█░█  ║
# ║  ░█░█░█▀▀░░█░░█▀█░█░█░█░█░█░█░█░░░█░█░█░█░░█░  ║
# ║  ░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░  ║
# ╚════════════════════════════════════════════════╝
#
# Force XDG specification compliance: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest


# You may need to manually set your language environment
export LANG=en_US.UTF-8

# follow XDG base dir specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# bootstrap .zshrc to ~/.config/zsh/.zshrc, any other zsh config files can also reside here
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# default programs
export EDITOR="nvim"
# --- config ----
# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
# export TERM="/usr/bin/open-wezterm-here"
# export TERMINAL="/usr/bin/open-wezterm-here"
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
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH="/usr/local/bin:/opt/nvim/:$XDG_CONFIG_HOME/.cargo/bin:$PATH"
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
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export CONDA_ROOT="/opt/conda/";
export CONDA_EXE="$CONDA_ROOT/bin/conda";
export MAMBA_EXE="$CONDA_ROOT/bin/mamba";
export MAMBA_ROOT_PREFIX="$XDG_DATA_HOME/conda";
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
EMOJI_FZF_CLIPBOARD="xsel -b"

# ======== fzf ======== #
# https://github.com/junegunn/fzf

# use fd instead of find
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"    # use fd for ctrl-t
# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --preview 'batcat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# use fd for subdirectories
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
# Preview directories with eza 
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# history widget settings
# export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview" # separate opts for history widget
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --info inline
  --no-sort
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'
  --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# Rose Pine Dawn Theme
export FZF_DEFAULT_OPTS="
	--color=fg:#797593,bg:#faf4ed,hl:#d7827e
	--color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
	--color=border:#dfdad9,header:#286983,gutter:#faf4ed
	--color=spinner:#ea9d34,info:#56949f,separator:#dfdad9
	--color=pointer:#907aa9,marker:#b4637a,prompt:#797593"
# export FZF_DEFAULT_OPTS="--style minimal --color 16 --layout=reverse --height 30% --preview='bat -p --color=always {}'"
# export MANPAGER="less -R --use-color -Dd+r -Du+b" # colored man pages
export STARSHIP_CONFIG=$HOME/.config/starship.toml

# colored less + termcap vars
export LESS="-R"
# Start blink → set text to bold red
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
# Start bold → set text to bold cyan
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
# End all modes (reset to normal text)
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
# Start standout (reverse video or highlight) → blue background + yellow text
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
# End standout → reset formatting
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
# Start underline → bold green
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
# End underline → reset formatting
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"
