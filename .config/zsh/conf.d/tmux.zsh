export TMUX_HOME=home
if [[ -o interactive ]] && which tmux &>/dev/null && ! tmux info &>/dev/null && tmux ls | awk '/^'"${TMUX_HOME}"':/ { if ($NF == "(attached)") { exit 1 }}'; then
    if tmux has-session -t "$TMUX_HOME" &>/dev/null; then
        tmux attach-session -t "$TMUX_HOME" -c "$HOME"
    else
        tmux new-session -s "$TMUX_HOME" -c "$HOME"
    fi
fi
