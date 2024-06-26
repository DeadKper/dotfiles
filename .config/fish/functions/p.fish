function p
    set -l positional
    getopts $argv | while read -l key value
        switch $key
            case _
                set -a positional $value
            case t type
                if test -n "$value"
                    if test "$value" = true
                        echo 'no value was given to flag \'-t/--type\''
                        return 1
                    else
                        set -f type "$value"
                    end
                end
            case c cmd
                if test -n "$value"
                    if test "$value" = true
                        echo 'no value was given to flag \'-c/--cmd\''
                        return 1
                    else
                        set -f cmd "$value"
                    end
                end
            case conf
                if test -n "$value"
                    if test "$value" = true
                        echo 'no value was given to flag \'--conf\''
                        return 1
                    else
                        set -f conf_file "$value"
                    end
                end
            case h help
                printf '%s\n' 'usage: p [flags] [query...]'
                printf '%s\t%s\n' '-t --type' 'select type to open proyect, \'s\' for a new tmux session, \'w\' for a new tmux window and \'t\' (default) for current terminal'
                printf '%s\t%s\n' '-c --cmd' 'command to execute on the selected proyect folder, defaults to \'nvim .\' if installed, or vim/vi'
                printf '%s\t%s\n' '--conf  ' 'config file to use, defaults to \'~/.config/proyect-selector.fish\', config file should \'set -f cmd <command with args>\' if not already set, and \'set -f proyects <array of proyect folders>\''
                printf '%s\t%s\n' '-h --help' 'prints help message'
                printf '%s\t%s\n' '[query...]' 'querys to match with \'grep -i\' on the proyects'
                return 0
            case \*
                echo "\'$key\' flag is unknown" 1>&2
                return 1
        end
    end

    if not set -q conf_file
        set -f conf_file "$HOME/.config/deadkper/proyect-selector.fish"
    end

    if test -f "$conf_file"
        source "$conf_file"
    end

    if test (count $proyects) -eq 0
        if not test -f "$conf_file"
            echo "no proyects to select in arguments, config file was not detected" 1>&2
        else
            echo "no proyects to select in config file or in arguments" 1>&2
        end
        return 1
    end

    for arg in $positional
        set proyects (printf '%s\n' $proyects | grep -i $arg)
    end

    if not count $proyects &>/dev/null
        echo "no proyects left after matching positional args with 'grep -i'"
        return 1
    end

    if test (count $proyects) = 1
        set -f selected (echo $proyects | string replace -r '^~' "$HOME")
    end

    if not set -q TMUX
        if test -f "$HOME/.config/tmux-init-conf.fish"
            source "$HOME/.config/tmux-init-conf.fish"
        end

        if test -n "$tmux_session_home_name"
            set -fx TMUX_HOME "$tmux_session_home_name"
        else
            set -fx TMUX_HOME home
        end
    end

    if not set -q type
        set -f type t
    else if not test "$type" = s -o "$type" = w -o "$type" = t
        echo "type '$type' was not recognized, valid types are:" 1>&2
        echo "'t' current terminal" 1>&2
        echo "'w' new tmux window" 1>&2
        echo "'s' new tmux session" 1>&2
        return 1
    end

    if not set -q cmd
        if type -q nvim
            set -f cmd nvim
        else if type -q vim
            set -f cmd vim
        else if type -q vi
            set -f cmd vi
        else
            echo "cannot set default command to nvim, vim or vi" 1>&2
            return 1
        end
    end
    if not set -q TMUX; and test "$type" != t
        if test "$type" != t
            echo "not in a tmux session but type '$type' requires it" 1>&2
            return 1
        end
    end

    printf '%s\n' $proyects | string replace -r "^$HOME" '~' | sort >/tmp/__p_proyects

    set -f curr_session (tmux display-message -p '#S')

    switch $type
        case t
            if test -z "$selected"
                set -f selected (cat "/tmp/__p_proyects" | fzf | string replace -r '^~' "$HOME")
            end
            if test -n "$selected"
                cd "$selected"
                eval "$cmd"
            end
        case s w
            if test -z "$selected"
                tmux new-window -t "$curr_session:0" -n sessionizer "cat '/tmp/__p_proyects' | fzf | string replace -r '^~' '$HOME' > '/tmp/__p_selected'"
                while tmux list-windows | rg -e '^0: sessionizer' &>/dev/null
                    sleep 0.1
                end
                set -f selected (cat "/tmp/__p_selected")
                rm /tmp/__p_*
            end
            if test "$type" = s
                set -f session (basename "$selected")
                if not tmux has-session -t "$session" 2>/dev/null
                    tmux new-session -d -s "$session" -c "$selected"
                    sleep 0.1 # Wait for session to be created
                    tmux switch-client -t "$curr_session"
                    sleep 0.4 # Wait for fish to load
                    tmux send-keys -t "$session:" "$cmd" Enter
                end
                tmux switch-client -t "$session"
            else
                set -l prev_windows (tmux list-windows | sed -r 's,([0-9]+).*,\1,g')
                tmux new-window -t "$curr_session" -d -c "$selected"
                for i in (tmux list-windows | sed -r 's,([0-9]+).*,\1,g')
                    if not contains $i $prev_windows
                        set -f window "$curr_session:$i"
                    end
                end
                sleep 0.5 # Wait for fish to load
                tmux send-keys -t "$window" "$cmd" Enter
                tmux select-window -t "$window"
            end
    end
end
