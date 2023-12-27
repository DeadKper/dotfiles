function vim --argument-names file
    # check vim instalation
    if type -q nvim
        set -f vim nvim
    else if type -q vim
        set -f vim vim
    else if type -q vi
        set -f vim vi
    else
        echo "neovim, vim and vi are not installed"
        return 1
    end

    # check if it's a wslpath
    if type -q wslpath; and wslpath "$file" &> /dev/null
        set -f file (wslpath "$file")
        set -f valid 'y'
    else if -n "$(echo $file | grep -E '^(\.?|[^\0/-][^\0/]+)((/[^\0/]+)+/?|/?)$')"
        set -f valid 'y'
    end

    if test (count $argv) -ne 1 -o -z "$valid"
        # more than 1 arg or args is not a path, just open vim
        command $vim $argv && return 0; return 1
    end
    
    set -f pwd "$PWD" # save current dir

    # ends with '/' so it's a folder
    if string match -q -r '.*/$' -- "$file"
        set -f folder "$file"
        set -f file "."
    else
        set -f folder (dirname "$file")
        set -f file (basename "$file")
    end

    # create folder if it doesn't exist
    if test ! -d "$folder"
        set -l folder_copy "$folder"
        set -f folders
        while test ! -d "$folder_copy"
            set -a folders (basename "$folder_copy") # save created folders
            set folder_copy (dirname "$folder_copy")
        end
        mkdir -p "$folder"
    end
    
    cd "$folder"
    set -l error 1
    command $vim -- "$file" && set error 0

    cd ..
    # remove empty folders if created
    while test (count $folders) -gt 0; and is_empty_dir "$folders[1]"
        rm -rf "$folders[1]"
        set -e folders[1]
        cd ..
    end

    cd "$pwd" # cd back to original dir
    return $error
end
