function lines --arg file start end
    if test -z "$end"
        sed ''$start'q;d' "$file"
    else
        sed -n ''$start','$end'p;'$end'q' "$file"
    end
end
