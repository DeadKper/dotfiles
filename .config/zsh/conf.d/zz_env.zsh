export TMUX_HOME=home

path=("$HOME/.local/scripts" "${XDG_DATA_HOME:=$HOME/.local/share}/bin" "$HOME/.local/bin" "${path[@]}")

if [[ -o interactive ]] && which tmux &>/dev/null && ! tmux info | grep -q '\S' && tmux ls 2>/dev/null | awk '/^'"${TMUX_HOME}"':/ { if ($NF == "(attached)") { exit 1 }}' &>/dev/null; then
    tmux new-session -s "$TMUX_HOME" -c "$HOME" &>/dev/null || tmux attach-session -t "$TMUX_HOME" -c "$HOME"
fi
