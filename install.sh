#!/bin/bash

welcome_screen() {
cat << "EOF"

________/\\\\\\\\\_____/\\\\\\\\\\___________________________/\\\_____________________________/\\\____        
 _____/\\\////////____/\\\///////\\\________________________/\\\\\___________________________/\\\\\____       
  ___/\\\/____________\///______/\\\______/\\\_____________/\\\/\\\_________________________/\\\/\\\____      
   __/\\\_____________________/\\\//____/\\\\\\\\\\\______/\\\/\/\\\_____/\\/\\\\\\\_______/\\\/\/\\\____     
    _\/\\\____________________\////\\\__\////\\\////_____/\\\/__\/\\\____\/\\\/////\\\____/\\\/__\/\\\____    
     _\//\\\______________________\//\\\____\/\\\_______/\\\\\\\\\\\\\\\\_\/\\\___\///___/\\\\\\\\\\\\\\\\_   
      __\///\\\___________/\\\______/\\\_____\/\\\_/\\__\///////////\\\//__\/\\\_________\///////////\\\//__  
       ____\////\\\\\\\\\_\///\\\\\\\\\/______\//\\\\\_____________\/\\\____\/\\\___________________\/\\\____ 
        _______\/////////____\/////////_________\/////______________\///_____\///____________________\///_____

EOF
}

bye_screen() {
cat << "EOF"

_____/\\\\\\\\\__________________________________/\\\________________________________________/\\\____                          
 ___/\\\\\\\\\\\\\_______________________________\/\\\______________________________________/\\\\\\\__                         
  __/\\\/////////\\\______________________________\/\\\_____________________________________/\\\\\\\\\_                        
   _\/\\\_______\/\\\_____/\\\\\\\\__/\\\\\\\\\____\/\\\____________/\\\\\_____/\\\____/\\\_\//\\\\\\\__                       
    _\/\\\\\\\\\\\\\\\___/\\\//////__\////////\\\___\/\\\\\\\\\____/\\\///\\\__\/\\\___\/\\\__\//\\\\\___                      
     _\/\\\/////////\\\__/\\\___________/\\\\\\\\\\__\/\\\////\\\__/\\\__\//\\\_\/\\\___\/\\\___\//\\\____                     
      _\/\\\_______\/\\\_\//\\\_________/\\\/////\\\__\/\\\__\/\\\_\//\\\__/\\\__\/\\\___\/\\\____\///_____                    
       _\/\\\_______\/\\\__\///\\\\\\\\_\//\\\\\\\\/\\_\/\\\\\\\\\___\///\\\\\/___\//\\\\\\\\\______/\\\____                   
        _\///________\///_____\////////___\////////\//__\/////////______\/////______\/////////______\///_____                  
________/\\\\\\\\\__/\\\_______________________________________________________________/\\\________/\\\________/\\\____        
 _____/\\\////////__\/\\\_____________________________________________________________/\\\\\\\____/\\\\\\\____/\\\\\\\__       
  ___/\\\/___________\/\\\____________________________________________________________/\\\\\\\\\__/\\\\\\\\\__/\\\\\\\\\_      
   __/\\\_____________\/\\\__________/\\\\\\\\\_______/\\\\\__/\\\\\____/\\\\\\\\\____\//\\\\\\\__\//\\\\\\\__\//\\\\\\\__     
    _\/\\\_____________\/\\\\\\\\\\__\////////\\\____/\\\///\\\\\///\\\_\////////\\\____\//\\\\\____\//\\\\\____\//\\\\\___    
     _\//\\\____________\/\\\/////\\\___/\\\\\\\\\\__\/\\\_\//\\\__\/\\\___/\\\\\\\\\\____\//\\\______\//\\\______\//\\\____   
      __\///\\\__________\/\\\___\/\\\__/\\\/////\\\__\/\\\__\/\\\__\/\\\__/\\\/////\\\_____\///________\///________\///_____  
       ____\////\\\\\\\\\_\/\\\___\/\\\_\//\\\\\\\\/\\_\/\\\__\/\\\__\/\\\_\//\\\\\\\\/\\_____/\\\________/\\\________/\\\____ 
        _______\/////////__\///____\///___\////////\//__\///___\///___\///___\////////\//_____\///________\///________\///_____

EOF
}

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

#RUN SCRIPT
clear
welcome_screen


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
  alt-tab angry-ip-scanner anydesk basictex brave-browser cursor dbeaver-community element font-powerline-symbols 
  font-meslo-for-powerlevel10k google-chrome google-drive insomnia istat-menus jetbrains-toolbox notion obsidian onedrive 
  orbstack qbittorrent rustdesk shottr spotify sublime-text teamviewer visual-studio-code vlc whimsical windows-app			
)

