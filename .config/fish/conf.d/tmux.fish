if status is-interactive; and not set -q TMUX_LOADED; and type -q tmux; and not set -q TMUX
    set -x TMUX_LOADED
    set TMUX_HOME home

    if tmux info &>/dev/null; and tmux has-session -t "$TMUX_HOME" &>/dev/null; and test -z "$(tmux ls 2>/dev/null | grep -F "$TMUX_HOME:" | grep -vF '(attached)')"
        # tmux detach-client -s "$TMUX_HOME" -a
        return
    else
        if not tmux info &>/dev/null; and tmux has-session -t "$TMUX_HOME" &>/dev/null
            tmux attach-session -t "$TMUX_HOME" -c "$HOME"
        else
            tmux new-session -c "$HOME"
        end
    end
end
