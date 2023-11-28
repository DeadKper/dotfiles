function proyect-selector --argument filter application return
    if test -f "$HOME/.config/proyect-selector.fish"
        source "$HOME/.config/proyect-selector.fish"
    end

    if test (count $folders_depth1) -gt 0
        set -a proyects (find $folders_depth1 -maxdepth 1 -mindepth 1 -type d)
    end
    if test (count $folders_depth2) -gt 0
        set -a proyects (find $folders_depth2 -maxdepth 2 -mindepth 2 -type d)
    end

    if test -z "$filter" -o "$filter" = "*" -o "$filter" = "."
        set -f proyect (printf '%s\n' $proyects | fzf)
    else
        set -f proyect (printf '%s\n' $proyects | grep "$filter" | fzf)
    end

    if test -z "$proyect"
        return 1
    end

    if test -z "$application" -o "$application" = "."
        set -f application vim
    end

    set -f pwd "$PWD"
    cd "$proyect"
    eval "$application" "$proyect"

    if test "$return" = "true" -o "$return" = "1"
        cd "$pwd"
    end
end
