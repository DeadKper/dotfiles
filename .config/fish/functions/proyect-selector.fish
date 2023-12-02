function proyect-selector --argument application
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

    cd "$proyect"
    eval "$application ."
end
