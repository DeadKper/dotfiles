function yn() {
    if test -z "$1"; then
        local prompt="Confirm"
    else
        local prompt="$1"
    fi

    for var in yn ysed nsed default; do local $var=''; done
    local messages=("${(@f)$(locale LC_MESSAGES)}")

    if [[ "$2" =~ ${messages[1]} ]]; then local ysed='s/./[\U&]/'; local default=0; fi
    if [[ "$2" =~ ${messages[2]} ]]; then local nsed='s/./[\U&]/'; local default=1; fi
    local yword=$(sed -e "${ysed:=s/./[&]/}" <<< ${messages[3]})
    local nword=$(sed -e "${nsed:=s/./[&]/}" <<< ${messages[4]})

    while true; do
        echo -n "$prompt ($yword/$nword) "
        read yn
        test -z "$yn" -a -n "$default" && return $default
        if [[ "$yn" =~ ${messages[1]} ]]; then return 0; fi
        if [[ "$yn" =~ ${messages[2]} ]]; then return 1; fi
    done
}
