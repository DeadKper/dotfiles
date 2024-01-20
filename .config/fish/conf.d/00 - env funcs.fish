function add_path --no-scope-shadowing
    set -l flag (contains -i -- -p $argv; or contains -i -- -a $argv)
    if test -n "$flag"
        set -l tmp $argv[$flag]
        set -e argv[$flag]
        set flag $tmp
    else
        set flag '-p'
    end

    set -l name $argv[1]
    set -l to_add

    for path in (printf '%s\n' $argv[2..] | sed -r 's/:/\n/')
        if echo $path | grep -vE -- '^-' &> /dev/null; and not contains $path $$name $to_add
            set -a to_add $path
        end
    end

    if count $to_add &> /dev/null
        set $flag $name $to_add
    end
end

function github_download --argument-names ORG REPO FILE TYPE OUTPUT
    set -l url_type
    if test $TYPE = zip
        set url_type zipball_url
    else if test $TYPE = tar
        set url_type tarball_url
    else
        set url_type browser_download_url
    end

    set -l url (curl -s https://api.github.com/repos/$ORG/$REPO/releases/latest | \
		sed -nr 's/.*"'$url_type'": "([^"]+'$FILE'[^"]+)".*/\1/pi')

    set -l dir "$PWD"

    if test -z "$OUTPUT"
        cd ~/Downloads
        wget --content-disposition --continue "$url"
    else if test -d "$OUTPUT"
        cd "$OUTPUT"
        wget --content-disposition --continue "$url"
    else
        wget --output-document="$OUTPUT" --continue "$url"
    end

    cd "$dir"
end

# ShutdownConfirm ShutdownType ShutdownMode

# ShutdownConfirm can take the following values:

# -1: default
#  0: no
#  1: yes

# ShutdownType can take the following values:

# -1: default
#  0: none (log out)
#  1: reboot
#  2: halt (shutdown)
#  3: logout (same as 0? no idea…)

# and finally, ShutdownMode can be:

# -1: default
#  0: schedule
#  1: try now
#  2: force now
#  3: interactive

function shutdown
    if test -z "$argv"
        if not test (qdbus org.kde.ksmserver /KSMServer logout 0 2 1 &> /dev/null)
            sudo command shutdown now
        end
    else
        command shutdown $argv
    end
end

function reboot
    if test -z "$argv"
        if not test (qdbus org.kde.ksmserver /KSMServer logout 0 1 2 &> /dev/null)
            sudo shutdown -r now
        end
    else
        command reboot $argv
    end
end

function logout
    if not test (qdbus org.kde.ksmserver /KSMServer logout 0 0 2 &> /dev/null)
        pkill -U $USER
    end
end
