function __tmux-selector-windowizer --argument session app proyect
    tmux new-window -t "$session" -d -c "$proyect"
    sleep 0.1 # Wait for tmux to create window
    tmux select-window -t "$session"
    sleep 0.2 # Wait for fish to load
    tmux send-keys -t "$session" "$app ." Enter 
end
