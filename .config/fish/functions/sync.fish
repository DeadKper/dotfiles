function sync --description 'alias sync=yadm pull --all --recurse-submodules'
  if git submodule status | grep --quiet '^-'
    yadm submodule update --init --recursive
  end
  yadm pull --all --recurse-submodules
end
