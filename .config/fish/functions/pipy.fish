function pipy --argument cmd
  set pypiUrl https://pypi.org/simple/
  set cacheFile $HOME/.cache/pipy

  if test ! -f $cacheFile
    set update true
  else if test $cmd = "update"
    set update true
  else if test (date -d (head $cacheFile -n 1 | sed -rn "s/.*\"(.*)\"/\1/pi") +%s) -lt (date +%s)
    set update true
  end

  if test "$update" = true
    echo "Updating pipy cache... \n"
    echo "expiration: \"$(date -d @(math (date +%s) + 86400 x 3))\"" > $cacheFile
    echo "" >> $cacheFile
    curl $pypiUrl | tail -n +8 | head -n -2 | sed -rn "s/.*\"\/simple\/(.*\/)\".*>(.*)<.*/name:\"\2\"\n - url:\"https:\/\/pypi.org\/project\/\1\"/pi" >> $cacheFile
  end

  switch "$cmd"
  case -h --help help
    echo "Usage: pipy search <application>   Search package in pipy"
    echo "       pipy update                 Update pipy cache"
    echo "       pipy help                   Print help"
  case search
    set found (cat $cacheFile | sed -rn "s/name:\"(.*)\".*/\1/pi")
    for i in (seq 2 (count $argv))
      set found (echo $found | string split " " | grep -iE $argv[$i])
    end
    if test -n "$found"
      for i in (seq 1 (count $found))
        echo $found[$i]
      end
    else
      echo "Nothing found..."
      return 1
    end
  case update
    return 0
  case '*'
    echo "Use \"pipy help\" to print help"
  end
end