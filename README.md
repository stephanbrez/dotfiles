# Dotfiles

- [Dotfiles](#dotfiles)
  * [Introduction](#introduction)
    + [Try Before you Buy](#try-before-you-buy)
    + [Machine Specific Config](#machine-specific-config)
  * [Organization](#organization)
    + [Home Directories](#home-directories)
    + [Dotfiles](#dotfiles-1)
  * [Requirements](#requirements)
    + [Git](#git)
    + [Stow](#stow)
  * [Installation](#installation)
    + [Install Script](#install-script)
    + [Manual Install](#manual-install)


## Introduction

This isn't *yet another collection of dotfiles*. Why? Through the process of writing an install script I got tired of having to spin up a new virtual machine to test each new version. This led to the following two major features (laziness: the true driver of innovation):

### Try Before you Buy
With the use of *Stowaway Catcher* (a wrapper for [stow](https://www.gnu.org/software/stow/)), you can selectively use, backup, and adopt dotfiles on a package by package basis. This means you can try these (or any) dotfiles before committing to them, before or after forking this repo. *e.g.* Changed your mind about a specific package? Run the installer again and re-do the dotfiles setup. It's also really useful if you have several machines and only want to use some packages and dotfiles on certain ones (see below).

### Machine Specific Config
Don't want to install packages & apps on your machine? No problem, you can only install dotfiles.
Have more than one machine (like a desktop & laptop)? You can select separate package install configs.

**Other useful ideas & concepts**
There are a lot of great dotfiles managers and solutions out there. A lot of them unfortunately force you to use their naming scheme/file structure/methodology. Dotfiles are very personal, and you may have already spent a lot time organizing them how you want. If you're going to use this repo (isn't that the point of public repos?), wouldn't it be nice if it required minimal changes on your part? It would also be convenient if personalization only had to be done in one file–instead of 5 in 5 directories–wouldn't it? Or better yet, wouldn't it be great if the installer was interactive so you didn't have to figure out how to make changes?

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
└──  ▄█▀ ▀█▀ ▐▄█ █▀ █▀
```

### Dotfiles

To make it easier to install and configure apps individually, each app has a folder in `~/.dotfiles`. The structure mirrors the home directory structure. The contents then can be symlinked to the proper location in `~` on an app by app basis.
🚨 *Not following this structure will cause Stow and Stowaway Catcher to break.*

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

## Requirements

At the bare minimum you'll need these to install dotfiles:

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

🛠️ ## Installation
You can use the interactive install script, or if you're feeling a little masochistic, you can do a manual install.

### Install Script
Automate the setup of your dotfiles with this handy script!

Manually download the script from [here](https://github.com/stephanbrez/dotfiles/blob/main/install.sh) or run the commands below in your favorite terminal.

You'll need curl for the fully automated setup:
`apt install curl` or `dnf install curl` or `pacman -S curl` or `brew install curl`

First download the script into your **home**:
```
cd ~
curl -LO https://raw.githubusercontent.com/stephanbrez/dotfiles/main/install
```

Check the script if you want to doublecheck everything (you should never trust explicitly!):
```
less install
```

Make it executable and then run it *with sudo*:
```
chmod +x install && sudo ./install
```

### Manual Install

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
