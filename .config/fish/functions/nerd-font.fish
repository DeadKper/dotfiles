function nerd-font --argument font
    set -l pwd "$(pwd)"
    if test -z "$font"
        set font SourceCodePro
    end

    if test -d "$XDG_DATA_HOME/fonts/$font"
        rm -rf "$XDG_DATA_HOME/fonts/$font"
    end

    mkdir -p "$XDG_DATA_HOME/fonts/$font"
    cd "$XDG_DATA_HOME/fonts/$font"

    curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz

    tar -Jxf $font.tar.xz
    rm $font.tar.xz

    cd "$pwd"
end
