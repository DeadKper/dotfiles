if status is-interactive; and type -q fzf
    if type -q fd
        set -x FZF_DEFAULT_COMMAND 'fd -H'
    end
    if type -q tmux
        set -x FZF_DEFAULT_OPTS --tmux 90%
    end
    fzf --fish | source
end
