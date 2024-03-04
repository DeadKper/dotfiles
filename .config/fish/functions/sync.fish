function sync --description 'alias sync=yadm pull --all --recurse-submodules'
  if yadm submodule status | grep --quiet '^-'
    yadm submodule update --init --recursive
  end
  yadm pull --all --recurse-submodules
  git -C "$XDG_CONFIG_HOME/nvim" checkout main &> /dev/null
  git -C "$XDG_CONFIG_HOME/nvim" pull
end
