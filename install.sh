# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'

# Install the Command Line Tools
set +e
xcode-select -p
RETVAL=$?
set -e
if [[ "$RETVAL" -ne "0" ]]; then
    echo "Installing XCode Command Line Tools"
    xcode-select --install
    read -p "Continue? [Enter]"
fi

# Install brew
if [[ ! -x "/usr/local/bin/brew" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install packages
for package in sqlite coreutils vim git zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting pyenv pyenv-virtualenv mas sfml;
do
  if [[ ! -d "/usr/local/Cellar/${package}" ]]; then
    echo "Installing ${package}"
    brew install ${package}
  fi
done

# Install casks
for cask in firefox google-chrome iterm2 corretto8 intellij-idea-ce visual-studio-code spectacle openemu slack discord zoomus telegram;
do
  if ( brew cask info ${cask} | grep "Not installed" &>/dev/null ); then
    echo "Installing ${cask}"
    brew cask install ${cask}
  fi
done

APPSTORE_APPS=(
"462058435 Microsoft Excel (16.41)"
"462054704 Microsoft Word (16.41)"
"462062816 Microsoft PowerPoint (16.41)"
)

# Install from Mac App Store
for app in ${APPSTORE_APPS[*]};
do
  APPID=$(echo ${app} | awk '{print $1}')
  if ! ( mas list | grep "${APPID}" &>/dev/null ); then
    echo "Installing ${app}"
    mas install ${APPID}
  fi
done

# Install fonts
git clone --depth=1 https://github.com/powerline/fonts.git /tmp/fonts
pushd /tmp/fonts
./install.sh
popd
rm -rf /tmp/fonts

# Install oh-my-zsh
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install powerlevel10k theme
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

if [[ $SHELL != "/bin/zsh" ]]; then
  chsh -s /bin/zsh
fi

cat <<EOF >> ${HOME}/.zshrc
if command -v pyenv 1>/dev/null 2>&1; then
  eval "\$(pyenv init -)"
fi
export PYENV_ROOT="\$HOME/.pyenv"
export PATH="\$PYENV_ROOT/bin:\$PATH"
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF


