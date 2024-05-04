if type -q flatpak
    set -l installations $XDG_DATA_HOME/flatpak
    begin
        set -le G_MESSAGES_DEBUG
        set -lx GIO_USE_VFS local
        set installations $installations (flatpak --installations)
    end

    set -x --path XDG_DATA_DIRS $XDG_DATA_DIRS
    add-path XDG_DATA_DIRS {$installations}/exports/share
end
