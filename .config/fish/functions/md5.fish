function md5 --argument file sumcheck
    if test -n "$sumcheck"
        md5sum "$file" | grep -E "^$sumcheck( |	)"
    else
        md5sum "$file"
    end
end