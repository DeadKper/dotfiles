function cliptype --argument sleepTime
    test -z "$sleepTime" && set sleepTime 3
    sleep $sleepTime
    if test -z "$WAYLAND_DISPLAY"
        xdotool type "$(xclip -o -selection clipboard)"
    else
        ydotool type "$(wl-paste | sed -e 'y/|\'¿´+}ñ{-°!"&\/()=?¡¨*]Ñ[;:_/`-=[]\\\\;\'\/~!@^&*()_+{}|:"<>?/')"
    end
end
