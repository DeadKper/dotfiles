function visudo --wraps='sudo visudo' --description 'alias visudo=\'sudo visudo\''
    sudo visudo $argv
end
