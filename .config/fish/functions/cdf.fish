function cdf
    if test "$(count $argv)" = 0
        set -f dir (fd -t d . . | sk)
    else if test "$(count $argv)" = 1
        set -f dir (fd -t d "$argv[1]" . | sk)
    else
        set -f dir (fd -t d $argv | sk)
    end

    if test -n "$dir"
        cd "$dir"
    end
end
