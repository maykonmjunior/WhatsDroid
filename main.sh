#!/bin/bash
set -e

echo "🔧 Instalando dependências..."
# yay -S --needed - < pkgs.list

# Etapa 0: Tornar scripts executáveis
echo "🔧 Tornando scripts executáveis..."
chmod +x src/install.sh
chmod +x src/microphone.sh
chmod +x src/webcam.sh
chmod +x src/WhatsDroid.sh

echo -e ">> Etapa 1: Executando install.sh..."]
# Etapa 1: Instalar Android na VM (via ISO)
./src/install.sh

# Etapa 2: Iniciar a VM normalmente
echo -e ">> Etapa 2: Iniciando a VM instalada..."
nohup ./src/WhatsDroid.sh &> /dev/null &