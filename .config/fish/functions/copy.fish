function copy --wraps='rsync -ah --info=progress2' --description 'alias copy=rsync -ah --info=progress2'
  rsync -ah --info=progress2 $argv
end
