if test -e /home/missael/.nix-profile
    set -x NIXPKGS_ALLOW_UNFREE 1

    if not test -e "$XDG_DATA_HOME/nix-env/share/"
        mkdir -p "$XDG_DATA_HOME/nix-env/share" 2>/dev/null
    end

    fish_add_path "$HOME/.nix-profile/bin"

    set -x --path XDG_DATA_DIRS $XDG_DATA_DIRS
    set -q XDG_DATA_DIRS[1]; or set XDG_DATA_DIRS /usr/local/share /usr/share
    add_to_path XDG_DATA_DIRS "$XDG_DATA_HOME/nix-env/share" $XDG_DATA_DIRS

    function nix-env
        if count $argv &>/dev/null
            command nix-env $argv
        end
        rsync -pqrLK --chmod=u+rwx "$HOME/.nix-profile/share/" "$XDG_DATA_HOME/nix-env/share/" --delete-after &>/dev/null
        update-desktop-database "$XDG_DATA_HOME/nix-env/share/applications" &>/dev/null
    end

    nix-env
end
