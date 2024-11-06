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

# Função para instalar aplicativos via brew cask com verificação
install_cask_package() {
  if brew list --cask "$1" &>/dev/null; then
    echo "$1 já está instalado. Ignorando."
  elif [ -d "/Applications/$(echo "$1" | sed 's/-/ /g').app" ]; then
    echo "Parece que já existe uma instalação de $1 em /Applications/$(echo "$1" | sed 's/-/ /g').app."
    read -p "Deseja remover a versão existente e instalar a versão do brew? (s/n): " resposta
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
      echo "Removendo versão existente de $1..."
      rm -rf "/Applications/$(echo "$1" | sed 's/-/ /g').app"
      echo "Instalando $1..."
      brew install --cask "$1"
    else
      echo "Ignorando a instalação de $1."
    fi
  else
    echo "Instalando $1..."
    brew install --cask "$1"
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
  curl git php composer nvm yarn fzf atuin dust btop tldr eza zsh
)

# Instalar aplicativos via cask
for app in "${cask_apps[@]}"; do
  install_cask_package "$app"
done

# Instalar pacotes via brew
for package in "${brew_packages[@]}"; do
  install_brew_package "$package"
done

# Caminho do Zsh
ZSH_PATH=$(which zsh)

# Verifica se o caminho do Zsh já está listado em /etc/shells
if grep -qF "$ZSH_PATH" /etc/shells; then
  echo "Zsh já está listado em /etc/shells."
else
  echo "Adicionando $ZSH_PATH em /etc/shells..."
  sudo sh -c "echo $ZSH_PATH >> /etc/shells"
fi

# Verifica se o Zsh já é o shell padrão do usuário
if [[ "$SHELL" == "$ZSH_PATH" ]]; then
  echo "Zsh já é o shell padrão."
else
  echo "Definindo Zsh como shell padrão..."
  chsh -s "$ZSH_PATH"
fi

# Caminho padrão do Oh My Zsh e do tema Powerlevel10k
OH_MY_ZSH="$HOME/.oh-my-zsh"
POWERLEVEL10K="$OH_MY_ZSH/custom/themes/powerlevel10k"

# Verifica se Oh My Zsh já está instalado
if [ -d "$OH_MY_ZSH" ]; then
  echo "Oh My Zsh já está instalado."
else
  echo "Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Verifica se o tema Powerlevel10k já está instalado
if [ -d "$POWERLEVEL10K" ]; then
  echo "O tema Powerlevel10k já está instalado."
else
  echo "Instalando o tema Powerlevel10k..."
  git clone https://github.com/romkatv/powerlevel10k.git $POWERLEVEL10K
fi

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
### Comandos
alias upd='omz update && brew update && brew upgrade'

### Comandos Laravel
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias pest='[ -f pest ] && sh pest || sh vendor/bin/pest'
alias runsail='sail up -d && sail npm run watch'
alias runtest='sail artisan test'

### Gerador de Senha
alias gerarsenha='echo -n "Digite o tamanho da senha: "; read tamanho; openssl rand -base64 $tamanho | tr -d "\n"; echo'

ALIAS

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Caminho padrão do zsh-autosuggestions
ZSH_AUTOSUGGESTIONS="$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# Verifica se zsh-autosuggestions já está instalado
if [ -d "$ZSH_AUTOSUGGESTIONS" ]; then
  echo "zsh-autosuggestions já está instalado."
else
  echo "Instalando zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# Caminho padrão do zsh-syntax-highlighting
ZSH_HIGHLIGHTING="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Verifica se zsh-syntax-highlighting já está instalado
if [ -d "$ZSH_AUTOSUGGESTIONS" ]; then
  echo "zsh-syntax-highlighting já está instalado."
else
  echo "Instalando zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

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

# Instalar a versão LTS do Node.js
echo "Instalando Node.js LTS (Hydrogen)..."
nvm install lts/hydrogen

# Configurar Thema do Terminal
# 1. Baixa o conteúdo e salva no arquivo ~/.p10k.zsh
echo "" > ~/.p10k.zsh
curl -o ~/.p10k.zsh https://raw.githubusercontent.com/c3t4r4/Personal-MacOS-Modifications/refs/heads/main/p10k.conf

if [ ! -f "$HOME/Dracula.terminal" ]; then
  echo "Baixando o tema Dracula..."
  curl -L -o "$HOME/Dracula.terminal" https://raw.githubusercontent.com/c3t4r4/Personal-MacOS-Modifications/refs/heads/main/Dracula.terminal
fi

# Importa o tema Dracula e o define como padrão usando AppleScript
osascript <<EOF
tell application "Terminal"
    -- Importa o tema
    do shell script "open $HOME/Dracula.terminal"
    delay 1
    -- Define como o tema padrão para novas janelas e inicialização
    set default settings to settings set "Dracula"
    set startup settings to settings set "Dracula"
end tell
EOF

echo "Configurações aplicadas. O tema Dracula e a fonte MesloLGS NF foram ativados."

rm -rf "$HOME/Dracula.terminal"

# Finalização
echo "Instalação concluída. para reconfigurar o p10k use: pk10 configure"
