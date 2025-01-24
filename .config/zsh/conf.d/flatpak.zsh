if which flatpak &>/dev/null; then
    flatpak_ins=(
        "${XDG_DATA_HOME:="$HOME/.local/share"}/flatpak"
        "${(@f)$(G_MESSAGES_DEBUG= GIO_USE_VFS=local flatpak --installations)}"
    )
    xdg_data_dirs=("${flatpak_ins[@]}"/exports/share "${xdg_data_dirs[@]}")
    path=("${flatpak_ins[@]}"/exports/bin "${path[@]}")
    unset flatpak_ins
fi
