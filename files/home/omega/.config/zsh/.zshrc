typeset -U path cdpath fpath manpath

plugin_dirs=(
  zsh-abbr
)
for plugin_dir in "${plugin_dirs[@]}"; do
  path+="/home/omega/.config/zsh/plugins/$plugin_dir"
  fpath+="/home/omega/.config/zsh/plugins/$plugin_dir"
  for plugin_fpath_dir in \
    "$plugin_dir/share/zsh/plugins/$plugin_dir" \
    "$plugin_dir/share/zsh/site-functions" \
    "$plugin_dir/share/zsh/vendor-completions"; do
    [[ -d "/home/omega/.config/zsh/plugins/$plugin_fpath_dir" ]] && fpath+="/home/omega/.config/zsh/plugins/$plugin_fpath_dir"
  done
done
unset plugin_dir plugin_dirs plugin_fpath_dir


ZSH_AUTOSUGGEST_STRATEGY=(history)

plugins=(git docker tmux vi-mode history npm node git-extras git-auto-fetch)

source $ZSH/oh-my-zsh.sh

plugins=(
  zsh-abbr/share/zsh/zsh-abbr/zsh-abbr.plugin.zsh
)
for plugin in "${plugins[@]}"; do
  [[ -f "/home/omega/.config/zsh/plugins/$plugin" ]] && source "/home/omega/.config/zsh/plugins/$plugin"
done
unset plugin plugins

HISTSIZE="100000"
SAVEHIST="10000"
HISTORY_IGNORE='(ll|ls|exit|clear|c|x|l)'
HISTFILE="/home/omega/.local/state/shell/history"
mkdir -p "$(dirname "$HISTFILE")"

if [[ $options[zle] = on ]]; then
  source <(fzf --zsh)
fi

set_opts=(
  HIST_FCNTL_LOCK HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE
  SHARE_HISTORY autocd NO_APPEND_HISTORY NO_EXTENDED_HISTORY
  NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS
)
for opt in "${set_opts[@]}"; do
  setopt "$opt"
done
unset opt set_opts

# TODO: 
# source /nix/store/jmki6acqs0s7vf694ax6ljc1sjn4ihxh-functions;
# source /nix/store/g1mcappzysc9d56f1554m8hlrfi5y7hp-ssh;

export GPG_AGENT_INFO
export SSH_AUTH_SOCK
export PINENTRY_USER_DATA=USE_TTY=1
export GPG_TTY=$(tty)
unset SSH_ASKPASS
unset GIT_ASKPASS

gpg-connect-agent updatestartuptty /bye >/dev/null

setopt noautomenu

PROMPT=$'\n%(?.%{\e[7;49;36m%}.%{\e[7;49;35m%})'"%n"$'%(?.%{\e[0;40;36m%}.%{\e[0;40;35m%})'""$'%(?.%{\e[0;40;36m%}.%{\e[0;40;35m%})'" %~"$'%{\e[0;49;30m%}'""
PROMPT+=$'%{\e[m%}\n%{\e[7;49;35m%}'"%m"$'%{\e[0;40;35m%}'""$'%{\e[0;40;35m%}'" %j"$'%{\e[7;49;35m%}'""$'%{\e[7;49;35m%}'
PROMPT+=" zsh"$'%{\e[0;40;35m%}'""$'%{\e[0;40;35m%}'" %!"$'%{\e[0;49;30m%}'""$'%{\e[0;40;35m%}'"%(!.#.$) "$'%{\e[m%}'

autoload -Uz add-zsh-hook vcs_info

setopt prompt_subst

add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats $'%{\e[0;40;35m%}'""$'%{\e[7;49;35m%}'"%s "$'%{\e[0;40;35m%}'"%b "$'%{\e[0;40;35m%}'""$'%{\e[7;49;35m%}'"%u%c "
zstyle ':vcs_info:git*' actionformats $'%{\e[0;40;35m%}'""$'%{\e[7;49;35m%}'"%a"
zstyle ':vcs_info:git*' unstagedstr '*'
zstyle ':vcs_info:git*' stagedstr '+'
zstyle ':vcs_info:*:*' check-for-changes true

RPROMPT=$'%{\e[0;49;30m%}'""$'%{\e[0;40;35m%}'"%* "'$vcs_info_msg_0_'$'%{\e[m%}'

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="no-rc no-sudo no-cursor"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

eval "$(direnv hook zsh)"

export GPG_TTY=$TTY

