function gitc --wraps='git add -A; git commit -m ' --description 'alias gitc=git add -A; git commit -m '
  git add -A; git commit -m $argv
end
