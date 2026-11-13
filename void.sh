#!/usr/bin/env bash

ech() { echo "### $1 ###"; }
ech2() { echo "- $1"; }
tch() { [ -f "$1" ] || :> "$1"; }
mkd() { [ -d "$1" ] || mkdir -p "$1"; }
ins() { for p in "$@"; do xbps-query "$p" > /dev/null || { ech2 "installing $p" && xi -y "$p"; }; done }

ech "START"

if [ ! -f init-done ]; then
  ech "WIFI SETUP"
  sh -c "wpa_passphrase tilde $1 >> /etc/wpa_supplicant/wpa_supplicant.conf"
  wpa_supplicant -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlp2s0 > /dev/null &
fi

ech "SYSTEM UPDATE"
xi -Syu
xi -yu xbps
xi -Syu

ech "UNFREE REPOS"
ins void-repo-{multilib{,-nonfree},nonfree}
ins intel-ucode

ech "APPS"
# TODO: foot
ins xtools git curl neovim base-devel ffmpeg kitty

ech "DOAS"
ins opendoas
echo 'ignorepkg=sudo' > /etc/xbps.d/10-ignore.conf
# TODO: doas rules
echo 'permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel' > /etc/doas.conf
xbps-remove -OoRy sudo

ech "CRON FSTRIM"
mkd /etc/cron.weekly
echo '#!/bin/sh

fstrim /' > /etc/cron.weekly/fstrim
chmod u+x /etc/cron.weekly/fstrim

# TODO: zram

ech "WAYLAND"
ins dbus elogind linux-firmware-intel mesa-{dri,vaapi,vdpau,vulkan-radeon} vulkan-loader wlr-randr xdg-desktop-portal-wlr
[ -f /var/service/dbus ] || ln -s /etc/sv/dbus /var/service/
[ -f /var/service/elogind ] || ln -s /etc/sv/elogind /var/service/
mkd /home/omega/.config/bash
echo 'QT_QTA_PLATFORM="wayland-egl"
ELM_DISPLAY="wl"
SDL_VIDEODRIVER="wayland"' > /home/omega/.config/bash/envrc

ech "RIVER"
ins wayland{,-protocols,-devel} {pixman,lib{input,xkbcommon,evdev}}{,-devel} wlroots pkg-config scdoc
xbps-install -yR https://github.com/VUP-Linux/vup/releases/download/core-x86_64-current -S zig15
# xbps-install -yR https://github.com/VUP-Linux/vup/releases/download/core-x86_64-current -S vuru
# doas -u omega -- vuru install -y zig15
[ ! -d river-classic ] && git clone https://codeberg.org/river/river-classic
pushd river-classic
git checkout ea4774c6
zig build -Doptimize=ReleaseSafe -Dxwayland --prefix /home/omega/.local install
popd
echo "#!/bin/sh

riverctl keyboard-layout ch
riverctl map normal Super Return spawn kitty
riverctl map normal Super J focus-view next
riverctl map normal Super K focus-view previous
riverctl map normal Super Q close
riverctl map normal Super+Shift Q exit
" > /home/omega/.config/river/init

ech "PIPEWIRE"
# TODO: finish
ins pipewire{,-pulse} pulseaudio-utils pavucontrol
mkd /etc/pipewire/pipewire.conf.d
[ -f /etc/pipewire/pipewire.conf.d/10-wireplumber.conf ] || ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
[ -f /etc/pipewire/pipewire.conf.d/20-pipewire-pulse.conf ] || ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

ech "CLEANUP"
chown -R omega:omega /home/omega/

ech "DONE"
echo "TODO: xcheckrestart"
# TODO: mesa-vdpau pipewire-pulse not found in repository pool
