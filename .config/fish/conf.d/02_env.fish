set -x fish_greeting
set -x EDITOR nvim
set -x VISUAL nvim
set -x YDOTOOL_SOCKET "$HOME/.local/run/ydotool"

if type -q setxkbmap; and test -z "$WAYLAND_DISPLAY"
    set -x XKB_DEFAULT_LAYOUT (setxkbmap -query | grep layout | sed -r "s/^layout:\t* *(.*)/\1/g")
    set -x XKB_DEFAULT_VARIANT (setxkbmap -query | grep variant | sed -r "s/^variant:\t* *(.*)/\1/g")
end

if type -q manpath; and not set -q MANPATH
    set -x --path MANPATH $(manpath)
end
