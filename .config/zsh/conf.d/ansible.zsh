if type ansible &>/dev/null && ! type apl &>/dev/null; then
  local list="$(abbr list)"
  add() {
    name="$1"
    shift
    type "$name" &>/dev/null || alias "$name=$@"
    [[ "$list" = *"\"$name\""* ]] || abbr "$name=$@"
  }

  add apl ansible-playbook
  add apv ansible-playbook --extra-vars
  add apa ansible-playbook asd.yaml -i

  add agl ansible-galaxy
  add agi ansible-galaxy init

  add aed ansible-edit

  add arn ansible-run -m
  add arc ansible-run -m shell -a
  add arx ansible-run -m script -a

  add alg ansible-logs

  add atp ansible-template
fi
