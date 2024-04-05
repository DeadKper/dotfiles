function ex --description "Expand or extract bundled & compressed files" --argument file dir
    if test (count $argv) -gt 2
        echo 'more than 2 args given, only FILE and OUTPUT_DIR where expected'
        return 1
    end

    set --local ext (echo $file | awk -F . '{print $NF}')

    if test (echo $file | awk -F . '{print $(NF-1)}') = tar
        set ext tar.{$ext}
    end

    if test -z "$dir"
        set dir (echo $file | sed 's/.'$ext'$//')
    end

    mkdir -p "$dir"

    set -f pwd (pwd)
    mv "$file" "$dir"
    cd "$dir"

    switch $ext
        case tar.gz or tgz
            tar -xvfz $file
        case tar.bz2 or tbz2
            tar -xvfj $file
        case tar.xz
            tar -xvfJ $file
        case tar # non-compressed, just bundled
            tar -xvf $file
        case gz
            gunzip $file
        case bz2
            bunzip2 $file
        case rar
            unrar -x $file
        case zip or crx
            unzip $file
        case Z
            uncompress $file
        case 7z
            7za x $file
        case '*'
            echo "Unknown compressed extension '."$ext"'"
    end

    mv "$file" "$pwd"
    cd "$pwd"

    set -l files (fd -t d -H -d 1 . "$dir")

    if test (count $files) -eq 1
        if test (basename "$files") = (dirname "$files")
            mv "$dir" "$dir-tmp"
            mv "$dir-tmp/$dir" .
            rm -r "$dir-tmp"
        else
            mv "$files" .
            rm -r "$dir"
        end
    end
end
