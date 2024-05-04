if status is-interactive
    # use vi key binds
    fish_vi_key_bindings

    # edit current line in buffer
    bind -M default \cx edit_command_buffer
    bind -M insert \cx edit_command_buffer
    bind -M visual \cx edit_command_buffer

    # move in insert mode
    bind -M insert \ch backward-char
    bind -M insert \cj down-or-search
    bind -M insert \ck up-or-search
    bind -M insert \f forward-char # this is \cl for some reason

    # ctrl + left/right
    bind -M insert \e\[1\;5D backward-bigword
    bind -M insert \e\[1\;5C forward-bigword

    # closest I can get to visual line
    bind -M default -m visual V beginning-of-buffer begin-selection end-of-buffer

    # ctrl + e to accept autosuggestion
    bind -M insert \cE accept-autosuggestion

    # ctrl + delete to kill word
    bind -M insert \e\[3\;5~ kill-word

    # search prefix through history
    bind -M insert \cp history-prefix-search-backward
    bind -M insert \cn history-prefix-search-forward

    # yank to clipboard
    bind -M visual ' y' fish_clipboard_copy

    # fix delete key
    bind -M default -k dc delete-char
    bind -M insert -k dc delete-char
    bind -M visual -k dc kill-selection end-selection
end
