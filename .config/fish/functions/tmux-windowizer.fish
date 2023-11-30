function tmux-windowizer
    tmux neww -d
    sleep 0.1 # Wait for tmux to create window
    tmux selectw -t {end}
    sleep 0.2 # Wait for fish to load
    tmux send-keys 'cd' Enter 'clear' Enter $argv
end
