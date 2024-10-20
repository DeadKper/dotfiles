if status is-interactive
    # edit current line in buffer
    bind \ex edit_command_buffer

    # ctrl + left/right
    bind \e\[1\;3D backward-bigword
    bind \e\[1\;3C forward-bigword

    # reverse i-search
    bind \cR history-pager

    # ctrl + e to accept autosuggestion
    bind \cE accept-autosuggestion

    # ctrl + delete to kill word
    bind \e\[3\;5~ kill-word

    # search prefix through history
    bind \cp history-prefix-search-backward
    bind \cn history-prefix-search-forward

    # fix delete key
    bind -k dc delete-char
end
