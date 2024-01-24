if type -q npm
  set -l NPM_PACKAGES "$XDG_DATA_HOME/npm-packages"

  fish_add_path "$NPM_PACKAGES/bin"
  set -x --path MANPATH $MANPATH
  add_to_path MANPATH "$NPM_PACKAGES/share/man"
  set -x NODE_PATH "$NPM_PACKAGES/lib/node_modules"

  if not test -f "$HOME/.npmrc"
    echo "prefix = $NPM_PACKAGES" | sed "s,$HOME,~,g" > "$HOME/.npmrc"
  end

  if not test -d "$NPM_PACKAGES"
    mkdir "$NPM_PACKAGES"
  end
end
