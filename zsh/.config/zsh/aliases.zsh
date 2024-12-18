#  █████╗ ██╗     ██╗ █████╗ ███████╗███████╗███████╗
# ██╔══██╗██║     ██║██╔══██╗██╔════╝██╔════╝██╔════╝
# ███████║██║     ██║███████║███████╗█████╗  ███████╗
# ██╔══██║██║     ██║██╔══██║╚════██║██╔══╝  ╚════██║
# ██║  ██║███████╗██║██║  ██║███████║███████╗███████║
# ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
# 
# Run this to find alias ideas
# history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10

# -----------------
# Quick edit config files #
# -----------------
alias starshipcfg="nvim $STARSHIP_CONFIG"         # Edit starship config
alias zshrc="nvim $HOME/.zshrc"                   # Edit zsh config
alias zaliases="nvim ~/.config/zsh/aliases.zsh"   # Edit zsh aliases

# -----------------
# File commands   #
# -----------------
if which batcat >/dev/null 2>&1; then bat="batcat" else bat="bat" fi    # Debian fix
alias mf="fzf | xargs ls -l"      # Show info for searched file
alias pf="fzf --preview='$bat --theme=base16 --style=numbers,header,changes --color=always {}' --bind k:preview-up,j:preview-down"
alias mdir="mkdir -p"          # Create parent directories
function mcd() { 
  mkdir -pv $1
  cd $1
}                                 # Make directory and navigate to it
alias rm="rm -i"                  # Remove a file with confirmation
alias cp="cp -i"                  # Copy a file with confirmation
alias mv="mv -i"                  # Move a file with confirmation
alias du="du -ch"                 # File usage in human readable w/ total
alias df="df -H --total"          # Disk usage in human readable w/ total
alias dud="du -d 1 -h"            # Directory usage in human readable
alias t="tail -f"                 # Tail a file
alias lc="find . -type f | wc -l" # Count all files in current directory
alias lu="du -ah | sort -h"       # Show size of all files and folders in current directory

# ** Uncomment if not using eza ** #
# alias l="ls -lFh"                 # List files as a long list, show size, type, human-readable
# alias la="ls -GhAlF"              # List almost all files as a long list show size, type, human-readable 
# alias ld="ls -al | grep ^d"       # List all directories in current directory in long list format
# alias ldot="ls -ld .*"            # List dotfiles in current directory
# alias ll="ls -l"                  # List files in long list format
# alias lt="ls -1tFh"               # List files as a long list sorted by date, show type, human-readable
# alias lr="ls -tR"                 # List files recursively sorted by date, show type, human-readable
# alias lS="ls -1FSsh"    	        # List files showing only size and name sorted by size
# alias lart="ls -1Fcart"           # List all files sorted in reverse of create/modification time (oldest first)
# alias lrt="ls -1Fcrt"             # List files sorted in reverse of create/modification time(oldest first)
# alias lsr="ls -lARFh"             # List all files and directories recursively
# alias lsn="ls -1"                 # List files and directories in a single column
# alias fcd="cd /**<TAB>"         # CD by fuzzy search

## eza aliases ##
alias l="eza -la --icons --group-directories-first --git"
alias ls="eza"
alias la="eza -a --icons"             # List all files
alias ll="eza -l --icons"             # List files in long list format
alias lL="eza -al --icons"            # List all files in long list format
alias lf="eza -f"                     # List files only
alias lF="eza -af"                    # List all files only
alias llf="eza -lf"                   # List files in long list format
alias llF="eza -alf"                  # List all files in long list format
alias ld="eza -D"                     # List directories in current directory
alias lD="eza -aD"                    # List all directories in current directory
alias lld="eza -lD"                   # List directories in current directory in long list format
alias llD="eza -laD"                  # List all directories in long list format
alias lldot="eza -ld .*"              # List dotfiles in current directory
alias lt="eza -snewest --icons"               # List files as a list sorted by date
alias llt="eza -l -snewest --icons"           # List files as a long list sorted by date
alias llT="eza -al -snewest --icons"          # List all files as a long list sorted by date
alias lrt="eza -l -soldest --icons"           # List files as a list sorted by reverse date
alias lrT="eza -al -soldest --icons"          # List all files as a long list sorted by reverse date
alias lls="eza -l -ssize --icons"             # List files as a long list sorted by size
alias llS="eza -al -ssize --icons"            # List all files as a long list sorted by size
alias lrS="eza -l -ssize --reverse --icons"   # List files as a long list sorted by reverse date
alias tree="eza -l --tree"
alias tree2="eza -l --tree --level=2"
alias tree3="eza -l --tree --level=3"
alias tree4="eza -l --tree --level=4"
alias tree5="eza -l --tree --level=5"
alias tree6="eza -l --tree --level=6"

# -----------------
# Navigation      #
# -----------------

# ** Uncomment if not using oh my zsh ** ##
## Quickly get out of current directory ##
alias ..="cd .."
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"
alias 1="cd -1"
alias 2="cd -2"
alias 3="cd -3"
alias 4="cd -4"
alias 5="cd -5"
alias 6="cd -6"
alias 7="cd -7"

