function add-path --no-scope-shadowing
    set -l flag (contains -i -- -p $argv; or contains -i -- -a $argv)
    if test -n "$flag"
        set -l tmp $argv[$flag]
        set -e argv[$flag]
        set flag $tmp
    else
        set flag -p
    end

    set -l name $argv[1]
    set -l to_add

    for path in $argv[2..]
        if not contains "$path" $to_add $$name
            set -a to_add $path
        end
    end

    if count $to_add &>/dev/null
        set $flag $name $to_add
    end
end
