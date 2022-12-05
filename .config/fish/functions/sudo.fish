function sudo --description 'run fish functions with sudo'
  set -l sudo_flags
  for arg in $argv
    if test -z "$(echo $arg | grep '^-')"
      break
    end
    set sudo_flags $sudo_flags $arg
  end
  set -l commands (echo $argv | sed -r "s/^$sudo_flags ?//g")
  if test -n "$commands" -a -z "$(echo "$commands" | grep -E -- "^su")"
    command sudo $sudo_flags XDG_CONFIG_HOME="$HOME/.config" fish -c "$commands"
  else
    command sudo $argv
  end
end
