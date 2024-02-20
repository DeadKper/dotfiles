function logparse --arg values file
    set -f out_values
    for value in (echo $values | string split ',')
        switch $value
        case 'ip'
            set -a out_values 4
        case 'db'
            set -a out_values 6
        case 'user'
            set -a out_values 7
        case 'id'
            set -a out_values 9
        case 'act'
            set -a out_values 10
        end
    end

    if test ! -f "$file"
        echo "file '$file' doesn't exists"
        return 1
    end

    if test (count $out_values) = 0
        echo 'needs at least 1 valid parameter to print'
        printf '  - id        transaction id\n'
        printf '  - ip        ip that connects to the server\n'
        printf '  - db        database in use\n'
        printf '  - user      user in use\n'
        printf '  - act       connection action\n'
        printf '\nex: logparse ip,db postgresql-01.log\n'
        return 1
    end

    set -l out_file (echo "$file" | sed -E 's,\.[^.]+$,\.csv,g')
    set -l out
    set -l unique

    if test -f "$out_file"
        echo "parsed file: '$out_file' already exists"
        return 1
    end

    cat $file | while read -l line
        if ! echo $line | grep -E '^<[0-9-]+ [0-9:]+ [^ ]+ [0-9.]+' > /dev/null
            continue
        end

        set -l info (echo $line | sed -E 's/^<([^>]+)>.*$/\1/')
        set -l actn (echo $line | sed -E 's/^<[^>]+>(.*)$/\1/')

        set -l data (echo $info | sed -E 's/^([0-9-]+) ([0-9:]+) ([^ ]+) ([0-9.]+)\(([0-9]+)\) (.*)$/\1\n\2\n\3\n\4\n\5\n\6/')
        set -a data (echo $data[6] | sed -E 's/(.+ )?([^ ]+) ([^ ]+) ([0-9]+) ([^ ]+) (.+)?$/\2\n\3\n\4\n\5\n\6/')
        set -e data[6]

        set -l id
        for v in $out_values
            set id "$id,$data[$v]"
        end
        set id (echo $id | sed -E 's/^,//g')

        set -a out "$id"
        if not contains $id $unique
            set -a unique "$id"
            echo "$file: '$id'"
        end
    end

    set -l out_data (printf '%s\n' $out | sort)
    set -l unique
    set -l out

    for line in $out_data
        if contains $line $unique
            continue
        end

        set -a unique "$line"
        set -a out "$line,$(printf '%s\n' $out_data | grep "$line" | count)"
    end
    printf '%s\n' $out > "$out_file"
end
