if status is-interactive
    if count ~/.config/fish/conf.d/interactive/*.fish &> /dev/null
        for src in ~/.config/fish/conf.d/interactive/*.fish
            source "$src"
        end

        set -e src
    end
end
