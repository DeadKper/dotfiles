function krestart --wraps='killall plasmashell && kstart5 plasmashell' --wraps='killall plasmashell && kwin --replace && kstart plasmashell & exit' --description 'alias krestart=killall plasmashell && kwin --replace && kstart plasmashell & exit'
  killall plasmashell
  kwin --replace
  kstart plasmashell
  exit 
end
