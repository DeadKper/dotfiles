if not set -q TMUX; and status is-interactive
    if not tmux has-session -t 'home'
        tmux new-session -d -s 'home'
    end
    tmux attach-session -t 'home'
end
