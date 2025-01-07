function yadm-update-submodules() {
    local submodules=("${(@f)$(yadm -C ~ config --file .gitmodules --get-regexp path | awk '{print $2}')}")
    local pad=$(( $(printf '%s\n' "${submodules[@]}" | awk '{print length}' | sort -rn | head -1)+5 ))
    for submodule in "${submodules[@]}"; do
        local commit="$(git -C "$HOME/$submodule" ls-remote -qt --sort=committerdate | tail -n 1 | cut -f1)"
        if test -n "$commit"; then
            git -C "$HOME/$submodule" fetch
            git -C "$HOME/$submodule" checkout "$commit" |& xargs -r -d \\n -I {} printf "%-${pad}s %s\n" "[~/$submodule]:" '{}'
        else
            printf "%-${pad}s %s\n" "[~/$submodule]:" 'No tags were found'
        fi
    done
}
