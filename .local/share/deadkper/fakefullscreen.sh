#!/usr/bin/sh

RUNDIR=/run/user/$EUID/hypr
WAYBAR_FILE=$RUNDIR/.waybar_is_hidden

function hide {
  if [ ! -f $WAYBAR_FILE ]; then
    hyprctl keyword workspace , gapsout:0 > /dev/null 2>&1
    killall -SIGUSR1 waybar && touch $WAYBAR_FILE
  fi
}

function show {
  if [ -f $WAYBAR_FILE ]; then
    hyprctl keyword workspace , gapsout:$(hyprctl getoption general:gaps_out -j | jq -r .custom | tr \  ,) > /dev/null 2>&1
    killall -SIGUSR1 waybar && rm $WAYBAR_FILE > /dev/null 2>&1
  fi
}

function fakefullscreen() {
  local fullscreenclients=$(hyprctl clients -j | jq -r '.[] | select(.tags | contains(["fakefullscreen"])).workspace.id')
  [ -z "$fullscreenclients" -a ! -f $WAYBAR_FILE ] && return
  local active=$(hyprctl activeworkspace -j | jq -r .id)
  for id in $fullscreenclients; do
    if [ $active -eq $id -a $(hyprctl clients -j | jq -r "[.[] | select(.workspace.id == $id) | select(.floating | not)] | length") -eq 1 ]; then
      hide
      return
    fi
  done
  show
}

sleep 1
fakefullscreen

socat -u "UNIX-CONNECT:$RUNDIR/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" STDOUT | while read -r event; do
  case $event in
    workspace\>\>*|openwindow\>\>*|closewindow\>\>*) fakefullscreen;;
  esac
done

show
