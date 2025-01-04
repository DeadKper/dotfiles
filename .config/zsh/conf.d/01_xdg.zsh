if [[ -o login ]]; then
    # Config xdg dirs
    test -z "${XDG_CONFIG_HOME+1}" && export XDG_CONFIG_HOME=~/.config
    test -z "${XDG_CACHE_HOME+1}"  && export XDG_CACHE_HOME=~/.cache
    test -z "${XDG_DATA_HOME+1}"   && export XDG_DATA_HOME=~/.local/share
    test -z "${XDG_STATE_HOME+1}"  && export XDG_STATE_HOME=~/.local/state

    if test -z "${XDG_STATE_HOME+1}"; then
        export XDG_DATA_DIRS="/usr/local/share:/usr/share"
        if test -d /usr/share/kde-settings/kde-profile/default/share; then
            export XDG_DATA_DIRS="/usr/share/kde-settings/kde-profile/default/share:${XDG_DATA_DIRS}"
        fi
    fi
    typeset -U path XDG_DATA_DIRS

    if test -z "${XDG_CONFIG_DIRS+1}"; then
        export XDG_CONFIG_DIRS="/etc/xdg"
        if test -d ~/.config/kdedefaults; then
            export XDG_CONFIG_DIRS="${HOME}/.config/kdedefaults:${XDG_CONFIG_DIRS}"
        fi
        if test -d /usr/share/kde-settings/kde-profile/default/xdg; then
            export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS}:/usr/share/kde-settings/kde-profile/default/xdg"
        fi
    fi
    typeset -U path XDG_CONFIG_DIRS
fi
