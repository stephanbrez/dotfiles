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
# Extra aliases   #
# -----------------
alias_path="$ZDOTDIR/server_aliases.zsh"
[[ -f "$alias_path" ]] && source "$alias_path"

# -----------------
# Quick edit config files #
# -----------------
alias starshipcfg="nvim $STARSHIP_CONFIG"      # Edit starship config
alias zprofile="nvim $HOME/.zprofile"          # Edit zsh profile
alias zshrc="nvim $ZDOTDIR/.zshrc"             # Edit zsh config
alias zaliases="nvim $ZDOTDIR/aliases.zsh"     # Edit zsh aliases
alias zfunctions="nvim $ZDOTDIR/functions.zsh" # Edit zsh functions

# -----------------
# File commands   #
# -----------------
# Debian fix
if command -v batcat >/dev/null 2>&1; then
    alias bat="batcat"
else
    alias bat="bat"
fi
alias mf="fzf | xargs ls -l"      # Show info for searched file
alias pf="fzf --preview='$bat --theme=base16 --style=numbers,header,changes --color=always {}' --bind k:preview-up,j:preview-down"
alias mdir="mkdir -p"          # Create parent directories
alias rm="rm -i"                  # Remove a file with confirmation
alias cp="cp -i"                  # Copy a file with confirmation
alias mv="mv -i"                  # Move a file with confirmation
alias du="du -ch"                 # File usage in human readable w/ total
alias dud="du -d 1 -h"            # Directory usage in human readable
alias df="df -H --total"          # Total disk usage in human readable w/ total
alias t="tail -f"                 # Tail a file
alias lc="find . -type f | wc -l" # Count all files in current directory
alias lu="du -ah | sort -h"       # Show size of all files and folders in current directory
alias lb="lsblk -fp"              # List all block devices
alias lcf="rename 'y/A-Z/a-z/' "  # Rename uppercase to lowercase
alias ucf="rename 'y/a-z/A-Z/' "  # Rename lowercase to uppercase

# alias chmod commands
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

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
alias l="eza -la --icons --smart-group --group-directories-first --git"
alias ls="eza"
alias la="eza -a --icons"             # List all files
alias ll="eza -l --icons"             # List files in long list format
alias lL="eza -alg --icons"            # List all files in long list format with groups
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

###################
# Navigation      #
###################

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

# -----------------
# Common commands #
# -----------------
alias al="echo '------------Your curent aliases are:------------¡'; alias" # List aliases
alias reload="exec zsh -l"  	# Reload zsh config
alias sudo="sudo -v; sudo "		# Make sudo work with aliases & refresh the password timeout
alias root="sudo -i"			# Switch to root user
alias se="sudo -e"			    # Edit files with sudo
alias ffs="sudo !!"			    # Rerun prev command with sudo 
alias ffa="!:0"                # Rerun prev command without arguments
alias grep="grep --color=auto"		# Colorize Grep output
alias ff="find . -type f -name"		# Find a file with name 
alias fdir="find . -type d -name"	# Find a directory with name
alias c="clear"				# Clear
alias h="history | nl"			# History
alias hs="history 50 | fzf +s --tac"  # Search last 50 terminal history
alias j="jobs -l"                     # List jobs
alias p="ps -f"                       # Display current processes

# -----------------
# Global aliases  #
# -----------------
alias -g H="| head"               # Pipes output to head which outputs the first part of a file
alias -g T="| tail"               # Pipes output to tail which outputs the last part of a file
alias -g G="| rg"                 # Pipes output to ripgrep to search for some word
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
# --- Apt ---
alias aptcs='apt-cache search'
alias apti='sudo apt install'
alias aptr='sudo apt remove'
alias aptre='sudo apt reinstall'
alias apts='apt search'
alias aptsh='sudo apt show'
alias aptu='sudo apt update'
alias aptuu='sudo apt update;sudo apt upgrade;'

# --- Default programs ---
alias -s txt=nvim             # Open txt files with nvim
# alias vi='vim'                  # Open vim instead of vi

# --- Archives ---
# List contents
alias zipl="unzip -l"           # List zip contents
alias rarl="unrar l"            # List rar contents
alias tarl="tar -tvf"           # List tar contents
alias tar.gz="tar -zvtf"            # List tar.gz contents
alias acel="unace l"                # List ace contents
alias extr="extract"                # functions.zsh
alias extrr='extract_and_remove '   # functions.zsh

