if type -q npm
  set -l NPM_PACKAGES "$XDG_DATA_HOME/npm-packages"

  add_path PATH "$NPM_PACKAGES/bin"
  add_path MANPATH "$NPM_PACKAGES/share/man"
  add_path NODE_PATH "$NPM_PACKAGES/lib/node_modules"

  if not test -f "$HOME/.npmrc"
    echo "prefix = $NPM_PACKAGES" | sed "s,$HOME,~,g" > "$HOME/.npmrc"
  end

  if not test -d "$NPM_PACKAGES"
    mkdir "$NPM_PACKAGES"
  end
end