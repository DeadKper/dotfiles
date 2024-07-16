if status is-interactive
    # edit current line in buffer
    bind \cx edit_command_buffer

    # move in insert mode
    bind \ch backward-char
    bind \cj down-or-search
    bind \ck up-or-search
    bind \f forward-char # this is \cl for some reason

    # vim-like work jump
    bind \cB backward-bigword
    bind \cF forward-bigword

    # kill words with alt
    bind \el kill-bigword
    bind \eh backward-kill-bigword

    # ctrl + left/right
    bind \e\[1\;5D backward-bigword
    bind \e\[1\;5C forward-bigword

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
