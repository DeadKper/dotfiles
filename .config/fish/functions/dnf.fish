function dnf --wraps dnf
    command dnf $argv 2>| read -d '\n' -a output
    if echo $output | grep -F 'Error: This command has to be run with superuser privileges' &> /dev/null
        command sudo dnf $argv
    else
        printf '%s\n' $output
    end
end
