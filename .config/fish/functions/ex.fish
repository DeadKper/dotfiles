function ex --description "Expand or extract bundled & compressed files" --argument file dir
    set --local ext (echo $file | awk -F. '{print $NF}')

    if test (echo $file | awk -F. '{print $(NF-1)}') = tar
        set ext tar.{$ext}
    end

    if test -z "$dir"
        set dir (echo $file | sed 's/.'$ext'$//')
    end

    mkdir -p "$dir"

    set -l pwd (pwd)
    mv "$file" "$dir"
    cd "$dir"

    switch $ext
        case tar.gz or tgz
            tar -zxvf $file
        case tar.bz2 or tbz2
            tar -jxvf $file
        case tar.xz
            tar -Jxvf $file
        case tar # non-compressed, just bundled
            tar -xvf $file
        case gz
            gunzip $file
        case bz2
            bunzip2 $file
        case rar
            unrar x $file
        case zip or crx
            unzip $file
        case Z
            uncompress $file
        case 7z
            7z x $file
        case '*'
            echo "Unknown compressed extension '."$ext"'"
    end

    mv "$file" "$pwd"
    cd "$pwd"
end
