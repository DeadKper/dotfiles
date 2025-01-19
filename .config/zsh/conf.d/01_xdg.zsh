# Config xdg dirs
test -z "${XDG_CONFIG_HOME+1}" && export XDG_CONFIG_HOME=~/.config
test -z "${XDG_CACHE_HOME+1}"  && export XDG_CACHE_HOME=~/.cache
test -z "${XDG_DATA_HOME+1}"   && export XDG_DATA_HOME=~/.local/share
test -z "${XDG_STATE_HOME+1}"  && export XDG_STATE_HOME=~/.local/state

typeset -TUx XDG_DATA_DIRS xdg_data_dirs
xdg_data_dirs+=("/usr/local/share" "/usr/share")
if test -d /usr/share/kde-settings/kde-profile/default/share; then
    xdg_data_dirs=("/usr/share/kde-settings/kde-profile/default/share" "${xdg_data_dirs[@]}")
fi

typeset -TUx XDG_CONFIG_DIRS xdg_config_dirs
xdg_config_dirs+=("/etc/xdg")
if test -d ~/.config/kdedefaults; then
    xdg_config_dirs=("${HOME}/.config/kdedefaults" "${xdg_config_dirs[@]}")
fi
if test -d /usr/share/kde-settings/kde-profile/default/xdg; then
    xdg_config_dirs+=("/usr/share/kde-settings/kde-profile/default/xdg")
fi
