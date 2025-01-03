if [[ -o login ]] && test -z "${ZSH_LOGIN+1}"; then
    export PATH="$HOME/.local/scripts:$HOME/.local/bin:$PATH"
fi
