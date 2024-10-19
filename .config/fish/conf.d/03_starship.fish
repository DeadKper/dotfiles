if status is-interactive; and type -q starship
    test -d "$HOME/.local/bin" || mkdir -p "$HOME/.local/bin"
    type -q starship || curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin/ -y

    set -x STARSHIP_LOG error
    starship init fish | source
    function starship_transient_prompt_func
        starship module character
    end
    function starship_transient_rprompt_func
        starship module time
    end
    enable_transience
end
