if [[ -o interactive ]] && command -v starship &>/dev/null; then
    eval "$(starship init zsh)"

    STARSHIP_TRANSIENT_PROMPT="${${PROMPT[@]:2:-1}// prompt / prompt --profile transient }"
    STARSHIP_TRANSIENT_RPROMPT="${${PROMPT[@]:2:-1}// prompt / prompt --profile rtransient }"

    function starship-transient-prompt-precmd {
        # Save transient prompt
        STARSHIP_SAVED_PROMPT="$(eval "${STARSHIP_TRANSIENT_PROMPT}")"
        STARSHIP_SAVED_RPROMPT="$(eval "${STARSHIP_TRANSIENT_RPROMPT}")"

        # Fix ctrl+c behavior
        TRAPINT() { starship-transient-prompt 2>/dev/null; return $(( 128 + $1 )) }
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook precmd starship-transient-prompt-precmd

    function starship-transient-prompt() {
        # Use same directory transient prompt only
        if [[ "$PWD" == "$STARSHIP_SAVED_PROMPT_PWD" ]]; then
            # Use saved transient prompt
            PROMPT="$STARSHIP_SAVED_PROMPT" RPROMPT="$STARSHIP_SAVED_RPROMPT" zle .reset-prompt
        else
            # Save current directory to enable transient prompt next time
            STARSHIP_SAVED_PROMPT_PWD="$PWD"
        fi
    }

    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget zle-line-finish starship-transient-prompt

    function clear-screen() {
        # Save transient prompt before clearing screen
        starship-transient-prompt-precmd
        zle .clear-screen
    }

    zle -N clear-screen
fi
