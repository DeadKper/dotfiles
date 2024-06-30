function visudo --description 'alias visudo EDITOR=nvim command visudo'
    sudo EDITOR="$(which nvim)" command visudo $argv
end
