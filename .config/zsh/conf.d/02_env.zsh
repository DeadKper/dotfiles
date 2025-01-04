if [[ -o login ]]; then
    export EDITOR=nvim
    export VISUAL=nvim
    which nvim &>/dev/null && export MANPAGER='nvim +Man!'
    export YDOTOOL_SOCKET="${XDG_STATE_HOME:=$HOME/.local/state}/ydotool.socket"

    if which manpath &>/dev/null && test -z "${MANPATH+1}"; then
        export MANPATH="$(manpath)"
        typeset -U path MANPATH
    fi
    typeset -U path PATH

    tmp_path1="$(echo "$PATH" | sed 's/:/\n/g' | grep -vE "^$HOME/" | grep -vE "^(/usr/local/sbin|/usr/local/bin|/usr/sbin|/usr/bin|/sbin|/bin)$" \
        | xargs -d \\n -I {} echo -n {}: | sed 's,:$,:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin,')"
    tmp_path2="$(echo "$PATH" | sed 's/:/\n/g' | grep -v "^$HOME/" | xargs -d \\n -I {} echo -n {}: | sed 's/:$//')"

    if which flatpak &>/dev/null; then
        unset G_MESSAGES_DEBUG
        flatpak_ins=(
            "${XDG_DATA_HOME:-"$HOME/.local/share"}/flatpak"
            "${(@f)$(GIO_USE_VFS=local flatpak --installations)}"
        )
        tmp_path1="$(printf '%s/exports/bin:' "${flatpak_ins[@]}")$tmp_path1"

        new_dirs=$(
            (
                printf '%s\n' "${flatpak_ins[@]}"
            ) | (
                new_dirs=
                while read -r install_path
                do
                    share_path=$install_path/exports/share
                    case ":$XDG_DATA_DIRS:" in
                        (*":$share_path:"*) :;;
                        (*":$share_path/:"*) :;;
                        (*) new_dirs=${new_dirs:+${new_dirs}:}$share_path;;
                    esac
                done
                echo "$new_dirs"
            )
        )

        export XDG_DATA_DIRS="${new_dirs:+${new_dirs}:}${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

        unset new_dirs
        unset flatpak_ins
    fi

    export PATH="$tmp_path1:$tmp_path2"
    unset tmp_path1
    unset tmp_path2
fi

unset LS_COLORS
unset GREP_COLOR
unset GREP_COLORS

ZSH_AUTOSUGGEST_STRATEGY=(abbreviations $ZSH_AUTOSUGGEST_STRATEGY)
