function cdf
    if test "$(count $argv)" = 0
        set -f dir (fd -t d . . | fzf)
    else if test "$(count $argv)" = 1
        set -f dir (fd -t d "$argv[1]" . | fzf)
    else
        set -f dir (fd -t d $argv | fzf)
    end

    if test -n "$dir"
        cd "$dir"
    end
end
