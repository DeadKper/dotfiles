local XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
local NPM_PACKAGES="$XDG_DATA_HOME/npm-packages"

if ! test -f "$HOME/.npmrc"; then
  echo "prefix = $NPM_PACKAGES" | sed "s,$HOME,~,g" >~/.npmrc
fi

if type npm &>/dev/null; then
  if ! test -d "$NPM_PACKAGES"; then
    mkdir "$NPM_PACKAGES"
  fi

  add_path PATH "$NPM_PACKAGES/bin"
  add_path MANPATH "$NPM_PACKAGES/share/man"
  export NODE_PATH="$NPM_PACKAGES/lib/node_modules"
fi
