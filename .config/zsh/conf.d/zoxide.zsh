if [[ -o interactive ]] && which zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi
