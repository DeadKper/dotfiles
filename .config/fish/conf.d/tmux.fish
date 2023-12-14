if not set -q TMUX; and status is-interactive
    set -x TMUX_HOME 'home'
    
    if not tmux has-session -t "$TMUX_HOME" &> /dev/null
        set -f __init_tmux 1

        tmux new-session -s "$TMUX_HOME" -c "$HOME" -d
        sleep 0.1
    end

    if test "$__init_tmux" = '1'
        source "$HOME/.config/tmux-init-conf.fish"

        set -f cnt (seq (math (count $tmux_sessions_names)))
        echo $cnt

        for i in $cnt
            if test "$i" != '1'
                if test -z "$tmux_sessions_names[$i]"
                    tmux new-window -t "$TMUX_HOME" -s "$tmux_sessions_names[$i]"
                else
                    tmux new-window -t "$TMUX_HOME"
                end
            else if test -n "$tmux_sessions_names[$i]"
                tmux rename-window -t "$TMUX_HOME:1" "$tmux_sessions_names[$i]"
            end
        end

        if test -n "$cnt"
            tmux new-window -t "$TMUX_HOME" -c "$home" -d
        end

        tmux select-window -t "$TMUX_HOME:{end}"

        for i in $cnt
            tmux send-keys -t "$TMUX_HOME:$i" "$tmux_sessions_cmds[$i]" Enter
        end
    end

    if not tmux info &> /dev/null
        tmux attach-session -t "$TMUX_HOME"
    end
end
