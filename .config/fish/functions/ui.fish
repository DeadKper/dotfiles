function ui
    if type -q explorer.exe
        explorer.exe . &
    else
        xdg-open . 1> /dev/null 2> /dev/null &
    end
    return 0
end
