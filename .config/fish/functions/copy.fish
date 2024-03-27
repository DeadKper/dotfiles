function copy --wraps='rsync -ahAHSX --info=progress2' --description 'alias copy=rsync -ahAHSX --info=progress2'
    rsync -ahAHSX --info=progress2 $argv
end
