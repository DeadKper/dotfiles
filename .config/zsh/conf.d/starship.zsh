if [[ -o interactive ]] && which starship &>/dev/null; then
    eval "$(starship init zsh)"

    TRANSIENT_PROMPT="${PROMPT// prompt / prompt --profile transient }"
    TRANSIENT_RPROMPT="${PROMPT// prompt / prompt --profile rtransient }"
    TRANSIENT_RPROMPT="${TRANSIENT_RPROMPT%%)} | sed -E \"s/([0-9]{2}:){2}[0-9]{2}/\$SAVED_TIME/\")" # Fix transient time

    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget zle-line-init transient-prompt-startup
    add-zle-hook-widget zle-line-finish transient-prompt

    function transient-prompt-startup() { # Fix transient time
        SAVED_TIME="$(date +%H:%M:%S)"
    }

    function transient-prompt() { # Use transient instead of default starship
        PROMPT="$TRANSIENT_PROMPT" RPROMPT="$TRANSIENT_RPROMPT" zle .reset-prompt
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd transient-prompt-precmd

    function transient-prompt-precmd { # Fix ctrl+c behavior
        TRAPINT() { transient-prompt; return $(( 128 + $1 )) }
    }
fi
