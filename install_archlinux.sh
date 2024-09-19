#!/bin/bash

# Variables
USER_NAME="axelcodev"
USER_PASSWORD="gfyk8m3j"
EFI_PART="/dev/sda4"
SWAP_PART="/dev/sda5"
ROOT_PART="/dev/sda6"
TIMEZONE="America/Mexico_City"

# Montar las particiones
echo "Montando particiones..."
mount $ROOT_PART /mnt
mkdir /mnt/boot
mount $EFI_PART /mnt/boot
swapon $SWAP_PART

# Instalar los paquetes base
echo "Instalando el sistema base..."
pacstrap /mnt base linux linux-firmware nano grub efibootmgr base-devel networkmanager dhcpcd pulseaudio-alsa alsa-utils pulseaudio

# Generar fstab
echo "Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot al nuevo sistema
echo "Entrando a chroot..."
arch-chroot /mnt /bin/bash <<EOF

# Configurar zona horaria
echo "Configurando zona horaria..."
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Establecer idioma y localización
echo "Configurando locales..."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Configurar red
echo "Configurando el hostname y el hosts file..."
echo "archlinux" > /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    archlinux.localdomain archlinux" >> /etc/hosts

# Configurar NetworkManager
echo "Habilitando NetworkManager..."
systemctl enable NetworkManager

# Configurar zona horaria local
echo "Configurando el reloj local..."
timedatectl set-timezone $TIMEZONE
timedatectl set-local-rtc 1 --adjust-system-clock

# Configurar contraseña de root
echo "Configurando la contraseña de root..."
echo "root:gfyk8m3j" | chpasswd

# Crear usuario con contraseña
echo "Creando el usuario $USER_NAME..."
useradd -m $USER_NAME
echo "$USER_NAME:$USER_PASSWORD" | chpasswd
usermod -aG wheel $USER_NAME

# Permitir que los usuarios del grupo wheel usen sudo
echo "Permitendo que el grupo wheel use sudo..."
sed -i '/%wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers

# Instalar y configurar GRUB
echo "Instalando y configurando GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

EOF

# Desmontar particiones y reiniciar
echo "Finalizando la instalación..."
umount -R /mnt
swapoff $SWAP_PART
echo "Instalación completa. Reinicia el sistema."

# Fin del script