# --- Anaconda ---
alias ca="conda activate"                      # Activate the specified conda environment
alias cab="conda activate base"                # Activate the base conda environment
alias ccf="conda env create -f"                 # Create a new conda environment from a YAML file
alias ccn="conda create -y -n"                 # Create a new conda environment with the given name
alias ccp="conda create -y -p"                 # Create a new conda environment with the given prefix (path)
alias cce="conda create -y -p ./envs"                 # Create a new conda environment in ./envs 
alias cc="conda create -n"                     # Create new virtual environment with given name
function ccc ()
{
  conda create --clone $1 --name $2
}                                               # Clone the specified conda env
alias cconf="conda config"                      # View or modify conda configuration
alias css="conda config --show-source"          # Show the locations of conda configuration sources
alias cda="conda deactivate"                    # Deactivate the current conda environment
alias cel="conda env list"                      # List all available conda environments
alias ci="conda install"                        # Install given package
alias ciy="conda install -y"                    # Install given package without confirmation
alias cl="conda list"                           # List installed packages in the current environment
alias cle="conda list --export"                 # Export the list of installed packages in the current environment
alias cles="conda list --explicit > spec-file.txt"  # Export the list of installed packages in the current environment to a spec file
alias cr="conda remove"                         # Remove given package
alias cra="conda remove -y --all -n"            # Remove all packages in the specified environment
alias crp="conda remove -y --all -p"            # Remove environment at specified path
alias cs="conda search"                        # Search conda repositories for package
alias cu="conda update"                        # Update the specified package(s)
alias cua="conda update --all"                 # Update all installed packages
alias cue="conda env update"                   # Update the current environment based on environment file
alias cuf="conda env update --prune"           # Update & prune the current environment based on environment file
alias cuc="conda update conda"                 # Update conda package manager
# Mamba #
alias ma="mamba activate"                      # Activate the specified mamba environment
alias mab="mamba activate base"                # Activate the base mamba environment
alias mcf="mamba env create -f"                 # Create a new mamba environment from a YAML file
alias mcn="mamba create -y -n"                 # Create a new mamba environment with the given name
alias mcp="mamba create -y -p"                 # Create a new mamba environment with the given prefix (path)
alias mc="mamba create -n"                     # Create new virtual environment with given name
function mcc ()
{
  mamba create --clone $1 --name $2
}                                              # Clone the specified mamba env
alias mconf="mamba config"                     # View or modify mamba configuration
alias mss="mamba config --show-source"         # Show the locations of mamba configuration sources
alias mda="mamba deactivate"                   # Deactivate the current mamba environment
alias mel="mamba env list"                     # List all available mamba environments
alias mi="mamba install"                       # Install given package
alias miy="mamba install -y"                   # Install given package without confirmation
alias ml="mamba list"                          # List installed packages in the current environment
alias mle="mamba list --export"                # Export the list of installed packages in the current environment
alias mles="mamba list --explicit > spec-file.txt"  # Export the list of installed packages in the current environment to a spec file
alias mr="mamba remove"                        # Remove given package
alias mra="mamba remove -y -all -n"            # Remove all packages in the specified environment
alias mrp="mamba remove -y --all -p"           # Remove environment at specified path
alias ms="mamba search"                        # Search mamba repositories for package
alias mu="mamba update"                        # Update the specified package(s)
alias muf="mamba env update --prune"           # Update & prune the current environment based on environment file
alias mua="mamba update --all"                 # Update all installed packages
alias mue="mamba env update"                   # Update the current environment
alias muc="mamba update mamba"                 # Update mamba package manager

# --- Avante ---
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'

