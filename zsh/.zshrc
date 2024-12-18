export PATH=$HOME/.local/bin:/usr/local/bin:/opt/nvim/:$PATH

# ======== scripts ======== #
if [ -f /usr/bin/fastfetch ]; then
	fastfetch -c examples/7.jsonc
fi

# ======== keybinds ======== #
bindkey '^I^I'   complete-word       # tab          | complete
# bindkey '^[[Z' autosuggest-accept  # shift + tab  | autosuggest
# bindkey '^H' autosuggest-clear		#			| clear autosuggest	

# ======== aliases ======== #
export ZSHRC_CONFIG=$HOME/.config/zsh
[[ -f $ZSHRC_CONFIG/aliases.zsh ]] && source $ZSHRC_CONFIG/aliases.zsh 

#########################################
# Setup                          				#
#########################################

# ======== history ======== #
export HISTSIZE=100000000
export SAVEHIST=100000000
HIST_STAMPS="%Y.%m.%d"
HISTDUP=erase
export HISTFILE=$HOME/.zsh_history
setopt extended_history
setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

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

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::1password
# zinit snippet OMZP::tmux
zinit snippet OMZP::vi-mode
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
# ======== 1Password ======== #
export SSH_AUTH_SOCK=~/.1password/agent.sock

# ======== batman ======== #
# Read system manual pages (man) using bat as the manual page formatter.
# eval "$(batman --export-env)"
# batman() {
#     BAT_THEME="Solarized (dark)" batman "$@"
#     return $?
# }

# ======== conda ======== #
source /opt/conda/etc/profile.d/conda.sh

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
source <(fzf --zsh)

# use fd instead of find
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"    # use fd for ctrl-t
# Preview directories with tree 
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates. 
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}
# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}
# Rose Pine Dawn Theme
export FZF_DEFAULT_OPTS="
	--color=fg:#797593,bg:#faf4ed,hl:#d7827e
	--color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
	--color=border:#dfdad9,header:#286983,gutter:#faf4ed
	--color=spinner:#ea9d34,info:#56949f,separator:#dfdad9
	--color=pointer:#907aa9,marker:#b4637a,prompt:#797593"

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
export STARSHIP_CONFIG=$HOME/.config/starship.toml

# ======== thefuck ======== #
# Thefuck
eval $(thefuck --alias fuck)

# ======== zoxide ======== #
# init & replace cd
# For completions to work, this must be added after compinit is called
eval "$(zoxide init --cmd cd zsh)"

