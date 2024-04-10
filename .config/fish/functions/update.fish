function update
    set --local perm (sudo echo "y" || echo "n")

    if test $perm = n
        return 1
    end

    sh -c '(while [ true ]; do sudo -nv &> /dev/null && sleep 1 || exit; done &)'

    function update_func
        echo "[ --- Updating $argv[1] --- ]"
        eval "$argv[2]"
        echo ""
    end

    if type -q yadm
        echo "[ --- Updating yadm --- ]"
        echo "fetching new info..."
        git -C "$HOME/.local/share/yadm-project" fetch &>/dev/null
        set -l tag (git -C "$HOME/.local/share/yadm-project" ls-remote -qt --sort=committerdate | tail -n 1 | sed -En 's,.*refs/tags/(.*).*,\1,p')
        set -l current (git -C "$HOME/.local/share/yadm-project" status | head -n 1 | awk '{print $4}')
        if test "$tag" != "$current"
            echo "updating to $tag"
            git -C "$HOME/.local/share/yadm-project" checkout $tag &>/dev/null
        else
            echo "no update available"
        end
        echo ""
    end

    if type -q dnf
        update_func dnf "sudo dnf update -y"
        sudo dnf autoremove -y
    end

    if type -q paru
        update_func paru paru
    end

    if type -q flatpak
        update_func flatpak "flatpak update -y"
        flatpak uninstall --unused -y
    end

    if type -q brew
        update_func brew "brew upgrade"
    end

    if type -q nix-env
        update_func nix-env "nix-env -f '<nixpkgs>' -uA"
        nix-collect-garbage --delete-older-than 30d
    end

    sudo -k
end
