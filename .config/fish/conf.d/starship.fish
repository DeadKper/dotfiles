if status is-interactive; and type -q starship
  set -x STARSHIP_LOG "error"
  starship init fish | source
end
