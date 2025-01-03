function sudo() {
	local flags=(--preserve-env=PATH -sE)

    for arg in "$@"; do
        if grep -q '^-' <<< "$arg"; then
            if grep -qE 'k|K|i' <<< "$arg"; then
                set -f flags
			fi
        else
            break
		fi
	done

	env sudo "${flags[@]}" "$@"
}
