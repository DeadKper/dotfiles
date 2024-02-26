function resrc
    set -l sources ~/.config/fish/conf.d/profile ~/.config/fish/conf.d

    for source in $sources
        if count $source/*.fish &> /dev/null
            for src in $source/*.fish
                source "$src"
            end
        end
    end

    source ~/.config/fish/config.fish
end
