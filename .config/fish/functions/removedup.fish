function removedup
    if not count $argv >/dev/null
        read --null --list --delimiter=\n argv
    end
    set -l list
    printf '%s\n' $argv | while read line
        if not printf '%s\n' $list | rg -i -- "$line" &>/dev/null
            set -a list $line
            echo $line
        end
    end
end
