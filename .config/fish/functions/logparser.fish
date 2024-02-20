function logparser --arg values
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

    set -e argv[1]

    if test (count $argv) -lt 1
        echo 'no file given'
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

    printf '%s\n' $argv | sort | parallel -u -j 3 "logparse '$values' '{}'"
    set -l total_file 'parsed_logs_total.csv'

    if test -f "$total_file"
        echo "total file: '$total_file' already exists"
        return 1
    end

    set -l total

    for file in $argv
        set -a total (cat "$file")
    end

    set -l id
    set -l cnt

    for value in (printf '%s\n' $total | sort)
        set -l data (echo $value | sed -E 's/(.*),([0-9]+)$/\1\n\2/g')
        if test "$data[1]" = "$id"
            set cnt (math $cnt + $data[2])
        else
            if test -n "$id"
                echo "$id,$cnt" >> "$total_file"
            end
            set id "$data[1]"
            set cnt "$data[2]"
        end
    end
    echo "$id,$cnt" >> "$total_file"
end
