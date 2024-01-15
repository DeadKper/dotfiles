function cdf
    if test "$(count $argv)" = 0
        cd (fd -t d . . | sk)
    else if test "$(count $argv)" = 1
        cd (fd -t d "$argv[1]" . | sk)
    else
        cd (fd -t d $argv | sk)
    end
end
