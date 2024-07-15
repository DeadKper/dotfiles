function sudo --wraps="sudo" --description 'alias sudo=sudo'
    if command -q doas; and not command -q sudo
        set -f sudo doas
    else
        set -f sudo sudo
    end
    set -f flags
    set -f count 0
    for arg in $argv
        if test "$arg" = --
            set -e argv[$count]
            break
        else if echo -- "$arg" | rg -q '^-'
            set count (math "$count+1")
            set -a flags "$arg"
            set -e argv[$count]
        else
            break
        end
    end
    if test "$USER" != root
        if echo "$argv" | rg -q '\S'
            command $sudo VISUAL="$VISUAL" EDITOR="$EDITOR" XDG_DATA_HOME="$XDG_DATA_HOME" XDG_CONFIG_HOME="$XDG_CONFIG_HOME" TMUX="$TMUX" PATH="$PATH" $flags fish -c "$(printf '\'%s\' ' $argv)"
        else
            command $sudo $flags
        end
    else
        command $sudo $flags $argv
    end
end
