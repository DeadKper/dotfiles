if [[ -o login ]] && test -z "${ZSH_LOGIN+1}"; then
    export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/zig:$PATH"
fi
