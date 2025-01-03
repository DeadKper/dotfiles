if [[ -o interactive ]] && which fzf &>/dev/null; then
    if which fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd -u -t d --min-depth 1 | sort -r'
    else
        export FZF_DEFAULT_COMMAND='find -mindepth 1 -type d | sort -r'
    fi
    # if which tmux &>/dev/null; then
    #     export FZF_DEFAULT_OPTS='--tmux 90%'
    # fi
    eval "$(fzf --zsh)"
fi
