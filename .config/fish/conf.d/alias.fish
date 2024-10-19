if status is-interactive
    if type -q lsd
        alias ls="lsd"
        alias lt="ls --tree"
        alias tree="ls --tree"
    else
        alias ls="ls --color=auto"
    end

    alias l="ls -l"
    alias ll="ls -l"
    alias la="ls -A"
    alias lla="ls -lA"

    if type -q fzf
        alias cf='cd "$(fzf)"'
        alias zf='z "$(fzf)"'
    end
end
