set -x fish_greeting
set -x EDITOR nvim
set -x VISUAL nvim
set -x YDOTOOL_SOCKET "$HOME/.local/state/ydotool.socket"

if type -q manpath; and not set -q MANPATH
    set -x --path MANPATH $(manpath)
end
