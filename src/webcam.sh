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

echo "$BUS" > tmp/cam_bus.txt
echo "$ADDR" > tmp/cam_addr.txt

echo "SUBSYSTEM==\"usb\", ATTR{idVendor}==$IdVendor, ATTR{idProduct}==$IdProduct, MODE=\"0666\", GROUP=\"video\"" | sudo tee  /etc/udev/rules.d/99-webcam.rules
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=usb
sudo chmod a+rw /dev/bus/usb/"$BUS"/"$ADDR"