# Bootstrap antigen

local CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/antigen"
PLUGIN="$CACHE/antigen.zsh"
RC="$CACHE/antigenrc"
ANTIGEN_COMPDUMP="$CACHE/zcompdump"
ANTIGEN_CACHE="$CACHE/init.zsh"

ADOTDIR="${XDG_DATA_HOME:-$HOME/.local/share}/antigen"

test -d "$ADOTDIR" || mkdir -p "$ADOTDIR"
test -d "$CACHE" || mkdir -p "$CACHE"

if ! test -f "$PLUGIN"; then
	curl -q -L git.io/antigen > "$PLUGIN"
fi

if ! test -f "$RC"; then
	theme=romkatv/powerlevel10k

	bundles=(
		command-not-found
		git
		git-flow
		history
		npm
		pip
		python
		rsync

		zsh-users/zsh-autosuggestions
		"zsh-users/zsh-completions src"
		"zsh-users/zsh-history-substring-search ./zsh-history-substring-search.zsh"
		zsh-users/zsh-syntax-highlighting

		olets/zsh-abbr@main
		hlissner/zsh-autopair
	)

	{
		echo "antigen use oh-my-zsh"
		echo "antigen bundles <<EOF"
		printf '\t%s\n' "${bundles[@]}"
		echo "EOF"
		echo "antigen theme $theme"
		echo "antigen apply"
	} > "$RC"
fi

if test -f "$PLUGIN" -a -f "$RC"; then
	source "$PLUGIN"
	antigen init "$RC"
fi
