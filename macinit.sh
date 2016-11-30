#!/usr/bin/env bash

# macinit.sh
# Brandon Freitag, 2016

{
  LOG=macinit.log

  # install brew
  if test ! `which brew`; then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" >> $LOG
  fi

  # install binaries
  echo "Installing binaries..."
  binaries=(
    asciinema
    bash
    bash-completion
    Caskroom/cask/brew-cask
    Caskroom/cask/java
    cmake
    coreutils
    ffmpeg
    findutils
    git
    gnutls
    golang
    homebrew/dupes/grep
    htop
    irssi
    leiningen
    lua
    nmap
    python
    python3
    rust
    tmux
    vim
    youtube-dl
  )
  brew update >> $LOG
  brew tap homebrew/dupes >> $LOG
  brew install ${binaries[@]} >> $LOG
  brew cleanup >> $LOG

  # install apps
  echo "Installing apps..."
  apps=(
    chromium
    iterm2
    sketch
    spotify
  )
  brew cask install --appdir="/Applications" ${apps[@]} >> $LOG

  # setup git
  read -p 'Name: ' name
  git config --global user.name "${name}"
  unset name
  read -p 'Email: ' email
  git config --global user.email "${email}"
  echo "Set up git."

  # generate ssh key
  echo "Generating ssh key..."
  ssh-keygen -t rsa -b 4096 -C "${email}" >> $LOG
  unset email
  eval "$(ssh-agent -s)" >> $LOG
  ssh-add ~/.ssh/id_rsa >> $LOG

  # add key to github
  read -p 'GitHub username: ' un
  read -sp 'GitHub password: ' pw
  curl -u \
    "${un}:${pw}" \
    --data "{\"title\":\"${HOSTNAME}\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}" \
    https://api.github.com/user/keys >> $LOG
  unset un
  unset pw
  echo "Added ssh key to GitHub."

  # clone repos
  read -p "Dotfiles repo path: " dotfiles
  git clone https://github.com/$dotfiles  ~/src/dotfiles >> $LOG
  unset dotfiles
  echo "Cloned dotfiles repo."

  # install dotfiles
  echo "Installing dotfiles..."
  cd ~/src/dotfiles
  ./install.sh
  cd ~

  # setup vim
  echo "Setting up vim..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >> $LOG
  vim +PlugInstall +qall
  mkdir ~/.vim/undo

  # install nvm
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash >> $LOG
  source ~/.bash_profile
  nvm install stable >> $LOG
  nvm use stable >> $LOG
  nvm alias default stable >> $LOG

  # echo switch shells command
  echo -e "To finish setup, execute the following command:\n"
  echo -e "\tchsh -s /usr/local/bin/bash"
}
