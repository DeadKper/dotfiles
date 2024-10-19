if status is-interactive
    # edit current line in buffer
    bind \cx edit_command_buffer

    # move in insert mode
    bind \ch backward-char
    bind \cj down-or-search
    bind \ck up-or-search
    bind \f forward-char # this is \cl for some reason

    # word jumpinp
    bind \cB backward-word
    bind \eb backward-bigword
    bind \cF forward-word
    bind \ef forward-bigword

    # kill words with alt
    bind \el kill-word
    bind \eh backward-kill-word
    bind \eL kill-bigword
    bind \eH backward-kill-bigword

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

    if type -q fzf
        fzf --fish | source
    end
end
