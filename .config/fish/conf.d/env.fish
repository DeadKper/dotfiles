set -x fish_greeting
set -x EDITOR nvim
set -x VISUAL nvim

if type -q setxkbmap
    set -x XKB_DEFAULT_LAYOUT (setxkbmap -query | grep layout | sed -r "s/^layout:\t* *(.*)/\1/g")
    set -x XKB_DEFAULT_VARIANT (setxkbmap -query | grep variant | sed -r "s/^variant:\t* *(.*)/\1/g")
end


if test -d ~/.surrealdb
    add-path PATH ~/.surrealdb
end

if test -z "$JDTLS_JVM_ARGS" -a -f "$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar"
    set -x JDTLS_JVM_ARGS "-javaagent:$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar"
end
