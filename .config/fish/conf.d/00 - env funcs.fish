# Add path functions
function parse_path --no-scope-shadowing --argument-names name
  if not test (echo $$name | grep ':')
    return 0
  end

  set --path $name (echo $$name | string split ':')
end

function add_if_missing --no-scope-shadowing
  set -l initial
  set -l as_first 1
  if test "$argv[1]" = "-first"
    set initial 3
  else if test "$argv[1]" = "-last"
    set initial 3
    set as_first 0
  else
    set initial 2
  end
  set -l name "$argv[$(math $initial - 1)]"
  for i in (seq $initial (count $argv))
    if not test (echo "$$name" | grep "$argv[$i]")
      if test "$as_first" = 1
        set $name $argv[$i] $$name
      else
        set $name $$name $argv[$i]
      end
    end
  end
end

function add_export --no-scope-shadowing --argument-names name
  if test -z (echo $$name)
    set -x $argv
  else
    add_if_missing $argv
  end
end

function add_path --no-scope-shadowing --argument-names name
  if test -z (echo $$name)
    set --path -x $argv
  else
    parse_path $name
    add_if_missing $argv
  end
end

function remove_from --no-scope-shadowing --argument-names name
  for i in (seq 1 (count $$name))
    for j in (seq 2 (count $argv))
      if test (echo "$$name[1][$i]" | grep -E "^$argv[$j]\$")
        set --erase $name[1][$i]
      end
    end
  end
end

function github_download --argument-names ORG REPO FILE TYPE OUTPUT
  set -l url_type
  if test $TYPE = zip
    set url_type "zipball_url"
  else if test $TYPE = tar
    set url_type "tarball_url"
  else
    set url_type "browser_download_url"
  end

  set -l url (curl -s https://api.github.com/repos/$ORG/$REPO/releases/latest | \
    sed -nr 's/.*"'$url_type'": "([^"]+'$FILE'[^"]+)".*/\1/pi')

  set -l dir "$PWD"

  if test -z "$OUTPUT"
    cd ~/Downloads
    wget --content-disposition --continue "$url"
  else if test -d "$OUTPUT"
    cd "$OUTPUT"
    wget --content-disposition --continue "$url"
  else
    wget --output-document="$OUTPUT" --continue "$url"
  end

  cd "$dir"
end

# ShutdownConfirm ShutdownType ShutdownMode

# ShutdownConfirm can take the following values:

# -1: default
#  0: no
#  1: yes

# ShutdownType can take the following values:

# -1: default
#  0: none (log out)
#  1: reboot
#  2: halt (shutdown)
#  3: logout (same as 0? no idea…)

# and finally, ShutdownMode can be:

# -1: default
#  0: schedule
#  1: try now
#  2: force now
#  3: interactive

function shutdown
  if test -z "$argv"
    if not test (qdbus org.kde.ksmserver /KSMServer logout 0 2 1)
      sudo command shutdown now
    end
  else
    command shutdown $argv
  end
end

function reboot
  if test -z "$argv"
    if not test (qdbus org.kde.ksmserver /KSMServer logout 0 1 2)
      sudo shutdown -r now
    end
  else
    command reboot $argv
  end
end

function logout
  if not test (qdbus org.kde.ksmserver /KSMServer logout 0 0 2)
    pkill -U $USER
  end
end