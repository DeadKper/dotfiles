if [[ -o login ]]; then
    export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/zig:$PATH"
fi
