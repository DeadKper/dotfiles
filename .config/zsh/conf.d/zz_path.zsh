new_path="$PATH"

if type wslpath &>/dev/null && ! type cmd.exe &>/dev/null; then
  if test -z "${WSL_PATH}"; then
    export WSL_PATH="$(/mnt/c/Windows/system32/cmd.exe /c echo %PATH% 2>/dev/null | xargs -r -d ';' -n 1 wslpath | grep '\S')"
    add_path -a PATH "$WSL_PATH"
  fi
fi

if test -f /run/.containerenv; then
  add_path PATH "$HOME/.local/container:/usr/container"
fi

add_path PATH "$HOME/.local/scripts:$HOME/.local/bin"
