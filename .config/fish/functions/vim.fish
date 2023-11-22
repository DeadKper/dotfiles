function vim --argument file
    if test -z "$file" # no file given, just open vim
        if type -q nvim
            command nvim
        else if type -q vim
            command vim
        else
            command nano
        end
        return 0
    end

    set -f pwd "$PWD" # save current dir

    if string match -q -r '.*/$' -- "$file" # ends with '/' so it's a folder
        set -f folder "$file"
        set -f file "."
    else
        set -f folder (dirname "$file")
        set -f file (basename "$file")
    end

    if test ! -d "$folder" # create folder if it doesn't exist
        set -l folder_copy "$folder"
        set -f folders
        while test ! -d "$folder_copy"
            set -a folders (basename "$folder_copy") # save created folders
            set folder_copy (dirname "$folder_copy")
        end
        mkdir -p "$folder"
    end

    cd "$folder"

    if type -q nvim
        command nvim -- "$file"
    else if type -q vim
        command vim -- "$file"
    else
        command nano -- "$file"
    end

    cd ..
    while test (count $folders) -gt 0; and is_empty_dir "$folders[1]" # remove empty folders if created
        rm -rf "$folders[1]"
        set -e folders[1]
        cd ..
    end

    cd "$pwd" # cd back to original dir
end
