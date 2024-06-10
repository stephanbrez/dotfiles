# Dotfiles

## Requirements

These are required to install dotfiles:

### Git

```
brew install git
```

or

```
sudo apt install git
```

### Stow

```
brew install stow
```

or

```
sudo apt install stow
```

## Installation

Check out the [dotfiles repo](https://github.com/stephanbrez/dotfiles)

```
git clone https://github.com/stephanbrez/dotfiles.git
cd ~/.dotfiles
```

Use `stow` to symlink all the files

```
stow . -t ~ --adopt
```

The adopt flag will overwrite all files in `~/.dotfiles` with any matching files in `~`. To restore the files from the remote repo, run:

```
git restore .
```

## Organization

### Home Directories

Following [xdg base directories standards](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

```
.
├── .config/ $XDG_CONFIG_HOME --> app specific configs
│   ├── nvim
│   ├── tmux
│   ├── zsh       --> each app has a folder
│   │   └── zshrc --> config files
│   └── etc...
├── .dotfiles/   --> this repo
├── .local/
│   ├── bin/   $PATH            --> my scripts
│   ├── cache/ $XDG_CACHE_HOME  --> runtime files
│   ├── docs/  ~docs            --> my documents
│   ├── lib/   $pkgManger_HOME  --> app libraries
│   ├── share/ $XDG_DATA_HOME   --> shared app files
│   ├── src/
│   │   └── other_code/
│   └── state/ $XDG_STATE_HOME  --> app state files
│       └── zsh/
│           └── history --> app created files
├── .ssh/
│   ├── authorized_keys
│   ├── config
│   └── known_hosts
└── ▄█▀ █▬█ █ ▀█▀
```

### Dotfiles

To make it easier to install and configure apps individually, each app has a folder in `~/.dotfiles`. The structure mirrors the home directory structure. The contents then can be symlinked to the proper location in `~` on an app by app basis.

```
.dotfiles/
├── README.md
├── starship
│   └── .config
│       └── starship.toml   --> symlinked to ~/.config
└── tmux                    --> app folder
    └── .config
        └── tmux            --> symlinked to ~/.config
            └── tmux.conf   --> config files
```
### Install Script
Automate the setup of your dotfiles with this handy script!

Manually download the script from [here](https://github.com/stephanbrez/dotfiles/blob/main/install.sh) or run the commands below in your favorite terminal.

You'll need curl, so install if needed:
`apt install curl` or `dnf install curl` or `pacman -S curl` or `brew install curl`

First download the script:
```
cd ~
curl -LO https://raw.githubusercontent.com/stephanbrez/dotfiles/main/install
```

Check the script (you should never trust explicitly!):
```
less install
```

Make it executable and then run it *with sudo*:
```
chmod +x install && sudo ./install
```
