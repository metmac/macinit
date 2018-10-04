#!/usr/bin/env bash

# macinit.sh
# Brandon Freitag, 2018

setup_api_token() {
  token="$1"
  echo "export HOMEBREW_GITHUB_API_TOKEN=$token" > "$HOME/.homebrew_api_token"
  source "$HOME/.homebrew_api_token"
}

install_homebrew_and_formulae() {
  if test ! "$(which brew)"; then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  echo "Installing formulae..."
  formulae=(
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
  brew install "${formulae[@]}"
  brew cleanup
}

setup_git() {
  name="$1"
  email="$2"
  echo "Setting up git..."
  git config --global user.name "$name"
  git config --global user.email "$email"
}

generate_ssh_key() {
  email="$1"
  un="$2"
  pw="$3"
  echo "Generating ssh key..."
  ssh-keygen -t rsa -b 4096 -C "$email"
  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/id_rsa"
  read -sp "GitHub authentication code: " otp
  echo
  echo "Adding ssh key to GitHub..."
  curl -fsSL \
    -o /dev/null \
    -u "$un:$pw" \
    -H "X-GitHub-OTP: $otp" \
    --data "{\"title\":\"${HOSTNAME%.local}\",\"key\":\"$(cat ${HOME}/.ssh/id_rsa.pub)\"}" \
    https://api.github.com/user/keys
  unset otp
}

install_dotfiles() {
  un="$1"
  dotfiles="$2"
  echo "Cloning dotfiles repo..."
  git clone "https://github.com/$un/$dotfiles" "$HOME/src/dotfiles"
  echo "Installing dotfiles..."
  cd "$HOME/src/dotfiles"
  ./install
  cd
}

setup_vim() {
  echo "Setting up vim..."
  curl -fsSLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +PlugInstall +qall
  mkdir "$HOME/.vim/undo"
}

install_nvm() {
  echo "Installing nvm..."
  curl -fsSL -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | bash
  source "$HOME/.bash_profile"
  nvm install stable
  nvm use stable
  nvm alias default stable
}

change_shell() {
  echo "$(which bash)" >> /etc/shells
  echo -e "To finish setup, execute the following command:\n"
  echo -e "\tchsh -s $(which bash)"
}

{
  set -e

  echo "1) Setup Homebrew GitHub API token"
  echo "2) Install Homebrew and formulae"
  echo "3) Setup git"
  echo "4) Generate ssh key and add it to GitHub"
  echo "5) Install dotfiles"
  echo "6) Setup vim"
  echo "7) Install nvm"
  echo "8) Change shell"
  read -p "Select steps to run (12345678): " steps
  steps="${steps:-12345678}"

  if [[ "$steps" =~ 1 ]]; then
    read -sp "GitHub Homebrew API token: " token
    echo
  fi
  if [[ "$steps" =~ 3 ]]; then
    read -p "Full Name: " name
  fi
  if [[ "$steps" =~ (3|4) ]]; then
    read -p "Email: " email
  fi
  if [[ "$steps" =~ (4|5) ]]; then
    read -p "GitHub username: " un
  fi
  if [[ "$steps" =~ 4 ]]; then
    read -sp "GitHub password: " pw
    echo
  fi
  if [[ "$steps" =~ 5 ]]; then
    read -p "Dotfiles repo name (dotfiles): " dotfiles
    dotfiles="${dotfiles:-dotfiles}"
  fi

  if [[ "$steps" = *"1"* ]]; then
    setup_api_token "$token"
  fi
  if [[ "$steps" = *"2"* ]]; then
    install_homebrew_and_formulae
  fi
  if [[ "$steps" = *"3"* ]]; then
    setup_git "$name" "$email"
  fi
  if [[ "$steps" = *"4"* ]]; then
    generate_ssh_key "$email" "$un" "$pw"
  fi
  if [[ "$steps" = *"5"* ]]; then
    install_dotfiles "$un" "$dotfiles"
  fi
  if [[ "$steps" = *"6"* ]]; then
    setup_vim
  fi
  if [[ "$steps" = *"7"* ]]; then
    install_nvm
  fi
  if [[ "$steps" = *"8"* ]]; then
    change_shell
  fi
}
