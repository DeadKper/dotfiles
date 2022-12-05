function pipewire-restart --wraps='systemctl --user restart pipewire pipewire-pulse; sleep 2; noisetorch -i -t 80' --description 'alias pipewire-restart=systemctl --user restart pipewire pipewire-pulse; sleep 2; noisetorch -i -t 80'
  systemctl --user restart pipewire pipewire-pulse; sleep 2; noisetorch -i -t 80;
end
