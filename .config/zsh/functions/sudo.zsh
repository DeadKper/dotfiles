function sudo() {
    local args=()
    local iflag=-n
    while test "$#" -gt 0; do
        [[ "$1" == -* ]] || break
        case "$1" in
            --)
                args+=("$1")
                break
            ;;
            -n|--non-interactive)
                unset iflag
                args+=("$1")
                shift
            ;;
            -C|-D|-g|-h|-p|-R|-T|-U|-u)
                args+=("$1" "$2")
                shift 2
            ;;
            *)
                args+=("$1")
                shift
            ;;
        esac
    done
    local extra_args=()
    if test "$(env sudo $iflag --preserve-env=PATH -E "${args[@]}" echo y 2>&1)" = "$(env sudo -n echo y 2>&1)"; then
        extra_args=(--preserve-env=PATH -E)
    fi
    env sudo "${extra_args[@]}" "${args[@]}" "$@"
}

alias sudo="sudo "
