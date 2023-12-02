function tmux-selector --argument type app proyect
    function windowizer --argument session app proyect
        tmux new-window -t "$session" -d -c "$proyect"
        sleep 0.1 # Wait for tmux to create window
        tmux select-window -t "$session"
        sleep 0.2 # Wait for fish to load
        tmux send-keys -t "$session" "$app ." Enter 
    end

    if test -z "$proyect"
        source "$HOME/.config/proyect-selector.fish"
        set -f proyect (printf '%s\n' $proyects | sort | fzf | sed -E "s,^~,$HOME,")
    end

    if test -z "$proyect"
        return 1
    end

    if test "$type" = "s"
        set -f session (basename "$proyect")
        if tmux has-session -t "$session" 2>&1 >/dev/null
            set -f window (tmux list-windows -t "$session" | count)
            if test "$(tmux display-message -p '#S')" != "$session"
                set window (math $window + 1)
            end
            windowizer "$session:$window" "$app" "$proyect"
            return
        end
        tmux new-session -d -s "$session" -c "$proyect" 
        sleep 0.3 # Wait for fish to load
        tmux send-keys -t "$session:" "$app ." Enter
        tmux switch-client -t "$session"
    else
        set -f window (tmux list-windows -t "$session" | count)
        if test -z "$(tmux list-windows | grep -E '^0:')"
            set window (math $window + 1)
        end
        windowizer "$(tmux display-message -p '#S'):$window" "$app" "$proyect"
    end
end
