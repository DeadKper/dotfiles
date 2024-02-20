function gclones
  for i in $argv
    git clone $i
  end
end