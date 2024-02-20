function fixsecdef --argument real_owner sec_definer
    if test ! -d nonfixable
        mkdir nonfixable
    end

    set -l files (ls | grep -E "\.sql\$")

    for file in $files
        set -l not_fixed
        if test -n "$sec_definer"
            if not cat $file | rg -i 'language\splpgsql' &> /dev/null
                set not_fixed 'y'
            else if cat $file | rg -ie 'security\sdefiner' &> /dev/null
                # already has one
            else
                cat $file | sed -E "s,(\s*)(language\splpgsql),\1\2\n\1$sec_definer,gi" >$file
            end
        end

        set owner (cat $file | grep -iE "alter function" | sed -E "s,.+owner to (\w+).*,\1,gi")
        set user (cat $file | grep -iE "grant execute" | sed -E "s,.+ to (\w+).*,\1,gi")

        if echo $owner | grep -iE "^$real_owner\$" &>/dev/null
            # nothing to be done
        else if not cat $file | grep -iE 'alter function .* owner to \w+' &>/dev/null
            set not_fixed 'y' # alter not in function
        else if test -n "$owner" -a -n "$user" -a (echo $owner | grep -iEv "^$real_owner\$") -a (echo $user | grep -iE "^$real_owner\$")
            cat $file | sed -E "s,^(alter function.+owner to )(\w+)(.*)\$,\1$user\3,gi" >$file
            cat $file | sed -E "s,^(grant execute.+ to )(\w+)(.*)\$,\1$owner\3,gi" >$file
            echo $file
            tail -n 3 $file
            echo ""
            echo ""
        else if test -n "$owner" -a -z "$user" -a (echo $owner | grep -iEv "^$real_owner\$")
            if test -n (tail $file -c 1)
                echo "" >>$file
            end
            cat $file | grep -iE "alter function" | sed "s,alter function,GRANT EXECUTE ON FUNCTION,gi" | sed "s,owner ,,gi" >>$file
            cat $file | sed -E "s,^(alter function.+owner to )(\w+)(.*)\$,\1$real_owner\3,gi" >$file
            echo $file
            tail -n 3 $file
            echo ""
            echo ""
        else
            set not_fixed 'y' # not a knowable case
        end

        if test "$not_fixed" = 'y'
            mv $file ./nonfixable
        end
    end

    if is_empty_dir nonfixable
        rm -r nonfixable
    end
end
