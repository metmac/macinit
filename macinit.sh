#!/usr/bin/env bash

# macinit.sh
# Brandon Freitag, 2016
# Inspired by Lapwing Labs
# https://github.com/lapwinglabs/blog/blob/master/hacker-guide-to-setting-up-your-mac.md

{
  COUT="macinit.out"

  # install brew
  if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" >> ${COUT}
  fi

  # install binaries
  echo "Installing binaries..."
  binaries=(
    asciinema
    bash
    bash-completion
    Caskroom/cask/brew-cask
    Caskroom/cask/haskell-platform
    Caskroom/cask/java
    coreutils
    closure-compiler
    ffmpeg
    findutils
    git
    golang
    homebrew/dupes/grep
    htop
    irssi
    leiningen
    lua
    mongodb
    mutt
    nmap
    python
    python3
    screenfetch
    reattach-to-user-namespace
    rust
    tmux
    vim
    youtube-dl
  )
  brew update >> ${COUT}
  brew tap homebrew/dupes >> ${COUT}
  brew install ${binaries[@]} >> ${COUT}
  brew cleanup >> ${COUT}

  # install apps
  echo "Installing apps..."
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
  brew cask install --appdir="/Applications" ${apps[@]} >> ${COUT}

  # setup git
  read -p 'Name: ' name
  git config --global user.name "${name}"
  unset name
  read -p 'Email: ' email
  git config --global user.email "${email}"
  echo "Set up git."

  # generate ssh key
  echo "Generating ssh key..."
  ssh-keygen -t rsa -b 4096 -C "${email}" >> ${COUT}
  unset email
  eval "$(ssh-agent -s)" >> ${COUT}
  ssh-add ~/.ssh/id_rsa >> ${COUT}

  # add key to github
  read -p 'GitHub username: ' un
  read -sp 'GitHub password: ' pw
  curl -u \
    "${un}:${pw}" \
    --data '{"title":"${HOSTNAME}","key":"$(cat ~/.ssh/id_rsa.pub)"}' \
    https://api.github.com/user/keys >> ${COUT}
  unset un
  unset pw
  echo "Added ssh key to GitHub."

  # clone repos
  read -p "Dotfiles repo path: " dotfiles
  git clone https://github.com/${dotfiles}  ~/src/dotfiles >> ${COUT}
  unset dotfiles
  echo "Cloned dotfiles repo."

  # link the dotfiles
  echo "Linking dotfiles..."
  if [ -f ~/src/dotfiles/bash_aliases ]; then
    ln -s ~/src/dotfiles/bash_aliases ~/.bash_aliases
  fi
  if [ -f ~/src/dotfiles/bash_colors ]; then
    ln -s ~/src/dotfiles/bash_colors ~/.bash_colors
  fi
  if [ -f ~/src/dotfiles/bashrc ]; then
    ln -s ~/src/dotfiles/bashrc ~/.bash_profile
  fi
  if [ -f ~/src/dotfiles/gitconfig ]; then
    ln -s ~/src/dotfiles/gitconfig ~/.gitconfig
  fi
  if [ -f ~/src/dotfiles/gitignore ]; then
    ln -s ~/src/dotfiles/gitignore ~/.gitignore
  fi
  if [ -f ~/src/dotfiles/tmux.conf ]; then
    ln -s ~/src/dotfiles/tmux.conf ~/.tmux.conf
  fi
  if [ -f ~/src/dotfiles/vimrc ]; then
    ln -s ~/src/dotfiles/vimrc ~/.vimrc
  fi

  # setup vim
  echo "Setting up vim..."
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim >> ${COUT}
  vim +PluginInstall +qall
  mkdir ~/.vim/undo

  # install nvm
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash >> ${COUT}
  source ~/.bash_profile
  nvm install stable >> ${COUT}
  nvm use stable >> ${COUT}
  nvm alias default stable >> ${COUT}

  # echo switch shells command
  echo "To finish setup, execute the following command:"
  echo "chsh -s /usr/local/bin/bash"
}
