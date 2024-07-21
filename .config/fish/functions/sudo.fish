function sudo --wraps="sudo" --description 'alias sudo=sudo'
    set -f env y

    for arg in $argv
        if echo $arg | grep -q '^-'
            if echo $arg | grep '^--' | grep -qE 'preserve‐env'
                set -f env n
            else if echo $arg | grep -qE 'k|K|i'
                set -f env n
            end
        else
            break
        end
    end

    if test "$env" = y
        command sudo -sE $argv
    else
        command sudo $argv
    end
end
