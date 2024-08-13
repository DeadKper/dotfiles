function sudo --wraps="sudo" --description 'alias sudo=sudo'
    set -f flags '-sE'

    for arg in $argv
        if echo $arg | grep -q '^-'
            if echo $arg | grep '^--' | grep -qE 'preserve‐env'
                set -f flags
            else if echo $arg | grep -qE 'k|K|i'
                set -f flags
            end
        else
            break
        end
    end

    if type distrobox-host-exec &>/dev/null && echo "$(which $argv[1])" | grep -qF "/container/$(basename "$argv[1]")"
        distrobox-host-exec sudo $flags $argv
    else
        command sudo $flags $argv
    end
end
