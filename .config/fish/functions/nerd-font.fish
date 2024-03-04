function nerd-font
    set -l pwd "$(pwd)"

    if test -d "$XDG_DATA_HOME/fonts/SourceCodePro"
        rm -rf "$XDG_DATA_HOME/fonts/SourceCodePro"
    end

    mkdir -p "$XDG_DATA_HOME/fonts/SourceCodePro"
    cd "$XDG_DATA_HOME/fonts/SourceCodePro"

    curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.tar.xz

    tar -Jxvf SourceCodePro.tar.xz
    rm SourceCodePro.tar.xz

    cd "$pwd"
end
