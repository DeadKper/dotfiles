function view() {
    nvim +'set nofoldenable | set nonumber | map q :qa!<cr>' "$@"
}
