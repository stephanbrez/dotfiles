function dsx() {
  find . -name "*.DS_Store" -type f -delete
}

# Extract
function extract () 
{
  if [ -z "$1" ]; then
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
  else
    if [ -f $1 ]; then
      case $1 in
        *.tar.bz2)   tar xvjf $1    ;;
        *.tar.gz)    tar xvzf $1    ;;
        *.tar.xz)    tar xvJf $1    ;;
        *.lzma)      unlzma $1      ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar x -ad $1 ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xvf $1     ;;
        *.tbz2)      tar xvjf $1    ;;
        *.tgz)       tar xvzf $1    ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *.xz)        unxz $1        ;;
        *.exe)       cabextract $1  ;;
        *)           echo "extract: '$1' - unknown archive method" ;;
      esac
    else
      echo "$1 - file does not exist"
    fi
  fi
}

function extract_and_remove () 
{
  extract $1
  rm -f $1
}

# Search in manual
function find_man() {
    man $1 | grep -- $2
}

# Search in aliases
function find_alias() {
  alias | grep -- $1
}

# Make directory and navigate to it
function mcd() { 
  mkdir -pv $1
  cd $1
}                                 

# Jupyter
function ipyki() {
  python -m ipykernel install --user --name=$1 --display-name="Python ($1)"
}
# uv version
function uvpyk() {
    local name="${1:-$(basename "$PWD")}"

    uv run ipython kernel install \
      --user \
      --name "$name" \
      --display-name "Python ($name)"
}

# Wezterm
# Connect to a remote host from .ssh/config file in a new tab
# function wts() {
#     wezterm cli spawn --domain-name SSHMUX:$1
# }


# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	~/.local/bin/yazi/yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
