function sudo --wraps="sudo" --description 'alias sudo=sudo'
    if command -q doas; and not command -q sudo
        set -f sudo doas
    else
        set -f sudo sudo
    end
    command $sudo VISUAL="$VISUAL" EDITOR="$EDITOR" XDG_DATA_HOME="$XDG_DATA_HOME" XDG_CONFIG_HOME="$XDG_CONFIG_HOME" TMUX="$TMUX" fish -c "$(printf '\'%s\' ' $argv)"
end
