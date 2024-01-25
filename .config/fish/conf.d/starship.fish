if status is-interactive
  set -x STARSHIP_LOG "error"
  starship init fish | source
end
