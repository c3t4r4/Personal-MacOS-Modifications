#!/bin/bash

# Função para instalar pacotes via brew
install_brew_package() {
  if ! brew list "$1" &>/dev/null; then
    echo "Instalando $1..."
    brew install "$1"
  else
    echo "$1 já está instalado. Ignorando."
  fi
}

# Função para instalar aplicativos via brew cask
install_cask_package() {
  if ! brew list --cask "$1" &>/dev/null; then
    echo "Instalando $1..."
    brew install --cask "$1"
  else
    echo "$1 já está instalado. Ignorando."
  fi
}

# Instalar o Homebrew
if ! command -v brew &>/dev/null; then
  echo "Instalando o Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew já está instalado."
fi

# Atualizar Homebrew
echo "Atualizando Homebrew..."
brew update && brew upgrade

# Lista de aplicativos a instalar via cask
cask_apps=(
  google-chrome element sublime-text dbeaver-community insomnia anydesk spotify
  angry-ip-scanner teamviewer qbittorrent vlc alt-tab shottr whatsapp
  visual-studio-code docker istat-menus jetbrains-toolbox google-drive onedrive
  font-fira-code calibre ollama brave-browser
)

# Lista de pacotes a instalar via brew
brew_packages=(
  curl git php composer nvm yarn fzf atuin dust btop tldr eza
)

# Instalar aplicativos via cask
for app in "${cask_apps[@]}"; do
  install_cask_package "$app"
done

# Instalar pacotes via brew
for package in "${brew_packages[@]}"; do
  install_brew_package "$package"
done

# Instalar Zsh
brew install zsh
sudo sh -c 'echo $(which zsh) >> /etc/shells'
chsh -s $(which zsh)

# Instalar Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install romkatv/powerlevel10k/powerlevel10k

# Instalar plugins
brew install zsh-autosuggestions zsh-syntax-highlighting

# Adicionar configurações adicionais ao .zshrc
cat <<EOF >> ~/.zshrc

# Fontes Powerlevel10k e configurações
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Carregar aliases
source ~/.zshrc_aliases
EOF

# Criar e adicionar aliases no .zshrc_aliases
cat <<'ALIAS' > ~/.zshrc_aliases
### Comandos Laravel
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias pest='[ -f pest ] && sh pest || sh vendor/bin/pest'
alias runsail='sail up -d && sail npm run watch'
alias runtest='sail artisan test'
alias upd='brew update && brew upgrade'
ALIAS

# Instalar fontes necessárias
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font

# Instalar tema Dracula
git clone https://github.com/dracula/zsh.git ~/dracula-zsh
ln -s ~/dracula-zsh/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme

# Substituir ZSH_THEME e plugins no .zshrc
echo "Configurando tema e plugins no .zshrc..."
sed -i '' 's/^ZSH_THEME=".*"/ZSH_THEME="dracula"/' ~/.zshrc
sed -i '' 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Carregar ~/.zshrc
echo "Carregando ~/.zshrc..."
source ~/.zshrc

# Configurar NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d"

# Instalar a versão LTS do Node.js
echo "Instalando Node.js LTS (Hydrogen)..."
nvm install lts/hydrogen

# Finalização
echo "Instalação concluída."

exec zsh -l
