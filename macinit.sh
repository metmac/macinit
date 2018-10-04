#!/usr/bin/env bash

# macinit.sh
# Brandon Freitag, 2017

{
  set -e

  read -p "Full Name: " name
  read -p "Email: " email
  read -p "GitHub username: " un
  read -sp "GitHub password: " pw
  echo
  read -sp "GitHub Homebrew API Token: " token
  echo
  read -p "Dotfiles repo name (dotfiles): " dotfiles
  dotfiles=${dotfiles:-dotfiles}

  # setup API Token
  echo "export HOMEBREW_GITHUB_API_TOKEN=$token" > $HOME/.homebrew_api_token

  # install brew
  if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  # install binaries
  echo "Installing binaries..."
  binaries=(
    asciinema
    bash
    bash-completion
    caskroom/cask/java
    chezscheme
    chicken
    cmake
    coreutils
    ffmpeg
    findutils
    git
    gnutls
    golang
    grep
    htop
    irssi
    leiningen
    lua
    nmap
    python
    python3
    rust
    sbcl
    tmux
    vim
    youtube-dl
  )
  brew update
  brew install ${binaries[@]}
  brew cleanup

  # setup git
  git config --global user.name "${name}"
  unset name
  git config --global user.email "${email}"
  echo "Set up git."

  # generate ssh key
  echo "Generating ssh key..."
  ssh-keygen -t rsa -b 4096 -C "${email}"
  unset email
  eval "$(ssh-agent -s)"
  ssh-add $HOME/.ssh/id_rsa

  # add key to github
  read -sp "GitHub authentication code: " otp
  echo
  curl \
    -u "${un}:${pw}" \
    -H "X-GitHub-OTP: ${otp}" \
    --data "{\"title\":\"${HOSTNAME}\",\"key\":\"$(cat $HOME/.ssh/id_rsa.pub)\"}" \
    https://api.github.com/user/keys
  unset un
  unset pw
  unset otp
  echo "Added ssh key to GitHub."

  # clone repos
  git clone "https://github.com/$un/$dotfiles" $HOME/src/dotfiles
  unset dotfiles
  echo "Cloned dotfiles repo."

  # install dotfiles
  echo "Installing dotfiles..."
  cd $HOME/src/dotfiles
  ./install
  cd

  # setup vim
  echo "Setting up vim..."
  curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +PlugInstall +qall
  mkdir $HOME/.vim/undo

  # install nvm
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | bash
  source $HOME/.bash_profile
  nvm install stable
  nvm use stable
  nvm alias default stable

  # add new bash to list of usable shells
  echo "$(which bash)" >> /etc/shells

  # echo switch shells command
  echo -e "To finish setup, execute the following command:\n"
  echo -e "\tchsh -s /usr/local/bin/bash"
}
