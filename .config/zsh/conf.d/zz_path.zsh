new_path="$PATH"

if type wslpath &>/dev/null && ! type cmd.exe &>/dev/null; then
  if test -z "${WSL_PATH}"; then
    WSL_PATH="$(/mnt/c/Windows/system32/cmd.exe /c echo %PATH% 2>/dev/null | xargs -r -d ';' -n 1 wslpath | grep '\S')"
    while IFS=: read -r path; do
      if [[ ! ":$new_path:" = *":$path:"* ]] ; then
        new_path="$new_path:$path"
      fi
    done <<< "$WSL_PATH"
  fi
fi

if test -f /run/.containerenv; then
  while IFS=: read -r path; do
    if [[ ! ":$new_path:" = *":$path:"* ]] ; then
      new_path="$new_path:$path"
    fi
  done <<< "$HOME/.local/container:/usr/container"
fi

while IFS=: read -r path; do
  if [[ ! ":$new_path:" = *":$path:"* ]] ; then
    new_path="$path:$new_path"
  fi
done <<< "$HOME/.local/scripts:$HOME/.local/bin"

export PATH="$new_path"
