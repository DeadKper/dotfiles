function ping --wraps=ping --description 'alias ping=ping'
    if type -q wsl.exe
        ping.exe $argv
    else
        command ping $argv
    end
end
