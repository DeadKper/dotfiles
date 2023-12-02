function __tmux-selector --argument type app tmux_win
    source "$HOME/.config/proyect-selector.fish"

    set -f proyect (printf '%s\n' $proyects | sort | fzf | sed -E "s,^~,$HOME,")

    tmux select-window -t "$tmux_win"

    if test -z "$proyect"
        return 1
    end

    cd "$proyect"

    if test "$type" = "s"
        set -f session (basename "$proyect")
        if tmux has-session -t "$session" 2>&1 >/dev/null
            set -f window (tmux list-windows -t "$session" | count)
            if ! echo "$tmux_win" | grep "$session" 2>&1 >/dev/null
                set window (math $window + 1)
            end
            __tmux-selector-windowizer "$session:$window" "$app" "$proyect"
            return
        end
        tmux new-session -d -s "$session" -c "$proyect" 
        sleep 0.3 # Wait for fish to load
        tmux send-keys -t "$session:" "$app ." Enter
        tmux switch-client -t "$session"
    else
        __tmux-selector-windowizer "$(tmux display-message -p '#S'):$(tmux list-windows | count)" "$app" "$proyect"
    end
end
