function vim --argument-names file
    # check vim instalation
    if type -q nvim
        set -f vim nvim
    else if type -q vim
        set -f vim vim
    else if type -q vi
        set -f vim vi
    else
        echo "neovim, vim and vi are not installed"
        return 1
    end

    if cat /etc/os-release | rg -q '^NAME=NixOS'
        command steam-run $vim $argv
    else
        command $vim $argv
    end
    return $status
end
