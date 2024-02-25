# use vi key binds
fish_vi_key_bindings

# edit current line in buffer
bind -M default \cx edit_command_buffer
bind -M insert \cx edit_command_buffer
bind -M visual \cx edit_command_buffer

# ctrl + left/right
bind -M insert \e\[1\;5D backward-bigword
bind -M insert \e\[1\;5C forward-bigword

# closest I can get to visual line
bind -M default -m visual V beginning-of-buffer begin-selection end-of-buffer

# ctrl + l to accept autosuggestion
bind -M insert \cl accept-autosuggestion

# search prefix through history
bind -M insert \cp history-prefix-search-backward
bind -M insert \cn history-prefix-search-forward

# yank to clipboard
bind -M visual ' y' fish_clipboard_copy

# fix delete key
bind -M insert -k dc backward-delete-char
bind -M default -k dc backward-delete-char
bind -M visual -m default -k dc kill-selection end-selection
