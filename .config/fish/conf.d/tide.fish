if status is-interactive; and not set -q __env_tide; and rg -q '/tide\b' ~/.config/fish/fish_plugins
    set -gx __env_tide

    set -l bg0 0b0b0b
    set -l bg1 161616
    set -l bg2 262626
    set -l bg3 292929

    set -l fg0 e0e0e0
    set -l fg1 8d8d8d
    set -l fg2 6f6f6f

    set -l blue 78a9ff
    set -l green 42be65
    set -l lavender be95ff
    set -l magenta ee5396
    set -l pink ff7eb6
    set -l verdigris 08bdba
    set -l gray adb5bd
    set -l sky 99daff
    set -l cyan 25cac8

    set -l accent 9134cc

    set -gx tide_character_color $accent

    set -gx tide_pwd_color_dirs blue
    set -gx tide_pwd_color_anchors blue
    set -gx tide_pwd_color_truncated_dirs blue

    set -gx tide_git_color_branch $fg0
    set -gx tide_git_color_conflicted $magenta
    set -gx tide_git_color_dirty $pink
    set -gx tide_git_color_operation $green
    set -gx tide_git_color_staged $green
    set -gx tide_git_color_stash $lavender
    set -gx tide_git_color_untracked $magenta
    set -gx tide_git_color_upstream $lavender

    set -gx tide_time_color $fg1
    set -gx tide_cmd_duration_color $sky
end
