if status is-interactive; and type -q starship
    set -x STARSHIP_LOG error

    if type -q starship
        starship init fish | source
    end
end
