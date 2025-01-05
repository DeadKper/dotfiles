if [[ -o login ]]; then
    path=("${XDG_DATA_HOME:-$HOME/.local/share}/zig" "${path[@]}")
fi
