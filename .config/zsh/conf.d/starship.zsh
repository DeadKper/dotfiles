if [[ -o interactive ]] && which starship &>/dev/null; then
    eval "$(starship init zsh)"

    TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"
    TRANSIENT_RPROMPT="${PROMPT// prompt / prompt --profile rtransient }"

    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget zle-line-init transient-prompt-startup
    add-zle-hook-widget zle-line-finish transient-prompt

    function transient-prompt-startup() { # Save transient prompt format
        SAVED_PROMPT="$(eval "printf '%s' '${TRANSIENT_PROMPT}'")"
        SAVED_RPROMPT="$(eval "printf '%s' '${TRANSIENT_RPROMPT}'")"
    }

    function transient-prompt() { # Use saved transient prompt
        PROMPT="$SAVED_PROMPT" RPROMPT="$SAVED_RPROMPT" zle .reset-prompt
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd transient-prompt-precmd

    function transient-prompt-precmd { # Fix ctrl+c behavior
        TRAPINT() { transient-prompt; return $(( 128 + $1 )) }
    }
fi
