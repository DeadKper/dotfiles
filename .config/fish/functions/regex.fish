function regex --argument-names pattern
  set -l exit_status 1
  for i in (seq 2 (count $argv))
    echo $argv[$i] | grep -E -- "$pattern"
    if test "$exit_status" = 1 -a "$status" = 0
      set exit_status 0
    end
  end
  if not isatty stdin
    while read -l line
      echo $line | grep -E -- "$pattern"
      if test "$exit_status" = 1 -a "$status" = 0
        set exit_status 0
      end
    end
  end
  return $exit_status
end