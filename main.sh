#!/bin/bash
set -e

echo "🔧 Instalando dependências..."
# yay -S --needed - < pkgs.list

# Etapa 0: Tornar scripts executáveis
echo "🔧 Tornando scripts executáveis..."
chmod +x src/android-vm.sh
chmod +x src/microphone.sh
chmod +x src/webcam.sh
chmod +x src/whatsapp-setup.sh
chmod +x src/WhatsDroid.sh

echo -e ">> Etapa 1: Executando android-vm.sh..."]
# Etapa 1: Instalar Android na VM (via ISO)
./src/android-vm.sh

# Etapa 2: Iniciar a VM normalmente
echo -e ">> Etapa 3: Iniciando a VM instalada..."
./src/WhatsDroid.sh

# Etapa 3: Conectar ADB para aplicar otimizações
echo -e ">> Etapa 2: Conectando Whatsapp na VM..."
./src/whatsapp-setup.sh

