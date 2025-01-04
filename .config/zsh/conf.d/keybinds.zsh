[[ -o interactive ]] || return

function bindkey-word() {
    local keybind="$1"
    local command="$2"
    eval "
        function ${command}-to-space () {
            local WORDCHARS=\"|@*?_-.[]~=\\/&;!#\$%^(){}<>'\\\"\"
            zle ${command}
        }
        zle -N ${command}-to-space
        bindkey '${keybind}' ${command}-to-space
    "
}

# use alt + left/right to jump big word
bindkey-word "^[[1;3C" forward-word
bindkey-word "^[[1;3D" backward-word

bindkey '^[[Z' reverse-menu-complete

unset -f bindkey-word
