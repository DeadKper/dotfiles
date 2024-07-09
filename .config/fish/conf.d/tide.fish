if rg -q '/tide\b' ~/.config/fish/fish_plugins
    set -g tide_character_color 9134CC
    set -g tide_pwd_color_dirs 5455CB
    set -g tide_pwd_color_anchors 5455CB
    set -g tide_pwd_color_truncated_dirs 5455CB
end
