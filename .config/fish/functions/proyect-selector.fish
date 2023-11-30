function proyect-selector --argument application return
    if test -f "$HOME/.config/proyect-selector.fish"
        source "$HOME/.config/proyect-selector.fish"
    end

    if ! type -q $application
        echo "Unknown command: $application"
        return 1
    end

    set -f proyect (printf '%s\n' $proyects | sort | fzf | sed -E "s,^~,$HOME,")

    if test -z "$proyect"
        return 1
    end

    if test -z "$application" -o "$application" = "."
        set -f application vim
    end

    set -f pwd "$PWD"
    cd "$proyect"
    eval "$application" "$proyect"

    if test "$return" = "true" -a "$application" != "cd"
        cd "$pwd"
    end
end
