#!/bin/bash
#!/bin/bash
# set -x

# Verifica webcam automaticamente
CAM_LINE=$(lsusb | grep -i webcam | head -n1)
if [[ -z "$CAM_LINE" ]]; then
    echo "⚠️ Não foi possível detectar webcam automaticamente."
else
    echo "✅ Webcam detectada: $CAM_LINE"
fi
BUS=$(echo "$CAM_LINE" | awk '{print $2}' | grep -o '[0-9]\+')
ADDR=$(echo "$CAM_LINE" | awk '{print $4}' | grep -o '[0-9]\+')
ID=$(echo "$CAM_LINE" | awk '{print $6}')
IdVendor=$(echo "$ID" | cut -d':' -f1)
IdProduct=$(echo "$ID" | cut -d':' -f2)

echo "$IdVendor" > tmp/cam_vend.txt
echo "$IdProduct" > tmp/cam_prod.txt


echo "🔍 Verificando pré-condições para webcam virtual..."

# Verifica se /dev/video0 está em uso
if fuser /dev/video0 >/dev/null 2>&1; then
  echo '❌ A webcam real (/dev/video0) está em uso por outro processo.'
  echo '   Feche o app que está usando a webcam e tente novamente.'
  exit 1
fi

# Verifica se /dev/video10 já existe e remove se necessário
# if [ -e /dev/video10 ]; then
#   echo "⚠️  O dispositivo virtual /dev/video10 já existe. Tentando remover..."
#   sudo modprobe -r v4l2loopback
#   sleep 1
# fi

# # Carrega o módulo v4l2loopback
# echo "🔌 Carregando v4l2loopback..."
# sudo modprobe v4l2loopback video_nr=10 card_label='VirtualCam' exclusive_caps=1 || {
#   echo '❌ Falha ao carregar o módulo v4l2loopback.'
#   exit 1
# }

# # Aguarda até que /dev/video10 seja criado
# for i in {1..10}; do
#   if [ -e /dev/video10 ]; then
#     break
#   fi
#   sleep 0.5
# done

# # Verifica se /dev/video10 foi criado
# if [ ! -e /dev/video10 ]; then
#   echo '❌ O dispositivo /dev/video10 não foi criado.'
#   exit 1
# fi

# # Verifica permissão de escrita em /dev/video10
# if [ ! -w /dev/video10 ]; then
#   echo '⚠️  Ajustando permissões de /dev/video10...'
#   sudo chown "$USER":"video" /dev/video10 || {
#     echo '❌ Falha ao ajustar permissões de /dev/video10.'
#     exit 1
#   }
# fi

echo "✅ Verificações concluídas. Continuando execução..."