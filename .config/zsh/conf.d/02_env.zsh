typeset -U path PATH
path+=(/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin)
path=("$HOME/.local/scripts" "$HOME/.local/bin" "${XDG_DATA_HOME:=$HOME/.local/share}/bin" "${path[@]}")

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

export EDITOR=nvim
export VISUAL=nvim
which nvim &>/dev/null && export MANPAGER='nvim +Man!'
export YDOTOOL_SOCKET="${XDG_STATE_HOME:=$HOME/.local/state}/ydotool.socket"

export ZSH_AUTOSUGGEST_STRATEGY=(abbreviations $ZSH_AUTOSUGGEST_STRATEGY)

export TIMEFMT="$(cat <<EOF

________________________________________
Executed in %*E CPU %P
   usr time %*U
   sys time %*S
EOF
)"

if which manpath &>/dev/null; then
    unset MANPATH
    export MANPATH="$(find "$ZIM_HOME" -type d -name man | xargs -r -d \\n -I {} echo -n {}:)$(manpath)"
    typeset -U manpath MANPATH
fi

unset LS_COLORS
unset GREP_COLOR
unset GREP_COLORS
