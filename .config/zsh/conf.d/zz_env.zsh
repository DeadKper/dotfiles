export TMUX_HOME=home

path=("$HOME/.local/scripts" "${XDG_DATA_HOME:=$HOME/.local/share}/bin" "$HOME/.local/bin" "${path[@]}")

if [[ -o interactive ]] && which tmux &>/dev/null && ! tmux info &>/dev/null && tmux ls | awk '/^'"${TMUX_HOME}"':/ { if ($NF == "(attached)") { exit 1 }}'; then
    if tmux has-session -t "$TMUX_HOME" &>/dev/null; then
        tmux attach-session -t "$TMUX_HOME" -c "$HOME"
    else
        tmux new-session -s "$TMUX_HOME" -c "$HOME"
    fi
fi
