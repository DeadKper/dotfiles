function dnf --wraps dnf
    command dnf $argv 2> ~/.cache/dnf-err
    set -l stat $status
    if cat ~/.cache/dnf-err | grep -F 'Error: This command has to be run with superuser privileges' &> /dev/null
        command sudo dnf $argv
    else
        cat ~/.cache/dnf-err
        rm ~/.cache/dnf-err
        return $stat
    end
end
