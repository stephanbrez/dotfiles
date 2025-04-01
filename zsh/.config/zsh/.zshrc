# ███████╗███████╗██╗  ██╗██████╗  ██████╗
# ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#   ███╔╝ ███████╗███████║██████╔╝██║     
#  ███╔╝  ╚════██║██╔══██║██╔══██╗██║     
# ███████╗███████║██║  ██║██║  ██║╚██████╗
# ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#
# read second - loaded by ZDOTDIR env var
#
# ╔════════════════════════════════════════════════╗
# ║  ░█▄█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀█░█░░░█▀█░█▀▀░█░█  ║
# ║  ░█░█░█▀▀░░█░░█▀█░█░█░█░█░█░█░█░░░█░█░█░█░░█░  ║
# ║  ░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░  ║
# ╚════════════════════════════════════════════════╝
# main zsh settings go in this file. 
# env vars in ~/.zprofile
# plugin settings via env vars also in ~/.zprofile

# ======== scripts ======== #
if [ -f /usr/bin/fastfetch ]; then
	fastfetch -c examples/7.jsonc
fi

# ======== keybinds ======== #
# see available keybinds: https://zsh.sourceforge.io/Doc/Release/Key-Bindings.html
# or: zle -al
bindkey '^I^I'   complete-word        # tab          | complete
# bindkey '^[[Z' autosuggest-accept   # shift + tab  | autosuggest
bindkey '^H' autosuggest-clear        # ctrl + H | clear autosuggest
# emacs keybinds
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^k" kill-line          # Delete from cursor to end of line
bindkey "^u" kill-whole-line    # Delete entire line
bindkey "^q" push-line          # Push the current buffer onto the buffer stack and clear the buffer
# bindkey "^j" backward-word
# bindkey "^k" forward-word
# bindkey "^H" backward-kill-word
# ctrl J & K for going up and down in prev commands
bindkey "^J" history-search-forward
bindkey "^K" history-search-backward
bindkey '^r' fzf-history-widget

# ======== aliases ======== #
# [[ -f $ZDOTDIR/aliases.zsh ]] && source $ZDOTDIR/aliases.zsh 

#########################################
# Setup                                 #
#########################################

# ======== history ======== #
export HISTSIZE=100000000
export SAVEHIST=100000000
HIST_STAMPS="%Y.%m.%d"
HISTDUP=erase
export HISTFILE=$XDG_CACHE_HOME/.zsh_history
setopt extended_history
setopt append_history         # append on exit instead of overwrites
setopt share_history          # share across sessions
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
# ======== main opts ======== #
# to see options: set -o
# setopt inc_append_history     # history is appended as soon as cmds executed
setopt auto_menu menu_complete # autocmp first menu match
setopt autocd # type a dir to cd
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
setopt no_case_glob no_case_match # make cmp case insensitive
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell

# --- config ----
# export MANPATH="/usr/local/man:$MANPATH"
# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# ======== zinit ======== #
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# install if not present
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# zsh plugins
# A glance at the new for-syntax – load all of the above
# plugins with a single command. For more information see:
# https://zdharma-continuum.github.io/zinit/wiki/For-Syntax/
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
      zsh-users/zsh-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

# ZVM plugin
# https://github.com/jeffreytse/zsh-vi-mode
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# ======== emoji-fzf ======== #
zinit light-mode wait lucid for pschmitt/emoji-fzf.zsh

# Add in snippets
zinit snippet $ZDOTDIR/aliases.zsh 
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
zinit snippet OMZP::git
zinit snippet OMZP::sudo        # Prefix current or previous commands with sudo by pressing esc twice.
zinit snippet OMZP::1password
# zinit snippet OMZP::tmux
zinit snippet OMZP::vi-mode
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vscode
zinit snippet OMZP::vscode

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ======== completions ======== #
# Pretty colors for completions
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
# case insensitive partial path-completion 
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' 

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"


#########################################
# Other plugins & tools									#
#########################################
# see .zprofile for settings


# ======== batman ======== #
# Read system manual pages (man) using bat as the manual page formatter.
# eval "$(batman --export-env)"
# batman() {
#     BAT_THEME="Solarized (dark)" batman "$@"
#     return $?
# }

# ======== conda ======== #
# source /opt/conda/etc/profile.d/conda.sh  # commented out by conda initialize
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/conda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
        . "/opt/conda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/conda/bin:$PATH"
    fi
fi
unset __conda_setup

# <<< conda initialize <<<

# ======== fzf ======== #
source <(fzf --zsh)

# Use fd (https://github.com/sharkdp/fd) for listing path candidates. 
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}
# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# ======== mamba ======== #
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/opt/conda/bin/mamba';
export MAMBA_ROOT_PREFIX='/$HOME/.local/share/conda';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<


# ======== starship ======== #
# eval "$(starship init zsh)"
# Load starship theme
# line 1: `starship` binary as command, from github release
# line 2: starship setup at clone(create init.zsh, completion)
# line 3: pull behavior same as clone, source init.zsh
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# ======== thefuck ======== #
# Thefuck
eval $(thefuck --alias fuck)

# ======== zoxide ======== #
# init & replace cd
# For completions to work, this must be added after compinit is called
eval "$(zoxide init --cmd cd zsh)"

