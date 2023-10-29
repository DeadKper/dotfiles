function vcode --wraps=cd --description 'alias vcode=j $argv; code .; exit'
  if test -n "$argv"
    j $argv
  end
  code .
end
