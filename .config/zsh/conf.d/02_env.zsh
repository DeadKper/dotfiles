typeset -TUx PATH path
path+=(/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin)
path=("$HOME/.local/scripts" "$HOME/.local/bin" "${XDG_DATA_HOME:=$HOME/.local/share}/bin" "${path[@]}")

export EDITOR=nvim
export VISUAL=nvim
which nvim &>/dev/null && export MANPAGER='nvim +Man!'
export YDOTOOL_SOCKET="${XDG_STATE_HOME:=$HOME/.local/state}/ydotool.socket"

export TIMEFMT="
________________________________________
Executed in %*E CPU %P
   usr time %*U
   sys time %*S"

# LS_COLORS — oxocarbon palette (RGB true-color where supported, 256-color fallback in comments)
export LS_COLORS="\
di=38;2;120;169;255:\
ln=38;2;153;218;255:\
ex=38;2;66;190;101:\
fi=38;2;224;224;224:\
pi=38;2;190;149;255:\
so=38;2;190;149;255:\
bd=38;2;255;126;182:\
cd=38;2;255;126;182:\
or=1;38;2;238;83;150:\
mi=1;38;2;238;83;150:\
su=38;2;255;126;182:\
sg=38;2;255;126;182:\
tw=38;2;120;169;255:\
ow=38;2;120;169;255:\
st=38;2;120;169;255"

unset GREP_COLOR
unset GREP_COLORS
