NPM_PACKAGES="${XDG_DATA_HOME:-$HOME/.local/share}/npm-packages"

if test ! -f "$HOME/.npmrc"; then
    echo "prefix = ${NPM_PACKAGES//${~HOME}/~}" > ~/.npmrc
fi

path=("$NPM_PACKAGES/bin" "${path[@]}")
manpath=("$NPM_PACKAGES/share/man" "${manpath[@]}")
export NODE_PATH="$NPM_PACKAGES/lib/node_modules"
if test ! -d "$NPM_PACKAGES"; then
    mkdir -p "$NPM_PACKAGES"
fi

unset NPM_PACKAGES
