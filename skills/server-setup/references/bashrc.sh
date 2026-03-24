# ~/.bashrc: executed for every interactive non-login shell

# ─── 1. Non-interactive guard ─────────────────────────────────────────────────
case $- in
    *i*) ;;
      *) return;;
esac

# ─── 2. History settings ─────────────────────────────────────────────────────
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%F %T "
shopt -s histappend

# ─── 3. Shell options ────────────────────────────────────────────────────────
shopt -s checkwinsize
shopt -s globstar
shopt -s cdspell
shopt -s autocd

# ─── 4. Terminal color definitions ───────────────────────────────────────────
BLACK='\[\e[0;30m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
YELLOW='\[\e[0;33m\]'
BLUE='\[\e[0;34m\]'
PURPLE='\[\e[0;35m\]'
CYAN='\[\e[0;36m\]'
WHITE='\[\e[0;37m\]'

BOLD_RED='\[\e[1;31m\]'
BOLD_GREEN='\[\e[1;32m\]'
BOLD_YELLOW='\[\e[1;33m\]'
BOLD_BLUE='\[\e[1;34m\]'
BOLD_PURPLE='\[\e[1;35m\]'
BOLD_CYAN='\[\e[1;36m\]'
BOLD_WHITE='\[\e[1;37m\]'

RESET='\[\e[0m\]'

# ─── 5. PS1 prompt ──────────────────────────────────────────────────────────
# Format: user@host cwd (git-branch) (python-env)
# Newline then $ or #, color changes based on last command's exit status
__set_ps1() {
    local exit_code=$?

    local status_color
    if [ $exit_code -eq 0 ]; then
        status_color='\[\e[1;32m\]'
    else
        status_color='\[\e[1;31m\]'
    fi

    local user_color
    if [ "$EUID" -eq 0 ]; then
        user_color='\[\e[1;31m\]'
    else
        user_color='\[\e[1;32m\]'
    fi

    # Python virtual env (conda / uv / venv)
    local py_env=""
    if [ -n "${CONDA_DEFAULT_ENV:-}" ] && [ "${CONDA_DEFAULT_ENV}" != "base" ]; then
        py_env="conda:${CONDA_DEFAULT_ENV}"
    elif [ -n "${VIRTUAL_ENV:-}" ]; then
        py_env="$(basename "${VIRTUAL_ENV}")"
    fi
    local py_env_str=""
    if [ -n "$py_env" ]; then
        py_env_str=" \[\e[0;35m\](${py_env})\[\e[0m\]"
    fi

    # Git branch
    local git_branch=""
    if command -v git &>/dev/null; then
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null \
                 || git describe --tags --exact-match 2>/dev/null)
        if [ -n "$branch" ]; then
            if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
                git_branch=" \[\e[1;33m\](${branch}*)\[\e[0m\]"
            else
                git_branch=" \[\e[1;36m\](${branch})\[\e[0m\]"
            fi
        fi
    fi

    PS1="${user_color}\u\[\e[0m\]"
    PS1+="${WHITE}@\[\e[0m\]"
    PS1+="\[\e[1;34m\]\h\[\e[0m\]"
    PS1+=" ${BOLD_CYAN}\w\[\e[0m\]"
    PS1+="${py_env_str}"
    PS1+="${git_branch}"
    PS1+="\n${status_color}\$\[\e[0m\] "
}

PROMPT_COMMAND='__set_ps1'

# ─── 6. Terminal title (xterm/screen/tmux) ───────────────────────────────────
case "$TERM" in
xterm*|rxvt*|screen*|tmux*)
    PROMPT_COMMAND="${PROMPT_COMMAND}; echo -ne \"\033]0;\${USER}@\${HOSTNAME}: \${PWD}\007\""
    ;;
esac

# ─── 7. Color support ───────────────────────────────────────────────────────
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ─── 8. Source aliases ───────────────────────────────────────────────────────
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ─── 9. Source local overrides (machine-specific) ────────────────────────────
if [ -f ~/.bashrc_local ]; then
    . ~/.bashrc_local
fi

# ─── 10. Bash completion ────────────────────────────────────────────────────
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ─── 11. Environment variables ──────────────────────────────────────────────
if command -v code &>/dev/null; then
    export EDITOR='code --wait'
    export VISUAL='code --wait'
else
    export EDITOR=vim
    export VISUAL=vim
fi
export PAGER=less
export LESS='-R --use-color -Dd+r$Du+b'
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"


