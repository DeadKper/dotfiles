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
        tmp_path1="${XDG_DATA_HOME:=$HOME/.local/share}/flatpak/exports/bin:$tmp_path1"
    fi
    export PATH="$tmp_path1:$tmp_path2"
    # export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
fi

unset LS_COLOR
unset GREP_COLORS
