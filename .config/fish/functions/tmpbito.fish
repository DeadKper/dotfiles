function tmpbito
    if test (count $argv) -eq 0
        set argv -h
    end

    getopts $argv | while read -l key value
        switch $key
            case _
                if set -q files
                    set -a files "$value"
                else
                    set -f files "$value"
                end
            case f files
                if set -q folder
                    echo "--files is mutually exclusive with --folder" 1>&2
                    return 1
                end
                set -f files "$value"
            case d folder
                if set -q files
                    echo "--folder is mutually exclusive with --files" 1>&2
                    return 1
                end
                set -f folder "$value"
            case g glob
                if set -q regex
                    echo "--glob is mutually exclusive with --regex" 1>&2
                    return 1
                end
                set -f glob "$value"
            case r regex
                if set -q glob
                    echo "--regex is mutually exclusive with --glob" 1>&2
                    return 1
                end
                set -f regex "$value"
            case n skip
                set -f skip "$value"
            case s start
                set -f start "$value"
            case e end
                set -f end "$value"
            case p prompt
                set -f prompt "$value"
            case c context
                set -f context "$value"
            case m model
                set -f model "$value"
            case o output
                set -f output "$value"
            case h help
                echo "uses bito to update or fix a code file automagically"
                printf '\n\n'
                printf '%s\t%s\n' "-f --files" "files to update, mutually exclusive with --folder"
                printf '%s\t%s\n' "-d --folder" "folder to find files using regex or glob, mutually exclusive with --files"
                printf '%s\t%s\n' "-g --glob" "file globber, mutually exclusive with --regex"
                printf '%s\t%s\n' "-r --regex" "file regex finder, mutually exclusive with --glob"
                printf '%s\t%s\n' "-n --skip" "regex to skip files"
                printf '%s\t%s\n' "-s --start" "regex indicating the start of the code to query"
                printf '%s\t%s\n' "-e --end" "regex indicating the end of the code to query"
                printf '%s\t%s\n' "-p --prompt" "file containing prompt or instructions to perform an operation [mandatory]"
                printf '%s\t%s\n' "-c --context" "file to save the context/conversation history in non-interactive mode"
                printf '%s\t%s\n' "-m --moldel" "model type to use for AI query in the current session. Model type can be set to BASIC/ADVANCED, which
				is case insensitive"
                printf '%s\t%s\n' "-o --output" "output folder for the files, will respect folder hierarchy [mandatory]"
                printf '%s\t%s\n' "-h --help" "prints this message"
                printf '\n\n'
                echo "by default all values without flag are considered part of the files to use the AI for"
                return 0
            case \*
                echo "$key flag is unknown" 1>&2
                return 1
        end
    end

    if test -z "$files" -a -z "$folder"
        echo "--files or --folder need to be defined" 1>&2
        return 1
    end

    if test -n "$regex" -o -n "$glob"
        if test -z "$folder"
            echo "cannot use --regex or --glob without folder" 1>&2
            return 1
        end
    end

    if test -n "$folder" -a -z "$regex" -a -z "$glob"
        echo "if folder is given either --regex or --glob need to be defined" 1>&2
        return 1
    end

    if test -z "$prompt"
        echo "--prompt needs to be defined" 1>&2
        return 1
    end

    if test -z "$output"
        echo "--output needs to be defined" 1>&2
        return 1
    end

    # Valid args

    if set -q folder
        if set -q glob
            if set -q skip
                set -f files (find "$folder" -iname "$glob" -not -iregex "$skip")
            else
                set -f files (find "$folder" -iname "$glob")
            end

        else
            if set -q skip
                set -f files (find "$folder" -iregex "$regex" -not -iregex "$skip")
            else
                set -f files (find "$folder" -iregex "$regex")
            end
        end
        set -e folder
        set -e glob
        set -e regex
        set -e skip
    end

    set -f bitoargs -p "$prompt"
    set -e prompt

    if set -q context
        set -a bitoargs -c "$context"
        set -e context
    end

    if set -q model
        set -a bitoargs -m "$model"
        set -e model
    end

    echo $start
    echo $end
    # return

    rm -rf "$output"

    for file in $files
        cat $file | read -l line

        if test (echo $line | grep -Ei "$start")
            set flag 0
        else if test (echo $line | grep -Ei "$end")
            set flag 1
        end

        set -l flag
        set -l start_flag
        set -l end_flag
        set -l count 0
        set -l basefile (basename "$file")
        set -l outpath (echo "$file" | sed -E "s,^[^/]+,$output,g" | sed -E "s,$basefile\$,,g")

        if test ! -d "$outpath"
            mkdir -p "$outpath"
        end

        cat $file | while read -l line
            set start_flag 0
            set end_flag 0
            if test (echo $line | grep -Ei $start)
                set flag 0
                set start_flag 1
            end
            if test (echo $line | grep -Ei $end)
                set flag 1
                set end_flag 1
            end

            if test "$start_flag" -eq 1 -a "$end_flag" -eq 1
                set -f ign_file "$file"
                echo "$line" >>"$outpath$basefile.$count"
                continue
            end

            if test "$flag" -eq 1
                echo "$line" >>"$outpath$basefile.$count"
                continue
            end

            if test "$start_flag" -eq 1
                set count (math $count + 1)
            end

            echo "$line" >>"$outpath$basefile.$count"

            if test "$end_flag" -eq 1
                set count (math $count + 1)
            end
        end

        if set -q ign_file
            echo "single lines were ignore in \"$ign_file\""
            set -e ign_file
            return
        end
    end
end
