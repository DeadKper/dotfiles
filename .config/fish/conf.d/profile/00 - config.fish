set -x FISH_SOURCED
set -f FISH_RESOURCE

# Config xdg dirs
set -x XDG_CONFIG_HOME ~/.config
set -x XDG_CACHE_HOME ~/.cache
set -x XDG_DATA_HOME ~/.local/share
set -x XDG_STATE_HOME ~/.local/state

set -x --path XDG_DATA_DIRS /usr/local/share /usr/share
if test -d /usr/share/kde-settings/kde-profile/default/share
    set -p XDG_DATA_DIRS /usr/share/kde-settings/kde-profile/default/share
end

set -x --path XDG_CONFIG_DIRS /etc/xdg
if test -d ~/.config/kdedefaults
    set -p XDG_CONFIG_DIRS ~/.config/kdedefaults
end
if test -d /usr/share/kde-settings/kde-profile/default/xdg
    set -a XDG_CONFIG_DIRS /usr/share/kde-settings/kde-profile/default/xdg
end

set -x --path PATH /usr/local/bin /usr/bin /bin

function add-path --no-scope-shadowing
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

    set -x --path $name $$name

    for path in $argv[2..]
        if not contains $path $to_add $$name
            set -a to_add $path
        end
    end

    if count $to_add &> /dev/null
        set $flag $name $to_add
    end
end
