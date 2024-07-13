function update
    set --local perm (sudo echo "y" || echo "n")

    if test $perm = n
        return 1
    end

    sh -c '(while [ true ]; do sudo -nv &> /dev/null && sleep 1 || exit; done &)'

    function update_func
        echo ""
        echo "[ --- Updating $argv[1] --- ]"
        eval "$argv[2]"
        echo ""
    end

    if type -q dnf
        update_func dnf "sudo dnf update -y"
        sudo dnf autoremove -y
    end

    if type -q zypper
        update_func zypper "sudo zypper update --best-effort -y"
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
