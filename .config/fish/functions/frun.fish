function frun --argument app
  set -l results (flatpak list --columns=name,application | grep -Ei "$app")
  set -l app

  if test (count $results) = 0
    echo "No app with that name found."
    return
  else if test (count $results) = 1
    set app $results
  else
    echo "Select which app to run"
    set -l number
    for i in (seq 1 (count $results))
      echo "  $i) $(echo $results[$i] | sed -r 's/[\t ]+(([a-z0-9\-_]+\.){2,}[^ ]+)//gi')"
    end
    read number
    set app $results[$number]
  end

  flatpak run (echo $app | sed -r 's/.*[\t ]+(([a-z0-9\-_]+\.){2,}[^ ]+)/\1/gi') $argv
end
