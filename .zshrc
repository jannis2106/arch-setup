# ZSH
export ZSH="$HOME/.oh-my-zsh"
export HISTFILE="$HOME/zsh/history"

### Theme ###
ZSH_THEME="agnoster"

### Plugins ###
plugins=(
    git 
    zsh-autosuggestions
    copyfile
    vi-mode
)

source $ZSH/oh-my-zsh.sh

### Aliases ###

# confirm commands
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# change "ls" to "exa"
alias ls="exa -al --group-directories-first"
alias lt="exa -aT --group-directories-first --icons"

# change "cat" to "bat"
alias cat="bat"

# pacman / yay
alias pac="sudo pacman"
alias pacsyu="sudo pacman -Syu"		# update package list and upgrade all packages afterwards
alias yaysua="yay -Sua --noconfirm" 	# synchronize and update AUR packages

# vim
alias v="vim"

# clear
alias c="clear"

# formatted date and time
alias ddate="date +'%R - %a, %B %d, %Y'"
alias ttime="while true; do tput clear; date +'%H : %M : %S' | figlet ; sleep 1; done"

# git
alias add="git add"
alias commit="git commit -m"
alias push="git push"
alias status="git status"
