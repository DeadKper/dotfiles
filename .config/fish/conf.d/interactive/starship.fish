set -x STARSHIP_LOG "error"

if type -q starship
    starship init fish | source
end
