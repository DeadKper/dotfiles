function note() {
    command -v nvim &>/dev/null || { echo neovim is not installed; return 1 }
    local vault="$HOME/Nextcloud/Apps/Obsidian/Personal/"

    nvim "$vault" +'cd %:h | lua vim.defer_fn(function() vim.cmd("Lazy load obsidian.nvim") vim.cmd("set ma") end, 50)'
}
