# Ajustar hora para dualboot

```
timedatectl set-timezone America/Mexico_City
```

```
timedatectl set-local-rtc 1 --adjust-system-clock
```

# Aplicaciones base al instalar linux

```
pacstrap -K /mnt base base-devel linux linux-firmware intel-ucode networkmanager dhcpcd nano pulseaudio alsa-utils grub efibootmgr
```
