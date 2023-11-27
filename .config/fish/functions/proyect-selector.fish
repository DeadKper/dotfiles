function proyect-selector --argument filter command return
    set -l proyects "$HOME/.config/nvim" "$HOME/.config/fish"
    set -l proyect_folders
    set -l discover_folders "$HOME/Documents/Codes"
    if test (count $proyect_folders) -gt 0 -a -d "$proyect_folders"
        set -a proyects (find $proyect_folders -maxdepth 1 -mindepth 1 -type d)
    end
    if test (count $discover_folders) -gt 0 -a -d "$discover_folders"
        set -a proyects (find $discover_folders -maxdepth 2 -mindepth 2 -type d)
    end
    if test -z "$filter" -o "$filter" = "*" -o "$filter" = "."
        set -f proyect (printf '%s\n' $proyects | fzf)
    else
        set -f proyect (printf '%s\n' $proyects | grep "$filter" | fzf)
    end
    if test -z "$proyect"
        return 1
    end
    if test -z "$command" -o "$fcommand" = "."
        set -f command nvim
    end
    set -l pwd "$PWD"
    cd "$proyect"
    command "$command" "$proyect"
    if test -n "$return"
        cd "$pwd"
    end
end
