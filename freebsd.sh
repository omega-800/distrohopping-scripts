#!/bin/sh

ech() { echo "### $1 ###"; }
ech2() { echo "- $1"; }
tch() { [ -f "$1" ] || :> "$1"; }
mkd() { [ -d "$1" ] || mkdir -p "$1"; }
ins() { for p in "$@"; do pkg search "$p" > /dev/null || { ech2 "installing $p" && pkg install -y "$p"; }; done }

ech "START"

ech "KEYBOARD LAYOUT"
sysrc keymap="ch.kbd"

ech "TIMEZONE"
cp -v /usr/share/zoneinfo/Europe/Zurich /etc/localtime
adjkerntz -a

ech "USER"
adduser omega -G'wheel video' -d/home/omega -wyes -ssh -q

ech "UPDATE"
pkg update

ech "APPS"
ins git curl neovim ffmpeg kitty

ech "DOAS"
ins doas
echo 'permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel' > /etc/doas.conf

ech "WAYLAND"
ins wayland xwayland seatd dunst ly river-classic
sysrc seatd_enable="YES"
service seatd start

mkd /home/omega/.config/river
echo "#!/bin/sh

riverctl keyboard-layout ch
riverctl map normal Mod4 Return spawn 'kitty'
riverctl map normal Super J focus-view next
riverctl map normal Super K focus-view previous
" > /home/omega/.config/river/init

echo "Ly:\
  :lo=/usr/local/bin/ly:\
  :al=root:" >> /etc/gettytab

# TODO: /etc/ttys
sed -i 's@ttyv1.*@ttyv1 "/usr/libexec/getty Ly" xterm onifexists secure@' /etc/ttys 

ech "CLEANUP"
chown -R omega:omega /home/omega/

ech "DONE"
