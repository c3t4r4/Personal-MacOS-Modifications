#!/bin/bash

# Solicita nome do aplicativo
read -p "Digite o nome do aplicativo que deseja remover (ex: NFStools): " APP_NAME

# Verifica se nome é válido
if [[ -z "$APP_NAME" ]]; then
  echo "❌ Nome do aplicativo não pode estar vazio."
  exit 1
fi

# Normaliza nomes para variações
APP_NAME_LOWER=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')
APP_NAME_NO_SPACES=$(echo "$APP_NAME" | sed 's/ //g')

echo "🔍 Buscando arquivos relacionados a \"$APP_NAME\"..."

# Locais comuns de instalação/configuração
declare -a SEARCH_PATHS=(
  "/Applications"
  "$HOME/Library/Application Support"
  "$HOME/Library/Preferences"
  "$HOME/Library/Caches"
  "$HOME/Library/LaunchAgents"
  "/Library/Application Support"
  "/Library/Preferences"
  "/Library/LaunchAgents"
  "/Library/LaunchDaemons"
  "/usr/local/bin"
  "/usr/local"
  "/Library/Extensions"
)

# Armazena caminhos encontrados
FOUND_ITEMS=()

# Busca nos diretórios
for DIR in "${SEARCH_PATHS[@]}"; do
  if [[ -d "$DIR" ]]; then
    while IFS= read -r -d '' ITEM; do
      FOUND_ITEMS+=("$ITEM")
    done < <(find "$DIR" -iname "*$APP_NAME*" -print0 2>/dev/null)
  fi
done

# Exibe resultado
ITEM_COUNT=${#FOUND_ITEMS[@]}

if [[ $ITEM_COUNT -eq 0 ]]; then
  echo "✅ Nenhum arquivo relacionado encontrado."
  exit 0
fi

echo ""
echo "⚠️  Foram encontrados $ITEM_COUNT itens relacionados ao aplicativo \"$APP_NAME\":"
echo "------------------------------------------------------"
for ITEM in "${FOUND_ITEMS[@]}"; do
  echo "$ITEM" | sed "s|[^/]*/|  |g"
done
echo "------------------------------------------------------"

read -p "Deseja remover todos esses arquivos? (s/n): " CONFIRM

if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
  echo "❎ Operação cancelada."
  exit 0
fi

# Verifica se sudo será necessário
NEEDS_SUDO=false
for ITEM in "${FOUND_ITEMS[@]}"; do
  if [[ "$ITEM" == /Library/* || "$ITEM" == /usr/* || "$ITEM" == /Applications/* ]]; then
    NEEDS_SUDO=true
    break
  fi
done

# Solicita senha de sudo, se necessário
if $NEEDS_SUDO; then
  echo "🔐 Algumas pastas exigem permissões de administrador."
  sudo -v || exit 1
fi

echo "🧹 Iniciando remoção..."

for ITEM in "${FOUND_ITEMS[@]}"; do
  echo "🗑️  Removendo: $ITEM"
  if [[ "$ITEM" == /Library/* || "$ITEM" == /usr/* || "$ITEM" == /Applications/* ]]; then
    sudo rm -rf "$ITEM"
  else
    rm -rf "$ITEM"
  fi
done

echo "✅ Remoção finalizada com sucesso."
