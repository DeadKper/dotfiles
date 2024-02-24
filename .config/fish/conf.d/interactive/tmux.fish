if type -q tmux; and not set -q TMUX; and status is-interactive; and test -e "$HOME/.config/tmux-init-conf.fish"
    source "$HOME/.config/tmux-init-conf.fish"

    if test -n "$tmux_session_home_name"
        set -x TMUX_HOME "$tmux_session_home_name"
    else
        set -x TMUX_HOME 'home'
    end

    if not tmux list-sessions &> /dev/null; and test "$tmux_session_home_create" = "y"
        tmux new-session -s "$TMUX_HOME" -c "$HOME" -d

        set -f cnt (seq (math (count $tmux_window_names)))

        sleep 0.1 # wait for session to be created

        for i in $cnt
            if test "$i" != '1'
                if test -z "$tmux_window_names[$i]"
                    tmux new-window -t "$TMUX_HOME" -s "$tmux_window_names[$i]"
                else
                    tmux new-window -t "$TMUX_HOME"
                end
            else if test -n "$tmux_window_names[$i]"
                tmux rename-window -t "$TMUX_HOME:1" "$tmux_window_names[$i]"
            end
        end

        if test -n "$cnt"
            tmux new-window -t "$TMUX_HOME" -c "$home" -d
        end

        tmux select-window -t "$TMUX_HOME:{end}"
        sleep 0.2 # wait for fish to load

        for i in $cnt
            tmux send-keys -t "$TMUX_HOME:$i" "$tmux_window_cmds[$i]" Enter
        end
    end

    if not tmux info &> /dev/null; and tmux has-session -t "$TMUX_HOME" &> /dev/null; and test "$tmux_session_home_attach" = "y"
        tmux attach-session -t "$TMUX_HOME"
    end
end
