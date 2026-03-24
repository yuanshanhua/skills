# ~/.bash_aliases: sourced by ~/.bashrc

# ─── File & directory operations ─────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -Ah'
alias l='ls -CFh'
alias lt='ls -ltrh'
alias lsize='ls -lSrh'
alias tree='tree -C'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias ln='ln -iv'

# ─── Directory navigation ────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# ─── Text & search ──────────────────────────────────────────────────────────
alias less='less -R'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='diff --color=auto'

# ─── System info ─────────────────────────────────────────────────────────────
alias df='df -hT'
alias du='du -sh'
alias du.='du -shd 1'
alias du1='du -h --max-depth=1'
alias free='free -h'
alias top='top -d 1'
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i'

# ─── Network ─────────────────────────────────────────────────────────────────
alias ping='ping -c 5'
alias ports='ss -tulnp'
alias myip='curl -s https://ifconfig.me && echo'
alias localip="ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"

# ─── Git shortcuts ───────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch -vv'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias gstp='git stash pop'

# ─── Editor ──────────────────────────────────────────────────────────────────
alias vi='vim'
alias v='vim'

# ─── Utilities ───────────────────────────────────────────────────────────────
alias c='clear'
alias h='history'
alias hg='history | grep'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias reload='source ~/.bashrc'
alias bashrc='${EDITOR:-vim} ~/.bashrc'
alias aliases='${EDITOR:-vim} ~/.bash_aliases'

# ─── Safety ──────────────────────────────────────────────────────────────────
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# ─── Pueue (only if installed) ───────────────────────────────────────────────
if command -v pueue &>/dev/null; then
    alias t='pueue'
    alias tt='pueue add -s'
    alias t-re='pueue restart -is'
    alias t-kill='pueue kill -s 9'
fi

# ─── Functions ───────────────────────────────────────────────────────────────

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Universal extractor
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1"    ;;
            *.tar.gz)   tar xzf "$1"    ;;
            *.tar.xz)   tar xJf "$1"    ;;
            *.tar.zst)  tar --zstd -xf "$1" ;;
            *.bz2)      bunzip2 "$1"    ;;
            *.gz)       gunzip "$1"     ;;
            *.tar)      tar xf "$1"     ;;
            *.tbz2)     tar xjf "$1"    ;;
            *.tgz)      tar xzf "$1"    ;;
            *.zip)      unzip "$1"      ;;
            *.Z)        uncompress "$1" ;;
            *.7z)       7z x "$1"       ;;
            *.xz)       unxz "$1"       ;;
            *.rar)      unrar x "$1"    ;;
            *)          echo "'$1' cannot be extracted — unrecognized format" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Search file contents recursively
ftext() {
    grep -iIr --color=always "$1" . | less -R
}

# Quick backup with timestamp
bak() {
    cp -v "$1" "${1}.bak.$(date +%Y%m%d_%H%M%S)"
}

# Yazi file manager integration (only if installed)
if command -v yazi &>/dev/null; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
    }
fi

# ─── User specific ───────────────────────────────────────────────────────

