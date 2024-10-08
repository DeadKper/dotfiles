function sudo --wraps="sudo" --description 'alias sudo=sudo'
    set -f flags --preserve-env=PATH -sE

    for arg in $argv
        if echo -- $arg | grep -q '^-'
            if echo -- $arg | grep -qE 'k|K|i'
                set -f flags
            end
        else
            break
        end
    end

    if type distrobox-host-exec &>/dev/null && echo "$(which $argv[1] 2>/dev/null)" | grep -qF "/container/$(basename "$argv[1]" 2>/dev/null)"
        distrobox-host-exec sudo $flags $argv
    else
        command sudo $flags $argv
    end
end
