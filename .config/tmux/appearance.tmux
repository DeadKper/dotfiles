# palette
bg0="#0b0b0b"
bg1="#161616"
bg2="#262626"
bg3="#292929"

fg0="#e0e0e0"
fg1="#8d8d8d"
fg2="#6f6f6f"
fg3="#525252"

none="default"

blue="#78a9ff"
green="#42be65"
lavender="#be95ff"
magenta="#ee5396"
pink="#ff7eb6"
verdigris="#08bdba"
gray="#adb5bd"
sky="#99daff"
cyan="#25cac8"

status_color_fg="#{?client_prefix,#[fg=$green],#{?pane_in_mode,#[fg=$blue],#{?pane_synchronized,#[fg=$magenta],#[fg=$lavender]}}}"
status_color_bg="#{?client_prefix,#[bg=$green],#{?pane_in_mode,#[bg=$blue],#{?pane_synchronized,#[bg=$magenta],#[bg=$lavender]}}}"

# status bar
set -g status-style "bg=$none"
set -g status-left-length 150
set -g status-right-length 150
set -g status-left "#[fg=$bg3,bold]$status_color_bg  #(#{SRC}/cuttxt '#{session_name}' 16) #[bg=$bg3]$status_color_fg"
set -ag status-left "#[bg=$bg3 fg=bold]$status_color_fg  #(#{SRC}/uptime-display) #[bg=$none fg=$bg3,bold]"
set -g status-right "#[fg=$fg0 bg=$none]#(#{SRC}/battery-display '')"
set -ag status-right " #(date +'%%H:%%M  %%d %%b')"
set -ag status-right " #[bg=$none fg=$bg3,bold]#[bg=$bg3 fg=terminal,bold]$status_color_fg #(#{SRC}/username | #{SRC}/cuttxt 16)"
set -ag status-right " #[bg=$bg3]$status_color_fg#[fg=$bg3,bold]$status_color_bg #(#{SRC}/hostname | #{SRC}/cuttxt 16) "

# windows
active=$pink
set -g window-status-style "bg=$none,fg=$fg2"
set -g window-status-separator ""
set -g window-status-format "#[default,bold,reverse]#{?window_flags,#[bg=$fg0],#[bg=$bg0]} #I:#W #[default]"
set -g window-status-current-format "#[fg=$active,bg=default,reverse,bold]#[bg=$bg0] #I:#W #[default,fg=$active]"

# message area
set -g message-command-style "bg=$pink fg=$bg0"
set -g message-style "bg=$pink fg=$bg0"
set -g mode-style "bg=$pink fg=$bg0"
