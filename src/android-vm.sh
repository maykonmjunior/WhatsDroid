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


# Etapa 1.1: Criar arquivos de instalação
echo -e "\n>> Etapa 1.1: Criando o arquivo Iso..."
# Baixa ISO do Android-x86
if [[ ! -f "$ISO_FILE" ]]; then
    echo "⬇️ Baixando Android ISO..."
    wget -O "$ISO_FILE" "$ISO_URL"
else
    echo "✔️ ISO já presente: $ISO_FILE"
fi

# Cria disco virtual
echo -e "\n>> Etapa 1.2: Criando disco virtual..."
if [[ ! -f "$DISK_IMAGE" ]]; then
    echo ">> Criando disco virtual..."
    qemu-img create -f qcow2 "$DISK_IMAGE" $DISK_SIZE
else
    echo "✔️ Disco virtual já existe: $DISK_IMAGE"
fi

# Etapa 1.3 e 1.4: Detectar webcam e microfone
echo -e "\n>> Etapa 1.3: Detectando webcam..."
mkdir -p tmp
./src/webcam.sh
CAM_BUS=$(cat tmp/cam_bus.txt)
CAM_ADDR=$(cat tmp/cam_addr.txt)
echo -e "\n>> Etapa 1.4: Detectando microfone..."
./src/microphone.sh
MIC_FREQ=$(cat tmp/mic_freq.txt)
MIC_CHANNELS=$(cat tmp/mic_channels.txt)


# Instruções de instalação
echo "\n🔧 Etapa 1.5: Instalação da VM Android-x86"
echo "Siga as instruções do README:"

#    -audiodev pa,id=snd0,out.frequency=48000,in.frequency=48000,out.channels=2,in.channels=2 \
# Inicia instalação
qemu-system-x86_64 \
    -cdrom "$ISO_FILE" \
    -boot d \
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
    -display default,show-cursor=on
