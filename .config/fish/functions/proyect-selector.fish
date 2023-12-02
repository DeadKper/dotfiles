function proyect-selector --argument application
    if test -f "$HOME/.config/proyect-selector.fish"
        source "$HOME/.config/proyect-selector.fish"
    end

    if ! type -q $application
        echo "Unknown command: $application"
        return 1
    end

    if test -z "$application" -o "$application" = "."
        if type -q nvim
            set -f application nvim
        else if type -q vim
            set -f application vim
        else if type -q vi
            set -f application vi
        else
            echo "Cannot set default application to nvim, vim or vi" 1>&2
            return 1
        end
    end

    set -f proyect (printf '%s\n' $proyects | sort | fzf | sed -E "s,^~,$HOME,")

    if test -z "$proyect"
        return 1
    end

    cd "$proyect"
    eval "$application ."
end
