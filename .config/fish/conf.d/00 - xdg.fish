if test -z "$XDG_CONFIG_HOME"
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
end
