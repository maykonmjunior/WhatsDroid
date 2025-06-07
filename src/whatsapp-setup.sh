#!/bin/bash
set -x

ADB_IP=$(grep 'ADB_IP' config.json | awk -F'"' '{print $4}')
ADB_PORT=$(grep 'ADB_PORT' config.json | awk -F'"' '{print $4}')
APP_URL=$(grep 'APP_URL' config.json | awk -F'"' '{print $4}')
APP_SRC=$(grep 'APP_SRC' config.json | awk -F'"' '{print $4}')
APP_NAME=$(grep 'APP_NAME' config.json | awk -F'"' '{print $4}')

# echo "Exemplo: adb connect 192.168.x.x:5555"
# read -p "Digite o IP da VM Android (descubra com ip neigh): " ADB_IP
read -p "Press [ENTER] when you finish logging in to the Android VM" _

echo "🔗 Conectando a $ADB_IP:$ADB_PORT..."
adb connect "$ADB_IP:$ADB_PORT" || true


# Verificar conexão com a VM
if ! adb get-state 1>/dev/null 2>&1; then
    echo "❌ ADB não está conectado. Use: adb connect IP:$ADB_PORT"
    exit 1
fi

#Instalar WhatsApp se necessário
wget "$APP_URL" \
     --user-agent="Mozilla/5.0" \
     --referer="$APP_SRC" \
     -O "$APP_NAME.apk" || { echo "❌ Erro ao baixar WhatsApp. Verifique a URL."; exit 1; }

#|| { echo "❌ Erro ao baixar WhatsApp. Verifique a URL."; exit 1; }
adb install WhatsApp.apk || echo "⚠️ WhatsApp já instalado ou erro ao instalar."

echo "✅ Conectado via ADB. Aplicando otimizações..."

# Desativar animações
echo "🔧 Desativando animações..."
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

# Desativar lockscreen
echo "🔒 Desativando lockscreen..."
adb shell settings put secure lock_screen_allow_private_notifications 0
adb shell settings put secure lockscreen.disabled 1
adb shell settings put system screen_off_timeout 2147483647
#adb shell pm disable-user --user 0 com.android.keyguard

# Desativar serviços desnecessários
echo "🚫 Desativando serviços desnecessários..."
for service in bluetooth nfc location; do
  adb shell settings put global ${service}_on 0 || true
done

# Ativar instalação via fontes desconhecidas (caso precise reinstalar o WhatsApp)
echo "📦 Ativando instalação de fontes desconhecidas..."
adb shell settings put secure install_non_market_apps 1

echo "🎯 Otimizações aplicadas!"