# --- Docker ---
alias dbl='docker build'            # Build an image from a Dockerfile
alias dcin='docker container inspect'  # Display detailed information on one or more containers
alias dcls='docker container ls'     # List all the running docker containers
alias dclsa='docker container ls -a' # List all running and stopped containers
alias dib='docker image build'      # Build an image from a Dockerfile (same as docker build)
alias dii='docker image inspect'     # Display detailed information on one or more images
alias dils='docker image ls'         # List docker images
alias dipu='docker image push'       # Push an image or repository to a remote registry
alias dipru='docker image prune -a'  # Remove all images not referenced by any container
alias dirm='docker image rm'         # Remove one or more images
alias dit='docker image tag'         # Add a name and tag to a particular image
alias dlog='docker container logs'   # Fetch the logs of a docker container
alias dnc='docker network create'    # Create a new network
alias dncn='docker network connect'  # Connect a container to a network
alias dndcn='docker network disconnect' # Disconnect a container from a network
alias dni='docker network inspect'   # Return information about one or more networks
alias dnls='docker network ls'       # List all networks the engine daemon knows about, including those spanning multiple hosts
alias dnrm='docker network rm'        # Remove one or more networks
alias dpo='docker container port'     # List port mappings or a specific mapping for the container
alias dps='docker ps'                 # List all the running docker containers
alias dpsa='docker ps -a'             # List all running and stopped containers
alias dpu='docker pull'               # Pull an image or a repository from a registry
alias dr='docker container run'       # Create a new container and start it using the specified command
alias drit='docker container run -it' # Create a new container and start it in an interactive shell
alias drm='docker container rm'       # Remove the specified container(s)
alias drm!='docker container rm -f'   # Force the removal of a running container (uses SIGKILL)
alias ds='docker container start'     # Start one or more stopped containers
alias drs='docker container restart'  # Restart one or more containers
alias dsta='docker stop $(docker ps -q)' # Stop all running containers
alias dstp='docker container stop'    # Stop one or more running containers
alias dtop='docker top'               # Display the running processes of a container
alias dvi='docker volume inspect'     # Display detailed information about one or more volumes
alias dvls='docker volume ls'         # List all the volumes known to docker
alias dvprune='docker volume prune'   # Cleanup dangling volumes
alias dxc='docker container exec'     # Run a new command in a running container
alias dxcit='docker container exec -it' # Run a new command in a running container in an interactive shell

# --- Docker Compose ---
alias dc='docker-compose'             # Docker-compose main command
alias dcb='docker-compose build'      # Build containers
alias dce='docker-compose exec'       # Execute command inside a container
alias dcps='docker-compose ps'        # List containers
alias dcrestart='docker-compose restart' # Restart container
alias dcrm='docker-compose rm'        # Remove container
alias dcr='docker-compose run'        # Run a command in container
alias dcstop='docker-compose stop'    # Stop a container
alias dcup='docker-compose up'        # Build, (re)create, start, and attach to containers for a service
alias dcupb='docker-compose up --build' # Same as dcup, but build images before starting containers
alias dcupd='docker-compose up -d'    # Same as dcup, but starts as daemon
alias dcupdb='docker-compose up -d --build' # Same as dcup, but build images before starting containers and starts as daemon
alias dcdn='docker-compose down'      # Stop and remove containers
alias dcl='docker-compose logs'       # Show logs of container
alias dclf='docker-compose logs -f'   # Show logs and follow output
alias dclF='docker-compose logs -f --tail=0' # Just follow recent logs
alias dcpull='docker-compose pull'     # Pull image of a service
alias dcstart='docker-compose start'   # Start a container
alias dck='docker-compose kill'       # Kills containers

# --- Emoji FZF ---
alias emojifzf="fzf --preview 'echo {} | emoji -s' --preview-window=down:50%:wrap --bind 'ctrl-y:execute-silent(echo {} | xsel --clipboard --input)+abort'"
alias emojicat='emoji | xsel | xargs cat'
alias emoj="emoji-fzf preview --prepend | fzf | awk '{ print \$1 }'"
alias emo='emoji | xsel -b'

# --- Git ---
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

# --- Jupyter ---
alias jn="jupyter notebook"
alias ipyk-install='python -m ipykernel install --user --name="$(basename "$CONDA_PREFIX")" --display-name="Python ($(basename "$CONDA_PREFIX"))"'
# More in $ZDOTDIR/functions.zsh

# --- Lazygit ---
alias lg='lazygit'                # Open lazygit

# --- Neovim/vim ---
alias nv='nvim'                   # Open neovim
alias nvf='nvim -o `fzf`'         # Edit file by fuzzy search
alias sv='sudo vi'                # Open vi as sudo

# --- openvpn ---
alias ovpnstop="openvpn3 session-manage --disconnect"
alias ovpnc="1password && openvpn3 session-start --config /etc/openvpn3/surfshark/us-nyc.prod.surfshark.com_udp.ovpn"
alias ovpnd="openvpn3 session-manage --config /etc/openvpn3/surfshark/us-nyc.prod.surfshark.com_udp.ovpn --disconnect"

# --- PKM ---
alias pkm="cd ~/Documents/BC_PKM/ && nv"

# --- ssh ---
alias sshkey="cat ~/.ssh/id_rsa.pub"                    # View ssh key
alias sshcfg="vi ~/.ssh/config"                         # Edit ssh key
alias sshcpkey='command cat ~/.ssh/id_rsa.pub | pbcopy' # Copy ssh key

