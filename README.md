# WhatsDroid

Download and install Android-x86\_64

Create a virtual disk and run it with qemu

Automatic Detection:

> Micropfone (PulseAudio/ALSA)  
> Webcam (/dev/video\*)

Optimize it through adb

```
✅ No GApps
✅ Lighter than a windows VM
```

## 1st Android's Boot:

On Android's boot screen:"

```
Select (and press enter on) [Installation - Install Android-x86 to harddisk]

Press 'c'   → to Create/Modify partitions, confirming with enter

'enter'     → to confirm

[No]        → to GPT, do not install GPT

[New]       → to create a new partition

[Primary]   → to create a primary partition

'enter'     → to confirm the size (8GB is recommended)

[Bootable]  → to mark the partition as bootable

[Write]     → confirm writing 'yes' + enter to write on the partition table

[Quit]      → to go back to the partition table"

[<name of your partition>] → Select the new partition (usually /dev/vda1) and press 'Enter'

[ext4]      → to format the partition"

[Yes]       → to confirm formatting"

[Yes]       → to install the GRUB bootloader"

[Yes]       → to make it read/write"

[Reboot]    → to finish the installation"
```

After it finish rebooting, close the window

A new window will be open.

Go through the initial android setup,

Do not skip the internet setup

Do a google account to make sure WhatsApp will run

and when you see the apps screen, press enter