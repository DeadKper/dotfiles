#!/usr/bin/sh

RUNDIR=/run/user/$EUID/hypr
SCRIPT="/run/user/$EUID/.run-macro"

function macros() {
  case "$1" in
    activewindow\>\>steam_app_238960,Path\ of\ Exile)
      hyprctl keyword bind ",F5,exec,$SCRIPT -fi /hideout" >/dev/null
      hyprctl keyword bind ",F6,exec,$SCRIPT -fi /exit" >/dev/null

      hyprctl keyword bind ",F9,exec,$SCRIPT -fi /kingsmarch" >/dev/null
      hyprctl keyword bind ",F10,exec,$SCRIPT -fi /menagerie" >/dev/null

      unbind_list=(',F5' ',F6' ',F9' ',F10')
      ;;
  esac
}

cat <<EOF > "$SCRIPT"
#!/usr/bin/env bash

unset text filter use_shift sepparate initial_enter final_enter

while test \$# -gt 0; do
    case "\$1" in
      -f)
          final_enter=yes
          shift
          ;;
      -i)
          initial_enter=yes
          shift
          ;;
      -s)
          use_shift=yes
          shift
          ;;
      -*)
          sepparate="\$1"
          shift
          set -- \$(echo \${sepparate[@]:1} | sed -E 's/(.)/-\1 /g') "\$@"
          ;;
      *)
          test -z "\$text" && text="\$1"
          shift
          ;;
    esac
done

test -z "\$use_shift" && sequence=(29:1 47:1 29:0 47:0)
test -n "\$use_shift" && sequence=(29:1 42:1 47:1 29:0 47:0 42:0)

test -n "\$initial_enter" && sequence=(28:1 28:0 "\${sequence[@]}")
test -n "\$final_enter" && sequence=("\${sequence[@]}" 28:1 28:0)

clipboard="\$(wl-paste)"
wl-copy -n <<< "\$text"
ydotool key "\${sequence[@]}"
wl-copy <<< "\$clipboard"
EOF

chmod +x "$SCRIPT"

unbind_list=()

socat -u "UNIX-CONNECT:$RUNDIR/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" STDOUT | while read -r event; do
  case $event in
    activewindow\>\>*)
      if test "${#unbind_list[@]}" -gt 0; then
        for key in "${unbind_list[@]}"; do
          hyprctl keyword unbind "$key" >/dev/null
        done
        unbind_list=()
      fi

      macros "$event"
      ;;
  esac
done
