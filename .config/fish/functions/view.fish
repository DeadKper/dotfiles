function view
    nvim +'set noma | set nofoldenable | set nonumber | map q :qa!<cr>' $argv
end
