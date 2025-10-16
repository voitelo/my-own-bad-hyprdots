# ~/.config/fish/config.fish

# --- History settings ---
set -gx HISTFILE /dev/null
set -gx HISTSIZE 5000
set -gx SAVEHIST 5000
set -gx HISTCONTROL ignoreboth

set -g fish_greeting ""

# --- Only run commands in interactive sessions ---
if not status is-interactive
    exit
end

# --- System aliases ---
alias ls='ls --color=auto'

# --- Aliases for colorized output with bat ---
alias lsblk='lsblk | bat -l conf'
alias lsblc='lsblk | bat -l conf -p'
alias free='free -h | bat -l conf'
alias ps='ps aux | bat -l conf -p'

# --- User-defined aliases ---
alias breezy="$HOME/Breezy/breezy.py"
alias Breezy="$HOME/Breezy/breezy.py"
alias mean="$HOME/Scripts/mean-PM.sh"
alias update="$HOME/Scripts/updateNclean.sh"
alias maintain="$HOME/Scripts/maintanence.sh"
alias vim="nvim"
alias v="nvim"
alias l="ls -lapr"
alias yi="yay -S"
alias pi="sudo pacman -S"
alias ri="yay -Rns"
alias pri="sudo pacman -Rns"
alias yc="yay -Yc"
alias w="which" 
alias chroot="arch-chroot"
alias FZF="fzf | xargs -o nvim"

# --- Flatpak aliases ---
alias discord="flatpak run com.discordapp.Discord"
alias flatseal="flatpak run com.github.tchx84.Flatseal"
alias obs="flatpak run com.obsproject.Studio"
alias spotify="flatpak run com.spotify.Client"
alias steam="flatpak run com.valvesoftware.Steam"
alias sober="flatpak run org.vinegarhq.Sober"
alias roblox="flatpak run org.vinegarhq.Sober"

afetch

# --- Auto-start Hyprland ---
if test (tty) = "/dev/tty1" -a -z "$DISPLAY"
    exec Hyprland
end

# --- Fancy gradient prompt (green → blue → green) ---
function fish_prompt
    # Get current path, shorten if too long
    set p (string replace -r "^$HOME" "$HOME" $PWD)
    set max 30
    if test (string length -- $p) -gt $max
        set parts (string split "/" $p)
        set p "$parts[1]/…/$parts[-2]/$parts[-1]"
    end

    # Gradient colors
    set g 34 35 36 37 38 39 38 37 36 35 34
    set gcount (count $g)
    set l (string length -- $p)

    # Print each character with gradient
    for i in (seq $l)
        set idx (math "floor(($i - 1) * ($gcount - 1) / $l)")
        set c $g[(math "$idx + 1")]
        set ch (string sub -s $i -l 1 -- $p)
        printf "\033[38;5;%dm%s" $c $ch
    end

    printf "\033[0m\n"

    # Print the prompt line with literal >
    printf "-> "
end

