#zmodload zsh/zprof

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Path stuff
[[ ":$PATH:" != *"${HOME}/.scripts/"* ]] && PATH="${HOME}/.scripts/:${PATH}"
[[ ":$PATH:" != *"${HOME}/.scripts/bin"* ]] && PATH="${HOME}/.scripts/bin:${PATH}"
[[ ":$PATH:" != *"${HOME}/.wireshark/"* ]] && PATH="${HOME}/.wireshark/:${PATH}"
[[ ":$PATH:" != *"${HOME}/.cargo/bin/"* ]] && PATH="${HOME}/.cargo/bin/:${PATH}"
[[ ":$PATH:" != *"${GOPATH}/bin/"* ]] && PATH="${GOPATH}/bin/:${PATH}"
[[ ":$PATH:" != *"${HOME}/.local/bin/"* ]] && PATH="${HOME}/.local/bin/:${PATH}"

alias rawcat="stty raw icrnl -echo; netcat"
alias fd=fdfind
alias rg="rg --follow"
alias l="ls"
alias ll="ls -l"
alias g=git
alias v=nvim
alias vi=nvim
alias vim=nvim
alias sl=ls
alias open=xdg-open
alias bell="echo -e '\a'"
alias cd..="cd .."
alias dc=cd
alias lss="less -I"

alias ipy="bpython"
alias bpy=ipy
alias ipy3=ipy
alias bpy3=ipy

alias gjd="git jump diff"
alias gjm="git jump merge"

export EDITOR=nvim
export PAGER=less
export editor=$EDITOR
export TIG_EDITOR=$EDITOR
export GIT_EDITOR=$EDITOR

# Build script
function b() {
    anybuild -v
    # build $@
    echo -e '\a'
}

alias ndu="ncdu -rr -x --exclude .git --exclude node_modules"
alias cht=cht.sh
alias tmux="TERM=xterm-256color tmux"

export HISTORY_IGNORE="(&|[ ]*|exit|ls|bg|fg|history|rlog|log|tig|gjm|r|share-tmux|clear|gk|'|pwd|rlog)"

# stop your hand holding zsh!
unalias cp
unalias rm
unalias b
setopt clobber

function rename_tmux_to_git() {
    if [ -n "$TMUX" ]; then
        BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        WINNAME=$(basename "$PWD")
        [ -n "$BRANCH" ] && WINNAME=$BRANCH
        [ "$WINNAME" = "$USER" ] && WINNAME=home
        tmux rename-window " $WINNAME"
    fi
}
rename_tmux_to_git

autoload -U add-zsh-hook
add-zsh-hook chpwd rename_tmux_to_git

HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

export FZF_DEFAULT_OPTS=" \
--color=bg+:#363A4F,bg:#24273A,spinner:#F4DBD6,hl:#ED8796 \
--color=fg:#CAD3F5,header:#ED8796,info:#C6A0F6,pointer:#F4DBD6 \
--color=marker:#B7BDF8,fg+:#CAD3F5,prompt:#C6A0F6,hl+:#ED8796 \
--color=selected-bg:#494D64 \
--color=border:#6E738D,label:#CAD3F5"

if [[ -z "$LANG" ]]; then
    export LANG='en_US.UTF-8'
fi
