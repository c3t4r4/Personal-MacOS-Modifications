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
mkdir ~/.nvm

# Lista de aplicativos a instalar via cask
cask_apps=(
  google-chrome element sublime-text dbeaver-community insomnia anydesk spotify
  angry-ip-scanner teamviewer qbittorrent vlc alt-tab shottr whatsapp
  visual-studio-code docker istat-menus jetbrains-toolbox google-drive onedrive
  font-fira-code calibre ollama brave-browser font-meslo-for-powerlevel10k
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
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Adicionar configurações adicionais ao .zshrc
if ! grep -q "# Fontes Powerlevel10k e configurações" ~/.zshrc; then
cat <<EOF >> ~/.zshrc

# Adicionar configurações adicionais ao .zshrc
# Fontes Powerlevel10k e configurações
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
fi

# Configurar zshrc_aliases
if ! grep -q "# Carregar aliases" ~/.zshrc; then
cat <<EOF >> ~/.zshrc

# Carregar aliases
source ~/.zshrc_aliases
EOF
fi


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

# Instalar plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Substituir ZSH_THEME e plugins no .zshrc
echo "Configurando tema e plugins no .zshrc..."
sed -i '' 's#^ZSH_THEME=".*"#ZSH_THEME="powerlevel10k/powerlevel10k"#' ~/.zshrc
sed -i '' 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Configurar NVM
if ! grep -q "# NVM" ~/.zshrc; then
cat <<EOF >> ~/.zshrc

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
EOF
fi

# Configurar Laravel
if ! grep -q "# Laravel" ~/.zshrc; then
cat <<EOF >> ~/.zshrc

# Laravel
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
EOF
fi

# Carregar ~/.zshrc
echo "Carregando ~/.zshrc..."
source ~/.zshrc


# Instalar a versão LTS do Node.js
echo "Instalando Node.js LTS (Hydrogen)..."
nvm install lts/hydrogen

exec zsh -l

# Configurar Thema do Terminal
# 1. Baixa o conteúdo e salva no arquivo ~/.p10k.zsh
curl -o ~/.p10k.zsh https://raw.githubusercontent.com/c3t4r4/Personal-MacOS-Modifications/refs/heads/main/p10k.conf

# 2. Baixa o arquivo do tema Dracula para Terminal.app
curl -L -o ~/Dracula.terminal https://raw.githubusercontent.com/dracula/terminal-app/refs/heads/master/Dracula.terminal

# 3. Importa o tema Dracula do caminho fornecido
osascript <<EOF
tell application "Terminal"
    do shell script "open $HOME/Dracula.terminal"
    delay 1
    set default settings to settings set "Dracula"
end tell
EOF

# Limpando p10k
echo "" > ~/.p10k.zsh

# Configurando
curl -o ~/.p10k.zsh https://raw.githubusercontent.com/c3t4r4/Personal-MacOS-Modifications/refs/heads/main/p10k.conf

# Configura a fonte para todos os perfis do Terminal.app
# Itera sobre os perfis configurados no Terminal
profiles=$(defaults read com.apple.terminal "Window Settings" | grep -o '"[^"]*"' | tr -d '"')

for profile in $profiles; do
  # Define a fonte para o perfil atual
  defaults write com.apple.terminal "Window Settings" -dict-add "$profile" "FontName" -string "MesloLGS NF"
  defaults write com.apple.terminal "Window Settings" -dict-add "$profile" "FontSize" -int 15
done

# 5. Define Dracula como o tema padrão para janelas e inicialização
defaults write com.apple.terminal "Default Window Settings" -string "Dracula"
defaults write com.apple.terminal "Startup Window Settings" -string "Dracula"

# Reinicia o Terminal para aplicar as mudanças (opcional)
killall Terminal

echo "Configurações aplicadas. O tema Dracula e a fonte MesloLGS NF foram ativados."

# Finalização
echo "Instalação concluída. para reconfigurar o p10k use: pk10 configure"
