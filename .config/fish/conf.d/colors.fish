if status is-interactive; and not set -q __env_colors
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

    set -gx __env_colors

    set -gx fish_color_command $pink
    set -gx fish_color_redirection $fg0 --bold
    set -gx fish_color_quote $lavender
    set -gx fish_color_error $magenta --italics
    set -gx fish_color_param $fg0
    set -gx fish_color_comment $fg2 --italics
    set -gx fish_color_autosuggestion $fg2
    set -gx fish_color_escape $magenta
    set -gx fish_color_end $green
    set -gx fish_color_operator $sky

    # defaults

    # set -gx fish_color_normal normal
    # set -gx fish_color_command blue
    # set -gx fish_color_quote yellow
    # set -gx fish_color_redirection cyan --bold
    # set -gx fish_color_end green
    # set -gx fish_color_error brred
    # set -gx fish_color_param cyan
    # set -gx fish_color_comment red
    # set -gx fish_color_match --background=brblue
    # set -gx fish_color_selection white --bold --background=brblack
    # set -gx fish_color_search_match bryellow --background=brblack
    # set -gx fish_color_history_current --bold
    # set -gx fish_color_operator brcyan
    # set -gx fish_color_escape brcyan
    # set -gx fish_color_cwd green
    # set -gx fish_color_cwd_root red
    # set -gx fish_color_valid_path --underline
    # set -gx fish_color_autosuggestion brblack
    # set -gx fish_color_user brgreen
    # set -gx fish_color_host normal
    # set -gx fish_color_cancel --reverse
    # set -gx fish_pager_color_prefix normal --bold --underline
    # set -gx fish_pager_color_progress brwhite --background=cyan
    # set -gx fish_pager_color_completion normal
    # set -gx fish_pager_color_description yellow --italics
    # set -gx fish_pager_color_selected_background --reverse
    # set -gx fish_color_host_remote
    # set -gx fish_pager_color_secondary_completion
    # set -gx fish_color_keyword
    # set -gx fish_pager_color_secondary_description
    # set -gx fish_pager_color_background
    # set -gx fish_pager_color_secondary_background
    # set -gx fish_color_option
    # set -gx fish_pager_color_secondary_prefix
    # set -gx fish_pager_color_selected_prefix
    # set -gx fish_pager_color_selected_completion
    # set -gx fish_pager_color_selected_description
end
