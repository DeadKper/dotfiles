if status is-login
    if not set -q FISH_INIT_CONFIG; and count ~/.config/fish/conf.d/profile/*.fish &> /dev/null
        set -x FISH_INIT_CONFIG

        for src in ~/.config/fish/conf.d/profile/*.fish
            source "$src"
        end

        if test -d ~/.local/bin
            add-path PATH ~/.local/bin
        end

        if test -d ~/.local/scripts
            add-path PATH ~/.local/scripts
        end

        set -e src
    end

    if count ~/.config/fish/conf.d/login/*.fish &> /dev/null
        for src in ~/.config/fish/conf.d/login/*.fish
            source "$src"
        end

        set -e src
    end
end
