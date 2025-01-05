if [[ -o interactive ]] && which fzf &>/dev/null; then
    if which fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd -t d --min-depth 1'
    else
        export FZF_DEFAULT_COMMAND='find -L . -mindepth 1 -type d \( -path "*/.*" -prune -o -not -name ".*" \) 2>/dev/null | grep -v "/\." | sed "s,^\./,,"'
    fi
    eval "$(fzf --zsh)"
fi
