if not set -q FISH_INIT_CONFIG; and count ~/.config/fish/conf.d/profile/*.fish &>/dev/null
    set -x FISH_INIT_CONFIG

    # Config xdg dirs
    set -x XDG_CONFIG_HOME ~/.config
    set -x XDG_CACHE_HOME ~/.cache
    set -x XDG_DATA_HOME ~/.local/share
    set -x XDG_STATE_HOME ~/.local/state

    set -x --path XDG_DATA_DIRS /usr/local/share /usr/share
    if test -d /usr/share/kde-settings/kde-profile/default/share
        set -p XDG_DATA_DIRS /usr/share/kde-settings/kde-profile/default/share
    end
    set -p XDG_DATA_DIRS "$XDG_DATA_HOME"

    set -x --path XDG_CONFIG_DIRS /etc/xdg
    if test -d ~/.config/kdedefaults
        set -p XDG_CONFIG_DIRS ~/.config/kdedefaults
    end
    if test -d /usr/share/kde-settings/kde-profile/default/xdg
        set -a XDG_CONFIG_DIRS /usr/share/kde-settings/kde-profile/default/xdg
    end

    set -x --path PATH $PATH

    for src in ~/.config/fish/conf.d/profile/*.fish
        source "$src"
    end

    if test -d ~/.local/bin
        add-path PATH ~/.local/bin
    end

    if test -d ~/.local/scripts
        add-path PATH ~/.local/scripts
    end

    add-path -a PATH /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

    set -e src
end
