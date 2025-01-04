if [[ -o login ]]; then
    NPM_PACKAGES="${XDG_DATA_HOME:-$HOME/.local/share}/npm-packages"

    if test ! -f "$HOME/.npmrc"; then
        echo "prefix = $NPM_PACKAGES" | sed "s,$HOME,~,g" >~/.npmrc
    fi

    export PATH="$NPM_PACKAGES/bin:$PATH"
    export MANPATH="$NPM_PACKAGES/share/man:$MANPATH"
    export NODE_PATH="$NPM_PACKAGES/lib/node_modules"
    if test ! -d "$NPM_PACKAGES"; then
        mkdir -p "$NPM_PACKAGES"
    fi

    unset NPM_PACKAGES
fi