alias -- ..='cd ../'
alias -- ...='cd ../../'
alias -- ....='cd ../../../'
alias -- .....='cd ../../../../'
alias -- ......='cd ../../../../../'
alias -- .......='cd ../../../../../../'
alias -- ........='cd ../../../../../../../'
alias -- .........='cd ../../../../../../../../'
alias -- ..........='cd ../../../../../../../../../'
alias -- ...........='cd ../../../../../../../../../../'
alias -- ............='cd ../../../../../../../../../../../'
alias -- .............='cd ../../../../../../../../../../../../'
alias -- ..............='cd ../../../../../../../../../../../../../'
alias -- ...............='cd ../../../../../../../../../../../../../../'
alias -- ................='cd ../../../../../../../../../../../../../../../'
alias -- .................='cd ../../../../../../../../../../../../../../../../'
alias -- ..................='cd ../../../../../../../../../../../../../../../../../'
alias -- ...................='cd ../../../../../../../../../../../../../../../../../../'
alias -- ....................='cd ../../../../../../../../../../../../../../../../../../../'
alias -- .....................='cd ../../../../../../../../../../../../../../../../../../../../'
alias -- ag='alias | grep'
alias -- c=clear
alias -- cal='cal -m'
alias -- clip='wl-copy <'
alias -- cocker='docker compose'
alias -- cp='cp -i'
alias -- cpr='tar -czvf'
alias -- cpv='rsync -ah --info=progress2'
alias -- dbr='docker run --rm -it $(docker build -q .)'
alias -- dfr='diff -ZBbwdryEN --color --suppress-common-lines --no-dereference --speed-large-files'
alias -- dir='dir --color=auto'
alias -- drma='docker stop $(docker ps -a --format "{{.ID}}") && docker rm $(docker ps -a --format "{{.ID}}")'
alias -- drmav='docker volume rm $(docker volume ls --format "{{.Name}}")'
alias -- dsa='docker stop $(docker ps -a --format "{{.ID}}")'
alias -- egrep='egrep --color=auto'
alias -- entry='vim $(date +%y%m%d).txt'
alias -- fd='fd --hidden'
alias -- fdel='find . -size 0 -print -delete'
alias -- fdwatchers='find /proc/*/fd/ -type l -lname "anon_inode:inotify" -printf "%hinfo/%f\n" | xargs grep -cE "^inotify" | sort -nk2 -t: | column -t -s:'
alias -- fgrep='fgrep --color=auto'
alias -- get='nix-shell -p'
alias -- gp='git fetch && git pull'
alias -- grep='grep --color=auto'
alias -- grepr='grep -nRHIi'
alias -- greprf='grep -Rl'
alias -- gst='git status'
alias -- hg='history | grep'
alias -- ipinfo='curl ifconfig.me && curl ifconfig.me/host'
alias -- k_ch='setxkbmap -layout ch -variant de'
alias -- k_en='setxkbmap -layout us'
alias -- klt='khal list today'
alias -- kltm='khal list tomorrow'
alias -- l='ls -CF'
alias -- la='ls -A'
alias -- lg='ll | grep'
alias -- ll='exa --icons -a -l -F -h -g -s size --git'
alias -- loc='locate -A'
alias -- ls='ls --color=auto'
alias -- lt='ls --human-readable --size -1 -S --classify'
alias -- mv='mv -i'
alias -- nano=vim
alias -- ntyp='d="$(date +%y.%m.%d)"; f="$d.typ"; ( [ -f "$f" ] || echo "= $d" >> "$f" ) && vim "$f"'
alias -- nwtyp='typst watch "$(date +%y.%m.%d).typ"'
alias -- please=sudo
alias -- qmk_cmp='qmk compile -kb handwired/dactyl_manuform/4x6_omega -km custom'
alias -- qmk_left='qmk flash -kb handwired/dactyl_manuform/4x6_omega -km custom -bl avrdude-split-left'
alias -- qmk_right='qmk flash -kb handwired/dactyl_manuform/4x6_omega -km custom -bl avrdude-split-right'
alias -- rg='rg --hidden'
alias -- rm=trash
alias -- ssh='TERM=xterm-256color ssh'
alias -- switch-git-to-ssh='new_origin="$(git config --get remote.origin.url | sed -E "s/https:\/\/([^\/]*)\/(.*)$/git@\1:\2/")"; git remote rm origin && git remote add origin "$new_origin"'
alias -- tarbak='tar -czvf $(date +%F)-backup.tgz backup/'
alias -- tree='exa --tree --icons -a -I '\''.git|.svn|node_modules'\'''
alias -- treea='exa --tree --icons -a -l -F -h -g -s size --git'
alias -- treed='exa --tree --icons -a -I '\''.git|.svn|node_modules'\'' -D'
alias -- vdir='vdir --color=auto'
alias -- vf='vim $(fzf)'
alias -- vi=nvim
alias -- vim=nvim
alias -- vimtmp='vim $(mktemp)'
alias -- vpn-school-cookie='openconnect-sso -s vpn2.ost.ch --authenticate json'
alias -- x=exit
alias -- yq='yq -Pojson'
# TODO:
# source /nix/store/flm0avh0db0g4k8wsvyvbz7r2p2aw9pa-zsh-syntax-highlighting-0.8.0/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main main brackets line root)

ZSH_HIGHLIGHT_PATTERNS+=('rm -rf' 'fg=white,bold,bg=red')

