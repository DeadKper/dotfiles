# remap prefix from 'C-b' to 'C-a'
set -g prefix C-a
bind C-a send-prefix
unbind C-b

# reset to defaults and reload config
bind R run "#{SRC}/reset; exit 0" \; source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."

# general
bind    C-w kill-window
bind    C-x kill-pane \; refresh-client -S
bind    C-c new-window -c "#{session_path}" \; refresh-client -S
bind    c   new-window \; refresh-client -S
bind    C   command-prompt -p "(new-session)" "new-session -A -s '%%' -c '#{pane_current_path}'" \; refresh-client -S
bind    \   command-prompt -p "(rename-session)" -I "#{session_name}" "rename-session '%%'" \; refresh-client -S
bind -n M-q confirm -p 'Kill this tmux session? (y/n)' kill-session
bind -n F11 resize-pane -Z

# windows
bind    p   previous-window   \; refresh-client -S
bind    n   next-window       \; refresh-client -S
bind -r C-p previous-window   \; refresh-client -S
bind -r C-n next-window       \; refresh-client -S
bind -r P   swap-window -t -1 \; select-window -t -1
bind -r N   swap-window -t +1 \; select-window -t +1

bind C-o last-window

bind 1 select-window -t 1  \; refresh-client -S
bind 2 select-window -t 2  \; refresh-client -S
bind 3 select-window -t 3  \; refresh-client -S
bind 4 select-window -t 4  \; refresh-client -S
bind 5 select-window -t 5  \; refresh-client -S
bind 6 select-window -t 6  \; refresh-client -S
bind 7 select-window -t 7  \; refresh-client -S
bind 8 select-window -t 8  \; refresh-client -S
bind 9 select-window -t 9  \; refresh-client -S
bind 0 select-window -t 10 \; refresh-client -S

# panes
bind -r H   resize-pane -L 5
bind -r J   resize-pane -D 2
bind -r K   resize-pane -U 2
bind -r L   resize-pane -R 5
bind -r C-h select-pane -L
bind -r C-j select-pane -D
bind -r C-k select-pane -U
bind -r C-l select-pane -R

bind S setw synchronize-panes

# copy-mode
bind -T copy-mode-vi v      send -X begin-selection
bind -T copy-mode-vi C-v    send -X begin-selection \; send -X rectangle-toggle
bind -T copy-mode-vi Escape send -X clear-selection
bind -T copy-mode-vi C-c    send -X cancel
bind -T copy-mode-vi C-y    send -X copy-pipe
bind v                      copy-mode
bind C-u                    copy-mode \; send -X halfpage-up
bind C-b                    copy-mode \; send -X page-up
bind C-y                    copy-mode \; send -X scroll-up

# popup
bind C-Space run "tmux display-popup -xC -yC -w90% -h90% -E '#{SRC}/popup-toggle' || exit 0"

bind -T popup C-Space detach
bind -T popup M-v     copy-mode
bind -T popup M-[     copy-mode
bind -T popup M-q     confirm -p 'Kill this tmux session? (y/n)' { kill-session ; detach }
