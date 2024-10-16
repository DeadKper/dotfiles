add_path() {
  if test "$1" = "-p" -o "$1" = "-a"; then
    flag=$1
    shift
  fi

  name=$1
  shift

  local env_path="$(eval "echo \$$name")"

  if test -z "$env_path"; then
    env_path="$(printf '%s:' "$@" | sed -E 's/^:|:$//g;s/:+/:/g')"
  else
    while read -r new_path; do
      if ! grep -qF ":$new_path:" <<< ":$env_path:"; then
        if test "$flag" = "-a"; then
          env_path="$env_path:$new_path"
        else
          env_path="$new_path:$env_path"
        fi
      fi
    done < <(printf '%s:' "$@" | sed -E 's/:/\n/g' | grep '\S')
  fi

  eval "export $name='$env_path'"
}
