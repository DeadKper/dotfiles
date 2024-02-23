function resrc 
    if count ~/.config/fish/profile/*.fish &> /dev/null
        set -l src

        for src in ~/.config/fish/profile/*.fish
            source "$src"
        end
    end
end
