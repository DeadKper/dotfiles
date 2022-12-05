function vcode --wraps=cd --description 'alias vcode=cd $argv; code .; exit'
  if test -n "$argv"
    cd $argv
  end
  code .
  exit
end
