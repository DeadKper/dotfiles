function ls --description 'alias ls=ls'
    if command -q lsd
        command lsd $argv
    else
        command ls $argv
    end
end
