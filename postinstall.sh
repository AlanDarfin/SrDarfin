#!/bin/bash

# ========================
# Pós-instalação Arch Linux (GNOME)
# ========================

set -e

echo "🌎 Instalando reflector e otimizando mirrors para o Brasil..."
sudo pacman -S --noconfirm reflector
sudo reflector --country Brazil --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo "🔧 Atualizando sistema..."
sudo pacman -Syu --noconfirm

echo "📂 Instalando Syncthing..."
sudo pacman -S --noconfirm syncthing
systemctl --user enable syncthing.service
systemctl --user start syncthing.service

# echo "🌐 Instalando Zerotier..."
# yay -S --noconfirm zerotier-one
# sudo systemctl enable zerotier-one
# sudo systemctl start zerotier-one

echo "📦 Instalando Flatpak e apps desejados..."
sudo pacman -S --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub menu.kando.Kando
# flatpak install -y flathub com.obsproject.Studio
flatpak install -y flathub com.discordapp.Discord
# flatpak install -y flathub com.valvesoftware.Steam
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub com.spotify.Client

echo "Removendo Firefox e Instalando Vivldi"
sudo pacman -Rns firefox
flatpak install -y flathub com.vivaldi.Vivaldi


echo "🔧 Corrigindo Bluetooth..."
sudo pacman -S --noconfirm bluez bluez-utils
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# echo "🎨 Instalando tema de cursor Bibata..."
# yay -S --noconfirm bibata-cursor-theme

# echo "🎨 Definindo Bibata como cursor padrão..."
# gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'

echo "🎨 Instalando tema de ícones Papirus..."
sudo pacman -S --noconfirm papirus-icon-theme
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# echo "Virtual Cam no OBS"
# sudo pacman -S linux-headers v4l2loopback-dkms

# echo "🌙 Aplicando tema escuro no sistema..."
# sudo pacman -S --noconfirm  adw-gtk-theme
# gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "🧼 Aplicando tema para Flatpak também..."
mkdir -p ~/.icons
ln -s /usr/share/icons/Bibata-Modern-Classic ~/.icons/default

echo "✅ Script finalizado com sucesso!"
