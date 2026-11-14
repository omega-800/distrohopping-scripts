#!/bin/sh

ech() { echo "### $1 ###"; }
ech2() { echo "- $1"; }
tch() { [ -f "$1" ] || :> "$1"; }
# TODO: posix mkdir
mkd() { [ -d "$1" ] || mkdir -p "$1"; }
ins() { for p in "$@"; do pkg search "$p" > /dev/null || { ech2 "installing $p" && pkg install -y "$p"; }; done }
# TODO: template vars
tpl() { mkd "$(dirname "$2")" && cp "$1" "$2"; }

ech "START"

ech "KEYBOARD LAYOUT"
sysrc keymap="ch.kbd"

if [ ! -e /etc/localtime ]; then
  ech "TIMEZONE"
  cp -v /usr/share/zoneinfo/Europe/Zurich /etc/localtime
  adjkerntz -a
fi

ech "UPDATE"
pkg update
sysrc linux_enable="YES"
service linux start

ech "APPS"
ins git curl neovim zsh \
  swaylock flameshot rofi \
  pass yazi ripgrep opencode \
  discord iamb siggy aerc \
  drawio libreoffice xournalpp \
  zathura feh mpv \
  qutebrowser firefox chromium wireshark \
  wshowkeys woomer
# TODO: calcurse or sth

id omega > /dev/null || { ech "USER" && adduser omega -G'wheel video' -d/home/omega -wyes -szsh -q; }
# TODO: mk std dirs
mkd /home/omega/doc/cal/school
mkd /home/omega/doc/media/img/screenshots
mkd /home/omega/ws
mkd /home/omega/dl/iamb
mkd /home/omega/dl/siggy

ech "DOAS"
ins doas
echo 'permit setenv {PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin} :wheel' > /etc/doas.conf

ech "WAYLAND"
ins wayland xwayland seatd river-classic ly dunst kitty 7z
sysrc seatd_enable="YES"
service seatd start

grep Ly /etc/gettytab ||
  echo "Ly:\
    :lo=/usr/local/bin/ly:\
    :al=root:" >> /etc/gettytab

# TODO: simpler sed
grep Ly /etc/ttys ||
  sed -i 's@ttyv1.*@ttyv1 "/usr/libexec/getty Ly" xterm onifexists secure@' /etc/ttys 

# TODO: gpu
# sysrc kld_list+="i915kms"

ech "RIVER"
mkd /home/omega/.config/river
echo "#!/bin/sh

riverctl keyboard-layout ch
riverctl map normal Super Return spawn foot
riverctl map normal Super J focus-view next
riverctl map normal Super K focus-view previous
riverctl map normal Super Q close
riverctl map normal Super+Shift Q exit
" > /home/omega/.config/river/init

if [ ! -f /home/omega/.local/share/fonts/JetBrainsMonoNLNerdFont-Regular.ttf ]; then
  ech "FONTS"
  curl -sSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/JetBrainsMono.zip
  mkd /home/omega/.local/share/fonts
  unzip JetBrainsMono.zip -d /home/omega/.local/share/fonts
  fc-cache -f
  rm JetBrainsMono.zip
fi

ech "CLEANUP"
chown -R omega:omega /home/omega/

ech "DONE"
