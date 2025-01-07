function yadm-update-submodules() {
    local submodules=("${(@f)$(yadm -C ~ config --file .gitmodules --get-regexp path | awk '{print $2}')}")
    local pad=$(( $(printf '%s\n' "${submodules[@]}" | awk '{print length}' | sort -rn | head -1)+5 ))

    trap 'unset -f git' EXIT

    function git() {
        env git -C "$HOME/$submodule" "$@"
    }

    for submodule in "${submodules[@]}"; do
        {
            git remote update
            if git show-ref --quiet --tags; then
                local commit="$(git ls-remote --quiet --tags --sort=committerdate \
                    | tail -n 1 \
                    | cut -f1)"

                git fetch
                git checkout "$commit"
            else
                if test -n "$(git symbolic-ref --quiet --short HEAD)"; then
                    git pull --rebase
                else
                    git checkout "$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')"
                    if git status -uno |& grep '^Your branch is behind'; then
                        git pull --rebase
                    fi
                fi
            fi
        } |& xargs -r -d \\n -I {} printf "%-${pad}s %s\n" "[~/$submodule]:" '{}'
    done
}
