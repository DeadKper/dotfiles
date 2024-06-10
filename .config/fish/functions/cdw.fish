if type -q wsl.exe
    function cdw
        cd "$(wslpath $argv)"
    end
end
