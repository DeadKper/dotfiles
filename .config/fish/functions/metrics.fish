function metrics
    set -l skip 0
    set -l folder
    set -l include
    set -l exclude
    set -l type
    set -l printFiles
    set -l printArgs
    set -l args
    set -l workingDir
    set -l files
    set -l solution
    set -l proj
    set -l lines
    set -l size
    set -l fileNumber
    set -l i

    for i in (seq (count $argv))
        if test "$skip" -gt "0"
            set skip (math $skip - 1)
            continue
        end

        switch "$argv[$i]"
        case -d
            set folder $argv[(math $i + 1)]
            set skip 1
        case -i
            set include $argv[(math $i + 1)]
            set skip 1
        case -e
            set exclude $argv[(math $i + 1)]
            set skip 1
        case -t
            set type $argv[(math $i + 1)]
            set skip 1
        case -f
            set printFiles 1
        case -a
            set printArgs 1
        case '*'
            set args $args $i
        end
    end

    for i in $args
        if test -z "$include"
            set include $argv[$i]
            continue
        end
        if test -z "$exclude"
            set exclude $argv[$i]
            continue
        end
        if test -z "$type"
            set type $argv[$i]
            continue
        end
        if test -z "$folder"
            set folder $argv[$i]
            continue
        end
    end

    if test -z "$folder"
        set folder '.'
    end

    if test -n "$printArgs"
        echo "Include '$include'"
        echo "Exclude '$exclude'"
        echo "Type    '$type'"
        echo "Folder  '$folder'"
    end

    if test "$folder" != '.'; and test -d "$folder"
        set workingDir (pwd)
        cd $folder
    end

    switch "$type"
    case vsproj
        set solution (find . -iname '*.sln')
        
        if test (count $solution) -gt 1
            echo 'Specify a solution to explore'
            for i in (seq (count $solution))
                echo "  $solution[$i]"
            end
            read solution
        end

        if test -f "$solution"
            set proj (cat "$solution" | sed -En 's/.*"([^"]+\.\w+proj)".*/\1/p' | sed 's/\\\/\//g')
        end

        for i in (seq (count $proj))
            if test -z "$exclude"
                set files (cat $proj | sed -nE 's/.*(Compile Include|RelativePath)="([^"]+)".*/\2/p' | sed 's/\\\/\//g' | grep -E "$include") $files
            else
                set files (cat $proj | sed -nE 's/.*(Compile Include|RelativePath)="([^"]+)".*/\2/p' | sed 's/\\\/\//g' | grep -E "$include" | grep -Ev "$exclude") $files
            end
        end
    case manual
        set lines (awk '{ sum += $1 } END { print sum }' lines.txt)
        set size  (awk '{ sum += $1 } END { print sum }' size.txt)
        set fileNumber (cat lines.txt | wc -l)
    case '*'
        if test -z "$exclude"
            set files (find . -type f | grep -E "$include")
        else
            set files (find . -type f | grep -E "$include" | grep -Ev "$exclude")
        end
    end

    if test "$type" != "manual"
        if test -n "$printFiles"
            echo $files
        end

        for file in $files
            if test -e "$file" 
                set lines (math $lines + (cat $file | wc -l) + 1)
                set size (math $size + (du -cb $file | grep "total\$" | sed -E "s/([0-9]+).*/\1/g"))
                set fileNumber (math $fileNumber + 1)
            end
        end
    end

    if test -n "$workingDir"
        cd $workingDir
    end

    if test -n "$lines"
        echo "Lines: $lines"
        echo "Size:  $size B"
        echo "Files: $fileNumber"
    end
end