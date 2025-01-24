if [[ -o interactive ]] && which starship &>/dev/null; then
    eval "$(starship init zsh)"

    TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"
    TRANSIENT_RPROMPT="${PROMPT// prompt / prompt --profile rtransient }"

    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget zle-line-finish transient-prompt

    function transient-prompt() {
        PROMPT="$TRANSIENT_PROMPT" RPROMPT="$TRANSIENT_RPROMPT" zle .reset-prompt
    }

    # autoload -Uz add-zsh-hook
    # add-zsh-hook precmd transient-prompt-precmd
    #
    # function transient-prompt-precmd {
    #     TRAPINT() { transient-prompt; return $(( 128 + $1 )) }
    # }
fi