## Comment if not using zoxide ##
alias zz="z -"                    # Zoxide last directory

# Common commands #
alias al="echo '------------Your curent aliases are:------------¡'; alias" # List aliases
alias reload="source $HOME/.zshrc"    # Reload zsh config
alias sudo="sudo -v; sudo "           # Make sudo work with aliases & refresh the password timeout
alias root="sudo -i"                  # Switch to root user
alias ffs="sudo !!"                   # Rerun prev command with sudo 
alias grep="grep --color=auto"        # Colorize Grep output
alias ff="find . -type f -name"       # Find a file with name 
alias fdir="find . -type d -name"     # Find a directory with name
alias c="clear"                       # Clear
alias h="history -i | nl"             # History
alias hs="history | fzf +s --tac"     # Search terminal history
alias j="jobs -l"                     # List jobs
alias p="ps -f"                       # Display current processes
function find_man() {
    man $1 | grep -- $2
}

# -----------------
# Global aliases  #
# -----------------
alias -g H="| head"               # Pipes output to head which outputs the first part of a file
alias -g T="| tail"               # Pipes output to tail which outputs the last part of a file
alias -g G="| grep"               # Pipes output to grep to search for some word
alias -g L="| less"               # Pipes output to less, useful for paging
alias -g M="| most"               # Pipes output to more, useful for paging
alias -g LL="2>&1 | less"         # Writes stderr to stdout and passes it to less
alias -g CA="2>&1 | cat -A"       # Writes stderr to stdout and passes it to cat
alias -g NE="2 > /dev/null"       # Silences stderr
alias -g NUL="> /dev/null 2>&1"   # Silences both stdout and stderr

# -----------------
# Shortcuts       #
# -----------------
alias dotfiles="cd ~/.dotfiles"                   # Navigate to dotfiles
alias src="cd ~/.local/src"                       # Navigate to src

# -----------------
# Apps and Tools  #
# -----------------

# Update packages based on OS #
if [[ $OSTYPE == darwin* ]]; then
  alias update="brew update && brew upgrade"
else
  alias update="sudo apt update && sudo apt upgrade -y && flatpak update -y" 
fi

# Default programs #
alias -s txt=nvim             # Open txt files with nvim
# alias vi='vim'                  # Open vim instead of vi

# Archives #
alias zipl="unzip -l"           # List zip contents
alias rarl="unrar l"            # List rar contents
alias tarl="tar -tvf"           # List tar contents
alias tar.gz="tar -zvtf"       # List tar.gz contents
alias acel="unace l"            # List ace contents

# Anaconda #
alias ca="conda activate"     # Activate conda
alias cda="conda deactivate"  # Deactivate conda
alias ceu="conda env update"  # Update conda environment
alias cle="conda env list"    # List conda environments
alias clp="conda list"        # List conda packages
alias cmk="conda create"      # Create conda env
function ccp ()
{
  conda create --clone $1 --name $2
}                             # Clone a conda env
alias ci="conda install"      # Install conda package
alias cr="conda remove"       # Remove conda package
alias mi="mamba install"      # Install mamba package
alias mr="mamba remove"       # Remove mamba package
alias mle="mamba env list"    # List mamba environments
alias mlp="mamba list"        # List mamba packages

# Git #
function g() { git $1 }             # Shorten git 
alias gb="git branch"
alias gc="git commit -m"
alias gcb="git checkout -b"
alias gco="git checkout"
alias gd="git diff"
alias gf="git fetch"
alias gm="git merge"
alias gld='git log --pretty=format:"%h %ad %s" --date=short --all' # Detailed log
alias glog="git log --all --oneline --decorate --graph" # Pretty log
alias gp="git push"
alias gpo="git push origin"
alias gpom="git push origin master"
alias gpu="git pull"
alias gs="git status"               # Git status
function gacp() {
  git add .
  if [ "$1" != "" ]
  then
      git commit -m "$1"
  else
      git commit -m update # default commit message is `update`
  fi
  git push
}

# Jupyter #
alias jn="jupyter notebook"

# Neovim/vim #
alias nv='nvim'                   # Open neovim
alias nvf='nvim -o `fzf`'         # Edit file by fuzzy search
alias sv='sudo vi'                # Open vi as sudo

# openvpn
alias ovpnstop="openvpn3 session-manage --disconnect"
alias ovpnc="1password && openvpn3 session-start --config /etc/openvpn3/surfshark/us-nyc.prod.surfshark.com_udp.ovpn"
alias ovpnd="openvpn3 session-manage --config /etc/openvpn3/surfshark/us-nyc.prod.surfshark.com_udp.ovpn --disconnect"

# PKM #
alias pkm="cd ~/Documents/BC_PKM/ && nv"

#ssh
alias sshkey="cat ~/.ssh/id_rsa.pub"                    # View ssh key
alias sshcfg="vi ~/.ssh/config"                         # Edit ssh key
alias sshcpkey='command cat ~/.ssh/id_rsa.pub | pbcopy' # Copy ssh key

#tdf
alias tdf="tdfgo fonts -vp"                 # Find & preview fonts in tdfgo

# tmux
alias tn="tmux new -s $(pwd | sed 's/.*\///g')"         # New session named after current path 
