#!/bin/bash
set -e

ISO_FILE=$(grep 'ISO_FILE' config.json | awk -F'"' '{print $4}')
ISO_URL=$(grep 'ISO_URL' config.json | awk -F'"' '{print $4}')
DISK_IMAGE=$(grep 'DISK_IMAGE' config.json | awk -F'"' '{print $4}')
DISK_SIZE=$(grep 'DISK_SIZE' config.json | awk -F'"' '{print $4}')
RAM_MB=$(grep 'RAM_MB' config.json | awk -F'"' '{print $4}')
CPU_CORES=$(grep 'CPU_CORES' config.json | awk -F'"' '{print $4}')

# ./src/webcam.sh
# echo -e "\n>> Etapa 1.4: Detectando microfone..."
# ./src/microphone.sh
CAM_BUS=$(cat tmp/cam_bus.txt)
CAM_ADDR=$(cat tmp/cam_addr.txt)
MIC_FREQ=$(cat tmp/mic_freq.txt)
MIC_CHANNELS=$(cat tmp/mic_channels.txt)

# Iniciar VM com disco já instalado
qemu-system-x86_64 \
    -boot c \
    -enable-kvm \
    -m "$RAM_MB" \
    -smp "$CPU_CORES" \
    -machine accel=kvm \
    -device virtio-net,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::5555-:5555 \
    -cpu host \
    -device usb-ehci,id=ehci \
    -device usb-tablet \
    -drive if=virtio,file="$DISK_IMAGE",format=qcow2 \
    -audiodev pa,id=snd0,out.frequency=$MIC_FREQ,in.frequency=$MIC_FREQ,out.channels=$MIC_CHANNELS,in.channels=$MIC_CHANNELS \
    -device ich9-intel-hda \
    -device hda-duplex,audiodev=snd0 \
    -device usb-host,hostbus="$CAM_BUS",hostaddr="$CAM_ADDR" \
    -display default,show-cursor=on &>/dev/null &
