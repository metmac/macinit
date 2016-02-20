#!/usr/bin/env bash

# macinit.sh
# Brandon Freitag, 2016
# Inspired by Lapwing Labs
# https://github.com/lapwinglabs/blog/blob/master/hacker-guide-to-setting-up-your-mac.md

{
  # install brew
  # check for Homebrew,
  # install if we don't have it
  if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  # install binaries
  binaries=(
    coreutils
    findutils
    bash
    bash-completion
    caskroom/cask/brew-cask
    ffmpeg
    git
    homebrew/dupes/grep
    htop
    irssi
    leiningen
    mongodb
    nmap
    python
    python3
    screenfetch
    tmux
    vim
  )
  echo "Installing binaries..."
  brew update
  brew tap homebrew/dupes
  brew install ${binaries[@]}
  brew cleanup

  # install Apps
  apps=(
    dropbox
    evernote
    firefox
    google-chrome
    iterm2
    sketch
    skype
    slack
    spotify
    transmission
    vlc
  )
  echo "Installing apps..."
  brew cask install --appdir="/Applications" ${apps[@]}

  # setup git
  git config --global user.name "Brandon Freitag"
  git config --global user.email "freitagbr@gmail.com"

  # generate ssh key
  ssh-keygen -t rsa -b 4096 -C "freitagbr@gmail.com"

  # add key to ssh-agent
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa

  # add key to github
  curl -u "username" --data '{"title":"${HOSTNAME}","key":"$(cat ~/.ssh/id_rsa.pub)"}' https://api.github.com/user/keys

  # clone repos
  git clone https://github.com/freitagbr/dotfiles ~/src/dotfiles

  # link the dotfiles
  ln -s ../../.bash_aliases ~/src/dotfiles/bash_aliases
  ln -s ../../.bash_colors ~/src/dotfiles/bash_colors
  ln -s ../../.bash_profile ~/src/dotfiles/bashrc
  ln -s ../../.gitconfig ~/src/dotfiles/gitconfig
  ln -s ../../.gitignore ~/src/dotfiles/gitignore
  ln -s ../../.tmux.conf ~/src/dotfiles/tmux.conf
  ln -s ../../.vimrc ~/src/dotfiles/vimrc

  # setup vim
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall

  # install nvm
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
  source ~/.bash_profile
  nvm install stable
  nvm use stable
  nvm alias default stable
}
