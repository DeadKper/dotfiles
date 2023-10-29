function cliptype --argument sleepTime
    if test -z "$sleepTime"
        set sleepTime 3
    end
    xdotool sleep $sleepTime type "$(xclip -o -selection clipboard)"
end
