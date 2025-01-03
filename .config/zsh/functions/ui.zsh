function ui() {
    if which explorer.exe &>/dev/null; then
        ( nohup explorer.exe . &>/dev/null & )
    else
        ( nohup xdg-open . &>/dev/null & )
    fi
    return 0
}
