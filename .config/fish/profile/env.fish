set -x fish_greeting
set -x EDITOR nvim
set -x VISUAL nvim

if type -q setxkbmap
	set -x XKB_DEFAULT_LAYOUT (setxkbmap -query | grep layout | sed -r "s/^layout:\t* *(.*)/\1/g")
	set -x XKB_DEFAULT_VARIANT (setxkbmap -query | grep variant | sed -r "s/^variant:\t* *(.*)/\1/g")
end

if test -d ~/.local/bin
	fish_add_path ~/.local/bin
end

if test -d ~/.local/scripts
	fish_add_path ~/.local/scripts
end

if test -d ~/.surrealdb
	fish_add_path ~/.surrealdb
end

if test -z "$JDTLS_JVM_ARGS" -a -f "$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar"
	set -x JDTLS_JVM_ARGS "-javaagent:$HOME/.local/share/nvim/mason/packages/jdtls/lombok.jar"
end
