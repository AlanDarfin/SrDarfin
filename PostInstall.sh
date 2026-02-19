#!/bin/bash
# ==========================================================
# Pós-instalação Arch Linux — KDE Plasma
# ==========================================================

set -e

# ----------------------------------------------------------
# Função utilitária para instalar pacotes sem reinstalar
# ----------------------------------------------------------
install_pkgs() {
  sudo pacman -S --noconfirm --needed "$@"
}

# ----------------------------------------------------------
# Mirrors e atualização
# ----------------------------------------------------------
echo "==> Ajustando mirrors (Brasil)..."
install_pkgs --noconfirm reflector
sudo reflector \
  --country Brazil \
  --age 12 \
  --protocol https \
  --sort rate \
  --save /etc/pacman.d/mirrorlist

echo "==> Atualizando sistema..."
sudo pacman -Syu --noconfirm

# ----------------------------------------------------------
# Base essencial
# ----------------------------------------------------------
echo "==> Instalando utilitários básicos..."
install_pkgs --noconfirm \
  base-devel \
  git \
  curl \
  wget \
  unzip \
  p7zip \
  rsync \
  htop \
  fastfetch \
  man-db \
  man-pages

# ----------------------------------------------------------
# AUR helper (yay ou paru)
# ----------------------------------------------------------
echo
read -rp "Qual AUR helper deseja instalar? [yay/paru/N]: " aurhelper

case "$aurhelper" in
  yay)
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    ;;
  paru)
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    rm -rf /tmp/paru
    ;;
  *)
    echo "Nenhum AUR helper será instalado."
    ;;
esac

# ----------------------------------------------------------
# Fontes (CJK e essenciais)
# ----------------------------------------------------------
echo "==> Instalando fontes..."
install_pkgs --noconfirm \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  ttf-dejavu \
  ttf-liberation

# ----------------------------------------------------------
# Fish shell
# ----------------------------------------------------------
echo "==> Instalando Fish shell..."
install_pkgs --noconfirm fish
chsh -s /usr/bin/fish || true

# ----------------------------------------------------------
# Bluetooth
# ----------------------------------------------------------
echo "==> Configurando Bluetooth..."
install_pkgs --noconfirm bluez bluez-utils
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# ----------------------------------------------------------
# Rede: ZeroTier
# ----------------------------------------------------------
echo "==> Instalando ZeroTier..."
install_pkgs --noconfirm zerotier-one
sudo systemctl enable zerotier-one.service
sudo systemctl start zerotier-one.service

# ----------------------------------------------------------
# Syncthing
# ----------------------------------------------------------
echo "==> Instalando Syncthing..."
install_pkgs --noconfirm syncthing
systemctl --user enable syncthing.service
systemctl --user start syncthing.service

# ----------------------------------------------------------
# Flatpak + Flathub
# ----------------------------------------------------------
echo "==> Instalando Flatpak..."
install_pkgs --noconfirm flatpak

sudo flatpak remote-add --if-not-exists \
  flathub https://flathub.org/repo/flathub.flatpakrepo

# ----------------------------------------------------------
# Ferramentas Flatpak
# ----------------------------------------------------------
flatpak install -y flathub \
  io.github.kolunmi.Bazaar \
  com.github.tchx84.Flatseal \
  io.github.giantpinkrobots.flatsweep

# ----------------------------------------------------------
# Aplicativos Flatpak
# ----------------------------------------------------------
flatpak install -y flathub \
  md.obsidian.Obsidian \
  com.discordapp.Discord \
  com.spotify.Client \
  com.vivaldi.Vivaldi \
  menu.kando.Kando \
  com.heroicgameslauncher.hgl \
  org.vinegarhq.Sober

# ----------------------------------------------------------
# OBS Studio
# ----------------------------------------------------------
install_pkgs --noconfirm obs-studio

# ----------------------------------------------------------
# Jogos e emulação
# ----------------------------------------------------------
install_pkgs --noconfirm \
  steam \
  retroarch \
  wine \
  winetricks \
  wine-mono \
  wine-gecko

# ----------------------------------------------------------
# KDE visual
# ----------------------------------------------------------
install_pkgs --noconfirm \
  papirus-icon-theme \
  breeze \
  breeze-gtk

# ----------------------------------------------------------
# Áudio e vídeo
# ----------------------------------------------------------
install_pkgs --noconfirm \
  pipewire \
  pipewire-alsa \
  pipewire-pulse \
  pipewire-jack \
  wireplumber \
  gst-libav \
  gst-plugins-good \
  gst-plugins-bad \
  gst-plugins-ugly

# ----------------------------------------------------------
# Integração visual Flatpak
# ----------------------------------------------------------
sudo flatpak override --system \
  --filesystem=/usr/share/icons:ro \
  --env=GTK_THEME=Breeze-Dark \
  --env=QT_STYLE_OVERRIDE=breeze

# ----------------------------------------------------------
# Forçar GTK3 em modo escuro
# ----------------------------------------------------------
mkdir -p ~/.config/gtk-3.0

cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-application-prefer-dark-theme=true
EOF

# ----------------------------------------------------------
# Remover Firefox se existir
# ----------------------------------------------------------
if pacman -Qi firefox &>/dev/null; then
  sudo pacman -Rns --noconfirm firefox
fi

# ----------------------------------------------------------
# Limpeza de pacotes órfãos
# ----------------------------------------------------------
ORPHANS=$(pacman -Qtdq || true)

if [[ -n "$ORPHANS" ]]; then
  echo "$ORPHANS"
  read -rp "Deseja remover pacotes órfãos? [s/N]: " limpar
  [[ "$limpar" =~ ^([sS]|[sS][iI][mM])$ ]] && sudo pacman -Rns $ORPHANS
fi

# ----------------------------------------------------------
# Finalização
# ----------------------------------------------------------
echo
read -rp "Deseja reiniciar o sistema agora? [s/N]: " resposta
[[ "$resposta" =~ ^([sS]|[sS][iI][mM])$ ]] && sudo reboot
