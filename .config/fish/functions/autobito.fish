function autobito --argument-names prompt context folder file_glob neg_regex
    set -l output_folders "$folder.bito" "$folder.bito.context"
    set -l files

    if test -n "$neg_regex"
        set files (find "$folder" -name "$file_glob" | grep -Ev "$neg_regex")
    else
        set files (find "$folder" -name "$file_glob")
    end

    set -l cnt (math (count $files) x 2)
    set -l i 0

    if test -f "$context"
        rm "$context"
    end

    touch "$context"

    for file in $files
        set -l output_files (echo $file | sed -E "s/^$folder/$output_folders[1]/g") (echo $file | sed -E "s/^$folder/$output_folders[2]/g")
        set -l save_folders (echo $output_files[1] | sed -E 's,[^/]*$,,g') (echo $output_files[2] | sed -E 's,[^/]*$,,g')

        for save_folder in $save_folders
            if test ! -d "$save_folder"
                mkdir -p "$save_folder"
            end
        end

        echo "Working with '$file'..."
        bito -p "$prompt" -f "$file" >"$output_files[1]"
        set i (math $i + 1)
        printf '\t%06.2f%% without context\n' (math $i / $cnt x 100)
        bito -p "$prompt" -c "$context" -f "$file" >"$output_files[2]"
        set i (math $i + 1)
        printf '\t%06.2f%% with context\n' (math $i / $cnt x 100)
    end
end
