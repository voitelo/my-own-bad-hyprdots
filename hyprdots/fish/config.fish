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

# function for cd into gemini and running gemini only in ~/gemini
function geminii
    # optional: pass along any arguments
    if test "$PWD" = "$HOME"
        cd gemini
        gemini $argv
    else
        echo "go into your home directory first"
    end
end

# fastfetch alias
alias fastfetch_no_logo="fastfetch --logo none"

# ls aliases (aka eza)
alias 'lss'="eza --color=always  --icons=always --no-time --no-user --long"
alias 'ls'="eza --color=always --icons=always --no-user --no-time"

#--- Aliases for colorized output with bat ---
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
alias yi="yay -S"
alias pi="sudo pacman -S"
alias ri="yay -Rns"
alias pri="sudo pacman -Rns"
alias yc="yay -Yc"
alias w="which" 
alias chroot="arch-chroot"
alias FZF="fzf | xargs -o nvim"

alias kilall="killall"
alias killlall="killall"

# window specific command alias
alias dvd="hyprdvd --workspaces 1,2,3,4,5,6 --exit-on signal -s
kitty,qutebrowser --title DVD"

fastfetch

zoxide init fish | source

export PATH="/bin/scripts:$PATH"
export PATH="/bin/flatpaks:$PATH"

function fish_prompt
    # Get last command exit status
    set exit_code $status

    # Colors using named colors
    set -l col_time (set_color --background black; set_color yellow)
    set -l col_user (set_color --background black; set_color white)
    set -l col_path (set_color --background black; set_color white)
    set -l col_arrow_ok (set_color --background black; set_color white)
    set -l col_arrow_fail (set_color --background black; set_color red)
    set -l col_reset (set_color normal)

    # SSH info
    set -l ssh_info ""
    if set -q SSH_CLIENT
        set ssh_info "(ssh from "(string split " " $SSH_CLIENT)[1]") "
    end

    # Arrow color based on last exit code
    set -l arrow_color $col_arrow_ok
    if test $exit_code -ne 0
        set arrow_color $col_arrow_fail
    end

    echo -n "$ssh_info$col_time"( date +'%H:%M')" $col_path"(pwd)" $arrow_color ❯ $col_reset "
end

function blankline_enter
    if test -z (commandline -t)
        # Empty line: print a newline
        printf "\n"
    else
        # Non-empty line: execute command normally
        commandline -f execute
    end
end

bind \n blankline_enter

# Everything below is just to make the shell feel more interactive
function df
    command df $argv
    echo "Checked filesystem usage"
end

function free
    command free -h $argv
    echo "Memory status checked"
end


function lol
    printf "bro i know right, that was so funy \n"
    printf " "
end

function what
    printf "bro trueee, that was sooo weird \n"
    printf " "
end

function huh
    printf "bro exactly, that was so confusing \n"
    printf " "
end
