function copy --wraps='rsync -ahAHSX --info=progress2' --description 'alias copy=rsync -ahAHSX --info=progress2'
    if test (count $argv) = 2 -a -d "$argv[1]" -a \( ! -e "$argv[2]" -o -d "$argv[2]" \)
        if test ! -e "$argv[2]"
            cp -auxv $argv
        end
        if count $argv/{.*,*} >/dev/null
            rsync -ahAHSX --info=progress2 $argv[1]/{.*,*} "$argv[2]"
        end
    else
        rsync -ahAHSX --info=progress2 $argv
    end
end
