if not set -q FISH_SOURCED
    set -x FISH_SOURCED

    # Create function to add to any path var easily
    function add_to_path --no-scope-shadowing
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

        for path in $argv[2..]
            if not contains $path $to_add $$name
                set -a to_add $path
            end
        end

        if count $to_add &> /dev/null
            set $flag $name $to_add
        end
    end

    # Config xdg dirs
    set -x XDG_CONFIG_HOME ~/.config
    set -x XDG_CACHE_HOME ~/.cache
    set -x XDG_DATA_HOME ~/.local/share
    set -x XDG_STATE_HOME ~/.local/state

    set -x --path XDG_DATA_DIRS /usr/local/share /usr/share
    if test -d /usr/share/kde-settings/kde-profile/default/share
        add_to_path XDG_DATA_DIRS /usr/share/kde-settings/kde-profile/default/share
    end

    set -x --path XDG_CONFIG_DIRS /etc/xdg
    if test -d ~/.config/kdedefaults
        add_to_path XDG_CONFIG_DIRS ~/.config/kdedefaults
    end
    if test -d /usr/share/kde-settings/kde-profile/default/xdg
        add_to_path -a XDG_CONFIG_DIRS /usr/share/kde-settings/kde-profile/default/xdg
    end

    # Function to reapply changes to profile dir
    if count ~/.config/fish/profile/*.fish &> /dev/null
        set -l src

        for src in ~/.config/fish/profile/*.fish
            source "$src"
        end
    end
end
