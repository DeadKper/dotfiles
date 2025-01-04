if [[ -o login ]]; then
    export PATH="$HOME/.local/scripts:${XDG_DATA_HOME:=$HOME/.local/share}/bin:$HOME/.local/bin:$PATH"
fi
