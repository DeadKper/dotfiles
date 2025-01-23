if [[ -o interactive ]]; then
    eval "$(starship init zsh)"

    TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"
    TRANSIENT_RPROMPT="${PROMPT// prompt / prompt --profile rtransient }"

    zle -N send-break transient-prompt-send-break
    function transient-prompt-send-break {
        transient-prompt-zle-line-finish
        zle .send-break
    }

    zle -N zle-line-finish transient-prompt-zle-line-finish
    function transient-prompt-zle-line-finish {
        PROMPT="$TRANSIENT_PROMPT" RPROMPT="$TRANSIENT_RPROMPT" zle reset-prompt
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd transient-prompt-precmd

    function transient-prompt-precmd {
        TRAPINT() { zle && transient-prompt-zle-line-finish; return $(( 128 + $1 )) }
    }
fi
