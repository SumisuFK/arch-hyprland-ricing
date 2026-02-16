#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls  --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias chromium='chromium --proxy-server="socks5://127.0.0.1:1080"'
alias discord='discord --proxy-server="socks5://127.0.0.1:1080"'
alias spotify='spotify --proxy-server="socks5://127.0.0.1:1080"'

PS1='[\u@\h \W]\$ '

if [[ $- == *i* ]]; then
    fastfetch
fi

[[ -r /usr/share/bash-completion ]] && . /usr/share/bash-completion/bash_completion
