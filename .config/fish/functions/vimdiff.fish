function vimdiff
    if test (count $argv) != 2
        echo vimdiff requires 2 files to compare >&2
        return 1
    end
    nvim +'vsplit | bnext | windo diffthis | windo set noma | windo set nofoldenable' $argv
end
