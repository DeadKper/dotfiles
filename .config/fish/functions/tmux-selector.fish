function tmux-selector --argument type application sort
    if test -f "$HOME/.config/proyect-selector.fish"
        source "$HOME/.config/proyect-selector.fish"
    else
        echo "Cannot source '$HOME/.config/proyect-selector.fish' because it doesn't exist" 1>&2
        echo "'proyect-selector.fish' should 'set -f' at least 'proyects'" 1>&2
        return 1
    end

    if test -z "$type" -o "$type" = "."
        set type "w"
    end

    if ! test "$type" = "s" -o "$type" = "w"
        echo "Unknown type: $type" 1>&2
        echo "s = session" 1>&2
        echo "w = window" 1>&2
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

    if ! type -q $application
        echo "Unknown command: $application" 1>&2
        return 1
    end

    set -f session (tmux display-message -p '#S')

    tmux new-window -t "$session:0" -n "select" "__tmux-selector '$type' '$application'"
end
