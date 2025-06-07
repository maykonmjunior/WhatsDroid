#!/bin/bash
set -e

# Import global configs from config.json
if [[ ! -f "config.json" ]]; then
    echo "❌ config.json não encontrado. Certifique-se de que ele está no diretório atual."
    exit 1
fi

ISO_FILE=$(grep 'ISO_FILE' config.json | awk -F'"' '{print $4}')
ISO_URL=$(grep 'ISO_URL' config.json | awk -F'"' '{print $4}')
DISK_IMAGE=$(grep 'DISK_IMAGE' config.json | awk -F'"' '{print $4}')
DISK_SIZE=$(grep 'DISK_SIZE' config.json | awk -F'"' '{print $4}')
RAM_MB=$(grep 'RAM_MB' config.json | awk -F'"' '{print $4}')
CPU_CORES=$(grep 'CPU_CORES' config.json | awk -F'"' '{print $4}')

echo -e "🔧 Detectando drivers"
./src/webcam.sh
./src/microphone.sh
CAM_VEND=$(cat tmp/cam_vend.txt)
CAM_PROD=$(cat tmp/cam_prod.txt)
MIC_FREQ=$(cat tmp/mic_freq.txt)
MIC_CHANNELS=$(cat tmp/mic_channels.txt)


# Começa a enviar vídeo real da webcam para a webcam virtual
# ffmpeg -f v4l2 -i /dev/video0 -vf "format=yuv420p" -f v4l2 /dev/video10 -loglevel error &
# FFMPEG_PID=$!
# sleep 2  # Aguarda o ffmpeg iniciar corretamente

# Iniciar VM com disco já instalado
qemu-system-x86_64 \
    -boot c \
    -enable-kvm \
    -m "$RAM_MB" \
    -smp "$CPU_CORES" \
    -machine type=q35,accel=kvm \
    -device virtio-net-pci,netdev=mynet \
    -netdev user,id=mynet,hostfwd=tcp::5555-:5555 \
    -cpu host \
    -device usb-ehci,id=ehci \
    -device usb-tablet \
    -drive if=virtio,file="$DISK_IMAGE",format=qcow2 \
    -audiodev pa,id=snd0,out.frequency=$MIC_FREQ,in.frequency=$MIC_FREQ,out.channels=$MIC_CHANNELS,in.channels=$MIC_CHANNELS \
    -device ich9-intel-hda \
    -device hda-duplex,audiodev=snd0 \
    -device usb-host,vendorid="0x$CAM_VEND",productid="0x$CAM_PROD" \
    -vga vmware \
    -display gtk,show-cursor=on,zoom-to-fit=on,grab-on-hover=on,window-close=on,show-menubar=off || {
    echo "⚠️ Falha ao iniciar a VM. Verifique os logs acima."
    # pkill "ffmpeg"
    exit 1
}

# Encerra o ffmpeg depois que QEMU fechar
# pkill "ffmpeg"