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

# Install sqllite
if [[ ! -d "/usr/local/Cellar/sqlite" ]]; then
    echo "Installing sqlite"
    brew install sqlite --with-function --with-secure-delete
fi

# Install packages
for package in coreutils vim git zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting pyenv pyenv-virtualenvwrapper mas sfml;
do
  if [[ ! -d "/usr/local/Cellar/${package}" ]]; then
    echo "Installing ${package}"
    brew install ${package}
  fi
done

# Install casks
for cask in firefox google-chrome iterm2 docker corretto8 intellij-idea-ce visual-studio-code unity-hub unity spectacle slack clickup zoomus gimp alfred love spotify anydesk vanilla vlc;
do
  if ( brew cask info ${cask} | grep "Not installed" &>/dev/null ); then
    echo "Installing ${cask}"
    brew cask install ${cask}
  fi
done

APPSTORE_APPS=( "462058435 Microsoft Excel (16.40)"
"1054607607 Helium (2.0)"
"1339170533 CleanMyMac X (4.6.12)"
"634148309 Logic Pro X (10.5.1)"
"1176895641 Spark (2.8.3)"
"897118787 Shazam (2.10.0)"
"682658836 GarageBand (10.3.5)"
"408981434 iMovie (10.1.15)"
"409201541 Pages (10.1)"
"497799835 Xcode (11.7)"
"409183694 Keynote (10.1)"
"462054704 Microsoft Word (16.40)"
"462058435 Microsoft Excel (16.40)"
"462062816 Microsoft PowerPoint (16.40)"
"409203825 Numbers (10.1)" )

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
export PATH="\$PYENV_ROOT/bin:\$PATH
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF


