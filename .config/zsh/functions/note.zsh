function note() {
    command -v nvim &>/dev/null || { echo neovim is not installed; return 1 }
    local vault="$HOME/Nextcloud/Apps/Obsidian/Personal/"
    local file="$(find "$vault" -type f -print -quit)"
    if [[ -n "$file" ]]; then
        nvim "$file" +"cd $vault | bd | Dashboard"
    else
        nvim +"cd $vault"
    fi
}
