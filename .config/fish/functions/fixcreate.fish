function fixcreate
    if test ! -d nonfixable
        mkdir nonfixable
    end

    set -l files (ls | grep -E "\.sql\$")
    set -l not_modified
    set -l not_fixable

    for file in $files
        set -l create (cat $file | grep -iE "create( or replace)? function")

        if test -z "$create"
            set not_fixable $not_fixable $file
            mv $file ./nonfixable
        else if test (echo $create | grep -i "create function")
            cat $file | sed 's/create function/CREATE OR REPLACE FUNCTION/gi' >$file
            grep -Ei "(^|\b)create\b.*\bfunction\b" "$file"
        else
            set not_modified $not_modified $file
        end
    end

    if test -n "$not_modified"
        echo "Not modified:"
        for file in $not_modified
            printf '\t%s\n' "$file"
        end
    end

    if test -n "$not_fixable"
        echo "Not fixable:"
        for file in $not_fixable
            printf '\t%s\n' "$file"
        end
    else
        rm -rf nonfixable
    end
end
