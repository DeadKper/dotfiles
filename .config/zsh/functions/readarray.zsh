function readarray() {
    if test "$1" != -t; then
        echo "only -t compatibility is currently supported" >&2
        return 1
    fi
    if test -t 0; then
        echo "function needs data to read from stdin" >&2
        return 1
    fi

    eval "$2=(\"\${(@f)\$(timeout 0.1 cat -)}\")"
}
