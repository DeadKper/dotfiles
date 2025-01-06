if [[ -o interactive ]] && which fzf &>/dev/null; then
    if which fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd -t d --min-depth 1'
    else
        export FZF_DEFAULT_COMMAND='find -L . -mindepth 1 -type d \( -path "*/.*" -prune -o -not -name ".*" \) 2>/dev/null | grep -v "/\." | sed "s,^\./,,"'
    fi
    eval "$(fzf --zsh)"
    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false
    # set descriptions format to enable group support
    # NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
    zstyle ':completion:*:*' format '[%d]'
    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
    zstyle ':completion:*' menu no
    # preview directory's content with lsd when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'
    # custom fzf flags
    # NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
    zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
    # To make fzf-tab follow FZF_DEFAULT_OPTS.
    # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
    # switch group using `<` and `>`
    zstyle ':fzf-tab:*' switch-group '<' '>'
    # use tmux popup for showing completion
    #zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi
