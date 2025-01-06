export TMUX_HOME=home

path=("$HOME/.local/scripts" "${XDG_DATA_HOME:=$HOME/.local/share}/bin" "$HOME/.local/bin" "${path[@]}")

if [[ -o interactive ]] && [[ -o login ]] && which tmux &>/dev/null && ! tmux info &>/dev/null && tmux ls 2>/dev/null | awk '/^'"${TMUX_HOME}"':/ { if ($NF == "(attached)") { exit 1 }}'; then
    tmux new-session -s "$TMUX_HOME" -c "$HOME" &>/dev/null || tmux attach-session -t "$TMUX_HOME" -c "$HOME"
fi
