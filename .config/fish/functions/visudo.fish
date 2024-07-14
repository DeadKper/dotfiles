function visudo --wraps='sudo sudoedit' --description 'alias visudo=\'sudo EDITOR="$(which nvim)" visudo\''
    sudo EDITOR="$(which nvim)" visudo $argv
end