#tdf
alias tdf="tdfgo fonts -vp"                 # Find & preview fonts in tdfgo

# --- tmux ---
alias tn="tmux new -s $(pwd | sed 's/.*\///g')"         # New session named after current path 

# --- uv ---
# Installing and managing Python itself.
alias uvpyi="uv python install"         # Install Python versions
alias uvpyl="uv python list"            # View available Python versions
alias uvpyf="uv python find"            # Find an installed Python version
alias uvpyp="uv python pin"             # Pin the current project to use a specific Python version
alias uvpyu="uv python uninstall"       # Uninstall a Python version
alias uvpyd="uv python dir"             # Show the uv installed Python versions path

# Scripts
# Executing standalone Python scripts, e.g., example.py.
alias uvr="uv run"                      # Run a script
alias uvas="uv add --script"            # Add a dependency to a script
alias uvrms="uv remove --script"        # Remove a dependency from a script

# Projects
# Creating and working on Python projects, i.e., with a pyproject.toml.
alias uvi="uv init"                     # Create a new Python project
alias uva="uv add"                      # Add a dependency to the project
alias uvrm="uv remove"                  # Remove a dependency from the project
alias uvs="uv sync"                     # Sync the project's dependencies with the environment
alias uvsrc="source .venv/bin/activate" # Activate the python env in the current working directory
alias uvl="uv lock"                     # Create a lockfile for the project's dependencies
alias uvup="uv lock --upgrade-package"  # Upgrade a specific package while keeping the rest of the environment locked
# alias uv14="uv run"                   # Run a command in the project environment
alias uvt="uv tree"                     # View the dependency tree for the project
alias uvb="uv build"                    # Build the project into distribution archives
alias uvp="uv publish"                  # Publish the project to a package index

# Tools
# Running and installing tools published to Python package indexes, e.g., ruff or black.
# alias uvx="uv tool run"             # Run a tool in a temporary environment
alias uvti="uv tool install"          # Install a tool user-wide
alias uvtu="uv tool uninstall"        # Uninstall a tool
alias uvtl="uv tool list"             # List installed tools
alias uvtus="uv tool update-shell"    # Update the shell to include tool executables
alias uvtd="uv tool dir"              # Show the uv tool directory path

# The pip interface
# Manually managing environments and packages — intended to be used in legacy workflows or cases where the high-level commands do not provide enough control.
# Creating virtual environments (replacing venv and virtualenv)
alias uvv="uv venv"                  # Create a new virtual environment

# Managing packages in an environment (replacing pip and pipdeptree)
alias uvpi="uv pip install"           # Install packages into the current environment
alias uvps="uv pip show"              # Show details about an installed package
alias uvpf="uv pip freeze"            # List installed packages and their versions
alias uvpc="uv pip check"             # Check that the current environment has compatible packages
alias uvpl="uv pip list"              # List installed packages
alias uvpu="uv pip uninstall"         # Uninstall packages
alias uvpt="uv pip tree"              # View the dependency tree for the environment

# Locking packages in an environment (replacing pip-tools)
alias uvpc="uv pip compile"           # Compile requirements into a lockfile
alias uvps="uv pip sync"              # Sync an environment with a lockfile

# Utility
# Managing and inspecting uv's state, such as the cache, storage directories, or performing a self-update:
alias uvcc="uv cache clean"           # Remove cache entries
alias uvcp="uv cache prune"           # Remove outdated cache entries
alias uvcd="uv cache dir"             # Show the uv cache directory path
alias uvu="uv self update"           # Update uv to the latest version


# --- Utils ---
alias sitecopy='wget -k -K -E -r -l 10 -p -N -F -nH '

# --- Wezterm ---
# Usage: wtc <hostname> or just use host-specific aliases below
wtc() {
    wezterm connect --new-tab "$1"                  # Connect to host in new tab
}
alias wtd="wezterm disconnect"                      # Disconnect from wezterm session
alias wtl="wezterm cli list"                        # List all windows tabs and panes
wta() {
    wezterm connect "$1"                            # Connect/Attach to SSH domain 
}
# Quick host-specific aliases (using ~/.ssh/config hostnames)
alias wtpi="wezterm connect pinus"
alias wtcl="wezterm connect clawdbot"
# Tab-specific connections (open in new tab)
alias wtpit="wezterm connect --new-tab pinus"
alias wtclt="wezterm connect --new-tab clawdbot"
