if not set -q TMUX; and status is-interactive
    set -x TMUX_HOME 'home'
    if not tmux has-session -t "$TMUX_HOME"
        tmux new-session -d -s "$TMUX_HOME" -c "$HOME"
    end
    tmux attach-session -t "$TMUX_HOME" 
end