# Lista de pacotes a instalar via brew
brew_packages=(
  atuin btop composer curl docker-compose docker-machine dust eza ffmpeg fzf gd go git mas magic-wormhole mtr nvm tldr uv ncdu php rsync zsh wget yarn
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
### Gerador de Senha
alias gerarsenha='echo -n "Digite o tamanho da senha: "; read tamanho; echo -n "Incluir caracteres especiais? (s/n): "; read especiais; if [ "$especiais" = "s" ]; then LC_ALL=C tr -dc "a-zA-Z0-9@!#$%^&*()_+" < /dev/urandom | fold -w1 | head -n $tamanho | perl -MList::Util=shuffle -e "print shuffle(<>);" | tr -d "\n"; else LC_ALL=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w1 | head -n $tamanho | perl -MList::Util=shuffle -e "print shuffle(<>);" | tr -d "\n"; fi; echo'

alias gerarsenhafast='LC_ALL=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w1 | head -n 64 | perl -MList::Util=shuffle -e "print shuffle(<>);" | tr -d "\n";'

alias magicSend='function _magic_send() {
    if [ -z "$1" ]; then
        echo "Uso: magicSend nomedoarquivo";
        return 1;
    fi;
    
    # Gerar senha
    local SENHA=$(LC_ALL=C tr -dc "a-zA-Z0-9" < /dev/urandom | fold -w1 | head -n 64 | perl -MList::Util=shuffle -e "print shuffle(<>);" | tr -d "\n");
    
    # Nome do arquivo encriptado
    local ARQUIVO_ENC="${1}.enc";
    
    # Encriptar o arquivo com a senha
    echo "$SENHA" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$1" -out "$ARQUIVO_ENC" -pass stdin;
    
    # Verificar se a encriptação foi bem-sucedida
    if [ ! -f "$ARQUIVO_ENC" ]; then
        echo "Erro: Falha na encriptação do arquivo.";
        return 1;
    fi;
    
    # Enviar usando wormhole e capturar a saída
    echo -e "\nEnviando arquivo encriptado...";
    local RESULTADO=$(wormhole send "$ARQUIVO_ENC");
    
    # Exibir resultados
    echo -e "\n=====================================";
    echo "$RESULTADO";
    echo -e "\n=====================================";
    echo -e "SENHA PARA DESCRIPTOGRAFAR: $SENHA";
    echo -e "=====================================\n";
    echo -e "Para descriptografar, use:\nopenssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in $ARQUIVO_ENC -out $1";
    echo -e "=====================================";
}; _magic_send'

### Ative Node
alias activenode='nvm alias default lts/* && nvm use default'

### Comandos Laravel
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'

alias pest='[ -f pest ] && sh pest || sh vendor/bin/pest'

alias runsail='sail up -d && sail npm run watch'

alias runtest='sail artisan test'

# Primeiro, crie uma função para limpar as versões antigas do NVM
clean_nvm_versions() {
	echo "Limpando versões antigas do NVM..."
	local current=$(nvm current | sed 's/v//')

	# Usar grep mais específico para capturar apenas versões numéricas
	for version in $(nvm ls --no-colors | grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" | sed 's/v//'); do
		# Não remover a versão atual
		if [ "$version" != "$current" ]; then
			nvm uninstall "$version" > /dev/null 2>&1
		fi
	done
}

### Sistema
alias upd='echo "Atualizando Oh My Zsh..." && \
omz update > /dev/null 2>&1 && \
source ~/.zshrc && \
echo "Atualizando brew e pacotes globais..." && \
brew update > /dev/null 2>&1 && \
brew upgrade > /dev/null 2>&1 && \
brew cleanup && \
echo "Atualizando composer e pacotes globais..." && \
composer self-update > /dev/null 2>&1 && \
composer global update > /dev/null 2>&1 && \
echo "Atualizando NodeJS LTS..." && \
nvm install --lts > /dev/null 2>&1 && \
nvm use --lts > /dev/null 2>&1 && \
echo "Atualizando Pacotes npm Global..." && \
npm update -g > /dev/null 2>&1 && \
clean_nvm_versions && \
nvm cache clear > /dev/null 2>&1 && \
echo "Atualizando python3 pip e pacotes globais..." && \
python3 -m pip install --upgrade pip > /dev/null 2>&1 && \
pip3 list --outdated --format=columns | tail -n +3 | awk "{print \$1}" | xargs -n1 pip3 install -U > /dev/null 2>&1 && \
echo "Atualizando tldr..." && \
tldr --update > /dev/null 2>&1 && \
echo "Verificando atualizações da Apple Store..." && \
softwareupdate -l > /dev/null 2>&1 && \
mas upgrade'

### Backups LidTec
alias criarBKLidTec='ssh root@server.lidtec.com.br "cd /root && ./backupDocker.sh;"'

alias copiarBKLidTec='scp "root@server.lidtec.com.br:/root/*.enc" /Users/c3t4r4/Cloud-Drive/Trabalho/BackupPortainer/ && rsync -av --ignore-existing /Users/c3t4r4/Cloud-Drive/Trabalho/BackupPortainer/ /Volumes/SDD/BackupPortainer/'

alias excluirBKLidTec='ssh root@server.lidtec.com.br "find /root/ -name \"*.zip.enc\" -type f -exec rm {} \;"'

alias bkLidTec='criarBKLidTec && copiarBKLidTec && excluirBKLidTec'

alias webui='docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main'

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
if [ -d "$ZSH_HIGHLIGHTING" ]; then
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

nvm use --lts > /dev/null 2>&1

EOF
fi

# Configurar Laravel
if ! grep -q "# Laravel" ~/.zshrc; then
cat <<EOF >> ~/.zshrc

# Laravel
export PATH="$PATH:$HOME/.composer/vendor/bin:/usr/local/sbin"
EOF
fi

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

echo "Recarregando e Atualizando"
source ~/.zshrc

#Instalar o Uninstall App
mv uninstall_app.sh /usr/local/bin/uninstall_app

#Instalar o NVM
nvm install --lts

#Ativar o NVM
nvm use --lts

#Ativar o Composer
composer self-update

#Instalar o Laravel Installer
composer global require laravel/installer

#Atualizar o Composer Global
composer global update

#Atualizar o Oh My Zsh
omz update

#Atualizar o Homebrew
brew update

#Atualizar o Homebrew
brew upgrade

upd

#Finalização
bye_screen