function view --arg file
    if echo $file | grep -Ev '^\s*$' &>/dev/null
        cat "$file" | nvim +Man! -c 'set filetype=text'
    else
        nvim +Man! -c 'set filetype=text'
    end
end
