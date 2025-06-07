#!/bin/bash
# Script 2: fix_grub_android.sh
# Mounts Android disk image and edits GRUB to force GUI at boot
set -x

DISK_IMG="android_whatsapp.qcow2"
MOUNT_DIR="/mnt/android_root"
LOOP_IMG="/tmp/android_loop.img"

echo "[+] Extracting first partition from qcow2..."
qemu-img convert -O raw "$DISK_IMG" "$LOOP_IMG"

PART_OFFSET=$(fdisk -l "$LOOP_IMG" | grep "Linux" | awk '{print $3}')
if [ -z "$PART_OFFSET" ]; then
    echo "[-] Failed to find partition offset."
    exit 1
fi

OFFSET_BYTES=$((PART_OFFSET * 512))
echo "[+] Mounting partition at offset $OFFSET_BYTES..."

sudo mkdir -p "$MOUNT_DIR"
sudo mount -o loop,offset=$OFFSET_BYTES "$LOOP_IMG" "$MOUNT_DIR"

MENU_LST="$MOUNT_DIR/grub/menu.lst"
if [ ! -f "$MENU_LST" ]; then
    echo "[-] GRUB config not found."
    sudo umount "$MOUNT_DIR"
    exit 1
fi

echo "[+] Patching GRUB menu.lst..."
sudo sed -i '/kernel/ s/$/ nomodeset xforcevesa/' "$MENU_LST"

# sudo umount "$MOUNT_DIR"
# rm "$LOOP_IMG"
echo "[+] GRUB config patched. GUI should now boot."
