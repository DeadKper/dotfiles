readarray() {
  if test "$1" = "-t"; then
    shift
  else
    echo 'only `readarray -t` is supported for now'
    exit 1
  fi
  name="$1"
  shift
  if test -n "$*"; then
    eval "$name=("${(@f)$(printf '%s\n' "$@")}")"
  else
    eval "$name=("${(@f)$(cat)}")"
  fi
}
