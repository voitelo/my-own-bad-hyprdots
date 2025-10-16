#
# ~/.bashrc
#

# history stuff

HISTFILE=/dev/null
HISTSIZE=5000
HISTCONTROL=ignoreboth
SAVEHIST=5000

# Only run in interactive shells
[[ $- != *i* ]] && return

# System made Aliases

alias ls='ls --color=auto'

# bat alias's (for some nice colour)
alias lsblk="lsblk | bat -l conf"
alias lsblc="lsblk | bat -l conf -p"
alias free="free -h | bat -l conf"
alias ps="ps aux | bat -l conf -p"
alias htop="top | bat -l conf"

# user created alias's

alias breezy="$HOME/Breezy/breezy.py"
alias Breezy="$HOME/Breezy/breezy.py"
alias mean="~/Scripts/mean-PM.sh"
alias update="~/Scripts/updateNclean.sh"
alias maintain="/home/dog/Scripts/maintanence.sh"
alias vim="nvim"
alias v="nvim"
alias l="ls -lapr"
alias yi="yay -S"
alias pi="sudo pacman -S"
alias chroot="arch-chroot"
alias FZF="fzf | xargs -o nvim"

# sources (input shit here later)

# user made alias's for flatpaks

alias discord="flatpak run com.discordapp.Discord"
alias flatseal="flatpak run com.github.tchx84.Flatseal"
alias obs="flatpak run com.obsproject.Studio"
alias spotify="flatpak run com.spotify.Client"
alias steam="flatpak run com.valvesoftware.Steam"
alias sober="flatpak run org.vinegarhq.Sober"
alias roblox="flatpak run org.vinegarhq.Sober"

# Add custom scripts to PATH
export PATH="$HOME/Breezy:$PATH"

# running apps/scripts

fastfetch

# Auto-start Hyprland if on tty1 and no DISPLAY


if [[ $(tty) == /dev/tty1 ]] && [[ -z $DISPLAY ]]; then
  exec Hyprland
fi

# Fancy gradient prompt (green → blue → green)

PS1='
\n$(
    p="${PWD/#$HOME/~}"; max=30 # current path, replace $HOME with ~, set max path length

    (( ${#p} > max )) && {
        IFS=/ read -ra a <<< "$p"
        p="${a[0]}/…/${a[-2]}/${a[-1]}"
    } # shorten long paths

    g=(34 35 36 37 38 39 38 37 36 35 34) # gradient color codes (green → blue → green)

    o="" # output string for the colored path

    for ((i=0,l=${#p};i<l;i++)); do
        idx=$(( i * ( ${#g[@]}-1 )/l )) # map character position to gradient index
        c=${g[$idx]} # pick the color from gradient array
        o+="\[\033[38;5;${c}m\]${p:i:1}" # add character with color to output
    done

    echo -n "$o\[\033[0m\]" # print the colored path and reset terminal colors
)\n$ '
